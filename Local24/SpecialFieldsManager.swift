//
//  SpecialFieldsManager.swift
//  Local24
//
//  Created by Local24 on 13/03/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation
import SwiftyJSON

class SpecialFieldsManager {
    
    static let shared = SpecialFieldsManager()
    
    func getSpecialFieldsFor(entityType :String) -> [SpecialField]? {
        var specialFields = [SpecialField]()
        guard let path = Bundle.main.path(forResource: "specialFields", ofType: "json") else {return nil}
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = JSON(data: data)
                guard json != JSON.null else {return nil}
                guard let fields = json[entityType].dictionary else {return nil}
                for field in fields {
                    let specialField = SpecialField(entityType: entityType, name: field.key)
                    specialFields.append(specialField)
                }
                return specialFields
            } catch let error {
                print(error.localizedDescription)
                return nil
            }
    }
}
