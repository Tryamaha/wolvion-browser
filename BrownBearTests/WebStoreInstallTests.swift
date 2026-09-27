//
//  WebStoreInstallTests.swift
//  BrownBearTests
//
//  The Chrome Web Store install bookkeeping that backs the in-page "Add / Remove from BrownBear"
//  button: recording the originating store id, looking an installed extension back up by it, and
//  re-installing from the same store page replacing (not duplicating) the prior copy.
//

import XCTest
@testable import BrownBear

final class WebStoreInstallTests: XCTestCase {

    private func archive(name: String) -> Data {
        let manifest = "{\"manifest_version\":3,\"name\":\"\(name)\",\"version\":\"1.0\"}"
        return TestZip.make([
            (name: "manifest.json", data: Data(manifest.utf8)),
            (name: "c.js", data: Data("/* content */".utf8))
        ])
    }

    private func tempStore() -> (WebExtensionStore, URL) {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("bb-store-\(UUID().uuidString)")
        return (WebExtensionStore(baseDirectory: dir), dir)
    }

    private let storeID = "cjpalhdlnbpafiamejdnhcphjbkeiagm"

    func testStoreIDRecordedAndLookedUp() async throws {
        let (store, dir) = tempStore()
        defer { try? FileManager.default.removeItem(at: dir) }

        let installed = try await store.install(archive: archive(name: "Blocker"), storeID: storeID,
                                                authorize: { _ in true })
        XCTAssertEqual(installed.storeID, storeID)
        XCTAssertNotEqual(installed.id, storeID, "the local id is generated, not the store id")

        let found = await store.installed(forStoreID: storeID)
        XCTAssertEqual(found?.id, installed.id)
        let missing = await store.installed(forStoreID: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
        XCTAssertNil(missing)
    }

    func testSideloadedArchiveHasNoStoreID() async throws {
        let (store, dir) = tempStore()
        defer { try? FileManager.default.removeItem(at: dir) }

        let installed = try await store.install(archive: archive(name: "Sideload"), authorize: { _ in true })
        XCTAssertNil(installed.storeID)
        let found = await store.installed(forStoreID: storeID)
        XCTAssertNil(found)
    }

    func testReinstallFromSameStorePageReplaces() async throws {
        let (store, dir) = tempStore()
        defer { try? FileManager.default.removeItem(at: dir) }

        let first = try await store.install(archive: archive(name: "V1"), storeID: storeID,
                                            authorize: { _ in true })
        let second = try await store.install(archive: archive(name: "V2"), storeID: storeID,
                                             authorize: { _ in true })

        let all = await store.all()
        XCTAssertEqual(all.count, 1, "re-installing the same store id replaces, never duplicates")
        XCTAssertEqual(all.first?.id, second.id)
        XCTAssertNotEqual(first.id, second.id)
        let superseded = await store.ext(for: first.id)
        XCTAssertNil(superseded, "the superseded copy is gone")
    }

    func testStoreIDSurvivesReopen() async throws {
        let (store, dir) = tempStore()
        defer { try? FileManager.default.removeItem(at: dir) }

        _ = try await store.install(archive: archive(name: "Persisted"), storeID: storeID,
                                    authorize: { _ in true })
        let reopened = WebExtensionStore(baseDirectory: dir)
        let found = await reopened.installed(forStoreID: storeID)
        XCTAssertEqual(found?.displayName, "Persisted")
    }

    func testCodableRoundTripPreservesStoreID() throws {
        let ext = WebExtension(id: String(repeating: "a", count: 32),
                               manifestJSON: "{\"name\":\"X\",\"version\":\"1\"}",
                               storeID: storeID)
        let data = try JSONEncoder().encode(ext)
        let decoded = try JSONDecoder().decode(WebExtension.self, from: data)
        XCTAssertEqual(decoded.storeID, storeID)
    }

    func testDecliningReinstallPreservesInstalledExtension() async throws {
        let (store, dir) = tempStore()
        defer { try? FileManager.default.removeItem(at: dir) }
        let original = try await store.install(archive: archive(name: "Original"), storeID: storeID,
                                               authorize: { _ in true })

        do {
            _ = try await store.install(archive: archive(name: "Replacement"), storeID: storeID,
                                        authorize: { manifest in
                                            XCTAssertEqual(manifest.name, "Replacement")
                                            return false
                                        })
            XCTFail("declined extension must not be installed")
        } catch BrownBearError.extensionInstallDeclined {
            let retained = await store.installed(forStoreID: storeID)
            XCTAssertEqual(retained?.id, original.id)
            XCTAssertEqual(retained?.displayName, "Original")
        }
    }

    func testReviewShowsRequiredOptionalAndScriptSiteAccess() throws {
        let manifest = try WebExtensionManifest.parse([
            "manifest_version": 3, "name": "Conso", "version": "0.1.4",
            "permissions": ["identity", "scripting", "storage"],
            "host_permissions": ["https://conso.xyz/*"],
            "optional_host_permissions": ["https://chatgpt.com/*"],
            "content_scripts": [["matches": ["https://example.com/*"], "js": ["content.js"]]]
        ])
        let review = WebExtensionInstallPrompt.reviewText(for: manifest)
        XCTAssertTrue(review.contains("identity, scripting, storage"))
        XCTAssertTrue(review.contains("Required site access: https://conso.xyz/*"))
        XCTAssertTrue(review.contains("May request sites later: https://chatgpt.com/*"))
        XCTAssertTrue(review.contains("Sites where scripts run: https://example.com/*"))
    }
}
