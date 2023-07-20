//
//  CrewRoster.swift

//
//  Created by Naveed Azhar on 29/04/2016.
//  Copyright © 2016 PIA. All rights reserved.
//

import UIKit

class CrewDuty {
    
    var ac:String!
    var dayIndex:Int32!
    var reg:String!
    var date:String!
    var duty:String!
    var dep:String!
    var arr:String!
    var std:String!
    var sta:String!
    var type:String!
    var dutyDetails:String!
    
    init(type:String, dayIndex:Int32, ac:String,reg:String, date:String, duty:String,dep:String, arr:String, std:String, sta:String, dutyDetails:String){
        self.type = type
        self.dayIndex = dayIndex
        self.ac = ac
        self.reg = reg
        self.date = date
        self.duty = duty
        self.dep = dep
        self.arr = arr
        self.std = std
        self.sta = sta
        self.dutyDetails = dutyDetails
    }
}

class CrewRoster {
    
    
    var crewId:String!
    var startDate:String!
    var endDate:String!
    var duties=[CrewDuty]()
    
    
    init(crewId:String,startDate:String, endDate:String, duties:[CrewDuty]){
        
        self.crewId = crewId
        self.startDate = startDate
        self.endDate = endDate
        self.duties = duties
    }
    
    
}
