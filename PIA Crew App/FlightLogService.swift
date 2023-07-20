//
//  FlightLogService.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 02/07/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FlightLogService {
    
    private static var Manager : Alamofire.SessionManager = {
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "crew1.piac.com.pk": .disableEvaluation,
            "crew2.piac.com.pk": .disableEvaluation,
            "crew3.piac.com.pk": .disableEvaluation,
            "crewserver1.piac.com.pk": .disableEvaluation,

        ]
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let man = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return man
    }()
    
    static func getFlCrewList(_ crewId:String, completion: @escaping (_ flCrewArray:[FLCrew]? ,_ error:String?)->Void){
        
        let data = UserDefaults.standard.object(forKey: AppConstants.CACHE_KEY_ACTIVE_CREW_LIST) as AnyObject?
        if ( data == nil ) {
            Manager.request( NetworkUtils.getActiveServerURL() + "/GetActiveCrewList_SECURE?username=\(AppConstants.WEB_SERVICE_USERNAME)&password=\(AppConstants.WEB_SERVICE_PASSWORD)&token=1")
                .responseJSON { (response) in
                    
                    var object:JSON = JSON.null
                    
                    var dataloaded = false
                    if ( response.result.error != nil ) {
                        let data = UserDefaults.standard.object(forKey: AppConstants.CACHE_KEY_ACTIVE_CREW_LIST) as AnyObject?
                        object = JSON(data)
                        dataloaded = true
                    } else {
                        object = JSON(response.result.value!)
                        UserDefaults.standard.set(response.result.value!, forKey: AppConstants.CACHE_KEY_ACTIVE_CREW_LIST )
                    }
                    
                    if response.result.error == nil || dataloaded  {
                        
                        
                        var flCrews = [FLCrew]()
                        
                        
                        for obj in object["crewList"].arrayValue {
                            
                            let designation = obj["Designation"].stringValue
                            let name = obj["Name"].stringValue
                            let staffNo = obj["StaffNo"].stringValue
                            let base = obj["Base"].stringValue
                            let passcode = obj["Passcode"].stringValue
                            let dob = obj["Dob"].stringValue
                            
                            
                            flCrews.append(FLCrew(designation: designation, staffNo: staffNo, base: base, name: name,passcode: passcode, dob:dob))
                        }
                        
                        completion(flCrews, nil)
                        
                    }else{
                        
                        completion(nil, response.result.error!.localizedDescription)
                        
                    }
                    
            }
        }  else {
            Indicator.stop()
        }
        
    }
    
    static func getFlCrewScheduleList(_ crewId:String, completion: @escaping (_ flCrewArray:[FLCrewSchedule]? ,_ error:String?)->Void){
        
        var useLocalCache = false
        let currentTime = CFAbsoluteTimeGetCurrent() as Double
        
        if let lastUpdateTime =  UserDefaults.standard.value(forKey: AppConstants.CACHE_KEY_CREWS_FOR_CREW_TIME_INFO) as? Double{
            
            if (currentTime - lastUpdateTime) < 180 {
                useLocalCache = true
            }
            
        }
        
        if !useLocalCache {
            
            var password = AppConstants.WEB_SERVICE_PASSWORD
            if ( AppConstants.ADMIN_MODE == "1"  ) {
                password = AppConstants.WEB_SERVICE_PASSWORD_ADMIN
            }
            
            let url1 = NetworkUtils.getActiveServerURL()
                + "/GetCrewsForCrew_SECURE?crewId=\(crewId)&username=\(AppConstants.WEB_SERVICE_USERNAME)&password=\(password)&startDate="
                + StringUtils.getStringFromDate(Date(timeIntervalSinceNow: -1 * 60 * 60 * 24))
                + "&endDate="
                + StringUtils.getStringFromDate(Date(timeIntervalSinceNow: 5 * 60 * 60 * 24))
            
            Manager.request( NetworkUtils.getActiveServerURL()
                + "/GetCrewsForCrew_SECURE?crewId=\(crewId)&username=\(AppConstants.WEB_SERVICE_USERNAME)&password=\(password)&startDate="
                + StringUtils.getStringFromDate(Date(timeIntervalSinceNow: -1 * 60 * 60 * 24))
                + "&endDate="
                + StringUtils.getStringFromDate(Date(timeIntervalSinceNow: 5 * 60 * 60 * 24)))
                
                .responseJSON { (response) in
                    
                    var object:JSON = JSON.null
                    
                    var dataloaded = false
                    if ( response.result.error != nil ) {
                        let data = UserDefaults.standard.object(forKey: AppConstants.CACHE_KEY_CREWS_FOR_CREW) as AnyObject?
                        object = JSON(data)
                        dataloaded = true
                    } else {
                        object = JSON(response.result.value!)
                        UserDefaults.standard.set(response.result.value!, forKey: AppConstants.CACHE_KEY_CREWS_FOR_CREW)
                        UserDefaults.standard.set(currentTime, forKey: AppConstants.CACHE_KEY_CREWS_FOR_CREW_TIME_INFO )
                        
                    }
                    
                    if response.result.error == nil || dataloaded  {
                        
                        
                        var flCrews = [FLCrewSchedule]()
                        
                        
                        for obj in object["CrewList"].arrayValue {
                            
                            let fltno = obj["FltNo"].stringValue
                            let date = obj["Date"].stringValue
                            let dep = obj["Dep"].stringValue
                            let sno = obj["Sno"].stringValue
                            let pos = StringUtils.getCodedPosForFlightLogApp(obj["Pos"].stringValue)
                            let staffno = obj["Staffno"].stringValue
                            let status = obj["Status"].stringValue
                            let stn = obj["Stn"].stringValue
                            let gmt = obj["Gmt"].stringValue
                            
                            
                            
                            flCrews.append(FLCrewSchedule(fltno: fltno, date: date, dep: dep, sno: sno,pos: pos, staffno: staffno, status: status, stn: stn,gmt: gmt))
                        }
                        
                        completion(flCrews, nil)
                        
                    }else{
                        
                        completion(nil, response.result.error!.localizedDescription)
                        
                    }
                    
            }
        }else{
            Indicator.stop()
        }
        //
    }
    
    static func getFlFlightInfoList(_ crewId:String, completion: @escaping (_ flFlightInfoArray:[FLFlightInfo]? ,_ error:String?)->Void){
        
        var useLocalCache = false
        let currentTime = CFAbsoluteTimeGetCurrent() as? Double
        
        if let lastUpdateTime =  UserDefaults.standard.value(forKey: AppConstants.CACHE_KEY_FLIGHT_FOR_CREW_TIME_INFO) as? Double{
            
            print("Time between refresh  \(currentTime! - lastUpdateTime)")
            
            if (currentTime! - lastUpdateTime) < 180 {
                useLocalCache = true
            }
            
        }
        
        if !useLocalCache {
            
            var password = AppConstants.WEB_SERVICE_PASSWORD
            if ( AppConstants.ADMIN_MODE == "1"  ) {
                password = AppConstants.WEB_SERVICE_PASSWORD_ADMIN
            }
            var webservice_url = NetworkUtils.getActiveServerURL()
                + "/GetFlightsForCrew_SECURE?crewId=\(crewId)&username=\(AppConstants.WEB_SERVICE_USERNAME)&password=\(password)&startDate="
                + StringUtils.getStringFromDate(Date(timeIntervalSinceNow: -1 * 60 * 60 * 24))
                + "&endDate="
                + StringUtils.getStringFromDate(Date(timeIntervalSinceNow: 5 * 60 * 60 * 24))
            
            print (webservice_url)
            
            Manager.request( webservice_url)
            
            
                
                .responseJSON { (response) in
                    
                    var object:JSON = JSON.null
                    
                    var dataloaded = false
                    if ( response.result.error != nil ) {
                        let data = UserDefaults.standard.object(forKey: AppConstants.CACHE_KEY_FLIGHT_FOR_CREW ) as AnyObject?
                        if ( data != nil ) {
                            object = JSON(data as! String)
                            dataloaded = true
                        }
                    } else {
                        object = JSON(response.result.value!)
                        
                        UserDefaults.standard.set(object.rawString(), forKey: AppConstants.CACHE_KEY_FLIGHT_FOR_CREW)
                        
                        UserDefaults.standard.set(currentTime!, forKey: AppConstants.CACHE_KEY_FLIGHT_FOR_CREW_TIME_INFO)
                    }
                    
                    if response.result.error == nil || dataloaded  {
                        
                        
                        var flFlightIfos = [FLFlightInfo]()
                        
                        
                        for obj in object["FltList"].arrayValue {
                            
                            let date = obj["Date_"].stringValue
                            let flight = obj["Flight"].stringValue
                            let dep = obj["Dep"].stringValue
                            let arr = obj["Arr"].stringValue
                            let std = obj["Std"].stringValue
                            let sta = obj["Sta"].stringValue
                            let aircraft = obj["Ac"].stringValue
                            let reg = obj["Reg"].stringValue
                            
                            
                            
                            flFlightIfos.append(FLFlightInfo(date: date, flight: flight, dep: dep, arr: arr,std: std, sta: sta, aircraft: aircraft, reg: reg))
                        }
                        
                        completion(flFlightIfos, nil)
                        
                    }else{
                        
                        completion(nil, response.result.error!.localizedDescription)
                        
                    }
                    
            }
            
            
        }else{
            
            let data = UserDefaults.standard.object(forKey: AppConstants.CACHE_KEY_FLIGHT_FOR_CREW) as AnyObject?
            
            var object:JSON = JSON.null
            
            
            
            var flFlightIfos = [FLFlightInfo]()
            
            if ( data != nil ) {
                object = JSON(data as! String)
                
                for obj in object["FltList"].arrayValue {
                    
                    let date = obj["Date_"].stringValue
                    let flight = obj["Flight"].stringValue
                    let dep = obj["Dep"].stringValue
                    let arr = obj["Arr"].stringValue
                    let std = obj["Std"].stringValue
                    let sta = obj["Sta"].stringValue
                    let aircraft = obj["Ac"].stringValue
                    let reg = obj["Reg"].stringValue
                    
                    
                    
                    flFlightIfos.append(FLFlightInfo(date: date, flight: flight, dep: dep, arr: arr,std: std, sta: sta, aircraft: aircraft, reg: reg))
                }
            }
            
            completion(flFlightIfos, nil)
            
            
            Indicator.stop()
        }
        
    }
    
    static fileprivate func stringToNSdate(_ date:String)->Date{
        
        //2016-05-15
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: date)
        return date!
        
    }
    
}
