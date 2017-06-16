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
    var bodyColor :String?
    var bodyForm :String?
    var condition :String?
    var fuelType :String?
    var gearType :String?
    var initialRegistration :Date?
    var power :Int?
    
    let formatter = DateFormatter()
    
    required init() {}
    
    required init(apiValue value: [AnyHashable: Any]) {
        let json = JSON(value)
        guard json != JSON.null else {return}
        self.mileAge = json["Mileage"].int
        self.make = json["Make"].string
        self.model = json["Model"].string
        self.bodyColor = json["BodyColor"].string
        self.bodyForm = json["BodyForm"].string
        self.condition = json["Condition"].string
        self.fuelType = json["FuelType"].string
        self.gearType = json["GearType"].string
        if let initialRegistrationString = json["InitialRegistration"].string {
            formatter.dateFormat = "mm/yyyy"
            self.initialRegistration = formatter.date(from: initialRegistrationString)
        }
        self.power = json["Power"].int
    }
    required init(searchIndexValue value: [AnyHashable : Any]) {
        let json = JSON(value)
        guard json != JSON.null else {return}
        if let mileAgeString = json["mileage"].string {
            self.mileAge = Int(mileAgeString)
        }
        self.make = json["makeName"].string
        self.model = json["modelName"].string
        self.bodyColor = json["bodyColor"].string
        self.bodyForm = json["bodyForm"].string
        self.condition = json["condition"].string
        self.fuelType = json["fuelType"].string
        self.gearType = json["gearingType"].string
        if var initialRegistrationString = json["firstRegistration"].string {
            initialRegistrationString = initialRegistrationString.substring(to: initialRegistrationString.index(initialRegistrationString.startIndex, offsetBy: 10))
            formatter.dateFormat = "yyyy-mm-dd"
            print(initialRegistrationString)
            self.initialRegistration = formatter.date(from: initialRegistrationString)
        }
        if let powerPSString = json["powerPS"].string {
            self.power = Int(powerPSString)
        }
    }
    
    func componentToJSON() -> [AnyHashable: Any]? {
        var values = [AnyHashable: Any]()
        values["mileAge"] = mileAge
        values["make"] = make
        values["model"] = model
        values["bodyColor"] = bodyColor
        values["bodyForm"] = bodyForm
        values["condition"] = condition
        values["fuelType"] = fuelType
        values["gearType"] = gearType
        if initialRegistration != nil {
            formatter.dateFormat = "MM/yyyy"
            let initialRegistrationString = formatter.string(from: initialRegistration!)
            values["initialRegistration"] = initialRegistrationString
        }
        values["power"] = power
        values.forEach({print("\($0.key): \($0.value)")})
        return values
    }
    
    func componentToRepresentableTupleArray() -> [(name: String?,value: String?)] {
        var tupleArray = [(name: String?, value: String?)]()
        if mileAge != nil { tupleArray.append((name: "Laufleistung",value: "\(mileAge!) km")) }
        if make != nil { tupleArray.append((name: "Marke",value: "\(make!)")) }
        if model != nil { tupleArray.append((name: "Modell",value: "\(model!)")) }
        if bodyColor != nil { tupleArray.append((name: "Außenfarbe",value: "\(bodyColor!)")) }
        if bodyForm != nil {tupleArray.append((name: "Karosserieform", value: "\(bodyForm!)"))}
        if condition != nil {tupleArray.append((name: "Zustand", value: "\(condition!)"))}
        if fuelType != nil {tupleArray.append((name: "Kraftstoffart", value: "\(fuelType!)"))}
        if gearType != nil {tupleArray.append((name: "Getriebeart", value: "\(gearType!)"))}
        if initialRegistration != nil {
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            let initialRegistrationString = formatter.string(from: initialRegistration!)
            tupleArray.append((name: "Erstzulassung", value: "\(initialRegistrationString)"))
        }
        if power != nil {tupleArray.append((name: "Leistung", value: "\(power!) PS"))}
        return tupleArray
    }
}

