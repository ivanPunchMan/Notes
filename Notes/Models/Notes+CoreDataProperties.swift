//
//  Notes+CoreDataProperties.swift
//  Notes
//
//  Created by Admin on 05.02.2022.
//
//

import Foundation
import CoreData


extension Notes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notes> {
        return NSFetchRequest<Notes>(entityName: "Notes")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: String?
    @NSManaged public var dateCreate: Date?
    @NSManaged public var title: String?

}
