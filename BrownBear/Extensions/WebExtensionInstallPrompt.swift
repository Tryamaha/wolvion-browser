//
//  WebExtensionInstallPrompt.swift
//  BrownBear
//
//  Reviews the actual downloaded extension package before it can be written to disk. The store
//  requires this decision for every install entry point; optional permissions are shown here for
//  awareness and still require their own consent when requested at runtime.
//

import UIKit

enum WebExtensionInstallPrompt {

    @MainActor
    static func request(manifest: WebExtensionManifest) async -> Bool {
        await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
            let scene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }
            guard let window = scene?.windows.first(where: \.isKeyWindow),
                  window.rootViewController != nil else {
                continuation.resume(returning: false)
                return
            }

            let alert = UIAlertController(title: "Install \(manifest.name)?",
                                          message: reviewText(for: manifest),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                continuation.resume(returning: false)
            })
            alert.addAction(UIAlertAction(title: "Install", style: .default) { _ in
                continuation.resume(returning: true)
            })
            TopViewControllerPresenter.present(alert)
        }
    }

    /// Lists required access separately from access the extension can ask for later. A content
    /// script's matches also matter: it can run code on matching pages without a host grant.
    static func reviewText(for manifest: WebExtensionManifest) -> String {
        var lines = ["Version \(manifest.version) · Manifest V\(manifest.manifestVersion)"]
        lines.append(section("Required APIs", values: manifest.permissions))
        lines.append(section("Required site access", values: manifest.hostPermissions))
        let scriptSites = manifest.contentScripts.flatMap(\.matches)
        lines.append(section("Sites where scripts run", values: scriptSites))
        lines.append(section("May request APIs later", values: manifest.optionalPermissions))
        lines.append(section("May request sites later", values: manifest.optionalHostPermissions))
        lines.append("Only install extensions you trust. This review does not verify the extension's code or safety.")
        return lines.joined(separator: "\n\n")
    }

    private static func section(_ title: String, values: [String]) -> String {
        let unique = Array(Set(values)).sorted()
        guard !unique.isEmpty else { return "\(title): none" }
        let shown = unique.prefix(12).joined(separator: ", ")
        let remainder = unique.count > 12 ? " (+\(unique.count - 12) more)" : ""
        return "\(title): \(shown)\(remainder)"
    }
}
