//
//  LFESearchViewController.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 28/11/2021.
//  Copyright © 2021 Naveed Azhar. All rights reserved.
//

import UIKit


var sharedDocumentsLFE = [LFEDocumentItem]()
var selectedLFETab = 0
var LFEFilter = ["PilotNotes"]

class LFESearchViewController: UIViewController {

    
    @IBOutlet weak var btnPilotNotes: UIButton!
    
    @IBOutlet weak var btnASRs: UIButton!
    
    @IBOutlet weak var btnIncidentsAccidents: UIButton!
    
    @IBOutlet weak var btnLibrary: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.btnSearch.layer.cornerRadius =  self.btnSearch.frame.size.height/2
        self.btnLibrary.layer.cornerRadius =  self.btnLibrary.frame.size.height/2
        self.btnASRs.layer.cornerRadius =  self.btnASRs.frame.size.height/2
        self.btnPilotNotes.layer.cornerRadius =  self.btnPilotNotes.frame.size.height/2
        self.btnIncidentsAccidents.layer.cornerRadius =  self.btnIncidentsAccidents.frame.size.height/2
        
        // Do any additional setup after loading the view.
        
        
    }
    

    
    
    @IBAction func doSearch(sender: Any) {
        
        guard let button = sender as? UIButton else {
            return
        }

        selectedLFETab = button.tag
        
        if ( selectedLFETab == 0 ) {
            LFEFilter = ["PilotNotes"]
        } else if ( selectedLFETab == 1 ) {
            LFEFilter  = ["ASRs"]
        } else if ( selectedLFETab == 2 ) {
            LFEFilter  = ["Incident"]
        } else if ( selectedLFETab == 3 ) {
            LFEFilter  = ["PilotNotes","ASRs","Incident"]
        }
        
        print("Total documents \(totalLFEdocuments.count)")
        
        if let searchText = self.searchBar.text, !searchText.isEmpty {
            totalLFEdocuments =  totalUnFileteredLFEdocuments.filter { docItem in
                return docItem.subject.lowercased().contains(searchText.lowercased())
            }
            sharedDocumentsLFE = totalLFEdocuments
        } else {
            totalLFEdocuments = totalUnFileteredLFEdocuments
            sharedDocumentsLFE = totalLFEdocuments
        }
        
        print("Filter documents \(totalLFEdocuments.count)")
        
        
        
        performSegue(withIdentifier: "showLFEResults", sender:  self)
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
