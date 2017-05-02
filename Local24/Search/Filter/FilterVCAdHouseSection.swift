//
//  FilterVCAdHouseSection.swift
//  Local24
//
//  Created by Nikolai Kratz on 02.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka


extension FilterViewController {
    func sectionForAdHouse() -> Section {
        let section = Section("adHouseSection") {
            $0.hidden = Condition.function(["subCatTag"], {form in
                return (form.rowBy(tag: "subCatTag")?.value != "Haus")
            })
        }
        
        section <<< RangeRow<Int>() {
            $0.options = arrayFrom(0, to: 10, stepValue: 1)
            $0.value = FilterRange(upperBound: (FilterManager.shared.getFilter(withName: .totalRooms) as? Rangefilter)?.lte, lowerBound: (FilterManager.shared.getFilter(withName: .totalRooms) as? Rangefilter)?.gte)
            $0.title = "Zimmeranzahl"
            }.onChange {
                let rangeFilter = Rangefilter(name: .totalRooms, descriptiveString: "Zimmeranzahl", gte: $0.value?.lowerBound, lte: $0.value?.upperBound)
                FilterManager.shared.setfilter(newfilter: rangeFilter)
            }.cellUpdate {cell, row in
        }
        return section
    }

}
