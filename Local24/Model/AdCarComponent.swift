//
//  AdCarComponent.swift
//  Local24
//
//  Created by Nikolai Kratz on 25.04.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation
import SwiftyJSON



class AdCarComponent: AdComponent {

    var mileAge: Int?
    
    required init() {}
    
    required init(apiValue value: [AnyHashable: Any]) {
        let json = JSON(value)
        guard json != JSON.null else {return}
        self.mileAge = json["MileAge"].int
    }
    required init(searchIndexValue value: [AnyHashable : Any]) {
        let json = JSON(value)
        guard json != JSON.null else {return}
        if let mileAgeString = json["mileage"].string {
            self.mileAge = Int(mileAgeString)
        }
    }
    
    
    func componentToJSON() -> [AnyHashable: Any]? {
        var values = [AnyHashable: Any]()
        values["mileAge"] = mileAge
        return values
    }
    
    func componentToRepresentableTupleArray() -> [(name: String?,value: String?)] {
        var tupleArray = [(name: String?, value: String?)]()
        if mileAge != nil { tupleArray.append((name: "Laufleistung",value: "\(mileAge!) km")) }
        return tupleArray
    }
}

