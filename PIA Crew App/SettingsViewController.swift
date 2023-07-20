//
//  SettingsViewController.swift
//  FlightLog
//
//  Created by Naveed Azhar on 26/07/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData
import Reachability


class SettingsViewController: UITableViewController {

    
    @IBOutlet weak var Tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        

        
        //        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        //        urlconfig.timeoutIntervalForRequest = 180
        //        urlconfig.timeoutIntervalForResource = 180
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
       
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if ( indexPath.row == ROW_FLIGHT_SCHEDULE ) {
//            
//            //refresh.addTarget(self, action: "refreshFlightData", forControlEvents: UIControlEvents.ValueChanged)
//            //self.Tableview.addSubview(refresh)
//            //refresh.beginRefreshing()
//            //            refreshFlightData()
//            
//        } else if ( indexPath.row == ROW_CREW_SCHEDULE) {
//            
//            //            refreshCrewSchedule()
//            
//        }
//        else if ( indexPath.row == ROW_CREW_DATABASE ) {
//            //            refreshCrewList()
//            
//        } else if ( indexPath.row == ROW_FLIGHT_LOG ) {
//            self.performSegueWithIdentifier("showFlightList", sender: nil)
//            
//        }
        
    }
    

    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
