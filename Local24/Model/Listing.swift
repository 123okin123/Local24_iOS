//
//  Listing.swift
//  Local24
//
//  Created by Local24 on 09/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class Listing :NSObject {
    
    // MARK: General
    
    var adID :Int!
    var source :String?
    var adState :AdState?
    var advertiserID :Int?
    var user :User?
    var title :String?
    var adDescription :String?
    /// Type of the listing. Can be "Gesuch" or "Angebot"
    var adType :AdType?
    /// AdClass of the listing. Can be: AdTruck, AdCat, AdCommune, AdDating, AdDog, AdHorse, AdJob, AdMotorcycle, AdOtherProperty, AdCar, AdHouse, AdApartment, AdPlain
    var entityType :AdClass?
    /// The url of the listing on local24.de
    var url :URL?
    var containsAdultContent = false
    /// Component of the listing, which contains further information. For example a listing for a car has an AdCarComponent, which holds information like mileage etc.
    var component :AdComponent?
    
    var createdDate :String?
    var updatedDate :String?
    
    // MARK: Price
    
    var price :String?
    /// Possible values: Zu verschenken, VHB, Festpreis, keine Angabe
    var priceType :String?
    var priceWithCurrency :String? {get {
        if price != nil {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            if let price = Double(price!) {
            return formatter.string(from: NSNumber(value: price))
            } else {
            return "-, €"
            }
        } else {
        return nil
        }
    }}
    
    // MARK: Location
    
    ///Distance of the coordinates of the listing and the coordinates of the current geofilter. If the listing has no coordinates or no the filtermanager has no geofilter, this property is nil.
    var distance :Double? {
        guard let lat = self.listingLocation?.coordinates?.latitude else {return nil}
        guard let long = self.listingLocation?.coordinates?.longitude else {return nil}
        if let geofilter = FilterManager.shared.getFilter(withName: .geo_distance) as? Geofilter {
            let location = CLLocation(latitude: lat, longitude: long)
            return round(location.distance(from:  CLLocation(latitude: geofilter.lat, longitude: geofilter.lon))/1000)
        } else {return nil}
    }
    
    var listingLocation : ListingLocation?
    
    // MARK: Contact
    
    var phoneNumber :String?
    
    // MARK: Category
    
    var catID :Int?
    var mainCatString :String?
    var subCatString :String?
    
    // MARK: Images
    
    var hasImages = false
    var thumbImage :UIImage?
    var images :[UIImage]?
    var thumbImageURL :String?
    var imageURLs = [String]()
    

    // MARK: Inits
    
    override init() {
        super.init()
    }
    
    /// init method for API calls. Used for own listings in account
    init(apiValue value: [AnyHashable:Any]) {
        super.init()
        let json = JSON(value)
        guard json != JSON.null else {return}
       
        print(json)
        self.source = "MPS"
        
        if let adID = value["Id"] as? Int {
            self.adID = adID
        }
        if let advertiserID = value["ID_Advertiser"] as? Int {
            self.advertiserID = advertiserID
        }
        if let catID = value["ID_Category"] as? Int {
            self.catID = catID
        }
        if let adState = value["AdState"] as? String {
            self.adState = AdState(rawValue: adState)
        }
        if let adType = value["AdType"] as? String {
            self.adType = AdType(rawValue: adType)
        }
        if let entityType = value["EntityType"] as? String {
            self.entityType = AdClass(rawValue: entityType)
            switch self.entityType! {
            case .AdCar: self.component = AdCarComponent(apiValue: value)
            default: break
            }
        }
        if let url = value["DetailPageLink"] as? String {
            self.url = URL(string: url)
        }
        if let listingTitle = value["Title"] as? String {
            self.title = listingTitle
        }
        if let description = value["Body"] as? String {
            self.adDescription = description
        }
        if let priceType = value["PriceType"] as? String {
            self.priceType = priceType
        }

        if let listingPrice = value["Price"] as? Float {
            self.price = String(describing: Int(listingPrice))
        } else {
            self.price = "-, €"
        }

        if var listingDate = value["CreatedAt"] as? String {
            let listingDateYear = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 2) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 4))]
            let listingDateMonth = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 5) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 7))]
            let listingDateDay = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 8) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 10))]
            listingDate = "\(listingDateDay).\(listingDateMonth).\(listingDateYear)"
            self.createdDate = listingDate
        }
        if var updatedAt = value["UpdatedAt"] as? String {
            let updatedAtYear = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 2) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 4))]
            let updatedAtMonth = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 5) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 7))]
            let updatedAtDay = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 8) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 10))]
            updatedAt = "\(updatedAtDay).\(updatedAtMonth).\(updatedAtYear)"
            self.updatedDate = updatedAt
        }
        if let hasImages = value["HasImages"] as? Bool {
        if hasImages  {
            self.hasImages = true
            if let images = value["GalleryImage"] as? NSDictionary {
                if let thumbImageURL = images["ImagePathMedium"] as? String  {
                    self.thumbImageURL = thumbImageURL
                }
            }
        } else {
            self.hasImages = false
        }
        }
        
        if let phone = value["Phone"] as? String {
            self.phoneNumber = phone
        }
        
        var coordinate = CLLocationCoordinate2D()
        if let latitude = value["Latitude"] as? Double {
            coordinate.latitude = latitude
        }
        if let longitude = value["Longitude"] as? Double {
            coordinate.longitude = longitude
        }
        
        
        let street = value["Street"] as? String
        let houseNumber = value["HouseNumber"] as? String
        let city = value["City"] as? String
        let zipcode = value["ZipCode"] as? String
    
        self.listingLocation = ListingLocation(coordinates: coordinate, street: street, houseNumber: houseNumber, zipCode: zipcode, city: city)
        
    }
    
    
    
    /// init method for calls to elasticsearch proxy. Used in search.
    init(searchIndexValue :[AnyHashable: Any]) {
        super.init()
        guard let values = searchIndexValue["_source"] as? [AnyHashable : Any] else {return}
        let json = JSON(values)
        guard json != JSON.null else {return}
        print(json)
        
        self.title = json["title"].string
        self.adDescription = json["description"].string
        if let adIDString = json["id"].string {
            self.adID = Int(adIDString)
        }
        if let urlString = json["url"].string {
            self.url = URL(string: urlString)
        }
        self.phoneNumber = json["debug_source_Phone"].string
        self.catID = json["subcategoryId"].int
        self.mainCatString = json["category"].string
        self.subCatString = json["subcategory"].string
        self.price = json["price"].string
        
        var coordinates = CLLocationCoordinate2D()
        if let latString = json["lat"].string {
            if let latDouble = Double(latString) {
                coordinates.latitude = latDouble
            }
        }
        if let lonString = json["lon"].string {
            if let lonDouble = Double(lonString) {
                coordinates.longitude = lonDouble
            }
        }
        let city = json["city"].string
        let zipCode = json["postalcode"].string
        let street = json["street"].string
        let houseNumber = json["housenumber"].string
        
        self.listingLocation = ListingLocation(coordinates: coordinates, street: street, houseNumber: houseNumber, zipCode: zipCode, city: city)
        
        if var listingDate = json["createDate"].string {
            let listingDateYear = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 2) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 4))]
            let listingDateMonth = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 5) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 7))]
            let listingDateDay = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 8) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 10))]
            listingDate = "\(listingDateDay).\(listingDateMonth).\(listingDateYear)"
            self.createdDate = listingDate
        }
        if var updatedAt = json["updateDate"].string {
            let updatedAtYear = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 2) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 4))]
            let updatedAtMonth = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 5) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 7))]
            let updatedAtDay = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 8) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 10))]
            updatedAt = "\(updatedAtDay).\(updatedAtMonth).\(updatedAtYear)"
            self.updatedDate = updatedAt
        }
        if let hasThumbUrl = json["hasThumbUrl"].string {
            if hasThumbUrl == "true" {
            self.hasImages = true
            }
        }
        if let containsAdultContent = json["containsAdultContent"].string {
            if containsAdultContent == "true" {
                self.containsAdultContent = true
            }
        }
        self.source = json["sourceId"].string
        self.thumbImageURL = json["thumbUrl"].string
        if let thumbUrlJSONArray = json["thumbUrlArray"].array {
            for jsonUrl in thumbUrlJSONArray {
                if let url = jsonUrl.string {
                self.imageURLs.append(url)
                }
            }
        } else {
            if thumbImageURL != nil {
            self.imageURLs.append(thumbImageURL!)
            }
        }
        if source != nil {
        switch self.source! {
        case "AS", "ASBikes":
            self.thumbImageURL = self.thumbImageURL?.replacingOccurrences(of: "small", with: "420x315")
            self.imageURLs = imageURLs.map({$0.replacingOccurrences(of: "small", with: "big")})
        case "IS":
            self.thumbImageURL = self.thumbImageURL?.replacingOccurrences(of: "/ORIG/resize/118x118%3E/extent/118x118/", with: "/ORIG/resize/370x297%3E/extent/370x297/")
            self.imageURLs = imageURLs.map({$0.replacingOccurrences(of: "/ORIG/resize/118x118%3E/extent/118x118/", with: "/ORIG/resize/370x297%3E/extent/370x297/")})
        case "Quo":
            self.thumbImageURL = self.thumbImageURL?.replacingOccurrences(of: "foto-bild-t", with: "foto-bild-m")
            self.imageURLs = imageURLs.map({$0.replacingOccurrences(of: "foto-bild-t", with: "foto-bild-m")})
        default: break
        }
        }
        
        if let entityType = json["debug_source_EntityType"].string {
            self.entityType = AdClass(rawValue: entityType)
        }
        if self.entityType == .AdCar || self.source == "AS" {
            self.component = AdCarComponent(searchIndexValue: values)
        }
        
        
    }
    
    
    
    
}

// MARK: Listing enums


/// Possible values: Gesuch, Angebot
enum AdType :String{
    case Angebot
    case Gesuch
    static let allValues = [Angebot : "Angebot", Gesuch : "Gesuch"]
}

/// Possible values: active, paused, expired, deletedByAdvertiser
enum AdState :String {
    case active
    case paused
    case expired
    case deletedByAdvertiser
}
/// Possible values: Zu verschenken, VHB, Festpreis, keine Angabe
enum PriceType :String {
    case zuVerschenken = "Zu verschenken"
    case vhb  = "VHB"
    case festpreis = "Festpreis"
    case keineAngabe = "Keine Angabe"
    static let allValues = [zuVerschenken : "Zu verschenken", vhb : "VHB", festpreis : "Festpreis", keineAngabe : "Keine Angabe"]
}







