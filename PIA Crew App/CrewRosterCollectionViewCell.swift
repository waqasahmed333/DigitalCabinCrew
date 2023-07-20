
//
//  CrewRosterCollectionViewCell.swift
//  PIA Crew App
//
//  Created by Naveed Azhar on 07/06/2016.
//  Copyright © 2016 Naveed Azhar. All rights reserved.
//

import UIKit

class CrewRosterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dateInfo: UILabel!
    
    
    @IBOutlet weak var dutyInfo: UILabel!
    
    
    override func draw(_ rect: CGRect) {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    

}
