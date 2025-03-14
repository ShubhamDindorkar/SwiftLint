import ArgumentParser
import Foundation
import SwiftLintFramework

extension SwiftLint {
    struct Docs: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Open SwiftLint documentation website in the default web browser"
        )

        @Argument(help: "The identifier of the rule to open the documentation for")
        var ruleID: String?

        func run() throws {
            var subPage = ""
            if let ruleID {
                if RuleRegistry.shared.rule(forID: ruleID) == nil {
                    Issue.genericWarning("There is no rule named '\(ruleID)'. Opening rule directory instead.").print()
                    subPage = "rule-directory.html"
                } else {
                    subPage = ruleID + ".html"
                }
            }
            try open(url: URL(string: "https://realm.github.io/SwiftLint/\(subPage)")!)
        }
    }
}

func open(url: URL) throws {
    let process = Process()
    #if os(Windows)
    process.executableURL = URL(fileURLWithPath: "cmd.exe")
    process.arguments = ["/c", "start", url.absoluteString]
    try process.run()
    #else
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    let command = "open"
    process.arguments = [command, url.absoluteString]
    try process.run()
    #endif
}
