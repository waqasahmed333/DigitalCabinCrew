//
//  LFEOEViewController.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 24/11/2021.
//  Copyright © 2021 Naveed Azhar. All rights reserved.
//

import UIKit


var totalLFEdocuments = [LFEDocumentItem]()
var totalUnFileteredLFEdocuments = [LFEDocumentItem]()

class LFEOEViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Indicator.start(self)
        var ac = userEntity.ac!

        ac = MiscUtils.getACTypeFromIATACode(acType: ac)
        
        ac = "Manual/" + ac
        
        DocumentServices.getLFEDocuments(ac.trimmingCharacters(in: CharacterSet.whitespaces)) { (documentSectionArray, error) in

            if error == nil {
                
                if !documentSectionArray!.isEmpty {
                    
                    for doc in  documentSectionArray![0].documents{
                       
                        //if !PresistanceStorage.isDeleted(doc.docID){
                        // also include deleted documents
                        //{
                            totalUnFileteredLFEdocuments.append(doc)
                        //}

                    }
                    
                    totalLFEdocuments = totalUnFileteredLFEdocuments;
                    
                    
                    Indicator.stop()
                }else{
                    
                    alert("Message", Body: "Manuals Data not available")
                    Indicator.stop()
                    
                }
                
            }else{
                alert("Message", Body: error!)
                Indicator.stop()
                
            }
            
        }

    }
    
    @IBAction func selectLFE(_ sender: Any) {
        
        MiscUtils.alert("No data", message: "No date", controller: self)
        exit(0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showOEList") {
            totalLFEdocuments = totalUnFileteredLFEdocuments
            sharedDocumentsLFE = totalLFEdocuments
            LFEFilter = ["EO"]
        }
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
