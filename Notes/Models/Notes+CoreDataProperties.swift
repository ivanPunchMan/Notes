//
//  Notes+CoreDataProperties.swift
//  Notes
//
//  Created by Admin on 05.03.2022.
//
//

import Foundation
import CoreData


extension Notes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notes> {
        return NSFetchRequest<Notes>(entityName: "Notes")
    }

    @NSManaged public var content: NSMutableAttributedString?
    @NSManaged public var date: String?
    @NSManaged public var dateCreate: Date?

}

extension Notes : Identifiable {

}
