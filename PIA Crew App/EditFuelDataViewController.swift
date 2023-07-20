//
//  EditFuelDataViewController.swift
//  FlightLog
//
//  Created by Naveed Azhar on 23/08/2015.
//  Copyright © 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData

class EditFuelDataViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var currentTagEditing = 0
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var txtDate: UITextField!
    
    @IBOutlet weak var txtFltNo: UITextField!
    
    @IBOutlet weak var txtReg: UITextField!
    
    @IBOutlet weak var txtBlkOff: UITextField!
    
    @IBOutlet weak var txtDepDelay: UITextField!
    
    @IBOutlet weak var txtBlkOn: UITextField!
    
    @IBOutlet weak var txtArrDelay: UITextField!
    
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
    
    @IBAction func checkBoxClicked(_ sender: AnyObject) {
        self.saveData()
    }
    
    @IBAction func depDelayCNSQClicked(_ sender: Any) {
        
        if (self.btnDepDelayCNSQ.isChecked && !self.txtDepDelay.text!.contains("C"))  {
            self.txtDepDelay.text = self.txtDepDelay.text! + "C"
        }
        
        if (!self.btnDepDelayCNSQ.isChecked )  {
            self.txtDepDelay.text = self.txtDepDelay.text!.replacingOccurrences(of: "C", with: "")
        }

    }
    

    @IBAction func arrDelayCNSQClicked(_ sender: Any) {
        if (self.btnArrDelayCNSQ.isChecked && !self.txtArrDelay.text!.contains("C"))  {
            self.txtArrDelay.text = self.txtArrDelay.text! + "C"
        }
        
        if (!self.btnArrDelayCNSQ.isChecked && !self.txtArrDelay.text!.contains("C"))  {
            self.txtArrDelay.text = self.txtArrDelay.text!.replacingOccurrences(of: "C", with: "")
        }
    }

    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.saveData()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        AppSettings.refresh(self.view)
        
        let systemVersion = Int(UIDevice.current.systemVersion.components(separatedBy: ".").first!)
        if ( systemVersion! < 11 ) {
            textView.contentInset = UIEdgeInsets(top: -70.0,left: 0.0,bottom: 0,right: 0.0);
        }
        
        if #available(iOS 12.0, *) {
            MiscUtils.setupUITextView(textView: textView, userInterfaceStyle: traitCollection.userInterfaceStyle)
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view.
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        currentTagEditing = textView.tag
        
        if ( EDIT_MODE != 1 ) {
            return false
        }
        return true
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            
        if ( EDIT_MODE != 1 ) {
            return false
        }
        return true
    }
    
    private func saveData() {
        
        if (EDIT_MODE != 1 ) { return }
        
        
        let datePredicate = NSPredicate(format: "primaryDate = %@",StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate))
        let fltNoPredicate = NSPredicate(format: "primaryFltNo = %@", FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo)
        let fromPredicate = NSPredicate(format: "primaryFrom = %@", FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation)
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
        
        
        
        let acPackFetchreq = NSFetchRequest<LegData>(entityName: "LegData")
        acPackFetchreq.predicate = compound
        
        do {
            let data : [LegData] = try context.fetch(acPackFetchreq)
            
            if ( data.count > 0 ) {
                let  legData = data[0]
                legData.captainDebrief = self.textView.text
                legData.depDelay = self.txtDepDelay.text
                legData.arrDelay = self.txtArrDelay.text
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
            }

            
            try context.save()
            
        } catch {
            print ("Error")
        }
        
    }
    
    
    @IBAction func addFrequency(_ sender: Any) {
        
        let button:Checkbox = sender as! Checkbox
        var freq = button.titleLabel!.text!
        if (!button.isChecked) {
        if ( !self.textView.text.contains("{FREQ:\(freq)}")) {
            self.textView.text += "{FREQ:\(freq)}"
        }
        } else {
            self.textView.text = self.textView.text.replacingOccurrences(of: "{FREQ:\(freq)}", with: "")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditFuelDataViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditFuelDataViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        self.tabBarController?.navigationItem.title = "Captain's De-Brief"
        
        self.tabBarController?.navigationItem.rightBarButtonItems?.removeAll()
        
        
        //        let b = UIBarButtonItem(
        //            title: "Add",
        //            style: .plain,
        //            target: self,
        //            action: #selector(FuelDetailsViewController.sayHello(_:))
        //        )
        //        self.tabBarController?.navigationItem.setRightBarButtonItems([b], animated: true)
        
               fetchFuelInfoFromDB()
        //
        //        fuelMatrix = fuelMatrixList[0] as FuelMatrix
        //        acPackMatrix = acPackMatrixList[0] as ACPackMatrix
        
    }
    
    func fetchFuelInfoFromDB() {
        print(#function, terminator: "")
        
        if ( FlightLogEntity.sharedInstance.flightIdentifiers.count == 0 ){
            FlightLogEntity.sharedInstance.initIdentifiers()
        }
        
        
        let datePredicate = NSPredicate(format: "primaryDate = %@",StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate))
        let fltNoPredicate = NSPredicate(format: "primaryFltNo = %@", FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo)
        let fromPredicate = NSPredicate(format: "primaryFrom = %@", FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation)
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
        
        
        
        let acPackFetchreq = NSFetchRequest<LegData>(entityName: "LegData")
        acPackFetchreq.predicate = compound
        
        do {
            let data = try context.fetch(acPackFetchreq)
            
            if ( data.count > 0 ) {
                self.textView.text = data[0].captainDebrief
                self.txtDate.text = data[0].date
                self.txtFltNo.text = data[0].fltNo
                self.txtReg.text = data[0].reg
                self.txtBlkOff.text = data[0].blocksOff

                self.txtBlkOn.text = data[0].blocksOn
                self.txtArrDelay.text = data[0].blocksOn
                
                self.btnDblDept1.isChecked = data[0].dblDept1 == 1
                self.btnDblDept2.isChecked = data[0].dblDept2 == 1
                self.btnDblDept3.isChecked = data[0].dblDept3 == 1
                self.btnDblDept4.isChecked = data[0].dblDept4 == 1
                self.btnDblDept5.isChecked = data[0].dblDept5 == 1
                self.btnDblDept6.isChecked = data[0].dblDept6 == 1
                self.btnDblDept7.isChecked = data[0].dblDept7 == 1
                self.btnDblDept8.isChecked = data[0].dblDept8 == 1
                self.btnDepDelayCNSQ.isChecked = data[0].flag1 == 1
                self.btnArrDelayCNSQ.isChecked = data[0].flag2 == 1
                

                
                
                let std = data[0].std
                let sta = data[0].sta
                
                if ( self.txtBlkOff.text != ""  && std != "") {
                    let std_val = StringUtils.getMinutesFromHHMM(std!)
                    
                    let blkoff_val = StringUtils.getMinutesFromHHMM(self.txtBlkOff.text!)
                    
                    var delaytime =  blkoff_val - std_val
                    
                    if ( delaytime < 0 ) {
                        delaytime += 1440;
                    }
                    
                    if ( delaytime > 1390 || data[0].blocksOn == data[0].blocksOff) {
                        delaytime = 0
                    }
                    
                    self.txtDepDelay.text = "\(StringUtils.getHHMMFromMinutes(delaytime))"

                    if (self.btnDepDelayCNSQ.isChecked && !self.txtDepDelay.text!.contains("C"))  {
                        self.txtDepDelay.text = self.txtDepDelay.text! + "C"
                    }
                }
                
                if ( self.txtBlkOn.text != ""  && std != "") {
                    let std_val = StringUtils.getMinutesFromHHMM(sta!)
                    
                    let blkon_val = StringUtils.getMinutesFromHHMM(self.txtBlkOn.text!)
                    
                    var delaytime =  blkon_val - std_val
                    
                    if ( delaytime < 0 ) {
                        delaytime += 1440;
                    }
                    
                    if ( delaytime > 1390 || data[0].blocksOn == data[0].blocksOff) {
                        delaytime = 0
                    }
                    
                    self.txtArrDelay.text = "\(StringUtils.getHHMMFromMinutes(delaytime))"
                    
                    if (self.btnArrDelayCNSQ.isChecked && !self.txtArrDelay.text!.contains("C"))  {
                        self.txtArrDelay.text = self.txtArrDelay.text! + "C"
                    }
                    
                }
                
            }
            
            
            
        } catch {
            print ("Error")
        }
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

        
        self.saveData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        
        if ( currentTagEditing == 0 ) {
            return
        }
        var keyboardHeight:CGFloat = 0
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // fieldBottomConstant.constant = keyboardSize.height
            keyboardHeight = keyboardSize.height
        }
        
        bottomConstraint.constant = keyboardHeight  - 50
        
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        
        bottomConstraint.constant = 100
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
             

    }
    
}
