//
//  ListingLocation.swift
//  Local24
//
//  Created by Nikolai Kratz on 07.06.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation
import CoreLocation

class ListingLocation :Equatable {
    var coordinates: CLLocationCoordinate2D?
    var street: String?
    var houseNumber: String?
    var zipCode: String?
    var city: String?
    
    init(coordinates: CLLocationCoordinate2D? = nil, street: String? = nil, houseNumber: String? = nil, zipCode: String? = nil, city: String? = nil) {
        self.coordinates = coordinates
        self.street = street
        self.houseNumber = houseNumber
        self.zipCode = zipCode
        self.city = city
    }
    static func == (lhs: ListingLocation, rhs: ListingLocation) -> Bool {
        return
            lhs.street == rhs.street &&
            lhs.houseNumber == rhs.houseNumber &&
            lhs.city == rhs.city &&
            lhs.zipCode == rhs.zipCode
    }
    
}
