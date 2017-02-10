//
//  HomeHeaderCollectionReusableView.swift
//  Local24
//
//  Created by Local24 on 24/01/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit

class HomeHeaderCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var currentLocationButton: UIButton!
    
    override func layoutSubviews() {

    self.frame.size.height = 50
    }
  
    
}
