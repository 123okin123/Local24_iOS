//
//  SearchCollectionViewAdCell.swift
//  Local24
//
//  Created by Local24 on 10/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class SearchCollectionViewAdCell: UICollectionViewCell {
   
    
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adImageView: UIImageView!
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var adCallToActionButton: UIButton!
    
    
    
    var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cellContentView.layer.cornerRadius = 3

        
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
