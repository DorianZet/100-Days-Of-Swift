//
//  scriptSavedForTableView.swift
//  Extension
//
//  Created by MacBook on 01/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//


import Foundation

class scriptSavedForTableView: NSObject, Codable {
    var tableName: String?
    var tableScript: String?
    
    init (tableName: String, tableScript: String) {
        self.tableName = tableName
        self.tableScript = tableScript
    }
}
