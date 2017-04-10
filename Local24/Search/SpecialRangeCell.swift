//
//  SpecialRangeCell.swift
//  Local24
//
//  Created by Local24 on 13/03/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit

class SpecialRangeCell: UITableViewCell {

    var rangeSlider = NMRangeSlider()

    var upperRangeLabel = UILabel()
    var lowerRangeLabel = UILabel()
    var descriptionLabel = UILabel()
    var unit :String?
    var searchIndexName :String!
    var used = false
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    override func layoutSubviews() {
        let rangeframe = CGRect(origin: CGPoint(x:15, y:48), size: CGSize(width: self.bounds.width - 30, height: 44))
        rangeSlider.frame = rangeframe
        self.addSubview(rangeSlider)
        
        
        
        let descriptionLabelFrame = CGRect(origin: CGPoint(x:15, y:8), size: CGSize(width: self.bounds.width - 30, height: 20))
        descriptionLabel.frame =  descriptionLabelFrame
        descriptionLabel.font = UIFont(name: "OpenSans", size: 16)
        self.addSubview(descriptionLabel)

        let upperRangeLabelFrame = CGRect(origin: CGPoint(x:15 + (self.bounds.width - 30)/2 , y:28), size: CGSize(width: (self.bounds.width - 30)/2, height: 20))
        upperRangeLabel.frame = upperRangeLabelFrame
        upperRangeLabel.font = UIFont(name: "OpenSans-Semibold", size: 15)
        upperRangeLabel.textColor = greencolor
        upperRangeLabel.textAlignment = .right
        self.addSubview(upperRangeLabel)
        
        let lowerRangeLabelFrame = CGRect(origin: CGPoint(x:15, y:28), size: CGSize(width: (self.bounds.width - 30)/2, height: 20))
        lowerRangeLabel.frame = lowerRangeLabelFrame
        lowerRangeLabel.font = UIFont(name: "OpenSans-Semibold", size: 15)
        lowerRangeLabel.textColor = greencolor
        self.addSubview(lowerRangeLabel)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
