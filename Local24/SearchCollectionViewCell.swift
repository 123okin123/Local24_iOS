//
//  SearchCollectionViewCell.swift
//  Local24
//
//  Created by Local24 on 09/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var listingImage: UIImageView!
    @IBOutlet weak var listingTitle: UILabel!
    @IBOutlet weak var listingPrice: UILabel!
    @IBOutlet weak var listingDate: UILabel!
    @IBOutlet weak var cellContentView: UIView!
    
    
    var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        cellContentView.layer.cornerRadius = 3
        listingPrice.layer.shadowColor = UIColor.black.cgColor
        listingPrice.layer.shadowOffset = CGSize(width: 1, height: 1)
        listingPrice.layer.shadowOpacity = 0.5
        listingPrice.layer.shadowRadius = 1
        listingPrice.layer.masksToBounds = false
        
        if shadowLayer == nil {
            self.backgroundColor = UIColor.clear
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 3).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            shadowLayer.shadowColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1).cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 1.5)
            shadowLayer.shadowOpacity = 1.0
            shadowLayer.shadowRadius = 0.0
            layer.insertSublayer(shadowLayer, at: 0)
        }        
    }

    
    
}
