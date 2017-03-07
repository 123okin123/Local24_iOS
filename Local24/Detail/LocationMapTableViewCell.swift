//
//  LocationMapTableViewCell.swift
//  Local24
//
//  Created by Local24 on 09/03/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import MapKit

class LocationMapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let littleRadiusView = UIView()
        littleRadiusView.frame.size = CGSize(width: 75, height: 75)
        littleRadiusView.center = CGPoint(x: screenwidth/2, y: self.center.y)
        littleRadiusView.backgroundColor = UIColor(red:  70/255, green: 177/255, blue: 13/255, alpha: 0.3)
        littleRadiusView.layer.cornerRadius = littleRadiusView.frame.size.height/2
        self.addSubview(littleRadiusView)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
