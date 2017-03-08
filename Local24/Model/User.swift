//
//  User.swift
//  Local24
//
//  Created by Local24 on 21/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation
import MapKit
import SwiftyJSON

public class User {

    var id :Int?
    var salutationID :Int?
    var email :String?
    var firstName :String?
    var lastName :String?
    var fullName :String? {
        var fullName :String?
        if firstName != nil {
        fullName = firstName
            if lastName != nil {
                fullName = fullName! + " " + lastName!
            }
        }
        return fullName
    }
    var totalAdsCount :Int?
    var zipCode :String?
    var city :String?
    var street :String?
    var houseNumber :String?
    var telephone :String?
    
    var placemark :CLPlacemark?
    var isCommercial :Bool?
    
    init() {}
    
    init(value: [AnyHashable:Any]) {
        let json = JSON(value)
        print(json)
        id = json["ID"].int
        email = json["LoginEmail"].string
        salutationID = json["ID_Salutation"].int
        firstName = json["FirstName"].string
        lastName = json["LastName"].string
        totalAdsCount = json["TotalAdsCount"].int
        zipCode = json["ZipCode"].string
        city = json["City"].string
        street = json["Street"].string
        houseNumber = json["HouseNumber"].string
        telephone = json["Phone"].string
        isCommercial = json["IsCommercial"].bool
    }

     func userToJSON() -> [AnyHashable: Any]? {

        guard let email = self.email else {return nil}
        guard let firstName = self.firstName else {return nil}
        guard let lastName = self.lastName else {return nil}
        guard let city = self.city else {return nil}
        guard let isCommercial = self.isCommercial else {return nil}
        

        
        var values :[AnyHashable: Any] = ["ID":"1",
                      "LoginEmail": email,
                      "FirstName": firstName,
                      "LastName": lastName,
                      "City": city,
                      "isCommercial": isCommercial
        ]
        
        if let telephone = self.telephone {
            values["Phone"] = telephone
        }
        if let street = self.street {
            values["Street"] = street
        }
        if let houseNumber = self.houseNumber {
            values["HouseNumber"] = houseNumber
        }
        if let zipCode = self.zipCode  {
            values["ZipCode"] = zipCode
        }
        if let salutationID = self.salutationID {
            values["ID_Salutation"] = salutationID
        }
        return values
    }


    

}

