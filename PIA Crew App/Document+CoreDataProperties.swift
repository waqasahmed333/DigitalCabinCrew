//
//  Document+CoreDataProperties.swift
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

extension Document {

    @NSManaged var date: Date?
    @NSManaged var docText: String?
    @NSManaged var section: String?
    @NSManaged var subSection: String?
    @NSManaged var title: String?

}
