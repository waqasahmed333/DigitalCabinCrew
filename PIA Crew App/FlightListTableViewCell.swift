//
//  FlightListTableViewCell.swift
//  FlightLog
//
//  Created by Naveed Azhar on 26/06/2015.
//  Copyright (c) 2015 Naveed Azhar. All rights reserved.
//

import UIKit

class FlightListTableViewCell: UITableViewCell {

    @IBOutlet weak var lblFlightNumber: UILabel!
    
    @IBOutlet weak var lblSector: UILabel!
   
    @IBOutlet weak var lblStatus: UILabel!
    
    @IBOutlet weak var lblCommand: UIButton!

    @IBOutlet weak var scheduledTimings: UILabel!
    
    @IBOutlet weak var aircraftType: UILabel!
    
    @IBOutlet weak var captainId: UILabel!
    
    @IBOutlet weak var btnRefresh: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
