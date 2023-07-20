
//
//  FlightListTableViewController.swift
//  FlightLog
//
//  Created by Naveed Azhar on 26/06/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData
import Reachability
import Alamofire
import SwiftyJSON


struct Setting {
    var name: String
    var value: String
}

var crewDataList = [CrewData]()
var flightCrews = [CrewData]()

var EDIT_MODE = 1

var DISPLAY_UPLOADED_LOGS = 0


class FlightListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, URLSessionDelegate {


    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.serverTrust == nil {
            completionHandler(.useCredential, nil)
        } else {
            let trust: SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }

    private static var Manager: Alamofire.SessionManager = {
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


    var postedFlights = [LegData]()

    @IBOutlet var Tableview: UITableView!


    var filterMode = 0;


    override func viewWillAppear(_ animated: Bool) {


        AppSettings.refresh(self.view)
        Indicator.start(self)
        self.fetchFlightInfoFromJSON();

        self.navigationItem.title = "Flight List"
        let b = UIBarButtonItem(
            title: "Add New Flight Log",
            style: .plain,
            target: self,
            action: #selector(FlightListTableViewController.addNewFlightLog(_:))
        )
        
        b.tintColor = UIColor.systemBlue

        self.navigationItem.rightBarButtonItem = b

        self.fetchFlightInfoFromLocalDB()

        self.Tableview.reloadData()


    }

    @objc func addNewFlightLog(_ sender: UIBarButtonItem) {
        FlightLogEntity.sharedInstance.initIdentifiers()
        EDIT_MODE = 1
        performSegue(withIdentifier: "add", sender: nil)


    }
    override func viewDidLoad() {
        super.viewDidLoad()

        /* implemented to see the impact of green button
         moved to viewwill appear
         
         AppSettings.refresh(self.view)
         Indicator.start(self)
         self.fetchFlightInfoFromJSON();
         
         */

    }

    func flightSorter (_ flight1: LegData, flight2: LegData) -> Bool {
        return flight1.date! + flight1.std! < flight2.date! + flight2.std!
    }

    func fetchFlightInfoFromLocalDB() {

        let legRequest = NSFetchRequest<LegData>(entityName: "LegData")
        let legData = try! context.fetch(legRequest)

        var isFlightPendingUpload = false

        if (DISPLAY_UPLOADED_LOGS == 1) {

            let statusPredicate = NSPredicate(format: "uploadStatus != nil AND uploadStatus == %@", "Uploaded")

            let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [statusPredicate])

            legRequest.predicate = compound
        } else {

            let statusPredicate = NSPredicate(format: "uploadStatus = nil OR uploadStatus != %@", "Uploaded")
            let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [statusPredicate])

            legRequest.predicate = compound
        }

        postedFlights.removeAll()


        for tempLegData: LegData in legData {
            var shouldDisplay = false

            if (DISPLAY_UPLOADED_LOGS == 0) {
                if (tempLegData.uploadStatus == nil || tempLegData.uploadStatus != "Uploaded") {
                    shouldDisplay = true

                    let date_obj = StringUtils.getDateFromString(StringUtils.getDMYStringFromYMDString(tempLegData.date!))

                    let fill_grace_period = Calendar.current.date(byAdding: .minute, value: -1440 * 7, to: Date())

                    let save_grace_period = Calendar.current.date(byAdding: .minute, value: -1440 * 14, to: Date())

                    let upload_grace_period = Calendar.current.date(byAdding: .minute, value: -1440 * 14, to: Date())

                    if ((tempLegData.uploadStatus == nil) && date_obj! < fill_grace_period!) {
                        shouldDisplay = false
                    }

                    if ((tempLegData.uploadStatus == "") && date_obj! < save_grace_period!) {
                        shouldDisplay = false
                    }

                    if ((tempLegData.uploadStatus == "Saved") && date_obj! < upload_grace_period!) {
                        shouldDisplay = false
                    }

                    if (MiscUtils.isOnlineMode()) {
                        if ((tempLegData.uploadStatus == "Saved") && date_obj! >= upload_grace_period!) {
                            isFlightPendingUpload = true
                        }

                    }

                }
            } else {
                if (tempLegData.uploadStatus == "Uploaded") {
                    shouldDisplay = true
                }
            }



            if (shouldDisplay) {
                //               print("\(tempLegData.uploadStatus) \(tempLegData.fltNo) \(tempLegData.date) \(tempLegData.from)")
                //                print ("Add posted flight 1 \(tempLegData.fltNo)")
                self.postedFlights.append(tempLegData)

            }
        }

        //postedFlights = legData

        postedFlights.sort(by: flightSorter)

        self.Tableview.reloadData()

        if (isFlightPendingUpload) {
            MiscUtils.alert("Flights pending upload", message: "You have not uploaded previously saved flights.\r\nPlease upload all such flights", controller: self)
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source



    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }




    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postedFlights.count
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = self.Tableview.dequeueReusableCell(withIdentifier: "flightCell") as! FlightListTableViewCell

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium

        cell.lblFlightNumber.text = "PK" + postedFlights[(indexPath as NSIndexPath).row].fltNo! + "/" + StringUtils.getDDMMStringFromYMDString(postedFlights[(indexPath as NSIndexPath).row].date!)
        cell.lblSector.text = postedFlights[(indexPath as NSIndexPath).row].from! + "-" + postedFlights[(indexPath as NSIndexPath).row].to!
        cell.scheduledTimings.text = postedFlights[(indexPath as NSIndexPath).row].std! + "-" + postedFlights[(indexPath as NSIndexPath).row].sta!
        cell.aircraftType.text = postedFlights[(indexPath as NSIndexPath).row].aircraft
        cell.captainId.text = postedFlights[(indexPath as NSIndexPath).row].captainId

        //        if( indexPath.row % 2 == 0 ){
        //            cell.backgroundColor = UIColor(red: 200.0/255, green: 255.0/255, blue: 200.0/255, alpha: 1.0)
        //        }
        //        else{
        //            cell.backgroundColor = UIColor(red: 150.0/255, green: 255.0/255, blue: 150.0/255, alpha: 1.0)
        //        }

        // if local copy (filled by captain) found

        if (postedFlights[(indexPath as NSIndexPath).row].source == "IPAD") {
            //            cell.swtStatus.setOn(true, animated: false)

        } else {
            //            cell.swtStatus.setOn(false, animated: false)
        }

        let status = postedFlights[(indexPath as NSIndexPath).row].uploadStatus

        cell.btnRefresh.isHidden = true

        if (status == nil) {
            cell.btnRefresh.isHidden = false
            cell.lblStatus.text = ""
            cell.lblCommand.setTitle("", for: UIControl.State.normal)
        } else if (status == "") {
            //cell.btnRefresh.isHidden = false
            cell.lblStatus.text = ""
            cell.lblCommand.setTitle("Save", for: UIControl.State.normal)
        } else if (status == "Saved") {
            cell.lblStatus.text = "Saved"
            cell.lblCommand.setTitle("Upload", for: UIControl.State.normal)
        } else if (status == "Uploaded") {
            cell.lblStatus.text = "Uploaded"
            cell.lblCommand.setTitle("Re-Upload", for: UIControl.State.normal)
        }

        if #available(iOS 12.0, *) {
            cell.backgroundColor = MiscUtils.getRowBGColor(indexPathRow: indexPath.row, userInterfaceStyle: traitCollection.userInterfaceStyle)
        } else {
            // Fallback on earlier versions
        }

        return cell

    }
    //    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        performSegueWithIdentifier("modifyLog", sender: indexPath.row)
    //    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {

        if segue.identifier == "modifyLog" {
            EDIT_MODE = 1

            let cell = sender as! FlightListTableViewCell
            let indexPath = Tableview.indexPath(for: cell)
            let parentController: FLTabBarController = segue.destination as! FLTabBarController

            let flight: LegData = postedFlights[(indexPath! as NSIndexPath).row]

            FlightLogEntity.sharedInstance.initIdentifiers()

            FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo = flight.fltNo!
            FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate = StringUtils.getDMYStringFromYMDString(flight.date!)
            FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation = flight.from!

            parentController.aircraft = flight.aircraft!
            parentController.reg = flight.reg!


            let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")

            //        let parentController =  self.tabBarController as! FLTabBarController

            let fltNo = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
            let date = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate
            let dep = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation


            let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString(date))
            let fltNoPredicate = NSPredicate(format: "fltNo = %@", fltNo)
            let fromPredicate = NSPredicate(format: "from = %@", dep)
            //            let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")

            let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])

            fetchreq.predicate = compound

            let data = try! context.fetch(fetchreq)
            crewDataList = data

            for crewData in crewDataList {
                if (crewData.staffno! == userEntity.username) {

                    if (crewData.status != "A" && crewData.status != "P") {
                        // if it is not surface travel
                        if (cell.aircraftType.text! != "TBA") {
                            EDIT_MODE = 0
                        }
                    }

                }
            }


            if (cell.lblStatus.text! == "Uploaded" || cell.lblStatus.text! == "Saved") {

                EDIT_MODE = 2

            }


        } else if segue.identifier == "add" {

            FlightLogEntity.sharedInstance.initIdentifiers()

        } else if segue.identifier == "logout" {

            userEntity.username = ""



        } else if (segue.identifier == "viewCurrentLogs") {
            DISPLAY_UPLOADED_LOGS = 0
        }

    }



    func fetchFlightInfoFromJSON() {



        FlightLogService.getFlFlightInfoList(userEntity.username!) { (flFlightInfoArray, error) in

            if error == nil {

                if !flFlightInfoArray!.isEmpty {

                    self.removeFlightInfoFromDB()
                    self.postedFlights.removeAll()

                    for flflightinfo in flFlightInfoArray! {



                        if !StringUtils.isIPADFlightPresentSavedOrUploaded(flflightinfo.date, flightNo: flflightinfo.flight, depStation: flflightinfo.dep) {



                            let legEntityDescripition = NSEntityDescription.entity(forEntityName: "LegData", in: context)

                            let legData = LegData(entity: legEntityDescripition!, insertInto: context)


                            if (DISPLAY_UPLOADED_LOGS == 0) {
                                //                                                print ("Add posted flight 2 \(legData.fltNo)")
                                self.postedFlights.append(legData)
                            } else {

                            }


                            legData.date = StringUtils.getYMDStringFromDMYString(flflightinfo.date)
                            legData.std = flflightinfo.std

                            legData.sta = flflightinfo.sta
                            legData.aircraft = flflightinfo.aircraft
                            legData.reg = flflightinfo.reg
                            legData.date = StringUtils.getYMDStringFromDMYString(flflightinfo.date)
                            legData.fltNo = flflightinfo.flight
                            legData.from = flflightinfo.dep
                            legData.to = flflightinfo.arr
                            //                            legData.blocksOff = flflightinfo.std
                            //                            legData.takeOff = flflightinfo.std
                            //                            legData.landing = flflightinfo.sta
                            //                            legData.blocksOn = flflightinfo.sta
                            //                            legData.blockTime = StringUtils.getHHMMFromMinutes(StringUtils.getDifferenceInMinutes(flflightinfo.std, hhmm2: flflightinfo.sta))
                            legData.blockTime = "0000"
                            legData.nightTime = "0000"
                            legData.instTime = "0000"
                            legData.toFlag = "01D"
                            legData.landFlag = "01D"
                            legData.source = "JSON"
                        } else {
                            let fetchreq = NSFetchRequest<LegData>(entityName: "LegData")

                            let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString(flflightinfo.date))
                            let fltNoPredicate = NSPredicate(format: "fltNo = %@", flflightinfo.flight)
                            let fromPredicate = NSPredicate(format: "from = %@", flflightinfo.dep)
                            //                                    let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")

                            let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])

                            fetchreq.predicate = compound


                            let data = try! context.fetch(fetchreq)

                            if data.count > 0
                            {


                                let legData = data[0]

                                var shouldDisplay = false

                                if (DISPLAY_UPLOADED_LOGS == 0) {
                                    if (legData.uploadStatus == nil || legData.uploadStatus != "Uploaded") {
                                        shouldDisplay = true
                                    }
                                } else {
                                    if (legData.uploadStatus == "Uploaded") {
                                        shouldDisplay = true
                                    }
                                }


                                if (shouldDisplay) {
                                    //                                                    print ("Add posted flight 3 \(legData.fltNo)")
                                    self.postedFlights.append(legData)

                                }


                                legData.std = flflightinfo.std
                                legData.sta = flflightinfo.sta



                            }



                            //                                                            crewDataList.append(LegData)

                        }

                    }


                    do {
                        try context.save()

                        self.fetchCrewScheduleFromJSON()


                    } catch let error as NSError {
                        print("Error occurred: \(error)")

                    } catch {
                        fatalError()
                    }

                    //                    self.Tableview.reloadData()

                } else {

                    //alert("Message", Body: "Flight Data not available")
                    Indicator.stop()

                }

            } else {
                alert("Message", Body: error!)
                Indicator.stop()

            }

        }
    }


    func removeCrewScheduleFromDB() {


        let legRequest = NSFetchRequest<CrewData>(entityName: "CrewData")
        let legList = try! context.fetch(legRequest)


        for bas: AnyObject in legList
        {

            let ld = bas as! CrewData

            if (ld.source != "IPAD") {
                context.delete(bas as! NSManagedObject)
            }

        }

        do {
            try context.save()
        } catch _ {
        }

    }

    func fetchCrewScheduleFromJSON() {



        FlightLogService.getFlCrewScheduleList(userEntity.username!) { (flCrewScheduleArray, error) in

            if error == nil {

                if !flCrewScheduleArray!.isEmpty {


                    self.removeCrewScheduleFromDB()

                    for flcrewschedule in flCrewScheduleArray! {


                        if (!StringUtils.pastDataExists(flcrewschedule.date, flightNo: flcrewschedule.fltno, depStation: flcrewschedule.dep)) {

                            let entityDescripition = NSEntityDescription.entity(forEntityName: "CrewData", in: context)

                            let crewData = CrewData(entity: entityDescripition!, insertInto: context)

                            crewData.source = "JSON"
                            crewData.fltNo = flcrewschedule.fltno
                            crewData.date = StringUtils.getYMDStringFromDMYString(flcrewschedule.date)
                            crewData.from = flcrewschedule.dep
                            crewData.sno = flcrewschedule.sno
                            crewData.pos = flcrewschedule.pos
                            crewData.staffno = flcrewschedule.staffno
                            crewData.status = flcrewschedule.status
                            crewData.stn = flcrewschedule.stn
                            crewData.gmt = flcrewschedule.gmt


                            crewDataList.append(crewData)

                        }

                    }


                    do {
                        try context.save()

                        self.fetchFlightInfoFromLocalDB()
                        self.Tableview.reloadData()
                        Indicator.stop()

                    } catch let error as NSError {
                        print("Error occurred: \(error)")

                    } catch {
                        fatalError()
                    }


                } else {

                    Indicator.stop()

                }

            } else {
                alert("Message", Body: error!)
                Indicator.stop()

            }

        }


    }


    func removeFlightInfoFromDB() {


        let legRequest = NSFetchRequest<LegData>(entityName: "LegData")
        let legList = try! context.fetch(legRequest)


        for bas: AnyObject in legList
        {

            let ld = bas as! LegData

            // @TODO: CHANGE AT OTHER PLACES
            // CHECK FOR IPAD IS WRONG. SHOULD ONLY CHECK FOR UPLOADSTATUS AND IT IS SUFFICIENT
            if (ld.source != "IPAD" || ld.uploadStatus == nil) {
                context.delete(bas as! NSManagedObject)
            }

        }

        do {
            try context.save()
        } catch _ {
        }

    }

    func saveAndSignFlightLogLegDataString(_ fltDate: String, fltNo: String, depStation: String) -> String {

        let str: String = ""

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

            var entity: LegData

            for i in 0..<legdataList.count {

                entity = legdataList[i]

                entity.uploadStatus = "Saved"

                do {
                    try context.save()
                } catch _ {
                }
            }
        }
        catch let error as NSError {
            NSLog("Error %@", error)
        } catch {
            NSLog("Error occured", "")
        }

        return str

    }


    func markUploadedFlightLogLegDataString(_ fltDate: String, fltNo: String, depStation: String) -> String {

        let str: String = ""

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

            var entity: LegData

            for i in 0..<legdataList.count {

                entity = legdataList[i]

                entity.uploadStatus = "Uploaded"

                do {
                    try context.save()
                } catch _ {
                }
            }
        }
        catch let error as NSError {
            NSLog("Error %@", error)
        } catch {
            NSLog("Error occured", "")
        }

        return str

    }


    func validateFlightLogLegDataString(_ fltDate: String, fltNo: String, depStation: String) -> String {

        let str: String = ""

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

            var entity: LegData

            for i in 0..<legdataList.count {

                entity = legdataList[i]

                //                if StringUtils.isEmptyValue(str: entity.aircraft) { return "Please provide aircraft."}

                if StringUtils.isEmptyValue(str: entity.std) { return "Please provide [STD]." }
                if StringUtils.isEmptyValue(str: entity.sta) { return "Please provide [STA]." }
                if StringUtils.isEmptyValue(str: entity.aircraft) { return "Please provide [Aircraft Type]" }
                if StringUtils.isEmptyValue(str: entity.reg) { return "Please provide [Regisration]" }
                if StringUtils.isEmptyValue(str: entity.captainId) { return "Please provide [Captain Id]." }
                if StringUtils.isEmptyValue(str: entity.date) { return "Please provide date." }
                if StringUtils.isEmptyValue(str: entity.fltNo) { return "Please provide fltNo." }
                if StringUtils.isEmptyValue(str: entity.from) { return "Please provide from." }
                if StringUtils.isEmptyValue(str: entity.to) { return "Please provide to." }
                if StringUtils.isEmptyValue(str: entity.primaryDate) { return "Please provide primaryDate." }
                if StringUtils.isEmptyValue(str: entity.primaryFltNo) { return "Please provide primaryFltNo." }
                if StringUtils.isEmptyValue(str: entity.primaryFrom) { return "Please provide primaryFrom." }
                if entity.primaryFrom == "NRT" && entity.fuelUplUnit! == 0 { return "Please select USG as Fuel unit\r\nFuel uplift value must be in USG (for NRT)"
                }
                if entity.primaryFrom != "NRT" && entity.fuelUplUnit! != 0 { return "Please check fuel unit"
                }

                var flightCancelled = false

                if (
                    entity.blocksOff == "0000" &&
                        entity.takeOff == "0000" &&
                        entity.landing == "0000" &&
                        entity.blocksOn == "0000") {
                    flightCancelled = true
                }
                if (entity.aircraft! == "TBA") {
                    flightCancelled = true
                }


                if (!flightCancelled) {


                    if StringUtils.isEmptyValue(str: entity.blocksOff) { return "Please provide [Blocks Off]" }

                    if StringUtils.isEmptyValue(str: entity.blocksOn) { return "Please provide [Blocks On]" }
                    if StringUtils.isEmptyValue(str: entity.blockTime) { return "Please provide [Block Time]" }

                    if StringUtils.isEmptyValue(str: entity.instTime) { return "Please provide instTime." }
                    if StringUtils.isEmptyValue(str: entity.landFlag) { return "Please provide landFlag." }
                    if StringUtils.isEmptyValue(str: entity.landing) { return "Please provide landing." }
                    if StringUtils.isEmptyNSNumberValue(str: entity.legNo) { return "Please provide legNo." }
                    if StringUtils.isEmptyValue(str: entity.nightTime) { return "Please provide nightTime." }


                    if StringUtils.isEmptyValue(str: entity.source) { return "Please provide source." }
                    if StringUtils.isEmptyValue(str: entity.takeOff) { return "Please provide takeOff." }

                    if StringUtils.isEmptyValue(str: entity.toFlag) { return "Please provide toFlag." }


                    //                if StringUtils.isEmptyValue(str: entity.cat23) { return "Please provide cat23."}
                    if StringUtils.isEmptyValue(str: entity.date) { return "Please provide date." }

                    if StringUtils.isEmptyValue(str: entity.beforeRefuelingKGS) { return "Please provide [Before Refueling KGS]." }


                    if StringUtils.isEmptyValue(str: entity.density) { return "Please provide [Density]." }
                    if StringUtils.isEmptyValue(str: entity.fuelUpLiftQty) { return "Please provide [Volume to be Uplifted]." }

                    if StringUtils.isEmptyValue(str: entity.totalUplift) { return "Please provide [Total Uplift]." }

                    let density = Int(entity.density!)!
                    let volumnToBeUplifted = Int(entity.fuelUpLiftQty!)!
                    let totalUplift = Int(entity.totalUplift!)!

                    if (density > 0 || volumnToBeUplifted > 0 || totalUplift > 0) {
                        if (density == 0 || volumnToBeUplifted == 0 || totalUplift == 0) {
                            return "Values of [Density], [Volume to be Uplifted] and [Total Uplift] are inconsistent."
                        }
                    }

                    if StringUtils.isEmptyValue(str: entity.fltNo) { return "Please provide fltNo." }
                    if StringUtils.isEmptyValue(str: entity.from) { return "Please provide from." }


                    if StringUtils.isEmptyValue(str: entity.primaryFltNo) { return "Please provide primaryFltNo." }
                    if StringUtils.isEmptyValue(str: entity.primaryFrom) { return "Please provide primaryFrom." }



                    if StringUtils.isEmptyValue(str: entity.depKG) || Int(entity.depKG!) == 0 { return "Please provide [Total Dep Fuel KGS]." }

                    if StringUtils.isEmptyValue(str: entity.arrKG) || Int(entity.arrKG!) == 0 { return "Please provide [Arr Fuel KGS]." }


                    if (!StringUtils.isEmptyValue(str: entity.depKG) && !StringUtils.isEmptyValue(str: entity.arrKG) && Int(entity.depKG!)! < Int(entity.arrKG!)!) {
                        return "Please check [Total Dep Fuel KGS] & [Arr Fuel KGS]."
                    }

                    if StringUtils.isEmptyValue(str: entity.zeroFuelWt) || Int(entity.zeroFuelWt!) == 0 { return "Please provide [Zero Fuel Wt]." }





                }


            }
        }
        catch let error as NSError {
            NSLog("Error %@", error)
        } catch {
            NSLog("Error occured", "")
        }

        return str

    }

    func markUploadedFlightLogCrewDataString(_ fltDate: String, fltNo: String, depStation: String) -> String {



        let str: String = ""

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


        do {
            let legdataList = try context.fetch(fetchreq)

            var entity: CrewData

            for i in 0..<legdataList.count {

                entity = legdataList[i]

                entity.uploadStatus = "Uploaded"

                do {
                    try context.save()
                } catch _ {
                }



            }
        }




        catch let error as NSError {
            NSLog("Error %@", error)
        } catch {
            NSLog("Error occured", "")
        }

        return str

    }

    func validateFlightLogCrewDataString(_ fltDate: String, fltNo: String, depStation: String) -> String {



        let str: String = ""

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


        do {
            let legdataList = try context.fetch(fetchreq)

            var entity: CrewData

            for i in 0..<legdataList.count {

                entity = legdataList[i]

                if StringUtils.isEmptyValue(str: entity.date) { return "Crew ID \(entity.staffno!) :Please provide date." }
                if StringUtils.isEmptyValue(str: entity.fltNo) { return "Crew ID \(entity.staffno!) :Please provide fltNo." }
                if StringUtils.isEmptyValue(str: entity.from) { return "Crew ID \(entity.staffno!) :Please provide from." }
                if StringUtils.isEmptyValue(str: entity.gmt) { return "Crew ID \(entity.staffno!) :Please provide gmt." }
                if StringUtils.isEmptyValue(str: entity.pos) { return "Crew ID \(entity.staffno!) :Please provide pos." }
                if StringUtils.isEmptyValue(str: entity.primaryDate) { return "Crew ID \(entity.staffno!) :Please provide primaryDate." }
                if StringUtils.isEmptyValue(str: entity.primaryFltNo) { return "Crew ID \(entity.staffno!) :Please provide primaryFltNo." }
                if StringUtils.isEmptyValue(str: entity.primaryFrom) { return "Crew ID \(entity.staffno!) :Please provide primaryFrom." }
                if StringUtils.isEmptyValue(str: entity.sno) { return "Crew ID \(entity.staffno!) :Please provide sno." }
                if StringUtils.isEmptyValue(str: entity.source) { return "Crew ID \(entity.staffno!) :Please provide source." }
                if StringUtils.isEmptyValue(str: entity.staffno) { return "Crew ID \(entity.staffno!) :Please provide staffno." }
                if StringUtils.isEmptyValue(str: entity.status) { return "Crew ID \(entity.staffno!) :Please provide status." }
                if StringUtils.isEmptyValue(str: entity.stn) { return "Crew ID \(entity.staffno!) :Please provide stn." }


            }
        }
        catch let error as NSError {
            NSLog("Error %@", error)
        } catch {
            NSLog("Error occured", "")
        }

        return str

    }






    func validateOperatingCrewPassword(_ fltDate: String, fltNo: String, depStation: String) -> String {


        if (true) {
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

                var entity: LegData

                for i in 0..<legdataList.count {

                    entity = legdataList[i]

                    if (entity.flag3 == 1) {
                        _ = self.saveAndSignAction(fltDate, fltNo: fltNo, depStation: depStation)

                        self.Tableview.reloadData()
                        return ""
                    }

                }
            }
            catch let error as NSError {
                NSLog("Error %@", error)
            } catch {
                NSLog("Error occured", "")
            }
        }

        var validPasswordCount = 0


        let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")

        let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString(fltDate))
        let fltNoPredicate = NSPredicate(format: "fltNo = %@", fltNo)
        let fromPredicate = NSPredicate(format: "from = %@", depStation)

        //        let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")

        let operatingCrewpredicate = NSPredicate(format: "(status = %@ OR status = %@) AND (pos = '0' OR pos = '1')", argumentArray: ["P", "A"])


        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, operatingCrewpredicate])

        fetchreq.predicate = compound


        let dateSortDescriptor = NSSortDescriptor(key: "sno", ascending: true)
        let sortDescriptors = [dateSortDescriptor]
        fetchreq.sortDescriptors = sortDescriptors

        let MESSAGE_STRING = "Password of P-"

        do {
            let legdataList = try context.fetch(fetchreq)

            var entity: CrewData


            //1. Create the alert controller.
            let alert = UIAlertController(title: "Flight Log Validation", message: "Please provide password/DOB of operating crew ", preferredStyle: .alert)

            if legdataList.count < 2 {

                MiscUtils.alert("Crew Count Error", message: "Minimum two operating crew should be assigned.", controller: self)

                //return "Operating Crew not assigned"

            }
            for i in (0..<legdataList.count).reversed() {

                entity = legdataList[i]

                //2. Add the text field. You can configure it however you need.
                alert.addTextField { (textField) in
                    textField.text = ""
                    textField.placeholder = MESSAGE_STRING + "\(entity.staffno!)"
                    textField.isSecureTextEntry = true

                }
            }

            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "OK, Digitally Sign", style: .default, handler: { (_) in

                for password: UITextField in alert.textFields! {

                    //                    MiscUtils.alert("Validating password", message: (password.placeholder?.replacingOccurrences(of: "Password of Crew Id ", with: ""))! + " " + password.text! , controller: self)

                    if (MiscUtils.validateCrewPassword(id: (password.placeholder?.replacingOccurrences(of: MESSAGE_STRING, with: ""))!, password: password.text!)) {
                        validPasswordCount += 1
                    }

                }


                if (validPasswordCount > 1) {

                    _ = self.saveAndSignAction(fltDate, fltNo: fltNo, depStation: depStation)

                    self.Tableview.reloadData()
                } else {
                    MiscUtils.alert("Crew Password", message: "Please provide correct passwords", controller: self)
                }


            }))

            alert.message = "Please provide password or DOB(yyyymmdd) of \(legdataList.count) operating crew ";




            DispatchQueue.main.async {
                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
            }

        }
        catch let error as NSError {
            NSLog("Error %@", error)
        } catch {
            NSLog("Error occured", "")
        }

        return ""

    }



    private func saveAndSignAction (_ fltDate: String, fltNo: String, depStation: String) -> String {
        //        Indicator.start(self)



        var errorMessage = ""

        errorMessage = self.saveAndSignFlightLogLegDataString(fltDate, fltNo: fltNo, depStation: depStation)



        if (errorMessage != "") {
            let alert = UIAlertController(title: "Saving flight log", message: "Log saved and signed", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }


        return errorMessage


    }


    private func validateAction (_ fltDate: String, fltNo: String, depStation: String) -> String {
        //        Indicator.start(self)





        var errorMessage = ""

        errorMessage = self.validateFlightLogLegDataString(fltDate, fltNo: fltNo, depStation: depStation)
        if (errorMessage == "") {
            errorMessage = self.validateFlightLogCrewDataString(fltDate, fltNo: fltNo, depStation: depStation)
        }

        if (errorMessage == "") {
            errorMessage = self.validateOperatingCrewPassword(fltDate, fltNo: fltNo, depStation: depStation)
        }


        if (errorMessage != "") {
            let alert = UIAlertController(title: "Validation response", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }


        return errorMessage


    }

    private func uploadAction (_ fltDate: String, fltNo: String, depStation: String) {
        Indicator.start(self)




        let flLegDataString = MiscUtils.getFlightLogLegDataString(fltDate, fltNo: fltNo, depStation: depStation)
        let flCrewDataString = MiscUtils.getFlightLogCrewDataString(fltDate, fltNo: fltNo, depStation: depStation)


        //        print(flLegDataString + "\n\n")
        //        print(flCrewDataString)

        var request = URLRequest(url: URL(string: NetworkUtils.getActiveServerURL() + "/PostFlightLog_SECURE")!)
        request.httpMethod = "POST"

        print(NetworkUtils.getActiveServerURL())

        let date = NSDate()
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date as Date)
        let minutes = calendar.component(.minute, from: date as Date)

        let postData = ["token": "\(hour)\(minutes)",
            "userId": "\(userEntity.username!)",
            "username": "\(AppConstants.WEB_SERVICE_USERNAME)",
            "password": "\(AppConstants.WEB_SERVICE_PASSWORD)",
            "flCraft": "\(flLegDataString)",
            "flCrew": "\(flCrewDataString)",
            "appversion": "\(CheckVersionServices.getVerion())"]


        FlightListTableViewController.Manager.request(NetworkUtils.getActiveServerURL() + "/PostFlightLog_SECURE", method: .post, parameters: postData, encoding: URLEncoding.default, headers: [:])
            .responseString { (response) in



            // Indicator.stop()

            var responseText = ""

            if let dataStr = response.data {
                responseText = NSString(data: dataStr, encoding: String.Encoding.utf8.rawValue)! as String
            } else {
                responseText = ""
            }


            if (responseText != "success") {

                let alert = UIAlertController(title: "Server response", message: "Error in connection." + "[" + responseText + "]", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            } else {

                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

                let delivery_receipt_exists = FileManager.default.fileExists(atPath: documentsURL.appendingPathComponent(fltDate + "_" + fltNo + "_" + depStation + "_DeliveryReceipt.jpg").path)

                let fuel_indent_exists = FileManager.default.fileExists(atPath: documentsURL.appendingPathComponent(fltDate + "_" + fltNo + "_" + depStation + "_FuelIndent.jpg").path)



                if (delivery_receipt_exists && fuel_indent_exists) {


                    let data_delivery_receipt = try? Data(contentsOf: documentsURL.appendingPathComponent(fltDate + "_" + fltNo + "_" + depStation + "_DeliveryReceipt.jpg"))

                    let filedata_delivery_receipt = data_delivery_receipt!


                    let postData_delivery_receipt = ["flightNo": "\(fltNo)",
                                                     "flightDate": "\(StringUtils.getStringFromDate(StringUtils.getDateFromString(fltDate) , dateFormat: "yyyy-MM-dd"))",
                        "departure": "\(depStation)",
                        "file": "\(filedata_delivery_receipt.base64EncodedString())",
                        "token": "\(StringUtils.MD5_New(string: StringUtils.getStringFromDate(NSDate() as Date, dateFormat: "yyyyMMdd")).map { String(format: "%02hhx", $0) }.joined().uppercased())"]


                    FlightListTableViewController.Manager.request("https://crewserver1.piac.com.pk/FileUploadAPI/WebService.asmx/Upload", method: .post, parameters: postData_delivery_receipt, encoding: URLEncoding.default, headers: [:])
                        .responseString { (response_delivery_receipt) in



//                                Indicator.stop()

                        var responseText_delivery_receipt = ""

                        if let dataStr_delivery_receipt = response_delivery_receipt.data {
                            responseText_delivery_receipt = NSString(data: dataStr_delivery_receipt, encoding: String.Encoding.utf8.rawValue)! as String
                        } else {
                            responseText_delivery_receipt = ""
                        }


                        if (responseText_delivery_receipt.contains("Success")) {

                            let data_fuel_indent = try? Data(contentsOf: documentsURL.appendingPathComponent(fltDate + "_" + fltNo + "_" + depStation + "_FuelIndent.jpg"))

                            let filedata_fuel_indent = data_fuel_indent!


                            let postData_fuel_indent = ["flightNo": "\(fltNo)",
                                "flightDate": "\(StringUtils.getStringFromDate(StringUtils.getDateFromString(fltDate), dateFormat: "yyyy-MM-dd"))",
                                "departure": "\(depStation)",
                                "file": "\(filedata_fuel_indent.base64EncodedString())",
                                "token": "\(StringUtils.MD5_New(string: StringUtils.getStringFromDate(NSDate() as Date, dateFormat: "yyyyMMdd")).map { String(format: "%02hhx", $0) }.joined().uppercased())"]


                            FlightListTableViewController.Manager.request("https://crewserver1.piac.com.pk/FileUploadAPI/WebService.asmx/Upload", method: .post, parameters: postData_fuel_indent, encoding: URLEncoding.default, headers: [:])
                                .responseString { (response_fuel_indent) in



                                Indicator.stop()

                                var responseText_fuel_indent = ""

                                if let dataStr_fuel_indent = response_fuel_indent.data {
                                    responseText_fuel_indent = NSString(data: dataStr_fuel_indent, encoding: String.Encoding.utf8.rawValue)! as String
                                } else {
                                    responseText_fuel_indent = ""
                                }


                                if (responseText_fuel_indent.contains("Success")) {


                                    let alert = UIAlertController(title: "Server response", message: "Flight Log uploaded successfully (with fuel images).", preferredStyle: UIAlertController.Style.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))


                                    DispatchQueue.main.async {
                                        self.present(alert, animated: true, completion: nil)

                                        _ = self.markUploadedFlightLogLegDataString(fltDate, fltNo: fltNo, depStation: depStation)

                                        _ = self.markUploadedFlightLogCrewDataString(fltDate, fltNo: fltNo, depStation: depStation)

                                        self.Tableview.reloadData()
                                    }
                                }
                            }
                        }

                    }

                } else {
                    // without fuel images

                    Indicator.stop()

                    let alert = UIAlertController(title: "Server response", message: "Flight Log uploaded successfully (without fuel images).", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))


                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)

                        _ = self.markUploadedFlightLogLegDataString(fltDate, fltNo: fltNo, depStation: depStation)

                        _ = self.markUploadedFlightLogCrewDataString(fltDate, fltNo: fltNo, depStation: depStation)

                        self.Tableview.reloadData()
                    }
                }





            }
        }



    }

    private func invokeRefresh () {

        if (true) {
            let legRequest = NSFetchRequest<LegData>(entityName: "LegData")

            //            let statusPredicate = NSPredicate(format: "uploadStatus = nil OR uploadStatus != %@", "Uploaded")

            let statusPredicate = NSPredicate(format: "uploadStatus = nil")

            let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [statusPredicate])

            legRequest.predicate = compound

            let legList = try! context.fetch(legRequest)



            for bas: AnyObject in legList
            {

                // let ld = bas as! LegData
                context.delete(bas as! NSManagedObject)

            }

            do {
                try context.save()
            } catch _ {
            }
        }

        if (true) {
            let legRequest = NSFetchRequest<CrewData>(entityName: "CrewData")

            //            let statusPredicate = NSPredicate(format: "uploadStatus = nil OR uploadStatus != %@", "Uploaded")
            let statusPredicate = NSPredicate(format: "uploadStatus = nil")

            let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [statusPredicate])

            legRequest.predicate = compound

            let legList = try! context.fetch(legRequest)


            for bas: AnyObject in legList
            {

                let ld = bas as! CrewData

                // check if flight already present (because it is not deleted even after refresh)
                if (!StringUtils.isInProgressFlightPresent(StringUtils.getDMYStringFromYMDString(ld.date!), flightNo: ld.fltNo!, depStation: ld.from!)) {
                    context.delete(bas as! NSManagedObject)
                }


            }


            do {
                try context.save()
            } catch _ {
            }



        }


        Indicator.start(self)
        self.fetchFlightInfoFromJSON();

    }
    @IBAction func refreshFlightData(_ sender: AnyObject) {



        if (!MiscUtils.checkAndWarnAboutNetworkConnection(controller: self)) {
            return
        }

        UserDefaults.standard.removeObject(forKey: AppConstants.CACHE_KEY_CREWS_FOR_CREW)
        UserDefaults.standard.removeObject(forKey: AppConstants.CACHE_KEY_FLIGHT_FOR_CREW)
        UserDefaults.standard.removeObject(forKey: AppConstants.CACHE_KEY_CREWS_FOR_CREW_TIME_INFO)
        UserDefaults.standard.removeObject(forKey: AppConstants.CACHE_KEY_FLIGHT_FOR_CREW_TIME_INFO)


        // create the alert
        let alert = UIAlertController(title: "Notice", message: "Are you sure you want to refresh flight data?\nFlights already uploaded will not be refreshed.", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { action in



        }))

        alert.addAction(UIAlertAction(title: "Refresh", style: UIAlertAction.Style.destructive, handler: { action in


            self.invokeRefresh()


        }))

        // show the alert
        self.present(alert, animated: true, completion: nil)




    }


    @IBAction func actionOnLog(_ sender: AnyObject) {

        let button: UIButton = sender as! UIButton

        var superview: UIView = sender.superview!!

        while (type(of: superview) != FlightListTableViewCell.self) {
            superview = superview.superview!
        }

        if (type(of: superview) == FlightListTableViewCell.self) {
            let cell = superview as! FlightListTableViewCell
            let indexPath = self.Tableview.indexPath(for: cell)


            let flight: LegData = postedFlights[(indexPath! as NSIndexPath).row]

            let depStation = flight.from!
            let fltDate = StringUtils.getDMYStringFromYMDString(flight.date!)
            let fltNo = flight.fltNo!

            if (button.currentTitle! == "Save") {
                if (self.validateAction(fltDate, fltNo: fltNo, depStation: depStation) == "") {



                }
            } else if (button.currentTitle! == "Upload") {
                self.uploadAction(fltDate, fltNo: fltNo, depStation: depStation)
            } else if (button.currentTitle! == "Re-Upload") {
                MiscUtils.alert("Re-Upload Flight", message: "Flight Log has previously been uploaded. But re-uploaded as requested.", controller: self)
                self.uploadAction(fltDate, fltNo: fltNo, depStation: depStation)
            }
        }

    }

}
