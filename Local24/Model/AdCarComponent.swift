//
//  AdCarComponent.swift
//  Local24
//
//  Created by Nikolai Kratz on 25.04.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation
import SwiftyJSON

class AdComponent {}

class AdCarComponent: AdComponent {

    var mileAge: Int?
    
    init(value: [AnyHashable: Any]) {
        let json = JSON(value)
        guard json != JSON.null else {return}
        self.mileAge = json["MileAge"].int
    }
}

