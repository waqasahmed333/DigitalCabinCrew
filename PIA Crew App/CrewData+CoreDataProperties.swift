//
//  CrewData+CoreDataProperties.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 26/10/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import Foundation
import CoreData


extension CrewData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CrewData> {
        return NSFetchRequest<CrewData>(entityName: "CrewData");
    }

    @NSManaged public var date: String?
    @NSManaged public var fltNo: String?
    @NSManaged public var from: String?
    @NSManaged public var gmt: String?
    @NSManaged public var pos: String?
    @NSManaged public var primaryDate: String?
    @NSManaged public var primaryFltNo: String?
    @NSManaged public var primaryFrom: String?
    @NSManaged public var sno: String?
    @NSManaged public var source: String?
    @NSManaged public var staffno: String?
    @NSManaged public var status: String?
    @NSManaged public var stn: String?
    @NSManaged public var uploadStatus: String?

}
