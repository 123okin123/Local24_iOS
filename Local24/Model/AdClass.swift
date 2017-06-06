//
//  AdClass.swift
//  Local24
//
//  Created by Nikolai Kratz on 06.06.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation


/**
 Type of Ad. Determines additional Fields. Must be identical with API AdClasses.
 
 Possible Values:
 - AdTruck
 - AdCat
 - AdCommune
 - AdDating
 - AdDog
 - AdHorse
 - AdJob
 - AdMotorcycle
 - AdOtherProperty
 - AdCar
 - AdHouse
 - AdApartment
 - AdPlain
 */
enum AdClass:String {
    case AdTruck, AdCat, AdCommune, AdDating, AdDog, AdHorse, AdJob, AdMotorcycle, AdOtherProperty, AdCar, AdHouse, AdApartment, AdPlain
}
