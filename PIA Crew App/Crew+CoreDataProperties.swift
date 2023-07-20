//
//  Crew+CoreDataProperties.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 02/11/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import Foundation
import CoreData


extension Crew {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Crew> {
        return NSFetchRequest<Crew>(entityName: "Crew");
    }

    @NSManaged public var base: String?
    @NSManaged public var designation: String?
    @NSManaged public var name: String?
    @NSManaged public var passcode: String?
    @NSManaged public var staffNo: String?
    @NSManaged public var dob: String?

}
