//
//  SideMenuVC.swift
//  PIA Crew App
//
//  Created by Admin on 08/09/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData

protocol crewDataDelegate {
    func sendData(_ acPackMatrix:ACPackMatrix)
}

class SideMenuVC: UIViewController{

    var fuelMatrix:FuelMatrix = FuelMatrix()
    
    var acPackMatrix:ACPackMatrix = ACPackMatrix()
    
    var delegate:crewDataDelegate?
    
    
    @IBOutlet weak var flightLevel: UITextField!
    
    @IBOutlet weak var grossWeight: UITextField!
    
    @IBOutlet weak var TAT: UITextField!
    
    @IBOutlet weak var SAT: UITextField!
    
    @IBOutlet weak var MACH: UITextField!
    
    @IBOutlet weak var IAS: UITextField!
    
    @IBOutlet weak var EPRTQL: UITextField!
    
    @IBOutlet weak var EPRTQR: UITextField!
    
    @IBOutlet weak var N1NPL: UITextField!
    
    @IBOutlet weak var N1NPR: UITextField!
    
    
    @IBOutlet weak var EGGITTL: UITextField!
    
    @IBOutlet weak var EGGITTR: UITextField!
    
    @IBOutlet weak var N2NHL: UITextField!
    
    @IBOutlet weak var N2NHR: UITextField!
    
    @IBOutlet weak var FuelFlowL: UITextField!
    
    @IBOutlet weak var FuelFlowR: UITextField!
    
    @IBOutlet weak var EngineBleedL: UISegmentedControl!
    
    @IBOutlet weak var EngineBleedR: UISegmentedControl!
    
    @IBOutlet weak var VIBN1L: UITextField!
    
    @IBOutlet weak var VIBN1R: UITextField!
    
    @IBOutlet weak var VIBN2L: UITextField!
    
    @IBOutlet weak var VIBN2R: UITextField!
    
    @IBOutlet weak var OilPressL: UITextField!
    
    @IBOutlet weak var OilPressR: UITextField!
    
    @IBOutlet weak var OilTempL: UITextField!
    
    @IBOutlet weak var OilTempR: UITextField!
    
    @IBOutlet weak var NACTempL: UITextField!
    
    @IBOutlet weak var NACTempR: UITextField!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
                self.flightLevel.text = acPackMatrix.flightLevel
        
                self.grossWeight.text = acPackMatrix.grossWeight
        
                self.TAT.text = acPackMatrix.tat
        
                self.SAT.text = acPackMatrix.sat
        
                self.MACH.text = acPackMatrix.mach
        
                self.IAS.text = acPackMatrix.ias
        
                self.EPRTQL.text = acPackMatrix.ePRTQL
        
                self.EPRTQR.text = acPackMatrix.ePRTQR
        
                self.N1NPL.text = acPackMatrix.n1NPL
        
                self.N1NPR.text = acPackMatrix.n1NPR
        
        
                self.EGGITTL.text = acPackMatrix.eGTTTL
        
                self.EGGITTR.text = acPackMatrix.eGTTTR
        
                self.N2NHL.text = acPackMatrix.n2NHL
        
                self.N2NHR.text = acPackMatrix.n2NHR
        
                self.FuelFlowL.text = acPackMatrix.fuelFlowL
        
                self.FuelFlowR.text = acPackMatrix.fuelFlowR
        
                self.EngineBleedL.selectedSegmentIndex = (acPackMatrix.engineBleedL == "" ) ? 0 : 1
        
                self.EngineBleedR.selectedSegmentIndex = (acPackMatrix.engineBleedR == "" ) ? 0 : 1
        
                self.VIBN1L.text = acPackMatrix.vIBN1L
        
                self.VIBN1R.text = acPackMatrix.vIBN1R
        
                self.VIBN2L.text = acPackMatrix.vIBN2L
        
                self.VIBN2R.text = acPackMatrix.vIBN2R
        
                self.OilPressL.text = acPackMatrix.oilPressL
                
                self.OilPressR.text = acPackMatrix.oilPressR
                
                self.OilTempL.text = acPackMatrix.oilTempL
                
                self.OilTempR.text = acPackMatrix.oilTempR
                
                self.NACTempL.text = acPackMatrix.nacTempL
                
                self.NACTempR.text = acPackMatrix.nacTempR
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {

//        if ( fuelMatrix.legNo == 0 ) {
//        let acPackEntityDescripition = NSEntityDescription.entityForName("ACPackData", inManagedObjectContext: context)
//        
//        let acPackData = ACPackData(entity: acPackEntityDescripition!, insertIntoManagedObjectContext: context)
        
//        acPackData.date = StringUtils.getYMDStringFromDMYString(fuelMatrix.date)
//        acPackData.fltNo = fuelMatrix.fltNo
//        acPackData.from = fuelMatrix.from
//        acPackData.primaryFltDate = StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate)
//        acPackData.primaryFltNo = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
//        acPackData.primaryFrom = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation
//        acPackData.flightLevel = self.flightLevel.text!
//        acPackData.grossWeight = self.grossWeight.text!
//        acPackData.tat = self.TAT.text!
//        acPackData.sat = self.SAT.text!
//        acPackData.mach = self.MACH.text!
//        acPackData.ias = self.IAS.text!
//        acPackData.ePRTQL = self.EPRTQL.text!
//        acPackData.ePRTQR = self.EPRTQR.text!
//        acPackData.n1NPL = self.N1NPL.text!
//        acPackData.n1NPR = self.N1NPR.text!
//        acPackData.eGTTTL = self.EGGITTL.text!
//        acPackData.eGTTTR = self.EGGITTR.text!
//        acPackData.n2NHL = self.N2NHL.text!
//        acPackData.n2NHR = self.N2NHR.text!
//        acPackData.fuelFlowL = self.FuelFlowL.text!
//        acPackData.fuelFlowR = self.FuelFlowR.text!
//        acPackData.engineBleedL = String(self.EngineBleedL.selectedSegmentIndex)
//        acPackData.engineBleedR = String(self.EngineBleedR.selectedSegmentIndex)
//        acPackData.vIBN1L = self.VIBN1L.text!
//        acPackData.vIBN1R = self.VIBN1R.text!
//        acPackData.vIBN2L = self.VIBN2L.text!
//        acPackData.vIBN2R = self.VIBN2R.text!
//        acPackData.oilPressL = self.OilPressL.text!
//        acPackData.oilPressR = self.OilPressR.text!
//        acPackData.oilTempL = self.OilTempL.text!
//        acPackData.oilTempR = self.OilTempR.text!
//        acPackData.nacTempL = self.NACTempL.text!
//        acPackData.nacTempR = self.NACTempR.text!
//        } else {
//            let datePredicate = NSPredicate(format: "date = %@", StringUtils.getYMDStringFromDMYString(fuelMatrix.date))
//            let fltNoPredicate = NSPredicate(format: "fltNo = %@", fuelMatrix.fltNo)
//            let fromPredicate = NSPredicate(format: "from = %@", fuelMatrix.from)
//            
//            let compound = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
//            
//                        let acPackFetchreq = NSFetchRequest<ACPackData>(entityName: "ACPackData")
//                        acPackFetchreq.predicate = compound
//                        let acPackDataList = try! context.executeFetchRequest(acPackFetchreq)
//            
//            for acPackData in acPackDataList {
//                acPackData.date = StringUtils.getYMDStringFromDMYString(fuelMatrix.date)
//                acPackData.fltNo = fuelMatrix.fltNo
//                acPackData.from = fuelMatrix.from
//                acPackData.primaryFltDate = StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate)
//                acPackData.primaryFltNo = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
//                acPackData.primaryFrom = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation
//                acPackData.flightLevel = self.flightLevel.text!
//                acPackData.grossWeight = self.grossWeight.text!
//                acPackData.tat = self.TAT.text!
//                acPackData.sat = self.SAT.text!
//                acPackData.mach = self.MACH.text!
//                acPackData.ias = self.IAS.text!
//                acPackData.ePRTQL = self.EPRTQL.text!
//                acPackData.ePRTQR = self.EPRTQR.text!
//                acPackData.n1NPL = self.N1NPL.text!
//                acPackData.n1NPR = self.N1NPR.text!
//                acPackData.eGTTTL = self.EGGITTL.text!
//                acPackData.eGTTTR = self.EGGITTR.text!
//                acPackData.n2NHL = self.N2NHL.text!
//                acPackData.n2NHR = self.N2NHR.text!
//                acPackData.fuelFlowL = self.FuelFlowL.text!
//                acPackData.fuelFlowR = self.FuelFlowR.text!
//                acPackData.engineBleedL = String(self.EngineBleedL.selectedSegmentIndex)
//                acPackData.engineBleedR = String(self.EngineBleedR.selectedSegmentIndex)
//                acPackData.vIBN1L = self.VIBN1L.text!
//                acPackData.vIBN1R = self.VIBN1R.text!
//                acPackData.vIBN2L = self.VIBN2L.text!
//                acPackData.vIBN2R = self.VIBN2R.text!
//                acPackData.oilPressL = self.OilPressL.text!
//                acPackData.oilPressR = self.OilPressR.text!
//                acPackData.oilTempL = self.OilTempL.text!
//                acPackData.oilTempR = self.OilTempR.text!
//                acPackData.nacTempL = self.NACTempL.text!
//                acPackData.nacTempR = self.NACTempR.text!
//            }
        
//        }

        
        acPackMatrix.date = StringUtils.getYMDStringFromDMYString(fuelMatrix.date)
        acPackMatrix.fltNo = fuelMatrix.fltNo
        acPackMatrix.from = fuelMatrix.from
//        acPackMatrix.primaryFltDate = StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate)
//        acPackMatrix.primaryFltNo = FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo
//        acPackMatrix.primaryFrom = FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation
        acPackMatrix.flightLevel = self.flightLevel.text!
        acPackMatrix.grossWeight = self.grossWeight.text!
        acPackMatrix.tat = self.TAT.text!
        acPackMatrix.sat = self.SAT.text!
        acPackMatrix.mach = self.MACH.text!
        acPackMatrix.ias = self.IAS.text!
        acPackMatrix.ePRTQL = self.EPRTQL.text!
        acPackMatrix.ePRTQR = self.EPRTQR.text!
        acPackMatrix.n1NPL = self.N1NPL.text!
        acPackMatrix.n1NPR = self.N1NPR.text!
        acPackMatrix.eGTTTL = self.EGGITTL.text!
        acPackMatrix.eGTTTR = self.EGGITTR.text!
        acPackMatrix.n2NHL = self.N2NHL.text!
        acPackMatrix.n2NHR = self.N2NHR.text!
        acPackMatrix.fuelFlowL = self.FuelFlowL.text!
        acPackMatrix.fuelFlowR = self.FuelFlowR.text!
        acPackMatrix.engineBleedL = String(self.EngineBleedL.selectedSegmentIndex)
        acPackMatrix.engineBleedR = String(self.EngineBleedR.selectedSegmentIndex)
        acPackMatrix.vIBN1L = self.VIBN1L.text!
        acPackMatrix.vIBN1R = self.VIBN1R.text!
        acPackMatrix.vIBN2L = self.VIBN2L.text!
        acPackMatrix.vIBN2R = self.VIBN2R.text!
        acPackMatrix.oilPressL = self.OilPressL.text!
        acPackMatrix.oilPressR = self.OilPressR.text!
        acPackMatrix.oilTempL = self.OilTempL.text!
        acPackMatrix.oilTempR = self.OilTempR.text!
        acPackMatrix.nacTempL = self.NACTempL.text!
        acPackMatrix.nacTempR = self.NACTempR.text!
        
        
        self.delegate?.sendData(acPackMatrix)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
