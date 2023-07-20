//
//  TableViewCell.swift
//  PIA Crew App
//
//  Created by Admin on 08/09/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData
//import SwiftValidator



class TableViewCell: UITableViewCell, UITextFieldDelegate {

    
    @IBOutlet weak var legNoLabel: UILabel!
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var date: UITextField!
    
    @IBOutlet weak var flightNo: UITextField!
    
    
    @IBOutlet weak var from: UITextField!
    
    
    @IBOutlet weak var to: UITextField!
    
    @IBOutlet weak var blockOff: UITextField!
    
    @IBOutlet weak var takeOff: UITextField!
    
    @IBOutlet weak var landing: UITextField!
    
    
    @IBOutlet weak var blocksOn: UITextField!
    
    var viewController: FlightsVC? = nil

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    


    
    @IBAction func update(_ sender: AnyObject) {
        
        do {
            let legRequest = NSFetchRequest<LegData>(entityName: "LegData")
            let data = try  context.fetch(legRequest)
            
            let flights = data
            
            let entityDescripition = NSEntityDescription.entity(forEntityName: "FlightLog", in: context)
            
            let flightLogData = FlightLog(entity: entityDescripition!, insertInto: context)
            
            flightLogData.aircraftType = ""
            flightLogData.registration = ""
            
            let dep = self.to.text!
            let date = self.date.text!
            let fltNo = self.flightNo.text!
            
//            let parentController =  self.tabBarController
            
            FlightLogEntity.sharedInstance.initIdentifiers()
            
            for i in 0...0 {
                
                
                saveLegData(flights, legNo: i, primaryDate: date, primaryFltNo: fltNo, primaryFrom: dep)
                
            }
            
            
            
            
            
            try context.save()
            
            


            
            
        } catch _ {
        }
        
        
        viewController!.dismiss(animated: true, completion: nil)

//        let alert = UIAlertController(title: "Flight Log", message: "Flight data updated successfully.", preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
    }
    
    // ValidationDelegate methods
    
    func validationSuccessful() {
        // submit the form
    }
    

    


    
    func saveLegData(_ flights:[LegData],  legNo:Int, primaryDate: String, primaryFltNo: String, primaryFrom:String) {
        
        let dep = self.from.text!
        let arr = self.to.text!
        let date = self.date.text!
        let fltNo = self.flightNo.text!
        
        FlightLogEntity.sharedInstance.flightIdentifiers[legNo].fltNo = fltNo
        FlightLogEntity.sharedInstance.flightIdentifiers[legNo].fltDate = date
        FlightLogEntity.sharedInstance.flightIdentifiers[legNo].depStation = dep
        
        
        if (dep != "" && arr != "" && date != "" && arr != "" ) {
            var filteredArray = flights.filter( { (legData: LegData) -> Bool in
                return legData.date == StringUtils.getYMDStringFromDMYString(date) && legData.fltNo == fltNo && legData.from == dep && legData.source == "IPAD"
            })
            // if local copy (filled by captain) found
            if ( filteredArray.count == 1 ) {
                let legData = filteredArray[0]
                context.delete(legData)
                
            }
            
            let entityDescripition = NSEntityDescription.entity(forEntityName: "LegData", in: context)
            
            let legData = LegData(entity: entityDescripition!, insertInto: context)
            
            
            legData.date = StringUtils.getYMDStringFromDMYString(date)
            legData.fltNo = fltNo
            legData.from = dep
            legData.source = "IPAD"
            legData.legNo = legNo as NSNumber?
            legData.primaryDate = StringUtils.getYMDStringFromDMYString(primaryDate)
            legData.primaryFltNo = primaryFltNo
            legData.primaryFrom = primaryFrom
            if ( legData.captainId == nil ) {
                legData.captainId = userEntity.username
            }
            legData.aircraft = ""
            legData.reg = ""
//            legData.reg = self.registration.text
            
            
            
//            let to = self.getUIViewByTagId(4+legNo*13) as! UITextField
            legData.to = to.text!
//            let blocksOff = self.getUIViewByTagId(5+legNo*13) as! UITextField
            legData.blocksOff = blockOff.text!
//            let takeOff = self.getUIViewByTagId(6+legNo*13) as! UITextField
            legData.takeOff = takeOff.text!
//            let landing = self.getUIViewByTagId(7+legNo*13) as! UITextField
            legData.landing = landing.text!
//            let blocksOn = self.getUIViewByTagId(8+legNo*13) as! UITextField
            legData.blocksOn = blocksOn.text!
//            let blockTime = self.getUIViewByTagId(9+legNo*13) as! UITextField
            legData.blockTime = "0000" //blockTime.text!
//            let nightTime = self.getUIViewByTagId(10+legNo*13) as! UITextField
            legData.nightTime = "0000" //nightTime.text!
//            let instTime = self.getUIViewByTagId(11+legNo*13) as! UITextField
            legData.instTime = "0000" //instTime.text!
//            let toFlag = self.getUIViewByTagId(12+legNo*13) as! UITextField
            legData.toFlag = "01D" //toFlag.text!
//            let landFlag = self.getUIViewByTagId(13+legNo*13) as! UITextField
            legData.landFlag = "01D" //landFlag.text!
            if ( legData.std == nil ) {
                legData.std = legData.blocksOff
            }
            if (legData.sta == nil ) {
                legData.sta = legData.blocksOn
            }
            
        }
        
        
        do {
            try context.save()
            
            
            
        } catch _ {
        }
        
    }
    
    func getUIViewByTagId(_ tag:Int) -> UIView? {
        
        switch (tag ) {
        case 1: return self.date
        case 2: return self.flightNo
        case 3: return self.from
        case 4: return self.to
        case 5: return self.blockOff
        case 6: return self.takeOff
        case 7: return self.landing
        case 8: return self.blocksOn

        default: return nil
        }
        
    }
    
    func getUIViewValueByTagId(_ tag:Int) -> String? {
        
        if let view = self.getUIViewByTagId(tag) as? UITextField {
            return view.text
        } else {
            return nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
}
