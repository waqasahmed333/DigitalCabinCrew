//
//  ApplicationSettingsViewController.swift
//  FlightLog
//
//  Created by Naveed Azhar on 08/08/2015.
//  Copyright © 2015 Naveed Azhar. All rights reserved.
//

import UIKit

class ApplicationSettingsViewController: UIViewController {

    @IBOutlet weak var startDate: UIDatePicker!
    
    @IBOutlet weak var endDate: UIDatePicker!
    
    
    @IBAction func save(_ sender: AnyObject) {
        
        AppSettings.setParameter("CacheStartDate", value: StringUtils.getStringFromDate(self.startDate.date))
        AppSettings.setParameter("CacheEndDate", value: StringUtils.getStringFromDate(self.endDate.date))
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
AppSettings.refresh(self.view)
        let sDate = AppSettings.getParameter("CacheStartDate", defaultValue: "")
        let eDate = AppSettings.getParameter("CacheEndDate", defaultValue: "")
        
        if  let tempDate = StringUtils.getDateFromString(sDate)  {
            self.startDate.setDate( tempDate , animated: false)
        } else {
            self.startDate.setDate(Date(), animated: false)
        }
        
        if  let tempDate = StringUtils.getDateFromString(eDate)  {
            self.endDate.setDate( tempDate , animated: false)
        } else {
            self.endDate.setDate(Date(), animated: false)
        }
        
        // Do any additional setup after loading the view.
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
