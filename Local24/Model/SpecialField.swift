//
//  SpecialField.swift
//  Local24
//
//  Created by Local24 on 13/03/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation
import SwiftyJSON

///Used for Insertion and Search of Listings with AdClass(=entityType) other than AdPlain. A SpecialField has always a descriptiveString, which is used for UI purposes, a name and a type. Other properties depend on usage of the SpecialField (e.g. for Insertion or Search)
class SpecialField {
    var name:String!
    var descriptiveString :String!
    var type :SpecialFieldType!
    
    var searchIndexName :String?
    var value :Any?
    var possibleValues :[Any]?
    var hasDependentField = false
    
    //var isIndipendent = true
    var isDependent = false
    var dependentFieldName :String?
    var dependentField :SpecialField?
    //var dependingField :SpecialField?
    var unit: String?
    var minimumValue :Int?
    var maximumValue :Int?
    
    var valueString :String? {
        var string :String?
        switch type {
        case .string?:
            string = value as! String?
        case .int?:
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            if let value = value as? Int {
                string =  numberFormatter.string(from: NSNumber(value: value))
            }
        case nil:
            return nil
        }
        if unit != nil {
            string?.append(unit!)
        }
        return string
    }
    
    var possibleStringValues :[String]? {
        var stringValues  :[String]?
        switch type {
        case .string?:
            if let strings = possibleValues as? [String]? {
                stringValues = strings
            }
        case .int?:
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            if let ints = possibleValues as? [Int] {
                stringValues = ints.map {numberFormatter.string(from: NSNumber(value: $0))!}
            }
        case nil:
            return nil
        }
        if unit != nil {
            if stringValues != nil {
                stringValues = stringValues!.map {$0 + unit!}
            }
        }
        return stringValues
    }
    

    
    init(name: String, descriptiveString: String, type: SpecialFieldType, value: Any? = nil) {
        self.name = name
        self.descriptiveString = descriptiveString
        self.type = type
        self.value = value
    }

}








/** 
 Defines Type of SpecialField
 Possible Values:
 - string
 - int
*/
enum SpecialFieldType :String {
    case string
    case int
}
