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
    
    var specialFieldsCollection = [String:[SpecialField]]()
    
    
    init() {
        guard let path = Bundle.main.path(forResource: "specialFields", ofType: "json") else {return}
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            let json = JSON(data: data)
            guard json != JSON.null else {return}
            guard let adClasses = json.dictionary else {return}
            for adClass in adClasses {
                if let fields = adClass.value.dictionary {
                    var specialFields = [SpecialField]()
                    for field in fields {
                        let specialField = self.initSpecialFieldFrom(field: field)
                        specialFields.append(specialField)
                    }
                    specialFieldsCollection[adClass.key] = specialFields
                }
            }
        } catch let error {
            print(error.localizedDescription)
            return
        }
    }
    
    
    private func initSpecialFieldFrom(field: (key:String,value:JSON)) -> SpecialField {
        let name = field.key
        let descriptiveString = field.value["descriptiveString"].string!
        let type = field.value["type"].string!
        let specialField = SpecialField(name: name, descriptiveString: descriptiveString, type: SpecialFieldType(rawValue: type)!)
        
        specialField.possibleValues = field.value["possibleValues"].arrayObject
        specialField.unit = field.value["unit"].string
        specialField.minimumValue = field.value["minimumValue"].int
        specialField.maximumValue = field.value["maximumValue"].int
        specialField.searchIndexName = field.value["searchIndexName"].string
        if let hasDependentField = field.value["hasDependentField"].bool {
            specialField.hasDependentField = hasDependentField
            specialField.dependentFieldName = field.value["dependentField"].string
        }
        return specialField
    }
    
    func getSpecialFieldsFor(entityType :AdClass, mustBeInSearchIndex: Bool = false, withType type: SpecialFieldType? = nil) -> [SpecialField]? {
        guard let specialFields = specialFieldsCollection[entityType.rawValue] else {return nil}
        if mustBeInSearchIndex {
            return specialFields.filter({$0.searchIndexName != nil}).filter({$0.type == type})
        } else {
            if type == nil {
                return specialFields
            } else {
                return specialFields.filter({$0.type == type})
            }
        }
    }
    func getSpecialFieldWith(entityType: AdClass, name :String) -> SpecialField? {
        guard let specialFields = specialFieldsCollection[entityType.rawValue] else {return nil}
        return specialFields.first(where: {$0.name == name})
    }
    

    
    func entityTypHasSpecialFields(_ entityType: AdClass, mustBeInSearchIndex: Bool = false, withType type: SpecialFieldType? = nil) -> Bool {
        if let _ = getSpecialFieldsFor(entityType: entityType, mustBeInSearchIndex: mustBeInSearchIndex, withType: type) {
        return true
        } else {
        return false
        }
    }
    
    func numberOfSecialFieldsFor(_ entityType: AdClass,mustBeInSearchIndex: Bool = false, withType type: SpecialFieldType) -> Int {
        if let specialFields = getSpecialFieldsFor(entityType: entityType, mustBeInSearchIndex: mustBeInSearchIndex, withType: type) {
        return specialFields.count
        } else {
        return 0
        }
    }
 
}
