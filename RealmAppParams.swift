//
//  RealmAppParams.swift
//  FlightLog
//
//  Created by Naveed Azhar on 05/02/2020.
//  Copyright © 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import RealmSwift



class RealmAppParams: Object {
    @objc dynamic var lastRequestTimeFPFlights : Date?
    @objc dynamic var lastRequestTimeFPPlans : Date?
    @objc dynamic var minDelaySecFPFlightsRefreshRequest : Double = 5.0 * 60.0
    @objc dynamic var minDelaySecFPPlansRefreshRequest : Double = 5.0 * 60.0
}


class RealmParamsUtils: NSObject {
    
    
    static let shared = RealmParamsUtils()
    
    //Initializer access level change now
    private override init(){
        super.init()
        
        let realm = try! Realm()
        
        let paramobjects = realm.objects(RealmAppParams.self)
        
        
        if let paramsobj = paramobjects.first  {
            try! realm.write {
                paramsobj.lastRequestTimeFPFlights = Date()
                paramsobj.lastRequestTimeFPPlans = Date()
                paramsobj.minDelaySecFPFlightsRefreshRequest = 1.0 * 60.0
                paramsobj.minDelaySecFPPlansRefreshRequest = 1.0 * 60.0
            }
        } else {
            
            let paramsobj = RealmAppParams()
            // Persist your data easily
            try! realm.write {
                realm.add(paramsobj)
            }
        }
    }
    
    
    
    
    func  updateLastRequestTimeFPFlights() {
        
        let realm = try! Realm()
        let paramobjects = realm.objects(RealmAppParams.self)
        
        if let paramsobj = paramobjects.first {
            try! realm.write {
                paramsobj.lastRequestTimeFPFlights = Date()
            }
        }
        
    }
    
    
    
    func  shouldRefreshFPFlights() -> Bool {
        
        if (!MiscUtils.isOnlineMode() ) {
            return false
        }
        
        let currentTime = Date()
        
        let realm = try! Realm()
        
        let paramobjects = realm.objects(RealmAppParams.self)
        
        
        if let paramsobj = paramobjects.first {
            
            
            if let prevTime =  paramsobj.lastRequestTimeFPFlights  {
                
                let calendar = Calendar.current
                
                print(paramsobj.minDelaySecFPFlightsRefreshRequest)
                
                print(StringUtils.getStringFromDateTime(prevTime)  +  " " +
                    StringUtils.getStringFromDateTime(calendar.date(byAdding: .second, value: Int(paramsobj.minDelaySecFPFlightsRefreshRequest), to: prevTime)) + " " +
                    StringUtils.getStringFromDateTime(currentTime))
                
                
                
                return calendar.date(byAdding: .second, value: Int(paramsobj.minDelaySecFPFlightsRefreshRequest), to: prevTime)! < currentTime
                
                
                
            } else {
                return true
            }
            
        }
        
        return true
        
    }
    
    
    
    
}
