//
//  MasterTableViewCell.swift
//  PIA Crew App
//
//  Created by Admin on 05/06/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit

class MasterTableViewCell: UITableViewCell {

    @IBOutlet weak var subsectionButtonView: UIView!
    
    @IBOutlet weak var subsectionTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state

        if ( selected ) {
            if #available(iOS 13.0, *) {
                self.subsectionButtonView.backgroundColor = UIColor.label
                self.subsectionTitle.backgroundColor = UIColor.label
                self.subsectionTitle.textColor = UIColor.systemBackground
            } else {
                // Fallback on earlier versions
            }

        } else {
            if #available(iOS 13.0, *) {
                self.subsectionButtonView.backgroundColor = UIColor.systemBackground
                self.subsectionTitle.backgroundColor = UIColor.systemBackground
                self.subsectionTitle.textColor = UIColor.label
            } else {
                // Fallback on earlier versions
            }
        }
    }

}
