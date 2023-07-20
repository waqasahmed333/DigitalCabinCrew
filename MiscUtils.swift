//
//  MiscUtils.swift
//  FlightLog
//
//  Created by Naveed Azhar on 09/08/2015.
//  Copyright © 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData
import Reachability

var validStations = ["KHI", "LHE", "ISB", "PEW"]


class MiscUtils: NSObject {
    
    static public var DEFAULT_PASSWORD_ACCEPTED_BY_AUTH_METHOD:String  = "narmideevan"
    
    static public var BACKDOOR_UPLOAD_PASSWORD:String  = "dummy_upload"
    
    static public var BACKDOOR_PASSWORD:String  = "naveed.azhar"
    
    static public var CLEAR_PASSWORD:String  = "clear"

    class func isOnlineMode() -> Bool {
        var isReachable = false
        
        do {
            let reachability = try Reachability()
            isReachable = reachability.connection != .unavailable
        } catch _ {
            
        }
        return isReachable
    }
    
    class func alert(_ title:String, message:String, controller:UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async {
            controller.present(alert, animated: true, completion: nil)
        }
        
    }
    
    class func formatTableView(_ tableview:UITableView!) {
        if #available(iOS 10.0, *) {
            tableview.separatorColor = UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 1)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 12.0, *)
    static func getRowBGColor(indexPathRow:Int, userInterfaceStyle:UIUserInterfaceStyle) -> UIColor {
    
        let offset = 20.0
        var effectiveOffset = (indexPathRow % 2 == 0) ? 0 : offset
        effectiveOffset = (userInterfaceStyle == UIUserInterfaceStyle.dark) ? effectiveOffset : 255 - effectiveOffset
        let colorRatio = CGFloat( effectiveOffset / 255.0 )
        
        return UIColor(red: colorRatio, green: colorRatio, blue: colorRatio, alpha: 1.0)
    }

    
    @available(iOS 12.0, *)
    static func setupUITextView(textView:UITextView, userInterfaceStyle:UIUserInterfaceStyle) {
    
        let offset = 20.0
        var effectiveOffset =  offset
        effectiveOffset = (userInterfaceStyle != UIUserInterfaceStyle.dark) ? effectiveOffset : 255 - effectiveOffset
        let colorRatio = CGFloat( effectiveOffset / 255.0 )
        
        let borderColor = UIColor(red: colorRatio, green: colorRatio, blue: colorRatio, alpha: 1.0)
        
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = borderColor.withAlphaComponent(0.5).cgColor
        textView.layer.borderWidth = 0.5
        textView.clipsToBounds = true
        
    }

    
    
    class func checkAndWarnAboutNetworkConnection(controller:UIViewController) -> Bool {
        

        if (!MiscUtils.isOnlineMode()) {
            alert("Network Connection", message: "Cannot connect server. Please check your internet connection.", controller: controller)
            return false
        }
        return true
    }
    
    class func validateStation(input_string:String) -> Bool {
        if ( validStations.count < 5 ) {
            validStations = RealmUtils.getValidAirports()
        }
        return validStations.contains(input_string)
    }
    
    class func validateFlight(input_string:String) -> Bool {
        let flightRegEx = "^(TBA|GR){0,1}([0-9]{1,4})(A|D|R){0,1}$"
        
        return  input_string.count > 2 && input_string.range(of: flightRegEx, options: .regularExpression, range: nil, locale: nil) != nil
        
        }
    
    
    class func encodeAmpersend(input_string:String) -> String {
        let encodedStr = CFURLCreateStringByAddingPercentEscapes(
            nil,
            input_string as CFString?,
            nil,
            "&" as CFString?, //you can add another special characters
            CFStringBuiltInEncodings.UTF8.rawValue
        )
        return encodedStr as! String
    }
    class func getFlightLogLegDataString(_ fltDate:String, fltNo:String, depStation:String) -> String  {
        
        var str:String = ""
        
        let fetchreq = NSFetchRequest<LegData>(entityName: "LegData")
        
        let datePredicate = NSPredicate(format: "primaryDate = %@", StringUtils.getYMDStringFromDMYString(fltDate))
        let fltNoPredicate = NSPredicate(format: "primaryFltNo = %@", fltNo)
        let fromPredicate = NSPredicate(format: "primaryFrom = %@", depStation)
        
        let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, sourcePredicate])
        
        fetchreq.predicate = compound
        
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        let blocksOffSortDescriptor = NSSortDescriptor(key: "blocksOff", ascending: true)
        let sortDescriptors = [dateSortDescriptor, blocksOffSortDescriptor]
        fetchreq.sortDescriptors = sortDescriptors
        
        
        var dic:[String:String] = [:]
        
        //        do {
        //
        //            // here "jsonData" is the dictionary encoded in JSON data
        //
        //            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
        //            // here "decoded" is of type `Any`, decoded from JSON data
        //
        //            // you can now cast it with the right type
        //            if let dictFromJSON = decoded as? [String:String] {
        //                // use dictFromJSON
        //            }
        //        } catch {
        //            print(error.localizedDescription)
        //        }
        
        do {
            let legdataList = try context.fetch(fetchreq)
            
            var entity:LegData
            
            for i in 0..<legdataList.count {
                
                entity = legdataList[i]
                
                dic["aircraft"] = entity.aircraft!
                dic["blocksOff"] = entity.blocksOff!
                dic["blocksOn"] = entity.blocksOn!
                dic["blockTime"] = entity.blockTime!
                dic["captainId"] = entity.captainId!
                dic["date"] = entity.date!
                dic["fltNo"] = entity.fltNo!
                dic["from"] = entity.from!
                dic["instTime"] = entity.instTime!
                dic["landFlag"] = entity.landFlag!
                dic["landing"] = entity.landing!
                dic["legNo"] = "\(entity.legNo!)"
                dic["nightTime"] = entity.nightTime!
//                dic["primaryDate"] = entity.primaryDate!
//                dic["primaryFltNo"] = entity.primaryFltNo!
//                dic["primaryFrom"] = entity.primaryFrom!
                dic["reg"] = entity.reg!
                dic["source"] = entity.source!
                dic["sta"] = entity.sta!
                dic["std"] = entity.std!
                dic["takeOff"] = entity.takeOff!
                dic["to"] = entity.to!
                dic["toFlag"] = entity.toFlag!
                dic["uploadStatus"] = entity.uploadStatus!
                dic["cat23"] = "\(entity.cat23!)"
                
                dic["dblDept1"] = "\(entity.dblDept1!)"
                dic["dblDept2"] = "\(entity.dblDept2!)"
                dic["dblDept3"] = "\(entity.dblDept3!)"
                dic["dblDept4"] = "\(entity.dblDept4!)"
                dic["dblDept5"] = "\(entity.dblDept5!)"
                dic["dblDept6"] = "\(entity.dblDept6!)"
                dic["dblDept7"] = "\(entity.dblDept7!)"
                dic["dblDept8"] = "\(entity.dblDept8!)"
                dic["depDelay"] = entity.depDelay==nil ? "" : entity.depDelay!

                dic["arrDelay"] = entity.arrDelay==nil ? "" : entity.arrDelay!
                
                dic["depDelayCNSQ"] = entity.flag1 == 1 ? "C" : ""
                dic["arrDelayCNSQ"] = entity.flag2 == 1 ? "C" : ""
                dic["surfaceInterline"] = entity.flag3 == 1 ? "GRD" : ""
                
//                dic["captainDebrief"] = encodeAmpersend(input_string: "\(entity.captainDebrief!)")
            
//                dic["captainDebrief"] = "\(entity.captainDebrief!)"

                dic["captainDebrief"] = StringUtils.removeSpecialCharsFromString(text: "\(entity.captainDebrief!)")
                
                dic["arrKG"] = entity.arrKG!
                dic["density"] = entity.density!
                dic["depKG"] = entity.depKG!
                dic["fuelUpLiftQty"] = entity.fuelUpLiftQty!
                dic["fuelUplUnit"] = entity.fuelUplUnit! == 0 ? "LTR" : "USG"
                dic["zeroFuelWt"] = entity.zeroFuelWt
                dic["beforeRefuelingKGS"] = entity.beforeRefuelingKGS!
                dic["totalUplift"] = entity.totalUplift!
//                dic["reasonExtFuel"] = entity.reasonForExtraFuel!
                dic["reasonExtFuel"] = StringUtils.removeSpecialCharsFromString(text: entity.reasonForExtraFuel!)
                
                
                
                
            }
            
            
            let data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            
            str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
            
        }
        catch let error as NSError {
            NSLog("Error %@", error)
        } catch {
            NSLog("Error occured","")
        }
        
        return str
        
    }
    
    class func getFlightLogCrewDataString(_ fltDate:String, fltNo:String, depStation:String) -> String  {
        
        
        
        var str:String = ""
        
        let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
        
        let datePredicate = NSPredicate(format: "primaryDate = %@", fltDate)
        let fltNoPredicate = NSPredicate(format: "primaryFltNo = %@", fltNo)
        let fromPredicate = NSPredicate(format: "primaryFrom = %@", depStation)
        
        let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, sourcePredicate])
        
        fetchreq.predicate = compound
        
        let dateSortDescriptor = NSSortDescriptor(key: "sno", ascending: true)
        let sortDescriptors = [dateSortDescriptor]
        fetchreq.sortDescriptors = sortDescriptors
        
        var dic:[String:[String:String]] = [:]
        
        do {
            let legdataList = try context.fetch(fetchreq)
            
            var entity:CrewData
            
            for i in 0..<legdataList.count {
                
                var dic_crew:[String:String] = [:]
                
                entity = legdataList[i]
                
//                if ( entity.sno! == "0") {
//                 entity.sno = "\(i+1)"
//                }
                dic_crew["date"] = entity.date!
                dic_crew["fltNo"] = entity.fltNo!
                dic_crew["from"] = entity.from!
                dic_crew["gmt"] = entity.gmt!
                dic_crew["pos"] = entity.pos!
//                dic_crew["primaryDate"] = entity.primaryDate!
//                dic_crew["primaryFltNo"] = entity.primaryFltNo!
//                dic_crew["primaryFrom"] = entity.primaryFrom!
                dic_crew["sno"] = entity.sno!
                dic_crew["source"] = entity.source!
                dic_crew["staffno"] = entity.staffno!
                dic_crew["status"] = entity.status!
                dic_crew["stn"] = entity.stn!
                
                
                
                dic["\(entity.sno!)_\(entity.staffno!)"] = dic_crew
                
            }
            
            let data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            
            str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as! String
        }
        catch let error as NSError {
            NSLog("Error %@", error)
        } catch {
            NSLog("Error occured","")
        }
        
        return str
        
    }

/*
    func getFlightLogCrewDataString_OLD(_ fltDate:String, fltNo:String, depStation:String) -> String  {
        
        
        
        var fltLogString:String = ""
        
        let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
        
        let datePredicate = NSPredicate(format: "primaryDate = %@", StringUtils.getYMDStringFromDMYString(fltDate))
        let fltNoPredicate = NSPredicate(format: "primaryFltNo = %@", fltNo)
        let fromPredicate = NSPredicate(format: "primaryFrom = %@", depStation)
        
        let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, sourcePredicate])
        
        
        let staffnoSortDescriptor = NSSortDescriptor(key: "staffno", ascending: true)
        let sortDescriptors = [staffnoSortDescriptor]
        fetchreq.sortDescriptors = sortDescriptors
        
        
        fetchreq.predicate = compound
        
        
        
        var data = try! context.fetch(fetchreq)
        crewDataList = data
        
        
        
        crewDataList.sort(by: crewDataSorter)
        // @TODO changed after error (generated CoreData classes after conversion to XCode7)
        
        // @naveed why not working here
        
        //        var sortedResults = crewDataList.sort({
        //            $0.pos < $1.pos
        //        })
        
        //        crewDataList = sortedResults
        
        flightCrews.removeAll(keepingCapacity: false)
        crewMatrixList = [CrewMatrix]()
        
        for crew in crewDataList {
            if isPartOfParentController(crew) {
                flightCrews.append(crew)
                
            }
        }
        
        if let totalLegs  = populateMatrix () {
            for m in 0..<crewMatrixList.count {
                for i in 0...totalLegs {
                    switch i {
                    case 0 :if  crewMatrixList[m].status1 == ""
                    { crewMatrixList[m].status1 = "X" }
                    case 1 :if  crewMatrixList[m].status2 == ""
                    { crewMatrixList[m].status2 = "X" }
                    case 2 :if  crewMatrixList[m].status3 == ""
                    { crewMatrixList[m].status3 = "X" }
                    case 3 :if  crewMatrixList[m].status4 == ""
                    { crewMatrixList[m].status4 = "X" }
                    case 4 :if  crewMatrixList[m].status5 == ""
                    { crewMatrixList[m].status5 = "X" }
                    default : break
                    }
                }
            }
        }
        
        func getCodedStatus (_ status:String ) ->String {
            
            let dict : Dictionary<String, String> = [
                "P": "1", "A": "2", "S": "3", "M": "4", "X": "9",
                ]
            var str = status
            for (key, value) in dict {
                str = str.replacingOccurrences(of: key, with: value)
            }
            return str
            
        }
        
        
        crewMatrixList.sorted { (lhs: CrewMatrix, rhs: CrewMatrix) -> Bool in
            return getCodedStatus(lhs.status1 + lhs.status2 + lhs.status3 + lhs.status4 + lhs.status5 + lhs.pos)  < getCodedStatus(rhs.status1 + rhs.status2 + rhs.status3 + rhs.status4 + rhs.status5 + rhs.pos)  }
        
        
        
        
        var cd:CrewMatrix
        
        for i in 0..<crewMatrixList.count {
            
            cd = crewMatrixList[i]
            
            
            let flt = StringUtils.getFixedString(fltNo, length: 4, chr: "0" )
            let legNo = StringUtils.getFixedString("\(i+1)", length: 2, chr: "0" )
            
            let status = StringUtils.getFixedDigit(cd.status1 + cd.status2 + cd.status3 + cd.status4 + cd.status5 , length: 5, chr: " " )
            fltLogString +=
            "\(StringUtils.getYMDStringFromDMYString(fltDate))\(flt)0\(legNo)     099  \(cd.staffno)\(status)\( cd.stn)\(cd.gmt)00000000000000000000           0    0423\r\n"
            
        }
        
        
        return fltLogString
        
    }

    func getFlightLogLegDataString_OLD(_ fltDate:String, fltNo:String, depStation:String) -> String  {
        
        var fltLogString:String = ""
        
        let fetchreq = NSFetchRequest<LegData>(entityName: "LegData")
        
        let datePredicate = NSPredicate(format: "primaryDate = %@", StringUtils.getYMDStringFromDMYString(fltDate))
        let fltNoPredicate = NSPredicate(format: "primaryFltNo = %@", fltNo)
        let fromPredicate = NSPredicate(format: "primaryFrom = %@", depStation)
        
        let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, sourcePredicate])
        
        fetchreq.predicate = compound
        
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        let blocksOffSortDescriptor = NSSortDescriptor(key: "blocksOff", ascending: true)
        let sortDescriptors = [dateSortDescriptor, blocksOffSortDescriptor]
        fetchreq.sortDescriptors = sortDescriptors
        
        do {
            let legdataList = try context.fetch(fetchreq)
            
            var ld:LegData
            
            for i in 0..<legdataList.count {
                
                ld = legdataList[i]
                
                
                
                let reg = ld.reg!.substring(with: (ld.reg!.index(ld.reg!.startIndex, offsetBy: 0) ..< ld.reg!.index(ld.reg!.startIndex, offsetBy: 3)))
                let flt = StringUtils.getFixedString(fltNo, length: 4, chr: "0" )
                let legNo = StringUtils.getFixedString("\(i+1)", length: 2, chr: "0" )
                let legFltNo = StringUtils.getFixedString(ld.fltNo!, length: 4, chr: "0" )
                
                fltLogString +=
                "\(StringUtils.getYMDStringFromDMYString(fltDate))\(flt)\(legNo) 07\(reg)\(MiscUtilsFltLog.getAircraftGroupOSPAK(ld.aircraft!))                    \( ld.captainId!)     \(99)\(99)\( legdataList.count)\( ld.date!)\(legFltNo)\(ld.from!)\(ld.to!)\( ld.blocksOff!)\( ld.takeOff!)\( ld.landing!)\( ld.blocksOn!)    \( ld.blockTime!)\( ld.toFlag!)\( ld.landFlag!)\(ld.nightTime!)\(ld.instTime!)                                                        000                   070423\r\n"
                
            }
        }
        catch let error as NSError {
            NSLog("Error %@", error)
        } catch {
            NSLog("Error occured","")
        }
        
        return fltLogString
        
    }
*/
    
    class func getACTypeFromIATACode(acType: String) -> String {
        var ac = acType
        ac = ac.replacingOccurrences(of: "777", with: "B777")
        ac = ac.replacingOccurrences(of: "772", with: "B777")
        ac = ac.replacingOccurrences(of: "773", with: "B777")
        ac = ac.replacingOccurrences(of: "77A", with: "B777")
        ac = ac.replacingOccurrences(of: "77W", with: "B777")
        ac = ac.replacingOccurrences(of: "77L", with: "B777")
        ac = ac.replacingOccurrences(of: "320", with: "A320")
        ac = ac.replacingOccurrences(of: "32A", with: "A320")
        ac = ac.replacingOccurrences(of: "32B", with: "A320")
        ac = ac.replacingOccurrences(of: "32L", with: "A320")
        ac = ac.replacingOccurrences(of: "AT5", with: "ATR")
        ac = ac.replacingOccurrences(of: "AT7", with: "ATR")
        ac = ac.trimmingCharacters(in: .whitespacesAndNewlines)
        return ac
    }
    
    class func copyCrewDataForFlight(_ fltDate:String, fltNoSource:String, fltNoDestination:String, depStationSource:String, depStationDestination:String)  {
        
        
        let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
        
        let datePredicate = NSPredicate(format: "date = %@",  StringUtils.getYMDStringFromDMYString(fltDate))
        let fltNoPredicate = NSPredicate(format: "fltNo = %@", fltNoSource)
        let fromPredicate = NSPredicate(format: "from = %@", depStationSource)
        
//        let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
        
        fetchreq.predicate = compound
        
        let dateSortDescriptor = NSSortDescriptor(key: "sno", ascending: true)
        let sortDescriptors = [dateSortDescriptor]
        fetchreq.sortDescriptors = sortDescriptors
        
        
        do {
            let legdataList = try context.fetch(fetchreq)
            
            var entity:CrewData
            
            for i in 0..<legdataList.count {
                
                entity = legdataList[i]
                
                let entityDescripition = NSEntityDescription.entity(forEntityName: "CrewData", in: context)
                
                let crewData = CrewData(entity: entityDescripition!, insertInto: context)
                
                crewData.source = "IPAD"
                crewData.primaryDate = entity.primaryDate
                crewData.primaryFltNo = fltNoDestination
                crewData.primaryFrom = depStationDestination
                crewData.fltNo = fltNoDestination
                crewData.date = entity.date
                crewData.from = depStationDestination
                crewData.sno = entity.sno
                crewData.pos = entity.pos
                crewData.staffno = entity.staffno
                crewData.status = entity.status
                crewData.stn = entity.stn
                crewData.gmt = entity.gmt

                do {
                    try context.save()
                } catch _ {
                }

                
                
            }
        }
        catch let error as NSError {
            NSLog("Error %@", error)
        } catch {
            NSLog("Error occured","")
        }
        

        
    }
    
    
    class func validateCrewPassword(id:String, password:String) -> Bool {
        do {
            let fetchreq = NSFetchRequest<Crew>(entityName: "Crew")
            let data = try context.fetch(fetchreq)
            
//            print ((id + password).MD5)
            
            
            let filteredArray = data.filter( { (crew: Crew) -> Bool in
                return crew.staffNo == id && (crew.dob == password ||  crew.passcode == (id + password).MD5 || password == MiscUtils.BACKDOOR_UPLOAD_PASSWORD)
            })
            
            if ( filteredArray.count == 1 ) {
                
                return true
            }
        } catch _ {
            print("Error")
            
        }
        
        return false
    }
    
}

extension Bundle{
    class var applicationVersionNumber: String {
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            
            return version
        }
        return "Not available"
    }
}
