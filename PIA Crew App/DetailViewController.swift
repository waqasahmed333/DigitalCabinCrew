//
//  DetailViewController.swift
//  PIA Crew App
//
//  Created by Admin on 05/06/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit
import Alamofire

class DetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchResultsUpdating  {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.serverTrust == nil {
            completionHandler(.useCredential, nil)
        } else {
            let trust: SecTrust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }
    
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
    
    
    
    
    @IBOutlet weak var table: UITableView!
    
    var documents = [DocumentItem]()
    var unFiletereddocuments = [DocumentItem]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.updateUIElements()
    }
    
    var badgeCount:Int = 0
    
    private func updateUIElements() {
        
        self.table.reloadData()
        
        //        badgeCount = 0
        //
        //        for doc in self.unFiletereddocuments {
        //            if  (!doc.name.isFileAvailable()) {
        //                badgeCount += 1
        //            }
        //        }
        //        self.parent?.tabBarItem.badgeValue = (badgeCount == 0) ? nil : "\(badgeCount)"
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        var tempArr = [DocumentItem]()
        
        for i in 0 ..< self.unFiletereddocuments.count {
            
            //if !PresistanceStorage.isDeleted(self.documents[i].docID){
            // also include deleted documents
            //{
            tempArr.append(self.unFiletereddocuments[i])
            //}
        }
        
        self.documents = tempArr
        print("detail view controller has -> \(self.documents.count)")
        
        tempArr=[]
        
        table.estimatedRowHeight = 44.0
        table.rowHeight = UITableView.automaticDimension
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        table.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.placeholder = "Search in \(self.unFiletereddocuments.count) documents"
        searchController.searchBar.sizeToFit()
        
        //        searchController.searchBar.showsScopeBar = false
        //
        //        searchController.searchBar.scopeButtonTitles = ["All"]
        //
        //        let date = Date()
        //        let format = DateFormatter()
        //        format.dateFormat = "yyyy"
        //
        //
        //        for y in 0...5 {
        //            var temp_date = Calendar.current.date(byAdding: .year, value: y * -1, to: date)
        //            let formattedDate = format.string(from: temp_date!)
        //            searchController.searchBar.scopeButtonTitles?.append(formattedDate)
        //        }
        
        // if the searchbox does not automatically disappear after navigating to other controller
        self.definesPresentationContext = true
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            self.documents =  self.unFiletereddocuments.filter { docItem in
                return docItem.subject.lowercased().contains(searchText.lowercased())
            }
            
        } else {
            self.documents = unFiletereddocuments
        }
        updateUIElements()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DetailTableViewCell
        cell.subject.text="\(self.documents[(indexPath as NSIndexPath).row].subject!.replacingOccurrences(of: ".", with: " ").replacingOccurrences(of: "_", with: " ")) (\(self.documents[(indexPath as NSIndexPath).row].year!))"
        cell.createdDate.text="\(self.documents[(indexPath as NSIndexPath).row].createDate!)"
        cell.type.text="\(self.documents[(indexPath as NSIndexPath).row].type!)"
        
        
        
        cell.delete.addTarget(self, action: #selector(DetailViewController.DeleteDocumentUsingFileManager(_:)), for: .touchUpInside)
        cell.delete.tag = (indexPath as NSIndexPath).row
        
        cell.delete.layer.cornerRadius = 0.5 * cell.delete.frame.size.height/2
        cell.download.layer.cornerRadius = 0.5 * cell.download.frame.size.height/2
        
        if self.documents[(indexPath as NSIndexPath).row].name.isFileAvailable() {
            
            cell.download.removeTarget(self, action: nil, for: .touchUpInside)
            if ( self.documents[(indexPath as NSIndexPath).row].name.isAcknowledgementFileAvailable() || StringUtils.getDateFromString(cell.createdDate.text!, dateFormat: "dd/MM/yyyy")! < Calendar.current.date(byAdding: .day, value: -60, to: Date())!     ) {
                cell.download.setTitle("Open", for: UIControl.State())
                cell.download.addTarget(self, action: #selector(DetailViewController.open(_:)), for: .touchUpInside)
            } else {
                cell.download.setTitle("Ack/Open", for: UIControl.State())
                cell.download.addTarget(self, action: #selector(DetailViewController.ack_open(_:)), for: .touchUpInside)
                
            }
            cell.download.tag = (indexPath as NSIndexPath).row
            cell.delete.setTitle("Delete", for: UIControl.State())
            cell.delete.isEnabled = true
            
        }else{
            cell.download.setTitle("Download", for: UIControl.State())
            cell.download.addTarget(self, action: #selector(DetailViewController.download(_:)), for: .touchUpInside)
            cell.download.tag = (indexPath as NSIndexPath).row
            cell.delete.setTitle("        ", for: UIControl.State())
            cell.delete.backgroundColor = UIColor.clear
            cell.delete.isEnabled = false
            
        }
        cell.download.addTarget(self, action: #selector(DetailViewController.download(_:)), for: .touchUpInside)
        
        if #available(iOS 12.0, *) {
            cell.backgroundColor = MiscUtils.getRowBGColor(indexPathRow: indexPath.row, userInterfaceStyle: traitCollection.userInterfaceStyle)
        } else {
            // Fallback on earlier versions
        }
        
        
        return cell
    }
    
    @objc private func download(_ sender:UIButton) {
        
        let cell = self.table.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! DetailTableViewCell
        
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
                        
                        cell.download.removeTarget(self, action: nil, for: .touchUpInside)
                        
                        if (getImagePath.absoluteString.isAcknowledgementFileAvailable() || StringUtils.getDateFromString(cell.createdDate.text!, dateFormat: "dd/MM/yyyy")! < Calendar.current.date(byAdding: .day, value: -60, to: Date())!  ) {
                            cell.download.setTitle("Open", for: UIControl.State())
                            cell.download.addTarget(self, action: #selector(DetailViewController.open(_:)), for: .touchUpInside)
                        } else {
                            cell.download.setTitle("Ack/Open", for: UIControl.State())
                            cell.download.addTarget(self, action: #selector(DetailViewController.ack_open(_:)), for: .touchUpInside)
                        }
                        
                        
                        cell.download.tag = sender.tag
                        cell.download.isEnabled=true
                        cell.delete.setTitle("Delete", for: UIControl.State())
                        cell.delete.isEnabled = true
                        
                    }else{
                        
                        cell.download.tag = sender.tag
                        cell.download.setTitle( String(round(100 * (percentage ?? 0))) + "%", for: UIControl.State())
                        cell.download.isEnabled=false
                        
                        
                    }
                    
                }else{
                    
                    alert("Message", Body: "Suggestion:Download one file at a time.\r\n" + error!)
                }
                
            }
        }
        
        
    }
    
    @objc private func open(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "pdf") as! webViewController
        vc.fileName = self.documents[sender.tag].name
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc private func ack_open(_ sender:UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "pdf") as! webViewController
        vc.fileName = self.documents[sender.tag].name
        
        
        
        let alert = UIAlertController(title: "Notice", message: "System is being acknowledged that you have opened and read the document.", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { action in
            
            
            
            let postData = ["pno":userEntity.username!,
                            "subject":"\(self.documents[sender.tag].subject!)",
                            "documntId":"\(self.documents[sender.tag].docID!)",
                            "sentDateTime" : "\(self.documents[sender.tag].createDate!)",
                            "token" : "1"]
            
            
            DetailViewController.Manager.request(    "https://crewserver1.piac.com.pk/FlightLogService/JSON.asmx/InsertReadAcknowledgement", method: .get, parameters:  postData,encoding: URLEncoding.default , headers: [:] )
                .response { (response) in
                    
                    var responseText = NSString(data: response.data!, encoding: String.Encoding.utf8.rawValue)! as String
                    
                    if ( responseText == "success") {
                        vc.fileName!.createAcknowledgementFile()
                    }
                    
                }
            
            
            
            self.present(vc, animated: true, completion: nil)
            
            
        }))
        
        
        if ( MiscUtils.isOnlineMode()) {
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            self.present(vc, animated: true, completion: nil)
            
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
                //            print("Could not remove file: \(error)")
            }
            
            
            //        PresistanceStorage.saveDeletedID(self.documents[deletedIndex].docID, key: self.documents[deletedIndex].docID)
            //       self.documents.remove(at: deletedIndex)
            
            
            
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
                    

                    let cell : DetailTableViewCell? = self.table.cellForRow(at: IndexPath(row: index, section: 0)) as? DetailTableViewCell
                    
//                    let cell : ManualsDocumentTableViewCell? = self.tableViewDetails.cellForRow(at: IndexPath(row: index, section: 0)) as? ManualsDocumentTableViewCell
                    
                    
                    
                    if ( cell != nil ) {
                        if percentage == 1 {
                            cell!.download.setTitle("Open", for: UIControl.State())
                            cell!.download.addTarget(self, action: #selector(LFEDocumentViewController.open(_:)), for: .touchUpInside)
                            
                            cell!.download.isEnabled=true
                            cell!.delete.setTitle("Delete", for: UIControl.State())
                            cell!.delete.isEnabled = true
                            self.table.isScrollEnabled = true
//                            self.table.reloadData()
                            
                        }else{
                            
                            cell!.download.setTitle( String(round(100 * (percentage ?? 0))) + "%", for: UIControl.State())
                            cell!.download.isEnabled=false
//                            self.table.isScrollEnabled = false
//                            self.table.reloadData()

                            
                        }
                        
                    }
                }else{
                    
                    if (!error!.contains("same name")) {
                        alert("Message", Body: "Suggestion:Download one file at a time.\r\n" + error!)
                    }
                }
                
            }
            
        }))
        
        // show the alert
        self.present(alertC, animated: true, completion: nil)
        
        
    }
    

    
    
}
