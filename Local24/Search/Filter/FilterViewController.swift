//
//  FilterViewController.swift
//  Local24
//
//  Created by Nikolai Kratz on 26.04.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAnalytics

class FilterViewController: FormViewController {


    @IBAction func removeAllFilters(_ sender: UIBarButtonItem) {
        FilterManager.shared.removeAllfilters()
        self.performSegue(withIdentifier: "backfromfilterSegueID", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TextRow.defaultCellUpdate = { cell, row in cell.textLabel?.font = UIFont(name: "OpenSans", size: 17.0) }
        SwitchRow.defaultCellUpdate = { cell, row in cell.switchControl?.onTintColor = greencolor }
        tableView?.backgroundColor = local24grey
        tableView?.separatorColor = local24grey
        navigationAccessoryView.tintColor = greencolor
        
        form
            // Search Query
            +++ Section()
            <<< TextRow(){
                $0.title = "Suchbegriff"
                $0.value = (FilterManager.shared.getFilter(withName: .search_string) as? Stringfilter)?.queryString
                $0.placeholder = "z.B. Fahrrad"
                }.cellUpdate { cell, row in
                    row.value = (FilterManager.shared.getFilter(withName: .search_string) as? Stringfilter)?.queryString
                }.onChange {
                    guard let value = $0.value else {
                        FilterManager.shared.removefilterWithName(.search_string)
                        return}
                    if value == "" {
                        FilterManager.shared.removefilterWithName(.search_string)
                    } else {
                        FilterManager.shared.setfilter(newfilter: Stringfilter(value: value))
                    }
                }.onCellSelection {cell, row in
                    guard let value = row.value else {return}
                    FIRAnalytics.logEvent(withName: kFIREventSearch, parameters: [
                        kFIRParameterSearchTerm: value as NSObject,
                        "screen": "filter" as NSObject
                        ])
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
                if let intGtePrice = (FilterManager.shared.getFilter(withName: .price) as? Rangefilter)?.gte {
                    $0.value = Double(intGtePrice)
                } else {$0.value = nil}
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
                }.cellUpdate { cell, row in
                    if let intGtePrice = (FilterManager.shared.getFilter(withName: .price) as? Rangefilter)?.gte {
                        row.value = Double(intGtePrice)
                    } else {row.value = nil}
                }.onChange {
                    guard let value = $0.value else {return}
                    guard value != 0 else {return}
                    let currentPriceRangeFilter = FilterManager.shared.getFilter(withName: .price) as? Rangefilter
                    let priceRangeFilter = Rangefilter(name: .price, descriptiveString: "Preis", gte: Int(value), lte: currentPriceRangeFilter?.lte, unit: "€")
                    FilterManager.shared.setfilter(newfilter: priceRangeFilter)

            }
            <<< DecimalRow(){
                $0.useFormatterDuringInput = true
                $0.title = "Preis bis"
                if let intLtePrice = (FilterManager.shared.getFilter(withName: .price) as? Rangefilter)?.lte {
                    $0.value = Double(intLtePrice)
                } else {$0.value = nil}
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
                }.cellUpdate {cell, row in
                    if let intLtePrice = (FilterManager.shared.getFilter(withName: .price) as? Rangefilter)?.lte {
                        row.value = Double(intLtePrice)
                    } else {row.value = nil}
                }.onChange {
                    guard let value = $0.value else {return}
                    guard value != 0 else {return}
                    let currentPriceRangeFilter = FilterManager.shared.getFilter(withName: .price) as? Rangefilter
                    let priceRangeFilter = Rangefilter(name: .price, descriptiveString: "Preis", gte: currentPriceRangeFilter?.gte, lte: Int(value), unit: "€")
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
                    FilterManager.shared.removeAllfilters()
                    _ = self.form.allRows.map({$0.updateCell(); $0.reload()})
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
                $0.value = (FilterManager.shared.getFilter(withName: .sorting) as? Sortfilter)?.value
                $0.selectorTitle = "Sortierung"
                }.cellUpdate {cell, row in
                row.value = (FilterManager.shared.getFilter(withName: .sorting) as? Sortfilter)?.value
                }.onChange {
                    guard let value = $0.value else {return}
                    guard let sorting = sortingOptions.first(where: {$0.descriptiveString == value}) else {return}
                    FilterManager.shared.setfilter(newfilter: Sortfilter(criterium: sorting.criterium, order: sorting.order))
                }.onPresent { from, to in
                    self.applyCustomStyleOnSelectorVC(to)
                    to.enableDeselection = false
            }

            
            
            
            // Partnerportals
            +++ Section()
            <<< SwitchRow() {
                $0.title = "Partnerportale durchsuchen"
                $0.value = (FilterManager.shared.getFilter(withName: .sourceId) as? Termfilter)?.value == "MPS" ? false : true
                }.onChange {
                    guard let value = $0.value else {return}
                    if value {
                        FilterManager.shared.removefilterWithName(.sourceId)
                    } else {
                        FilterManager.shared.setfilter(newfilter: Termfilter(name: .sourceId, descriptiveString: "Nur Local24 Anzeigen", value: "MPS"))
                    }
            }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("Filter")
    }
        
    
    
    func applyCustomStyleOnSelectorVC(_ to: SelectorViewController<String>) {
        to.selectableRowCellUpdate = {cell, row in
            cell.textLabel?.font = UIFont(name: "OpenSans", size: 17.0)
            cell.tintColor = greencolor
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
