//
//  ImageCell.swift
//  Local24
//
//  Created by Local24 on 01/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 5


    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}


