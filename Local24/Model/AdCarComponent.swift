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
    var make: String?
    var model: String?
    
    required init() {}
    
    required init(apiValue value: [AnyHashable: Any]) {
        let json = JSON(value)
        guard json != JSON.null else {return}
        self.mileAge = json["MileAge"].int
        self.make = json["Make"].string
        self.model = json["Model"].string
    }
    required init(searchIndexValue value: [AnyHashable : Any]) {
        let json = JSON(value)
        guard json != JSON.null else {return}
        if let mileAgeString = json["mileage"].string {
            self.mileAge = Int(mileAgeString)
        }
        self.make = json["makeName"].string
        self.model = json["modelName"].string
        
    }
    
    func componentToJSON() -> [AnyHashable: Any]? {
        var values = [AnyHashable: Any]()
        values["mileAge"] = mileAge
        values["make"] = make
        values["model"] = model
        return values
    }
    
    func componentToRepresentableTupleArray() -> [(name: String?,value: String?)] {
        var tupleArray = [(name: String?, value: String?)]()
        if mileAge != nil { tupleArray.append((name: "Laufleistung",value: "\(mileAge!) km")) }
        if make != nil { tupleArray.append((name: "Marke",value: "\(make!)")) }
        if model != nil { tupleArray.append((name: "Modell",value: "\(model!)")) }
        return tupleArray
    }
}

