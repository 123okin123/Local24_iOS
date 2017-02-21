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
    var adID :Int!
    
    var source :String?
    var adState :AdState?
    var advertiserID :Int?
    var user :User?
    var title :String?
    var adDescription :String?

    var specialFields :[SpecialField]?
    
    var adType :AdType?
    var entityType :String?
    var price :String?
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

    var adLat: Double?
    var adLong: Double?
    
    var distance :Double? {
        guard self.adLat != nil else {return nil}
        guard self.adLong != nil else {return nil}
        let location = CLLocation(latitude: self.adLat!, longitude: self.adLong!)
        if let geofilter = FilterManager.shared.getFilter(withName: .geo_distance) as? Geofilter {
            return round(location.distance(from:  CLLocation(latitude: geofilter.lat, longitude: geofilter.lon))/1000)
        } else {return nil}
    }
 
    var city :String?
    var zipcode: String?
    var street: String?
    var houseNumber :String?
   
    var phoneNumber :String?
    
    var catID :Int?
    
    var createdDate :String?
    var updatedDate :String?
    
    var hasImages = false
    var thumbImage :UIImage?
    var images :[UIImage]?
    var thumbImageURL :String?
    var imageURLs = [String]()
    
    
    var url :URL?
    
    var containsAdultContent = false
    
    override init() {
    super.init()
    }
    
    
    init(value: [AnyHashable:Any]) {
        super.init()
        
        specialFields = [SpecialField]()
        
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
            self.entityType = entityType
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
        
        
        
        if let latitude = value["Latitude"] as? Double {
            self.adLat = latitude
        }
        if let longitude = value["Longitude"] as? Double {
            self.adLong = longitude
        }
        if let street = value["Street"] as? String {
            self.street = street
        }
        if let houseNumber = value["HouseNumber"] as? String {
            self.houseNumber = houseNumber
        }
        if let phone = value["Phone"] as? String {
            self.phoneNumber = phone
        }
        if let city = value["City"] as? String {
            self.city = city
        }
        if let zipcode = value["ZipCode"] as? String {
            self.zipcode = zipcode
        }
        
        
        

        if let model = value["Model"] as? String {
            let spicalField = SpecialField(name: "Model", descriptiveString: "Model", value: model, possibleValues: nil, type: .string)
            spicalField.dependsOn = SpecialField(name: "Make", descriptiveString: "Marke", value: nil, possibleValues: nil, type: .string)
            self.specialFields?.append(spicalField)
        }

        if let priceTypeProperty = value["PriceTypeProperty"] as? String {
            let spicalField = SpecialField(name: "PriceTypeProperty", descriptiveString: "Preisart", value: priceTypeProperty, possibleValues: nil, type: .string)
            spicalField.dependsOn = SpecialField(name: "SellOrRent", descriptiveString: "Verkauf oder Vermietung", value: nil, possibleValues: nil, type: .string)
            self.specialFields?.append(spicalField)
        }
        
        if let path = Bundle.main.path(forResource: "specialFields", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = JSON(data: data)
                if json != JSON.null {
                    guard let entityType = self.entityType else {return}
                    if let fields = json[entityType].dictionary {
                        for field in fields {
                            let specialField = SpecialField(entityType: entityType, name: field.key)
                            specialField.value = value[field.key]
                            
                            // Hide Nebenkosten / Kaution
                            if specialField.name == "AdditionalCosts" || specialField.name == "DepositAmount" {
                                if let sellOrRent = self.specialFields?.first(where: {$0.name == "SellOrRent"}) {
                                    if let value = sellOrRent.value as? String {
                                        if value == "Vermietung" {
                                        self.specialFields?.append(specialField)
                                        }
                                    }
                                }
                            } else {
                                // Default case
                                self.specialFields?.append(specialField)
                                
                            }
                            

                        }
                        
                    } else {
                        print("entitytype not in json")
                    }
                } else {
                    print("Could not get json from file, make sure that file contains valid json.")
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }

        
    }
    
    
    
    
    init(searchIndexValue :[AnyHashable: Any]) {
        super.init()
        guard let values = searchIndexValue["_source"] as? [AnyHashable : Any] else {return}
        let json = JSON(values)
        guard json != JSON.null else {return}
        self.title = json["title"].string
        self.adDescription = json["description"].string
        if let adIDString = json["id"].string {
            self.adID = Int(adIDString)
        }
        if let urlString = json["url"].string {
            self.url = URL(string: urlString)
        }
        self.catID = json["subcategoryId"].int
        self.price = json["price"].string
        if let latString = json["lat"].string {
            self.adLat = Double(latString)
        }
        if let lonString = json["lon"].string {
            self.adLong = Double(lonString)
        }
        self.city = json["city"].string
        self.zipcode = json["postalcode"].string
        
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
        case "AS":
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
    }
    
    
    
    
}


enum AdType :String{
case Angebot
case Gesuch
    static let allValues = [Angebot : "Angebot", Gesuch : "Gesuch"]
}

enum AdState :String {
case active
case paused
case expired
case deletedByAdvertiser

}

enum PriceType :String {
    case zuVerschenken = "Zu verschenken"
    case vhb  = "VHB"
    case festpreis = "Festpreis"
    case keineAngabe = "Keine Angabe"
    static let allValues = [zuVerschenken : "Zu verschenken", vhb : "VHB", festpreis : "Festpreis", keineAngabe : "Keine Angabe"]
}




class SpecialField {
    var name:String?
    var descriptiveString :String?
    var value :Any?
    var possibleValues :[Any]?
    var hasDependentField = false
    var type :SpecialFieldType?
    var isIndipendent = true
    var isDependent = false
    var dependsOn :SpecialField?
    var dependingField :SpecialField?
    var unit: String?
    
    var valueString :String? {
        var string :String?
        switch type {
        case .string?:
            string = value as! String?
        case .int?:
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            if let value = value as? Int {
                string =  numberFormatter.string(from: NSNumber(value: value))
            }
        case nil:
            return nil
        }
        if unit != nil {
            string?.append(unit!)
        }
        return string
    }
    
    var possibleStringValues :[String]? {
        var stringValues  :[String]?
        switch type {
        case .string?:
            if let strings = possibleValues as? [String]? {
            stringValues = strings
            }
        case .int?:
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            if let ints = possibleValues as? [Int] {
                stringValues = ints.map {numberFormatter.string(from: NSNumber(value: $0))!}
            }
        case nil:
            return nil
        }
        if unit != nil {
            if stringValues != nil {
                stringValues = stringValues!.map {$0 + unit!}
            }
        }
        return stringValues
    }
    
    enum SpecialFieldType :String {
    case string
    case int
    }
    
    
    init(entityType: String, name: String) {
    self.name = name
        if let path = Bundle.main.path(forResource: "specialFields", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = JSON(data: data)
                if json != JSON.null {
                    if let fields = json[entityType].dictionary {
                        if let field = fields[name]?.dictionary {
                            self.descriptiveString = field["descriptiveString"]?.string
                            self.possibleValues = field["possibleValues"]?.arrayObject as [Any]?
                            self.unit = field["unit"]?.string
                            if let hasDependentField = field["hasDependentField"]?.bool {
                            self.hasDependentField = hasDependentField
                            }
                            if let type = field["type"]?.string {
                            self.type = SpecialFieldType.init(rawValue: type)
                            }
                        }
                    }
                } else {
                    print("Could not get json from file, make sure that file contains valid json.")
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
    }
    
    init(name: String?, descriptiveString :String?, value: Any?) {
        self.name = name
        self.descriptiveString = descriptiveString
        self.value = value
    }
    
    init(name: String?, descriptiveString :String?, value: Any?, possibleValues: [Any]?) {
        self.name = name
        self.descriptiveString = descriptiveString
        self.value = value
        self.possibleValues = possibleValues
    }
    init(name: String?, descriptiveString :String?, value: Any?, possibleValues: [Any]?, type: SpecialFieldType?) {
        self.name = name
        self.descriptiveString = descriptiveString
        self.value = value
        self.possibleValues = possibleValues
        self.type = type
    }
}



