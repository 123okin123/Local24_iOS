//
//  InsertVCAdCarSection.swift
//  Local24
//
//  Created by Nikolai Kratz on 06.06.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka


extension InsertViewController {

func sectionForAdCar() -> Section {
    let section = Section("adCarSection") {
        $0.header?.title = nil
        $0.hidden = Condition.function(["catTag"], {form in
            if form.rowBy(tag: "catTag")?.value == "Auto" {
                self.listing.component = AdCarComponent()
                return false
            } else {
                return true
            }
          
        })
    }
    
    section <<< PickerInputRow<Int>() {
        $0.title = "Kilometerstand"
        $0.value = 500
        $0.options = arrayFrom(1, to: 500000, stepValue: 500)
        }.onChange {
            guard let component = self.listing.component as? AdCarComponent else {return}
             component.mileAge = $0.value
    }
    
    section <<< PushRow<String>("makeTag") { row in
        row.title = "Marke"
        row.selectorTitle = row.title
        row.options =  ["Alle Marken"]
        NetworkManager.shared.getValuesForField("Make", entityType: .AdCar, completion: { values, error in
            if error == nil {
                row.options = values!
            }
        })
        
        }.onChange {
            guard let value = $0.value else {return}
            guard value != "Alle Marken" else {return}
            
            
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

        $0.options = ["Alle Modelle"]
        }.cellUpdate {cell, row in
            
        }.onChange {
            guard let value = $0.value else {return}
            guard value != "Alle Modelle" else {return}

            //
        }.onPresent { from, to in
            self.applyCustomStyleOnSelectorVC(to)
            (to.row as! PushRow).options.removeAll()
            guard let makeRowValue = (self.form.rowBy(tag: "makeTag") as? PushRow<String>)?.value else {return}
            NetworkManager.shared.getValuesForDepending(field: "Model", independendField: "Make", value: makeRowValue, entityType: .AdCar, completion: {values, error in
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

    return section
}
}
