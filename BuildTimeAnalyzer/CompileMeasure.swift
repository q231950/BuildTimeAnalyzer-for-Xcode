//
//  CompileMeasure.swift
//  BuildTimeAnalyzer
//

import Foundation

@objcMembers class CompileMeasure: NSObject {
    
    dynamic var time: Double
    var path: String
    var code: String
    dynamic var filename: String
    var references: Int

    // baseline
    var baselineTime: Double?

    private var locationArray: [Int]

    public enum Order: String {
        case filename
        case time
    }

    var fileAndLine: String {
        return "\(filename):\(locationArray[0])"
    }

    var fileInfo: String {
        return "\(fileAndLine):\(locationArray[1])"
    }
    
    var location: Int {
        return locationArray[0]
    }
    
    var timeString: String {
        return String(format: "%.1fms", time)
    }
    
    init?(time: Double, rawPath: String, code: String, references: Int) {
        let untrimmedFilename = rawPath.split(separator: "/").map(String.init).last
        
        guard let filepath = rawPath.split(separator: ":").map(String.init).first,
            let filename = untrimmedFilename?.split(separator: ":").map(String.init).first else { return nil }
        
        let locationString = String(rawPath[filepath.endIndex...].dropFirst())
        let locations = locationString.split(separator: ":").compactMap{ Int(String.init($0)) }
        guard locations.count == 2 else { return nil }
        
        self.time = time
        self.code = code
        self.path = filepath
        self.filename = filename
        self.locationArray = locations
        self.references = references
        self.baselineTime = nil
    }

    init?(rawPath: String, time: Double) {
        let untrimmedFilename = rawPath.split(separator: "/").map(String.init).last

        guard let filepath = rawPath.split(separator: ":").map(String.init).first,
            let filename = untrimmedFilename?.split(separator: ":").map(String.init).first else { return nil }

        self.time = time
        self.code = ""
        self.path = filepath
        self.filename = filename
        self.locationArray = [1,1]
        self.references = 1
        self.baselineTime = nil
    }

    func write(into csv: CSVWriter) {
        csv.insert(line: ["\(self.time)", self.fileInfo, self.filename, "\(references)", self.baselineTime.map({"\($0)"}) ?? ""])
    }

    func makeBaseline() {
        self.baselineTime = self.time
    }

    subscript(column: Int) -> String {
        switch column {
        case 0:
            if let b = baselineTime {
                return "\(timeString) (\(b))"
            }
            return timeString
        case 1:
            return fileInfo
        case 2:
            return "\(references)"
        case 3:
            return code
        default:
            return baselineTime.map({"\(time / $0)"}) ?? ""
        }
    }
}
