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
    
    var filters = [filter]()

    
    
     func setfilter(newfilter :filter) {
        
        if filters.contains(where: {$0.name == newfilter.name}) {
            
            if let index = filters.index(where: {$0.name == newfilter.name}) {
                
                switch filters[index].filterType! {
                case .geo_distance:
                    (filters[index] as! Geofilter).lat = (newfilter as! Geofilter).lat
                    (filters[index] as! Geofilter).lon = (newfilter as! Geofilter).lon
                    (filters[index] as! Geofilter).distance = (newfilter as! Geofilter).distance
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
    }
    
    func removefilter(filterToRemove :filter) {
        if let index = filters.index(where: {$0.name == filterToRemove.name}) {
            filters.remove(at: index)
        }
    }
    func removefilterWithName(name: filterName) {
        if let index = filters.index(where: {$0.name == name}) {
            filters.remove(at: index)
        }
    }
    
    func removeAllfilters() {
        filters.removeAll()
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
    
    
    
    func getJSONFromfilterArray(filterArray: [filter]) -> JSON {
        var sort = [[AnyHashable:Any]]()
        var filterJson = [[AnyHashable: Any]]()
        
        for filter in filterArray {
            switch filter.filterType! {
            case .term:
                filterJson.append(["term" :[(filter as! Termfilter).name.rawValue: (filter as! Termfilter).value]])
            case .range:
                let rangefilter = filter as! Rangefilter
                let rangeJson = [
                    "range": [
                        "price": [
                            "gte": rangefilter.gte,
                            "lte": rangefilter.lte
                        ]
                    ]
                ]
                filterJson.append(rangeJson)
            case .sort:
                sort = [[(filter as! Sortfilter).criterium! : (filter as! Sortfilter).order!]]
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
            default: break
            }
        }
        if filterJson.count > 0 {
            let query =
                [
                    "filtered":[
                        "filter":[
                            "and": filterJson
                        ]
                    ]
            ]
            let request = ["query": query, "sort": sort] as [String : Any]
            print(JSON(request))
            return JSON(request)
        } else {
            let request = ["sort": sort] as [String : Any]
            print(JSON(request))
            return JSON(request)
        }
        
    }
    
    /*
    let categories = Categories()

    dynamic var subCategoryID = 99
    dynamic var mainCategoryID = 99
    dynamic var searchString = ""
    dynamic var minPrice = ""
    dynamic var maxPrice = ""
    dynamic var searchZip = ""
    dynamic var searchRadius :Int = 500
    dynamic var searchLong :Double = 10.361315553329199
    dynamic var searchLat :Double = 50.911368167654636
    dynamic var searchLocationString :String = "Deutschland"
    dynamic var sortingChanged = 0
    dynamic var onlyLocalListings = true
    dynamic var maxMileAge :Int = 500000
    dynamic var minMileAge :Int = 0
    
    var viewedRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.019013383496237, longitude: 10.349249403495108), span: MKCoordinateSpan(latitudeDelta: 9.5820552479217014, longitudeDelta: 9.4832213250153075))
    var sorting = Sorting.TimeDesc {
        didSet {
        sortingChanged += sortingChanged
        }
    }
    enum Sorting :String {
        case Relevance = "Relevanz", TimeAsc = "Datum aufsteigen", TimeDesc = "Datum absteigend", PriceAsc = "Preis aufsteigend", PriceDesc = "Preis absteigend", RangeAsc = "Entfernung aufsteigend", RangeDesc = "Entfernung absteigend"
    }
    
    

    func resetAllfilters() {
        subCategoryID = 99
        mainCategoryID = 99
        searchString = ""
        minPrice = ""
        maxPrice = ""
        sorting = Sorting.TimeDesc
        maxMileAge = 500000
        minMileAge = 0
    }

    
    
    func urlFromfilters() -> String {
        
        var url = ""
        var urlQueryStringsArray = [String]()
        
        
        if minPrice != "" {
            let minPriceURLString = "preisvon=\(minPrice)"
            urlQueryStringsArray.append(minPriceURLString)
        }
        if maxPrice != "" {
            let maxPriceURLString = "preisbis=\(maxPrice)"
            urlQueryStringsArray.append(maxPriceURLString)
        }
        if searchString != "" {
            let searchStringURLString = "what=\(noUmlaut(searchString))"
            urlQueryStringsArray.append(searchStringURLString)
        }
        var sortingString = ""
        switch sorting {
        case .Relevance: sortingString = ""
        case .TimeAsc: sortingString = "sortierung=datum-aufsteigend"
        case .TimeDesc: sortingString = "sortierung=datum-absteigend"
        case .PriceAsc: sortingString = "sortierung=preis-aufsteigend"
        case .PriceDesc: sortingString = "sortierung=preis-absteigend"
        case .RangeAsc: sortingString = "sortierung=ort-aufsteigend"
        case .RangeDesc: sortingString = "sortierung=ort-absteigend"
        }
        urlQueryStringsArray.append(sortingString)
        
        if mainCategoryID == 0 && subCategoryID == 1 {
            let minMileAgeString = "kilometerstandvon=\(minMileAge)"
            urlQueryStringsArray.append(minMileAgeString)

        let maxMileAgeString = "kilometerstandbis=\(maxMileAge)"
            urlQueryStringsArray.append(maxMileAgeString)
        }
        
        
        urlQueryStringsArray.append("center=\(searchZip)")
        urlQueryStringsArray.append("geocenter=\(searchLat)%2C\(searchLong)")
        urlQueryStringsArray.append("umkreis=\(searchRadius)")
        
        
        var nonAdultQuery = "clean=1"
        if adultContent  {
            nonAdultQuery = ""
        }
        urlQueryStringsArray.append("anzeigen=100")
        urlQueryStringsArray.append(nonAdultQuery)
        
        if onlyLocalListings {
        urlQueryStringsArray.append("collection=MPS")
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Partnerportale", action: "loadOnlyLocal24Listings", label: "", value: 0).build() as NSDictionary as! [AnyHashable: Any])
        } else {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Partnerportale", action: "loadAllListings", label: "", value: 0).build() as NSDictionary as! [AnyHashable: Any])
        }
        
        let mainCatURLString = categories.getURLFromMainCatID(mainCategoryID)
        var subCatURLString = ""
      //  if subCategoryID != nil {
            subCatURLString = categories.getSubCatURLFromID(mainCategoryID, subId: subCategoryID - 1)
     //   }
        url = url + mainCatURLString + subCatURLString
        if url == "" {
            url = "alle-anzeigen/"
        }
        if !(urlQueryStringsArray.isEmpty) {
            url = url + "?"
            for i in 0...urlQueryStringsArray.count - 2 {
                url = url + urlQueryStringsArray[i] + "&"
            }
            url = url + urlQueryStringsArray.last!
        }
        url = "https://\(mode).local24.de/" + url
        print("filterURL: \(url)")
        return url
    }
    
    
    
    func noUmlaut(_ string: String) -> String   {
               var newString = string
                newString = newString.replacingOccurrences(of: "ü", with: "ue")
                newString = newString.replacingOccurrences(of: "ä", with: "ae")
                newString = newString.replacingOccurrences(of: "ö", with: "oe")
                newString = newString.replacingOccurrences(of: "Ü", with: "ue")
                newString = newString.replacingOccurrences(of: "Ä", with: "ae")
                newString = newString.replacingOccurrences(of: "Ö", with: "oe")
                newString = newString.replacingOccurrences(of: "ß", with: "ss")
                newString = newString.replacingOccurrences(of: " ", with: "+")

        return newString
    }

    
*/
}


public class filter {
    var name: filterName!
    var descriptiveString: String!
    var filterType: filterType!
    

    
    init(name: filterName, descriptiveString :String, filterType :filterType) {
        self.name = name
        self.descriptiveString = descriptiveString
        self.filterType = filterType
    }
}

public class Termfilter :filter {
    var value: String!
    init(name: filterName, descriptiveString :String, value: String) {
        super.init(name: name, descriptiveString: descriptiveString, filterType: .term)
        self.value = value
    }
}
public class Sortfilter :filter {
    var criterium: String!
    var order: String!
    init(criterium: String, order :String) {
        super.init(name: .sorting, descriptiveString: "Sortierung", filterType: .sort)
        self.criterium = criterium
        self.order = order
    }
}

public class Geofilter: filter {
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

public class Rangefilter :filter {
    var gte :Double? //Lower value
    var lte :Double? //Upper Value
    init(name: filterName, descriptiveString :String, gte: Double?, lte: Double?) {
        super.init(name: name, descriptiveString: descriptiveString, filterType: .range)
        self.gte = gte
        self.lte = lte
    }
}

public class Stringfilter :filter {
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
    Sorting(criterium: .city, order: .desc, descriptiveString: "Entfernung"),
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
    


    
//    case TimeAsc = "Datum aufsteigen", TimeDesc = "Datum absteigend", PriceAsc = "Preis aufsteigend", PriceDesc = "Preis absteigend", RangeAsc = "Entfernung aufsteigend", RangeDesc = "Entfernung absteigend"
//    static let allValues = [TimeAsc, TimeDesc , PriceAsc, PriceDesc, RangeAsc, RangeDesc]
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
}
public enum filterType :String {
    case geo_distance
    case range
    case term
    case sort
    case search_string
}


