//
//  FilterViewController.swift
//  Local24
//
//  Created by Nikolai Kratz on 26.04.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka

class FilterViewController: FormViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TextRow.defaultCellUpdate = { cell, row in cell.textLabel?.font = UIFont(name: "OpenSans", size: 17.0) }
        SwitchRow.defaultCellUpdate = { cell, row in cell.switchControl?.onTintColor = greencolor }
        tableView?.backgroundColor = local24grey
        tableView?.separatorColor = local24grey
        
        
        form
            // Search Query
            +++ Section()
            <<< TextRow(){ row in
                row.title = "Suchbegriff"
                row.placeholder = "z.B. Fahrrad"
                }.onChange {
                    guard let value = $0.value else {return}
                    if value == "" {
                        FilterManager.shared.removefilterWithName(.search_string)
                    } else {
                        FilterManager.shared.setfilter(newfilter: Stringfilter(value: value))
                    }
            }
            
            
            // Location
            +++ Section()
            <<< PushRow<String>() {
                $0.title = "Ort"
                $0.value = FilterManager.shared.getValueOffilter(withName: .geo_distance, filterType: .geo_distance)
                $0.presentationMode = .segueName(segueName: "showLocationVCFromFilterSegueID", onDismiss: nil)
                }.cellUpdate { cell, row in
                    row.value = FilterManager.shared.getValueOffilter(withName: .geo_distance, filterType: .geo_distance)
            }
            
            
            
            //Price
            +++ Section()
            <<< DecimalRow(){
                $0.useFormatterDuringInput = true
                $0.title = "Preis von"
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
                }.onChange {
                    guard let value = $0.value else {return}
                    let currentPriceRangeFilter = FilterManager.shared.getFilter(withName: .price) as? Rangefilter
                    let priceRangeFilter = Rangefilter(name: .price, descriptiveString: "Preis", gte: Int(value), lte: currentPriceRangeFilter?.lte)
                    FilterManager.shared.setfilter(newfilter: priceRangeFilter)

            }
            <<< DecimalRow(){
                $0.useFormatterDuringInput = true
                $0.title = "Preis bis"
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
                }.onChange {
                    guard let value = $0.value else {return}
                    let currentPriceRangeFilter = FilterManager.shared.getFilter(withName: .price) as? Rangefilter
                    let priceRangeFilter = Rangefilter(name: .price, descriptiveString: "Preis", gte: currentPriceRangeFilter?.gte, lte: Int(value))
                    FilterManager.shared.setfilter(newfilter: priceRangeFilter)
            }
            
            
            
            
            //Category Filter
            +++ Section()
            <<< PushRow<String>("mainCatTag") {
                $0.title = "Kategorie"
                $0.options = ["Alle Anzeigen"] + CategoryManager.shared.mainCategories.map({$0.name})
                $0.value = (FilterManager.shared.getFilter(withName: .category) as? Termfilter)?.value ?? "Alle Anzeigen"
                $0.selectorTitle = "Kategorie"
                }.onChange {
                    FilterManager.shared.removefilterWithName(.subcategory)
                    guard ($0.value != nil) && $0.value != "Alle Anzeigen" else {return}
                    let filter = Termfilter(name: .category, descriptiveString: "Kategorie", value: $0.value!)
                    FilterManager.shared.setfilter(newfilter: filter)
                }.onPresent { from, to in
                    self.applyCustomStyleOnSelectorVC(to)
                    to.enableDeselection = false
                    to.sectionKeyForValue = { option in
                        switch option {
                        case "Alle Anzeigen": return ""
                        default: return " "
                        }
                    }
            }
            <<< PushRow<String>("subCatTag") {
                $0.hidden = Condition.function(["mainCatTag"], {form in
                    form.rowBy(tag: "subCatTag")?.updateCell()
                    return (form.rowBy(tag: "mainCatTag")?.value == "Alle Anzeigen")
                })
                $0.title = "Unterkategorie"
                $0.options = ["Alle Anzeigen"]
                $0.value = (FilterManager.shared.getFilter(withName: .subcategory) as? Termfilter)?.value ?? "Alle Anzeigen"
                $0.selectorTitle = "Unterkategorie"
                }.cellUpdate { cell, row in
                    row.value = (FilterManager.shared.getFilter(withName: .subcategory) as? Termfilter)?.value ?? "Alle Anzeigen"
                    cell.detailTextLabel?.text = row.value
                    guard let currentMainCatName = (FilterManager.shared.getFilter(withName: .category) as? Termfilter)?.value else {return}
                    guard let currentMainCatID = CategoryManager.shared.mainCategories.first(where: {$0.name == currentMainCatName})?.id else {return}
                    let subCats = CategoryManager.shared.subCategories.filter({$0.idParentCategory == currentMainCatID})
                    row.options = ["Alle Anzeigen"] + subCats.map({$0.name})
                }.onChange {
                    FilterManager.shared.removefilterWithName(.subcategory)
                    guard let value = $0.value else {return}
                    guard value != "Alle Anzeigen" else {return}
                    let filter = Termfilter(name: .subcategory, descriptiveString: "Unterkategorie", value: value)
                    FilterManager.shared.setfilter(newfilter: filter)
                }.onPresent { from, to in
                    self.applyCustomStyleOnSelectorVC(to)
                    to.enableDeselection = false
                    to.sectionKeyForValue = { option in
                        switch option {
                        case "Alle Anzeigen": return ""
                        default: return " "
                        }
                    }
            }
            
            +++ sectionForAdCar()
            +++ sectionForAdHouse()
    
            
            // Sorting
            +++ Section()
            <<< PushRow<String>() {
                $0.title = "Sortierung"
                $0.options = sortingOptions.map({$0.descriptiveString})
                $0.value = "Neuste zuerst"
                $0.selectorTitle = "Sortierung"
                }.onChange {
                    guard let value = $0.value else {return}
                    guard let sorting = sortingOptions.first(where: {$0.descriptiveString == value}) else {return}
                    FilterManager.shared.setfilter(newfilter: Sortfilter(criterium: sorting.criterium, order: sorting.order))
            }

            
            
            
            // Partnerportals
            +++ Section()
            <<< SwitchRow() {
                $0.title = "Partnerportale durchsuchen"
                $0.value = true
                }.onChange {
                    guard let value = $0.value else {return}
                    if value {
                        FilterManager.shared.removefilterWithName(.sourceId)
                    } else {
                        FilterManager.shared.setfilter(newfilter: Termfilter(name: .sourceId, descriptiveString: "Nur Local24 Anzeigen", value: "MPS"))
                    }
            }
    }

    
    
        
    
    
    func applyCustomStyleOnSelectorVC(_ to: SelectorViewController<String>) {
        to.selectableRowCellUpdate = {cell, row in
            cell.textLabel?.font = UIFont(name: "OpenSans", size: 17.0)
            to.tableView?.backgroundColor = local24grey
            to.tableView?.separatorColor = local24grey
        }
    }
    
    
    
    
    
    
    func arrayFrom(_ from: Int, to: Int, stepValue: Int) -> [Int]{
        var array = [Int]()
        for i in from..<(to/stepValue) {
            array.append(i*stepValue)
        }
        return array
    }

}
