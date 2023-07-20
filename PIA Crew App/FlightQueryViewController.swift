//
//  FlightQueryLegViewController.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 01/05/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData

import Reachability


class FlightQueryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, URLSessionDelegate {
    
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.serverTrust == nil {
            completionHandler(.useCredential, nil)
        } else {
            let trust: SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }
    
    var flights = [FlightQueryLeg]()
    var unfileteredFlights = [FlightQueryLeg]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var DATA_LOADED: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    override func viewDidLoad() {
        
        
        MiscUtils.formatTableView(tableView)
        
        super.viewDidLoad()
        

      

        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.placeholder = "Search by Flight Number or Crew Name"
        
        // if the searchbox does not automatically disappear after navigating to other controller
        definesPresentationContext = true
        
        self.refreshData()
    }
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            self.flights =  self.unfileteredFlights.filter { docItem in
                return docItem.flightNumber!.lowercased().contains(searchText.lowercased()) || docItem.crewInfo!.lowercased().contains(searchText.lowercased())
            }
            
        } else {
            self.flights = self.unfileteredFlights
        }
        tableView.reloadData()
    }
    
    
    func refreshData(){
        

        if ( !DATA_LOADED && MiscUtils.isOnlineMode()) {
            fetchFlightInfoFromJSON()
        } else {
            fetchFlightQueryLegFromLocalDB()
        }
    }
    
    
    func fetchFlightInfoFromJSON() {
        
        Indicator.start(self)

        let token:String = "new_token"
        let stIndex = StringUtils.getStringFromDate(Date())
        let enIndex = StringUtils.getStringFromDate(Date())
//        token = token.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed())!
        
        var request = URLRequest(url: URL(string: NetworkUtils.getActiveServerURL() + "/GetFlightsForDuration")!)
        request.httpMethod = "POST"
        let postString = "token=\(token)" + "&stIndex=\(stIndex)&enIndex=\(enIndex)";
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print( "\(error)")
                //                settings[self.ROW_FLIGHT_SCHEDULE].value = "Cannot update: please check connection"
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })

            } else {
                
                //                postedFlights.removeAll(keepCapacity: false)
                
                
                
                
                let parsedObject: Any?
                do {
                    parsedObject = try JSONSerialization.jsonObject(with: data!,
                                                                              options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    
                    //2
                    if let rootDictionary = parsedObject as? NSDictionary {
                        
                        
                        
                        if let entityList = rootDictionary["FltList"] as? NSArray {
                            
                            
                            let NumRows = entityList.count
                            
                            if ( NumRows > 0 ) {
                                self.removeFlightQueryLegFromDB()
                            }
                            NSLog("Processing JSON flight list %d records", NumRows)
                            
                            
                            for row in 0..<NumRows  {
                                
                                if  let fltrow = entityList[row] as? NSDictionary {
                                    
                                    var flt_date:String = ""
                                    var flt_dep:String = ""
                                    var flt_arr:String = ""
                                    var flt_flight:String = ""
                                    var flt_std:String = ""
                                    var flt_sta:String = ""
                                    var flt_aircraft:String = ""
//                                    var flt_reg:String = ""
                                    var flt_crewinfo:String = ""
                                    
                                    if  let  date_ = fltrow["Date_"] as? NSString {
                                        flt_date = date_ as String
                                    }
                                    if let flight = fltrow["Flight"] as? NSString {
                                        flt_flight = flight as String
                                    }
                                    if let dep = fltrow["Dep"] as? NSString {
                                        flt_dep = dep as String
                                    }
                                    if let arr = fltrow["Arr"] as? NSString {
                                        flt_arr = arr as String
                                    }
                                    if let std = fltrow["Std"] as? NSString {
                                        flt_std = std as String
                                    }
                                    if let sta = fltrow["Sta"] as? NSString {
                                        flt_sta = sta as String
                                    }
                                    if let aircraft = fltrow["Ac"] as? NSString {
                                        flt_aircraft = aircraft as String
                                    }
//                                    if let reg = fltrow["Reg"] as? NSString {
//                                        flt_reg = reg as String
//                                    }
                                    if let crewinfo = fltrow["CrewInfo"] as? NSString {
                                        flt_crewinfo = crewinfo as String
                                    }

                                    if  !StringUtils.isFlightQueryLegAlreadyPresent(flt_date, flightNo: flt_flight, depStation: flt_dep)  {
                                        
                                        
                                        
                                        let legEntityDescripition = NSEntityDescription.entity(forEntityName: "FlightQueryLeg", in: context)
                                        
                                        let legData = FlightQueryLeg(entity: legEntityDescripition!, insertInto: context)
                                        
                                        
                                        legData.date = flt_date
                                        legData.flightNumber = flt_flight
                                        legData.aircraft = flt_aircraft
                                        legData.depStation = flt_dep
                                        legData.arrStation = flt_arr
                                        legData.std = flt_std
                                        legData.sta = flt_sta
                                        legData.crewInfo = flt_crewinfo
                                    } else {
                                        let fetchreq = NSFetchRequest<FlightQueryLeg>(entityName: "FlightQueryLeg")
                                        
                                        let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString( flt_date))
                                        let fltNoPredicate = NSPredicate(format: "fltNo = %@", flt_flight)
                                        let fromPredicate = NSPredicate(format: "from = %@", flt_dep)
                                        //                                    let sourcePredicate = NSPredicate(format: "source = %@", "IPAD")
                                        
                                        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
                                        
                                        fetchreq.predicate = compound
                                        
                                        
                                        let data = try! context.fetch(fetchreq)
                                        
                                        if  data.count > 0
                                        {
                                            
                                            
                                            //                                            let legData = data[0]
                                            //
                                            //
                                            //                                            postedFlights.append(legData)
                                            //
                                            //
                                            //                                            legData.std = flt_std
                                            //                                            legData.sta = flt_sta
                                            
                                            
                                        }
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                    
                    try context.save()
                    

          
                    DispatchQueue.main.async(execute: {
                        self.fetchFlightQueryLegFromLocalDB()
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
    
    func removeFlightQueryLegFromDB() {
        
        
        let legRequest = NSFetchRequest<FlightQueryLeg>(entityName: "FlightQueryLeg")
        let legList = try! context.fetch(legRequest)
        
        
        for bas: AnyObject in legList
        {
            
            // let ld = bas as! FlightQueryLeg
            
            //            if ( ld.source != "IPAD" ) {
            context.delete(bas as! NSManagedObject)
            //            }
            
        }
        
        do {
            try context.save()
        } catch _ {
        }
        
    }
    
    func entitySorter (_ entity1:FlightQueryLeg, entity2:FlightQueryLeg) -> Bool {
        return  entity1.date! + entity1.std! <  entity2.date! + entity2.std!
    }
    
    func fetchFlightQueryLegFromLocalDB() {
        print(#function)
        
        
        
        
        
        let legRequest = NSFetchRequest<FlightQueryLeg>(entityName: "FlightQueryLeg")
        let legData = try! context.fetch(legRequest)
        
        unfileteredFlights = legData
        
        unfileteredFlights.sort(by: entitySorter)
        
        flights = legData
        flights.sort(by: entitySorter)

        //        self.Tableview.reloadData()
        
        
       //self.tableView.reloadData()
        
        
    }
    
    
    func loadData() {
        
        let actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.style = UIActivityIndicatorView.Style.gray
        actInd.backgroundColor = UIColor.blue
        view.addSubview(actInd)
        actInd.startAnimating()
        sleep(5000)
        actInd.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flights.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "flightCell") as! FlightQueryTableViewCell
        

        
        
        cell.date.text = flights[(indexPath as NSIndexPath).row].date!
        
        cell.flight.text = flights[(indexPath as NSIndexPath).row].flightNumber!
        
        cell.depStation.text = flights[(indexPath as NSIndexPath).row].depStation!
            
        cell.arrStation.text = flights[(indexPath as NSIndexPath).row].arrStation!
        
        cell.std.text  = flights[(indexPath as NSIndexPath).row].std!
        
        cell.sta.text = flights[(indexPath as NSIndexPath).row].sta!
        
        cell.aircraft.text = flights[(indexPath as NSIndexPath).row].aircraft
        
        cell.crewInfo.text = flights[(indexPath as NSIndexPath).row].crewInfo

        if #available(iOS 12.0, *) {
            cell.backgroundColor = MiscUtils.getRowBGColor(indexPathRow: indexPath.row, userInterfaceStyle: traitCollection.userInterfaceStyle)
        } else {
            // Fallback on earlier versions
        }
        
        cell.layoutIfNeeded()
        
        return cell
        
    }

    
    
}
