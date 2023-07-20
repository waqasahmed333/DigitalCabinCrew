//
//  SettingsTableViewCell.swift
//  FlightLog
//
//  Created by Naveed Azhar on 26/07/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var settingName: UILabel!
    
    @IBOutlet weak var settingValue: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
