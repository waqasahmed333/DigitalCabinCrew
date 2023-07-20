//
//  Constants.swift

//
//  Created by Naveed Azhar on 29/04/2016.
//  Copyright © 2016 PIA. All rights reserved.
//

import UIKit


//alert view 

func alert(_ Title:String,Body:String){
    let message: UIAlertView = UIAlertView(title: Title, message: Body, delegate: nil, cancelButtonTitle: "OK")
    message.show()
}


// to get day , month and year

extension Date {
    
    func getDateComponents()-> (Int,Int,Int){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let y = Int(dateFormatter.string(from: self))!
        
        
        dateFormatter.dateFormat = "dd"
        let d = Int(dateFormatter.string(from: self))!
        
        
        dateFormatter.dateFormat = "MM"
        let m = Int(dateFormatter.string(from: self))!
        
        
        let datecomp = (d, m, y)
        
        return datecomp
        
    }
    
}
    //check file availabe
    
    extension String {
       
        func isFileAvailable()->Bool{
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let getImagePath = documentsURL.appendingPathComponent(self)
            
            let checkValidation = FileManager.default
            
            
            if (checkValidation.fileExists(atPath: getImagePath.path))
            {
                return true
            }
            else
            {
                return false
            }
        }
        
        func isAcknowledgementFileAvailable()->Bool{
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let getImagePath = documentsURL.appendingPathComponent(self)
            
            let checkValidation = FileManager.default
            
            if (checkValidation.fileExists(atPath: getImagePath.path + "_ack"))
            {
                return true
            }
            else
            {
                return false
            }
        }
        
        func createAcknowledgementFile()->Bool{
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let getImagePath = documentsURL.appendingPathComponent(self)
            
            let checkValidation = FileManager.default
            
            
            return checkValidation.createFile(atPath: getImagePath.path + "_ack", contents: nil, attributes: nil)

        
        }
        
        
        
    }


func stringToNsdate(_ date:Date)->String{
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy MMM, dd"
    let date = formatter.string(from: date)
    return date
}
