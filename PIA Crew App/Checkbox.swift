//
//  Checkbox.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 23/10/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit

class Checkbox: UIButton {
    
    //images
    let checkedImage = UIImage(named: "checked_checkbox")
    let unCheckedImage = UIImage(named: "unchecked_checkbox")
    
    //bool property
    var isChecked:Bool = false{
        didSet{
            if isChecked == true{
                self.setImage(checkedImage, for: .normal)
            }else{
                self.setImage(unCheckedImage, for: .normal)
            }
        }
    }
    
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    
    
    @objc func buttonClicked(sender:UIButton) {
        if(sender == self){
            if isChecked == true{
                isChecked = false
            }else{
                isChecked = true
            }
        }
    }
    
}
