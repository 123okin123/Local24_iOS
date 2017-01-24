//
//  HomeCatCell.swift
//  Local24
//
//  Created by Local24 on 23/01/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit

class HomeCatCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    var catID :Int?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 5
    }
}
