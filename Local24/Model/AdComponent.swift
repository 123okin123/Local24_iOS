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
    func componentToJSON() -> [AnyHashable: Any]?
    func componentToRepresentableTupleArray() -> [(name: String?,value: String?)]
}
