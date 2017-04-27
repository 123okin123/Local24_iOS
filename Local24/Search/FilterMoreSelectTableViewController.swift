//
//  filterMoreSelectTableViewController.swift
//  Local24
//
//  Created by Local24 on 25/04/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class filterMoreSelectTableViewController: UITableViewController {

    var mainCatID : Int!
    var options = [String]()

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = CategoryManager.shared.mainCategories.first(where: {$0.id == mainCatID})?.name
        let subcategories = CategoryManager.shared.subCategories.filter({$0.idParentCategory == mainCatID})
        for subcategory in subcategories {
            options.append(subcategory.name)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let title = self.title {
            trackScreen("Filter/Kategorien/\(title)")
        } else {
            trackScreen("Filter/Kategorien/NotSet")
        }
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
        return 1
        }
        else {
        return options.count
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var defaultCell = UITableViewCell()
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "maincatfilterOptionsCellID", for: indexPath)
            let categoryName = CategoryManager.shared.mainCategories.first(where: {$0.id == mainCatID})!.name
            cell.textLabel?.text = "Alles in " + categoryName!
            if FilterManager.shared.getValueOffilter(withName: .category, filterType: .term) == categoryName &&
                FilterManager.shared.getValueOffilter(withName: .subcategory, filterType: .term) == nil {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
            defaultCell = cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "subcatfilterOptionsCellID", for: indexPath)
            cell.textLabel?.text = options[indexPath.row]
            if options[indexPath.row] == FilterManager.shared.getValueOffilter(withName: .subcategory, filterType: .term) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            defaultCell = cell
        }

            
     
        
        defaultCell.tag = (indexPath as NSIndexPath).row
        
        return defaultCell


    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = CategoryManager.shared.mainCategories.first(where: {$0.id == mainCatID})
        FilterManager.shared.setfilter(newfilter: Termfilter(name: .category, descriptiveString: "Kategorie", value: category!.name))
        switch indexPath.section {
        case 1:
            FilterManager.shared.setfilter(newfilter: Termfilter(name: .subcategory, descriptiveString: "Unterkategorie", value: options[indexPath.row]))
        case 0:
            FilterManager.shared.removefilterWithName(name: .subcategory)
        default: break;
        }
        let filterVC = self.navigationController?.viewControllers[0] as! FilterViewController1
        filterVC.tableView.reloadData()
        _ = self.navigationController?.popToRootViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
