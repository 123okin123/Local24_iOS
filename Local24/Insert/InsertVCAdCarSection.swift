//
//  InsertVCAdCarSection.swift
//  Local24
//
//  Created by Nikolai Kratz on 06.06.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka
import SwiftyJSON

extension InsertViewController {
    


    
    func sectionForAdCar() -> Section {
        let section = Section("adCarSection") {
            $0.header?.title = "Weitere Infos"
            $0.hidden = Condition.function(["catTag"], {form in
                if form.rowBy(tag: "catTag")?.value == "Auto" {
                    // set new adCarComponent for listing if not existing
                    if ((self.listing.component as? AdCarComponent) == nil) {
                        self.listing.component = AdCarComponent()
                    }
                    // load options for adcar fields
                    NetworkManager.shared.getOptionsForEntityType(.AdCar, completion: {options, error in
                        if error == nil && options != nil {
                        self.optionsForComponent = options
                        }
                    })
                    return false
                } else {
                    return true
                }
                
            })
        }
        
        section <<< PickerInputRow<Int>() {
            $0.title = "Kilometerstand in km"
            $0.options = arrayFrom(1, to: 500000, stepValue: 500)
            guard let component = self.listing.component as? AdCarComponent else {return}
            $0.value = component.mileAge
            }.onChange {
                guard let component = self.listing.component as? AdCarComponent else {return}
                component.mileAge = $0.value
            }
        
        section <<< PushRow<String>("makeTag") { row in
            row.title = "Marke"
            row.value = "Alle Marken"
            row.selectorTitle = row.title
            guard let component = self.listing.component as? AdCarComponent else {return}
            row.value = component.make
            }.onChange {
                guard let value = $0.value else {return}
                guard value != "Alle Marken" else {return}
                guard let component = self.listing.component as? AdCarComponent else {return}
                component.make = value
            }.onPresent { from, to in
                self.applyCustomStyleOnSelectorVC(to)
                to.enableDeselection = false
                to.sectionKeyForValue = { option in
                    switch option {
                    case "Alle Marken": return ""
                    default: return " "
                    }
                }
            }.cellUpdate {
                if let options = self.optionsForComponent?.filter({$0["SelectId"].string == "Make"}).map({return $0["OptionValue"].string!}) {
                    $1.options = options
                }
        }
        
        section <<< PushRow<String>("modelTag") {
            $0.hidden = Condition.function(["makeTag"], {form in
                form.rowBy(tag: "modelTag")?.updateCell()
                return (form.rowBy(tag: "makeTag")?.value == "Alle Marken")
            })
            $0.title = "Modell"
            $0.selectorTitle = $0.title
            guard let component = self.listing.component as? AdCarComponent else {return}
            $0.value = component.model
            }.onChange {
                guard let value = $0.value else {return}
                guard value != "Alle Modelle" else {return}
                guard let component = self.listing.component as? AdCarComponent else {return}
                component.model = value
            }.onPresent { from, to in
                self.applyCustomStyleOnSelectorVC(to)
                (to.row as! PushRow).options.removeAll()
                guard let makeRowValue = (self.form.rowBy(tag: "makeTag") as? PushRow<String>)?.value else {return}
                NetworkManager.shared.getValuesForDepending(field: "Model", independendField: "Make", value: makeRowValue, entityType: .AdCar, completion: {values, error in
                    if var options = values {
                        options.remove(at: 0)
                        (to.row as! PushRow).options = options
                        to.setupForm()
                    }
                })
                to.enableDeselection = false
                to.sectionKeyForValue = { _ in return " "}
        }
        
        
        section <<< PushRow<String>() { row in
            row.title = "Außenfarbe"
            row.selectorTitle = row.title
            guard let component = self.listing.component as? AdCarComponent else {return}
            row.value = component.bodyColor
            }.onChange {
                guard let value = $0.value else {return}
                guard let component = self.listing.component as? AdCarComponent else {return}
                component.bodyColor = value
            }.onPresent { from, to in
                self.applyCustomStyleOnSelectorVC(to)
                to.enableDeselection = false
                to.sectionKeyForValue = { _ in return " "}
                
            }.cellUpdate {
                if let options = self.optionsForComponent?.filter({$0["SelectId"].string == "BodyColor"}).map({return $0["OptionValue"].string!}) {
                    $1.options = options
                }
        }
        
        section <<< PushRow<String>() { row in
            row.title = "Karosserieform"
            row.selectorTitle = row.title
            guard let component = self.listing.component as? AdCarComponent else {return}
            row.value = component.bodyForm
            }.onChange {
                guard let value = $0.value else {return}
                guard let component = self.listing.component as? AdCarComponent else {return}
                component.bodyForm = value
            }.onPresent { from, to in
                self.applyCustomStyleOnSelectorVC(to)
                to.enableDeselection = false
                to.sectionKeyForValue = { _ in return " "}
            }.cellUpdate {
                if let options = self.optionsForComponent?.filter({$0["SelectId"].string == "BodyForm"}).map({return $0["OptionValue"].string!}) {
                    $1.options = options
                }
        }
        
        section <<< AlertRow<String>() { row in
            row.title = "Zustand"
            row.selectorTitle = row.title
            guard let component = self.listing.component as? AdCarComponent else {return}
            row.value = component.condition
            }.onChange {
                guard let value = $0.value else {return}
                guard let component = self.listing.component as? AdCarComponent else {return}
                component.condition = value
            }.cellUpdate {
                if let options = self.optionsForComponent?.filter({$0["SelectId"].string == "Condition"}).map({return $0["OptionValue"].string!}) {
                    $1.options = options
                }
            }.onPresent {from, to in
                to.cancelTitle = "Abbrechen"
        }
        
        
        section <<< PushRow<String>() { row in
            row.title = "Kraftstoffart"
            row.selectorTitle = row.title
            guard let component = self.listing.component as? AdCarComponent else {return}
            row.value = component.fuelType
            }.onChange {
                guard let value = $0.value else {return}
                guard let component = self.listing.component as? AdCarComponent else {return}
                component.fuelType = value
            }.onPresent { from, to in
                self.applyCustomStyleOnSelectorVC(to)
                to.enableDeselection = false
                to.sectionKeyForValue = { _ in return " "}
            }.cellUpdate {
                if let options = self.optionsForComponent?.filter({$0["SelectId"].string == "FuelType"}).map({return $0["OptionValue"].string!}) {
                    $1.options = options
                }
        }
        
        
        section <<< AlertRow<String>() { row in
            row.title = "Getriebeart"
            row.selectorTitle = row.title
            guard let component = self.listing.component as? AdCarComponent else {return}
            row.value = component.gearType
            }.onChange {
                guard let value = $0.value else {return}
                guard let component = self.listing.component as? AdCarComponent else {return}
                component.gearType = value
            }.cellUpdate {
                if let options = self.optionsForComponent?.filter({$0["SelectId"].string == "GearType"}).map({return $0["OptionValue"].string!}) {
                    $1.options = options
                }
            }.onPresent {from, to in
                to.cancelTitle = "Abbrechen"
        }
        
        section <<< DateRow() {
            $0.title = "Erstzulassung"
            $0.noValueDisplayText = "Bitte wählen..."
            $0.dateFormatter?.dateStyle = .short
            guard let component = self.listing.component as? AdCarComponent else {return}
            $0.value = component.initialRegistration
            }.onChange {
                guard let component = self.listing.component as? AdCarComponent else {return}
                component.initialRegistration = $0.value
        }
        
        section <<< PickerInputRow<Int>() {
            $0.title = "Leistung in PS"
            $0.options = arrayFrom(1, to: 500, stepValue: 1)
            guard let component = self.listing.component as? AdCarComponent else {return}
            $0.value = component.power
            }.onChange {
                guard let component = self.listing.component as? AdCarComponent else {return}
                component.power = $0.value
        }
    
        return section
    }
}
