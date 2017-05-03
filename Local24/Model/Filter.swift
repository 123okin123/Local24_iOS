//
//  Filter.swift
//  Local24
//
//  Created by Nikolai Kratz on 14.02.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation

class Filter {
    var name: FilterName!
    var descriptiveString: String!
    var filterType: filterType!
    init(name: FilterName, descriptiveString :String, filterType :filterType) {
        self.name = name
        self.descriptiveString = descriptiveString
        self.filterType = filterType
    }
}


class Termfilter :Filter {
    var value: String!
    init(name: FilterName, descriptiveString :String, value: String) {
        super.init(name: name, descriptiveString: descriptiveString, filterType: .term)
        self.value = value
    }
}

class Sortfilter :Filter {
    var criterium: Criterium!
    var order: Order!
    var value :String! {
        return sortingOptions.first(where: {$0.order == self.order && $0.criterium == self.criterium})!.descriptiveString
    }
    init(criterium: Criterium, order :Order) {
        super.init(name: .sorting, descriptiveString: "Sortierung", filterType: .sort)
        self.criterium = criterium
        self.order = order
    }
}

class Geofilter: Filter {
    var lat :Double!
    var lon :Double!
    var distance :Double!
    var value :String!
    init(lat: Double, lon: Double, distance :Double, value :String) {
        super.init(name: .geo_distance, descriptiveString: "Umkreis", filterType: .geo_distance)
        self.lat = lat
        self.lon = lon
        self.distance = distance
        self.value = value
    }
}

class Rangefilter :Filter {
    var unit :String?
    var gte :Int? //Lower value
    var lte :Int? //Upper Value
    init(name: FilterName, descriptiveString :String, gte: Int?, lte: Int?, unit :String? = nil) {
        super.init(name: name, descriptiveString: descriptiveString, filterType: .range)
        self.gte = gte
        self.lte = lte
        self.unit = unit
    }
}

class Stringfilter :Filter {
    var queryString :String!
    init(value: String) {
        super.init(name: .search_string, descriptiveString: "Suchbegriff", filterType: .search_string)
        self.queryString = value
    }
}


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


enum FilterName :String {
    case search_string
    case geo_distance
    case sorting
    case price
    case category
    case subcategory
    case sourceId
    
    // Adcar
    case mileage
    case powerPS
    case makeName
    case modelName
    // AdHouse
    case totalRooms
    case landarea
    case size
    
    
}

let adCarFilterNames:[FilterName] = [.mileage, .powerPS, .makeName, .modelName]
let adHouseFilterNames:[FilterName] = [.totalRooms, .landarea, .size]


 enum filterType :String {
    case geo_distance
    case range
    case term
    case sort
    case search_string
}
