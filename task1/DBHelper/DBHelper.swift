//
//  DBHelper.swift
//  task1
//
//  Created by Kirill Benderskii on 08.10.2021.
//

import Foundation
import SQLite3

class DBHelper{
    var db: OpaquePointer?
    var path: String = "myDb.sqlite"
    init(){
        self.db = createDB()
        self.createTable(query: "CREATE TABLE IF NOT EXISTS statistics (dist REAL, isMPH INTEGER, time INTEGER)")
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
    
    
    func insert(dist: Double, time: Int, isMPH: Bool){
            
            let query = "INSERT INTO statistics (dist, isMPH, time) VALUES (?, ?, ?);"
            
            var statement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                print(dist)
                sqlite3_bind_double(statement, 1, Double(dist))
                sqlite3_bind_int(statement, 2, isMPH ? Int32(1) : Int32(0))
                sqlite3_bind_int(statement, 3, Int32(time))
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
        let stat = "DROP TABLE IF EXISTS statistics;"
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, stat, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE{
                print("Table has dropped")
            }
        }
    }
    
    func read() -> [DbFiles] {
            var mainList = [DbFiles]()
            
            let query = "SELECT dist, isMPH, time FROM statistics ORDER BY time DESC;"
            var statement : OpaquePointer? = nil
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
                while sqlite3_step(statement) == SQLITE_ROW {
                    
                    let dist = Double(sqlite3_column_double(statement, 0))
                    let isMPH = Int(sqlite3_column_int(statement, 1))
                    let time = Int(sqlite3_column_int(statement, 2))
                    let model = DbFiles()
                    model.dist = dist
                    model.isMPH = isMPH == 0
                    model.time = time
                        
                    mainList.append(model)
                }
            }
            return mainList
    }
}
