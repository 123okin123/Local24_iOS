//
//  Listing.swift
//  Local24
//
//  Created by Local24 on 09/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation


class Listing {

    var title :String?
    var description :String?
    var adType :AdType?
    var entityType :String?
    var price :String?
    var priceType :PriceType?
    
    var advertiserID :Int?
    
    var catID :Int?
    
    var createdDate :String?
    var mainImage :UIImage?
    var hasImages: Bool?
    var imagePathMedium :String?
    
    var url :URL?
    
    
    
    init(value: [AnyHashable:Any]) {
        if let url = value["DetailPageLink"] as? String {
            self.url = URL(string: url)
        }
        if let listingTitle = value["Title"] as? String {
            self.title = listingTitle
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


enum AdType {
case gesuch
case angebot
}

enum PriceType {
case zuVerschenken
case vhb
case festpreis
case keineAngabe
}
