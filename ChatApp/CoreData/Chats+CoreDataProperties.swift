//
//  Chats+CoreDataProperties.swift
//  
//

import Foundation
import CoreData

extension Chats {
  
    @NSManaged public var dateLeft: String
    @NSManaged public var message: String
    @NSManaged public var status: String
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Chats> {
        return NSFetchRequest<Chats>(entityName: "Chats")
    }
}
