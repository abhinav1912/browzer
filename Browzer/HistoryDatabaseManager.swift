//

import Foundation
import SQLite3

class HistoryDatabaseManager {
    let dbFilename = ""
    var database: OpaquePointer?

    init() {
        database = openDatabase()
        self.createTable(using: createUrlsTableString)
        self.createTable(using: createVisitsTableString)
    }

    func openDatabase() -> OpaquePointer? {
        var db: OpaquePointer?
        guard sqlite3_open(dbFilename, &db) == SQLITE_OK else {
            print("Unable to open database at path \(dbFilename)")
            return nil
        }
        print("Successfully opened database at path \(dbFilename)")
        return db
    }

    // MARK: Private

    private let createUrlsTableString = """
        CREATE TABLE IF NOT EXISTS Url(
        Id INT PRIMARY AUTOINCREMENT,
        url VARCHAR(MAX),
        title VARCHAR(MAX),
        visit_count INT,
        last_visit_time INT);
    """

    private let createVisitsTableString = """
        CREATE TABLE IF NOT EXISTS Url(
        Id INT PRIMARY AUTOINCREMENT,
        url VARCHAR(MAX),
        last_visit_time INT);
    """

    private func createTable(using createTableString: String) {
        var createTableStatement: OpaquePointer?

        if sqlite3_prepare_v2(database, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Table created successfully")
            } else {
                print("Table creation successfully")
            }
        } else {
            print("CreateTable statement wasn't prepared")
        }
        sqlite3_finalize(createTableStatement)
    }
}
