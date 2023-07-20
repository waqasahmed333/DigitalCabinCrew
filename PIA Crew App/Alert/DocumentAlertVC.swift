//
//  DocAlertVC.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 08/03/2020.
//  Copyright © 2020 Naveed Azhar. All rights reserved.
//

import UIKit
import RealmSwift
import Reachability

class RmDocNotification: Object {
    @objc dynamic var crewId = ""
    @objc dynamic var sentDate = Date()
    @objc dynamic var documentId = 0
    @objc dynamic var subject = ""
    @objc dynamic var tokenId = ""
}


class DocumentAlertVC: UIViewController, URLSessionDelegate {
    
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.serverTrust == nil {
            completionHandler(.useCredential, nil)
        } else {
            let trust: SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }
    
    let webRequestName = WebRequest.DOCUMENT_LIST;
    
    let deleteObjectAfterDays = 5
    
    let minDelaySeconds = 2 * 60
    
    let standardDelaySeconds = 12 * 60 * 60
    
    @IBOutlet weak var unreadSectionCount: UILabel!
    
    @IBOutlet weak var unreadCircularCount: UILabel!
    
    @IBOutlet weak var unreadSectionLabel: UILabel!
    
    @IBOutlet weak var unreadCircularLabel: UILabel!
    
    
    @IBOutlet weak var dataUpdatedOn: UILabel!
    
    var docNotificationList : [RmDocNotification] = []
    
    override func viewWillAppear(_ animated: Bool) {
        if ( RealmUtils.shouldCallWebRequest(key: webRequestName, delayType: WebRequest.DELAY_TYPE_STANDARD) ) {
            loadFromJSONandUpdateRealmCache()
        } else {
            loadFromRealmCache()
        }
    }
    
    private func loadFromJSONandUpdateRealmCache() {
        
        Indicator.start(self)
        
        let token:String = "new_token"
        
        var request = URLRequest(url: URL(string:  "https://crewserver1.piac.com.pk/NotificationWS/Service1.asmx/getNotNotifiedDocuments")!)
        request.httpMethod = "POST"
        let postString = "pno=" + userEntity.username! + "&token=" + token;
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            var parsedObject: Any?
            
            
            if ( data != nil ) {
                do {
                    parsedObject = try JSONSerialization.jsonObject(with: data!,
                                                                    options: JSONSerialization.ReadingOptions.allowFragments)
                } catch _ as NSError {
                    parsedObject = nil
                } catch {
                    fatalError()
                }
            }
            
            
            //2
            if let rootDictionary = parsedObject as? NSArray {
                
                
                
                if let entityList = parsedObject as? NSArray {
                    
                    
                    let NumRows = entityList.count
                    
                    //                                    if ( NumRows > 0 ) {
                    self.removeObjectsFromRealm()
                    //                                    }
                    NSLog("Processing JSON flight list %d records", NumRows)
                    
                    
                    for row in 0..<NumRows  {
                        
                        if  let authenticationData = entityList[row] as? NSDictionary {
                            
                            
                            do {
                                let rmObject = RmDocNotification()
                                
                                
                                rmObject.crewId = authenticationData["Pno"]  as? String ?? ""
                                rmObject.sentDate = StringUtils.getDateFromString(authenticationData["SendDate"] as! String, dateFormat: "dd/MM/yyyy HH:mm" )!
                                rmObject.documentId = authenticationData["Sno"] as? Int ?? 0
                                rmObject.subject = authenticationData["Subject"] as? String ?? ""
                                rmObject.tokenId = authenticationData["TokenId"] as? String ?? ""
                                
                                
                                
                                
                                // Get the default Realm
                                let realm = try! Realm()
                                
                                try! realm.write {
                                    realm.add(rmObject)
                                }
                                
                                
                                DispatchQueue.main.async(execute: {
                                    
                                    RealmUtils.updateWebRequestCache(key: self.webRequestName, deleteObjectAfterDays: self.deleteObjectAfterDays, minDelaySeconds: self.minDelaySeconds, standardDelaySeconds: self.standardDelaySeconds)
                                    
                                    self.loadFromRealmCache()
                                    self.updateUIElements()
                                    Indicator.stop()
                                })
                                
                                
                            } catch let error as NSError {
                                print("Error : \(error)")
                                DispatchQueue.main.async(execute: {
                                    self.updateUIElements()
                                })
                            } catch {
                                fatalError()
                            }
                            
                        }
                    }
                    
                }
            }
            // no need to fetch because it will be done on relevant pages
            //            self.fetchFlightInfoFromLocalDB()
            
        })
        task.resume()
    }
    
    private func loadFromRealmCache() {
        print(#function)
        
        do {
            let realm = try Realm()
            
            let objects = realm.objects(RmDocNotification.self)
            
            //.filter("flightDate <= %@", earliestDate)
            
            
            self.docNotificationList = Array(objects)
            
            updateUIElements()
            
            
        } catch {
            //handle error
            print(error)
        }
        
        
        
        
    }
    
    private func removeObjectsFromRealm() {
        
        
        do {
            let realm = try Realm()
            
            //            let items = [Items]() // fill in your items values
            //            // then just grab the ids of the items with
            //            let ids = items.map { $0.id }
            //
            //            // query all objects where the id in not included
            //            let objectsToDelete = realm.objects(Items.self).filter("NOT id IN %@", ids)
            //
            //            // and then just remove the set with
            //            realm.delete(objectsToDelete)
            
            let result = realm.objects(RmDocNotification.self)
            
            try! realm.write {
                realm.delete(result)
            }
            
        } catch {
            //handle error
            print(error)
        }
        
        
    }
    
    private func updateUIElements () {
        
        var badgeCount = 0
        
        
        
        
        
        if let d = RealmUtils.getLastWebRequestTime(key: webRequestName) {
            self.dataUpdatedOn.text = StringUtils.getStringFromDate(d, dateFormat: "dd/MMM/yyyy HH:mm")
            
            if RealmUtils.shouldCallWebRequest(key: webRequestName, delayType: WebRequest.DELAY_TYPE_STANDARD) {
                badgeCount += 1
            }
        } else {
            
            badgeCount += 1
        }
        
        
        if ( badgeCount == 0 ) {
            badgeCount = self.docNotificationList.count
        }
        
        badgeCount += DocNotificationUtils.getUnreadCircularsOrSectionBadgeCount()
        
        BadgeUtils.updateBadgeCount(BadgeUtils.BADGE_CAT_DOCUMENTS, value: badgeCount)
        
        self.tabBarItem.badgeValue = (badgeCount == 0) ? nil : "\(badgeCount)"
        
        if (badgeCount == 0 ) {
            self.unreadCircularLabel.isHidden = true
            self.unreadCircularCount.isHidden = true
        } else {
            self.unreadCircularCount.text = self.tabBarItem.badgeValue
        }
        
        
        let totalAlertBadgeCount = BadgeUtils.getBadgeCount(BadgeUtils.BADGE_CAT_QUALIFICATION) + BadgeUtils.getBadgeCount(BadgeUtils.BADGE_CAT_DOCUMENTS) + DocNotificationUtils.getUnreadCircularsOrSectionBadgeCount()
        
        self.parent?.tabBarItem.badgeValue = (totalAlertBadgeCount == 0) ? nil : "\(totalAlertBadgeCount)"
        
        
        
    }
    
    @IBAction func refresh(_ sender: Any) {
        
        if ( RealmUtils.shouldCallWebRequest(key: webRequestName, delayType: WebRequest.DELAY_TYPE_MINIMMUM) ) {
            
            // create the alert
            let alert = UIAlertController(title: "Notice", message: "Are you sure you want to refresh Document Notification data?", preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { action in
                
                
                
            }))
            
            alert.addAction(UIAlertAction(title: "Refresh", style: UIAlertAction.Style.default, handler: { action in
                
                
                self.loadFromJSONandUpdateRealmCache()
                
                
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            
        } else {
            
            self.loadFromRealmCache()
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
