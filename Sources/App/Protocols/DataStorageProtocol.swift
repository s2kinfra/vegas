//
//  DataStorageProtocol.swift
//  App
//
//  Created by Daniel Skevarp on 2018-02-02.
//

import Foundation
import FluentProvider

typealias dataStorageRow = [String : Any]
typealias dataStorageACLRow = [String : [DataACL]]
enum DataACL {
    case json, row, priv, guest
}

protocol DataStorage : class {
    //    var JSONData : [String : Any] {get set}
    //    var RowData : [String : Any] {get set}
    //    var PrivateData : [String : Any] { get set }
    var dataStorage : dataStorageRow {get set}
    var dataStorageACL : dataStorageACLRow {get set}
    func getData(level : DataACL) throws -> dataStorageRow
    func getDataFor<T>(key : String) -> T?
    func initDatalevels()
    func setDataLevel(key : String, level : DataACL)
    func setDataLevel(key : String, levels : [DataACL])
    func getJSONFromStorageData(levels : [DataACL]) throws -> JSON
}

extension DataStorage {
    
    func getJSONFromStorageData(levels : [DataACL]) throws -> JSON{
        var json = JSON()
        for level in levels {
            for data in try getData(level: level).enumerated() {
                try json.set(data.element.key,data.element.value)
            }
        }
        return json
    }
    
    func getDataFor<T>(key : String) -> T? {
        guard let row = self.dataStorage[key] as? Row else {
            return self.dataStorage[key] as? T
        }
        let data = row.wrapped
        
        switch data {
        case .bool(let b) :
            return b as? T
        case .number(let num):
            switch num {
            case .int(let i) :
                return i as? T
            case .double(let d) :
                return d as? T
            case .uint(let ui):
                return ui as? T
            }
            
        case .string(let s):
            return s as? T
        case .array(let ar):
            return ar as? T
        case .object(let sd):
            return sd as? T
        case .null:
            return nil
        case .bytes(let b):
            return b as? T
        case .date(let date):
            return date as? T
        }
    }
    
    func getData(level: DataACL) throws -> dataStorageRow {
        var aclData = [String : Any]()
        for(k,v) in self.dataStorageACL {
            if v.contains(level) {
                if let value = dataStorage[k] {
                    aclData[k] = value
                }
            }
        }
        return aclData
    }
    
    func setDataLevel(key: String, level: DataACL) {
        guard self.dataStorageACL[key] != nil else {
            self.dataStorageACL[key] = [level]
            return
        }
        self.dataStorageACL[key]?.append(level)
    }
    
    func setDataLevel(key: String, levels: [DataACL]) {
        for level in levels {
            if let dl = self.dataStorageACL[key] {
                if !dl.contains(level){
                    self.dataStorageACL[key]?.append(level)
                }
            }else{
                self.dataStorageACL[key] = [level]
            }
        }
    }
}

