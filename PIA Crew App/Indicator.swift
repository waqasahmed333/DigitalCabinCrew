//
//  Indicator.swift

//
//  Created by Naveed Azhar on 29/04/2016.
//  Copyright © 2016 PIA. All rights reserved.
//

import UIKit
import SpringIndicator



class Indicator
{
    static fileprivate let indicator = SpringIndicator(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    
    static fileprivate var backView:UIView!
    
    static func start(_ Self:UIViewController){
        
        backView = UIView(frame:  UIApplication.shared.keyWindow!.frame)
        backView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8)
        
        indicator.lineColor = UIColor(red:0.0/255.0,green:133/255.0,blue:255/255.0,alpha:1.0)
        
        indicator.center = Self.view.center
        backView.addSubview(indicator)
        UIApplication.shared.keyWindow!.addSubview(backView)
        indicator.start()
        
        
    }
    
    static func stop(){
        
//        UIView.animateWithDuration(0.3) {
    
            
//        }
        
        DispatchQueue.main.async {
            
            self.backView.removeFromSuperview()
            indicator.stop()      
        }
    }
    
    
}
