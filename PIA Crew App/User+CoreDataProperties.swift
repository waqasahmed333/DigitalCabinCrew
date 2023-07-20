//
//  User+CoreDataProperties.swift
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

extension User {

    @NSManaged var ac: String?
    @NSManaged var crewBase: String?
    @NSManaged var password: String?
    @NSManaged var pos: String?
    @NSManaged var token: String?
    @NSManaged var username: String?

}
