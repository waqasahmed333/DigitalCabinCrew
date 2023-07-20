//
//  DetailTableViewCell.swift
//  PIA Crew App
//
//  Created by Admin on 06/06/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell{

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    
    @IBOutlet weak var download: UIButton!
    @IBOutlet weak var delete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    }
