//
//  HOTACViewController.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 30/04/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit
//import MRProgress
//import SpringIndicator

class HOTACViewController: UIViewController, UISearchResultsUpdating{
    
    
    @IBOutlet weak var tableViewDetails: UITableView!
    
    var documentSection:DocumentSection?
    

    var documents = [DocumentItem]()
    var unFiletereddocuments = [DocumentItem]()
    
///    var progressView:MRProgressOverlayView!
    
    var badgeCount :Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.updateUIElements()
    }
    
    private func updateUIElements() {
        
        self.tableViewDetails.reloadData()

        badgeCount = 0
        
        for doc in self.unFiletereddocuments {
            if  (!doc.name.isFileAvailable()) {
                badgeCount += 1
            }
        }
        self.tabBarItem.badgeValue = (badgeCount == 0) ? nil : "\(badgeCount)"
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarItem.badgeValue = "4"
            
        MiscUtils.formatTableView(self.tableViewDetails)
        
        self.edgesForExtendedLayout = UIRectEdge()
        self.tableViewDetails.tableFooterView = UIView()
    
        
        Indicator.start(self)
        var section = userEntity.ac!

        
        section = "Manual/HOTAC"
        
        DocumentServices.getDocuments(section.trimmingCharacters(in: CharacterSet.whitespaces)) { (documentSectionArray, error) in

            if error == nil {
                
                if !documentSectionArray!.isEmpty {
                    
                    for doc in  documentSectionArray![0].documents{
                       
                        //if !PresistanceStorage.isDeleted(doc.docID){
                        // also include deleted documents
                        //{
                            self.unFiletereddocuments.append(doc)
                        //}

                    }
                    
                    self.documents = self.unFiletereddocuments;
                    
                    self.updateUIElements()
                    
                    Indicator.stop()
                }else{
                    
                    alert("Message", Body: "HOTAC Data not available")
                    Indicator.stop()
                    
                }
                
            }else{
                alert("Message", Body: error!)
                Indicator.stop()
                
            }
            
        }
        
        tableViewDetails.estimatedRowHeight = 44.0
        tableViewDetails.rowHeight = UITableView.automaticDimension
        
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableViewDetails.tableHeaderView = searchController.searchBar

        self.navigationController?.isNavigationBarHidden = false

    }
    
    let searchController = UISearchController(searchResultsController: nil)

    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            self.documents =  self.unFiletereddocuments.filter { docItem in
                return docItem.name.lowercased().contains(searchText.lowercased())
            }
            
        } else {
            self.documents = unFiletereddocuments
        }
        self.updateUIElements()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}


extension HOTACViewController : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

            
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell") as! HOTACDocumentTableViewCell
        cell.fileName.text="\(self.documents[(indexPath as NSIndexPath).row].subject!.replacingOccurrences(of: ".", with: " ").replacingOccurrences(of: "_", with: " "))"
        cell.date.text="\(self.documents[(indexPath as NSIndexPath).row].createDate!)"
        cell.group.text="\(self.documents[(indexPath as NSIndexPath).row].type!)"
        cell.backgroundColor=UIColor.clear
        cell.delete.layer.cornerRadius = 0.5 * cell.delete.frame.size.height/2
        cell.download.layer.cornerRadius = 0.5 * cell.download.frame.size.height/2
        
        cell.delete.addTarget(self, action: #selector(HOTACViewController.DeleteDocumentUsingFileManager(_:)), for: .touchUpInside)
        cell.delete.tag = (indexPath as NSIndexPath).row
        
        
        if self.documents[(indexPath as NSIndexPath).row].name.isFileAvailable() {
            cell.download.setTitle("Open", for: UIControl.State())
            cell.download.addTarget(self, action: #selector(HOTACViewController.open(_:)), for: .touchUpInside)
            cell.download.tag = (indexPath as NSIndexPath).row
            cell.delete.setTitle("Delete", for: UIControl.State())
            cell.delete.isEnabled = true
            
        }else{
            cell.download.setTitle("Download", for: UIControl.State())
            cell.download.addTarget(self, action: #selector(HOTACViewController.download(_:)), for: .touchUpInside)
            cell.download.tag = (indexPath as NSIndexPath).row
            cell.delete.setTitle("        ", for: UIControl.State())
            cell.delete.backgroundColor = UIColor.clear
            cell.delete.isEnabled = false
        }
        cell.download.addTarget(self, action: #selector(HOTACViewController.download(_:)), for: .touchUpInside)
        
        if #available(iOS 12.0, *) {
            cell.backgroundColor = MiscUtils.getRowBGColor(indexPathRow: indexPath.row, userInterfaceStyle: traitCollection.userInterfaceStyle)
        } else {
            // Fallback on earlier versions
        }
        
        return cell

        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return self.documents.count
    }
    
 
    @objc func download(_ sender:UIButton) {
        
        let cell = self.tableViewDetails.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! HOTACDocumentTableViewCell

        
        if cell.download.currentTitle == "Download" {
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let getImagePath = documentsURL.appendingPathComponent(self.documents[sender.tag].name)
            print("Deleting file" + getImagePath.absoluteString)
            
            do {
                try FileManager.default.removeItem(at: getImagePath)
            } catch {
//                print("Could not remove file: \(error)")
            }
            
            DownloadServices.downloadFile(self.documents[sender.tag].url) { (percentage, error) in
                
                if error == nil {
                    
                    
                    if percentage == 1 {
                        cell.download.setTitle("Open", for: UIControl.State())
                        cell.download.addTarget(self, action: #selector(HOTACViewController.open(_:)), for: .touchUpInside)
                        cell.download.tag = sender.tag
                        cell.download.isEnabled=true
                        cell.delete.setTitle("Delete", for: UIControl.State())
                        cell.delete.isEnabled = true
                        self.tableViewDetails.isScrollEnabled = true
                        
                    }else{
                        //print("per=\(percentage)")
                        cell.download.tag = sender.tag
                        cell.download.setTitle( String(round(100 * (percentage ?? 0))) + "%", for: UIControl.State())
                        print(cell.fileName.text! + "\(percentage)" )
                        cell.download.isEnabled=false
                        self.tableViewDetails.isScrollEnabled = false

                    }
                    
                }else{
                    
                    alert("Message", Body: "Suggestion:Download one file at a time.\r\n" + error!)
                }
                
            }
        }
        
        
    }
    
    @objc func open(_ sender:UIButton){
        
        if let name = self.documents[sender.tag].name {

            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let getImagePath = documentsURL.appendingPathComponent(name)
            let filePath = getImagePath.path
            
            if FileManager.default.fileExists(atPath: filePath) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "pdf") as! webViewController
                vc.fileName = self.documents[sender.tag].name
                self.present(vc, animated: true, completion: nil)

            }
        }
    }
    
    @objc func DeleteDocumentUsingFileManager(_ sender:UIButton) {
        
        
        // create the alert
        let alert = UIAlertController(title: "Notice", message: "Are you sure you want to delete the document?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { action in
            
            return
            
        }))
        
        alert.addAction(UIAlertAction(title: "Confirm Deletion", style: UIAlertAction.Style.destructive, handler: { action in
            
            
            let deletedIndex = sender.tag
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let getImagePath = documentsURL.appendingPathComponent(self.documents[deletedIndex].name)
            print("getImagePath" + getImagePath.absoluteString)
            
            //let fileManager = FileManager.default
            //let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
            
            do {
                try FileManager.default.removeItem(at: getImagePath)
            } catch {
//                print("Could not remove file: \(error)")
            }
            
            //        PresistanceStorage.saveDeletedID(self.documents[deletedIndex].docID, key: self.documents[deletedIndex].docID)
            //        self.documents.remove(at: deletedIndex)
            
            self.updateUIElements()

        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        

    }
    
    @IBAction func downloadAll(_ sender: Any) {
        
        
        // create the alert
        let alertC = UIAlertController(title: "Notice", message: "Please make sure you are connected with high speed internet. Are you sure you want to download all the documents?", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alertC.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { action in
            
            return
            
        }))
        
        alertC.addAction(UIAlertAction(title: "Confirm", style: UIAlertAction.Style.destructive, handler: { action in
            
            var urls:[String] = []
            
            for doc in self.documents {
                urls.append(doc.url)
            }
            
            DownloadServices.downloadMultipleFiles(urls) { (index, percentage, error) in
                
                if error == nil {
                    

                    let cell : HOTACDocumentTableViewCell? = self.tableViewDetails.cellForRow(at: IndexPath(row: index, section: 0)) as? HOTACDocumentTableViewCell
                    
//                    let cell : HOTACDocumentTableViewCell? = self.tableViewDetails.cellForRow(at: IndexPath(row: index, section: 0)) as? HOTACDocumentTableViewCell
                    
                    
                    
                    if ( cell != nil ) {
                        if percentage == 1 {
                            cell!.download.setTitle("Open", for: UIControl.State())
                            cell!.download.addTarget(self, action: #selector(LFEDocumentViewController.open(_:)), for: .touchUpInside)
                            
                            cell!.download.isEnabled=true
                            cell!.delete.setTitle("Delete", for: UIControl.State())
                            cell!.delete.isEnabled = true
                            self.tableViewDetails.isScrollEnabled = true
//                            self.tableViewDetails.reloadData()
                            
                        }else{
                            
                            cell!.download.setTitle( String(round(100 * (percentage ?? 0))) + "%", for: UIControl.State())
                            cell!.download.isEnabled=false
//                            self.tableViewDetails.isScrollEnabled = false
//                            self.tableViewDetails.reloadData()

                            
                        }
                        
                    }
                }else{
                    
//                    if (!error!.contains("same name")) {
//                        alert("Message", Body: "Suggestion:Download one file at a time.\r\n" + error!)
//                    }
                }
                
            }
            
        }))
        
        // show the alert
        self.present(alertC, animated: true, completion: nil)
        
        
    }
    

    
}
