//
//  AlertVC.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 15/03/2020.
//  Copyright © 2020 Naveed Azhar. All rights reserved.
//

import UIKit

class AlertVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var totalAlertBadgeCount = BadgeUtils.getBadgeCount(BadgeUtils.BADGE_CAT_QUALIFICATION) + BadgeUtils.getBadgeCount(BadgeUtils.BADGE_CAT_DOCUMENTS)
        
        if (RealmUtils.shouldCallWebRequest(key: WebRequest.QUALIFICATION, delayType: WebRequest.DELAY_TYPE_STANDARD)) {
            totalAlertBadgeCount += 1
        }
        
        if (RealmUtils.shouldCallWebRequest(key: WebRequest.DOCUMENT_LIST, delayType: WebRequest.DELAY_TYPE_STANDARD)) {
            totalAlertBadgeCount += 1
        }
        
        self.tabBarItem.badgeValue = (totalAlertBadgeCount == 0) ? nil : "\(totalAlertBadgeCount)"
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
