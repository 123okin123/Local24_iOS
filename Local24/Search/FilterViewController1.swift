//
//  FilterViewController.swift
//  Local24
//
//  Created by Local24 on 10/03/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class FilterViewController1: UITableViewController, UITextFieldDelegate {

    //MARK: IBOutlets
    /*
    @IBOutlet weak var searchQueryTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var minPriceTextField: UITextField!
    @IBOutlet weak var maxPriceTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var sortingLabel: UILabel!
    @IBOutlet weak var onlyLocalListingsSwitch: UISwitch!

    
    @IBOutlet var specialRangeCells: [SpecialRangeCell]! {didSet {
        var i = 1
        for cell in specialRangeCells {
            cell.rangeSlider.tag = i
            //cell.rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
            i += 1
        }
    }}
*/
  

    // MARK: IBActions
    /*
    @IBAction func onlyLocalListingsSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            FilterManager.shared.removefilterWithName(name: .sourceId)
        } else {
            FilterManager.shared.setfilter(newfilter: Termfilter(name: .sourceId, descriptiveString: "Nur Local24 Anzeigen", value: "MPS"))
        }
    }
 */

//    func rangeSliderValueChanged(_ sender: NMRangeSlider) {
//        print("lower Value: \(sender.lowerValue)")
//        print("upper Value: \(sender.upperValue)")
//        let upperValue = Int(round(sender.upperValue/1000)*1000)
//        let lowerValue = Int(round(sender.lowerValue/1000)*1000)
//        print("tag: \(sender.tag)")
//        let formater = NumberFormatter()
//        formater.numberStyle = .decimal
//        guard let lowerValueString = formater.string(from: NSNumber(value: lowerValue)) else {return}
//        guard let upperValueString = formater.string(from: NSNumber(value: upperValue)) else {return}
//        
//        let rangeTag = sender.tag
//        guard let specialRangeCell = specialRangeCells.first(where: {$0.rangeSlider.tag == rangeTag}) else {return}
//        if let unit = specialRangeCell.unit {
//            specialRangeCell.upperRangeLabel.text = "bis " + upperValueString + " " + unit
//            specialRangeCell.lowerRangeLabel.text = "von " + lowerValueString + " " + unit
//        } else {
//            specialRangeCell.upperRangeLabel.text = "bis " + upperValueString
//            specialRangeCell.lowerRangeLabel.text = "von " + lowerValueString
//        }
//            }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
//        searchQueryTextField.delegate = self
//        maxPriceTextField.delegate = self
//        minPriceTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
       // saveFilters()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // loadFilters()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("Filter")
        
//        rangeSlider.setUpperValue(Float(upperValue), animated: true)
//        rangeSlider.setLowerValue(Float(lowerValue), animated: true)
//        rangeSlider.minimumValue = 0
//        rangeSlider.maximumValue = 500000
//        rangeSlider.stepValue = 5000
    }
    
    
    /*
    func loadFilters() {
        //SearchQuery
        searchQueryTextField.text = FilterManager.shared.getValueOffilter(withName: .search_string, filterType: .search_string)
        //Location
        locationLabel.text = FilterManager.shared.getValueOffilter(withName: .geo_distance, filterType: .geo_distance)
        //PriceRange
        if let priceRange = FilterManager.shared.getValuesOfRangefilter(withName: .price) {
            if let lte =  priceRange.lte {
                maxPriceTextField.text = String(describing: Int(lte))
            }
            if let gte =  priceRange.gte {
                minPriceTextField.text = String(describing: Int(gte))
            }
        }
        //Category
        if let category = FilterManager.shared.getValueOffilter(withName: .category, filterType: .term) {
            categoryLabel.text = category
        } else {
            categoryLabel.text = "Alle Anzeigen"
        }
        //Sorting
        sortingLabel.text = FilterManager.shared.getValueOffilter(withName: .sorting, filterType: .sort)
        //Source
        if let source = FilterManager.shared.getValueOffilter(withName: .sourceId, filterType: .term) {
            if source == "MPS" {
                onlyLocalListingsSwitch.setOn(false, animated: false)
            } else {
                onlyLocalListingsSwitch.setOn(true, animated: false)
            }
        }
        //SpecialFields Range
        if let subCat = FilterManager.shared.getCurrentSubCategory() {
            if SpecialFieldsManager.shared.entityTypHasSpecialFields(subCat.adclass, mustBeInSearchIndex: true, withType: .int) {
                loadAdditionalfilters()
            }
        }
        
        tableView.reloadData()
    }
    
    func loadAdditionalfilters() {
        guard let subCat = FilterManager.shared.getCurrentSubCategory() else {return}
        guard let specialFields = SpecialFieldsManager.shared.getSpecialFieldsFor(entityType: subCat.adclass, mustBeInSearchIndex: true, withType: .int) else {return}
        for i in 0...specialFields.count - 1 {
            let specialField = specialFields[i]
            let specialFieldCell = self.specialRangeCells[i]
            specialFieldCell.used = true
            specialFieldCell.descriptionLabel.text = specialField.descriptiveString
            specialFieldCell.rangeSlider.minimumValue = Float((specialField.possibleValues as! [Int]).first!)
            specialFieldCell.rangeSlider.maximumValue = Float((specialField.possibleValues as! [Int]).last!)
            specialFieldCell.rangeSlider.stepValue = Float((specialField.possibleValues as! [Int]).first!.advanced(by: 1) - (specialField.possibleValues as! [Int]).first!)
            specialFieldCell.unit = specialField.unit
            specialFieldCell.searchIndexName = specialField.searchIndexName

            
        }
    }
    
    func saveFilters() {
        if searchQueryTextField.text != "" {
            FIRAnalytics.logEvent(withName: kFIREventSearch, parameters: [
                kFIRParameterSearchTerm: searchQueryTextField.text! as NSObject,
                "screen": "filter" as NSObject
                ])
        }
        
        //        let tracker = GAI.sharedInstance().defaultTracker
        //        tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Search", action: "searchInfilter", label: searchQueryTextField.text!, value: 0).build() as NSDictionary as! [AnyHashable: Any])
        //
        
        FilterManager.shared.removeSpecialFilters()
        if let subCat = FilterManager.shared.getCurrentSubCategory() {
            if SpecialFieldsManager.shared.entityTypHasSpecialFields(subCat.adclass, mustBeInSearchIndex: true, withType: .int) {
                for specialRangeCell in specialRangeCells {
                    if let searchIndexName = specialRangeCell.searchIndexName {
                    let upperValue = Int(round(specialRangeCell.rangeSlider.upperValue/1000)*1000)
                    let lowerValue = Int(round(specialRangeCell.rangeSlider.lowerValue/1000)*1000)
                    if let filterName = filterName(rawValue: searchIndexName)  {
                        let filter = Rangefilter(name: filterName, descriptiveString: specialRangeCell.descriptionLabel.text!, gte: Double(lowerValue), lte: Double(upperValue), unit: specialRangeCell.unit)
                        filter.isSpecial = true
                        FilterManager.shared.setfilter(newfilter: filter)
                    }
                    }
                }
            }
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
            case searchQueryTextField:
                if searchQueryTextField.text != "" {
                    FilterManager.shared.setfilter(newfilter: Stringfilter(value: searchQueryTextField.text!))
                } else {
                    FilterManager.shared.removefilterWithName(name: .search_string)
            }
            case maxPriceTextField, minPriceTextField:
                if maxPriceTextField.text != "" || minPriceTextField.text != "" {
                    let priceRange = Rangefilter(name: .price, descriptiveString: "Preis", gte: nil, lte: nil, unit: "€")
                    if maxPriceTextField.text != "" {
                        priceRange.lte = Double(maxPriceTextField.text!)
                    }
                    if minPriceTextField.text != "" {
                        priceRange.gte = Double(minPriceTextField.text!)
                    }
                    FilterManager.shared.setfilter(newfilter: priceRange)
            }
        default: break
        }

    }
    

    */

    
   
    
    

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "filterInputCellID") else {return UITableViewCell()}
            cell.textLabel?.text = "Suchbegriff"
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "filterInputCellID") else {return UITableViewCell()}
            return cell
        case 2:
            switch indexPath.row {
            case 0:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "filterInputCellID") else {return UITableViewCell()}
                return cell
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "filterInputCellID") else {return UITableViewCell()}
                return cell
            default: return UITableViewCell()
            }
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "filterInputCellID") else {return UITableViewCell()}
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "filterInputCellID") else {return UITableViewCell()}
            return cell
        case 5:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "filterInputCellID") else {return UITableViewCell()}
            return cell
        case 6:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "filterInputCellID") else {return UITableViewCell()}
            return cell
        default: return UITableViewCell()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return 2
        case 3: return 1
        case 4:
            guard let subCat = FilterManager.shared.getCurrentSubCategory() else {return 0}
            return SpecialFieldsManager.shared.numberOfSecialFieldsFor(subCat.adclass, mustBeInSearchIndex: true, withType: .int)
        case 5: return 1
        case 6: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return nil
    }
  
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        return headerView
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if shouldHideSection((indexPath as NSIndexPath).section) {
        return 0.1
        } else {
        return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if shouldHideSection(section) {
            return 0.1
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if shouldHideSection(section) {
            return 0.1
        } else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
 
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if shouldHideSection(section) {
            let headerView = view as! UITableViewHeaderFooterView
            headerView.textLabel!.textColor = UIColor.clear
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if shouldHideSection(section) {
            let footerView = view as! UITableViewHeaderFooterView
            footerView.textLabel!.textColor = UIColor.clear
        }
    }

 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    



    // MARK: - Notifications
    

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.view.endEditing(true)
    }
    
    func shouldHideSection(_ section: Int) -> Bool {
        switch section {
        case 4:
            guard let subCat = FilterManager.shared.getCurrentSubCategory() else {return true}
            return SpecialFieldsManager.shared.numberOfSecialFieldsFor(subCat.adclass, mustBeInSearchIndex: true, withType: .int) == 0
        default: return false
        }

    }
    

 
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showfilterSelectVCSegueID" {
            if let filterSelectVC = segue.destination as? filterSelectTableViewController {
                if let cell = sender as? UITableViewCell {
                    switch cell.tag {
                    case 0: filterSelectVC.selectType = .categories
                    case 1: filterSelectVC.selectType = .sorting
                    default: break
                    }
                }
            }
        }
    }
  

}
 
