//
//  DocumentService.swift

//
//  Created by Naveed Azhar on 29/04/2016.
//  Copyright © 2016 PIA. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DocumentServices {
    private static var Manager: Alamofire.SessionManager = {
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

    static func getDocuments(_ section: String, completion: @escaping (_ documentSectionArray: [DocumentSection]?, _ error: String?) -> Void) {

        let serverIndex = UDUtils.getValue(forKey: "documentServer", defaultValue: "0")


        var ac = userEntity.ac!

        ac = MiscUtils.getACTypeFromIATACode(acType: ac)

        ac = ac.replacingOccurrences(of: " ", with: "")


        var url = "https://crewserver1.piac.com.pk" + AppConstants.WEB_SERVICE_URL + "/GetDocumentsForSectionFromDB_ByAC?token=1&ac=" + ac + "&section=" + section //+ "&ac=" + ac

        if (Int(serverIndex!)! > 2) {
            url = "https://crewserver1.piac.com.pk" + AppConstants.WEB_SERVICE_URL + "/GetDocumentsForSectionFromDB_ByAC?token=1&ac=" + ac + "&section=" + section //+ "&ac=" + ac
        }

        print(url)
        Manager.request(url)
            .responseJSON { (response) in
            var object: JSON = JSON.null

            var dataloaded = false
            if (response.result.error != nil) {
                let data = UserDefaults.standard.object(forKey: "JSON-" + section) as AnyObject?
                object = JSON(data)
//                    print(object)
                dataloaded = true
            } else {
                object = JSON(response.result.value!)
                UserDefaults.standard.set(response.result.value!, forKey: "JSON-" + section)
            }

            if response.result.error == nil || dataloaded {


                var documentSections = [DocumentSection]()

                var documents = [DocumentItem]()


                for document in object["DocumentList"].arrayValue {

                    let name = document["Name"].stringValue
                    let type = document["Type"].stringValue.replacingOccurrences(of: "_", with: " ")
                    let createDate = document["CreateDate"].stringValue
                    let url = document["Url"].stringValue
                    let docID = document["DocId"].stringValue
                    let subject = document["Subject"].stringValue
                    let year = document["Year"].stringValue
                    if (section == "Manual/Forms") {
                        if (type == "Forms") {
                            documents.append(DocumentItem(name: name, type: type, createDate: createDate, url: url, docID: docID, subject: subject, year: year))
                        }
                    } else if (section == "Manual/HOTAC") {
                        if (type == "HOTAC Documents") {
                            documents.append(DocumentItem(name: name, type: type, createDate: createDate, url: url, docID: docID, subject: subject, year: year))
                        }
                    } else {
                        documents.append(DocumentItem(name: name, type: type, createDate: createDate, url: url, docID: docID, subject: subject, year: year))
                    }
                }


                let documentSection = DocumentSection(title: object["title"].stringValue, description: object["description"].stringValue, documents: documents)

                documents = []
                documentSections.append(documentSection)


                completion(documentSections, nil)
                documentSections = []

            } else {

                completion(nil, response.result.error!.localizedDescription)

            }



        }

    }


    static func getLFEDocuments(_ section: String, completion: @escaping (_ documentSectionArray: [LFEDocumentSection]?, _ error: String?) -> Void) {

        let serverIndex = UDUtils.getValue(forKey: "documentServer", defaultValue: "0")


        var url = "https://crewserver1.piac.com.pk" + AppConstants.WEB_SERVICE_URL + "/GetLFEDocuments?username=54894&token=" + "913d0d2f7cb4df29a5f723c5f79f7b66";

        if (Int(serverIndex!)! > 2) {
            url = "https://crewserver1.piac.com.pk" + AppConstants.WEB_SERVICE_URL + "/GetLFEDocuments?username=54894&token=" + "913d0d2f7cb4df29a5f723c5f79f7b66";
        }
        print(url)
        Manager.request(url)
            .responseJSON { (response) in
            var object: JSON = JSON.null

            var dataloaded = false
            if (response.result.error != nil) {
                let data = UserDefaults.standard.object(forKey: "JSON-LFE" + section) as AnyObject?
                object = JSON(data)
//                    print(object)
                dataloaded = true
            } else {
                object = JSON(response.result.value!)
                UserDefaults.standard.set(response.result.value!, forKey: "JSON-LFE" + section)
            }

            if response.result.error == nil || dataloaded {


                var documentSections = [LFEDocumentSection]()

                var documents = [LFEDocumentItem]()


                for document in object["DocumentList"].arrayValue {

                    let filename = document["Filename"].stringValue
                    let type = document["Type"].stringValue.replacingOccurrences(of: "_", with: " ")
                    let createDate = document["CreateDate"].stringValue
                    let url = document["Url"].stringValue
                    let docID = document["DocId"].stringValue
                    let subject = document["Subject"].stringValue
                    let iata = document["Iata"].stringValue
                    let icao = document["Icao"].stringValue

                    documents.append(LFEDocumentItem(filename: filename, type: type, createDate: createDate, url: url, docID: docID, subject: subject, iata: iata, icao: icao))
                }


                let documentSection = LFEDocumentSection(title: object["title"].stringValue, description: object["description"].stringValue, documents: documents)

                documents = []
                documentSections.append(documentSection)


                completion(documentSections, nil)
                documentSections = []

            } else {

                completion(nil, response.result.error!.localizedDescription)

            }



        }

    }


    static fileprivate func stringToNSdate(_ date: String) -> Date {

        //2016-05-15

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: date)
        return date!

    }

}

