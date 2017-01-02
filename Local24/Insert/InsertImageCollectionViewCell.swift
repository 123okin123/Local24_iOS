//
//  InsertImageCollectionViewCell.swift
//  Local24
//
//  Created by Local24 on 01/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class InsertImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteImageButton: UIButton! {didSet {deleteImageButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)}}
    
    var delegate: InsertImageCellDelegate?
    
    @IBAction func deleteImageButtonTapped(_ sender: UIButton) {
    self.delegate?.buttonTapped(cell: self)
    }
    

    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 5
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        self.delegate = nil
    }
}


protocol InsertImageCellDelegate: class {
    func buttonTapped(cell: InsertImageCollectionViewCell)
}
