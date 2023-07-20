//
//  NetworkUtils.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 4/7/18.
//  Copyright © 2018 Naveed Azhar. All rights reserved.
//

import Foundation

class NetworkUtils {
    class func getActiveServerURL() -> String {
    
        let serverIndex = UDUtils.getValue(forKey: "documentServer", defaultValue: "0")
    
    let serverArrays = [
        "https://crew2.piac.com.pk",
        "https://crew3.piac.com.pk",
        "https://crewserver1.piac.com.pk",
        "https://crew2.piac.com.pk",
        "https://crew3.piac.com.pk",
        "https://crewserver1.piac.com.pk"]

        return serverArrays[Int(serverIndex!)!] + AppConstants.WEB_SERVICE_URL
        
    }
}
