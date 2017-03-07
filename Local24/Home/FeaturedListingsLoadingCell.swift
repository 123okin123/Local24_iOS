//
//  FeaturedListingsLoadingCell.swift
//  Local24
//
//  Created by Local24 on 07/03/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit

class FeaturedListingsLoadingCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView! {didSet{
        imageView.layer.cornerRadius = 10
        }}
}
