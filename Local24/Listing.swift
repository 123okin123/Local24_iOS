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
