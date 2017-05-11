//
//  FilterVCAdCarSection.swift
//  Local24
//
//  Created by Nikolai Kratz on 02.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka


extension FilterViewController {
    
    func sectionForAdCar() -> Section {
        let section = Section("adCarSection") {
            $0.header?.title = nil
            $0.hidden = Condition.function(["subCatTag"], {form in
                if form.rowBy(tag: "subCatTag")?.value != "Auto" {
                    FilterManager.shared.removeFiltersForAdClass(adClass: .AdCar)
                    return true
                } else {
                    return false
                }
            })
        }
        
        section <<< PushRow<String>("makeTag") {
            $0.title = "Marke"
            $0.selectorTitle = $0.title
            $0.value = (FilterManager.shared.getFilter(withName: .makeName) as? Termfilter)?.value ?? "Alle Marken"
            $0.options =  ["Alle Marken"] + SpecialFieldsManager.shared.getSpecialFieldWith(entityType: .AdCar, name: "Make")!.possibleStringValues!
            }.onChange {
                FilterManager.shared.removefilterWithName(.makeName)
                guard let value = $0.value else {return}
                guard value != "Alle Marken" else {return}
                FilterManager.shared.setfilter(newfilter: Termfilter(name: .makeName, descriptiveString: "Marke", value: value))
            }.onPresent { from, to in
                self.applyCustomStyleOnSelectorVC(to)
                to.enableDeselection = false
                to.sectionKeyForValue = { option in
                    switch option {
                    case "Alle Marken": return ""
                    default: return " "
                    }
                }
        }
        
        section <<< PushRow<String>("modelTag") {
            $0.hidden = Condition.function(["makeTag"], {form in
                form.rowBy(tag: "modelTag")?.updateCell()
                return (form.rowBy(tag: "makeTag")?.value == "Alle Marken")
            })
            $0.title = "Modell"
            $0.selectorTitle = $0.title
            $0.value = (FilterManager.shared.getFilter(withName: .modelName) as? Termfilter)?.value ?? "Alle Modelle"
            $0.options = ["Alle Modelle"]
            }.cellUpdate {cell, row in
                row.value = (FilterManager.shared.getFilter(withName: .modelName) as? Termfilter)?.value ?? "Alle Modelle"
                cell.detailTextLabel?.text = row.value
            }.onChange {
                FilterManager.shared.removefilterWithName(.modelName)
                guard let value = $0.value else {return}
                guard value != "Alle Modelle" else {return}
                let filter = Termfilter(name: .modelName, descriptiveString: "Modell", value: value)
                FilterManager.shared.setfilter(newfilter: filter)
            }.onPresent { from, to in
                self.applyCustomStyleOnSelectorVC(to)
                guard let makeFilter = FilterManager.shared.getFilter(withName: .makeName) as? Termfilter else {return}
                NetworkManager.shared.getValuesForDepending(field: "Model", independendField: "Make", value: makeFilter.value!, entityType: .AdCar, completion: {values, error in
                    if var options = values {
                        options.remove(at: 0)
                        if (to.row as! PushRow).options != options {
                        (to.row as! PushRow).options = options
                            to.setupForm()
                        }
                        
                    }
                })
                to.enableDeselection = false
                to.sectionKeyForValue = { option in
                    switch option {
                    case "Alle Modelle": return ""
                    default: return " "
                    }
                }
        }
        
        section <<< RangeRow<Int>() {
            $0.options = arrayFrom(0, to: 500000, stepValue: 5000)
            $0.value = FilterRange(upperBound: (FilterManager.shared.getFilter(withName: .mileage) as? Rangefilter)?.lte, lowerBound: (FilterManager.shared.getFilter(withName: .mileage) as? Rangefilter)?.gte)
            $0.title = "Laufleistung"
            $0.unit = "km"
            }.onChange {
                let rangeFilter = Rangefilter(name: .mileage, descriptiveString: "Laufleistung", gte: $0.value?.lowerBound, lte: $0.value?.upperBound, unit: "km")
                FilterManager.shared.setfilter(newfilter: rangeFilter)
            }
        
        
        
        return section
    }

}
