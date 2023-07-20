//
//  CrewMessage+CoreDataProperties.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 24/06/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CrewMessage {

    @NSManaged var dateTime: String?
    @NSManaged var id: String?
    @NSManaged var text: String?
    @NSManaged var type: String?

}
