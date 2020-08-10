//
//  Author+CoreDataProperties.swift
//  Project38
//
//  Created by Mateusz Zacharski on 28/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//
//

import Foundation
import CoreData


extension Author {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Author> {
        return NSFetchRequest<Author>(entityName: "Author")
    }

    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var commits: NSSet

}

// MARK: Generated accessors for commits
extension Author {

    @objc(addCommitsObject:)
    @NSManaged public func addToCommits(_ value: Commit)

    @objc(removeCommitsObject:)
    @NSManaged public func removeFromCommits(_ value: Commit)

    @objc(addCommits:)
    @NSManaged public func addToCommits(_ values: NSSet)

    @objc(removeCommits:)
    @NSManaged public func removeFromCommits(_ values: NSSet)

}
