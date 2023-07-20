//
//  BadgeUtils.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 08/03/2020.
//  Copyright © 2020 Naveed Azhar. All rights reserved.
//

import Foundation
import RealmSwift

// Define your models like regular Swift classes
public class BadgeValue: Object {
    @objc dynamic var category = 0
    @objc dynamic var value = 0
}


class BadgeUtils: NSObject {
    
    public static let BADGE_CAT_QUALIFICATION = 1
    public static let BADGE_CAT_DOCUMENTS = 2
    
    class func getBadgeCount(_ category:Int) -> Int {
        
        let realm = try! Realm()
        
        let bvList = realm.objects(BadgeValue.self).filter("category = %@", category)
        
        if let bv = bvList.first {
            return bv.value
        }
        
        return 0
        
    }
    
    class func updateBadgeCount(_ category:Int, value:Int) {
        
        let realm = try! Realm()
        
        let bvList = realm.objects(BadgeValue.self).filter("category = %@", category)
        
        if let bv = bvList.first {
            try! realm.write {
                bv.value = value
            }
        } else {
            try! realm.write {
                let bv = BadgeValue()
                bv.category = category
                bv.value = value
                realm.add(bv)
            }
        }
        
    }
    
}

