//
//  MiscUtils.swift
//  FlightLog
//
//  Created by Naveed Azhar on 09/08/2015.
//  Copyright © 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData

class MiscUtilsFltLog: NSObject {

    class func getCrewNameByStaffNo(_ staffNo:String) -> String {
        
        let fetchreq = NSFetchRequest<Crew>(entityName: "Crew")
        
        let staffNoPredicate = NSPredicate(format: "staffNo = %@", staffNo)

        
       let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [staffNoPredicate])
        
        fetchreq.predicate = compound
        
        
        do {
            let crew = try context.fetch(fetchreq)
            
            if (crew.count > 0 ) {
                return  crew[0].name!
            }
        } catch {
        }
        
        return ""
    }
    
    class func getCrewPosByStaffNo(_ staffNo:String) -> String {
        
        let fetchreq = NSFetchRequest<Crew>(entityName: "Crew")
        
        let staffNoPredicate = NSPredicate(format: "staffNo = %@", staffNo)
        
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [staffNoPredicate])
        
        fetchreq.predicate = compound
        
        
        do {
            let crew = try context.fetch(fetchreq)
            
            if (crew.count > 0 ) {
                return  getCrewPosFromDesignation(crew[0].designation!)
            }
        } catch {
        }
        
        return ""
    }

    class func getCrewPosFromDesignation(_ designation:String) -> String {
        switch designation {
        case "CP":return "0";
        case "FO":return "1";
        case "FE":return "2";
        case "SP":return "5";
        case "FP":return "6";
        case "FS":return "7";
        case "AH":return "8";
        case "FA":return "7";
        case "TC":return "5";
        default:return "7";
            
        }
    }
    class func getAircraftGroupOSPAK(_ aircraftType:String) ->String  {
        
        if ( aircraftType == "320" ) {
            return "D"
        }else {
                    return aircraftType.substring(with: (aircraftType.index(aircraftType.startIndex, offsetBy: 0) ..< aircraftType.index(aircraftType.startIndex, offsetBy: 1)))
        }
    }
    
    

    
    class func getCrewScheduleCount_old(_ startDate:String , endDate:String) -> Int {
        
        let legDataReq = NSFetchRequest<CrewData>(entityName: "CrewData")
        
        
        let datePredicate = NSPredicate(format: "date >= %@ and date <= %@", StringUtils.getYMDStringFromDMYString(startDate) , StringUtils.getYMDStringFromDMYString(endDate))
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate])
        
        legDataReq.predicate = compound
        
        
        let data = try! context.fetch(legDataReq)
        
        return data.count
        
    }
    
    

    class func getCrewScheduleCount() -> Int {
        
        let legDataReq = NSFetchRequest<CrewData>(entityName: "CrewData")

        let data = try! context.fetch(legDataReq)
        
        return data.count
        
    }

    class func getCrewCount() -> Int {
        
        let legDataReq = NSFetchRequest<Crew>(entityName: "Crew")
        
        
        let data = try! context.fetch(legDataReq)
        
        return data.count
        
    }
    
    
    class func alert(_ title:String, message:String, controller:UIViewController) {
        
        let alert = UIAlertController(title: title, message: message,  preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        DispatchQueue.main.async {
            controller.present(alert, animated: true, completion: nil)
        }
    
    }
    

    
}
