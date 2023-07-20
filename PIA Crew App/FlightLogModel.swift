//
//  FlightLogModel.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 02/07/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit

class FLCrew {
    
    var designation:String!
    var staffNo:String!
    var base:String!
    var name:String!
    var passcode:String!
    var dob:String!
    
    init(designation:String, staffNo:String, base:String,name:String, passcode:String,dob:String){

        self.designation = designation
        self.staffNo = staffNo
        self.base = base
        self.name = name
        self.passcode = passcode
        self.dob = dob
    }
}

class FLCrewSchedule {
    
    var fltno:String!
    var date:String!
    var dep:String!
    var sno:String!
    var pos:String!
    var staffno:String!
    var status:String!
    var stn:String!
    var gmt:String!
    
    init(fltno:String, date:String, dep:String,sno:String,pos:String, staffno:String, status:String,stn:String,gmt:String){
        
        self.fltno = fltno
        self.date = date
        self.dep = dep
        self.sno = sno
        self.pos = pos
        self.staffno = staffno
        self.status = status
        self.stn = stn
        self.gmt = gmt

    }
}


class FLFlightInfo {
    
    var date:String!
    var flight:String!
    var dep:String!
    var arr:String!
    var std:String!
    var sta:String!
    var aircraft:String!
    var reg:String!
    
    
    init(date:String, flight:String, dep:String,arr:String,std:String, sta:String, aircraft:String,reg:String){
        
        self.date = date
        self.flight = flight
        self.dep = dep
        self.arr = arr
        self.std = std
        self.sta = sta
        self.aircraft = aircraft
        self.reg = reg
        
    }
}

