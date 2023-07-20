//
//  PresistanceStorage.swift
//  PIA Crew App
//
//  Created by Admin on 08/06/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit

class PresistanceStorage {

    
    
    fileprivate static let defaults = UserDefaults.standard
    
    
    static func saveDeletedID(_ data:String , key:String){
        
        self.defaults.set(data, forKey: key)
 
    }
    
    static func isDeleted(_ key:String)->Bool{
        
        if let data = self.defaults.object(forKey: key) {
            
            return true
        }else{
            return false

            
        }
    }
    
    static func removeData(){
        
        for key in Array(self.defaults.dictionaryRepresentation().keys) {
            self.defaults.removeObject(forKey: key)
        }
    }
}
