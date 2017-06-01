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
    @IBOutlet weak var deleteImageButton: UIButton! {didSet {deleteImageButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)}}
    
    var delegate: ImageCellDelegate?
    
    @IBAction func deleteImageButtonTapped(_ sender: UIButton) {
    self.delegate?.deleteButtonTapped(cell: self)
    }
    

    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 5
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        self.delegate = nil
    }
}


protocol ImageCellDelegate: class {
    func deleteButtonTapped(cell: ImageCell)
}
