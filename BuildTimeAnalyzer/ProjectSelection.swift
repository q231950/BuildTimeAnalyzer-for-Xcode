//
//  ProjectSelection.swift
//  BuildTimeAnalyzer
//

import Cocoa

protocol ProjectSelectionDelegate: class {
    func didSelectProject(with database: XcodeDatabase)
    func didUpdateSelectedProject(with database: XcodeDatabase)
}

class ProjectSelection: NSObject {
    
    @IBOutlet weak var tableView: NSTableView!
    weak var delegate: ProjectSelectionDelegate?
    
    private var dataSource: [XcodeDatabase] = []

    private var lastSelection: Int? = nil
    
    static private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    func listFolders() {
        dataSource = DerivedDataManager.derivedData().compactMap{
            XcodeDatabase(fromPath: $0.url.appendingPathComponent("Logs/Build/Cache.db").path)
        }.sorted(by: { $0.modificationDate > $1.modificationDate })
        
        tableView.reloadData()

        if let last = lastSelection {
            delegate?.didUpdateSelectedProject(with: dataSource[last])
        }
    }
    
    // MARK: Actions
    
    @IBAction func didSelectCell(_ sender: NSTableView) {
        guard sender.selectedRow != -1 else { return }
        lastSelection = sender.selectedRow
        delegate?.didSelectProject(with: dataSource[sender.selectedRow])
    }
}

// MARK: NSTableViewDataSource

extension ProjectSelection: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSource.count
    }
}

// MARK: NSTableViewDelegate

extension ProjectSelection: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn, let columnIndex = tableView.tableColumns.index(of: tableColumn) else { return nil }
        
        let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell\(columnIndex)"), owner: self) as? NSTableCellView
        
        let source = dataSource[row]
        var value = ""
        
        switch columnIndex {
        case 0:
            value = source.schemeName
        default:
            value = ProjectSelection.dateFormatter.string(from: source.modificationDate)
        }
        cellView?.textField?.stringValue = value
        
        return cellView
    }
}
