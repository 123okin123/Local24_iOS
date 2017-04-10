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
    
    func getSpecialFieldsFor(entityType :AdClass) -> [SpecialField]? {
        var specialFields = [SpecialField]()
        guard let path = Bundle.main.path(forResource: "specialFields", ofType: "json") else {return nil}
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = JSON(data: data)
                guard json != JSON.null else {return nil}
                guard let fields = json[entityType.rawValue].dictionary else {return nil}
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
    
    
    
    func getSpecialFieldsFor(entityType :AdClass, withType type: SpecialFieldType, withExistingSearchIndexName searchIndexNameShouldExist: Bool) -> [SpecialField]? {
        var specialFieldsRaw = [SpecialField]()
        guard let path = Bundle.main.path(forResource: "specialFields", ofType: "json") else {return nil}
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            let json = JSON(data: data)
            guard json != JSON.null else {return nil}
            guard let fields = json[entityType.rawValue].dictionary else {return nil}
            for field in fields {
                let specialField = SpecialField(entityType: entityType, name: field.key)
                specialFieldsRaw.append(specialField)
            }
            if searchIndexNameShouldExist {
                return specialFieldsRaw.filter({$0.searchIndexName != nil}).filter({$0.type == type})
            } else {
            return specialFieldsRaw.filter({$0.type == type})
            }
            
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func entityTypHasSpecialFields(_ entityType: AdClass, inSearchIndex: Bool, withType type: SpecialFieldType) -> Bool {
        if let _ = getSpecialFieldsFor(entityType: entityType, withType: type, withExistingSearchIndexName: inSearchIndex) {
        return true
        } else {
        return false
        }
    }
}
