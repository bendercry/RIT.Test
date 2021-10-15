//
//  DBHelper.swift
//  task1
//
//  Created by Kirill Benderskii on 08.10.2021.
//

import Foundation
import SQLite3

class DBHelper{
    
    private var path: String = "myDb.sqlite"
    private var db: OpaquePointer?
    
    init(){
        self.db = createDB()
        self.createTable(query: "CREATE TABLE IF NOT EXISTS statistics (dist REAL, time INTEGER)")
        self.createTable(query: "CREATE TABLE IF NOT EXISTS config (idx INTEGER PRIMARY KEY, isMPH INTEGER);")
    }
    
    func createDB() -> OpaquePointer?{
        
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(path)
            var db: OpaquePointer? = nil
            
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK
            {
                print("Error opening database")
                return nil
            }
            else
            {
                print("Successfully opened connection to database at \(path)")
                return db
            }
    }
    
    func createTable(query: String){
        var statement: OpaquePointer? = nil
        if sqlite3_prepare(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Table creation success")
            }
            else{
                print("Table creation fail")
            }
        }
        else{
            print("Preparation fail")
        }
    }
    
    
    func insertStat(dist: Double, time: Int){
            
            let query = "INSERT INTO statistics (dist, time) VALUES (?, ?);"
            
            var statement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                print(dist)
                sqlite3_bind_double(statement, 1, Double(dist))
                sqlite3_bind_int(statement, 2, Int32(time))
                if sqlite3_step(statement) == SQLITE_DONE {
                    print("Successfully inserted row.")
                } else {
                    print("Could not insert row.")
                }
            } else {
                print("INSERT statement could not be prepared.")
            }
            sqlite3_finalize(statement)
    }
    
    func insertMPH(isMPH: Bool){
        let query = "REPLACE INTO config (idx, isMPH) VALUES (?, ?);"
        
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(1))
            sqlite3_bind_int(statement, 2, Int32(isMPH ? 1 : 0))
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(statement)
    }
    
    func drop(){
        var stat = "DROP TABLE IF EXISTS statistics;"
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, stat, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE{
                print("Table has dropped")
            }
        }
        stat = "DROP TABLE IF EXISTS config;"
        statement = nil
        if sqlite3_prepare_v2(db, stat, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE{
                print("Table has dropped")
            }
        }
    }
    
    func readStat() -> [DbFiles] {
            var mainList = [DbFiles]()
            
            let query = "SELECT dist, time FROM statistics ORDER BY time DESC;"
            var statement : OpaquePointer? = nil
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
                while sqlite3_step(statement) == SQLITE_ROW {
                    
                    let dist = Double(sqlite3_column_double(statement, 0))
                    let time = Int(sqlite3_column_int(statement, 1))
                    let model = DbFiles()
                    model.dist = dist
                    model.time = time
                    print(model)
                    mainList.append(model)
                }
            }
            return mainList
    }
    
    func readConfig() -> Bool{
        let query = "SELECT * from config"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW {
                let isMPH = Int(sqlite3_column_int(statement, 1))
                return isMPH != 0
            }
        }
        return false
    }
    
}
