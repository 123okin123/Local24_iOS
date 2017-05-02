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
            $0.header?.title = nil
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
        
        section <<< RangeRow<Int>() {
            $0.options = arrayFrom(0, to: 1000, stepValue: 1)
            $0.value = FilterRange(upperBound: (FilterManager.shared.getFilter(withName: .size) as? Rangefilter)?.lte, lowerBound: (FilterManager.shared.getFilter(withName: .size) as? Rangefilter)?.gte)
            $0.title = "Größe"
            $0.unit = "m²"
            }.onChange {
                let rangeFilter = Rangefilter(name: .size, descriptiveString: "Größe", gte: $0.value?.lowerBound, lte: $0.value?.upperBound, unit: "m²")
                FilterManager.shared.setfilter(newfilter: rangeFilter)
            }.cellUpdate {cell, row in
        }
        
        section <<< RangeRow<Int>() {
            $0.options = arrayFrom(0, to: 1000, stepValue: 1)
            $0.value = FilterRange(upperBound: (FilterManager.shared.getFilter(withName: .landarea) as? Rangefilter)?.lte, lowerBound: (FilterManager.shared.getFilter(withName: .landarea) as? Rangefilter)?.gte)
            $0.title = "Grundstücksfläche"
            $0.unit = "m²"
            }.onChange {
                let rangeFilter = Rangefilter(name: .landarea, descriptiveString: "Grundstücksfläche", gte: $0.value?.lowerBound, lte: $0.value?.upperBound, unit: "m²")
                FilterManager.shared.setfilter(newfilter: rangeFilter)
            }.cellUpdate {cell, row in
        }
        
        return section
    }

}
