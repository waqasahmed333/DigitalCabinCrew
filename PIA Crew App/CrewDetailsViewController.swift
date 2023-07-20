//
//  CrewDetailsViewController.swift
//  FlightLog
//
//  Created by Naveed Azhar on 04/07/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData
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



struct  CrewMatrix {
    
    var sno: String = ""
    var pos: String = ""
    var name: String = ""
    var staffno: String = ""
    var status1: String = ""
    var status2: String = ""
    var status3: String = ""
    var status4: String = ""
    var status5: String = ""
    var stn: String = ""
    var gmt: String = ""
    var flightNo: String = ""
    var date: String = ""
    var from: String = ""
    var source: String = ""
    var primaryFltNo: String = ""
    var primaryDate: String = ""
    var primaryFrom: String = ""
    
}

class CrewDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var add: UIBarButtonItem!
    
    var crewMatrixList = [CrewMatrix]()
    
    @IBOutlet weak var Tableview: UITableView!
    
    @IBAction func save(_ sender: AnyObject) {
        for i in 0..<crewMatrixList.count {
            
            let legRequest = NSFetchRequest<CrewData>(entityName: "CrewData")
            
            
            let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString(crewMatrixList[i].date))
            let fltNoPredicate = NSPredicate(format: "fltNo = %@", crewMatrixList[i].flightNo)
            let fromPredicate = NSPredicate(format: "from = %@", crewMatrixList[i].from)
            
            let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
            
            legRequest.predicate = compound
            
            let legList = try! context.fetch(legRequest)
            
            for legData in legList
            {
                
                
                legData.primaryFltNo =  FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
                legData.primaryDate = StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate)
                legData.primaryFrom = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation
                legData.source = "IPAD"
                
                
            }
            
            do {
                try context.save()
            } catch _ {
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppSettings.refresh(self.view)
        
        //        Indicator.start(self)
        
        //        self.fetchCrewListFromJSON()
        
    }
    @objc func sayHello(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "add", sender: nil)
        
    }
    func pastDataExists() -> Bool {
        
        
        let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
        
        if ( FlightLogEntity.sharedInstance.flightIdentifiers.count == 0 ){
            FlightLogEntity.sharedInstance.initIdentifiers()
        }
        if (FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate != "" && FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation != "" ) {
            let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString( FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate))
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
                    crewData.primaryDate = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.navigationItem.title = "Crew Details"
        let b = UIBarButtonItem(
            title: "Add Crew",
            style: .plain,
            target: self,
            action: #selector(CrewDetailsViewController.sayHello(_:))
        )
        
        b.tintColor = UIColor.systemBlue
        
        self.tabBarController?.navigationItem.setRightBarButtonItems([b], animated: true)
        
        if ( !pastDataExists() ) {
            copyJSONSourceToIPAD()
        }
        fetchFromDB()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return crewMatrixList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.Tableview.dequeueReusableCell(withIdentifier: "cell") as! CrewDetailTableViewCell
        cell.editButton.addTarget(self, action: #selector(CrewDetailsViewController.editData(_:)), for: .touchDragInside)
        cell.editButton.tag=(indexPath as NSIndexPath).row
        cell.sno.text = "\((indexPath as NSIndexPath).row + 1)"
        cell.pos.text = crewMatrixList[(indexPath as NSIndexPath).row].pos
        cell.name.text = crewMatrixList[(indexPath as NSIndexPath).row].name
        cell.staffno.text = crewMatrixList[(indexPath as NSIndexPath).row].staffno
        cell.status1.text = crewMatrixList[(indexPath as NSIndexPath).row].status1
        //        cell.status2.text = crewMatrixList[(indexPath as NSIndexPath).row].status2
        //        cell.status3.text = crewMatrixList[(indexPath as NSIndexPath).row].status3
        //        cell.status4.text = crewMatrixList[(indexPath as NSIndexPath).row].status4
        //        cell.status5.text = crewMatrixList[(indexPath as NSIndexPath).row].status5
        cell.stn.text = crewMatrixList[(indexPath as NSIndexPath).row].stn
        cell.gmt.text = crewMatrixList[(indexPath as NSIndexPath).row].gmt
        
        if #available(iOS 12.0, *) {
            cell.backgroundColor = MiscUtils.getRowBGColor(indexPathRow: indexPath.row, userInterfaceStyle: traitCollection.userInterfaceStyle)
        } else {
            // Fallback on earlier versions
        }
        
        return cell
    }
    
    func crewDataSorter (_ crew1:CrewData, crew2:CrewData) -> Bool {
        return crew1.pos  < crew2.pos
    }
    
    @objc func editData(_ sender:UIButton){
        
    }
    
    func fetchFromDB() {
        
        var fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
        
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
        
        func getCodedStatus (_ status:String, pos:String ) -> String {
            
            var dict : Dictionary<String, String> = [
                "P": "1", "A": "2", "S": "3", "M": "4", "X": "9",
                ]
            
            if (pos == "0" || pos == "1") {
                dict = [
                    "P": "1", "A": "1", "S": "3", "M": "4", "X": "9",
                ]
            }
            var str = status
            for (key, value) in dict {
                str = str.replacingOccurrences(of: key, with: value)
            }
            return str
            
        }
        
        func getCodedPos (_ status:String ) -> String {
            
            let dict : Dictionary<String, String> = [
                "0": "0", "1": "0", "5": "1", "6": "1", "7": "1", "8": "1", "9": "1"
            ]
            var str = status
            for (key, value) in dict {
                str = str.replacingOccurrences(of: key, with: value)
            }
            return str
            
        }
        
        
        
        let newCrewMatrixList = crewMatrixList.sorted { (lhs: CrewMatrix, rhs: CrewMatrix) -> Bool in
            
            return getCodedPos(lhs.pos) + getCodedStatus(lhs.status1 + lhs.status2 + lhs.status3 + lhs.status4 + lhs.status5 + lhs.pos + lhs.staffno, pos: lhs.pos)  < getCodedPos(rhs.pos) + getCodedStatus(rhs.status1 + rhs.status2 + rhs.status3 + rhs.status4 + rhs.status5 + rhs.pos + rhs.staffno, pos: rhs.pos)
            
            //return lhs.pos > rhs.pos
            
        }
        
        crewMatrixList =  newCrewMatrixList
        
        if ( crewMatrixList.count > 0 ) {
        FlightLogEntity.sharedInstance.flightIdentifiers[0].sharedCaptainId = crewMatrixList[0].staffno
        }

        
        self.Tableview.reloadData()
        
        
        
    }
    
    
    func populateMatrix () -> Int? {
        var highestOrder:Int? = nil
        
        for i in 0...0 {
            for fltCrew in flightCrews {
                if ( FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo == fltCrew.fltNo &&
                    FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate == StringUtils.getDMYStringFromYMDString(fltCrew.date!)  &&
                    FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation == fltCrew.from ) {
                    highestOrder = i
                    
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
    
    func getMatrixElementByStaffNo(_ staffNo:String ) -> Int? {
        for i in 0..<crewMatrixList.count {
            if ( crewMatrixList[i].staffno == staffNo) {
                return i
            }
        }
        return nil
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
    
    func getOtherSimilarCrew (_ crewMatrix:CrewMatrix) -> [String] {
        var otherSimilarCrew:[String] = []
        
        for i in 0..<self.crewMatrixList.count {
            if ( crewMatrix.status1 == self.crewMatrixList[i].status1 && crewMatrix.status2 == self.crewMatrixList[i].status2 && crewMatrix.status3 == self.crewMatrixList[i].status3 && crewMatrix.status4 == self.crewMatrixList[i].status4 && crewMatrix.status5 == self.crewMatrixList[i].status5 && crewMatrix.gmt == self.crewMatrixList[i].gmt && crewMatrix.stn == self.crewMatrixList[i].stn  ) {
                
                otherSimilarCrew.append(self.crewMatrixList[i].staffno)
                
            }
        }
        return otherSimilarCrew
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        let taskController:EditCrewDataViewController = segue.destination as! EditCrewDataViewController
        
        if segue.identifier == "edit" {
            //            let cell = sender as! UITableViewCell
            //            let indexPath = Tableview.indexPathForCell(cell)
            let crewMatrix:CrewMatrix = crewMatrixList[sender as! Int] as CrewMatrix
            taskController.crewMatrix = crewMatrix
            taskController.otherSimilarCrew = self.getOtherSimilarCrew(crewMatrix)
            taskController.segueName = "edit"
            
            
        } else if segue.identifier == "add" {
            
            var crewMatrix:CrewMatrix = CrewMatrix()
            crewMatrix.sno = "\(crewMatrixList.count + 1)"
            if ( crewMatrixList.count > 0 ) {
                crewMatrix.gmt = crewMatrixList[0].gmt
                crewMatrix.status1 = crewMatrixList[0].status1
                crewMatrix.stn = crewMatrixList[0].stn
            }
            taskController.crewMatrix = crewMatrix
            taskController.segueName = "add"
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "edit", sender: (indexPath as NSIndexPath).row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return EDIT_MODE == 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (EDIT_MODE == 1 && editingStyle == UITableViewCell.EditingStyle.delete) {
            
            
            let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
            
            for i in 0..<FlightLogEntity.sharedInstance.flightIdentifiers.count {
                
                if (FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate != "" && FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation != "" ) {
                    let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString( FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate))
                    let fltNoPredicate = NSPredicate(format: "fltNo = %@", FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo)
                    let fromPredicate = NSPredicate(format: "from = %@", FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation)
                    
                    let pnoPredicate = NSPredicate(format: "staffno = %@", crewMatrixList[(indexPath as NSIndexPath).row].staffno)
                    
                    let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, pnoPredicate])
                    
                    fetchreq.predicate = compound
                    
                    
                    let data = try! context.fetch(fetchreq)
                    
                    for crewData in data {
                        context.delete(crewData  as NSManagedObject)
                    }
                    
                }
            }
            
            
            
            do {
                try context.save()
            } catch _ {
            }
            
            //            crewMatrixList.removeAtIndex(indexPath.row)
            //            self.Tableview.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            self.fetchFromDB()
        }
    }
    
    
    
    
    
    
}
