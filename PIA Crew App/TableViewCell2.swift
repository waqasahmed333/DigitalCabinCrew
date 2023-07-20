//
//  TableViewCell2.swift
//  PIA Crew App
//
//  Created by Admin on 08/09/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit

class TableViewCell2: UITableViewCell {

    @IBOutlet weak var sno: UITextField!
    
    @IBOutlet weak var pos: UITextField!
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var staffno: UITextField!
    
    @IBOutlet weak var status1: UITextField!
    
    @IBOutlet weak var status2: UITextField!
    
    @IBOutlet weak var status3: UITextField!
    
    @IBOutlet weak var status4: UITextField!
    
    @IBOutlet weak var status5: UITextField!
    
    @IBOutlet weak var stn: UITextField!
    
    @IBOutlet weak var gmt: UITextField!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
