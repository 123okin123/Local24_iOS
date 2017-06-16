//
//  ZipGeoDB.swift
//  Local24
//
//  Created by Locla24 on 02/02/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation
import UIKit


class ZipGeo :NSObject {

    var lat :Double
    var long :Double
    var zip :String
    var name :String
    
    
    init(lat: Double, long: Double, zip: String, name: String) {
        self.lat = lat
        self.long = long
        self.zip = zip
        self.name = name
    }

}
