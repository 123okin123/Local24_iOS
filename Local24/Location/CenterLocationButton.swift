//
//  CenterLocationButton.swift
//  Local24
//
//  Created by Local24 on 15/02/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

@IBDesignable
class CenterLocationButton: UIButton {

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let origin = CGPoint(x: 0, y: 0)
        let size = CGSize(width: self.frame.width, height: self.frame.height)
        let path = UIBezierPath(roundedRect: CGRect(origin: origin, size: size), cornerRadius: 5)
        let color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        color.setFill()
        path.fill()
        self.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 5
    }
    

}
