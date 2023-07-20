//
//  FormsTableViewCell.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 08/05/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit

class FormsDocumentTableViewCell: UITableViewCell {
    @IBOutlet weak var background: UIView!

    @IBOutlet weak var delete: UIButton!
    @IBOutlet weak var download: UIButton!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var group: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var type: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.background.layoutIfNeeded()
        self.background.layer.cornerRadius = self.background.frame.height/2

    }
}
