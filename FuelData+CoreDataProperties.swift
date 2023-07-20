//
//  FuelData+CoreDataProperties.swift
//  
//
//  Created by Naveed Azhar on 07/09/2016.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension FuelData {

    @NSManaged var arrKG: String?
    @NSManaged var cat23: NSNumber?
    @NSManaged var date: String?
    @NSManaged var density: String?
    @NSManaged var depKG: String?
    @NSManaged var fltNo: String?
    @NSManaged var from: String?
    @NSManaged var fuelUpLiftQty: String?
    @NSManaged var fuelUplUnit: NSNumber?
    @NSManaged var legNo: String?
    @NSManaged var primaryFltDate: String?
    @NSManaged var primaryFltNo: String?
    @NSManaged var primaryFrom: String?
    @NSManaged var toPwrFR: String?
    @NSManaged var zeroFuelWt: String?

}
