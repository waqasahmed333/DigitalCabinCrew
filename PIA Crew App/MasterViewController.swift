//
//  MasterViewController.swift
//  PIA Crew App
//
//  Created by Admin on 05/06/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit
import SwiftyJSON

var circular_keys = ["Chief_Of_Flight_Operations",
                     "Chief_Pilot_Crew_Training",
                     "Chief_Pilot_Standard_Inspection",
                     "Chief_Pilot_Technical",
                     "Chief_Pilot_Scheduling",
                     "Flight_Operations_Quality_Assurance",
                     "Chief_Pilot_Safety",
                     "General_Manager_Central_Control",
                     "Chief_Pilot_North",
                     "Deputy_Chief_Pilot_DFO_Sectt",
                     "Dy_Chief_Pilot_A-320",
                     "Dy_Chief_Pilot_ATR",
                     "DY_Chief_Pilot_B-777",
                     
                     ]

class MasterViewController: UITableViewController {
    
    @IBOutlet var subsectionTable: UITableView!
    
    //type:document
    var documents = [String:[DocumentItem]]()
    

    
    override func viewWillAppear(_ animated: Bool) {
        updateUIElements()
        
    }
    
    
  
    private func updateUIElements() {
        
        self.subsectionTable.reloadData()
        
        let badgeCount = DocNotificationUtils.getUnreadCircularsOrSectionBadgeCount()
        
        self.parent?.tabBarItem.badgeValue = (badgeCount == 0) ? nil : "\(badgeCount)"
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        for k in circular_keys {
            if self.documents[k] == nil{
                self.documents[k] = []
            }
        }
        
        self.updateUIElements()
        //        self.performSegue(withIdentifier: "detail", sender: 0)
        
        // if the searchbox does not automatically disappear after navigating to other controller
        self.definesPresentationContext = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Array(circular_keys).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! MasterTableViewCell
        cell.subsectionTitle.text="\(Array(circular_keys)[(indexPath as NSIndexPath).row].replacingOccurrences(of: "_", with: " "))" + "..."
        
        cell.subsectionTitle.text="\(Array(circular_keys)[(indexPath as NSIndexPath).row].replacingOccurrences(of: "_", with: " "))"
//        do not show the count of documents in the section
//            +  "(\(self.getDocumentCount(section: "Circular/" + circular_keys[indexPath.row])))"
        
        cell.subsectionButtonView.layer.cornerRadius = 10;
        cell.subsectionButtonView.layer.masksToBounds = true;
        
        //cell.backgroundColor=UIColor.clear
        
        return cell
    }
    
    
//    private func getDocumentCount(section:String!) -> String {
//
//
//        if let data = UserDefaults.standard.object(forKey: "JSON-" + section) as AnyObject? {
//            let object = JSON(data)
//
//            let docCount =  object["DocumentList"].arrayValue.count
//            return "\(docCount)"
//        }
//        
//        return ">>>"
//    }

    
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        
        let subCategory = circular_keys[indexPath.row]
        
        Indicator.start(self)
        DocumentServices.getDocuments("Circular/" + subCategory ) { (documentSectionArray, error) in
            
            if error == nil {
                
                if !documentSectionArray!.isEmpty {
                    
                    self.documents[subCategory] = []
                    
                    for doc in documentSectionArray![0].documents{
                        //print(doc.name)
                        self.documents[subCategory]?.append(doc)
                    }
                    
                    let cell = tableView.cellForRow(at: indexPath) as! MasterTableViewCell
                    cell.subsectionTitle.text="\(Array(circular_keys)[(indexPath as NSIndexPath).row].replacingOccurrences(of: "_", with: " "))"
//                        + "(\(self.documents[circular_keys[indexPath.row]]!.count))"
//                    cell.subsectionTitle.textColor = 
                    
                    

                    
                    
                    Indicator.stop()
                    self.performSegue(withIdentifier: "detail", sender: (indexPath as NSIndexPath).row)
                    
                    
                    //self.performSegue(withIdentifier: "detail", sender: 0)
                    
                }else{
                    
                    alert("Message", Body: "Circulars Data not available")
                    Indicator.stop()
                    
                }
                
            }else{
                alert("Message", Body: error!)
                Indicator.stop()
                
            }
            
        }
        
        
        
    }
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let index  = sender as! Int
        let subCategory = circular_keys[index]
        
        let dest = segue.destination as! DetailViewController
        
        
        
        dest.unFiletereddocuments =  self.documents[subCategory]!
        print("prepare detail view controller has -> \(dest.unFiletereddocuments.count)")
        
        
        
        
    }
    
    
}
