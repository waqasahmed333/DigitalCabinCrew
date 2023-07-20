//
//  RosterService.swift

//
//  Created by Naveed Azhar on 29/04/2016.
//  Copyright © 2016 PIA. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RosterServices {
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
    
    static func getCrewRosters(_ crewId:String, completion: @escaping (_ crewRosterArray:[CrewRoster]? ,_ error:String?)->Void){
        
        Manager.request(NetworkUtils.getActiveServerURL() + "/GetRosterDutiesOfCrew?token=1&crewId=" + crewId)
            .responseJSON { (response) in
                
                var object:JSON = JSON.null
                
                var dataloaded = false
                if ( response.result.error != nil ) {
                    let data = UserDefaults.standard.object(forKey: "JSON-" + crewId) as AnyObject?
                    object = JSON(data)
                    dataloaded = true
                } else {
                   print( response.result.value! )
                    object = JSON(response.result.value!)
                                        var obj = response.result.value!
                    UserDefaults.standard.set(response.result.value!, forKey: "JSON-" + crewId)
                }
                
                if response.result.error == nil || dataloaded  {
                    
                    
                    var crewRosters = [CrewRoster]()
                    
                    var crewDuties = [CrewDuty]()
                    
                    
                    for crewDuty in object["DutyList"].arrayValue {
                        
                        let dayIndex = crewDuty["DayIndex"].numberValue.int32Value
                        let ac = crewDuty["Ac"].stringValue
                        let reg = crewDuty["Reg"].stringValue
                        let date = crewDuty["Date_"].stringValue
                        let duty = crewDuty["Duty"].stringValue
                        let dep = crewDuty["Dep"].stringValue
                        let arr = crewDuty["Arr"].stringValue
                        let std = crewDuty["Std"].stringValue
                        let sta = crewDuty["Sta"].stringValue
                        let type = crewDuty["Type"].stringValue
                        let dutyDetails = crewDuty["DutyDetails"].stringValue
                        
                                    
                        crewDuties.append(CrewDuty(type:type, dayIndex:dayIndex, ac: ac, reg: reg, date: date, duty: duty , dep: dep, arr:arr, std:std, sta:sta, dutyDetails: dutyDetails))
                    }
                    
                    
                    let crewRoster = CrewRoster(crewId:crewId,startDate:object["startDate"].stringValue, endDate:object["endDate"].stringValue, duties: crewDuties)
                    
                    crewDuties=[]
                    crewRosters.append(crewRoster)
                    
                    
                    completion(crewRosters, nil)
                    crewRosters=[]
                    
                }else{
                    
                    completion(nil, response.result.error!.localizedDescription)
                    
                }
                
                
                
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

