
//
//  RealmObjects.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 6/3/18.
//  Copyright © 2018 Naveed Azhar. All rights reserved.
//


//https://stackoverflow.com/questions/40970582/swift-remove-object-from-realm/40971579

//UIDevice.current.identifierForVendor!.uuidString


import Foundation
import RealmSwift

class WebRequestCache: Object {
    @objc dynamic var requestKey : String?
    @objc dynamic var lastRequestTime : Date?
    @objc dynamic var minDelaySeconds : Int = 1 * 60
    @objc dynamic var standardDelaySeconds : Int = 24 * 60 * 60
    
    //    @objc dynamic var lastResponseString : String?
    @objc dynamic var deleteObjectAfter : Date?
    
    override static func primaryKey() -> String? {
        return "requestKey"
    }
}

// Define your models like regular Swift classes
public class Airport: Object {
    @objc dynamic var code = ""
    @objc dynamic var name = ""
}

public class Aircraft : Object {
    @objc dynamic var code = ""
    @objc dynamic var name = "" // optionals supported
    
}

public class RealmUtils {
    
    public static func getValidAirports() -> [String] {
        // Get the default Realm
        let realm = try! Realm()
        
        var airportsRealm = Array(realm.objects(Airport.self)) //.filter("age < 2")
        
        var airports_array = [String]()
        
        airports_array.append("LYP")
        airports_array.append("BHX")
        airports_array.append("MJD")
        airports_array.append("CJL")
        airports_array.append("GWD")
        airports_array.append("KDU")
        airports_array.append("LHE")
        airports_array.append("MED")
        airports_array.append("PEW")
        airports_array.append("DEL")
        airports_array.append("OSL")
        airports_array.append("AUH")
        airports_array.append("LHR")
        airports_array.append("UET")
        airports_array.append("RZS")
        airports_array.append("MCT")
        airports_array.append("DMM")
        airports_array.append("DEA")
        airports_array.append("SKT")
        airports_array.append("TUK")
        airports_array.append("DAC")
        airports_array.append("RUH")
        airports_array.append("NJF")
        airports_array.append("MXP")
        airports_array.append("DBA")
        airports_array.append("KCF")
        airports_array.append("KHI")
        airports_array.append("MAN")
        airports_array.append("YYZ")
        airports_array.append("NRT")
        airports_array.append("PEK")
        airports_array.append("CPH")
        airports_array.append("BCN")
        airports_array.append("BKK")
        airports_array.append("CDG")
        airports_array.append("GIL")
        airports_array.append("JED")
        airports_array.append("KBL")
        airports_array.append("PZH")
        airports_array.append("RYK")
        airports_array.append("SHJ")
        airports_array.append("SKZ")
        airports_array.append("BHV")
        airports_array.append("DOH")
        airports_array.append("DXB")
        airports_array.append("ISB")
        airports_array.append("MUX")
        airports_array.append("KUL")
        airports_array.append("PJG")
        
        
        
        if ( airportsRealm.count == 0 ) {
            // Persist your data easily
            try! realm.write {
                
                for i in 0...airports_array.count - 1 {
                    let airport = Airport()
                    airport.name = airports_array[i]
                    airport.code = airports_array[i]
                    realm.add(airport)
                }
                // realm.add(myDog)
            }
        }
        
        
        airportsRealm = Array(realm.objects(Airport.self))
        
        if (airportsRealm.count  > 0) {
            var returnArr = [String]()
            for i in 0...airportsRealm.count - 1  {
                returnArr.append(airportsRealm[i].name)
            }
            return returnArr
        }
        
        return [String]()
    }
    
    
    class func getLastWebRequestTime(key:String) -> Date? {
        
        let realm = try! Realm()
        
        let wrcList = realm.objects(WebRequestCache.self).filter("requestKey = %@", key)
        
        
        if let wrc = wrcList.first {
            
            return   wrc.lastRequestTime
            
        }
        
        return nil
        
    }
    
    
    class func shouldCallWebRequest(key:String, delayType:Int) -> Bool {
        
        if (!MiscUtils.isOnlineMode() ) {
            return false
        }
        
        let currentTime = Date()
        
        let realm = try! Realm()
        
        let wrcList = realm.objects(WebRequestCache.self).filter("requestKey = %@", key)
        
        
        if let wrc = wrcList.first {
            
            if let prevTime =  getLastWebRequestTime(key: key)  {
                
                let calendar = Calendar.current
                
                if (delayType == WebRequest.DELAY_TYPE_STANDARD ) {
                    
                    return calendar.date(byAdding: .second, value: wrc.standardDelaySeconds, to: prevTime)! < currentTime
                } else {
                    return calendar.date(byAdding: .second, value: wrc.minDelaySeconds, to: prevTime)! < currentTime
                }
                
            } else {
                return true
            }
            
        }
        
        return true
        
    }
    
    
    class func  updateWebRequestCache(key:String, deleteObjectAfterDays:Int, minDelaySeconds: Int, standardDelaySeconds: Int) {
        
        let realm = try! Realm()
        let wrcList = realm.objects(WebRequestCache.self).filter("requestKey = %@", key)
        
        
        if let wrc = wrcList.first {
            try! realm.write {
                
                wrc.lastRequestTime = Date()
                
                var dateComponents = DateComponents()
                dateComponents.setValue(deleteObjectAfterDays, for: .day); // +N days
                
                let now = Date() // Current date
                let deleteObjectAfter = Calendar.current.date(byAdding: dateComponents, to: now)
                
                wrc.deleteObjectAfter = deleteObjectAfter
                //                wrc.lastResponseString = lastResponseString
                wrc.minDelaySeconds = minDelaySeconds
                wrc.standardDelaySeconds = standardDelaySeconds
                
            }
        } else {
            let wrc = WebRequestCache()
            wrc.requestKey = key
            wrc.lastRequestTime = Date()
            
            var dateComponents = DateComponents()
            dateComponents.setValue(deleteObjectAfterDays, for: .day); // +N days
            
            let now = Date() // Current date
            let deleteObjectAfter = Calendar.current.date(byAdding: dateComponents, to: now)
            
            wrc.deleteObjectAfter = deleteObjectAfter
            
            wrc.minDelaySeconds = minDelaySeconds
            wrc.standardDelaySeconds = standardDelaySeconds
            
            try! realm.write {
                realm.add(wrc)
            }
            
            
        }
        
    }
    
    
    
    
}


