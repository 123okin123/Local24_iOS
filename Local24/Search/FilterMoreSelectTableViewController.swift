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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = categoryBuilder.mainCategories.first(where: {$0.id == mainCatID})?.name
        let subcategories = categoryBuilder.subCategories.filter({$0.idParentCategory == mainCatID})
        for subcategory in subcategories {
            options.append(subcategory.name)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("filter/Kategorien/\(self.title)/")
    }
    
    // MARK: - Table view data source

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
            cell.textLabel?.text = "Alles in " + categoryBuilder.mainCategories.first(where: {$0.id == mainCatID})!.name
            
           // if filter.mainCategoryID != 99 && filter.subCategoryID == 99 {
//            if cell.textLabel?.text == categories.cats[filter.mainCategoryID][0] {
//                cell.accessoryType = .checkmark
//                }
//            }
//            else {
//                cell.accessoryType = .none
//            }
            
            defaultCell = cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "subcatfilterOptionsCellID", for: indexPath)
            cell.textLabel?.text = options[indexPath.row]
//            if filter.subCategoryID != 99 {
//            if cell.textLabel?.text == categories.cats[filter.mainCategoryID][filter.subCategoryID] {
//            cell.accessoryType = .checkmark
//            } else {
//            cell.accessoryType = .none
//            }
//            }
            defaultCell = cell
        }

            
     
        
        defaultCell.tag = (indexPath as NSIndexPath).row
        
        return defaultCell


    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categoryBuilder.mainCategories.first(where: {$0.id == mainCatID})
        FilterManager.shared.setfilter(newfilter: Termfilter(name: .category, descriptiveString: "Kategorie", value: category!.name))
        switch indexPath.section {
        case 1:
            FilterManager.shared.setfilter(newfilter: Termfilter(name: .subcategory, descriptiveString: "Unterkategorie", value: options[indexPath.row]))
        case 0:
            FilterManager.shared.removefilterWithName(name: .subcategory)
        default: break;
        }
        let filterVC = self.navigationController?.viewControllers[0] as! filterViewController
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
