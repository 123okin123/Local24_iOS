//
//  NewCatTableViewController.swift
//  Local24
//
//  Created by Locla24 on 27/01/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class NewCatTableViewController: UITableViewController {
    
    // MARK: Outlets & Variables
    var mainCatTag = 0
    var categories = Categories()
    
    let filter = (UIApplication.shared.delegate as! AppDelegate).filter
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gaUserTracking("HomeChooseSubCategoryInMainCategory=\(categories.mainCatsStrings[mainCatTag])")
        navigationItem.title = categories.mainCatsStrings[mainCatTag]
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var n = 0
        switch section {
        case 0: n = 1
        case 1: n = categories.cats[mainCatTag].count - 1
        default: break
        }
        return n
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subCatCellID", for: indexPath)
        let subcat = categories.cats[mainCatTag]
        switch (indexPath as NSIndexPath).section {
        case 0: cell.textLabel?.text = subcat[0]
        case 1: cell.textLabel?.text = subcat[(indexPath as NSIndexPath).row + 1]
        default: break
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filter.resetAllFilters()
        filter.mainCategoryID = mainCatTag
        if (indexPath as NSIndexPath).section == 1 {
        filter.subCategoryID = (indexPath as NSIndexPath).row + 1
        }        
        if let navVC = tabBarController?.childViewControllers[1] as? UINavigationController {
           
                tabBarController?.selectedViewController = navVC
                navVC.popToRootViewController(animated: true)
                navigationController?.popToRootViewController(animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
    }
    

    
}
