//
//  FeaturedListingsCell.swift
//  Local24
//
//  Created by Nikolai Kratz on 06.03.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit

class FeaturedListingsCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView! {didSet {
        imageView.layer.cornerRadius = 10
        }}
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        priceLabel.layer.shadowColor = UIColor.black.cgColor
        priceLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
        priceLabel.layer.shadowOpacity = 0.5
        priceLabel.layer.shadowRadius = 1
        priceLabel.layer.masksToBounds = false
    }
    
}
