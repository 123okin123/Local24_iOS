//
//  FilterViewController.swift
//  Local24
//
//  Created by Local24 on 10/03/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class FilterViewController: UITableViewController, UITextFieldDelegate {

    //MARK: IBOutlets
    
    @IBOutlet weak var searchQueryTextField: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var minPriceTextField: UITextField!
    @IBOutlet weak var maxPriceTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var sortingLabel: UILabel!
    @IBOutlet weak var onlyLocalListingsSwitch: UISwitch!
    @IBOutlet weak var sliderTableViewCell: UITableViewCell!
    @IBOutlet weak var rangeSlider: NMRangeSlider!
    @IBOutlet weak var rangeSliderLabel: UILabel!
    
    // MARK: Variables
    
    var upperValue = 500000
    var lowerValue = 0

    var sliderSectionHeaderString = ""
    var categories = Categories()
    var showCarfilters = false

    // MARK: IBActions
    
    @IBAction func onlyLocalListingsSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            FilterManager.shared.removefilterWithName(name: .sourceId)
        } else {
            FilterManager.shared.setfilter(newfilter: Termfilter(name: .sourceId, descriptiveString: "Nur Local24 Anzeigen", value: "MPS"))
        }
    }

    @IBAction func rangeSliderValueChanged(_ sender: NMRangeSlider) {
        if sliderSectionHeaderString == "Maximale Laufleistung" {
            upperValue = Int(round(sender.upperValue/1000)*1000)
            lowerValue = Int(round(sender.lowerValue/1000)*1000)
            
            let formater = NumberFormatter()
            formater.numberStyle = .decimal
            let lowerValueString = formater.string(from: NSNumber(value: lowerValue))
            let upperValueString = formater.string(from: NSNumber(value: upperValue))
            rangeSliderLabel.text = "von " + lowerValueString! + " km bis " + upperValueString! + " km"
            
            
        }
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchQueryTextField.delegate = self
        maxPriceTextField.delegate = self
        minPriceTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        if searchQueryTextField.text != "" {
        FIRAnalytics.logEvent(withName: kFIREventSearch, parameters: [
            kFIRParameterSearchTerm: searchQueryTextField.text! as NSObject,
            "screen": "filter" as NSObject
            ])
        }
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Search", action: "searchInfilter", label: searchQueryTextField.text!, value: 0).build() as NSDictionary as! [AnyHashable: Any])
//

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //gaUserTracking("Filter")
        loadfilters()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("Filter")
        
        rangeSlider.setUpperValue(Float(upperValue), animated: true)
        rangeSlider.setLowerValue(Float(lowerValue), animated: true)
        rangeSlider.minimumValue = 0
        rangeSlider.maximumValue = 500000
        rangeSlider.stepValue = 5000
    }
    
    
    func loadfilters() {
        searchQueryTextField.text = FilterManager.shared.getValueOffilter(withName: .search_string, filterType: .search_string)
        locationLabel.text = FilterManager.shared.getValueOffilter(withName: .geo_distance, filterType: .geo_distance)
        if let priceRange = FilterManager.shared.getValuesOfRangefilter(withName: .price) {
            if let lte =  priceRange.lte {
                maxPriceTextField.text = String(describing: Int(lte))
            }
            if let gte =  priceRange.gte {
                minPriceTextField.text = String(describing: Int(gte))
            }
        }
        if let category = FilterManager.shared.getValueOffilter(withName: .category, filterType: .term) {
            categoryLabel.text = category
        } else {
            categoryLabel.text = "Alle Anzeigen"
        }
        sortingLabel.text = FilterManager.shared.getValueOffilter(withName: .sorting, filterType: .sort)
        if let source = FilterManager.shared.getValueOffilter(withName: .sourceId, filterType: .term) {
            if source == "MPS" {
                onlyLocalListingsSwitch.setOn(false, animated: false)
            } else {
                onlyLocalListingsSwitch.setOn(true, animated: false)
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
                    let priceRange = Rangefilter(name: .price, descriptiveString: "Preis", gte: nil, lte: nil)
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
    
    func checkForAdditionalfilters() {
/*
        if filter.mainCategoryID == 0 && filter.subCategoryID == 1 {
            lowerValue = filter.minMileAge
            upperValue = filter.maxMileAge
            sliderSectionHeaderString = "Maximale Laufleistung"
            rangeSliderLabel.text = "von \(lowerValue) bis \(upperValue) km"
        
            rangeSlider.minimumValue = 0
            rangeSlider.maximumValue = 500000
            rangeSlider.stepValue = 5000

            showCarfilters = true
            
        } else {
            showCarfilters = false
        }
        tableView.reloadSections(IndexSet(integer: 4), with: .none)
 */
    }
    

    

    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 4:
            return sliderSectionHeaderString
        default:
            return nil
        }
        
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
            if showCarfilters { return false }
            else { return true }
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
 
