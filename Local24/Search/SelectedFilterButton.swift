//
//  SelectedfilterButton.swift
//  Local24
//
//  Created by Local24 on 12/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class SelectedfilterButton: UIButton {

    var filterName = ""
    
    var removeable = true
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        

    
    self.layer.cornerRadius  = 5
    self.layer.borderColor = UIColor.lightGray.cgColor
    self.layer.borderWidth = 1
    self.setTitleColor(UIColor.lightGray, for: UIControlState())
    self.titleLabel?.font = UIFont(name: "OpenSans", size: 14.0)
    self.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        if removeable {
        contentEdgeInsets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 10)
            let selectedfilterButtonImageView = UIImageView(image: UIImage(named: "cross"))
        selectedfilterButtonImageView.contentMode = .scaleAspectFit
        selectedfilterButtonImageView.frame.size = CGSize(width: 12.5, height: 12.5)
        selectedfilterButtonImageView.frame.origin = CGPoint(x: 10, y: 10)
        self.addSubview(selectedfilterButtonImageView)
        }


    }
    
 
    
}
