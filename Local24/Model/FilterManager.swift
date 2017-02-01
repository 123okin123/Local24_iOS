//
//  filterManager.swift
//  Local24
//
//  Created by Local24 on 25/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation
import MapKit
import SwiftyJSON


class FilterManager {

    static let shared = FilterManager()
    
    var filters = [Filter]()

    weak var delegate:FilterManagerDelegate?
    
     func setfilter(newfilter :Filter) {
        if filters.contains(where: {$0.name == newfilter.name}) {
            if let index = filters.index(where: {$0.name == newfilter.name}) {
                
                switch filters[index].filterType! {
                case .geo_distance:
                    (filters[index] as! Geofilter).lat = (newfilter as! Geofilter).lat
                    (filters[index] as! Geofilter).lon = (newfilter as! Geofilter).lon
                    (filters[index] as! Geofilter).distance = (newfilter as! Geofilter).distance
                    (filters[index] as! Geofilter).value = (newfilter as! Geofilter).value
                case .range:
                    (filters[index] as! Rangefilter).gte = (newfilter as! Rangefilter).gte
                    (filters[index] as! Rangefilter).lte = (newfilter as! Rangefilter).lte
                case .term: (filters[index] as! Termfilter).value = (newfilter as! Termfilter).value
                case .search_string:
                    (filters[index] as! Stringfilter).queryString = (newfilter as! Stringfilter).queryString
                case .sort:
                    (filters[index] as! Sortfilter).order = (newfilter as! Sortfilter).order
                    (filters[index] as! Sortfilter).criterium = (newfilter as! Sortfilter).criterium
                }

            }
        } else {
            filters.append(newfilter)
        }
        delegate?.filtersDidChange()
    }
    
    func removefilter(filterToRemove :Filter) {
        if let index = filters.index(where: {$0.name == filterToRemove.name}) {
            filters.remove(at: index)
            delegate?.filtersDidChange()
        }
    }
    func removefilterWithIndex(index :Int) {
            filters.remove(at: index)
            delegate?.filtersDidChange()
        
    }
    
    func removefilterWithName(name: filterName) {
        if let index = filters.index(where: {$0.name == name}) {
            filters.remove(at: index)
            delegate?.filtersDidChange()
        }
    }
    
    func removeAllfilters() {
        filters.removeAll()
        setfilter(newfilter: Sortfilter(criterium: .createDate, order: .desc))
        delegate?.filtersDidChange()
    }
    
    func getValueOffilter(withName name :filterName, filterType :filterType) -> String? {
        if let filter = filters.first(where: {$0.name == name}) {
            switch filter.filterType! {
            case .geo_distance:
                return (filter as! Geofilter).value
            case .term:
                return (filter as! Termfilter).value
            case .search_string:
                return (filter as! Stringfilter).queryString
            case .sort:
                let filter = filter as! Sortfilter
                let sorting = sortingOptions.first(where: { sorting in
                    if sorting.criterium == filter.criterium && sorting.order == filter.order {
                        return true
                    } else {
                        return false
                    }
                })
                return sorting?.descriptiveString
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    func getValuesOfRangefilter(withName name :filterName) -> (gte: Double?,lte: Double?)? {
        if let filter = filters.first(where: {$0.name == name}) {
            return ((filter as! Rangefilter).gte, (filter as! Rangefilter).lte)
        } else {
            return nil
        }
    }
    
    func getFilter(withName name: filterName) -> Filter? {
        return filters.first(where: {$0.name == name})
    }
    
    func getJSONFromfilterArray(filterArray: [Filter], size: Int, from: Int) -> JSON {
        var sort = [[AnyHashable:Any]]()
        var filterJson = [[AnyHashable: Any]]()
        var searchString :String?
        for filter in filterArray {
            switch filter.filterType! {
            case .term:
                filterJson.append(["term" :[(filter as! Termfilter).name.rawValue: (filter as! Termfilter).value]])
            case .range:
                let rangefilter = filter as! Rangefilter
                var range = [String:Any]()
                if let gte = rangefilter.gte {
                range["gte"] = gte
                }
                if let lte = rangefilter.lte {
                    range["lte"] = lte
                }
                let rangeJson = [
                    "range": [
                        "price": range                    ]
                ]
                filterJson.append(rangeJson)
            case .sort:
                sort = [[(filter as! Sortfilter).criterium.rawValue : (filter as! Sortfilter).order.rawValue]]
            case .geo_distance:
                let geofilter = filter as! Geofilter
                let geoJson = [
                    "geo_distance": [
                        "distance":(String(geofilter.distance)+"km"),
                        "latlon": [
                            "lat": geofilter.lat,
                            "lon": geofilter.lon
                        ]
                    ]
                ]
                filterJson.append(geoJson)
            case .search_string:
                searchString = (filter as! Stringfilter).queryString
            }
        }
        
        
        
        
        if !filterArray.contains(where: {$0.name == .category}) {
        let notKontaktanzeigen = [
            "not": [
                "filter": [
                    "term": [
                        "category": "Kontaktanzeigen"
                    ]
                ]
            ]
        ]
        filterJson.append(notKontaktanzeigen)
        let notFlirt = [
            "not": [
                "filter": [
                    "term": [
                        "category": "Flirt & Abenteuer"
                    ]
                ]
            ]
        ]
        filterJson.append(notFlirt)
        }
        
        
        
        
        
        if filterJson.count > 0 || searchString != nil {
            var query :Any!
            if filterJson.count > 0 && searchString != nil {
            query =
                [
                    "filtered":[
                        "query":[
                            "dis_max":[
                                "queries": [
                                    "query_string": [
                                        "query": searchString!,
                                        "default_operator": "AND",
                                        "fields": [
                                        "title",
                                        "description",
                                        "locationSearch"
                                        ]
                                    ]
                                ]
                            ]
                        ],
                        "filter":[
                            "and": filterJson
                        ]
                    ]
            ]
            }
            if filterJson.count > 0 && searchString == nil {
            query =
                [
                    "filtered":[
                        "filter":[
                            "and": filterJson
                        ]
                    ]
            ]
            }
            if filterJson.count == 0 && searchString != nil {
                query =
                    [
                        "filtered":[
                            "filter":[
                                "and": filterJson
                            ]
                        ]
                ]
            }
            let request = ["query": query,"from": from, "size": size, "sort": sort] as [String : Any]
            let json = JSON(request)
            print(json)
            return json
         
        } else {
            let request = ["from": from, "size": size, "sort": sort] as [String : Any]
            print(JSON(request))
            return JSON(request)
        }
        
    }
    
}



















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
    var gte :Double? //Lower value
    var lte :Double? //Upper Value
    init(name: filterName, descriptiveString :String, gte: Double?, lte: Double?) {
        super.init(name: name, descriptiveString: descriptiveString, filterType: .range)
        self.gte = gte
        self.lte = lte
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
    Sorting(criterium: .city, order: .asc, descriptiveString: "Entfernung"),
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
    case city
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
}



public enum filterType :String {
    case geo_distance
    case range
    case term
    case sort
    case search_string
}







protocol FilterManagerDelegate: class {
    func filtersDidChange()
}


