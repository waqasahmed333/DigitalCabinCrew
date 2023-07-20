//
//  HomeViewController.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 30/04/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData

import UIKit
import CoreData
import Reachability
import Alamofire
import SwiftyJSON


class HomeViewController: UIViewController, UITableViewDelegate, URLSessionDelegate {
    
    
    var EXPIRIES_LOADED = 0;
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.serverTrust == nil {
            completionHandler(.useCredential, nil)
        } else {
            let trust: SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }
    
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
    
    var postedFlights = [LegData]()
    
    var users = [User]()
    
    //    @IBOutlet var Tableview: UITableView!
    
    @IBOutlet weak var expiryinfo: UITextView!
    
    //    @IBOutlet weak var sep: UILabel!
    //
    //    @IBOutlet weak var dgr: UILabel!
    //
    //    @IBOutlet weak var med: UILabel!
    //
    //    @IBOutlet weak var crm: UILabel!
    //
    //    @IBOutlet weak var ref: UILabel!
    //
    //    @IBOutlet weak var licen: UILabel!
    //
    //    @IBOutlet weak var ielts: UILabel!
    //
    //    @IBOutlet weak var sepDays: UILabel!
    //
    //    @IBOutlet weak var dgrDays: UILabel!
    //
    //    @IBOutlet weak var medDays: UILabel!
    //
    //    @IBOutlet weak var crmDays: UILabel!
    //
    //    @IBOutlet weak var refDays: UILabel!
    //
    //    @IBOutlet weak var licenDays: UILabel!
    //
    //    @IBOutlet weak var ieltsDays: UILabel!
    
    
    @IBOutlet weak var home_screen_message: UILabel!
    
    @IBOutlet weak var crewName: UILabel!
    
    //    @IBOutlet weak var crewQualification: UILabel!
    
    
    var airlineName:String?
    
    
    @IBOutlet weak var btnLogBookPortal: UIButton!
    
    @IBAction func openLogBookPortalWebsite(_ sender: Any) {
        
        //       let url = "http://flightlog.piac.com.pk?id=" + userEntity.username! + "&password=" + StringUtils.md5(string: userEntity.username! + userEntity.password!)
        let url = "https://flightlog.piac.com.pk"
        
        UIApplication.shared.openURL(NSURL(string : url)! as URL)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let air = self.airlineName {
            self.tabBarController?.navigationItem.title = "\(air)"
        }
        
        //        let backgroundImageView = UIImageView(image: UIImage(named: "777_aircraft"))
        //        backgroundImageView.frame = view.frame
        //        backgroundImageView.alpha = 0.05
        //        backgroundImageView.contentMode = .scaleAspectFill
        //        view.addSubview(backgroundImageView)
        //        view.sendSubviewToBack(backgroundImageView)
        
        
        self.fetchFlightInfoFromJSON();
        
        
        
    }
    
    
    
    
    func flightSorter (_ flight1:LegData, flight2:LegData) -> Bool {
        return  flight1.date! + flight1.std! <  flight2.date! + flight2.std!
    }
    
    func fetchFlightInfoFromLocalDB() {
        
        //        print(#function)
        
        let legRequest = NSFetchRequest<LegData>(entityName: "LegData")
        let legData = try! context.fetch(legRequest) 
        
        //postedFlights = legData
        
        for tobeAddedFlight in legData {
            
            let date_obj = StringUtils.getDateFromString(StringUtils.getDMYStringFromYMDString(tobeAddedFlight.date!))
            
            let yesterday = Calendar.current.date(byAdding: .hour, value: -48, to: Date())
            
            if ( date_obj! > yesterday!) {
                
                postedFlights.append(tobeAddedFlight)
                
            }
            
        }
        
        postedFlights.sort(by: flightSorter)
        //self.Tableview.reloadData()
        
        
    }
    
    func removeFlightInfoFromDB() {
        
        
        let legRequest = NSFetchRequest<LegData>(entityName: "LegData")
        let legList = try! context.fetch(legRequest)
        
        
        for bas: AnyObject in legList
        {
            
            let ld = bas as! LegData
            
            if ( ld.source != "IPAD" || ld.uploadStatus == nil ) {
                context.delete(bas as! NSManagedObject)
            }
            
        }
        
        do {
            try context.save()
        } catch _ {
        }
        
    }
    
    func fetchFlightInfoFromJSON() {
        
        
        
        FlightLogService.getFlFlightInfoList(userEntity.username!) { (flFlightInfoArray, error) in
            
            if error == nil {
                
                if !flFlightInfoArray!.isEmpty {
                    
                    self.removeFlightInfoFromDB()
                    self.postedFlights.removeAll()
                    
                    for flflightinfo in  flFlightInfoArray!{
                        
                        
                        
                        if  !StringUtils.isIPADFlightPresentSavedOrUploaded(flflightinfo.date, flightNo: flflightinfo.flight, depStation: flflightinfo.dep)  {
                            
                            
                            
                            let legEntityDescripition = NSEntityDescription.entity(forEntityName: "LegData", in: context)
                            
                            let legData = LegData(entity: legEntityDescripition!, insertInto: context)
                            
                            let date_obj = StringUtils.getDateFromString(flflightinfo.date!)
                            
                            let yesterday = Calendar.current.date(byAdding: .hour, value: -48, to: Date())
                            
                            if ( date_obj! > yesterday!) {
                                
                                self.postedFlights.append(legData)
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
                            
                            let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString( flflightinfo.date))
                            let fltNoPredicate = NSPredicate(format: "fltNo = %@", flflightinfo.flight)
                            let fromPredicate = NSPredicate(format: "from = %@", flflightinfo.dep)
                            //                                    let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
                            
                            let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
                            
                            fetchreq.predicate = compound
                            
                            
                            let data = try! context.fetch(fetchreq) 
                            
                            if  data.count > 0
                            {
                                
                                
                                let legData = data[0]
                                
                                let date_obj = StringUtils.getDateFromString(StringUtils.getDMYStringFromYMDString(legData.date!))
                                
                                let yesterday = Calendar.current.date(byAdding: .hour, value: -48, to: Date())
                                
                                if ( date_obj! > yesterday!) {
                                    
                                    
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
                        
                        
                        self.fetchFlightInfoFromLocalDB()
                        
                        //                        for pflight in postedFlights {
                        //
                        //                            self.lblCurrentFlights.text! = ""
                        //                        self.lblCurrentFlights.text! +=  "PK-" + pflight.fltNo! + " " + pflight.date! + " " + pflight.from! + " " + pflight.to! + "\r\n"
                        //                        }
                        //                        Indicator.stop()
                        self.fetchCrewScheduleFromJSON()
                        
                        
                    } catch let error as NSError {
                        print("Error occurred: \(error)")
                        
                    } catch {
                        fatalError()
                    }
                    
                    //                    self.Tableview.reloadData()
                    
                } else{
                    
                    //                    alert("Message", Body: "Flight Data not available")
                    Indicator.stop()
                    
                }
                
            } else{
                alert("Message", Body: error!)
                Indicator.stop()
                
            }
            
        }
    }
    
    
    func loadExpiriesFromServer() {
        DISPLAY_UPLOADED_LOGS = 0
        
        let token:String = "new_token"
        
        let postData = ["crewId":"\(userEntity.username!)",
                        "token":"\(token)",
                        "appversion": "\(CheckVersionServices.getVerion())"]
        
        
        var useLocalCache = false
        let currentTime = CFAbsoluteTimeGetCurrent() as? Double
        
        if let lastUpdateTime =  UserDefaults.standard.value(forKey: AppConstants.CACHE_KEY_EXPIRY_TIME_INFO) as? Double{
            
            print("Time between refresh  \(currentTime! - lastUpdateTime)")
            
            if (currentTime! - lastUpdateTime) < 300 {
                useLocalCache = true
            }
            
        }
        
        if useLocalCache {
            self.EXPIRIES_LOADED = 1
        }
            
            
            
        
        if (EXPIRIES_LOADED == 0) {
        
        HomeViewController.Manager.request(   NetworkUtils.getActiveServerURL() + "/GetBasicCrewInformation_V2", method: .get, parameters:  postData,encoding: URLEncoding.default , headers: [:] )
            .responseJSON { (response) in
                
                self.EXPIRIES_LOADED = 1
                
                var object:JSON = JSON.null
                
                if ( response.result.error == nil ) {
                    object = JSON(response.result.value!)
                    
                    UserDefaults.standard.set(object.rawString(), forKey: AppConstants.CACHE_KEY_EXPIRY)
                    
                    UserDefaults.standard.set(currentTime!, forKey: AppConstants.CACHE_KEY_EXPIRY_TIME_INFO)
                    
                    Indicator.stop()
                    
                    
                    let parse =  object.dictionaryObject // as? NSDictionary
                    
                    if parse != nil {
                        
                        if true {
                            
                            
                            //2
                            if let authenticationData = parse as? NSDictionary {
                                
                                if authenticationData["Name"] != nil {
                                    
                                    
                                    userEntity.rosterName = authenticationData["Name"] as? String
                                    
                                    userEntity.crm = authenticationData["CRM"] as? String;
                                    userEntity.med = authenticationData["MED"] as? String;
                                    userEntity.dgr = authenticationData["DGR"] as? String;
                                    userEntity.sep = authenticationData["SEP"] as? String;
                                    userEntity.ref = authenticationData["REF"] as? String;
                                    userEntity.licen = authenticationData["LICEN"] as? String;
                                    userEntity.expiryInformation = authenticationData["ExpiryInformation"] as? String;
                                    
                                    userEntity.home_screen_message = authenticationData["HomeScreenMessage"] as? String;
                                    
                                    
                                    
                                    let versionUpdateMessage = authenticationData["VersionUpdateMessage"] as? String;
                                    
                                    if ( !(versionUpdateMessage?.isEmpty ?? true)) {
                                        
                                        let alert = UIAlertController(title: "Notice", message: versionUpdateMessage, preferredStyle: UIAlertController.Style.alert)
                                        
                                        // add the actions (buttons)
                                        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { action in
                                            
                                            return
                                            
                                        }))
                                        
                                        alert.addAction(UIAlertAction(title: "Update App", style: UIAlertAction.Style.default, handler: { action in
                                            
                                            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1127530435") {
                                                UIApplication.shared.open(url)
                                            }
                                            
                                        }))
                                        
                                        // show the alert
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }
                                    
                                    
                                    
                                }
                            }
                            
                            
                            

                            
                        }
                    }
                }
            }
        }
        
        do {
            let fetchreq = NSFetchRequest<User>(entityName: "User")
            let data = try context.fetch(fetchreq)
            
            self.users = data
            
            var filteredArray = self.users.filter( { (user: User) -> Bool in
                return user.username == userEntity.username
            })
            
            if ( filteredArray.count == 1 ) {
                
                let user_ = filteredArray[0];
                
                userEntity.token = user_.token
                userEntity.ac = user_.ac
                userEntity.crewBase = user_.crewBase
                userEntity.pos = user_.pos
                userEntity.username = user_.username
                
            }
        } catch _ {
            print("Error")
            
        }
        
//        DispatchQueue.main.async(execute: {
        
            
            if  let localExpiryData = UserDefaults.standard.object(forKey: AppConstants.CACHE_KEY_EXPIRY) as? String  {
                
                
//                var object:JSON = JSON( localExpiryData )
                
//                object = JSON(localExpiryData)
                
                
                let parse =  convertStringToDictionary ( text: localExpiryData) // as? NSDictionary
                
                
                
                
                if parse != nil {
                    
                    if true {
                        
                        
//                        let authenticationData = parse
                        //2
                        if let authenticationData = parse as? NSDictionary {
                            
                            if authenticationData["Name"] != nil {
                                
                                
                                userEntity.rosterName = authenticationData["Name"] as? String
                                
                                userEntity.crm = authenticationData["CRM"] as? String;
                                userEntity.med = authenticationData["MED"] as? String;
                                userEntity.dgr = authenticationData["DGR"] as? String;
                                userEntity.sep = authenticationData["SEP"] as? String;
                                userEntity.ref = authenticationData["REF"] as? String;
                                userEntity.licen = authenticationData["LICEN"] as? String;
                                userEntity.expiryInformation = authenticationData["ExpiryInformation"] as? String;
                                
                                userEntity.home_screen_message = authenticationData["HomeScreenMessage"] as? String;
                                
                                
                                
                            }
                        }
                        
                        
                        

                        
                    }
                }
                

                
                
                
                
                self.expiryinfo.text = userEntity.expiryInformation!
                
                if ( userEntity.expiryInformation!.contains("Expired")) {

                    
                    let lines = userEntity.expiryInformation!.components(separatedBy: "\r\n");
                    
                    var expiredDocs = " ";
                    
                    for line in lines {
                        if ( line.contains("Expired")) {
                            let tokens = line.components(separatedBy: " ");
                            expiredDocs += tokens[3] +  "/";
                        }
                    }
                    
                    expiredDocs.remove(at: expiredDocs.index(before: expiredDocs.endIndex))
                    
                    MiscUtils.alert("Competencies Expired", message: "Your following competencies are expired:" + expiredDocs  + ". \r\nPlease immediately contact PIA Training", controller: self)
                    
                } else if ( userEntity.expiryInformation!.contains("Expiring")) {
                    MiscUtils.alert("Competencies Expiring Soon", message: "Some of your competencies will expire soon. Please immediately contact PIA Training", controller: self)
                }
                
                
            }
            

            
            self.home_screen_message.text = userEntity.home_screen_message == nil ? "" : userEntity.home_screen_message
            
        self.crewName.text = "\(userEntity.pos!) \(userEntity.rosterName ?? "" ) P-\(userEntity.username ?? "") \r\n(\( MiscUtils.getACTypeFromIATACode(acType: userEntity.ac ?? "")) \(userEntity.crewBase!))"
            self.crewName.numberOfLines = 2
            
//        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        

            self.loadExpiriesFromServer()
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    @IBAction func openflights(_ sender: AnyObject) {
    //        let storyboar = UIStoryboard(name: "Main", bundle: nil)
    //        let controller  = storyboar.instantiateViewController(withIdentifier: "popup") as! FlightsVC
    //
    //        customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
    //
    //
    //    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postedFlights.count
    }
    
    
    
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //
    ////        let cell = self.Tableview.dequeueReusableCell(withIdentifier: "flightCell") as! FlightListTableViewCell
    //
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateStyle = DateFormatter.Style.medium
    //
    //        cell.lblFlightNumber.text = postedFlights[(indexPath as NSIndexPath).row].fltNo! + " " +  StringUtils.getDMYStringFromYMDString(postedFlights[(indexPath as NSIndexPath).row].date!)
    //        cell.lblSector.text = postedFlights[(indexPath as NSIndexPath).row].from! + "-" + postedFlights[(indexPath as NSIndexPath).row].to!
    //        cell.scheduledTimings.text = postedFlights[(indexPath as NSIndexPath).row].std! + "-" + postedFlights[(indexPath as NSIndexPath).row].sta!
    //        cell.backgroundColor = UIColor.clear
    //        cell.contentView.backgroundColor = UIColor.clear
    //
    //
    //        return cell
    //
    //    }
    
    //    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        performSegueWithIdentifier("modifyLog", sender: indexPath.row)
    //    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /*
         let storyboar = UIStoryboard(name: "Main", bundle: nil)
         let controller  = storyboar.instantiateViewController(withIdentifier: "popup") as! FlightsVC
         
         let currentCell = tableView.cellForRow(at: indexPath) as! FlightListTableViewCell
         
         
         //        controller.fltDate = StringUtils.getDMYStringFromYMDString(postedFlights[indexPath.row].date!)
         //        controller.depStation = postedFlights[indexPath.row].from!
         //        controller.fltNo = postedFlights[indexPath.row].fltNo!
         
         var flightNumber = currentCell.lblFlightNumber.text!
         var sector = currentCell.lblSector.text!
         
         
         var flightNumberArr = flightNumber.characters.split {$0 == " "}.map(String.init)
         
         var sectorArr = sector.characters.split{$0 == "-"}.map(String.init)
         
         
         controller.fltDate = flightNumberArr[1]
         
         controller.depStation = sectorArr[0]
         
         controller.fltNo = flightNumberArr[0]
         
         
         
         //        let cell = sender as! FlightListTableViewCell
         //        let indexPath = Tableview.indexPathForCell(cell)
         //        let parentController:FLTabBarController = segue.destinationViewController as! FLTabBarController
         
         //        let flight:LegData = postedFlights[indexPath.row]
         
         FlightLogEntity.sharedInstance.initIdentifiers()
         
         FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo =  flightNumberArr[0]
         FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate = flightNumberArr[1]
         FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation = sectorArr[0]
         
         //        parentController.aircraft = flight.aircraft!
         //        parentController.reg = flight.reg!
         //
         
         
         customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
         */
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        //        if segue.identifier == "modifyLog" {
        //            let cell = sender as! FlightListTableViewCell
        ////            let indexPath = Tableview.indexPath(for: cell)
        //            let parentController:FLTabBarController = segue.destination as! FLTabBarController
        //
        //            let flight:LegData = postedFlights[(indexPath! as NSIndexPath).row]
        //
        //            FlightLogEntity.sharedInstance.initIdentifiers()
        //
        //            FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo =  flight.fltNo!
        //            FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate = StringUtils.getDMYStringFromYMDString(flight.date!)
        //            FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation = flight.from!
        //
        //            parentController.aircraft = flight.aircraft!
        //            parentController.reg = flight.reg!
        //
        //        } else
        
        if segue.identifier == "add" {
            
            FlightLogEntity.sharedInstance.initIdentifiers()
            
        } else
        if segue.identifier == "logout" {
            
            userEntity.username = ""
            
            
            
        }
        
        
    }
    
    func removeCrewScheduleFromDB() {
        
        
        let legRequest = NSFetchRequest<CrewData>(entityName: "CrewData")
        let legList = try! context.fetch(legRequest)
        
        
        for bas: AnyObject in legList
        {
            
            let ld = bas as! CrewData
            
            if ( ld.source != "IPAD" ) {
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
                    
                    for flcrewschedule in  flCrewScheduleArray!{
                        
                        
                        if ( !StringUtils.pastDataExists(flcrewschedule.date, flightNo: flcrewschedule.fltno, depStation: flcrewschedule.dep)) {
                            
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
                            
                            
                            //                            if ( crewData.pos == "0" ) {
                            //                                let legDataReq = NSFetchRequest<LegData>(entityName: "LegData")
                            //
                            //
                            //                                let datePredicate = NSPredicate(format: "date = %@", crewData.date!)
                            //                                let fltNoPredicate = NSPredicate(format: "fltNo = %@", crewData.fltNo!)
                            //                                let fromPredicate = NSPredicate(format: "from = %@", crewData.from!)
                            //
                            //                                let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
                            //
                            //                                legDataReq.predicate = compound
                            //
                            //
                            //                                let data = try! context.fetch(legDataReq)
                            //
                            //                                for legData in data {
                            //                                    if ( legData.captainId == nil) {
                            //                                        legData.captainId = crewData.staffno
                            //                                    }
                            //                                }
                            //                            }
                            
                            
                            crewDataList.append(crewData)
                            
                        }
                        
                    }
                    
                    
                    do {
                        try context.save()
                        
                    } catch let error as NSError {
                        print("Error occurred: \(error)")
                        
                    } catch {
                        fatalError()
                    }
                    //                                                            dispatch_async(dispatch_get_main_queue(), {
                    //                                        Indicator.stop()
                    //                                                            });
                    
                    Indicator.stop()
                    //                    self.Tableview.reloadData()
                    
                    
                    
                    
                }else{
                    
                    //                    alert("Message", Body: "Crew Data not available")
                    Indicator.stop()
                    
                }
                
            }else{
                alert("Message", Body: error!)
                Indicator.stop()
                
            }
            
        }
        
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }

}
