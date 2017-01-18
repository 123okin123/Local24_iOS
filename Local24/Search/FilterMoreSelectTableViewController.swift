//
//  FilterMoreSelectTableViewController.swift
//  Local24
//
//  Created by Local24 on 25/04/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class FilterMoreSelectTableViewController: UITableViewController {

    var categories = Categories()
    var filter = (UIApplication.shared.delegate as! AppDelegate).filter
    var categoryTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = categories.mainCatsStrings[categoryTag]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("Filter/Kategorien/\(self.title)/")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
        return 1
        }
        else {
        return categories.cats[categoryTag].count - 1
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var defaultCell = UITableViewCell()
        if (indexPath as NSIndexPath).section == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "maincatFilterOptionsCellID", for: indexPath)
            cell.textLabel?.text = categories.cats[categoryTag][0]
            if filter.mainCategoryID != 99 && filter.subCategoryID == 99 {
            if cell.textLabel?.text == categories.cats[filter.mainCategoryID][0] {
                cell.accessoryType = .checkmark
                }
            }
            else {
                cell.accessoryType = .none
            }
            
            defaultCell = cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "subcatFilterOptionsCellID", for: indexPath)
            cell.textLabel?.text = categories.cats[categoryTag][(indexPath as NSIndexPath).row + 1]
            if filter.subCategoryID != 99 {
            if cell.textLabel?.text == categories.cats[filter.mainCategoryID][filter.subCategoryID] {
            cell.accessoryType = .checkmark
            } else {
            cell.accessoryType = .none
            }
            }
            defaultCell = cell
        }

            
     
        
        defaultCell.tag = (indexPath as NSIndexPath).row
        
        return defaultCell


    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        filter.mainCategoryID = categoryTag
        switch (indexPath as NSIndexPath).section {
        case 1:
            filter.subCategoryID = (indexPath as NSIndexPath).row + 1
        case 0:
            filter.subCategoryID = 99
        default: break;
        }
        let filterVC = self.navigationController?.viewControllers[0] as! FilterViewController
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
