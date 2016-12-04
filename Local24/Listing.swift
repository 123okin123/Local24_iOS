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
    var title :String?
    var description :String?
    var adType :AdType?
    var entityType :String?
    var price :String?
    var priceType :String?
    var city :String?
    var zipcode: String?
    
    var advertiserID :Int?
    
    var catID :Int?
    
    var createdDate :String?
    var mainImage :UIImage?
    var hasImages: Bool?
    var imagePathMedium :String?
    
    var url :URL?
    
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
        }
        if let listingPrice = value["Price"] as? String {
            self.price = listingPrice
        }
        if let listingPrice = value["Price"] as? Float {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            self.price = formatter.string(from: NSNumber(value: listingPrice))
        } else {
            if let pricetype = value["Price"] as? String {
                self.price = pricetype
            } else {
                self.price = "k.A."
            }
        }
        if let city = value["City"] as? String {
            self.city = city
        }
        if let zipcode = value["ZipCode"] as? String {
            self.zipcode = zipcode
        }
        if var listingDate = value["CreatedAt"] as? String {
            let listingDateYear = listingDate[Range(listingDate.startIndex ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 4))]
            let listingDateMonth = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 5) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 7))]
            let listingDateDay = listingDate[Range(listingDate.characters.index(listingDate.startIndex, offsetBy: 8) ..< listingDate.characters.index(listingDate.startIndex, offsetBy: 10))]
            listingDate = "\(listingDateDay).\(listingDateMonth).\(listingDateYear)"
            self.createdDate = listingDate
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
