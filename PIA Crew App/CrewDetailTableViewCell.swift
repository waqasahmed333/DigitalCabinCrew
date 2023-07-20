
//
//  CrewDetailTableViewCell.swift
//  FlightLog
//
//  Created by Naveed Azhar on 05/07/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit

class CrewDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var pos: UILabel!
    
    @IBOutlet weak var sno: UILabel!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var staffno: UILabel!
    
    @IBOutlet weak var status1: UILabel!
    
    @IBOutlet weak var status2: UILabel!
    
    @IBOutlet weak var status3: UILabel!
    
    @IBOutlet weak var status4: UILabel!
    
    @IBOutlet weak var status5: UILabel!
    
    @IBOutlet weak var stn: UILabel!
    
    @IBOutlet weak var gmt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
