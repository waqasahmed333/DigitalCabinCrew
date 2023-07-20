//
//  TableViewCell1.swift
//  PIA Crew App
//
//  Created by Admin on 08/09/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit

class TableViewCell1: UITableViewCell {
    
    
    @IBOutlet weak var legNoLabel: UILabel!

    @IBOutlet weak var fuelUpliftQty: UITextField!
    
    @IBOutlet weak var fuelUpliftUnit: UISegmentedControl!
    
    @IBOutlet weak var density: UITextField!
    
    @IBOutlet weak var depKG: UITextField!
    
    @IBOutlet weak var arrKG: UITextField!
    
    @IBOutlet weak var zeroFuelWeight: UITextField!
    
    @IBOutlet weak var toPwrFR: UITextField!
    
    @IBOutlet weak var cat23: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
