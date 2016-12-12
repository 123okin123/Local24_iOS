//
//  Listing.swift
//  Local24
//
//  Created by Local24 on 09/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation


class Listing {

    var adID :Int?
    var adState :AdState?
    var advertiserID :Int?
    var title :String?
    var description :String?
    var adType :AdType?
    var entityType :String?
    var price :String?
    var priceType :String?
    var priceWithCurrency :String? {get {
        if price != nil {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: Double(price!)!))
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
    
    
    var infos = [(String, String)]()
    // Auto
    var condition :String?
    var make : String?
    var model :String?
    var mileageString :String?
    var initialRegistration :String?
    var fuelType :String?
    var fuelConsumptionString :String?
    var powerString :String?
    var gearType :String?
    
    //Immo
    var priceTypeProperty :String?
    var additionalCostsFloat :Float?
    var depositAmountFloat :Float?
    var size :Float?
    var totalRoomsInt :Int?
    var apartmentType :String?
    
    init() {}
    
    
    init(value: [AnyHashable:Any]) {
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
            self.infos.append(("Preisart", priceType))
        }

        if let listingPrice = value["Price"] as? Float {
            self.price = String(describing: Int(listingPrice))
        } else {
            if let price = value["Price"] as? String {
                self.price = price
            } 
        }

        if var listingDate = value["CreatedAt"] as? String {
            let listingDateYear = listingDate[Range(listingDate.startIndex ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 4))]
            let listingDateMonth = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 5) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 7))]
            let listingDateDay = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 8) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 10))]
            listingDate = "\(listingDateDay).\(listingDateMonth).\(listingDateYear)"
            self.createdDate = listingDate
            self.infos.append(("Datum", listingDate))
        }
        if var updatedAt = value["UpdatedAt"] as? String {
            let updatedAtYear = updatedAt[Range(updatedAt.startIndex ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 4))]
            let updatedAtMonth = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 5) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 7))]
            let updatedAtDay = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 8) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 10))]
            updatedAt = "\(updatedAtDay).\(updatedAtMonth).\(updatedAtYear)"
            self.updatedDate = updatedAt
            self.infos.append(("Aktualisiert", updatedAt))
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
        
        
        
        //Autos
        if let condition = value["Condition"] as? String {
            self.condition = condition
        }
        if let make = value["Make"] as? String {
            self.make = make
        }
        if let model = value["Model"] as? String {
            self.model = model
        }
        if let mileage = value["Mileage"] as? Float {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let mileageString = formatter.string(from: NSNumber(value: mileage))! + " km"
            self.mileageString = mileageString
        }
        if let initialRegistration = value["InitialRegistration"] as? String {
            self.initialRegistration = initialRegistration
        }
        if let fuelType = value["FuelType"] as? String {
            self.fuelType = fuelType
        }
        if let fuelConsumption = value["FuelConsumption"] as? Float {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            let fuelConsumptionString = formatter.string(from: NSNumber(value: fuelConsumption))! + " l/100km (kombiniert)"
            self.fuelConsumptionString = fuelConsumptionString
        }
        if let power = value["Power"] as? Float {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            let kWpower = power * 0.735499
            let powerString = formatter.string(from: NSNumber(value: power))! + "PS / " + formatter.string(from: NSNumber(value: kWpower))! + "kW"
            self.powerString = powerString
        }
        if let gearType = value["GearType"] as? String {
            self.gearType = gearType
        }
        
        // Immobilien
        if let priceTypeProperty = value["PriceTypeProperty"] as? String {
            self.priceTypeProperty = priceTypeProperty
        }
        if var additionalCostsFloat = value["AdditionalCosts"] as? Float {
            additionalCostsFloat = (additionalCostsFloat * 1000)/1000
            //let additionalCosts = "\(String(format: "%.2f", additionalCostsFloat).replacingOccurrences(of: ".", with: ",")) €"
            self.additionalCostsFloat = additionalCostsFloat
        }
        if var depositAmountFloat = value["DepositAmount"] as? Float {
            depositAmountFloat = (depositAmountFloat * 1000)/1000
            //let depositAmount = "\(String(format: "%.2f", depositAmountFloat).replacingOccurrences(of: ".", with: ",")) €"
            self.depositAmountFloat = depositAmountFloat
        }
        if var sizeFloat = value["Size"] as? Float {
            sizeFloat = (sizeFloat * 1000)/1000
            //let size = "\(String(format: "%.2f", sizeFloat).replacingOccurrences(of: ".", with: ",")) m²"
            self.size = sizeFloat
        }
        if let totalRoomsInt = value["TotalRooms"] as? Int {
            //let totalRooms = String(totalRoomsInt)
            self.totalRoomsInt = totalRoomsInt
        }
        if let apartmentType = value["ApartmentType"] as? String {
            self.apartmentType = apartmentType
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
