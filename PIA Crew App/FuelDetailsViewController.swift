//
//  FuelDetailsViewController.swift
//  FlightLog
//
//  Created by Naveed Azhar on 04/07/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData


var fuelMatrixList = [FuelMatrix]()

struct  FuelMatrix  {
    
    var fuelUpLiftQty: String = ""
    var fuelUplUnit: NSNumber = 0
    var density: String = ""
    var beforeRefuelingKGS: String = ""
    var totalUplift: String = ""
    var depKG: String = ""
    var arrKG: String = ""
    var zeroFuelWt: String = ""
    var toPwrFR: String = ""
    var cat23: NSNumber = 0
    var date: String = ""
    var fltNo: String = ""
    var reasonForExtraFuel: String = ""
    var from: String = ""
    var legNo:Int32 = 0
    
}

var acPackDataList = [ACPackData]()

//var acPackFuelDatas = [ACPackData]()

var acPackMatrixList = [ACPackMatrix]()

struct  ACPackMatrix {
    
    var cruiseDataLegNo: String = ""
    var date: String = ""
    var eGTTTL: String = ""
    var eGTTTR: String = ""
    var engineBleedL: String = ""
    var engineBleedR: String = ""
    var ePRTQL: String = ""
    var ePRTQR: String = ""
    var flightLevel: String = ""
    var fltNo: String = ""
    var from: String = ""
    var fuelFlowL: String = ""
    var fuelFlowR: String = ""
    var grossWeight: String = ""
    var ias: String = ""
    var mach: String = ""
    var n1NPL: String = ""
    var n1NPR: String = ""
    var n2NHL: String = ""
    var n2NHR: String = ""
    var nacTempL: String = ""
    var nacTempR: String = ""
    var oilTempL: String = ""
    var oilTempR: String = ""
    var oilPressL: String = ""
    var oilPressR: String = ""
    var sat: String = ""
    var tat: String = ""
    var vIBN1L: String = ""
    var vIBN1R: String = ""
    var vIBN2L: String = ""
    var vIBN2R: String = ""
    var legNo:Int32 = 0
    
}



class FuelDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var Tableview: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppSettings.refresh(self.view)

    }
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "Technical Details"
//        let b = UIBarButtonItem(
//            title: "Add",
//            style: .plain,
//            target: self,
//            action: #selector(FuelDetailsViewController.sayHello(_:))
//        )
//        self.tabBarController?.navigationItem.setRightBarButtonItems([b], animated: true)

        fetchFuelInfoFromDB()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func sayHello(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addFuelData", sender: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fuelMatrixList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.Tableview.dequeueReusableCell(withIdentifier: "cell") as! FuelDetailsTableViewCell
        
        //        cell.sno.text = "\(indexPath.row + 1)"
        cell.flightDetails.text =
            
        " PK-\(fuelMatrixList[(indexPath as NSIndexPath).row].fltNo) \(fuelMatrixList[(indexPath as NSIndexPath).row].from) "
    
        return cell
    }
    
    
    
//    func moveToNextController () {
//        
//        var fuelMatrix:FuelMatrix?  = nil
//        var acPackMatrix:ACPackMatrix?  = nil
//        
//
//            let cell = sender as! UITableViewCell
//            let indexPath = Tableview.indexPath(for: cell)
//            fuelMatrix = fuelMatrixList[(indexPath! as NSIndexPath).row] as FuelMatrix
//            acPackMatrix = acPackMatrixList[(indexPath! as NSIndexPath).row] as ACPackMatrix
//            
//        } else if segue.identifier == "addFuelData" {
//            
//            fuelMatrix = FuelMatrix()
//            acPackMatrix = ACPackMatrix()
//            
//        }
//        
//        taskController.fuelMatrix = fuelMatrix!
//        taskController.acPackMatrix = acPackMatrix!
//        
//    }
    func fetchFuelInfoFromDB() {
        print(#function, terminator: "")
        
        if ( FlightLogEntity.sharedInstance.flightIdentifiers.count == 0 ){
            FlightLogEntity.sharedInstance.initIdentifiers()
        }

        
        let datePredicate = NSPredicate(format: "primaryFltDate = %@",StringUtils.getYMDStringFromDMYString(FlightLogEntity.sharedInstance.flightIdentifiers[0].fltDate))
        let fltNoPredicate = NSPredicate(format: "primaryFltNo = %@", FlightLogEntity.sharedInstance.flightIdentifiers[0].fltNo)
        let fromPredicate = NSPredicate(format: "primaryFrom = %@", FlightLogEntity.sharedInstance.flightIdentifiers[0].depStation)
        
        let compound = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [datePredicate, fltNoPredicate, fromPredicate])
        
        let acPackFetchreq = NSFetchRequest<ACPackData>(entityName: "ACPackData")
        acPackFetchreq.predicate = compound
        
        do {
            let data = try context.fetch(acPackFetchreq)
            
            acPackDataList = data
            
            
        } catch {
            print ("Error")
        }
        
        
        populateMatrix ()
        
        
        
        DispatchQueue.main.async(execute: {
            self.Tableview.reloadData()
        });
        
        
    }
    
    
    
    
    
    func populateMatrix () -> Int? {
        fuelMatrixList.removeAll()
        acPackMatrixList.removeAll()
        let highestOrder:Int? = nil

        let legCount = FlightLogEntity.sharedInstance.getLegCount()
        
        for i in 0..<legCount  {
            var found:Bool = false
            
            for fltACPack in acPackDataList {
                if ( StringUtils.getDMYStringFromYMDString( fltACPack.date!) == FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate &&  fltACPack.fltNo!  == FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo && fltACPack.from!  == FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation ) {
                    
                    var acPackMatrix = ACPackMatrix()
                    acPackMatrix.flightLevel = fltACPack.flightLevel!
                    acPackMatrix.grossWeight = fltACPack.grossWeight!
                    acPackMatrix.tat = fltACPack.tat!
                    acPackMatrix.sat = fltACPack.sat!
                    acPackMatrix.mach = fltACPack.mach!
                    acPackMatrix.ias = fltACPack.ias!
                    acPackMatrix.ePRTQL = fltACPack.ePRTQL!
                    acPackMatrix.ePRTQR = fltACPack.ePRTQR!
                    acPackMatrix.n1NPL = fltACPack.n1NPL!
                    acPackMatrix.n1NPR = fltACPack.n1NPR!
                    acPackMatrix.eGTTTL = fltACPack.eGTTTL!
                    acPackMatrix.eGTTTR = fltACPack.eGTTTR!
                    acPackMatrix.n2NHL = fltACPack.n2NHL!
                    acPackMatrix.n2NHR = fltACPack.n2NHR!
                    acPackMatrix.fuelFlowL = fltACPack.fuelFlowL!
                    acPackMatrix.fuelFlowR = fltACPack.fuelFlowR!
                    acPackMatrix.engineBleedL = fltACPack.engineBleedL!
                    acPackMatrix.engineBleedR = fltACPack.engineBleedR!
                    acPackMatrix.vIBN1L = fltACPack.vIBN1L!
                    acPackMatrix.vIBN1R = fltACPack.vIBN1R!
                    acPackMatrix.vIBN2L = fltACPack.vIBN2L!
                    acPackMatrix.vIBN2R = fltACPack.vIBN2R!
                    acPackMatrix.oilPressL = fltACPack.oilPressL!
                    acPackMatrix.oilPressR = fltACPack.oilPressR!
                    acPackMatrix.oilTempL = fltACPack.oilTempL!
                    acPackMatrix.oilTempR = fltACPack.oilTempR!
                    acPackMatrix.nacTempL = fltACPack.nacTempL!
                    acPackMatrix.nacTempR = fltACPack.nacTempR!
                    acPackMatrixList.append(acPackMatrix)
                    found = true
                    
                }
            }
            if ( !found) {

                
                var newacPackMatrix = ACPackMatrix()
                newacPackMatrix.date = StringUtils.getDMYStringFromYMDString(FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate)
                newacPackMatrix.fltNo = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo
                newacPackMatrix.from = FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation
                newacPackMatrix.legNo = 0
                acPackMatrixList.append(newacPackMatrix)
                
            }
            
        }

//        for i in fuelMatrixList.count...4 {
//
//                var newFuelMatrix = FuelMatrix()
//                newFuelMatrix.date = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltDate
//                newFuelMatrix.fltNo = FlightLogEntity.sharedInstance.flightIdentifiers[i].fltNo
//                newFuelMatrix.from = FlightLogEntity.sharedInstance.flightIdentifiers[i].depStation
//                fuelMatrixList.append(newFuelMatrix)
//
//        }

        return highestOrder
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let taskController:EditFuelDataViewController = segue.destination as! EditFuelDataViewController
        
        var fuelMatrix:FuelMatrix?  = nil
        var acPackMatrix:ACPackMatrix?  = nil
        
        if segue.identifier == "editFuelData" {
            
            let cell = sender as! UITableViewCell
            let indexPath = Tableview.indexPath(for: cell)
            fuelMatrix = fuelMatrixList[(indexPath! as NSIndexPath).row] as FuelMatrix
            acPackMatrix = acPackMatrixList[(indexPath! as NSIndexPath).row] as ACPackMatrix
            
        } else if segue.identifier == "addFuelData" {
            
            fuelMatrix = FuelMatrix()
            acPackMatrix = ACPackMatrix()
            
        }
        

    }
    
    func removeFromDB() {
        
        
    }
}


