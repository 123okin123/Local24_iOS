//
//  RadiusView.swift
//  Local24
//
//  Created by Local24 on 11/02/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class RadiusView: UIView {

    var moves :Bool = false
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
  
        
        
       
        let darkgreen = UIColor(red: 0.43, green: 0.59, blue: 0.16, alpha: 0.5)
        let green = UIColor(red: 0.40, green: 0.61, blue: 0.0, alpha: 0.3)

        
        
        let size = self.frame.size
        let origin = CGPoint(x: 0, y: 0)
        let filling = UIBezierPath(ovalIn: CGRect(origin: origin, size: size))
        
        green.setFill()
        filling.fill()
        
        let radiusPath = UIBezierPath(rect: CGRect(x: self.frame.width/2 - 1, y: 10, width: 2, height: 20))
        darkgreen.setFill()
        radiusPath.fill()
        let radiusPath2 = UIBezierPath(rect: CGRect(x: self.frame.width/2 - 1, y: 55, width: 2, height: self.frame.height/2 - 65))
        darkgreen.setFill()
        radiusPath2.fill()
        let radiusPath3 = UIBezierPath(roundedRect: CGRect(x: self.frame.width/2 - 5, y: 8, width: 10, height: 2), cornerRadius: 3)
        darkgreen.setFill()
        radiusPath3.fill()
        let radiusPath4 = UIBezierPath(roundedRect: CGRect(x: self.frame.width/2 - 5, y: self.frame.height/2 - 10, width: 10, height: 2), cornerRadius: 3)
        darkgreen.setFill()
        radiusPath4.fill()

        
        let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
        let radius: CGFloat = self.frame.size.width
        let arcWidth: CGFloat = self.frame.size.width - 2
        let startAngle: CGFloat = 0
        let endAngle: CGFloat =  2 * 3.14159
        let path = UIBezierPath(arcCenter: center,
            radius: radius/2 - arcWidth/2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true)
        path.lineWidth = arcWidth
        
        darkgreen.setStroke()
        path.stroke()
    }
    

}
