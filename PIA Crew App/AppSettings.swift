//
//  AppSettings.swift
//  FlightLog
//
//  Created by Naveed Azhar on 26/07/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit
import CoreData


class AppSettings: NSObject {
    
    
    class Colors {
        let colorTop = UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0.0, green: 96.0/255, blue: 0.0, alpha: 1.0).cgColor
        
        let gl: CAGradientLayer
        
        init() {
            gl = CAGradientLayer()
            gl.colors = [ colorTop, colorBottom]
            gl.locations = [ 0.0, 1.0]
        }
    }
    
    static let colors = Colors()
    
    class func refresh(_ view:UIView) {
//        view.backgroundColor = UIColor.clearColor()
//        let backgroundLayer = colors.gl
//        backgroundLayer.frame = view.frame
//        view.layer.insertSublayer(backgroundLayer, atIndex: 0)
    }



    static var settings = [AppSetting]()
    
    
    class func getParameter(_ name:String, defaultValue:String) -> String {
        
        let fetchreq = NSFetchRequest<AppSetting>(entityName: "AppSetting")
        let data = try! context.fetch(fetchreq) 
        
        settings = data
        
        let filteredArray = settings.filter( { (entity: AppSetting) -> Bool in
            return entity.name == name
        })
        
        if ( filteredArray.count == 1 ) {
            
            return filteredArray[0].value!
            
        }
        return defaultValue
        
    }
    
    class func setParameter(_ name:String, value:String) {
        
        
        let fetchreq = NSFetchRequest<AppSetting>(entityName: "AppSetting")
        let data = try! context.fetch(fetchreq) 
        
        settings = data
        
        let filteredArray = settings.filter( { (entity: AppSetting) -> Bool in
            return entity.name == name
        })
        
        if ( filteredArray.count == 0 ) {
            let entityDescripition = NSEntityDescription.entity(forEntityName: "AppSetting", in: context)
            
            let appSetting = AppSetting(entity: entityDescripition!, insertInto: context)
            
            appSetting.name = name
            appSetting.value = value
            
            do {
                try context.save()
            } catch _ {
            }
        } else if ( filteredArray.count == 1 ) {
            
            filteredArray[0].value = value
            
            do {
                try context.save()
            } catch _ {
            }
            
        }
        
    }
}
