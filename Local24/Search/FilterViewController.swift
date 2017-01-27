//
//  filterViewController.swift
//  Local24
//
//  Created by Local24 on 10/03/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit


class filterViewController: UITableViewController {

    
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
    var upperValue = 500000
    var lowerValue = 0

    var sliderSectionHeaderString = ""
    
    var categories = Categories()
    
    var showCarfilters = false

    @IBAction func onlyLocalListingsSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
        //filter.onlyLocalListings = false
        } else {
        //filter.onlyLocalListings = true
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

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        savefilters()
//        let tracker = GAI.sharedInstance().defaultTracker
//        tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Search", action: "searchInfilter", label: searchQueryTextField.text!, value: 0).build() as NSDictionary as! [AnyHashable: Any])
//        


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("filter")
        loadfilters()
        
//        searchQueryTextField.text = filter.searchString
//        locationLabel.text = filter.searchLocationString
//        maxPriceTextField.text = filter.maxPrice
//        minPriceTextField.text = filter.minPrice
//        if filter.mainCategoryID == 99 && filter.subCategoryID == 99 {
//            categoryLabel.text  = "Alle Anzeigen"
//        } else {
//            if filter.subCategoryID != 99 {
//                categoryLabel.text = categories.cats[filter.mainCategoryID][filter.subCategoryID]
//            } else {
//                categoryLabel.text = categories.cats[filter.mainCategoryID][0]
//            }
//        }
//        sortingLabel.text = filter.sorting.rawValue
//        if filter.onlyLocalListings {
//        onlyLocalListingsSwitch.isOn = false
//        } else {
//        onlyLocalListingsSwitch.isOn = true
//        }
//      
//        checkForAdditionalfilters()
        
        

    }
    
    func savefilters() {
        if searchQueryTextField.text != "" {
            FilterManager.shared.setfilter(newfilter: Stringfilter(value: searchQueryTextField.text!))
        }
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
    }
    
    func loadfilters() {
        searchQueryTextField.text = FilterManager.shared.getValueOffilter(withName: .search_string, filterType: .search_string)
        if let priceRange = FilterManager.shared.getValuesOfRangefilter(withName: .price) {
            maxPriceTextField.text = String(describing: priceRange.lte)
            minPriceTextField.text = String(describing: priceRange.gte)
        }
        categoryLabel.text = FilterManager.shared.getValueOffilter(withName: .category, filterType: .term)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       rangeSlider.setUpperValue(Float(upperValue), animated: true)
        rangeSlider.setLowerValue(Float(lowerValue), animated: true)
        rangeSlider.minimumValue = 0
        rangeSlider.maximumValue = 500000
        rangeSlider.stepValue = 5000
        


    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source
    
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
 
