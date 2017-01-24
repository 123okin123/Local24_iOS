//
//  FilterSelectTableViewController.swift
//  Local24
//
//  Created by Local24 on 25/04/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class FilterSelectTableViewController: UITableViewController {

    
    var filterTag :Int = 0
//    let categories = Categories()
//    var subCategoryID :Int?
//    var mainCategoryID :Int?
//    var sorting = Filter.Sorting.TimeAsc

    var options = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch filterTag {
        case 0:
            self.title = "Kategorien"
            for category in categoryBuilder.mainCategories {
                options.append(category.name)
            }
        case 1:
            self.title = "Sortierung"
        default: break
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("Filter/\(self.title)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        switch filterTag {
        case 0:
            return 2
        case 1:
            return 1
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch filterTag {
        case 0:
            if section == 1 {
            return categories.mainCatsStrings.count
            } else {
            return 1
            }
        case 1:
            return 7
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var defaultCell = UITableViewCell()
        switch filterTag {
        case 0:
            if (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "moreFilterOptionsCellID", for: indexPath)
                cell.textLabel?.text = categories.mainCatsStrings[(indexPath as NSIndexPath).row]
                defaultCell = cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "nomoreFilterOptionsCellID", for: indexPath)
                cell.textLabel?.text = "Alle Anzeigen"
                if mainCategoryID == nil {
                cell.accessoryType = .checkmark
                } else {
                cell.accessoryType = .none
                }
                defaultCell = cell
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "nomoreFilterOptionsCellID", for: indexPath)
        
            switch (indexPath as NSIndexPath).row {
            case 0: cell.textLabel?.text = "Relevanz"
            case 1: cell.textLabel?.text = "Datum aufsteigen"
            case 2: cell.textLabel?.text = "Datum absteigend"
            case 3: cell.textLabel?.text = "Preis aufsteigend"
            case 4: cell.textLabel?.text = "Preis absteigend"
            case 5: cell.textLabel?.text = "Entfernung aufsteigend"
            case 6: cell.textLabel?.text = "Entfernung absteigend"
            default: break
            }
            if cell.textLabel?.text == sorting.rawValue {
            cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            defaultCell = cell

        default: break
        }
        defaultCell.tag = (indexPath as NSIndexPath).row

        return defaultCell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filterVC = self.navigationController?.viewControllers[0] as! FilterViewController
        switch filterTag {
        case 0:
            if (indexPath as NSIndexPath).section == 0 {
            filterVC.filter.mainCategoryID = 99
            filterVC.filter.subCategoryID = 99
            filterVC.tableView.reloadData()
            _ = self.navigationController?.popToRootViewController(animated: true)
            }
        case 1:
            switch (indexPath as NSIndexPath).row {
            case 0: sorting = Filter.Sorting.Relevance
            case 1: sorting = Filter.Sorting.TimeAsc
            case 2: sorting = Filter.Sorting.TimeDesc
            case 3: sorting = Filter.Sorting.PriceAsc
            case 4: sorting = Filter.Sorting.PriceDesc
            case 5: sorting = Filter.Sorting.RangeAsc
            case 6: sorting = Filter.Sorting.RangeDesc
            default: break
            }
            filterVC.filter.sorting = sorting
            _ = self.navigationController?.popToRootViewController(animated: true)
        default: break
        
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilterSubCatSegueID" {
            if let filterMoreSelect = segue.destination as? FilterMoreSelectTableViewController {
                if let cell = sender as? UITableViewCell {
                filterMoreSelect.categoryTag = cell.tag

                }
            
            }
        }
    }
    
    
    

}
