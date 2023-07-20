//
//  LFETabBarViewController.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 29/11/2021.
//  Copyright © 2021 Naveed Azhar. All rights reserved.
//

import UIKit


class LFETabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectedIndex = selectedLFETab
        // Do any additional setup after loading the view.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if ( item.tag == 0 ) {
            LFEFilter = ["PilotNotes"]
        } else if ( item.tag == 1 ) {
            LFEFilter = ["ASRs"]
        } else if ( item.tag == 2 ) {
            LFEFilter = ["Incident"]
        } else if ( item.tag == 3 ) {
            LFEFilter = ["PilotNotes","ASRs","Incident"]
        } 
        
        print(  "\(item.tag) \(item.title!) \(LFEFilter)")

        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
