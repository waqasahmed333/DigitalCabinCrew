//
//  FlightPlanViewController.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 01/05/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import Reachability

class FPPlanListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, URLSessionDelegate {
    
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.serverTrust == nil {
            completionHandler(.useCredential, nil)
        } else {
            let trust: SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }
    
    var flightPlanList = [FPFlight]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var SHOW_HIDDEN: Bool = false
    
    var PAST_DAYS: Double = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        if ( RealmParamsUtils.shared.shouldRefreshFPFlights() ) {
            loadFromJSONandUpdateRealmCache()
        } else {
            loadFromRealmCache()
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard UIApplication.shared.applicationState == .inactive else {
            return
        }

        self.tableView.reloadData()
    }
    
    
    private func loadFromJSONandUpdateRealmCache() {
        
        Indicator.start(self)
        
        
        
        let token:String = "new_token"
        
        var request = URLRequest(url: URL(string: NetworkUtils.getActiveServerURL() + "/GetFlightPlans")!)
        request.httpMethod = "POST"
        let postString = "token=\(token)" + "&crewId=\(userEntity.username!)";
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print( "\(error)")
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            } else {
                
                let parsedObject: Any?
                do {
                    parsedObject = try JSONSerialization.jsonObject(with: data!,
                                                                    options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    
                    //2
                    if let rootDictionary = parsedObject as? NSDictionary {
                        
                        print(parsedObject)
                        
                        
                        if let entityList = rootDictionary["FltList"] as? NSArray {
                            
                            
                            let NumRows = entityList.count
                            
                            if ( NumRows > 0 ) {
                                self.removeObjectsFromRealm()
                            }
                            NSLog("Processing JSON flight list %d records", NumRows)
                            

                            
                            
                            for row in 0..<NumRows  {
                                
                                if  let fltrow = entityList[row] as? NSDictionary {
                                    
                                    let flt_date:String = fltrow["Date_"] as! String? ?? ""
                                    let flt_dep:String = fltrow["Dep"] as! String? ?? ""
                                    let flt_arr:String = fltrow["Arr"] as! String? ?? ""
                                    let flt_flight:String = fltrow["Flight"] as! String? ?? ""
                                    let flt_std:String = fltrow["Std"] as! String? ?? ""
                                    let flt_sta:String = fltrow["Sta"] as! String? ?? ""
                                    let flt_aircraft:String = fltrow["Ac"] as! String? ?? ""
                                    
                                    // Get the default Realm
                                    let realm = try! Realm()
                                    
                                    // Query Realm for all dogs less than 2 years old
                                    let fpFlights = realm.objects(FPFlight.self).filter("flightDate = %@ and depStation = %@ and flightNumber = %@", StringUtils.getDateFromString(flt_date), flt_dep, flt_flight )
                                    
                                    
                                    if (fpFlights.count == 0 ) {
                                        
                                        
                                        // Use them like regular Swift objects
                                        let fpFlight = FPFlight()
                                        fpFlight.aircraft = flt_aircraft
                                        fpFlight.arrStation = flt_arr
                                        fpFlight.flightDate = StringUtils.getDateFromString(flt_date)!
                                        fpFlight.crewId = "60985"
                                        fpFlight.depStation = flt_dep
                                        fpFlight.std =  fpFlight.flightDate.addingTimeInterval(TimeInterval(60 * Int(flt_std)!))
                                        fpFlight.sta = fpFlight.flightDate.addingTimeInterval(TimeInterval(60 * Int(flt_sta)!))
                                        fpFlight.flightNumber = flt_flight
                                        
                                        
                                        // Get the default Realm
                                        //                                       let realm = try! Realm()
                                        
                                        
                                        // Persist your data easily
                                        try! realm.write {
                                            realm.add(fpFlight)
                                        }
                                        //                                      try! realm.commitWrite()
                                        
                                        
                                        
                                        
                                    }
                                    
                                    
                                }
                                
                            }
                            
                        }
                    }
                    

                    
                    
                    DispatchQueue.main.async(execute: {
                    
                    
                        RealmParamsUtils.shared.updateLastRequestTimeFPFlights()
                        self.loadFromRealmCache()
                        self.tableView.reloadData()
                        Indicator.stop()
                    })
                    
                    
                } catch let error as NSError {
                    print("Error : \(error)")
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                } catch {
                    fatalError()
                }
                
            }
            
            // no need to fetch because it will be done on relevant pages
            //            self.fetchFlightInfoFromLocalDB()
            
        })
        task.resume()
    }
    
    func removeObjectsFromRealm() {
        
        
        do {
            let realm = try Realm()
            
            var fpFlights = realm.objects(FPFlight.self).makeIterator()
            while let fpFlight = fpFlights.next() {
                
                var shouldDeleteParent = true
                var fpPlans = fpFlight.plans.makeIterator()
                while let fpPlan = fpPlans.next() {
                    if (fpPlan.signedOn == nil && fpPlan.uploadedOn == nil) {
                        try! realm.write {
                            realm.delete(fpPlan)
                        }
                    } else {
                        shouldDeleteParent = false
                    }
                }
                
                if (shouldDeleteParent) {
                    try! realm.write {
                        realm.delete(fpFlight)
                    }
                }
            }
        } catch {
            //handle error
            print(error)
        }
        
        
    }
    
    func entitySorter (_ entity1:FlightPlan, entity2:FlightPlan) -> Bool {
        return  entity1.date! + entity1.std! <  entity2.date! + entity2.std!
    }
    
    private func loadFromRealmCache() {
        print(#function)
        
        do {
             let realm = try Realm()
             
            
            let earliestDate = NSDate().addingTimeInterval(60 * 60 * 24 * PAST_DAYS)
            
            var fpFlights = realm.objects(FPFlight.self)//.filter("flightDate <= %@", earliestDate)
            if (SHOW_HIDDEN) {
                fpFlights = realm.objects(FPFlight.self)//.filter("flightDate <= %@", earliestDate)
            } else {
                fpFlights = realm.objects(FPFlight.self)//.filter("flightDate <= %@", earliestDate)
                
                //                    let fpFlights = realm.objects(FPFlight.self).filter("date = '" + flt_date + "' and depStation = '" + flt_dep + "' and flightNumber = '" + flt_flight + "'" )
            }
            
                    flightPlanList = Array(fpFlights)
            
            } catch {
                //handle error
                print(error)
            }
        

        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return flightPlanList.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "flightCell") as! FPFlightListTableViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        //        var date = dateFormatter.stringFromDate(flights[indexPath.row].date)
        // var date = flights[indexPath.row]
        
        cell.date.text = StringUtils.getStringFromDate(flightPlanList[(indexPath as NSIndexPath).row].flightDate)
        
        cell.flight.text = flightPlanList[(indexPath as NSIndexPath).row].flightNumber
        
        cell.depStation.text = flightPlanList[(indexPath as NSIndexPath).row].depStation
        
        cell.arrStation.text = flightPlanList[(indexPath as NSIndexPath).row].arrStation
        
        cell.std.text  = StringUtils.getHHMMFromDateTime(flightPlanList[(indexPath as NSIndexPath).row].std)
        
        cell.sta.text = StringUtils.getHHMMFromDateTime(flightPlanList[(indexPath as NSIndexPath).row].sta)
        
        cell.aircraft.text = flightPlanList[(indexPath as NSIndexPath).row].aircraft
        cell.background.layer.cornerRadius = cell.background.frame.height/2
        cell.backgroundColor=UIColor.clear
        
        
        if flightPlanList[(indexPath as NSIndexPath).row].documentName.isFileAvailable() {
            cell.download.setTitle("Upload", for: UIControl.State())
            cell.download.addTarget(self, action: #selector(FPPlanListViewController.open(_:)), for: .touchUpInside)
            cell.download.tag = (indexPath as NSIndexPath).row
            cell.btnFill.setTitle("Digitally Fill", for: UIControl.State())
            cell.btnFill.isEnabled = true

        } else {
            cell.download.setTitle("Download", for: UIControl.State())
            cell.download.addTarget(self, action: #selector(FPPlanListViewController.download(_:)), for: .touchUpInside)
            cell.download.tag = (indexPath as NSIndexPath).row
            cell.btnFill.setTitle("        ", for: UIControl.State())
            cell.btnFill.backgroundColor = UIColor.clear
            cell.btnFill.isEnabled = false

        }
        
        
        
        if #available(iOS 12.0, *) {
            cell.backgroundColor = MiscUtils.getRowBGColor(indexPathRow: indexPath.row, userInterfaceStyle: traitCollection.userInterfaceStyle)
        } else {
            // Fallback on earlier versions
        }
        
        return cell
        
    }
    
    
    @objc private func download(_ sender:UIButton) {
        
        let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! FPFlightListTableViewCell
        
        if cell.download.currentTitle == "Download" {
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let getImagePath = documentsURL.appendingPathComponent(self.flightPlanList[sender.tag].documentName)
            print("Deleting file" + getImagePath.absoluteString)
            
            do {
                try FileManager.default.removeItem(at: getImagePath)
            } catch {
                //                print("Could not remove file: \(error)")
            }
            
            DownloadServices.downloadFlightPlan2(self.flightPlanList[sender.tag].url) { (percentage, error) in
                
                if error == nil {
                    
                    
                    if percentage == 1 {
                        cell.btnFill.setTitle("Upload", for: UIControl.State())
                        cell.btnFill.addTarget(self, action: #selector(FPPlanListViewController.open(_:)), for: .touchUpInside)
                        cell.btnFill.tag = sender.tag
                        cell.btnFill.isEnabled=true
                        cell.download.setTitle("Delete", for: UIControl.State())
                        cell.download.isEnabled = true
                        
                    }else{
                        
                        cell.download.tag = sender.tag
                        cell.download.setTitle( String(round(100 * (percentage ?? 0))) + "%", for: UIControl.State())
                        cell.download.isEnabled=false
                        
                        
                    }
                    
                }else{
                    
                    alert("Message", Body: "Suggestion:Download one file at a time.\r\n" + error!)
                }
                
            }
        }
        
        
    }
    
    @objc private func open(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "pdf") as! webViewController
        vc.fileName = self.flightPlanList[sender.tag].documentName
        self.present(vc, animated: true, completion: nil)
    }
    
    
}
