//
//  DocNotificationUtils.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 19/03/2020.
//  Copyright © 2020 Naveed Azhar. All rights reserved.
//

import Foundation
import SwiftyJSON



public class DocNotificationUtils {
    
    public static func getUnreadCircularsOrSectionBadgeCount() -> Int {
        
        var badgeCount = 0
        
        for k in circular_keys {
            badgeCount += self.getUnreadCircularsBadgeCount(section: "Circular/" + k)
        }
        
        return badgeCount
    }
    
    public static func getUnreadCircularsBadgeCount(section:String!) -> Int {
        
        var badgeCount = 0
        if let data = UserDefaults.standard.object(forKey: "JSON-" + section) as AnyObject? {
            let object = JSON(data)
            
            for document in object["DocumentList"].arrayValue {
                
                let name = document["Name"].stringValue
                
                if  (!name.isFileAvailable()) {
                    badgeCount += 1
                }
            }
        } else {
            return 1
        }
        
        return badgeCount
    }

}

