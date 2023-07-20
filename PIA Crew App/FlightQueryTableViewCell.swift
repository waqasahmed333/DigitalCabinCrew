//
//  FlightQueryTableViewCell.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 07/05/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit

class FlightQueryTableViewCell: UITableViewCell {
    @IBOutlet weak var background: UIView!

    @IBOutlet weak var flight: UILabel!
    
    @IBOutlet weak var depStation: UILabel!
    
    @IBOutlet weak var arrStation: UILabel!
    
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var std: UILabel!
    
    
    @IBOutlet weak var sta: UILabel!
    
    @IBOutlet weak var aircraft: UILabel!
    
    @IBOutlet weak var crewInfo: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
