//
//  FlightDetailsViewController.swift
//  FlightLog
//
//  Created by Naveed Azhar on 04/07/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class FlightDetailsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//    @IBOutlet weak var btnClock: UIButton!
//
//    //Setting up images for normal and selected state.
//    func configureUI() {
//        let image = UIImage(named: "btn_clock")
//        let imageFilled = UIImage(named: "btn_clock_filled")
//        btnClock.setImage(image, for: .normal)
//        btnClock.setImage(imageFilled, for: .selected)
//    }
//
//    @IBAction func btnClockPressed(_ sender: Any) {
//        // Toggle basically makes someBtn’s selected state either true or false when pressed
//        btnClock.isSelected.toggle()
//    }
    
    @IBOutlet weak var clockButton: UIButton!



    //Setting up images for normal and selected state.
    func configureUI() {
        let image = UIImage(named: "btn_clock")
        let imageFilled = UIImage(named: "btn_clock_filled")
        clockButton.setImage(image, for: .normal)
        clockButton.setImage(imageFilled, for: .selected)
    }

    @IBAction func btnClockPressed(_ sender: Any) {
        // Toggle basically makes someBtn’s selected state either true or false when pressed
        clockButton.isSelected.toggle()
    }
    
    

    @IBOutlet weak var newFlightNotice: UILabel!
    
    @IBOutlet weak var btnCancelled: Checkbox!
    
    @IBAction func cancelFlight(_ sender: AnyObject) {
        if !btnCancelled.isChecked {
            
            // create the alert
            let alert = UIAlertController(title: "Notice", message: "Are you sure you want to mark flight as CANCELLED.\nPlease enter Fuel data if available?\nThis action is irreversible.", preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { action in
                
                return
                
            }))
            
            alert.addAction(UIAlertAction(title: "Mark Flight as Cancelled", style: UIAlertAction.Style.destructive, handler: { action in
                
                self.blocksOff1.text = "0000"
                self.takeOff1.text = "0000"
                self.landing1.text = "0000"
                self.blocksOn1.text = "0000"
                self.btnCancelled.isChecked = true

                
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            


        }
    }
    
    @IBAction func surfactInterlineClicked(_ sender: AnyObject) {
        if !surfaceInterline.isChecked {
            self.aircraftType.text = "TBA"
            self.registration.text = "GRD"
            self.fltNo1.text = "100GR"
        } else {
            self.aircraftType.text = ""
            self.registration.text = ""
            self.fltNo1.text = "100GR"
        }
    }
    
    @IBOutlet weak var lblFlightLogEditMode: UILabel!
    
    var crewMatrixList = [CrewMatrix]()
    
    @IBOutlet weak var fltDate1: UITextField!
    
    @IBOutlet weak var fltNo1: UITextField!
    
    @IBOutlet weak var fromStation1: UITextField!
    
    @IBOutlet weak var toStation1: UITextField!
    
    @IBOutlet weak var blocksOff1: UITextField!
    
    
    @IBOutlet weak var takeOff1: UITextField!
    
    
    @IBOutlet weak var landing1: UITextField!
    
    
    
    @IBOutlet weak var blocksOn1: UITextField!
    
    
    
    @IBOutlet weak var blockTime1: UITextField!
    
    
    @IBOutlet weak var nightTime1: UITextField!
    
    
    @IBOutlet weak var instTime1: UITextField!
    
    
    @IBOutlet weak var takeOffFlag1: UITextField!
    
    
    @IBOutlet weak var landingFlag1: UITextField!
    
    @IBOutlet weak var captainDEbrief: UITextView!
    
    @IBOutlet weak var btnDblDept1: Checkbox!
    
    @IBOutlet weak var btnDblDept2: Checkbox!
    
    @IBOutlet weak var btnDblDept5: Checkbox!
    
    @IBOutlet weak var btnDblDept6: Checkbox!
    
    @IBOutlet weak var btnDblDept3: Checkbox!
    
    @IBOutlet weak var btnDblDept7: Checkbox!
    
    @IBOutlet weak var btnDblDept4: Checkbox!
    
    @IBOutlet weak var btnDblDept8: Checkbox!
    
    @IBOutlet weak var btnDepDelayCNSQ: Checkbox!
    
    @IBOutlet weak var btnArrDelayCNSQ: Checkbox!
    
    @IBOutlet weak var surfaceInterline: Checkbox!
    
    @IBOutlet weak var surfaceInterlineLabel: UILabel!
    
    
    @IBOutlet weak var aircraftType: UITextField!
    
    @IBOutlet weak var registration: UITextField!
    
    @IBOutlet weak var std: UITextField!
    
    @IBOutlet weak var sta: UITextField!
    
    @IBOutlet weak var cat23: UISegmentedControl!
    
    @IBOutlet weak var reasonForExtraFuel: UITextField!
    
    @IBOutlet weak var totalUplift: UITextField!
    
    @IBOutlet weak var beforeRefuelingKGS: UITextField!
    
    @IBOutlet weak var fuelUpliftQty: UITextField!
    
    @IBOutlet weak var fuelUpliftUnit: UISegmentedControl!
    
    @IBOutlet weak var density: UITextField!
    
    @IBOutlet weak var depKG: UITextField!
    
    @IBOutlet weak var arrKG: UITextField!
    
    @IBOutlet weak var zeroFuelWeight: UITextField!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var divertStation: UITextField!
    
    @IBOutlet weak var divertStationLabel: UILabel!
    
    @IBAction func doRampReturn(_ sender: Any) {
        
        // create the alert
        let alert = UIAlertController(title: "Notice", message: "Are you sure you want to create Ramp Return Flight?\nThis action is irreversible.", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { action in
            
            return
            
        }))
        
        alert.addAction(UIAlertAction(title: "Create Ramp Return Flight", style: UIAlertAction.Style.destructive, handler: { action in
            
            self.performRampReturn()
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func performRampReturn() {
        let legNo = 0
        
        
        let dep = self.getUIViewValueByTagId(legNo * 13 + 3)! as String
        let arr = self.getUIViewValueByTagId(legNo * 13 + 4)! as String
        let date = self.getUIViewValueByTagId(legNo * 13 + 1)! as String
        let fltNo = self.getUIViewValueByTagId(legNo * 13 + 2)! as String
        
        let primaryDate = date
        let primaryFltNo = fltNo
        let primaryFrom =  dep
        
        
        let to = self.getUIViewByTagId(4+legNo*13) as! UITextField
        
        if ( fltNo.hasSuffix(AppConstants.RAMP_RETURN_SUFFIX)  || StringUtils.isIPADFlightPresent(date, flightNo: fltNo + AppConstants.RAMP_RETURN_SUFFIX, depStation: dep)) {
            MiscUtils.alert("Flight Creation Error", message: "Flight already marked Ramp-Return", controller: self)
            return
        }
        
        
        
        let entityDescripition = NSEntityDescription.entity(forEntityName: "LegData", in: context)
        
        let legData = LegData(entity: entityDescripition!, insertInto: context)
        
        
        legData.date = StringUtils.getYMDStringFromDMYString(date)
        legData.fltNo = fltNo + AppConstants.RAMP_RETURN_SUFFIX
        legData.from = dep
        legData.source = "IPAD"
        legData.legNo = legNo as NSNumber?
        legData.primaryDate = StringUtils.getYMDStringFromDMYString(primaryDate)
        legData.primaryFltNo = primaryFltNo + AppConstants.RAMP_RETURN_SUFFIX
        legData.primaryFrom = primaryFrom
        //            if ( legData.captainId == nil ) {
        //                legData.captainId = userEntity.username
        //            }
        legData.captainId = FlightLogEntity.sharedInstance.flightIdentifiers[0].sharedCaptainId
        
        legData.aircraft = self.aircraftType.text
        legData.reg = self.registration.text
        legData.cat23 = self.cat23.selectedSegmentIndex as NSNumber?
        
        legData.captainDebrief = self.captainDEbrief.text
        legData.dblDept1 = btnDblDept1.isChecked ? 1 : 0
        legData.dblDept2 = btnDblDept2.isChecked ? 1 : 0
        legData.dblDept3 = btnDblDept3.isChecked ? 1 : 0
        legData.dblDept4 = btnDblDept4.isChecked ? 1 : 0
        legData.dblDept5 = btnDblDept5.isChecked ? 1 : 0
        legData.dblDept6 = btnDblDept6.isChecked ? 1 : 0
        legData.dblDept7 = btnDblDept7.isChecked ? 1 : 0
        legData.dblDept8 = btnDblDept8.isChecked ? 1 : 0
        
        legData.flag1 = btnDepDelayCNSQ.isChecked ? 1 : 0
        legData.flag2 = btnArrDelayCNSQ.isChecked ? 1 : 0
        legData.flag3 = surfaceInterline.isChecked ? 1 : 0
        
        legData.reasonForExtraFuel = self.reasonForExtraFuel.text
        legData.totalUplift = self.totalUplift.text
        legData.beforeRefuelingKGS = self.beforeRefuelingKGS.text
        legData.fuelUpLiftQty = self.fuelUpliftQty.text
        legData.fuelUplUnit = self.fuelUpliftUnit.selectedSegmentIndex as NSNumber?
        legData.density = self.density.text
        legData.depKG = self.depKG.text
        legData.arrKG = self.arrKG.text
        legData.zeroFuelWt = self.zeroFuelWeight.text
        
        
        
        
        legData.to = legData.from
        let blocksOff = self.getUIViewByTagId(5+legNo*13) as! UITextField
        if ( blocksOff.text == "" ) {
            blocksOff.text = self.std.text
        }
        legData.blocksOff = blocksOff.text!
        let takeOff = self.getUIViewByTagId(6+legNo*13) as! UITextField
        legData.takeOff = takeOff.text!
        let landing = self.getUIViewByTagId(7+legNo*13) as! UITextField
        legData.landing = landing.text!
        let blocksOn = self.getUIViewByTagId(8+legNo*13) as! UITextField
        legData.blocksOn = blocksOn.text!
        let blockTime = self.getUIViewByTagId(9+legNo*13) as! UITextField
        legData.blockTime = blockTime.text!
        let nightTime = self.getUIViewByTagId(10+legNo*13) as! UITextField
        legData.nightTime = nightTime.text!
        let instTime = self.getUIViewByTagId(11+legNo*13) as! UITextField
        legData.instTime = instTime.text!
        let toFlag = self.getUIViewByTagId(12+legNo*13) as! UITextField
        legData.toFlag = toFlag.text!
        let landFlag = self.getUIViewByTagId(13+legNo*13) as! UITextField
        legData.landFlag = landFlag.text!
        legData.std = self.std.text!
        legData.sta = self.sta.text!
        
        if (legData.uploadStatus != "Uploaded" && EDIT_MODE != 0 ) {
            if ( legData.blocksOn != "" || legData.blocksOff != "" || legData.takeOff != "" || legData.landing != ""  ) {
                legData.uploadStatus = ""
            } else {
                legData.uploadStatus = nil
            }
        }
        
        if ( legData.std == nil ) {
            legData.std = legData.blocksOff
        }
        if (legData.sta == nil ) {
            legData.sta = legData.blocksOn
        }
        
        
        MiscUtils.copyCrewDataForFlight(date, fltNoSource: fltNo, fltNoDestination: fltNo + AppConstants.RAMP_RETURN_SUFFIX, depStationSource: dep, depStationDestination: dep)
        
        do {
            try context.save()
            
            
            
        } catch _ {
        }
        
        MiscUtils.alert("Flight added", message: "Ramp Return flight added.", controller: self)
        
        performSegue(withIdentifier: "backToFlightList", sender: self)
        

    }
    
    func performDivert() {
        
        if ( self.divertStation.isHidden == true || self.divertStation.text?.lengthOfBytes(using: String.Encoding.utf8) != 3) {
            self.divertStation.isHidden = false
            self.divertStationLabel.isHidden = false
            self.divertStation.text = ""
            //MiscUtils.alert("Divert Station Missing", message: "Please enter Divert Station", controller: self)
            self.divertStation.becomeFirstResponder()
            self.divertStationLabel.textColor = UIColor.red
            return
        }
        

        let legNo = 0
        
        
        let dep = self.getUIViewValueByTagId(legNo * 13 + 3)! as String
        let arr = self.getUIViewValueByTagId(legNo * 13 + 4)! as String
        let date = self.getUIViewValueByTagId(legNo * 13 + 1)! as String
        let fltNo = self.getUIViewValueByTagId(legNo * 13 + 2)! as String
        
        
        let entityDescripition = NSEntityDescription.entity(forEntityName: "LegData", in: context)
        
        let legData = LegData(entity: entityDescripition!, insertInto: context)
        
        let primaryDate = date
        let primaryFltNo = fltNo
        let primaryFrom =  dep
        
        if ( arr.trimmingCharacters(in: CharacterSet.whitespaces) == "" || StringUtils.isIPADFlightPresent(date, flightNo: fltNo,  depStation: "")) {
            MiscUtils.alert("Flight Creation Error", message: "Flight already marked Diverted", controller: self)
            return
        }
        
        legData.date = StringUtils.getYMDStringFromDMYString(date)
        legData.fltNo = fltNo
        legData.from = divertStation.text
        legData.source = "IPAD"
        legData.legNo = legNo as NSNumber?
        legData.primaryDate = StringUtils.getYMDStringFromDMYString(primaryDate)
        legData.primaryFltNo = primaryFltNo
        legData.primaryFrom = divertStation.text
        //            if ( legData.captainId == nil ) {
        //                legData.captainId = userEntity.username
        //            }
        legData.captainId = FlightLogEntity.sharedInstance.flightIdentifiers[0].sharedCaptainId
        
        legData.aircraft = self.aircraftType.text
        legData.reg = self.registration.text
        legData.cat23 = self.cat23.selectedSegmentIndex as NSNumber?
        
        legData.captainDebrief = self.captainDEbrief.text
        legData.dblDept1 = btnDblDept1.isChecked ? 1 : 0
        legData.dblDept2 = btnDblDept2.isChecked ? 1 : 0
        legData.dblDept3 = btnDblDept3.isChecked ? 1 : 0
        legData.dblDept4 = btnDblDept4.isChecked ? 1 : 0
        legData.dblDept5 = btnDblDept5.isChecked ? 1 : 0
        legData.dblDept6 = btnDblDept6.isChecked ? 1 : 0
        legData.dblDept7 = btnDblDept7.isChecked ? 1 : 0
        legData.dblDept8 = btnDblDept8.isChecked ? 1 : 0
        
        legData.flag1 = btnDepDelayCNSQ.isChecked ? 1 : 0
        legData.flag2 = btnArrDelayCNSQ.isChecked ? 1 : 0
        legData.flag3 = surfaceInterline.isChecked ? 1 : 0
        
        legData.reasonForExtraFuel = self.reasonForExtraFuel.text
        legData.totalUplift = self.totalUplift.text
        legData.beforeRefuelingKGS = self.beforeRefuelingKGS.text
        legData.fuelUpLiftQty = self.fuelUpliftQty.text
        legData.fuelUplUnit = self.fuelUpliftUnit.selectedSegmentIndex as NSNumber?
        legData.density = self.density.text
        legData.depKG = self.depKG.text
        legData.arrKG = self.arrKG.text
        legData.zeroFuelWt = self.zeroFuelWeight.text
        
        
        
        let to = self.getUIViewByTagId(4+legNo*13) as! UITextField
        legData.to = to.text!
        let blocksOff = self.getUIViewByTagId(5+legNo*13) as! UITextField
        if ( blocksOff.text == "" ) {
            blocksOff.text = self.std.text
        }
        legData.blocksOff = blocksOff.text!
        let takeOff = self.getUIViewByTagId(6+legNo*13) as! UITextField
        legData.takeOff = takeOff.text!
        let landing = self.getUIViewByTagId(7+legNo*13) as! UITextField
        legData.landing = landing.text!
        let blocksOn = self.getUIViewByTagId(8+legNo*13) as! UITextField
        legData.blocksOn = blocksOn.text!
        let blockTime = self.getUIViewByTagId(9+legNo*13) as! UITextField
        legData.blockTime = blockTime.text!
        let nightTime = self.getUIViewByTagId(10+legNo*13) as! UITextField
        legData.nightTime = nightTime.text!
        let instTime = self.getUIViewByTagId(11+legNo*13) as! UITextField
        legData.instTime = instTime.text!
        let toFlag = self.getUIViewByTagId(12+legNo*13) as! UITextField
        legData.toFlag = toFlag.text!
        let landFlag = self.getUIViewByTagId(13+legNo*13) as! UITextField
        legData.landFlag = landFlag.text!
        legData.std = self.std.text!
        legData.sta = self.sta.text!
        
        
        if (legData.uploadStatus != "Uploaded" && EDIT_MODE != 0 ) {
            if ( legData.blocksOn != "" || legData.blocksOff != "" || legData.takeOff != "" || legData.landing != ""  ) {
                legData.uploadStatus = ""
            } else {
                legData.uploadStatus = nil
            }
        }
        
        if ( legData.std == nil ) {
            legData.std = legData.blocksOff
        }
        if (legData.sta == nil ) {
            legData.sta = legData.blocksOn
        }
        
        MiscUtils.copyCrewDataForFlight(date, fltNoSource: fltNo, fltNoDestination: fltNo, depStationSource: dep, depStationDestination: self.divertStation.text!)
        
        to.text = divertStation.text
        
        
        do {
            try context.save()
            
            
            
        } catch _ {
        }
        
        
        self.save()
        
        MiscUtils.alert("Flight added", message: "Ramp Return flight added.", controller: self)
        
        performSegue(withIdentifier: "backToFlightList", sender: self)

    }
    
    @IBAction func doDivert(_ sender: Any) {
        
        
        // create the alert
        let alert = UIAlertController(title: "Notice", message: "Are you sure you want to create Divert Flight?\nThis action is irreversible.", preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { action in
            
            return
            
        }))
        
        alert.addAction(UIAlertAction(title: "Create Divert Flight", style: UIAlertAction.Style.destructive, handler: { action in
            
            self.performDivert()
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    var currentTagEditing = 0
    
    
    @IBOutlet weak var btnCreateNewLog: UIButton!
    
    @IBAction func createNewLog(_ sender: AnyObject) {
        if (self.sta.text == "" || self.aircraftType.text == "" || self.registration.text == "" || self.fltDate1.text == "" || self.fltNo1.text == "" || fromStation1.text == "" || self.toStation1.text == "" ) {
            MiscUtils.alert("New Flight Log", message: "Please provide following required fields [AC Type], [Reg], [STD],[STA],[DATE],[FLT NO], [FROM] and [TO]", controller: self)
        } else {
            
         self.save()
         performSegue(withIdentifier: "backToFlightList", sender: self)
        }
    }
    
    
    @IBAction func printLog(_ sender: AnyObject) {
        let flLegDataString = MiscUtils.getFlightLogLegDataString(fltDate1.text!, fltNo: fltNo1.text!, depStation: fromStation1.text!)
        let flCrewDataString = MiscUtils.getFlightLogCrewDataString(fltDate1.text!, fltNo: fltNo1.text!, depStation: fromStation1.text!)
        
//        print(flLegDataString + "\n\n")
//        print(flCrewDataString)
    }
    
    
    @IBAction func prepareNewRow(_ sender: AnyObject) {
        let tag = sender.tag!
        if let view = self.getUIViewByTagId(tag) as? UITextField {
            if (view.text == "") {
                view.text = self.getUIViewValueByTagId(tag - 13)
            }
        }
        if let view = self.getUIViewByTagId(tag+2) as? UITextField {
            if (view.text == "") {
                view.text = self.getUIViewValueByTagId(tag - 10)
            }
        }
    }
    
    
    func setDelegate(_ view: UIView ) {
        
        NSLog("%@", view)
        
        for view in view.subviews {
            if let textField = view as? UITextField {
                textField.delegate = self
            } else {
                setDelegate(view)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.aircraftType {
            
            self.registration.becomeFirstResponder()
            
        } else if textField == self.registration {
            
            self.std.becomeFirstResponder()
            
        } else if textField == self.std {
            
            self.sta.becomeFirstResponder()
            
        } else if textField == self.sta {
            
            self.fltDate1.becomeFirstResponder()
            
        } else if textField == self.fltDate1 {
            
            self.fltNo1.becomeFirstResponder()
            
        } else if textField == self.fltNo1 {
            
            self.fromStation1.becomeFirstResponder()
            
        } else if textField == self.fromStation1 {
            
            self.toStation1.becomeFirstResponder()
            
        } else if textField == self.toStation1 {
            
            self.blocksOff1.becomeFirstResponder()
            
        } else if textField == self.blocksOff1 {
            
            self.takeOff1.becomeFirstResponder()
            
        } else if textField == self.takeOff1 {
            
            self.landing1.becomeFirstResponder()
            
        } else if textField == self.landing1 {
            
            self.blocksOn1.becomeFirstResponder()
            
        } else if textField == self.blocksOn1 {
            
            self.nightTime1.becomeFirstResponder()
            
        } else if textField == self.nightTime1 {
            
            self.instTime1.becomeFirstResponder()
            
        } else if textField == self.instTime1 {
            
            self.takeOffFlag1.becomeFirstResponder()
            
        } else if textField == self.takeOffFlag1 {
            
            self.landingFlag1.becomeFirstResponder()
            
        } else if textField == self.landingFlag1 {
            
            self.beforeRefuelingKGS.becomeFirstResponder()
            
        } else if textField == self.beforeRefuelingKGS {
            
            self.density.becomeFirstResponder()
            
        } else if textField == self.density {
            
            self.fuelUpliftQty.becomeFirstResponder()
            
        } else if textField == self.fuelUpliftQty {
            
            self.totalUplift.becomeFirstResponder()
            
        } else if textField == self.totalUplift {
            
            self.depKG.becomeFirstResponder()
            
        } else if textField == self.depKG {
            
            self.arrKG.becomeFirstResponder()
            
        } else if textField == self.arrKG {
            
            self.zeroFuelWeight.becomeFirstResponder()
            
        } else if textField == self.zeroFuelWeight {
            
            self.reasonForExtraFuel.becomeFirstResponder()
            
        }
        
        
        
        return true
    }
    
    func getSubviewsOfView(v:UIView) -> [UILabel] {
        var circleArray = [UILabel]()

        for subview in v.subviews as! [UIView] {
            circleArray += getSubviewsOfView(v: subview)

            if subview is UILabel {
                circleArray.append(subview as! UILabel)
            }
        }

        return circleArray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // dark mode to be done
//        let myViews = getSubviewsOfView(v: self.view)
//        for view in myViews {
//            view.textColor = UIColor.red
//            view.font = UIFont.boldSystemFont(ofSize: 14.0)
//        }

        var isNewFlightEntry = FlightLogEntity.sharedInstance.getLegCount() == 0
        
//        self.fuelUpliftUnit.selectedSegmentIndex = 1
        
        AppSettings.refresh(self.view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FlightDetailsViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FlightDetailsViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // if a new log is being added.
        
        self.btnCreateNewLog.isHidden = !isNewFlightEntry
        if ( newFlightNotice != nil) {
        self.newFlightNotice.isHidden = !isNewFlightEntry
        }
        self.surfaceInterline.isHidden = !isNewFlightEntry
        self.surfaceInterlineLabel.isHidden = !isNewFlightEntry
        
        if ( !isNewFlightEntry ) {
            let readOnlyTags = [1,2,3,53,54]
            for t in readOnlyTags {
                getUIViewByTagId(t)?.isUserInteractionEnabled = false
            }
        }
        
        // remove "Add Crew" or any other button
        //                    let a = UIBarButtonItem(
        //                        barButtonSystemItem: "",
        //                        target: self,
        //                        action: .plain)
        
        
        self.tabBarController?.navigationItem.rightBarButtonItems?.removeAll()
        
        
        
        if ( false && EDIT_MODE == 2 ) {
            // create the alert
            let alert = UIAlertController(title: "Notice", message: "You have already uploaded this flight log. Do you want to change the data?", preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Open as View-Only", style: UIAlertAction.Style.default, handler: { action in
                
                EDIT_MODE = 0
                
            }))
            
            alert.addAction(UIAlertAction(title: "Modify Data", style: UIAlertAction.Style.destructive, handler: { action in
                
                EDIT_MODE = 1
                
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        }
        
        
        //        let parentController =  self.tabBarController as! FLTabBarController
        if ( FlightLogEntity.sharedInstance.flightIdentifiers.count == 0 ){
            FlightLogEntity.sharedInstance.initIdentifiers()
        }
        
        self.fltNo1.text  = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
        self.fltDate1.text = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate
        self.fromStation1.text = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation
        
        //        self.aircraftType.text = self.aircraft
        //        self.registration.text = self.reg
        
        if ( FlightLogEntity.sharedInstance.getLegCount() > 0 ) {
            
            let legRequest = NSFetchRequest<LegData>(entityName: "LegData")
            do {
                let data = try context.fetch(legRequest)
                
                
                let flights = data
                
                var filteredArray = flights.filter( { (legData: LegData) -> Bool in
                    return legData.date == StringUtils.getYMDStringFromDMYString(self.fltDate1.text!)  && legData.fltNo == self.fltNo1.text && legData.from == self.fromStation1.text && legData.source == "IPAD"
                })
                
                if ( filteredArray.count == 1 ) {
                    let filterLegData = filteredArray[0]
                    
                    self.fltNo1.text  = filterLegData.primaryFltNo
                    self.fltDate1.text = filterLegData.primaryDate
                    self.fromStation1.text = filterLegData.primaryFrom
                    
                    var filteredArray = flights.filter( { (legData: LegData) -> Bool in
                        return legData.source == "IPAD" && legData.primaryDate == self.fltDate1.text && legData.primaryFltNo == self.fltNo1.text && legData.primaryFrom == self.fromStation1.text
                    })
                    
                    for i in 0..<filteredArray.count  {
                        populateFlight(filteredArray[i])
                    }
                    
                }
                
            } catch _ {
                print("Error")
            }
            
            
        }
        
        
        // @TODO : Changed this at last moment ( to always load fresh data)
        
        self.toStation1.text = ""
        
        loadFlightData()
        // Do any additional setup after loading the view.
        
        //        self.tabBarController!.navigationItem.title = "title"
        self.navigationController?.isNavigationBarHidden = false
        
        
        if tabBarController == nil {
            self.navigationItem.title = "Flight/Technical Data"
            
        }else{
            self.tabBarController!.navigationItem.title = "Flight/Technical Data"
            
        }
        
        
        if ( EDIT_MODE == 0 ) {
            self.lblFlightLogEditMode.text = "READ-ONLY (Supy)"
            
        } else if ( EDIT_MODE == 2 ) {
            self.lblFlightLogEditMode.text = "READ-ONLY (Already Saved)"
        } else {
            self.lblFlightLogEditMode.text = ""
        }
        
    }
    
//    func saveData(_ sender: UIBarButtonItem) {
//
//        self.save()
//    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        self.registration.delegate = self
        self.aircraftType.delegate = self
        

        if ( newFlightNotice != nil) {
        newFlightNotice.text = "If the flight number is already listed in previous screen. Please go back and click on flight number to fill the log.\r\n"
        }
        Indicator.start(self)
        
        
        
        self.fetchCrewScheduleFromJSON()
        
        
        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(imageDeliveryReceiptTapped(tapGestureRecognizer:)))
        imageViewDeliveryReceipt.isUserInteractionEnabled = true
        imageViewDeliveryReceipt.addGestureRecognizer(tapGestureRecognizer1)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(imageFuelIndentTapped(tapGestureRecognizer:)))
        imageViewFuelIndent.isUserInteractionEnabled = true
        imageViewFuelIndent.addGestureRecognizer(tapGestureRecognizer2)
        
        
    }
    
    
    
    @objc func keyboardWillShow(notification:NSNotification) {
        
        if ( currentTagEditing < 100 && currentTagEditing > 50 ) {
            return
        }
//        else
//        if ( currentTagEditing < 50 && btnCreateNewLog.isHidden ) {
//            return
//        }
        var keyboardHeight:CGFloat = 0
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // fieldBottomConstant.constant = keyboardSize.height
            keyboardHeight = keyboardSize.height
        }
        
        bottomConstraint.constant = keyboardHeight - 50
        
        if ( !btnCreateNewLog.isHidden ) {
            bottomConstraint.constant = keyboardHeight - 0
        }
        
        
    }
    @objc  
    func keyboardWillHide(notification:NSNotification) {
        
        bottomConstraint.constant = 100
        
    }
    
    
    
    func populateFlight(_ legData:LegData) {
        
        
        let date:UITextField = self.getUIViewByTagId(1 + Int(legData.legNo!) * 13) as! UITextField
        date.text = StringUtils.getDMYStringFromYMDString(legData.date!)
        let fltNo:UITextField  = self.getUIViewByTagId(2 + Int(legData.legNo!) * 13) as! UITextField
        fltNo.text = legData.fltNo
        let from:UITextField  = self.getUIViewByTagId(3 + Int(legData.legNo!) * 13) as! UITextField
        from.text = legData.from
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    @IBAction func save() {
        
        if (EDIT_MODE != 1 ) { return }
        
        do {
            let legRequest = NSFetchRequest<LegData>(entityName: "LegData")
            let data = try  context.fetch(legRequest)
            
            let flights = data
            
            let entityDescripition = NSEntityDescription.entity(forEntityName: "FlightLog", in: context)
            
            let flightLogData = FlightLog(entity: entityDescripition!, insertInto: context)
            
            flightLogData.aircraftType = self.aircraftType.text!
            flightLogData.registration = self.registration.text!
            
            let dep = self.getUIViewValueByTagId(3)! as String
            let date = self.getUIViewValueByTagId(1)! as String
            let fltNo = self.getUIViewValueByTagId(2)! as String
            
            _ =  self.tabBarController
            
            // removed to fix sharedcaptainid
            //            FlightLogEntity.sharedInstance.initIdentifiers()
            
            let blocksOff = self.getUIViewByTagId(5) as! UITextField
//            let takeOff = self.getUIViewByTagId(6) as! UITextField
//            let landing = self.getUIViewByTagId(7) as! UITextField
//            let blocksOn = self.getUIViewByTagId(8) as! UITextField

            if ( blocksOff.text != "" ) {
            for i in 0...0 {
                
                
                saveLegData(flights, legNo: i, primaryDate: date, primaryFltNo: fltNo, primaryFrom: dep)
                
            }
            
//            try context.save()
            }
            
            
            //            let alert = UIAlertController(title: "Flight Log", message: "Flight data updated successfully.", preferredStyle: UIAlertControllerStyle.alert)
            //            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            //            DispatchQueue.main.async {
            //                self.present(alert, animated: true, completion: nil)
            //            }
            
            
        } catch _ {
        }
    }
    
    
    func saveLegData(_ flights:[LegData],  legNo:Int, primaryDate: String, primaryFltNo: String, primaryFrom:String) {
        
        let dep = self.getUIViewValueByTagId(legNo * 13 + 3)! as String
        let arr = self.getUIViewValueByTagId(legNo * 13 + 4)! as String
        let date = self.getUIViewValueByTagId(legNo * 13 + 1)! as String
        let fltNo = self.getUIViewValueByTagId(legNo * 13 + 2)! as String
        
        FlightLogEntity.sharedInstance.flightIdentifiers[legNo].fltNo = fltNo
        FlightLogEntity.sharedInstance.flightIdentifiers[legNo].fltDate = date
        FlightLogEntity.sharedInstance.flightIdentifiers[legNo].depStation = dep
        
        
        if (dep != "" && arr != "" && date != "" && arr != "" ) {
            var filteredArray = flights.filter( { (legData: LegData) -> Bool in
                return legData.date == StringUtils.getYMDStringFromDMYString(date) && legData.fltNo == fltNo && legData.from == dep //&& legData.source == "IPAD"
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
            //            if ( legData.captainId == nil ) {
            //                legData.captainId = userEntity.username
            //            }
            legData.captainId = FlightLogEntity.sharedInstance.flightIdentifiers[0].sharedCaptainId
            
            legData.aircraft = self.aircraftType.text
            legData.reg = self.registration.text
            legData.cat23 = self.cat23.selectedSegmentIndex as NSNumber?
            
            legData.captainDebrief = self.captainDEbrief.text
            legData.dblDept1 = btnDblDept1.isChecked ? 1 : 0
            legData.dblDept2 = btnDblDept2.isChecked ? 1 : 0
            legData.dblDept3 = btnDblDept3.isChecked ? 1 : 0
            legData.dblDept4 = btnDblDept4.isChecked ? 1 : 0
            legData.dblDept5 = btnDblDept5.isChecked ? 1 : 0
            legData.dblDept6 = btnDblDept6.isChecked ? 1 : 0
            legData.dblDept7 = btnDblDept7.isChecked ? 1 : 0
            legData.dblDept8 = btnDblDept8.isChecked ? 1 : 0
            
            legData.flag1 = btnDepDelayCNSQ.isChecked ? 1 : 0
            legData.flag2 = btnArrDelayCNSQ.isChecked ? 1 : 0
            legData.flag3 = surfaceInterline.isChecked ? 1 : 0
            
            legData.reasonForExtraFuel = self.reasonForExtraFuel.text
            legData.totalUplift = self.totalUplift.text
            legData.beforeRefuelingKGS = self.beforeRefuelingKGS.text
            legData.fuelUpLiftQty = self.fuelUpliftQty.text
            legData.fuelUplUnit = self.fuelUpliftUnit.selectedSegmentIndex as NSNumber?
            legData.density = self.density.text
            legData.depKG = self.depKG.text
            legData.arrKG = self.arrKG.text
            legData.zeroFuelWt = self.zeroFuelWeight.text
            
            
            
            let to = self.getUIViewByTagId(4+legNo*13) as! UITextField
            legData.to = to.text!
            let blocksOff = self.getUIViewByTagId(5+legNo*13) as! UITextField
            legData.blocksOff = blocksOff.text!
            let takeOff = self.getUIViewByTagId(6+legNo*13) as! UITextField
            legData.takeOff = takeOff.text!
            let landing = self.getUIViewByTagId(7+legNo*13) as! UITextField
            legData.landing = landing.text!
            let blocksOn = self.getUIViewByTagId(8+legNo*13) as! UITextField
            legData.blocksOn = blocksOn.text!
            let blockTime = self.getUIViewByTagId(9+legNo*13) as! UITextField
            legData.blockTime = blockTime.text!
            let nightTime = self.getUIViewByTagId(10+legNo*13) as! UITextField
            legData.nightTime = nightTime.text!
            let instTime = self.getUIViewByTagId(11+legNo*13) as! UITextField
            legData.instTime = instTime.text!
            let toFlag = self.getUIViewByTagId(12+legNo*13) as! UITextField
            legData.toFlag = toFlag.text!
            let landFlag = self.getUIViewByTagId(13+legNo*13) as! UITextField
            legData.landFlag = landFlag.text!
            legData.std = self.std.text!
            legData.sta = self.sta.text!
            
            if (legData.uploadStatus != "Uploaded" && EDIT_MODE != 0 ) {
                if ( legData.blocksOn != "" || legData.blocksOff != "" || legData.takeOff != "" || legData.landing != "" || legData.aircraft == "TBA" || legData.reg == "GRD" ) {
                    legData.uploadStatus = ""
                } else {
                    legData.uploadStatus = nil
                }
            }
            
            if ( legData.std == nil ) {
                legData.std = legData.blocksOff
            }
            if (legData.sta == nil ) {
                legData.sta = legData.blocksOn
            }
            
        }
        
        
        do {
            try context.save()
            
            if ( self.totalUplift.text?.count > 0 ) {
                let totalUplift = Int(self.totalUplift.text!)!
                
                if ( totalUplift > 0 ) {
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    
                    let delivery_receipt_exists = FileManager.default.fileExists(atPath: documentsURL.appendingPathComponent(date + "_" + fltNo + "_" + dep + "_DeliveryReceipt.jpg").path)

                    let fuel_indent_exists = FileManager.default.fileExists(atPath: documentsURL.appendingPathComponent(date + "_" + fltNo + "_" + dep + "_FuelIndent.jpg").path)
                    
                    if ( !delivery_receipt_exists  || !fuel_indent_exists) {
                        alert("Missing images of Fuel documents", Body: "Please use iPad camera to upload pictures of Delivery Receipt & Fuel Indent")
                    }

                }
                
            }
            
                    
        } catch _ {
        }
        
    }
    
    func getFieldTypeFromTag(_ tag:Int) -> String {
        
        let remainder = tag % 13
        
        if ( tag > 0 ) {
            switch (remainder ) {
            case 1 : return "Date"
            case 2 : return "Flight"
            case 3, 4: return "Station"
            case 5,6,7,8,9,10,11: return "Time"
            case 12,0: return "Flag"
            default: return ""
            }
        } else {
            return ""
        }
        
    }
    
    
    func getUIViewValueByTagId(_ tag:Int) -> String? {
        
        if let view = self.getUIViewByTagId(tag) as? UITextField {
            return view.text
        } else {
            return nil
        }
    }
    
    func getUIViewByTagId(_ tag:Int) -> UIView? {
        
        switch (tag ) {
        case 1: return self.fltDate1
        case 2: return self.fltNo1
            
        case 3: return self.fromStation1
            
        case 4: return self.toStation1
            
        case 5: return self.blocksOff1
            
        case 6: return self.takeOff1
            
        case 7: return self.landing1
            
        case 8: return self.blocksOn1
            
        case 9: return self.blockTime1
            
        case 10: return self.nightTime1
            
        case 11: return self.instTime1
            
        case 12: return self.takeOffFlag1
            
        case 13: return self.landingFlag1
            
        default: return nil
        }
        
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //        print("\(#function)")
        
        currentTagEditing = textField.tag
        
        if ( EDIT_MODE != 1 ) {
            return false
        }
        
        if ( textField.tag == 1 ) {
            if (textField.text!.count == 0 ) {
                textField.text =  StringUtils.getStringFromDate(Date())
                
            }
        }
        
        if ( textField.tag % 13 == 1 && textField.tag > 1) {
            if (textField.text!.count == 0 ) {
                textField.text =  self.getUIViewValueByTagId(textField.tag-13)
                
            }
        }
        
        
        // disable auto entry of UTC timings
        if ( clockButton.isSelected ) {
            if (textField.tag >= 5 && textField.tag <= 8) {
                if (textField.text == "") {
                textField.text = StringUtils.getCurrentUTCTime()
                }
            }
        }
        

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if ( textField.tag >= 108 && textField.tag <= 114) {
            if (!self.validateRagne(textElement: textField, AC: self.aircraftType.text!, AStr: self.beforeRefuelingKGS.text!, BStr: self.fuelUpliftQty.text!, CStr: self.totalUplift.text!, DStr: self.depKG.text!, EStr: self.arrKG.text!, ZStr: self.zeroFuelWeight.text!)) {
                textField.text = ""
            }
        }
        if ( textField.tag < 100) {
            
            textField.text = textField.text!.uppercased()
        }
        
        if ( textField.tag < 50 ) {

            let type = self.getFieldTypeFromTag(textField.tag)

            switch (type) {
                
            case "Flight" : textField.text = textField.text!.uppercased()
            

            if ( MiscUtils.validateFlight(input_string: textField.text!) ) {
                textField.backgroundColor = UIColor.white
            } else {
                textField.text = ""
                MiscUtils.alert("New Flight Log", message: "Please correct flight number format e.g. 300, 3002A, 304D, 100T, GR350, TBA01 etc.", controller: self)
            }
                
            case "Station": textField.text = textField.text!.uppercased()
            if ( MiscUtils.validateStation(input_string: textField.text!) ) {
                textField.backgroundColor = UIColor.white
            } else {
                textField.backgroundColor = UIColor.yellow
                                MiscUtils.alert("Airport validation", message: "It seems that station is invalid. Please check and correct if necessary", controller: self)
                
                }
            case "Flag" : textField.text = textField.text!.uppercased()
            case "Date" :
                _ = textField.text!
                // @swift3
                //            textField.text = s.replacingOccurrences(
                //                of: "\\D", with: "", options: .regularExpression,
                //                range: s.characters.indices)
                if ( textField.text!.count < 8) {
                    textField.text = ""
                } else if let tempDate = StringUtils.getDateFromString(textField.text!)
                    
                {
                    if (tempDate.compare( Date(timeInterval: 2 * 60 * 60 * 24 , since: Date() )) == ComparisonResult.orderedDescending ) {
                        textField.text = ""
                        
                    }
                }
            case "Time" :
                let s = textField.text!
                textField.text = StringUtils.getNumericFromString(s)

                // @swift3
                //            textField.text = s.replacingOccurrences(
                //                of: "\\D", with: "", options: .regularExpression,
                //                range: s.characters.indices)
                if ( textField.text!.count < 4 ) {
                    textField.text = ""
                } else {
                    let str = textField.text
                    let hour =  Int(textField.text!.substring(with: (str!.index(str!.startIndex, offsetBy: 0) ..< str!.index(str!.startIndex, offsetBy: 2))))
                    
                    let minute =  Int(textField.text!.substring(with: (str!.index(str!.startIndex, offsetBy: 2) ..< str!.index(str!.startIndex, offsetBy: 4))))
                    
                    if ( hour > 23 || minute > 59 ) {
                        
                        textField.text = ""
                    }
                }
                
            default : break
                
            }
            
        }
        if ( textField.tag > 50 ) {
            return
        }
        if ( textField.tag % 13 == 2 || textField.tag % 13 == 3) {
            loadFlightData()
        }
        
        let offset = textField.tag % 13
        let base = Int(floor(Double(textField.tag / 13) ))
        
        if ( offset >= 5 && offset <= 8 ) {
            
            if ( self.getUIViewValueByTagId(base + 5)! != ""  && self.getUIViewValueByTagId(base + 8)! != "") {
                let blkon = StringUtils.getMinutesFromHHMM(self.getUIViewValueByTagId(base + 5)!)
                
                let blkoff = StringUtils.getMinutesFromHHMM(self.getUIViewValueByTagId(base + 8)!)
                
                var blktime =  blkoff - blkon
                
                if ( blktime < 0 ) {
                    blktime += 1440;
                }
                
                let blktimeView = self.getUIViewByTagId(base + 9) as? UITextField
                blktimeView?.text = "\(StringUtils.getHHMMFromMinutes(blktime))"
                
                
                let nighttimeView = self.getUIViewByTagId(base + 9) as? UITextField
                if (nighttimeView?.text == "" || nighttimeView?.text == "0000" ) {
                    nighttimeView?.text = "\(StringUtils.getHHMMFromMinutes(blktime))"
                }
                
            }
            
        }
        
//        if ( textField.tag == 5 || textField.tag == 8 ) {
//            self.save()
//        }
        
    }
    
    func updateParentController() {
        
        //        removed the init to fix sharedcaptainid
        //        FlightLogEntity.sharedInstance.initIdentifiers()
        for i in 0...0 {
            let dep = self.getUIViewValueByTagId(i * 13 + 3)! as String
            let date = self.getUIViewValueByTagId(i * 13 + 1)! as String
            let fltNo = self.getUIViewValueByTagId(i * 13 + 2)! as String
            
            FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo = fltNo
            FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate = date
            FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation = dep
        }
    }
    
    func loadFlightData() {
        
        
        
        for i in 0...0 {
            let date = self.getUIViewValueByTagId(i * 13 + 1)! as String
            let dep = self.getUIViewValueByTagId(i * 13 + 3)! as String
            let arr = self.getUIViewValueByTagId(i * 13 + 4)! as String
            
            if (date != "" && dep != "" && arr == "") {
                let date = self.getUIViewValueByTagId(i * 13 + 1)! as String
                let fltNo = self.getUIViewValueByTagId(i * 13 + 2)! as String
                
                let legRequest = NSFetchRequest<LegData>(entityName: "LegData")
                do {
                    let data = try context.fetch(legRequest)
                    
                    let flights = data
                    
                    var filteredArray = flights.filter( { (legData: LegData) -> Bool in
                        return legData.date == StringUtils.getYMDStringFromDMYString(date) && legData.fltNo == fltNo && legData.from == dep && legData.source == "IPAD"
                    })
                    // if local copy (filled by captain) found
                    if ( filteredArray.count == 1 ) {
                        let legData = filteredArray[0]
                        loadLegData(legData, legNo: i)
                    } else {
                        filteredArray = flights.filter( { (legData: LegData) -> Bool in
                            return legData.date == StringUtils.getYMDStringFromDMYString(date) && legData.fltNo == fltNo && legData.from == dep && legData.source == "JSON"
                        })
                        // if json copy found
                        if ( filteredArray.count == 1 ) {
                            let legData = filteredArray[0]
                            loadLegData(legData, legNo: i)
                        }
                    }
                } catch _ {
                    print("Error")
                }
                
            }
            
        }
        updateParentController()
    }
    
    
    
    func crewDataSorter (_ crew1:CrewData, crew2:CrewData) -> Bool {
        return crew1.pos  < crew2.pos
    }
    
    func isPartOfParentController(_ crewData: CrewData) -> Bool {
        
        
        
        for i in 0...0 {
            
            if ( FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo == crewData.fltNo &&
                FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate ==  StringUtils.getDMYStringFromYMDString(crewData.date!)  &&
                FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation == crewData.from ) {
                return true
            }
        }
        return false
    }
    
    
    func getMatrixElementByStaffNo(_ staffNo:String ) -> Int? {
        for i in 0..<crewMatrixList.count {
            if ( crewMatrixList[i].staffno == staffNo) {
                return i
            }
        }
        return nil
    }
    
    
    func loadLegData(_ legData:LegData, legNo:Int) {
        self.aircraftType.text = legData.aircraft
        self.registration.text = legData.reg
        self.captainDEbrief.text = legData.captainDebrief
        self.btnDblDept1.isChecked = legData.dblDept1 == 1
        self.btnDblDept2.isChecked = legData.dblDept2 == 1
        self.btnDblDept3.isChecked = legData.dblDept3 == 1
        self.btnDblDept4.isChecked = legData.dblDept4 == 1
        self.btnDblDept5.isChecked = legData.dblDept5 == 1
        self.btnDblDept6.isChecked = legData.dblDept6 == 1
        self.btnDblDept7.isChecked = legData.dblDept7 == 1
        self.btnDblDept8.isChecked = legData.dblDept8 == 1
        
        self.btnDepDelayCNSQ.isChecked = legData.flag1 == 1
        self.btnArrDelayCNSQ.isChecked = legData.flag2 == 1
        self.surfaceInterline.isChecked = legData.flag3 == 1
        
        
        self.cat23.selectedSegmentIndex = Int(legData.cat23!)
        self.reasonForExtraFuel.text = legData.reasonForExtraFuel
        self.totalUplift.text = legData.totalUplift
        self.beforeRefuelingKGS.text = legData.beforeRefuelingKGS
        self.fuelUpliftQty.text = legData.fuelUpLiftQty
        // change the default selection only if data is saved by the user (not loaded initially (by pressing refresh button))
//        if ( legData.source != "JSON") {
        self.fuelUpliftUnit.selectedSegmentIndex = legData.fuelUplUnit as! Int
//        }
        self.density.text = legData.density
        self.depKG.text = legData.depKG
        self.arrKG.text = legData.arrKG
        self.zeroFuelWeight.text = legData.zeroFuelWt
        
        
        self.std.text = legData.std
        self.sta.text = legData.sta
        
        let to = self.getUIViewByTagId(4+legNo*13) as! UITextField
        to.text = legData.to
        let blocksOff = self.getUIViewByTagId(5+legNo*13) as! UITextField
        blocksOff.text = legData.blocksOff
        let takeOff = self.getUIViewByTagId(6+legNo*13) as! UITextField
        takeOff.text = legData.takeOff
        let landing = self.getUIViewByTagId(7+legNo*13) as! UITextField
        landing.text = legData.landing
        let blocksOn = self.getUIViewByTagId(8+legNo*13) as! UITextField
        blocksOn.text = legData.blocksOn
        let blockTime = self.getUIViewByTagId(9+legNo*13) as! UITextField
        blockTime.text = legData.blockTime
        let nightTime = self.getUIViewByTagId(10+legNo*13) as! UITextField
        nightTime.text = legData.nightTime
        let instTime = self.getUIViewByTagId(11+legNo*13) as! UITextField
        instTime.text = legData.instTime
        let toFlag = self.getUIViewByTagId(12+legNo*13) as! UITextField
        toFlag.text = legData.toFlag
        let landFlag = self.getUIViewByTagId(13+legNo*13) as! UITextField
        landFlag.text = legData.landFlag
        
        if let x =  legData.captainId {
            FlightLogEntity.sharedInstance.flightIdentifiers[0].sharedCaptainId = x
        }
        
        
        
    }
    
    
    
    
    func populateMatrix () -> Int? {
        var highestOrder:Int? = nil
        
        for i in 0...0 {
            for fltCrew in flightCrews {
                if ( FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo == fltCrew.fltNo &&
                    FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate == StringUtils.getDMYStringFromYMDString(fltCrew.date!)  &&
                    FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation == fltCrew.from ) {
                    highestOrder = i
                    
                    if let index = getMatrixElementByStaffNo(fltCrew.staffno!) {
                        switch i {
                        case 0 :crewMatrixList[index].status1 = fltCrew.status!
                        case 1 :crewMatrixList[index].status2 = fltCrew.status!
                        case 2 :crewMatrixList[index].status3 = fltCrew.status!
                        case 3 :crewMatrixList[index].status4 = fltCrew.status!
                        case 4 :crewMatrixList[index].status5 = fltCrew.status!
                        default : break
                        }
                        
                    } else {
                        var newCrewMatrix = CrewMatrix()
                        switch i {
                        case 0 :newCrewMatrix.status1 = fltCrew.status!
                        case 1 :newCrewMatrix.status2 = fltCrew.status!
                        case 2 :newCrewMatrix.status3 = fltCrew.status!
                        case 3 :newCrewMatrix.status4 = fltCrew.status!
                        case 4 :newCrewMatrix.status5 = fltCrew.status!
                        default : break
                        }
                        newCrewMatrix.pos = fltCrew.pos!
                        newCrewMatrix.name = MiscUtilsFltLog.getCrewNameByStaffNo(fltCrew.staffno!)
                        newCrewMatrix.staffno = fltCrew.staffno!
                        newCrewMatrix.stn = fltCrew.stn!
                        newCrewMatrix.gmt = fltCrew.gmt!
                        newCrewMatrix.flightNo = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo
                        newCrewMatrix.from = FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation
                        newCrewMatrix.date = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate
                        
                        
                        crewMatrixList.append(newCrewMatrix)
                        
                    }
                    
                }
            }
        }
        return highestOrder
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func removeCrewScheduleFromDB() {
        
        
        let legRequest = NSFetchRequest<CrewData>(entityName: "CrewData")
        let legList = try! context.fetch(legRequest)
        
        
        for bas: AnyObject in legList
        {
            
            let ld = bas as! CrewData
            
            if ( ld.source != "IPAD" ) {
                context.delete(bas as! NSManagedObject)
            }
            
        }
        
        do {
            try context.save()
        } catch _ {
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
        
        FlightLogService.getFlCrewList(userEntity.username!) { (flCrewArray, error) in
            
            if error == nil {
                
                if !flCrewArray!.isEmpty {
                    
                    self.removeCrewListFromDB()
                    
                    for flcrew in  flCrewArray!{
                        
                        
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
                        
                        
                    } catch let error as NSError {
                        print("Error occurred: \(error)")
                        
                    } catch {
                        fatalError()
                    }
                    
                    //self.Tableview.reloadData()
                    
                }else{
                    
                    //                    alert("Message", Body: "Crew Data not available")
                    Indicator.stop()
                    
                }
                
            }else{
                alert("Message", Body: error!)
                Indicator.stop()
                
            }
            
        }
        
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.count + string.count - range.length
        
        let integerCheckValid = validateIntegerCheck(textField, string: string)
        let lengthValid = newLength <= getMaxLength(textField) // Bool

        if !( lengthValid && integerCheckValid ) {
            textField.text = ""
        }
        
        return lengthValid && integerCheckValid
        
        
    }
    
    func getMaxLength(_ textField : UITextField) -> Int {
        
        if ( textField.tag < 50 ) {
            let type = self.getFieldTypeFromTag(textField.tag)
            
            if ( type != "" ) {
                switch (type) {
                case "Date" : return 8
                case "Flight" : return 5
                case "Station": return 3
                case "Time" : return 4
                case "Flag" : return 3
                default: return 10
                }
            }
        } else if ( textField.tag < 100 ) {
            let tag = textField.tag
            
            switch (tag) {
            case 51 : return 3
            case 52 : return 3
            case 53 : return 4
            case 54 : return 4
            case 55 : return 3
            default : return 999
            }
        } else {
            
            let tag = textField.tag
            
            switch (tag) {
            case 108 : return 6
            case 109 : return 3
            case 110 : return 6
            case 111 : return 6
            case 112 : return 6
            case 113 : return 6
            case 114 : return 6
            default : return 999
                
            }
        }
        
        return 10
    }
    


var arr: [[String]] =
    [
        ["AT5" ,   "4",   "4" ,   "4",     "5750" ,   "4",   "4" ,   "5000",    "5" ,   "18000"],
        ["AT7"   , "4",    "4" ,   "4",    "6400" ,   "4" ,   "4"  ,  "5500" ,   "5"  , "22000"],
        ["320"   , "5",   "5"  ,  "5" ,    "24000"  ,  "5"  ,  "5"   , "19000" ,   "5"  ,  "63500"],
        ["773"   , "6" ,   "6" ,   "6",    "182000" ,   "6" ,   "6" ,   "146500" ,   "6" ,   "239000"],
        ["777"   , "6" ,   "6",   "6" ,    "182000"  ,  "6" ,   "6"  ,  "146500"  ,  "6"  ,  "211000"],
        ["772"   , "6" ,   "6",    "6",    "171500" ,   "6",    "6" ,   "138500" ,   "6" ,   "201000"]
]


    func validateRagne(textElement:UITextField, AC:String ,  AStr:String,    BStr:String,   CStr:String,   DStr:String,    EStr:String,  ZStr:String) -> Bool {
    for a in arr {
        if ( AC == a[0]) {
            let A:Int = Int(AStr.isEmpty ? "0" : AStr)!
            let B:Int = Int(BStr.isEmpty ? "0" : BStr)!
            let C:Int = Int(CStr.isEmpty ? "0" : CStr)!
            let D:Int = Int(DStr.isEmpty ? "0" : DStr)!
            let E:Int = Int(EStr.isEmpty ? "0" : EStr)!
            let Z:Int = Int(ZStr.isEmpty ? "0" : ZStr)!
            
            let A_Length = Int(a[1])!
            let B_Length = Int(a[2])!
            let C_Length = Int(a[3])!
            let D_Length = Int(a[5])!
            let E_Length = Int(a[6])!
            let Z_Length = Int(a[8])!
            
            
            let BC_MaxValue = Int(a[4])!
            let ADE_MaxValue = Int(a[7])!
            let Z_MaxValue = Int(a[9])!
            
            if (A > 0 && A > ADE_MaxValue) {
                textElement.text = nil
                return false
            }
            if (D > 0 && D > ADE_MaxValue) {
                textElement.text = nil
                return false
            }
            if (E > 0 && E > ADE_MaxValue) {
                textElement.text = nil
                return false
            }
            if (B > 0 && B > BC_MaxValue) {
                textElement.text = nil
                return false
            }
            if (C > 0 && C > BC_MaxValue) {
                textElement.text = nil
                return false
            }
            if (Z > 0 && Z > Z_MaxValue) {
                textElement.text = nil
                return false
            }
            
        }
        
    }
    return true
}

    
    
    func validateIntegerCheck(_ textField : UITextField, string:String) -> Bool {
        
        let type = textField.tag
        
        switch (type) {
        case 1 : return isNumericOnly(string)
        case 53 : return isNumericOnly(string)
        case 54 : return isNumericOnly(string)
        case 108 : return isNumericOnly(string)
        case 109 : return isNumericOnly(string)
        case 110 : return isNumericOnly(string)
        case 111 : return isNumericOnly(string)
        case 112 : return isNumericOnly(string)
        case 113 : return isNumericOnly(string)
        case 114 : return isNumericOnly(string)
        default : return true
            
        }
    }
    
    func isWithinRange(ac:String, reg:String, tag:Int, num:Int) -> Bool {
        
        
        if ( ac == "320" || ac == "32L" ) {
            
            
        }
        return false
    }
    
    func isNumericOnly(_ string:String) -> Bool {
        
        let aSet = CharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
        
    }
    
    
    
    func fetchCrewScheduleFromJSON() {
        
        
        FlightLogService.getFlCrewScheduleList(userEntity.username!) { (flCrewScheduleArray, error) in
            
            if error == nil {
                
                if !flCrewScheduleArray!.isEmpty {
                    
                    self.removeCrewScheduleFromDB()
                    
                    for flcrewschedule in  flCrewScheduleArray!{
                        
                        
                        if ( !StringUtils.pastDataExists(flcrewschedule.date, flightNo: flcrewschedule.fltno, depStation: flcrewschedule.dep)) {
                            
                            let entityDescripition = NSEntityDescription.entity(forEntityName: "CrewData", in: context)
                            
                            let crewData = CrewData(entity: entityDescripition!, insertInto: context)
                            
                            crewData.source = "JSON"
                            crewData.fltNo = flcrewschedule.fltno
                            crewData.date = StringUtils.getYMDStringFromDMYString(flcrewschedule.date)
                            crewData.from = flcrewschedule.dep
                            crewData.sno = flcrewschedule.sno
                            crewData.pos = flcrewschedule.pos
                            crewData.staffno = flcrewschedule.staffno
                            crewData.status = flcrewschedule.status
                            crewData.stn = flcrewschedule.stn
                            crewData.gmt = flcrewschedule.gmt
                            
                            
                            
                            //                            if ( crewData.pos == "0" ) {
                            //                                let legDataReq = NSFetchRequest<LegData>(entityName: "LegData")
                            //
                            //
                            //                                let datePredicate = NSPredicate(format: "date = %@", crewData.date!)
                            //                                let fltNoPredicate = NSPredicate(format: "fltNo = %@", crewData.fltNo!)
                            //                                let fromPredicate = NSPredicate(format: "from = %@", crewData.from!)
                            //
                            //                                let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
                            //
                            //                                legDataReq.predicate = compound
                            //
                            //
                            //                                let data = try! context.fetch(legDataReq)
                            //
                            //                                for legData in data {
                            //                                    if ( legData.captainId == nil) {
                            //                                        legData.captainId = crewData.staffno
                            //                                    }
                            //                                }
                            //                            }
                            
                            
                            crewDataList.append(crewData)
                            
                        }
                        
                    }
                    
                    
                    do {
                        try context.save()
                        
                        self.fetchCrewListFromJSON()
                        
                    } catch let error as NSError {
                        print("Error occurred: \(error)")
                        
                    } catch {
                        fatalError()
                    }
                    //                                                            dispatch_async(dispatch_get_main_queue(), {
                    //                                        Indicator.stop()
                    //                                                            });
                    
                    //                    Indicator.stop()
                    //                    self.Tableview.reloadData()
                    
                    
                    
                    
                }else{
                    
                    //                    alert("Message", Body: "Fligh Data not available")
                    Indicator.stop()
                    
                }
                
            }else{
                alert("Message", Body: error!)
                Indicator.stop()
                
            }
            
        }
        
        
    }
    
    

    // variables to gold current data
    var picker : UIPickerView!
    var activeTextField = 0
    var activeTF : UITextField!
    var activeValue = ""
    
    
    
    var list_reg = [
    "320.BLA","320.BLB","320.BLC","320.BLS","320.BLT","320.BLU","320.BLZ","320.BOK","320.BOL","320.BOM","320.BON","320.BMV",
        "32A.BLV","32A.BLW","32A.BLY",
        "32B.BMX","32B.BMY",

        "777.BGY","777.BGZ",
        "772.BGJ","772.BGK","772.BGL","772.BHX",
        "773.BHV","773.BHW","773.BID",
        "77A.BMG","77A.BMH",
        "77W.BMS",
        
        "AT5.BHH","AT5.BHI","AT5.BHJ","AT5.BHM","AT5.BHP",
        "AT7.BKV","AT7.BKW","AT7.BKX","AT7.BKY","AT7.BKZ",
        
        
        "TBA.GRD","N/A.N/A"]
    
    
    var list_ac = ["","772","773","777","77A","77W","320","32A","32B","AT5","AT7","TBA","N/A"]
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    

    
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        if activeTextField == self.registration.tag {
        return getregistrationlistforac(ac: self.aircraftType.text).count
        } else if activeTextField == self.aircraftType.tag {
        return list_ac.count
        }
        
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if activeTextField == self.registration.tag {
            if ( self.aircraftType.text != "" ) {
            return getregistrationlistforac(ac: self.aircraftType.text)[row]
            }
        } else if activeTextField == self.aircraftType.tag {
            return list_ac[row]
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // set currect active value based on picker view
        switch activeTextField {
        case 51:
            activeValue = list_ac[row]
            self.aircraftType.text = activeValue
            self.registration.text = ""
        case 52:
            activeValue = getregistrationlistforac(ac: self.aircraftType.text)[row]
            self.registration.text = activeValue
        default:
            activeValue = ""
        }

        
    }
    
    func getregistrationlistforac(ac:String!) -> [String] {

        var modified_reg_list = list_reg.filter { $0.hasPrefix(self.aircraftType.text!  + ".") }
        modified_reg_list.insert("", at: 0)
        for i in 0 ..< modified_reg_list.count  {
           modified_reg_list[i] = modified_reg_list[i].replacingOccurrences(of: self.aircraftType.text!  + ".", with: "")
        }
        
        return modified_reg_list
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
//        if textField == self.registration {
//            currentPickerTextView = self.registration
//            self.myPickerview.isHidden = false
////            self.registration.isHidden = true
//            //if you dont want the users to se the keyboard type:
//
//            textField.endEditing(true)
//        } else if textField == self.aircraftType {
//            currentPickerTextView = self.aircraftType
//            self.myPickerview.isHidden = false
////            self.aircraftType.isHidden = true
//            //if you dont want the users to se the keyboard type:
//
//            textField.endEditing(true)
//        }
        
        // set up correct active textField (no)
        switch textField {
        case self.registration:
            activeTextField = 52
        case self.aircraftType:
            activeTextField = 51
        default:
            activeTextField = 0
        }
        
        if ( activeTextField == 51  || activeTextField == 52 ) {
        // set active Text Field
        activeTF = textField
        
        self.pickUpValue(textField: textField)
            
        }
        
        
        
    }
    
    
    // show picker view
    func pickUpValue(textField: UITextField) {
        
        // create frame and size of picker view
        picker = UIPickerView(frame:CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: 216)))
        
        // deletates
        picker.delegate = self
        picker.dataSource = self
        
        // if there is a value in current text field, try to find it existing list
        if let currentValue = textField.text {
            
            var row : Int?
            
            // look in correct array
            switch activeTextField {
            case 51:
                row = list_ac.index(of: currentValue)
            case 52:
                row = getregistrationlistforac(ac: self.aircraftType.text).index(of: currentValue)
            default:
                row = nil
            }
            
            // we got it, let's set select it
            if row != nil {
                picker.selectRow(row!, inComponent: 0, animated: true)
            }
        }
        
        //picker.backgroundColor = UIColor.white
        textField.inputView = self.picker
        
        // toolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.barTintColor = UIColor.darkGray
        toolBar.sizeToFit()
        
        // buttons for toolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    // done
    @objc func doneClick() {
        activeTF.text = activeValue
        activeTF.resignFirstResponder()
        
    }
    
    // cancel
    @objc func cancelClick() {
        activeTF.resignFirstResponder()
    }
    

    var cameraFileName:String? = nil
    
    @IBAction func openCameraDeliveryReceipt(_ sender: Any) {
        cameraFileName =  "_DeliveryReceipt.jpg"
                if UIImagePickerController.isSourceTypeAvailable(.camera)  {
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController, animated: true, completion: nil)
                }
    }
    
    
    @IBAction func openCameraFuelIndent(_ sender: Any) {
        cameraFileName =  "_FuelIndent.jpg"
                if UIImagePickerController.isSourceTypeAvailable(.camera)  {
                    let imagePickerController = UIImagePickerController()
                    imagePickerController.delegate = self
                    imagePickerController.sourceType = .camera
                    self.present(imagePickerController, animated: true, completion: nil)
                }
    }
    
    

    
    @IBOutlet weak var imageViewDeliveryReceipt: UIImageView!

    
    @IBOutlet weak var imageViewFuelIndent: UIImageView!
    

    override func viewDidAppear(_ animated: Bool) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var filename = documentsURL.appendingPathComponent(fltDate1.text! + "_" + fltNo1.text! + "_" + fromStation1.text!  + "_DeliveryReceipt.jpg")
        
        if (FileManager.default.fileExists(atPath: filename.path)) {
        let data = try? Data(contentsOf: filename) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            imageViewDeliveryReceipt.image = UIImage(data: data!)
        }
        
         filename = documentsURL.appendingPathComponent(fltDate1.text! + "_" + fltNo1.text! + "_" + fromStation1.text!  + "_FuelIndent.jpg")
        
        if (FileManager.default.fileExists(atPath: filename.path)) {
        let data = try? Data(contentsOf: filename) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            imageViewFuelIndent.image = UIImage(data: data!)
        }
        
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        if cameraFileName! ==  "_DeliveryReceipt.jpg" {
            imageViewDeliveryReceipt.image = image
        } else {
            imageViewFuelIndent.image = image
        }
        
//        if let image = UIImage(named: "example.png") {
        if let data = image?.jpegData(compressionQuality: 0.2) {
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filename = documentsURL.appendingPathComponent(fltDate1.text! + "_" + fltNo1.text! + "_" + fromStation1.text!  + cameraFileName!)
                try? data.write(to: filename)
            }
//        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func imageDeliveryReceiptTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "imageVC") as! ImagePreviewViewController
        vc.filename = fltDate1.text! + "_" + fltNo1.text! + "_" + fromStation1.text!  + "_DeliveryReceipt.jpg"
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        if (FileManager.default.fileExists(atPath: documentsURL.appendingPathComponent(vc.filename).path)) {
            self.present(vc, animated: false, completion: nil)
        }
        
    }
    
    
    @objc func imageFuelIndentTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "imageVC") as! ImagePreviewViewController
        vc.filename = fltDate1.text! + "_" + fltNo1.text! + "_" + fromStation1.text!  + "_FuelIndent.jpg"
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        if (FileManager.default.fileExists(atPath: documentsURL.appendingPathComponent(vc.filename).path)) {
            self.present(vc, animated: false, completion: nil)
        }
        
    }
    
    
}
