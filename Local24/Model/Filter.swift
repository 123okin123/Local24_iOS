//
//  Filter.swift
//  Local24
//
//  Created by Nikolai Kratz on 14.02.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation


public class Filter {
    var name: filterName!
    var descriptiveString: String!
    var filterType: filterType!
    
    init(name: filterName, descriptiveString :String, filterType :filterType) {
        self.name = name
        self.descriptiveString = descriptiveString
        self.filterType = filterType
    }
}



public class Termfilter :Filter {
    var value: String!
    init(name: filterName, descriptiveString :String, value: String) {
        super.init(name: name, descriptiveString: descriptiveString, filterType: .term)
        self.value = value
    }
}

public class Sortfilter :Filter {
    var criterium: Criterium!
    var order: Order!
    init(criterium: Criterium, order :Order) {
        super.init(name: .sorting, descriptiveString: "Sortierung", filterType: .sort)
        self.criterium = criterium
        self.order = order
    }
}

public class Geofilter: Filter {
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

public class Rangefilter :Filter {
    var unit :String?
    var gte :Double? //Lower value
    var lte :Double? //Upper Value
    init(name: filterName, descriptiveString :String, gte: Double?, lte: Double?) {
        super.init(name: name, descriptiveString: descriptiveString, filterType: .range)
        self.gte = gte
        self.lte = lte
    }
    init(name: filterName, descriptiveString :String, gte: Double?, lte: Double?, unit: String?) {
        super.init(name: name, descriptiveString: descriptiveString, filterType: .range)
        self.gte = gte
        self.lte = lte
        self.unit = unit
    }
}

public class Stringfilter :Filter {
    var queryString :String!
    init(value: String) {
        super.init(name: .search_string, descriptiveString: "Suchbegriff", filterType: .search_string)
        self.queryString = value
    }
}

public var sortingOptions = [
    Sorting(criterium: .createDate, order: .desc, descriptiveString: "Neuste zuerst"),
    Sorting(criterium: .price, order: .asc, descriptiveString: "Preis aufsteigend"),
    Sorting(criterium: .price, order: .desc, descriptiveString: "Preis absteigend"),
    Sorting(criterium: .distance, order: .asc, descriptiveString: "Entfernung"),
]
public class Sorting {
    var criterium:Criterium!
    var order:Order!
    var descriptiveString:String!
    
    init(criterium :Criterium, order :Order,descriptiveString :String ) {
        self.criterium = criterium
        self.order = order
        self.descriptiveString = descriptiveString
    }
    
    
    
}
public enum Criterium :String{
    case createDate
    case price
    case distance
}
public enum Order :String{
    case desc
    case asc
}


public enum filterName :String {
    case search_string
    case geo_distance
    case sorting
    case price
    case category
    case subcategory
    case sourceId
    //Special Fields
    // Adcar
    case mileage
    case powerPS
}



public enum filterType :String {
    case geo_distance
    case range
    case term
    case sort
    case search_string
}
