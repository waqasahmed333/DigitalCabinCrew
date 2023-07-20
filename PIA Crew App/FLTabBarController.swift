//
//  FLTabBarController.swift
//  FlightLog
//
//  Created by Naveed Azhar on 03/07/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit

struct FlightIdentifier {
    var fltNo:String = ""
    var fltDate:String = ""
    var depStation:String = ""
    var sharedCaptainId:String? = nil
}



class FlightLogEntity {
    static let sharedInstance = FlightLogEntity()
    
    var flightIdentifiers = [FlightIdentifier]()
    
    
    func getLegCount() -> Int {
        var count = 0
        for flightIdentifier in FlightLogEntity.sharedInstance.flightIdentifiers {
            if (flightIdentifier.fltDate != "" && flightIdentifier.depStation != "" && flightIdentifier.fltNo != "") {
                count += 1
            }
        }
        return count
    }
    
    func getValidIdentifiers() -> [FlightIdentifier] {
        var tempIdentifiers = [FlightIdentifier]()
        for flightIdentifier in FlightLogEntity.sharedInstance.flightIdentifiers {
            if (flightIdentifier.fltDate != "" && flightIdentifier.depStation != "" && flightIdentifier.fltNo != "") {
                tempIdentifiers.append(flightIdentifier)
            }
        }
        return tempIdentifiers
    }
    
    func initIdentifiers() {
        flightIdentifiers = [FlightIdentifier]()
        flightIdentifiers.append(FlightIdentifier())
        flightIdentifiers.append(FlightIdentifier())
        flightIdentifiers.append(FlightIdentifier())
        flightIdentifiers.append(FlightIdentifier())
        flightIdentifiers.append(FlightIdentifier())
        
    }
    
    func isValidIdentifier(_ dmyDate:String, fltNo:String, dep:String ) -> Bool {
        for i in 0...flightIdentifiers.count {
            
            if ( flightIdentifiers[i].fltNo == fltNo &&
                flightIdentifiers[i].fltDate == dmyDate &&
                flightIdentifiers[i].depStation == dep ) {
                    return true
            }
            
            
        }
        
        return false
    }
    
}

    
    
    class FLTabBarController: UITabBarController, UITabBarControllerDelegate {
        
        
        
        var aircraft:String = ""
        
        var reg:String = ""
        
        
        
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            AppSettings.refresh(self.view)
            if ( FlightLogEntity.sharedInstance.flightIdentifiers.count == 0 ){
                FlightLogEntity.sharedInstance.initIdentifiers()
            }
            
            self.navigationController?.isNavigationBarHidden = true
            // Do any additional setup after loading the view.
            
        }
        
        override func  viewWillLayoutSubviews()
        {
        var tabFrame  = self.tabBar.frame; //self.TabBar is IBOutlet of your TabBar
        tabFrame.size.height = 80
        tabFrame.origin.y = self.view.frame.size.height - 80
        self.tabBar.frame = tabFrame
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
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
