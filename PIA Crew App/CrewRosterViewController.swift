//
//  CrewRosterViewController.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 07/06/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData
import Reachability


class CrewRosterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var duties = [CrewDuty]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 00, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth/17, height: screenHeight/1)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.showsHorizontalScrollIndicator=false
        collectionView.showsVerticalScrollIndicator=false
        self.collectionView.bounces=false

        Indicator.start(self)
        RosterServices.getCrewRosters(userEntity.username!) { (crewRosterArray, error) in
            
            if error == nil {
                
                if !crewRosterArray!.isEmpty {
                    
                    for doc in  crewRosterArray![0].duties{
                        
                        self.duties.append(doc)
                    
                    }
                    
                    
                    
                    self.collectionView.reloadData()
                    
                    Indicator.stop()
                }else{
                    
                    alert("Message", Body: "Crew Roster Data not available")
                    Indicator.stop()
                    
                }
                
            }else{
                alert("Message", Body: error!)
                Indicator.stop()
                
            }
            
        }
        
    }
    
    
    
    func entitySorter (_ entity1:FlightQueryLeg, entity2:FlightQueryLeg) -> Bool {
        return  entity1.date! + entity1.std! <  entity2.date! + entity2.std!
    }
    
    
    
    func loadData() {
        
        let actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0, width: 50, height: 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.style = UIActivityIndicatorView.Style.gray
        actInd.backgroundColor = UIColor.blue
        view.addSubview(actInd)
        actInd.startAnimating()
        sleep(5000)
        actInd.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.duties.count;
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CrewRosterCollectionViewCell
        cell.backgroundColor = UIColor.white
        
        cell.dateInfo.layer.borderColor = UIColor.white.cgColor;
        cell.dateInfo.layer.borderWidth = 3.0;
        
        cell.dateInfo.text = self.duties[(indexPath as NSIndexPath).row].date
        
        let cDuty = self.duties[(indexPath as NSIndexPath).row]
        
//        if (cDuty.type == "G") {
//        cell.dutyInfo.text = "\(cDuty.duty)\r\n\(cDuty.std)\r\n\(cDuty.sta)\r\n"
//        } else {
//        cell.dutyInfo.text = "PK\(cDuty.duty)\r\n(\(cDuty.ac))\r\n\(cDuty.std)\r\n\(cDuty.dep)-\(cDuty.arr)\r\n\(cDuty.sta)\r\n"
//        }
        
        
        cell.dutyInfo.text = cDuty.dutyDetails
        cell.dutyInfo.sizeToFit()
        
        cell.dutyInfo.text = cell.dutyInfo.text?.replacingOccurrences(of: "0000\r\n0000", with: "")

        if #available(iOS 12.0, *) {
            cell.backgroundColor = MiscUtils.getRowBGColor(indexPathRow: indexPath.row, userInterfaceStyle: traitCollection.userInterfaceStyle)
        } else {
            // Fallback on earlier versions
        }
        
        return cell
    }
    

    


}
