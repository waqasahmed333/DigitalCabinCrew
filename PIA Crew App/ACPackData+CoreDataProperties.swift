//
//  ACPackData+CoreDataProperties.swift
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

extension ACPackData {

    @NSManaged var cruiseDataLegNo: String?
    @NSManaged var date: String?
    @NSManaged var eGTTTL: String?
    @NSManaged var eGTTTR: String?
    @NSManaged var engineBleedL: String?
    @NSManaged var engineBleedR: String?
    @NSManaged var ePRTQL: String?
    @NSManaged var ePRTQR: String?
    @NSManaged var flightLevel: String?
    @NSManaged var fltNo: String?
    @NSManaged var from: String?
    @NSManaged var fuelFlowL: String?
    @NSManaged var fuelFlowR: String?
    @NSManaged var grossWeight: String?
    @NSManaged var ias: String?
    @NSManaged var legNo: String?
    @NSManaged var mach: String?
    @NSManaged var n1NPL: String?
    @NSManaged var n1NPR: String?
    @NSManaged var n2NHL: String?
    @NSManaged var n2NHR: String?
    @NSManaged var nacTempL: String?
    @NSManaged var nacTempR: String?
    @NSManaged var oilPressL: String?
    @NSManaged var oilPressR: String?
    @NSManaged var primaryFltNo: String?
    @NSManaged var primaryFrom: String?
    @NSManaged var primaryFltDate: String?
    @NSManaged var sat: String?
    @NSManaged var tat: String?
    @NSManaged var vIBN1L: String?
    @NSManaged var vIBN1R: String?
    @NSManaged var vIBN2L: String?
    @NSManaged var vIBN2R: String?
    @NSManaged var oilTempL: String?
    @NSManaged var oilTempR: String?

}
