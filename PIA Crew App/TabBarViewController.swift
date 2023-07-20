//
//  TabBarViewController.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 01/05/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let nav = self.parent as! UINavigationController

//         nav.isNavigationBarHidden=false
        
        DISPLAY_UPLOADED_LOGS = 1
        
        
        if item.title != "Home" {
            nav.isNavigationBarHidden=true
            
        }else{
            nav.isNavigationBarHidden=false

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


}
