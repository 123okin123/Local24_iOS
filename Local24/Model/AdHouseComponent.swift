//
//  AdHouseComponent.swift
//  Local24
//
//  Created by Nikolai Kratz on 02.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation
import SwiftyJSON

class AdHouseComponent:AdComponent {

    var size: Int?
    
    required init() {}
    
    required init(apiValue value:[AnyHashable: Any]) {
        let json = JSON(value)
        guard json != JSON.null else {return}
        self.size = json["size"].int
    }
    
    required init(searchIndexValue value: [AnyHashable : Any]) {
        let json = JSON(value)
        guard json != JSON.null else {return}
        self.size = json["size"].int
    }
    
    
    func componentToJSON() -> [AnyHashable: Any]? {
        return nil
    }
    
    func componentToRepresentableTupleArray() -> [(name: String?,value: String?)] {
        var tupleArray = [(name: String?, value: String?)]()
        if size != nil { tupleArray.append((name: "Größe",value: "\(size!) m2")) }
        return tupleArray
    }
}
