//
//  Favorite+CoreDataProperties.swift
//  
//
//  Created by Burak Turhan on 4.04.2023.
//
//

import Foundation
import CoreData


extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var full_name: String?
    @NSManaged public var is_favorited: Bool

}
