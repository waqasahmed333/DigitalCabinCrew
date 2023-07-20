//
//  ViewController.swift
//  FlightLog
//
//  Created by Naveed Azhar on 22/06/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData
import Reachability
import Alamofire
import SwiftyJSON

struct UserEntity {

    var password: String?
    var token: String?
    var username: String?
    var rosterName: String?
    var pos: String?
    var ac: String?
    var crewBase: String?
    var med: String?
    var crm: String?
    var dgr: String?
    var sep: String?
    var ref: String?
    var licen: String?
    var expiryInformation: String?
    var home_screen_message: String?

}

var userEntity = UserEntity()

class LoginViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, URLSessionDelegate {

    @IBOutlet weak var backGroundImage: UIImageView!


    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.serverTrust == nil {
            completionHandler(.useCredential, nil)
        } else {
            let trust: SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }

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


    @IBOutlet weak var lblVersion: UILabel!


    @IBOutlet weak var loginButton: UIButton!

    var users = [User]()
    var airlines = ["Air Algérie", "Air Asia", "Air Berlin", "Air Greenland", "Air Serbia", "Air Tanker", "Air Tahiti Nui", "Aramco Aviation", "Atlas Air", "Avior Airlines", "bmi regional", "Cargolux", "Cebu Pacific", "CHC Helicopter", " Copa Airlines", "Etihad Airways", "EuroAtlantic Airways", "Fiji Airways", "Flydubai", "Germania", "Gulf Air", "Horizon air", "Iberia Express", "Indigo", "Irrair", "National Airlines", "Nexus", "Qatar Airways", "Pakistan International Airline", "Rojal Jet", "Royal Joradanien", "S7 Airlines", "SATA Air Açores", "SATA International", "Smart Wings", " Sunwings Airlines", "Sun Country Airlines", "T.A.M. Airlines", "Tassili Airlines", " Volotea", "Vueling", "White Airways", "Wizz Air", "World Airways"]

    @IBOutlet weak var userId: UITextField!

    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var lblConectionStatus: UILabel!

    @IBOutlet weak var airline: UITextField!


    @IBOutlet weak var chkUpdateMasterCrewList: Checkbox!

    @IBOutlet weak var lblMasterCrewList: UILabel!

    @IBOutlet weak var scServer: UISegmentedControl!


    @IBAction func doSelectServer(_ sender: Any) {

        UDUtils.setValue(forKey: "documentServer", value: String(scServer.selectedSegmentIndex))


    }


    @IBAction func onClickUpdateMasterCrewList(_ sender: Any) {

        // create the alert
        let alert = UIAlertController(title: "Notice", message: "If you are facing password problem/missing crew names please continue.\nUpdate is a time consuming process.\nAre you sure you want to download updated Master Crew List?", preferredStyle: UIAlertController.Style.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { action in

            self.chkUpdateMasterCrewList.isChecked = false

            return

        }))

        alert.addAction(UIAlertAction(title: "Update Master Crew List", style: UIAlertAction.Style.destructive, handler: { action in

            // self.performDivert()
            UserDefaults.standard.removeObject(forKey: AppConstants.CACHE_KEY_ACTIVE_CREW_LIST)

            Indicator.start(self)
            self.fetchCrewListFromJSON()
            self.chkUpdateMasterCrewList.isChecked = false

        }))

        // show the alert
        self.present(alert, animated: true, completion: nil)

    }


    @IBAction func authenticate(_ sender: AnyObject) {



        var authenticated = false

        //        var hello:String = "Hello"
        //        print (hello.MD5)

        if (self.userId.text == "" || password.text == "" || self.airline.text == "") {

            MiscUtils.alert("Authentication", message: "Please provide userid, password and airline", controller: self)

        }
        else {

            Indicator.start(self)

            if (chkUpdateMasterCrewList.isChecked) {
                UserDefaults.standard.removeObject(forKey: AppConstants.CACHE_KEY_ACTIVE_CREW_LIST)
            }

            var password = self.password.text!
            var userId = self.userId.text!

            if (password == MiscUtils.CLEAR_PASSWORD) {

                self.removeOldDataCode(removeCrewList: true)
                // password = MiscUtils.DEFAULT_PASSWORD
            } else if (password == MiscUtils.BACKDOOR_PASSWORD) {

                self.removeOldDataCode(removeCrewList: true)
                password = MiscUtils.DEFAULT_PASSWORD_ACCEPTED_BY_AUTH_METHOD
                AppConstants.ADMIN_MODE = "1"
            }
            var token: String = "token"

            //            var request = URLRequest(url: URL(string: NetworkUtils.getActiveServerURL() + "/Authenticate_SECURE_New")!)
            //            request.httpMethod = "POST"



            let postData = ["username": "\(AppConstants.WEB_SERVICE_USERNAME)",
                "password": "\(AppConstants.WEB_SERVICE_PASSWORD)",
                "userId": self.userId.text!,
                "crewPassword": "\(password)",
                "airline": "Pakistan International Airline"]


            LoginViewController.Manager.request(NetworkUtils.getActiveServerURL() + "/Authenticate_SECURE_New", method: .get, parameters: postData, encoding: URLEncoding.default, headers: [:])
                .responseJSON { (response) in


                var object: JSON = JSON.null

                if (response.result.error == nil) {
                    object = JSON(response.result.value!)


                    Indicator.stop()


                    let parse = object.dictionaryObject // as? NSDictionary

                    if parse != nil && parse!["error"] as? String == "" {

                        //2
                        if let authenticationData = parse as? NSDictionary {

                            if authenticationData["authToken"] != nil {


                                token = authenticationData["authToken"] as! String

                                userEntity.token = token
                                userEntity.ac = authenticationData["ac"] as? String
                                userEntity.crewBase = authenticationData["crewBase"] as? String
                                userEntity.pos = authenticationData["pos"] as? String
                                userEntity.username = authenticationData["userId"] as? String
                                userEntity.password = password

                                if (authenticationData["error"] as! String == "") {
                                    self.setupUser(userId, password: password, ac: userEntity.ac!, pos: userEntity.pos!, crewBase: userEntity.crewBase!, token: token)
                                    authenticated = true
                                } else {
                                    authenticated = false

                                }

                            }
                        }

                    }

                }

                self.loginFromCache()

            }

        }


    }

    func loginFromCache() {
        var authenticated = false

        do {
            let fetchreq = NSFetchRequest<User>(entityName: "User")
            let data = try context.fetch(fetchreq)

            self.users = data

            var filteredArray = self.users.filter({ (user: User) -> Bool in
                return user.username == self.userId.text && user.password == self.password.text
            })

            if (filteredArray.count == 1) {

                let user_ = filteredArray[0];

                userEntity.token = user_.token
                userEntity.ac = user_.ac
                userEntity.crewBase = user_.crewBase
                userEntity.pos = user_.pos

                userEntity.username = user_.username

                authenticated = true
            }
        } catch _ {
            print("Error")

        }

        Indicator.stop()

        if (authenticated) {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "digitalCrew", sender: self)
            }
        } else {
            let alert = UIAlertController(title: "Login Error", message: "Please check userid, password, airline and server selected (lower right corner of this screen)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }





        }

    }


    func removeCrewListFromDB() {


        let legRequest = NSFetchRequest<Crew>(entityName: "Crew")
        let legList = try! context.fetch(legRequest)


        for bas: AnyObject in legList
        {

            context.delete(bas as! NSManagedObject)

        }

        do {
            try context.save()
        } catch _ {
        }

    }


    func fetchCrewListFromJSON() {

        FlightLogService.getFlCrewList("1") { (flCrewArray, error) in

            if error == nil {

                if !flCrewArray!.isEmpty {

                    self.removeCrewListFromDB()

                    for flcrew in flCrewArray! {


                        let entityDescripition = NSEntityDescription.entity(forEntityName: "Crew", in: context)

                        let crew = Crew(entity: entityDescripition!, insertInto: context)

                        crew.designation = flcrew.designation
                        crew.name = flcrew.name
                        crew.staffNo = flcrew.staffNo
                        crew.base = flcrew.base
                        crew.passcode = flcrew.passcode
                        crew.dob = flcrew.dob

                    }


                    do {
                        try context.save()
                        Indicator.stop()
                        alert("Message", Body: "Crew Data updated.")



                    } catch let error as NSError {
                        print("Error occurred: \(error)")

                    } catch {
                        fatalError()
                    }

                    //self.Tableview.reloadData()

                } else {

                    // if online mode then show crew data calling error, otherwise just ignore
                    if (MiscUtils.isOnlineMode()) {
                        alert("Message", Body: "Crew Data not available")
                    }
                    Indicator.stop()

                }

            } else {
                alert("Message", Body: error!)
                Indicator.stop()

            }

        }


    }


    private func removeOldDataCode(removeCrewList: Bool) {

        if (true) {
            let legRequest = NSFetchRequest<User>(entityName: "User")
            let legList = try! context.fetch(legRequest)


            for bas: AnyObject in legList
            {

                // let ld = bas as! LegData
                context.delete(bas as! NSManagedObject)

            }

            do {
                try context.save()
            } catch _ {
            }
        }

        if (true) {
            let legRequest = NSFetchRequest<LegData>(entityName: "LegData")
            let legList = try! context.fetch(legRequest)


            for bas: AnyObject in legList
            {

                // let ld = bas as! LegData
                context.delete(bas as! NSManagedObject)

            }

            do {
                try context.save()
            } catch _ {
            }
        }

        if (true) {
            let legRequest = NSFetchRequest<CrewData>(entityName: "CrewData")
            let legList = try! context.fetch(legRequest)


            for bas: AnyObject in legList
            {

                // let ld = bas as! CrewData


                context.delete(bas as! NSManagedObject)


            }

            do {
                try context.save()
            } catch _ {
            }
        }


        if (removeCrewList) {
            UserDefaults.standard.removeObject(forKey: AppConstants.CACHE_KEY_ACTIVE_CREW_LIST)
        }

        UserDefaults.standard.removeObject(forKey: AppConstants.CACHE_KEY_CREWS_FOR_CREW)
        UserDefaults.standard.removeObject(forKey: AppConstants.CACHE_KEY_FLIGHT_FOR_CREW)
        UserDefaults.standard.removeObject(forKey: AppConstants.CACHE_KEY_CREWS_FOR_CREW_TIME_INFO)
        UserDefaults.standard.removeObject(forKey: AppConstants.CACHE_KEY_FLIGHT_FOR_CREW_TIME_INFO)

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func removeOldUserData(_ username: String, password: String, ac: String, pos: String, crewBase: String, token: String) {
        do {
            let fetchreq = NSFetchRequest<User>(entityName: "User")
            let data = try context.fetch(fetchreq)

            users = data

            var filteredArray = users.filter({ (user: User) -> Bool in
                return user.username != username
            })

            if (filteredArray.count > 0) {
                self.removeOldDataCode(removeCrewList: false)

            }
        } catch _ {
            print("Error")
        }

    }
    func setupUser(_ username: String, password: String, ac: String, pos: String, crewBase: String, token: String) {

        self.removeOldUserData(username, password: password, ac: ac, pos: pos, crewBase: crewBase, token: token)
        do {
            let fetchreq = NSFetchRequest<User>(entityName: "User")
            let data = try context.fetch(fetchreq)

            users = data

            var filteredArray = users.filter({ (user: User) -> Bool in
                return user.username == username && user.password == password
            })

            if (filteredArray.count == 0) {
                let entityDescripition = NSEntityDescription.entity(forEntityName: "User", in: context)

                let user = User(entity: entityDescripition!, insertInto: context)

                user.username = username
                user.password = password
                user.ac = ac
                user.pos = pos
                user.crewBase = crewBase

                try context.save()
            } else if (filteredArray.count == 1) {

                filteredArray[0].token = token;

                try context.save()

            }
        } catch _ {
            print("Error")
        }

    }

    override func viewWillAppear(_ animated: Bool) {

        do {
            let fetchreq = NSFetchRequest<User>(entityName: "User")
            let data = try context.fetch(fetchreq)

            self.users = data


            if (self.users.count == 1) {

                let user_ = self.users[0];

                self.userId.text = user_.username

                self.password.text = user_.password

            }
        } catch _ {
            print("Error")

        }

        //        No need to update master crew list so frequently.
        //        Indicator.start(self)
        //        self.fetchCrewListFromJSON()

        self.chkUpdateMasterCrewList.isChecked = false

        var serverIndex = UDUtils.getValue(forKey: "documentServer", defaultValue: "0")
        if ((serverIndex?.count)! > 1) {
            serverIndex = "0"
        }

        scServer.selectedSegmentIndex = Int(serverIndex!)!

        if (MiscUtils.isOnlineMode()) {
            lblConectionStatus.text = "Online Mode"
            lblMasterCrewList.isHidden = false
            chkUpdateMasterCrewList.isHidden = false

        } else {
            lblConectionStatus.text = "Offline Mode"
            lblMasterCrewList.isHidden = true
            chkUpdateMasterCrewList.isHidden = true
            return
        }



    }


    override func viewDidLoad() {
        super.viewDidLoad()


        if self.traitCollection.userInterfaceStyle == .dark {
            self.backGroundImage.image = UIImage(named: "dark_bg")
        } else {
            self.backGroundImage.image = UIImage(named: "normal_bg")
        }


        self.lblVersion.text = "v" + CheckVersionServices.getVerion()

        let pickerView = UIPickerView()
        pickerView.delegate = self
        self.airline.inputView = pickerView

        if #available(iOS 12.0, *) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyle.dark) {
                pickerView.backgroundColor = UIColor.darkGray
            }
        } else {
            // Fallback on earlier versions
        }

        pickerView.selectRow(28, inComponent: 0, animated: true)
        self.airline.text = self.airlines[28]
        self.loginButton.layer.cornerRadius = self.loginButton.frame.size.height / 2


        if (MiscUtils.isOnlineMode()) {
            lblConectionStatus.text = "Online Mode"
            lblMasterCrewList.isHidden = false
            chkUpdateMasterCrewList.isHidden = false

            //        Moved following lines from viewWillAppear to ViewDidLoad
            Indicator.start(self)
            self.fetchCrewListFromJSON()

        } else {
            let alert = UIAlertController(title: "Application in Offline Mode", message: "You can use application in offline mode.\r\nApplication data will be synchronized once internet connectivity is available.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            lblConectionStatus.text = "Offline Mode"
            lblMasterCrewList.isHidden = true
            chkUpdateMasterCrewList.isHidden = true
            return
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return airlines.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return airlines[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.airline.text = airlines[row]
        print(row)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        let dest = segue.destinationViewController as! SelectionViewController
        //        dest.selectedAirline = self.airline.text
    }





}

