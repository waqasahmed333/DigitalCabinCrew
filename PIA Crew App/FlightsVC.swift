//
//  FlightsVC.swift
//  PIA Crew App
//
//  Created by Admin on 08/09/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData
//import SwiftValidator
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


//let validator = Validator()

struct  FlightLegMatrix  {
    
    var aircraft: String = ""
    var blocksOff: String = ""
    var blocksOn: String = ""
    var blockTime: String = ""
    var captainId: String = ""
    var date: String = ""
    var fltNo: String = ""
    var from: String = ""
    var instTime: String = ""
    var landFlag: String = ""
    var landing: String = ""
    var legNo: NSNumber?
    var nightTime: String = ""
    var primaryDate: String = ""
    var primaryFltNo: String = ""
    var primaryFrom: String = ""
    var reg: String = ""
    var source: String = ""
    var sta: String = ""
    var std: String = ""
    var takeOff: String = ""
    var to: String = ""
    var toFlag: String = ""
    
}

class FlightsVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate {
    
    var crewMatrixList = [CrewMatrix]()
    var flightLegMatrixList = [FlightLegMatrix]()
    
    
    var fltNo:String = ""
    var fltDate:String = ""
    var depStation:String = ""
    
    @IBOutlet weak var popupTable: UITableView!
    
    
    @IBAction func fuelUnitChanged(_ sender: AnyObject) {
        //        let cell = sender.dequeueReusableCellWithIdentifier("cell1") as TableViewCell1
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.popupTable.tableFooterView = UIView()
    }
    
    
    @IBAction func save(_ sender: AnyObject) {
        
        do {
            let legRequest = NSFetchRequest<LegData>(entityName: "LegData")
            let data = try  context.fetch(legRequest) 
            
            let flights = data
            
            let entityDescripition = NSEntityDescription.entity(forEntityName: "FlightLog", in: context)
            
            _ = FlightLog(entity: entityDescripition!, insertInto: context)
            
            //            flightLogData.aircraftType = self.aircraftType.text!
            //            flightLogData.registration = self.registration.text!
            
            
            
            var missingData = false
            
            for i in 0...0 {
                let indexpath = IndexPath(row: i , section: 0)
                
                if ( popupTable.cellForRow(at: indexpath) == nil ) {
                    missingData = true
                    continue
                }
                let currentCell = popupTable.cellForRow(at: indexpath) as! TableViewCell
                
                
                
                if (currentCell.date.text != "" && currentCell.from.text != "" && currentCell.flightNo.text != "") {
                    if ( currentCell.blockOff.text! == "" || currentCell.blocksOn.text == "" || currentCell.takeOff.text! == "" || currentCell.landing.text! == "" ) {
                        missingData = true
                    }
                }
                
                
                
            }
            
            if ( missingData ) {
                let alert = UIAlertController(title: "Flight Log", message: "Please re-valdiate flight timings.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            
            let indexpath = IndexPath(row: 0 , section: 0)
            let currentCell = popupTable.cellForRow(at: indexpath) as! TableViewCell
            
            
            
            
            let dep = currentCell.from.text!
            let date = currentCell.date.text!
            let fltNo = currentCell.flightNo.text!
            
            _ =  self.tabBarController
            
            
            // removed on 22sep2016
            //        FlightLogEntity.sharedInstance.initIdentifiers()
            
            
            
            // remove prev copy
            let filteredArray = flights.filter( { (legData: LegData) -> Bool in
                return legData.primaryDate == StringUtils.getYMDStringFromDMYString(date) && legData.primaryFltNo == fltNo && legData.primaryFrom == dep && legData.source == "IPAD"
            })
            // if local copy (filled by captain) found
            for legData  in filteredArray {
                context.delete(legData)
            }
            
            
//            let fuelRequest = NSFetchRequest<FuelData>(entityName: "FuelData")
//            let fuelDataList = try  context.fetch(fuelRequest)
//            
//            
//            // remove prev copy
//            let filteredFuelArray = fuelDataList.filter( { (fuelData: FuelData) -> Bool in
//                return fuelData.primaryFltDate == StringUtils.getYMDStringFromDMYString(date) && fuelData.primaryFltNo == fltNo && fuelData.primaryFrom == dep
//            })
            // if local copy (filled by captain) found
//            for fuelData  in filteredFuelArray {
//                context.delete(fuelData)
//            }
            
            
            for i in 0...0 {
                
                
                saveLegData(flights, legNo: i, primaryDate: date, primaryFltNo: fltNo, primaryFrom: dep)
                
                saveFuelData(i, primaryDate: date, primaryFltNo: fltNo, primaryFrom: dep)
                
            }
            
            saveCrewData(date, primaryFltNo: fltNo, primaryFrom: dep)
            
            
            
            try context.save()
            
            
            let alert = UIAlertController(title: "Flight Log", message: "Flight data updated successfully.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
            //if (crewMatrixList.count == 0 ) {
            self.viewWillAppear(true)
            //s}
            
        } catch _ {
        }
        
        
    }
    
    func getFieldTypeFromTag(_ tag:Int) -> String {
        
        let remainder = tag % 13
        
        if ( tag > 0 ) {
            switch (remainder ) {
            case 1 : return "Date"
            case 2 : return "Flight"
            case 3, 4: return "Station"
            case 5,6,7,8,9,10,11: return "Time"
            case 12,0: return "Flag"
            default: return ""
            }
        } else {
            return ""
        }
        
    }
    
    //    func getUIViewValueByTagId(tag:Int) -> String? {
    //
    //        if let view = self.getUIViewByTagId(tag) as? UITextField {
    //            return view.text
    //        } else {
    //            return nil
    //        }
    //    }
    
    func getMaxLength(_ textField : UITextField) -> Int {
        
        let type = self.getFieldTypeFromTag(textField.tag)
        
        switch (type) {
        case "Date" : return 8
        case "Flight" : return 5
        case "Station": return 3
        case "Time" : return 4
        case "Flag" : return 3
        default : return 3
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.count + string.count - range.length
        
        return newLength <= getMaxLength(textField) // Bool
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        
        var superview:UIView  = textField.superview!
        
        while ( type(of: superview) != TableViewCell.self && type(of: superview) != TableViewCell1.self  && type(of: superview) != TableViewCell2.self ) {
            superview = superview.superview!
        }
        
        if ( type(of: superview) == TableViewCell.self ) {
            let cell = superview as! TableViewCell
            let indexPath = self.popupTable.indexPath(for: cell)
            
            
            
            
            if ( textField.tag == 1 && (indexPath! as NSIndexPath).row == 0) {
                if (textField.text!.count == 0 ) {
                    textField.text =  StringUtils.getStringFromDate(Date())
                    
                }
            }
            
            if ( textField.tag == 1 && (indexPath! as NSIndexPath).row > 0) {
                if (textField.text!.count == 0 ) {
                    
                    let indexpath = IndexPath(row: Int((indexPath! as NSIndexPath).row) - 1 , section: 0)
                    let previousCell = popupTable.cellForRow(at: indexpath) as! TableViewCell
                    
                    textField.text =  previousCell.getUIViewValueByTagId(textField.tag)
                    
                }
            }
            
        }
        return true
    }
    
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        var superview:UIView  = textField.superview!
        
        while ( type(of: superview) != TableViewCell.self && type(of: superview) != TableViewCell1.self  && type(of: superview) != TableViewCell2.self ) {
            superview = superview.superview!
        }
        
        if ( type(of: superview) == TableViewCell.self ) {
            let cell = superview as! TableViewCell
            let indexPath = self.popupTable.indexPath(for: cell)
            
            
            //            flightLeg÷MatrixList[indexPath?.row].legNo = legNo
            //            flightLegMatrixList[indexPath?.row].aircraft = legData.aircraft
            flightLegMatrixList[((indexPath as NSIndexPath?)?.row)!].blocksOff = cell.blockOff.text!
            flightLegMatrixList[((indexPath as NSIndexPath?)?.row)!].blocksOn = cell.blocksOn.text!
            //            flightLegMatrixList[(indexPath?.row)!].blockTime = cell.blockTime.text
            //            flightLegMatrixList[indexPath?.row].captainId = legData.captainId
            flightLegMatrixList[((indexPath as NSIndexPath?)?.row)!].date = StringUtils.getYMDStringFromDMYString(cell.date.text!)
            flightLegMatrixList[((indexPath as NSIndexPath?)?.row)!].fltNo = cell.flightNo.text!
            flightLegMatrixList[((indexPath as NSIndexPath?)?.row)!].from = cell.from.text!
            //            flightLegMatrixList[indexPath?.row].instTime = legData.instTime
            //            flightLegMatrixList[indexPath?.row].landFlag = legData.landFlag
            flightLegMatrixList[((indexPath as NSIndexPath?)?.row)!].landing = cell.landing.text!
            //            flightLegMatrixList[indexPath?.row].nightTime = legData.nightTime
            //            flightLegMatrixList[indexPath?.row].primaryDate = legData.primaryDate
            //            flightLegMatrixList[indexPath?.row].primaryFltNo = legData.primaryFltNo
            //            flightLegMatrixList[indexPath?.row].primaryFrom = legData.primaryFrom
            //            flightLegMatrixList[(indexPath?.row)!].reg = cell.reg.text
            //            flightLegMatrixList[(indexPath?.row)!].source = cell.source.text
            //            flightLegMatrixList[(indexPath?.row)!].sta = cell.sta.text
            //            flightLegMatrixList[(indexPath?.row)!].std = cell.std.text
            flightLegMatrixList[((indexPath as NSIndexPath?)?.row)!].takeOff = cell.takeOff.text!
            flightLegMatrixList[((indexPath as NSIndexPath?)?.row)!].to = cell.to.text!
            //            flightLegMatrixList[(indexPath?.row)!].toFlag = cell.toFlag.text
            
            
            let type = self.getFieldTypeFromTag(textField.tag)
            
            textField.text = textField.text!.uppercased()
            
            switch (type) {
                
            case "Flight" : textField.text = textField.text!.uppercased()
            case "Station": textField.text = textField.text!.uppercased()
            case "Flag" : textField.text = textField.text!.uppercased()
            case "Date" :
//                let s = textField.text!
// @swift3
//                textField.text = s.replacingOccurrences(
//                    of: "\\D", with: "", options: .regularExpression,
//                    range: s.characters.indices)
                if ( textField.text!.count < 8) {
                    textField.text = ""
                } else if let tempDate = StringUtils.getDateFromString(textField.text!)
                    
                {
                    if (tempDate.compare( Date(timeInterval: 2 * 60 * 60 * 24 , since: Date() )) == ComparisonResult.orderedDescending ) {
                        textField.text = ""
                        
                    }
                }
            case "Time" :
//                _ = textField.text!
// @swift3
//                textField.text = s.replacingOccurrences(
//                    of: "\\D", with: "", options: .regularExpression,
//                    range: s.characters.indices)
                if ( textField.text!.count < 4 ) {
                    textField.text = ""
                } else {
                    let str = textField.text
                    let hour =  Int(textField.text!.substring(with: (str!.index(str!.startIndex, offsetBy: 0) ..< str!.index(str!.startIndex, offsetBy: 2))))
                    
                    let minute =  Int(textField.text!.substring(with: (str!.index(str!.startIndex, offsetBy: 2) ..< str!.index(str!.startIndex, offsetBy: 4))))
                    
                    if ( hour > 23 || minute > 59 ) {
                        
                        textField.text = ""
                    }
                }
                
            default : break
                
            }
            
            if ( textField.tag % 13 == 2 || textField.tag % 13 == 3) {
                loadFlightData()
            }
            
            if ( textField.tag % 13 == 5 ) {
                
                if ( cell.getUIViewValueByTagId(textField.tag + 3)! != "" &&  cell.getUIViewValueByTagId(textField.tag)! != "" )  {
                    if let view = cell.getUIViewByTagId(textField.tag + 5) as? UITextField {
                        
                        view.text = "\(StringUtils.getHHMMFromMinutes(StringUtils.getMinutesFromHHMM(cell.getUIViewValueByTagId(textField.tag + 3)!) - StringUtils.getMinutesFromHHMM(cell.getUIViewValueByTagId(textField.tag)!)))"
                        
                    }
                }
            } else if ( textField.tag % 13 == 8 ) {
                
                if ( cell.getUIViewValueByTagId(textField.tag)! != "" &&  cell.getUIViewValueByTagId(textField.tag - 3)! != "" )  {
                    
                    if let view = cell.getUIViewByTagId(textField.tag + 1) as? UITextField {
                        
                        view.text = "\(StringUtils.getHHMMFromMinutes(StringUtils.getMinutesFromHHMM(cell.getUIViewValueByTagId(textField.tag)!) - StringUtils.getMinutesFromHHMM(cell.getUIViewValueByTagId(textField.tag - 3)!)))"
                        
                    }
                }
            }
            
            
        } else if ( type(of: superview) == TableViewCell1.self ) {
            let cell = superview as! TableViewCell1
            let indexPath = self.popupTable.indexPath(for: cell)
            
            if ( indexPath != nil) {
                fuelMatrixList[((indexPath as NSIndexPath?)?.row)!].fuelUpLiftQty = cell.fuelUpliftQty.text!
// @swift3
//                fuelMatrixList[((indexPath as NSIndexPath?)?.row)!].fuelUplUnit = NSNumber(cell.fuelUpliftUnit.selectedSegmentIndex)
//                fuelMatrixList[(indexPath?.row)!].fuelUplUnit = NSNumber(cell.fuelUpliftUnit.selectedSegmentIndex)
                fuelMatrixList[((indexPath as NSIndexPath?)?.row)!].depKG = cell.depKG.text!
                fuelMatrixList[((indexPath as NSIndexPath?)?.row)!].arrKG = cell.arrKG.text!
                fuelMatrixList[((indexPath as NSIndexPath?)?.row)!].zeroFuelWt = cell.zeroFuelWeight.text!
                fuelMatrixList[((indexPath as NSIndexPath?)?.row)!].toPwrFR = cell.toPwrFR.text!

// @swift3
                //                fuelMatrixList[((indexPath as NSIndexPath?)?.row)!].cat23 = NSNumber(cell.cat23.selectedSegmentIndex)
                fuelMatrixList[((indexPath as NSIndexPath?)?.row)!].density = cell.density.text!
            }
            
        }
        if ( type(of: superview) == TableViewCell2.self ) {
            let cell = superview as! TableViewCell2
            let indexPath = self.popupTable.indexPath(for: cell)
            
            if ( indexPath != nil) {
                crewMatrixList[((indexPath as NSIndexPath?)?.row)!].pos = cell.pos.text!
                crewMatrixList[((indexPath as NSIndexPath?)?.row)!].staffno = cell.staffno.text!
                crewMatrixList[((indexPath as NSIndexPath?)?.row)!].status1 = cell.status1.text!
                crewMatrixList[((indexPath as NSIndexPath?)?.row)!].status2 = cell.status2.text!
                crewMatrixList[((indexPath as NSIndexPath?)?.row)!].status3 = cell.status3.text!
                crewMatrixList[((indexPath as NSIndexPath?)?.row)!].status4 = cell.status4.text!
                crewMatrixList[((indexPath as NSIndexPath?)?.row)!].status5 = cell.status5.text!
                crewMatrixList[((indexPath as NSIndexPath?)?.row)!].stn = cell.stn.text!
                crewMatrixList[((indexPath as NSIndexPath?)?.row)!].gmt = cell.gmt.text!
            }
        }
        
        
        
        
        
    }
    
    
    func saveFuelData(_ legNo:Int, primaryDate: String, primaryFltNo: String, primaryFrom:String) {
        
        //        let indexpath1 = NSIndexPath(forRow: Int(legNo) , inSection: 0)
        //        let currentCell1 = popupTable.cellForRowAtIndexPath(indexpath1) as! TableViewCell
        
        let dep = flightLegMatrixList[legNo].from
        let date = flightLegMatrixList[legNo].date
        let fltNo = flightLegMatrixList[legNo].fltNo
        
        let indexpath = IndexPath(row: Int(legNo) , section: 1)
        
        if (dep != "" && fltNo != "" && date != "" ) {
            
            if (legNo < popupTable.numberOfRows(inSection: 1) ) {
                //        let currentCell = popupTable.cellForRowAtIndexPath(indexpath) as! TableViewCell1
                
                let entityDescripition = NSEntityDescription.entity(forEntityName: "FuelData", in: context)
                
//                let fuelData = FuelData(entity: entityDescripition!, insertInto: context)
//                
//                fuelData.date = date
//                fuelData.fltNo = fltNo
//                fuelData.from = dep
//                fuelData.primaryFltDate = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate
//                fuelData.primaryFltNo = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
//                fuelData.primaryFrom = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation
//                
//                
//                fuelData.fuelUpLiftQty = fuelMatrixList[legNo].fuelUpLiftQty
//                
//                fuelData.fuelUplUnit =  fuelMatrixList[legNo].fuelUplUnit
//                
//                fuelData.density = fuelMatrixList[legNo].density
//                
//                fuelData.depKG = fuelMatrixList[legNo].depKG
//                
//                fuelData.arrKG = fuelMatrixList[legNo].arrKG
//                
//                fuelData.zeroFuelWt = fuelMatrixList[legNo].zeroFuelWt
//                
//                fuelData.toPwrFR = fuelMatrixList[legNo].toPwrFR
//                
//                fuelData.cat23 = fuelMatrixList[legNo].cat23
                
                
            }
            do {
                try context.save()
                
                
                
            } catch _ {
            }
        }
    }
    
    
    func saveCrewData(_ primaryDate: String, primaryFltNo: String, primaryFrom:String) {
        
        let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
        
        
        for i in 0..<FlightLogEntity.sharedInstance.flightIdentifiers.count {
            
            for c in 0..<crewMatrixList.count {
                
                let indexpath = IndexPath(row: c , section: 2)
                
                if (c < popupTable.numberOfRows(inSection: 2) ) {
                    //                let currentCell = popupTable.cellForRowAtIndexPath(indexpath) as! TableViewCell2
                    
                    
                    
                    if ( FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation != "" ) {
                        
                        let datePredicate = NSPredicate(format: "date = %@", FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate)
                        let fltNoPredicate = NSPredicate(format: "fltNo = %@", FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo)
                        let fromPredicate = NSPredicate(format: "from = %@", FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation)
                        
                        let pnoPredicate = NSPredicate(format: "staffno = %@", crewMatrixList[c].staffno)
                        
                        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, pnoPredicate])
                        
                        
                        fetchreq.predicate = compound
                        
                        
                        let data = try! context.fetch(fetchreq)
                        
                        
                        // @todo change for new records check
                        if ( data.count > 0  ) {
                            
                            let datePredicate = NSPredicate(format: "date = %@", FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate)
                            let fltNoPredicate = NSPredicate(format: "fltNo = %@", FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo)
                            let fromPredicate = NSPredicate(format: "from = %@", FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation)
                            
                            let pnoPredicate = NSPredicate(format: "staffno = %@", crewMatrixList[c].staffno)
                            
                            let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, pnoPredicate])
                            
                            
                            fetchreq.predicate = compound
                            
                            
                            let data = try! context.fetch(fetchreq)
                            
                            for crewData in data {
                                crewData.source = "IPAD"
                                crewData.primaryDate = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate
                                crewData.primaryFltNo = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
                                crewData.primaryFrom = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation
                                crewData.fltNo = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo
                                crewData.date = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate
                                crewData.from = FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation
                                crewData.sno = "0"
                                
//                                if ( crewData.staffno! == "52372" ) {
//
//                                    print (crewData.staffno)
//
//                                }
                                crewData.stn = crewMatrixList[c].stn
                                crewData.gmt = crewMatrixList[c].gmt
                                switch i {
                                case 0:crewData.status = crewMatrixList[c].status1
                                case 1:crewData.status = crewMatrixList[c].status2
                                case 2:crewData.status = crewMatrixList[c].status3
                                case 3:crewData.status = crewMatrixList[c].status4
                                case 4:crewData.status = crewMatrixList[c].status5
                                default:crewData.status = crewMatrixList[c].status1
                                }
                                
                                do {
                                    try context.save()
                                } catch _ {
                                }
                                
                            }
                            
                        } else {
                            
                            let entityDescripition = NSEntityDescription.entity(forEntityName: "CrewData", in: context)
                            
                            let crewData = CrewData(entity: entityDescripition!, insertInto: context)
                            
                            crewData.source = "IPAD"
                            crewData.primaryDate = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate
                            crewData.primaryFltNo = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
                            crewData.primaryFrom = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation
                            crewData.fltNo = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo
                            crewData.date = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate
                            crewData.from = FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation
                            crewData.sno = "0"
                            crewData.pos = crewMatrixList[c].pos
                            crewData.staffno = crewMatrixList[c].staffno
                            switch i {
                            case 0:crewData.status = crewMatrixList[c].status1
                            case 1:crewData.status = crewMatrixList[c].status2
                            case 2:crewData.status = crewMatrixList[c].status3
                            case 3:crewData.status = crewMatrixList[c].status4
                            case 4:crewData.status = crewMatrixList[c].status5
                            default:crewData.status = crewMatrixList[c].status1
                            }
                            crewData.stn = crewMatrixList[c].stn
                            crewData.gmt = crewMatrixList[c].gmt
                            
                            
                            
                            
                            do {
                                try context.save()
                            } catch _ {
                            }
                        }
                        
                    }
                    
                }
                
                
            }
        }
    }
    
    func saveLegData(_ flights:[LegData],  legNo:Int, primaryDate: String, primaryFltNo: String, primaryFrom:String) {
        
        //        let indexpath = NSIndexPath(forRow: Int(legNo) , inSection: 0)
        //        let currentCell = popupTable.cellForRowAtIndexPath(indexpath) as! TableViewCell
        
        let dep = flightLegMatrixList[legNo].from
        let arr = flightLegMatrixList[legNo].to
        let date = flightLegMatrixList[legNo].date
        let fltNo = flightLegMatrixList[legNo].fltNo
        
        
        FlightLogEntity.sharedInstance.flightIdentifiers[legNo].fltNo = fltNo
        FlightLogEntity.sharedInstance.flightIdentifiers[legNo].fltDate = date
        FlightLogEntity.sharedInstance.flightIdentifiers[legNo].depStation = dep
        
        
        if (dep != "" && arr != "" && date != "" && arr != "" ) {
            var filteredArray = flights.filter( { (legData: LegData) -> Bool in
                return legData.date == date && legData.fltNo == fltNo && legData.from == dep && legData.source == "IPAD"
            })
            // if local copy (filled by captain) found
            if ( filteredArray.count == 1 ) {
                let legData = filteredArray[0]
                context.delete(legData)
                
            }
            
            let entityDescripition = NSEntityDescription.entity(forEntityName: "LegData", in: context)
            
            let legData = LegData(entity: entityDescripition!, insertInto: context)
            
            
            legData.date = date
            legData.fltNo = fltNo
            legData.from = dep
            legData.source = "IPAD"
            legData.legNo = legNo as NSNumber?
            legData.primaryDate = primaryDate
            legData.primaryFltNo = primaryFltNo
            legData.primaryFrom = primaryFrom
            legData.captainId = userEntity.username
            
            //            legData.reg = self.registration.text
            legData.captainId = userEntity.username
            
            
            legData.reg = flightLegMatrixList[legNo].reg
            legData.aircraft = flightLegMatrixList[legNo].aircraft
            //            let to = self.getUIViewByTagId(4+legNo*13) as! UITextField
            legData.to = flightLegMatrixList[legNo].to
            //            let blocksOff = self.getUIViewByTagId(5+legNo*13) as! UITextField
            legData.blocksOff = flightLegMatrixList[legNo].blocksOff
            //            let takeOff = self.getUIViewByTagId(6+legNo*13) as! UITextField
            legData.takeOff = flightLegMatrixList[legNo].takeOff
            //            let landing = self.getUIViewByTagId(7+legNo*13) as! UITextField
            legData.landing = flightLegMatrixList[legNo].landing
            //            let blocksOn = self.getUIViewByTagId(8+legNo*13) as! UITextField
            legData.blocksOn = flightLegMatrixList[legNo].blocksOn
            
            legData.blockTime = flightLegMatrixList[legNo].blockTime
            legData.nightTime = flightLegMatrixList[legNo].nightTime
            legData.instTime = flightLegMatrixList[legNo].instTime
            legData.toFlag = flightLegMatrixList[legNo].toFlag
            legData.landFlag = flightLegMatrixList[legNo].landFlag
            
            //            let blockTime = self.getUIViewByTagId(9+legNo*13) as! UITextField
            //            legData.blockTime = currentCell.blockTime.text!
            //            let nightTime = self.getUIViewByTagId(10+legNo*13) as! UITextField
            //            legData.nightTime = currentCell.nightTime.text!
            //            let instTime = self.getUIViewByTagId(11+legNo*13) as! UITextField
            //            legData.instTime = currentCell.instTime.text!
            //            let toFlag = self.getUIViewByTagId(12+legNo*13) as! UITextField
            //            legData.toFlag = currentCell.toFlag.text!
            //            let landFlag = self.getUIViewByTagId(13+legNo*13) as! UITextField
            //            legData.landFlag = currentCell.landFlag.text!
            if ( legData.std == nil ) {
                legData.std = legData.blocksOff
            }
            if (legData.sta == nil ) {
                legData.sta = legData.blocksOn
            }
            
        }
        
        
        do {
            try context.save()
            
            
            
        } catch _ {
        }
        
    }
    
    
    
    func populateFlight(_ legData:LegData) {
        
        let indexpath = IndexPath(row: Int(legData.legNo!) , section: 0)
        let currentCell = popupTable.cellForRow(at: indexpath) as! TableViewCell
        
        //let date:UITextField = self.getUIViewByTagId(1 + Int(legData.legNo!) * 13) as! UITextField
        currentCell.date.text = StringUtils.getDMYStringFromYMDString(legData.date!)
        //let fltNo:UITextField  = self.getUIViewByTagId(2 + Int(legData.legNo!) * 13) as! UITextField
        currentCell.flightNo.text = legData.fltNo
        //let from:UITextField  = self.getUIViewByTagId(3 + Int(legData.legNo!) * 13) as! UITextField
        currentCell.from.text = legData.from
        
        flightLegMatrixList[Int(legData.legNo!)].legNo = legData.legNo
        flightLegMatrixList[Int(legData.legNo!)].aircraft = legData.aircraft!
        flightLegMatrixList[Int(legData.legNo!)].blocksOff = legData.blocksOff!
        flightLegMatrixList[Int(legData.legNo!)].blocksOn = legData.blocksOn!
        flightLegMatrixList[Int(legData.legNo!)].blockTime = legData.blockTime!
        flightLegMatrixList[Int(legData.legNo!)].captainId = legData.captainId!
        flightLegMatrixList[Int(legData.legNo!)].date = legData.date!
        flightLegMatrixList[Int(legData.legNo!)].fltNo = legData.fltNo!
        flightLegMatrixList[Int(legData.legNo!)].from = legData.from!
        flightLegMatrixList[Int(legData.legNo!)].instTime = legData.instTime!
        flightLegMatrixList[Int(legData.legNo!)].landFlag = legData.landFlag!
        flightLegMatrixList[Int(legData.legNo!)].landing = legData.landing!
        flightLegMatrixList[Int(legData.legNo!)].nightTime = legData.nightTime!
        flightLegMatrixList[Int(legData.legNo!)].primaryDate = legData.primaryDate!
        flightLegMatrixList[Int(legData.legNo!)].primaryFltNo = legData.primaryFltNo!
        flightLegMatrixList[Int(legData.legNo!)].primaryFrom = legData.primaryFrom!
        flightLegMatrixList[Int(legData.legNo!)].reg = legData.reg!
        flightLegMatrixList[Int(legData.legNo!)].source = legData.source!
        flightLegMatrixList[Int(legData.legNo!)].sta = legData.sta!
        flightLegMatrixList[Int(legData.legNo!)].std = legData.std!
        flightLegMatrixList[Int(legData.legNo!)].takeOff = legData.takeOff!
        flightLegMatrixList[Int(legData.legNo!)].to = legData.to!
        flightLegMatrixList[Int(legData.legNo!)].toFlag = legData.toFlag!
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if ( FlightLogEntity.sharedInstance.flightIdentifiers.count == 0 ){
            FlightLogEntity.sharedInstance.initIdentifiers()
        }
        
        let indexpath = IndexPath(row: 0 , section: 0)
        if ( popupTable.cellForRow(at: indexpath) == nil ) {
            let alert = UIAlertController(title: "Flight Log", message: "Please re-validate flight timings.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        
        let currentCell = popupTable.cellForRow(at: indexpath) as! TableViewCell
        
        
        currentCell.flightNo.text  = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
        currentCell.date.text = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate
        currentCell.from.text = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation
        
        //        if ( true ) {
        //            //            flightLeg÷MatrixList[indexPath?.row].legNo = legNo
        //            //            flightLegMatrixList[indexPath?.row].aircraft = legData.aircraft
        //            flightLegMatrixList[indexpath].blocksOff = cell.blockOff.text!
        //            flightLegMatrixList[indexpath].blocksOn = cell.blocksOn.text!
        //            //            flightLegMatrixList[indexpath].blockTime = cell.blockTime.text
        //            //            flightLegMatrixList[indexPath?.row].captainId = legData.captainId
        //            flightLegMatrixList[indexpath].date = StringUtils.getYMDStringFromDMYString(cell.date.text!)
        //            flightLegMatrixList[indexpath].fltNo = cell.flightNo.text!
        //            flightLegMatrixList[indexpath].from = cell.from.text!
        //            //            flightLegMatrixList[indexPath?.row].instTime = legData.instTime
        //            //            flightLegMatrixList[indexPath?.row].landFlag = legData.landFlag
        //            flightLegMatrixList[indexpath].landing = cell.landing.text!
        //            //            flightLegMatrixList[indexPath?.row].nightTime = legData.nightTime
        //            //            flightLegMatrixList[indexPath?.row].primaryDate = legData.primaryDate
        //            //            flightLegMatrixList[indexPath?.row].primaryFltNo = legData.primaryFltNo
        //            //            flightLegMatrixList[indexPath?.row].primaryFrom = legData.primaryFrom
        //            //            flightLegMatrixList[indexpath].reg = cell.reg.text
        //            //            flightLegMatrixList[indexpath].source = cell.source.text
        //            //            flightLegMatrixList[indexpath].sta = cell.sta.text
        //            //            flightLegMatrixList[indexpath].std = cell.std.text
        //            flightLegMatrixList[indexpath].takeOff = cell.takeOff.text!
        //            flightLegMatrixList[indexpath].to = cell.to.text!
        //            //            flightLegMatrixList[indexpath].toFlag = cell.toFlag.text
        //
        //        }
        
        //                    self.aircraftType.text = self.aircraft
        //                    self.registration.text = self.reg
        
        if ( FlightLogEntity.sharedInstance.getLegCount() > 0 ) {
            
            let legRequest = NSFetchRequest<LegData>(entityName: "LegData")
            do {
                let data = try context.fetch(legRequest)
                
                
                let flights = data
                
                let filteredArray = flights.filter( { (legData: LegData) -> Bool in
                    return legData.date == StringUtils.getYMDStringFromDMYString(self.fltDate)  && legData.fltNo == self.fltNo && legData.from == self.depStation && legData.source == "IPAD"
                })
                
                if ( filteredArray.count == 1 ) {
                    let filterLegData = filteredArray[0]
                    
                    currentCell.flightNo.text  = filterLegData.primaryFltNo!
                    currentCell.date.text = filterLegData.primaryDate!
                    currentCell.from.text = filterLegData.primaryFrom!
                    
                    let filteredArray = flights.filter( { (legData: LegData) -> Bool in
                        return legData.source == "IPAD" && legData.primaryDate == currentCell.date.text && legData.primaryFltNo == currentCell.flightNo.text && legData.primaryFrom == currentCell.from.text
                    })
                    
                    flightLegMatrixList.removeAll()
                    
                    for i in 0..<filteredArray.count  {
                        let newFlightLegMatrix = FlightLegMatrix()
                        flightLegMatrixList.append(newFlightLegMatrix)
                        populateFlight(filteredArray[i])
                    }
                    
                }
                
            } catch _ {
                print("Error")
            }
            
            
        }
        
        
        
        loadFlightData()
        
        
        
        if ( !pastDataExists() ) {
            copyJSONSourceToIPAD()
        }
        
        fetchFuelFromDB()
        fetchFromDB()
        
        self.popupTable.reloadData()
        
    }
    
    
    
    func getMatrixElementByStaffNo(_ staffNo:String ) -> Int? {
        for i in 0..<crewMatrixList.count {
            if ( crewMatrixList[i].staffno == staffNo) {
                return i
            }
        }
        return nil
    }
    
    func crewDataSorter (_ crew1:CrewData, crew2:CrewData) -> Bool {
        return crew1.pos  < crew2.pos
    }
    
    func isPartOfParentController(_ crewData: CrewData) -> Bool {
        
        
        for i in 0...0 {
            
            if ( FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo == crewData.fltNo &&
                FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate ==  StringUtils.getDMYStringFromYMDString(crewData.date!)  &&
                FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation == crewData.from ) {
                return true
            }
        }
        return false
    }
    
    func populateMatrix () -> Int? {
        var highestOrder:Int? = nil
        
        for i in 0...0 {
            for fltCrew in flightCrews {
                if ( FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo == fltCrew.fltNo &&
                    FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate == StringUtils.getDMYStringFromYMDString(fltCrew.date!)  &&
                    FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation == fltCrew.from ) {
                    highestOrder = i
                    
                    if ( fltCrew.staffno! == "52372" ) {
                        
                        print (fltCrew.staffno!)
                        
                    }
                    
                    if let index = getMatrixElementByStaffNo(fltCrew.staffno!) {
                        switch i {
                        case 0 :crewMatrixList[index].status1 = fltCrew.status!
                        case 1 :crewMatrixList[index].status2 = fltCrew.status!
                        case 2 :crewMatrixList[index].status3 = fltCrew.status!
                        case 3 :crewMatrixList[index].status4 = fltCrew.status!
                        case 4 :crewMatrixList[index].status5 = fltCrew.status!
                        default : break
                        }
                        
                    } else {
                        var newCrewMatrix = CrewMatrix()
                        switch i {
                        case 0 :newCrewMatrix.status1 = fltCrew.status!
                        case 1 :newCrewMatrix.status2 = fltCrew.status!
                        case 2 :newCrewMatrix.status3 = fltCrew.status!
                        case 3 :newCrewMatrix.status4 = fltCrew.status!
                        case 4 :newCrewMatrix.status5 = fltCrew.status!
                        default : break
                        }
                        newCrewMatrix.pos = fltCrew.pos!
                        newCrewMatrix.name = MiscUtilsFltLog.getCrewNameByStaffNo(fltCrew.staffno!)
                        newCrewMatrix.staffno = fltCrew.staffno!
                        newCrewMatrix.stn = fltCrew.stn!
                        newCrewMatrix.gmt = fltCrew.gmt!
                        newCrewMatrix.flightNo = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo
                        newCrewMatrix.from = FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation
                        newCrewMatrix.date = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate
                        
                        
                        crewMatrixList.append(newCrewMatrix)
                        
                    }
                    
                }
            }
        }
        return highestOrder
    }
    
    func fetchFromDB() {
        
        print(#function)
        
        let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
        
        //        let parentController =  self.tabBarController as! FLTabBarController
        
        var fltNo =  FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
        var date = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate
        var dep = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation
        
        
        
        let datePredicate = NSPredicate(format: "primaryDate = %@", StringUtils.getYMDStringFromDMYString(date))
        let fltNoPredicate = NSPredicate(format: "primaryFltNo = %@", fltNo)
        let fromPredicate = NSPredicate(format: "primaryFrom = %@", dep)
        let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, sourcePredicate])
        
        fetchreq.predicate = compound
        
        var data = try! context.fetch(fetchreq)
        crewDataList = data
        
        if ( data.count ==  0 ) {
            //            let datePredicate = NSPredicate(format: "primaryDate = %@", StringUtils.getYMDStringFromDMYString(date))
            //            let fltNoPredicate = NSPredicate(format: "primaryFltNo = %@", fltNo)
            //            let fromPredicate = NSPredicate(format: "primaryFrom = %@", dep)
            //            let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
            //
            //            let compound = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, sourcePredicate])
            //
            //            fetchreq.predicate = compound
            fetchreq.predicate = nil
            var data = try! context.fetch(fetchreq)
            crewDataList = data
        }
        
        
        crewDataList.sort(by: crewDataSorter)
        
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
        
        //        dispatch_async(dispatch_get_main_queue(), {
        // self.popupTable.reloadData()
        //        });
        
        
    }
    
    
    
    func copyJSONSourceToIPAD() {
        
        let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
        
        for i in 0..<FlightLogEntity.sharedInstance.flightIdentifiers.count {
            
            if (FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate != "" && FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation != "" ) {
                
                let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString( FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate))
                let fltNoPredicate = NSPredicate(format: "fltNo = %@", FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo)
                let fromPredicate = NSPredicate(format: "from = %@", FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation)
                
                let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
                
                fetchreq.predicate = compound
                
                
                let data = try! context.fetch(fetchreq)
                
                for crewData in data {
                    crewData.source = "IPAD"
                    crewData.primaryDate = StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate)
                    crewData.primaryFltNo = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
                    crewData.primaryFrom = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation
                }
                do {
                    try context.save()
                } catch _ {
                }
                
            }
        }
        
        
        
        do {
            try context.save()
        } catch _ {
        }
    }
    
    
    func pastDataExists() -> Bool {
        
        
        let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
        
        if ( FlightLogEntity.sharedInstance.flightIdentifiers.count == 0 ){
            FlightLogEntity.sharedInstance.initIdentifiers()
        }
        if (FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate != "" && FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation != "" ) {
            let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate))
            let fltNoPredicate = NSPredicate(format: "fltNo = %@", FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo)
            let fromPredicate = NSPredicate(format: "from = %@", FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation)
            let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
            
            let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate,sourcePredicate])
            
            fetchreq.predicate = compound
            
            
            let data = try! context.fetch(fetchreq)
            
            return data.count > 0
        }
        return false
    }
    
    
    
    // ValidationDelegate methods
    
    func validationSuccessful() {
        // submit the form
    }
    
/*    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
        }
    } */
    
    /*
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validator.validateField(textField){ error in
            if error == nil {
                // Field validation was successful
            } else {
                // Validation error occurred
            }
        }
        return true
    }*/
    
    
    func loadLegData(_ legData:LegData, legNo:Int, cell:TableViewCell) {
        //        self.aircraftType.text = legData.aircraft
        //        self.registration.text = legData.reg
        
        cell.to.text = legData.to
        cell.blockOff.text = legData.blocksOff
        //        cell.takeOff.text = legData.takeOff
        //        cell.landing.text = legData.landing
        cell.takeOff.text = ""
        cell.landing.text = ""
        cell.blocksOn.text = legData.blocksOn
        
        flightLegMatrixList[legNo].legNo = legNo as NSNumber?
        flightLegMatrixList[legNo].aircraft = legData.aircraft!
        flightLegMatrixList[legNo].blocksOff = legData.blocksOff!
        flightLegMatrixList[legNo].blocksOn = legData.blocksOn!
        flightLegMatrixList[legNo].blockTime = legData.blockTime!
        //        flightLegMatrixList[legNo].captainId = legData.captainId!
        flightLegMatrixList[legNo].date = legData.date!
        flightLegMatrixList[legNo].fltNo = legData.fltNo!
        flightLegMatrixList[legNo].from = legData.from!
        flightLegMatrixList[legNo].instTime = legData.instTime!
        flightLegMatrixList[legNo].landFlag = legData.landFlag!
        flightLegMatrixList[legNo].landing = legData.landing!
        flightLegMatrixList[legNo].nightTime = legData.nightTime!
        if let s = legData.primaryDate {
            flightLegMatrixList[legNo].primaryDate = s
        }
        if let s = legData.primaryFltNo {
            flightLegMatrixList[legNo].primaryFltNo = s
        }
        if let s = legData.primaryFrom {
            flightLegMatrixList[legNo].primaryFrom = s
        }
        flightLegMatrixList[legNo].reg = legData.reg!
        //        flightLegMatrixList[legNo].source = legData.source!
        flightLegMatrixList[legNo].sta = legData.sta!
        flightLegMatrixList[legNo].std = legData.std!
        flightLegMatrixList[legNo].takeOff = legData.takeOff!
        flightLegMatrixList[legNo].to = legData.to!
        flightLegMatrixList[legNo].toFlag = legData.toFlag!
        
        //        let to = self.getUIViewByTagId(4+legNo*13) as! UITextField
        //        to.text = legData.to
        //        let blocksOff = self.getUIViewByTagId(5+legNo*13) as! UITextField
        //        blocksOff.text = legData.blocksOff
        //        let takeOff = self.getUIViewByTagId(6+legNo*13) as! UITextField
        //        takeOff.text = legData.takeOff
        //        let landing = self.getUIViewByTagId(7+legNo*13) as! UITextField
        //        landing.text = legData.landing
        //        let blocksOn = self.getUIViewByTagId(8+legNo*13) as! UITextField
        //        blocksOn.text = legData.blocksOn
        //        let blockTime = self.getUIViewByTagId(9+legNo*13) as! UITextField
        //        blockTime.text = legData.blockTime
        //        let nightTime = self.getUIViewByTagId(10+legNo*13) as! UITextField
        //        nightTime.text = legData.nightTime
        //        let instTime = self.getUIViewByTagId(11+legNo*13) as! UITextField
        //        instTime.text = legData.instTime
        //        let toFlag = self.getUIViewByTagId(12+legNo*13) as! UITextField
        //        toFlag.text = legData.toFlag
        //        let landFlag = self.getUIViewByTagId(13+legNo*13) as! UITextField
        //        landFlag.text = legData.landFlag
        
    }
    
    
    func loadFlightData() {
        
        
        flightLegMatrixList.removeAll()
        
        for i in 0...0 {
            
            var newFlightLegMatrix = FlightLegMatrix()
            flightLegMatrixList.append(newFlightLegMatrix)
            
            let indexpath = IndexPath(row: i, section: 0)
            let cell = popupTable.cellForRow(at: indexpath) as! TableViewCell
            
            let date = cell.date.text!
            let dep = cell.from.text!
            let arr = cell.to.text!
            
            if (date != "" && dep != "" && arr == "") {
                let date = cell.date.text!
                let fltNo = cell.flightNo.text!
                
                let legRequest = NSFetchRequest<LegData>(entityName: "LegData")
                do {
                    let data = try context.fetch(legRequest)
                    
                    let flights = data
                    
                    var filteredArray = flights.filter( { (legData: LegData) -> Bool in
                        return legData.date == StringUtils.getYMDStringFromDMYString(date) && legData.fltNo == fltNo && legData.from == dep && legData.source == "IPAD"
                    })
                    // if local copy (filled by captain) found
                    if ( filteredArray.count == 1 ) {
                        let legData = filteredArray[0]
                        loadLegData(legData, legNo: i, cell: cell)
                    } else {
                        filteredArray = flights.filter( { (legData: LegData) -> Bool in
                            return legData.date == StringUtils.getYMDStringFromDMYString(date) && legData.fltNo == fltNo && legData.from == dep && legData.source == "JSON"
                        })
                        // if json copy found
                        if ( filteredArray.count == 1 ) {
                            let legData = filteredArray[0]
                            loadLegData(legData, legNo: i, cell: cell)
                        }
                    }
                } catch _ {
                    print("Error")
                }
                
            }
            
        }
        updateParentController()
    }
    
    func updateParentController() {
        
        FlightLogEntity.sharedInstance.initIdentifiers()
        for i in 0...0 {
            let indexpath = IndexPath(row: i, section: 0)
            let cell = popupTable.cellForRow(at: indexpath) as! TableViewCell
            
            let date = cell.date.text!
            let dep = cell.from.text!
            let fltNo = cell.flightNo.text!
            
            //            let dep = self.getUIViewValueByTagId(i * 13 + 3)! as String
            //            let date = self.getUIViewValueByTagId(i * 13 + 1)! as String
            //            let fltNo = self.getUIViewValueByTagId(i * 13 + 2)! as String
            
            FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo = fltNo
            FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate = date
            FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation = dep
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            
            let cell =  tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
            
//            validator.registerField(cell.blockOff, errorLabel: cell.errorLabel, rules: [RequiredRule(), MinLengthRule(length: 4)])
            
            cell.legNoLabel.text = String((indexPath as NSIndexPath).row + 1)
            cell.viewController = self
            //            cell.flightNo.text = self.fltNo
            //            cell.date.text = self.fltDate
            //            cell.from.text = self.depStation
            
            return cell
            
        }else if (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as! TableViewCell1
            
            cell.legNoLabel.text = String((indexPath as NSIndexPath).row + 1)
            
            cell.fuelUpliftQty.text = fuelMatrixList[(indexPath as NSIndexPath).row].fuelUpLiftQty
            
            cell.fuelUpliftUnit.selectedSegmentIndex = Int(fuelMatrixList[(indexPath as NSIndexPath).row].fuelUplUnit)
            
            cell.density.text = fuelMatrixList[(indexPath as NSIndexPath).row].density
            
            cell.depKG.text = fuelMatrixList[(indexPath as NSIndexPath).row].depKG
            
            cell.arrKG.text = fuelMatrixList[(indexPath as NSIndexPath).row].arrKG
            
            cell.zeroFuelWeight.text = fuelMatrixList[(indexPath as NSIndexPath).row].zeroFuelWt
            
            cell.toPwrFR.text = fuelMatrixList[(indexPath as NSIndexPath).row].toPwrFR
            
            cell.cat23.selectedSegmentIndex = Int(fuelMatrixList[(indexPath as NSIndexPath).row].cat23)
            
            return cell
            
        }else{
            let cell =  tableView.dequeueReusableCell(withIdentifier: "cell2") as! TableViewCell2
            
            cell.sno.text = "\((indexPath as NSIndexPath).row + 1)"
            cell.pos.text = crewMatrixList[(indexPath as NSIndexPath).row].pos
            cell.name.text = crewMatrixList[(indexPath as NSIndexPath).row].name
            cell.staffno.text = crewMatrixList[(indexPath as NSIndexPath).row].staffno
            cell.status1.text = crewMatrixList[(indexPath as NSIndexPath).row].status1
            cell.status2.text = crewMatrixList[(indexPath as NSIndexPath).row].status2
            cell.status3.text = crewMatrixList[(indexPath as NSIndexPath).row].status3
            cell.status4.text = crewMatrixList[(indexPath as NSIndexPath).row].status4
            cell.status5.text = crewMatrixList[(indexPath as NSIndexPath).row].status5
            cell.stn.text = crewMatrixList[(indexPath as NSIndexPath).row].stn
            cell.gmt.text = crewMatrixList[(indexPath as NSIndexPath).row].gmt
            
            return cell
            
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
            
        }else if section == 1 {
            return fuelMatrixList.count
            
        }else{
            return self.crewMatrixList.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        if section == 0 {
            let nibView = Bundle.main.loadNibNamed("header", owner: self, options: nil)?[0] as! UIView
            return nibView
        }
        else if section == 1 {
            let nibView = Bundle.main.loadNibNamed("Header1", owner: self, options: nil)?[0] as! UIView
            return nibView
        }else{
            let nibView = Bundle.main.loadNibNamed("header2", owner: self, options: nil)?[0] as! UIView
            return nibView
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func fetchFuelFromDB() {
        print(#function, terminator: "")
        
        if ( FlightLogEntity.sharedInstance.flightIdentifiers.count == 0 ){
            FlightLogEntity.sharedInstance.initIdentifiers()
        }
        
        
        let datePredicate = NSPredicate(format: "primaryFltDate = %@",StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate))
        let fltNoPredicate = NSPredicate(format: "primaryFltNo = %@", FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo)
        let fromPredicate = NSPredicate(format: "primaryFrom = %@", FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation)
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
        
//        let fuelFetchreq = NSFetchRequest<FuelData>(entityName: "FuelData")
//        fuelFetchreq.predicate = compound
//        
//        do {
//            let data = try context.fetch(fuelFetchreq)
//            
//            fuelDataList = data
//            
//            
//        } catch {
//            print ("Error")
//        }
        
        let acPackFetchreq = NSFetchRequest<ACPackData>(entityName: "ACPackData")
        acPackFetchreq.predicate = compound
        
        do {
            let data = try context.fetch(acPackFetchreq)
            
            acPackDataList = data
            
            
        } catch {
            print ("Error")
        }
        
        
        populateFuelMatrix()
        
        
        
        //        dispatch_async(dispatch_get_main_queue(), {
        //            self.popupTable.reloadData()
        //        });
        
        
    }
    
    
    
    
    
    func populateFuelMatrix () -> Int? {
        fuelMatrixList.removeAll()
        acPackMatrixList.removeAll()
        let highestOrder:Int? = nil
        
        let legCount = FlightLogEntity.sharedInstance.getLegCount()
        
        for i in 0..<legCount  {
            var found:Bool = false
            
            
            
            if (i < acPackDataList.count) {
                let fltACPack = acPackDataList[i]
                if ( StringUtils.getDMYStringFromYMDString( fltACPack.date!) == FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate &&  fltACPack.fltNo!  == FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo && fltACPack.from!  == FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation ) {
                    
                    
                    
                    var acPackMatrix = ACPackMatrix()
                    acPackMatrix.flightLevel = fltACPack.flightLevel!
                    acPackMatrix.grossWeight = fltACPack.grossWeight!
                    acPackMatrix.tat = fltACPack.tat!
                    acPackMatrix.sat = fltACPack.sat!
                    acPackMatrix.mach = fltACPack.mach!
                    acPackMatrix.ias = fltACPack.ias!
                    acPackMatrix.ePRTQL = fltACPack.ePRTQL!
                    acPackMatrix.ePRTQR = fltACPack.ePRTQR!
                    acPackMatrix.n1NPL = fltACPack.n1NPL!
                    acPackMatrix.n1NPR = fltACPack.n1NPR!
                    acPackMatrix.eGTTTL = fltACPack.eGTTTL!
                    acPackMatrix.eGTTTR = fltACPack.eGTTTR!
                    acPackMatrix.n2NHL = fltACPack.n2NHL!
                    acPackMatrix.n2NHR = fltACPack.n2NHR!
                    acPackMatrix.fuelFlowL = fltACPack.fuelFlowL!
                    acPackMatrix.fuelFlowR = fltACPack.fuelFlowR!
                    acPackMatrix.engineBleedL = fltACPack.engineBleedL!
                    acPackMatrix.engineBleedR = fltACPack.engineBleedR!
                    acPackMatrix.vIBN1L = fltACPack.vIBN1L!
                    acPackMatrix.vIBN1R = fltACPack.vIBN1R!
                    acPackMatrix.vIBN2L = fltACPack.vIBN2L!
                    acPackMatrix.vIBN2R = fltACPack.vIBN2R!
                    acPackMatrix.oilPressL = fltACPack.oilPressL!
                    acPackMatrix.oilPressR = fltACPack.oilPressR!
                    acPackMatrix.oilTempL = fltACPack.oilTempL!
                    acPackMatrix.oilTempR = fltACPack.oilTempR!
                    acPackMatrix.nacTempL = fltACPack.nacTempL!
                    acPackMatrix.nacTempR = fltACPack.nacTempR!
                    acPackMatrixList.append(acPackMatrix)
                    found = true
                    
                }
            }
            if ( !found) {
                
                
                var newacPackMatrix = ACPackMatrix()
                newacPackMatrix.date = flightLegMatrixList[i].date
                newacPackMatrix.fltNo = flightLegMatrixList[i].fltNo
                newacPackMatrix.from = flightLegMatrixList[i].from
                newacPackMatrix.legNo = 0
                acPackMatrixList.append(newacPackMatrix)
                
            }
            
        }
        
        //        for i in fuelMatrixList.count...4 {
        //
        //                var newFuelMatrix = FuelMatrix()
        //                newFuelMatrix.date = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate
        //                newFuelMatrix.fltNo = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo
        //                newFuelMatrix.from = FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation
        //                fuelMatrixList.append(newFuelMatrix)
        //
        //        }
        
        return highestOrder
    }
    
}
