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
        $0.value = 0
        $0.options = arrayFrom(0, to: 500000, stepValue: 500)
        }.onChange {
            guard let component = self.listing.component as? AdCarComponent else {return}
             component.mileAge = $0.value
    }
    
    return section
}
}
