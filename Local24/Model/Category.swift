//
//  Category.swift
//  Local24
//
//  Created by Locla24 on 27/01/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import Foundation



class Category {
    var id :Int!
    var idParentCategory :Int!
    var name :String!
    var level :Int!
    /// The associated adclass of the category. Default is adplain .
    var adclass :AdClass!
    var isParentCat :Bool!
}


