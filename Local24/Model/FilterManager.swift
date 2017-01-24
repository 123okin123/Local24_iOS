//
//  FilterManager.swift
//  Local24
//
//  Created by Local24 on 25/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation
import MapKit



public class FilterManager: NSObject {

    var filters = [Filter]()
    
    
    func setFilter(newFilter :Filter) {
        if filters.contains(where: {$0.name == newFilter.name}) {
            if let index = filters.index(where: {$0.name == newFilter.name}) {
                switch filters[index].filterType! {
                case .geo_distance:
                    (filters[index] as! GeoFilter).lat = (newFilter as! GeoFilter).lat
                    (filters[index] as! GeoFilter).lon = (newFilter as! GeoFilter).lon
                    (filters[index] as! GeoFilter).distance = (newFilter as! GeoFilter).distance
                case .range:
                    (filters[index] as! RangeFilter).gte = (newFilter as! RangeFilter).gte
                    (filters[index] as! RangeFilter).lte = (newFilter as! RangeFilter).lte
                case .term: (filters[index] as! TermFilter).value = (newFilter as! TermFilter).value
                case .search_string:
                    (filters[index] as! StringFilter).queryString = (newFilter as! StringFilter).queryString
                }
            }
        } else {
            filters.append(newFilter)
        }
    }
    
    func removeFilter(filterToRemove :Filter) {
        if let index = filters.index(where: {$0.name == filterToRemove.name}) {
            filters.remove(at: index)
        }
        
    }
    
    func removeAllFilters() {
        filters.removeAll()
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
    
    

    func resetAllFilters() {
        subCategoryID = 99
        mainCategoryID = 99
        searchString = ""
        minPrice = ""
        maxPrice = ""
        sorting = Sorting.TimeDesc
        maxMileAge = 500000
        minMileAge = 0
    }

    
    
    func urlFromFilters() -> String {
        
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
        print("FilterURL: \(url)")
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


public class Filter {
    var name: String!
    var descriptiveString: String!
    var filterType :FilterType!
    
    init(name: String, descriptiveString :String, filterType :FilterType) {
        self.name = name
        self.descriptiveString = descriptiveString
        self.descriptiveString = descriptiveString
    }
}

public class TermFilter :Filter {
    var value: String!
    init(name: String, descriptiveString :String, value: String) {
        super.init(name: name, descriptiveString: descriptiveString, filterType: .term)
        self.value = value
    }
}

public class GeoFilter: Filter {
    var lat :Double!
    var lon :Double!
    var distance :Double!
    init(name: String, descriptiveString :String, lat: Double, lon: Double, distance :Double) {
        super.init(name: name, descriptiveString: descriptiveString, filterType: .geo_distance)
        self.lat = lat
        self.lon = lon
        self.distance = distance
    }
}

public class RangeFilter :Filter {
    var gte :Double! //Lower value
    var lte :Double! //Upper Value
    init(name: String, descriptiveString :String, gte: Double, lte: Double) {
        super.init(name: name, descriptiveString: descriptiveString, filterType: .range)
        self.gte = gte
        self.lte = lte
    }
}

public class StringFilter :Filter {
    var queryString :String!
    init(value: String) {
        super.init(name: "search_string", descriptiveString: "Suchbegriff", filterType: .search_string)
        self.queryString = value
    }
}

public enum FilterType :String {
    case geo_distance
    case range
    case term
    case search_string
}





public enum FilterName :String{
    case category
}

