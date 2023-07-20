//
//  FlightPlan+CoreDataProperties.swift
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

extension FlightPlan {

    @NSManaged var aircraft: String?
    @NSManaged var arrStation: String?
    @NSManaged var crewId: String?
    @NSManaged var date: String?
    @NSManaged var depStation: String?
    @NSManaged var documentName: String?
    @NSManaged var flightNumber: String?
    @NSManaged var sta: String?
    @NSManaged var std: String?
    @NSManaged var url: String?

}
