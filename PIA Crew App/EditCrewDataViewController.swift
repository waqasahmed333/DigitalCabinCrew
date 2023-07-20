//
//  EditCrewDataViewController.swift
//  FlightLog
//
//  Created by Naveed Azhar on 04/08/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData
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



class EditCrewDataViewController: UIViewController, UITextFieldDelegate {
    
    var crewMatrix:CrewMatrix = CrewMatrix()
    
    var otherSimilarCrew : [String] = []
    
    
    @IBOutlet weak var crewId: UITextField!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var pos: UITextField!
    
    @IBOutlet weak var status1: UITextField!
    
    @IBOutlet weak var status2: UITextField!
    
    @IBOutlet weak var status3: UITextField!
    
    @IBOutlet weak var status4: UITextField!
    
    @IBOutlet weak var status5: UITextField!
    
    @IBOutlet weak var station: UITextField!
    
    @IBOutlet weak var dutyStart: UITextField!
    
    
    var segueName:String?
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let segue = segueName , segue == "edit" {
            self.navigationItem.title = "Edit"

        }else{
            self.navigationItem.title = "Add"
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        AppSettings.refresh(self.view)
        self.crewId.text = crewMatrix.staffno
        self.name.text = crewMatrix.name
        self.pos.text = crewMatrix.pos
        self.status1.text = crewMatrix.status1
        self.status2.text = crewMatrix.status2
        self.status3.text = crewMatrix.status3
        self.status4.text = crewMatrix.status4
        self.status5.text = crewMatrix.status5
        self.station.text = crewMatrix.stn
        self.dutyStart.text = crewMatrix.gmt
        
        if  ( crewMatrix.staffno != "" ) {
            self.crewId.isEnabled = false
        }

        
        for i in 0..<FlightLogEntity.sharedInstance.flightIdentifiers.count {
            
            if (FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate != "" && FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation != "" ) {
                switch i {
                case 0 :self.status1.isEnabled = true
                case 1 :self.status2.isEnabled = true
                case 2 :self.status3.isEnabled = true
                case 3 :self.status4.isEnabled = true
                case 4 :self.status5.isEnabled = true
                default:return
                }
            } else {
                switch i {
                case 0 :self.status1.isEnabled = false
                case 1 :self.status2.isEnabled = false
                case 2 :self.status3.isEnabled = false
                case 3 :self.status4.isEnabled = false
                case 4 :self.status5.isEnabled = false
                default:return
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    private func save() {
        
        if (EDIT_MODE != 1 ) { return }
        
        if ( crewMatrix.staffno != "" ) {
            
            let fetchreq = NSFetchRequest<CrewData>(entityName: "CrewData")
            
            for i in 0..<FlightLogEntity.sharedInstance.flightIdentifiers.count {
                
                if ( FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation != "" ) {
                    
                    for c in 0..<self.otherSimilarCrew.count {
                        
                        if ( self.crewMatrix.staffno == self.otherSimilarCrew[c] ) {
                            let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate))
                            let fltNoPredicate = NSPredicate(format: "fltNo = %@", FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo)
                            let fromPredicate = NSPredicate(format: "from = %@", FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation)
                            
                            let pnoPredicate = NSPredicate(format: "staffno = %@", self.otherSimilarCrew[c])
                            
                            let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate, pnoPredicate])
                            
                            fetchreq.predicate = compound
                            
                            
                            let data = try! context.fetch(fetchreq)
                            
                            for crewData in data {
                                crewData.source = "IPAD"
                                crewData.gmt = self.dutyStart.text
                                crewData.stn = self.station.text
                                switch i {
                                case 0:crewData.status = self.status1.text
                                case 1:crewData.status = self.status2.text
                                case 2:crewData.status = self.status3.text
                                case 3:crewData.status = self.status4.text
                                case 4:crewData.status = self.status5.text
                                default:crewData.status = self.status1.text
                                }
                                
                                do {
                                    try context.save()
                                } catch _ {
                                }
                                
                            }
                            
                            
                        }
                    }
                }
            }
            
            do {
                try context.save()
            } catch _ {
            }
        }
        else {
            for i in 0..<FlightLogEntity.sharedInstance.flightIdentifiers.count {
                
                if ( FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation != "" ) {
                    
                    StringUtils.removeExistingCrewFromFlight(flightDate: StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate), flightNo: FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo, depStation: FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation, staffno: self.crewId.text!)
                    
                    
                    let entityDescripition = NSEntityDescription.entity(forEntityName: "CrewData", in: context)
                    
                    let crewData = CrewData(entity: entityDescripition!, insertInto: context)
                    
                    crewData.source = "IPAD"
                    crewData.primaryDate = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate
                    crewData.primaryFltNo = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
                    crewData.primaryFrom = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation
                    crewData.fltNo = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo
                    crewData.date = StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate)
                    crewData.from = FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation
                    crewData.sno = crewMatrix.sno
                    crewData.pos = self.pos.text
                    crewData.staffno = self.crewId.text
                    switch i {
                    case 0:crewData.status = self.status1.text
                    case 1:crewData.status = self.status2.text
                    case 2:crewData.status = self.status3.text
                    case 3:crewData.status = self.status4.text
                    case 4:crewData.status = self.status5.text
                    default:crewData.status = self.status1.text
                    }
                    crewData.stn = self.station.text
                    crewData.gmt = self.dutyStart.text
                    
                    
                    
                    
                    do {
                        try context.save()
                    } catch _ {
                    }
                    
                }
                
                
            }
            
            do {
                try context.save()
            } catch _ {
            }
            
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        
        self.view.endEditing(true)
        
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        
        var message:String = ""
        if StringUtils.isEmptyValue(str: self.dutyStart.text) { message = "Crew ID \(self.crewId.text) :Please provide gmt."}
        if StringUtils.isEmptyValue(str: self.pos.text) { message = "Crew ID \(self.crewId.text) :Please provide pos."}
        if StringUtils.isEmptyValue(str: self.crewId.text) { message = "Crew ID \(self.crewId.text) :Please provide staffno."}
        if StringUtils.isEmptyValue(str: self.status1.text) { message = "Crew ID \(self.crewId.text) :Please provide status."}
        if StringUtils.isEmptyValue(str: self.station.text) { message = "Crew ID \(self.crewId.text) :Please provide stn."}
        
        if ( message == "" ) {
        self.save()
        }

        
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if ( EDIT_MODE != 1 ) {
            return false
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.uppercased()
        if textField.tag == 1 {
            self.name.text =  MiscUtilsFltLog.getCrewNameByStaffNo(textField.text!)
            self.pos.text =  MiscUtilsFltLog.getCrewPosByStaffNo(textField.text!)
        }
        else if textField.tag == 5 {
            let s = textField.text!
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
        }
// removed after noticing that Keyboard does not close after back from "Add Crew"
//        if ( textField.text == "") {
//            textField.becomeFirstResponder()
//        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = textField.text!.count + string.count - range.length
        
        return newLength <= getMaxLength(textField) // Bool
    }
    
    func getMaxLength(_ textField : UITextField) -> Int {
        
        let type = textField.tag
        
        switch (type) {
        case 1 : return 5
        case 2,6...10 : return 1
        case 3: return 50
        case 4: return 3
        case 5: return 4
        default : return 1
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
}
