//
//  CheckVersionServices.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 02/11/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CheckVersionServices {
    
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
    

    
    
    static func getVerion()->String{
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
}
