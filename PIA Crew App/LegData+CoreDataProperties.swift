//
//  LegData+CoreDataProperties.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 06/11/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import Foundation
import CoreData


extension LegData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LegData> {
        return NSFetchRequest<LegData>(entityName: "LegData");
    }

    @NSManaged public var aircraft: String?
    @NSManaged public var arrKG: String?
    @NSManaged public var beforeRefuelingKGS: String?
    @NSManaged public var blocksOff: String?
    @NSManaged public var blocksOn: String?
    @NSManaged public var blockTime: String?
    @NSManaged public var captainDebrief: String?
    @NSManaged public var captainId: String?
    @NSManaged public var cat23: NSNumber?
    @NSManaged public var date: String?
    @NSManaged public var debrief: String?
    @NSManaged public var density: String?
    @NSManaged public var depKG: String?
    @NSManaged public var flag1: NSNumber?
    @NSManaged public var flag2: NSNumber?
    @NSManaged public var flag3: NSNumber?
    @NSManaged public var flag4: NSNumber?
    @NSManaged public var flag5: NSNumber?
    @NSManaged public var fltNo: String?
    @NSManaged public var from: String?
    @NSManaged public var fuelUpLiftQty: String?
    @NSManaged public var fuelUplUnit: NSNumber?
    @NSManaged public var instTime: String?
    @NSManaged public var landFlag: String?
    @NSManaged public var landing: String?
    @NSManaged public var legNo: NSNumber?
    @NSManaged public var nightTime: String?
    @NSManaged public var primaryDate: String?
    @NSManaged public var primaryFltNo: String?
    @NSManaged public var primaryFrom: String?
    @NSManaged public var reasonForExtraFuel: String?
    @NSManaged public var reg: String?
    @NSManaged public var source: String?
    @NSManaged public var sta: String?
    @NSManaged public var std: String?
    @NSManaged public var takeOff: String?
    @NSManaged public var to: String?
    @NSManaged public var toFlag: String?
    @NSManaged public var totalUplift: String?
    @NSManaged public var uploadStatus: String?
    @NSManaged public var zeroFuelWt: String?
    @NSManaged public var dblDept1: NSNumber?
    @NSManaged public var dblDept2: NSNumber?
    @NSManaged public var dblDept3: NSNumber?
    @NSManaged public var dblDept4: NSNumber?
    @NSManaged public var dblDept5: NSNumber?
    @NSManaged public var dblDept6: NSNumber?
    @NSManaged public var dblDept7: NSNumber?
    @NSManaged public var dblDept8: NSNumber?
    @NSManaged public var depDelay: String?
    @NSManaged public var arrDelay: String?

}
