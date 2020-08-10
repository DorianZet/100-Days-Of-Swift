//
//  Commit+CoreDataClass.swift
//  Project38
//
//  Created by Mateusz Zacharski on 25/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Commit)
public class Commit: NSManagedObject {
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("Init called!")
    }
}
