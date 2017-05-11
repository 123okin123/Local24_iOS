//
//  Sorting.swift
//  Local24
//
//  Created by Nikolai Kratz on 11.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation


struct Sorting {
    var criterium:Criterium!
    var order:Order!
    var descriptiveString:String!
    
    init(criterium :Criterium, order :Order,descriptiveString :String ) {
        self.criterium = criterium
        self.order = order
        self.descriptiveString = descriptiveString
    }
}

var sortingOptions = [
    Sorting(criterium: .createDate, order: .desc, descriptiveString: "Neuste zuerst"),
    Sorting(criterium: .price, order: .asc, descriptiveString: "Preis aufsteigend"),
    Sorting(criterium: .price, order: .desc, descriptiveString: "Preis absteigend"),
    Sorting(criterium: .distance, order: .asc, descriptiveString: "Entfernung"),
]

enum Criterium :String{
    case createDate
    case price
    case distance
}

enum Order :String{
    case desc
    case asc
}
