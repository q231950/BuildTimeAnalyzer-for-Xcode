final class CSVWriter {
    let labels: [String]
    var data: [[String]] = []

    private let lineSeperator: String
    private let fieldSeperator: String

    init(labels: [String], lineSeperator: String = "\n", fieldSeperator: String = ";") {
        self.labels = labels
        self.lineSeperator = lineSeperator
        self.fieldSeperator = fieldSeperator
    }

    func insert(line: [String]) {
        data.append(line)
    }

    func outputData() -> String {
        var output = labels.joined(separator: fieldSeperator)
        output.append(self.lineSeperator)
        for line in data {
            output.append("\(line.joined(separator: fieldSeperator))\(lineSeperator)")
        }
        return output
    }
}
