//
//  SelectionViewController.swift
//  PIA Crew App
//
//  Created by Admin on 25/06/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {

    var selectedAirline:String?
    
    @IBOutlet weak var flightLog: UIButton!
    @IBOutlet weak var digitalCrew: UIButton!
    @IBOutlet weak var logout: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let air = self.selectedAirline {
            self.title = "\(air)"
        }
        self.flightLog.layer.cornerRadius = self.flightLog.frame.size.height/2
         self.digitalCrew.layer.cornerRadius = self.digitalCrew.frame.size.height/2
        self.logout.layer.cornerRadius = self.logout.frame.size.height/2
   
        self.navigationItem.hidesBackButton=true
        self.navigationController?.isNavigationBarHidden=false
        let backItem = UIBarButtonItem()
        backItem.title = "Menu"
        navigationItem.backBarButtonItem = backItem
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func flightlog(_ sender: AnyObject) {
        performSegue(withIdentifier: "flightLogs", sender: nil)
    }

    @IBAction func digitalCrew(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "digitalCrew", sender: nil)
    }
    
    @IBAction func Logout(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "digitalCrew" {
            let des = segue.destination as! UITabBarController
            let cont = des.viewControllers![0] as! HomeViewController
            cont.airlineName = self.selectedAirline
        }

        
    
    
    }

}
