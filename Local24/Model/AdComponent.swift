//
//  AdComponent.swift
//  Local24
//
//  Created by Nikolai Kratz on 06.06.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol AdComponent {
    init()
    init(apiValue value:[AnyHashable: Any])
    init(searchIndexValue value: [AnyHashable: Any])
    /// Returns a JSON representation of the component, which can be used to post ads to the api.
    func componentToJSON() -> [AnyHashable: Any]?
    /// Returns an array of tuples, which represent the props of the component
    func componentToRepresentableTupleArray() -> [(name: String?,value: String?)]
}
