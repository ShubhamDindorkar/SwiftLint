import Dispatch
import Foundation

// Inspired by https://github.com/jkandzi/Progress.swift
actor ProgressBar {
    private var index = 1
    private var lastPrintedTime: TimeInterval = 0.0
    private let startTime = uptime()
    private let count: Int
    private var lastLineLength = 0

    init(count: Int) {
        self.count = count
    }

    func initialize() {
        // When progress is printed, the previous line is reset, so print an empty line before anything else
        queuedPrintError("")
    }

    func printNext() {
        guard index <= count else { return }

        let currentTime = uptime()
        if currentTime - lastPrintedTime > 0.1 || index == count {
            #if os(Windows)
            // On Windows, use carriage return to overwrite the line
            let lineReset = "\r"
            #else
            // On Unix systems, use ANSI escape codes
            let lineReset = "\u{1B}[1A\u{1B}[K"
            #endif
            
            let bar = makeBar()
            let timeEstimate = makeTimeEstimate(currentTime: currentTime)
            let lineContents = "\(index) of \(count) \(bar) \(timeEstimate)"
            
            #if os(Windows)
            // Pad with spaces to clear any remnants of the previous line
            let padding = String(repeating: " ", count: max(0, lastLineLength - lineContents.count))
            queuedPrintError("\(lineReset)\(lineContents)\(padding)")
            lastLineLength = lineContents.count
            #else
            queuedPrintError("\(lineReset)\(lineContents)")
            #endif
            
            lastPrintedTime = currentTime
        }

        index += 1
    }

    // MARK: - Private

    private func makeBar() -> String {
        let barLength = 30
        let completedBarElements = Int(Double(barLength) * (Double(index) / Double(count)))
        let barArray = Array(repeating: "=", count: completedBarElements) +
            Array(repeating: " ", count: barLength - completedBarElements)
        return "[\(barArray.joined())]"
    }

    private func makeTimeEstimate(currentTime: TimeInterval) -> String {
        let totalTime = currentTime - startTime
        let itemsPerSecond = Double(index) / totalTime
        let estimatedTimeRemaining = Double(count - index) / itemsPerSecond
        let estimatedTimeRemainingString = "\(Int(estimatedTimeRemaining))s"
        return "ETA: \(estimatedTimeRemainingString) (\(Int(itemsPerSecond)) files/s)"
    }
}

#if os(Linux)
// swiftlint:disable:next identifier_name
private let NSEC_PER_SEC = 1_000_000_000
#endif

private func uptime() -> TimeInterval {
    Double(DispatchTime.now().uptimeNanoseconds) / 1_000_000_000
}
