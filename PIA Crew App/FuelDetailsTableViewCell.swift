
//
//  FuelDetailsTableViewCell.swift
//  FlightLog
//
//  Created by Naveed Azhar on 25/07/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit

class FuelDetailsTableViewCell: UITableViewCell {

    

    @IBOutlet weak var flightDetails: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
