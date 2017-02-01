//
//  User.swift
//  Local24
//
//  Created by Local24 on 21/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation
import MapKit

public class User {

    var id :Int?
    var firstName :String?
    var lastName :String?
    var totalAdsCount :Int?
    var zipCode :String?
    var city :String?
    var street :String?
    var houseNumber :String?
    
    var placemark :CLPlacemark?
    
    init() {}
    
    init(value: [AnyHashable:Any]) {
   
        if let id = value["ID"] as? Int {
            self.id = id
        }
        if let firstName = value["FirstName"] as? String {
            self.firstName = firstName
        }
        if let lastName = value["LastName"] as? String {
            self.lastName = lastName
        }
        if let totalAdsCount = value["TotalAdsCount"] as? Int {
            self.totalAdsCount = totalAdsCount
        }
        if let zipCode = value["ZipCode"] as? String {
            self.zipCode = zipCode
        }
        if let city = value["City"] as? String {
            self.city = city
        }
        if let street = value["Street"] as? String {
            self.street = street
        }
        if let houseNumber = value["HouseNumber"] as? String {
            self.houseNumber = houseNumber
        }

    }

    

}
