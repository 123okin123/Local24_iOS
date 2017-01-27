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
    var shadowLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 5
        
        if shadowLayer == nil {
            self.backgroundColor = UIColor.clear
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
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
