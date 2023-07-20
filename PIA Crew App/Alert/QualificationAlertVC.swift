//
//  QualificationAlertVC.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 08/03/2020.
//  Copyright © 2020 Naveed Azhar. All rights reserved.
//

import UIKit
import RealmSwift
import Reachability

class RmQualification: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var base = ""
    @objc dynamic var position = ""
    @objc dynamic var aircraft = ""
    @objc dynamic var sep : Date?
    @objc dynamic var dgr : Date?
    @objc dynamic var med : Date?
    @objc dynamic var crm : Date?
    @objc dynamic var ref : Date?
    @objc dynamic var licen : Date?
}


class QualificationAlertVC: UIViewController, URLSessionDelegate {
    
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.serverTrust == nil {
            completionHandler(.useCredential, nil)
        } else {
            let trust: SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }
    
    let webRequestName = WebRequest.QUALIFICATION;
    
    let deleteObjectAfterDays = 5
    
    let minDelaySeconds = 2 * 60
    
    let standardDelaySeconds = 7 * 24 * 60 * 60
    
    @IBOutlet weak var txtID: UILabel!
    
    @IBOutlet weak var txtName: UILabel!
    
    @IBOutlet weak var txtBase: UILabel!
    
    @IBOutlet weak var txtPosition: UILabel!
    
    @IBOutlet weak var txtAircraft: UILabel!
    
    
    @IBOutlet weak var sep: UILabel!
    
    @IBOutlet weak var dgr: UILabel!
    
    @IBOutlet weak var med: UILabel!
    
    @IBOutlet weak var crm: UILabel!
    
    @IBOutlet weak var ref: UILabel!
    
    @IBOutlet weak var licen: UILabel!
    
    @IBOutlet weak var sepDays: UILabel!
    
    @IBOutlet weak var dgrDays: UILabel!
    
    @IBOutlet weak var medDays: UILabel!
    
    @IBOutlet weak var crmDays: UILabel!
    
    @IBOutlet weak var refDays: UILabel!
    
    @IBOutlet weak var licenDays: UILabel!
    
    private var RmObject : RmQualification?
    
    @IBOutlet weak var dataUpdatedOn: UILabel!
    
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
        
        var request = URLRequest(url: URL(string: NetworkUtils.getActiveServerURL() + "/GetBasicCrewInformation")!)
        request.httpMethod = "POST"
        let postString = "crewId=" + userEntity.username! + "&token=" + token;
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
            if let authenticationData = parsedObject as? NSDictionary {
                
                
                if error != nil {
                    
                } else if authenticationData["Name"] != nil {
                    
                    do {
                        let rmObject = RmQualification()
                        
                        rmObject.id = authenticationData["Pno"]  as? String ?? ""
                        rmObject.name = authenticationData["Name"] as? String ?? ""
                        rmObject.position = authenticationData["Pos"] as? String ?? ""
                        rmObject.aircraft = authenticationData["Ac"] as? String ?? ""
                        rmObject.base = authenticationData["CrewBase"] as? String ?? ""
                        
                        rmObject.crm = StringUtils.getDateFromString(StringUtils.getNumericFromString(authenticationData["CRM"] as! String));
                        rmObject.med = StringUtils.getDateFromString(StringUtils.getNumericFromString(authenticationData["MED"] as! String));
                        rmObject.dgr = StringUtils.getDateFromString(StringUtils.getNumericFromString(authenticationData["DGR"] as! String));
                        rmObject.sep = StringUtils.getDateFromString(StringUtils.getNumericFromString(authenticationData["SEP"] as! String));
                        rmObject.ref = StringUtils.getDateFromString(StringUtils.getNumericFromString(authenticationData["REF"] as! String));
                        rmObject.licen = StringUtils.getDateFromString(StringUtils.getNumericFromString(authenticationData["LICEN"] as! String));
                        
                        
                        self.removeObjectsFromRealm()
                        
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
            
            // no need to fetch because it will be done on relevant pages
            //            self.fetchFlightInfoFromLocalDB()
            
        })
        task.resume()
    }
    
    private func loadFromRealmCache() {
        print(#function)
        
        do {
            let realm = try Realm()
            
            var objects = realm.objects(RmQualification.self)
            
            //.filter("flightDate <= %@", earliestDate)
            
            
            self.RmObject = objects.first
            
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
            
            let result = realm.objects(RmQualification.self)
            
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
        
        if let obj = self.RmObject {
            
            self.txtID.text = obj.id
            self.txtBase.text = obj.base
            self.txtName.text = obj.name
            self.txtAircraft.text = obj.aircraft
            self.txtPosition.text = obj.position
            
            
            self.crm.text = StringUtils.getStringFromDate(obj.crm, dateFormat: "dd/MM/yyyy")
            self.med.text = StringUtils.getStringFromDate(obj.med, dateFormat: "dd/MM/yyyy")
            self.dgr.text = StringUtils.getStringFromDate(obj.dgr, dateFormat: "dd/MM/yyyy")
            self.sep.text = StringUtils.getStringFromDate(obj.sep, dateFormat: "dd/MM/yyyy")
            self.ref.text = StringUtils.getStringFromDate(obj.ref, dateFormat: "dd/MM/yyyy")
            self.licen.text = StringUtils.getStringFromDate(obj.licen, dateFormat: "dd/MM/yyyy")
            
            
            
            if (StringUtils.formatExpiryDuration(label: self.crmDays,date: obj.crm)) {
                badgeCount += 1
            }
            if (StringUtils.formatExpiryDuration(label: self.medDays,date: obj.med)) {
                badgeCount += 1
            }
            if (StringUtils.formatExpiryDuration(label: self.dgrDays,date: obj.dgr)) {
                badgeCount += 1
            }
            if (StringUtils.formatExpiryDuration(label: self.sepDays,date: obj.sep)) {
                badgeCount += 1
            }
            if (StringUtils.formatExpiryDuration(label: self.refDays,date: obj.ref)) {
                badgeCount += 1
            }
            if (StringUtils.formatExpiryDuration(label: self.licenDays,date: obj.licen)) {
                badgeCount += 1
            }
            
            if let d = RealmUtils.getLastWebRequestTime(key: webRequestName) {
                self.dataUpdatedOn.text = StringUtils.getStringFromDate(d, dateFormat: "dd/MMM/yyyy HH:mm")
                
                if RealmUtils.shouldCallWebRequest(key: webRequestName, delayType: WebRequest.DELAY_TYPE_STANDARD) {
                    badgeCount += 1
                }
            } else {
                
                badgeCount += 1
            }
        } else {
            badgeCount += 1
        }
        
        BadgeUtils.updateBadgeCount(BadgeUtils.BADGE_CAT_QUALIFICATION, value: badgeCount)
        
        self.tabBarItem.badgeValue = (badgeCount == 0) ? nil : "\(badgeCount)"
        
        let totalAlertBadgeCount = BadgeUtils.getBadgeCount(BadgeUtils.BADGE_CAT_QUALIFICATION) + BadgeUtils.getBadgeCount(BadgeUtils.BADGE_CAT_DOCUMENTS) + DocNotificationUtils.getUnreadCircularsOrSectionBadgeCount()
        
        self.parent?.tabBarItem.badgeValue = (totalAlertBadgeCount == 0) ? nil : "\(totalAlertBadgeCount)"
        
        
    }
    @IBAction func refresh(_ sender: Any) {
        
        if ( RealmUtils.shouldCallWebRequest(key: webRequestName, delayType: WebRequest.DELAY_TYPE_MINIMMUM) ) {
            
            // create the alert
            let alert = UIAlertController(title: "Notice", message: "Are you sure you want to refresh qualification data?", preferredStyle: UIAlertController.Style.alert)
            
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
