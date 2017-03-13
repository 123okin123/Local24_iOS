//
//  FilterManager.swift
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
        if let geoFilter = filters.first(where: {$0.name == .geo_distance}) {
            filters.removeAll()
            setfilter(newfilter: geoFilter)
            setfilter(newfilter: Sortfilter(criterium: .createDate, order: .desc))
        } else {
            filters.removeAll()
            setfilter(newfilter: Sortfilter(criterium: .createDate, order: .desc))
        }
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
                        rangefilter.name: range                    ]
                ]
                filterJson.append(rangeJson)
            case .sort:
                sort = [[(filter as! Sortfilter).criterium.rawValue : (filter as! Sortfilter).order.rawValue]]
                if (filter as! Sortfilter).criterium == .distance {
                    if let geofilter = FilterManager.shared.getFilter(withName: .geo_distance) as? Geofilter {
                        sort =  [[
                            "_geo_distance": [
                                "latlon": [
                                    "lat":  geofilter.lat,
                                    "lon":  geofilter.lon
                                ],
                                "order":         "asc",
                                "unit":          "km",
                                "distance_type": "plane"
                            ]
                            ]]
                    }
                }
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
    
    
    
    func setFiltersFromURL(url: URL) {
        guard url.absoluteString.contains("local24.de") else {return}
        
        removeAllfilters()
        guard let queryItems = URLComponents(string: url.absoluteString)?.queryItems else {return}
        
        if var mainCat = queryItems.first(where: {$0.name == "maincategory"})?.value {
            mainCat = mainCat.replacingOccurrences(of: "+", with: " ")
            setfilter(newfilter: Termfilter(name: .category, descriptiveString: "Kategorie", value: mainCat))
        }
        if var subCat = queryItems.first(where: {$0.name == "subcategory"})?.value {
            subCat = subCat.replacingOccurrences(of: "+", with: " ")
            setfilter(newfilter: Termfilter(name: .subcategory, descriptiveString: "Unterkategorie", value: subCat))
        }
        delegate?.filtersDidChange()
    }
    
    
}








protocol FilterManagerDelegate: class {
    func filtersDidChange()
}


