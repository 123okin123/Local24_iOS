//
//  User.swift
//  Local24
//
//  Created by Local24 on 21/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation


public class User {

    var firstName :String?
    var lastName :String?
    var totalAdsCount :Int?
    
    init(value: [AnyHashable:Any]) {
        if let firstName = value["FirstName"] as? String {
            self.firstName = firstName
        }
        if let lastName = value["LastName"] as? String {
            self.lastName = lastName
        }
        if let totalAdsCount = value["TotalAdsCount"] as? Int {
            self.totalAdsCount = totalAdsCount
        }
    }

}
