//
//  UDutils.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 12/26/17.
//  Copyright © 2017 Naveed Azhar. All rights reserved.
//

import Foundation


import UIKit
import CoreData


class UDUtils: NSObject {
    
    class func getValue(forKey:String, defaultValue:String) -> String!  {
        if  let x =    UserDefaults.standard.value(forKey: forKey)  {
            return x as! String
        }
        return defaultValue
    }
    
    class func setValue(forKey:String, value:String) {

        UserDefaults.standard.set(value, forKey: forKey)
        
    }
    
    class func removeValue(forKey:String) {
        
        UserDefaults.standard.removeObject(forKey: forKey)
        
    }
    
}

