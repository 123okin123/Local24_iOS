//
//  Listing.swift
//  Local24
//
//  Created by Local24 on 09/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation
import SwiftyJSON

class Listing {

    var source :String?
    var adID :Int?
    var adState :AdState?
    var advertiserID :Int?
    var user :User?
    var title :String?
    var description :String?

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
    
    var city :String?
    var zipcode: String?
    var street: String?
    var houseNumber :String?
   
    var phoneNumber :String?
    
    var catID :Int?
    
    var createdDate :String?
    var updatedDate :String?
    
    var mainImage :UIImage?
    var images :[UIImage]?
    var hasImages: Bool?
    var imagePathMedium :String?
    
    var url :URL?
    

    
    init() {}
    
    
    init(value: [AnyHashable:Any]) {
        
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
            self.description = description
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
            let listingDateYear = listingDate[Range(listingDate.startIndex ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 4))]
            let listingDateMonth = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 5) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 7))]
            let listingDateDay = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 8) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 10))]
            listingDate = "\(listingDateDay).\(listingDateMonth).\(listingDateYear)"
            self.createdDate = listingDate
        }
        if var updatedAt = value["UpdatedAt"] as? String {
            let updatedAtYear = updatedAt[Range(updatedAt.startIndex ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 4))]
            let updatedAtMonth = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 5) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 7))]
            let updatedAtDay = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 8) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 10))]
            updatedAt = "\(updatedAtDay).\(updatedAtMonth).\(updatedAtYear)"
            self.updatedDate = updatedAt
        }
        if let hasImages = value["HasImages"] as? Bool {
        if hasImages  {
            self.hasImages = true
            if let images = value["GalleryImage"] as? NSDictionary {
                if let imagePathMedium = images["ImagePathMedium"] as? String  {
                    self.imagePathMedium = imagePathMedium
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
        guard let values = searchIndexValue["_source"] as? [AnyHashable : Any] else {return}
        let json = JSON(values)
        guard json != JSON.null else {return}
        self.title = json["title"].string
        self.description = json["description"].string
        self.adID = json["_id"].int
        self.catID = json["subcategoryId"].int
        self.price = json["price"].string
        self.adLat = json["lat"].double
        self.adLong = json["lon"].double
        if var listingDate = json["createDate"].string {
            let listingDateYear = listingDate[Range(listingDate.startIndex ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 4))]
            let listingDateMonth = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 5) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 7))]
            let listingDateDay = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 8) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 10))]
            listingDate = "\(listingDateDay).\(listingDateMonth).\(listingDateYear)"
            self.createdDate = listingDate
        }
        if var updatedAt = json["updateDate"].string {
            let updatedAtYear = updatedAt[Range(updatedAt.startIndex ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 4))]
            let updatedAtMonth = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 5) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 7))]
            let updatedAtDay = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 8) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 10))]
            updatedAt = "\(updatedAtDay).\(updatedAtMonth).\(updatedAtYear)"
            self.updatedDate = updatedAt
        }
        self.source = json["sourceId"].string
        self.imagePathMedium = json["thumbUrl"].string
        if source != nil {
        switch self.source! {
        case "AS":
            self.imagePathMedium = self.imagePathMedium?.replacingOccurrences(of: "small", with: "420x315")
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



