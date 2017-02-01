//
//  FilterCollectionViewCell.swift
//  Local24
//
//  Created by Local24 on 31/01/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var filtername: UILabel!
    @IBOutlet weak var filtervalue: UILabel!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius  = 5
        self.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.layer.borderWidth = 1.5
        
    }
}
