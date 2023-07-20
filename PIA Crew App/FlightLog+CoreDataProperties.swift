//
//  FlightLog+CoreDataProperties.swift
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

extension FlightLog {

    @NSManaged var aircraftType: String?
    @NSManaged var ccCount: String?
    @NSManaged var fdCount: String?
    @NSManaged var id: String?
    @NSManaged var legs: String?
    @NSManaged var pageno: String?
    @NSManaged var primaryFltDate: String?
    @NSManaged var primaryFltNo: String?
    @NSManaged var primaryFrom: String?
    @NSManaged var registration: String?
    @NSManaged var status: String?
    @NSManaged var totalTNGLandings: String?

}
