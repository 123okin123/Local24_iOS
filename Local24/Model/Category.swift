//
//  Category.swift
//  Local24
//
//  Created by Locla24 on 27/01/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation



class Category {
    var id :Int!
    var idParentCategory :Int!
    var name :String!
    var level :Int!
    var adclass :AdClass!
    var isParentCat :Bool!
}

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

