//
//  LoadingCell.swift
//  Local24
//
//  Created by Nikolai Kratz on 06.02.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit

class LoadingCell: UICollectionViewCell {
    
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var titleLoadingView: UIView!
    @IBOutlet weak var dateLoadingView: UIView!
    @IBOutlet weak var distanceLoadingView: UIView!
    
    var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            cellContentView.layer.cornerRadius = 5
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
