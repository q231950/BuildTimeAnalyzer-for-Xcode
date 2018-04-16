//
//  ViewControllerDataSource.swift
//  BuildTimeAnalyzer
//
//  Created by Dmitrii on 02/12/2017.
//  Copyright © 2017 Cane Media Ltd. All rights reserved.
//

import Foundation

class ViewControllerDataSource {

    var aggregateByFile = false {
        didSet {
            processData()
        }
    }

    var filter = "" {
        didSet {
            processData()
        }
    }

    var sortDescriptors = [NSSortDescriptor]() {
        didSet {
            processData()
        }
    }

    private var originalData = [CompileMeasure]()
    private var processedData = [CompileMeasure]()

    private var baselines = [String: Double]()

    func csvExportableData() -> String {
        let writer = CSVWriter(labels: ["Time", "FileInfo", "FileName", "References"])
        for line in originalData {
            line.write(into: writer)
        }
        return writer.outputData()
    }

    func currentDataIsBaseline() {
        originalData.forEach { i in
            self.baselines[i.fileAndLine] = i.time
            i.baselineTime = -1
        }
    }

    func resetSourceData(newSourceData: [CompileMeasure]) {
        originalData = newSourceData.map { entry in
            if let existingbaseline = self.baselines[entry.fileAndLine] {
                entry.baselineTime = existingbaseline
            }
            return entry
        }
        processData()
    }

    func isEmpty() -> Bool {
        return processedData.isEmpty
    }

    func count() -> Int {
        return processedData.count
    }

    func measure(index: Int) -> CompileMeasure? {
        guard index < processedData.count && index >= 0 else { return nil }
        return processedData[index]
    }

    // MARK: - Private methods

    private func processData() {
        var newProcessedData = aggregateIfNeeded(originalData)
        newProcessedData = applySortingIfNeeded(newProcessedData)
        newProcessedData = applyFilteringIfNeeded(newProcessedData)

        processedData = newProcessedData
    }

    private func aggregateIfNeeded(_ input: [CompileMeasure]) -> [CompileMeasure] {
        guard aggregateByFile else { return input }
        var fileTimes: [String: CompileMeasure] = [:]
        for measure in input {
            if let fileMeasure = fileTimes[measure.path] {
                fileMeasure.time += measure.time
                fileTimes[measure.path] = fileMeasure
            } else {
                let newFileMeasure = CompileMeasure(rawPath: measure.path, time: measure.time)
                fileTimes[measure.path] = newFileMeasure
            }
        }
        return Array(fileTimes.values)
    }

    private func applySortingIfNeeded(_ input: [CompileMeasure]) -> [CompileMeasure] {
        if sortDescriptors.isEmpty { return input }
        return (input as NSArray).sortedArray(using: sortDescriptors) as! Array
    }

    private func applyFilteringIfNeeded(_ input: [CompileMeasure]) -> [CompileMeasure] {
        guard !filter.isEmpty else { return input }
        return input.filter{ textContains($0.code, pattern: filter) || textContains($0.filename, pattern: filter) }
    }

    private func textContains(_ text: String, pattern: String) -> Bool {
        return text.lowercased().contains(pattern.lowercased())
    }
}
