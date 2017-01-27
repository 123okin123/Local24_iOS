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
    var mainCatID :Int!
    var mainCatName :String!
    var categories = Categories()
    var subCategories = [CategoryModel]()
    
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subCategories = categoryBuilder.subCategories.filter({$0.idParentCategory == mainCatID})
        mainCatName = categoryBuilder.mainCategories.first(where: {$0.id == mainCatID})?.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
            navigationItem.title = mainCatName
            gaUserTracking("Home/\(mainCatName)/ChooseSubCategory")
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
        case 1: n = subCategories.count
        default: break
        }
        return n
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subCatCellID", for: indexPath)
        switch (indexPath as NSIndexPath).section {
        case 0: cell.textLabel?.text = "Alles in" + mainCatName
        case 1: cell.textLabel?.text = subCategories[indexPath.row].name
        default: break
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        FilterManager.shared.removeAllfilters()
        let category = categoryBuilder.mainCategories.first(where: {$0.id == mainCatID})
        FilterManager.shared.setfilter(newfilter: Termfilter(name: .category, descriptiveString: "Kategorie", value: category!.name))
        
        if indexPath.section == 1 {
            let subcategory = categoryBuilder.subCategories.first(where: {$0.id == subCategories[indexPath.row].id!})
            FilterManager.shared.setfilter(newfilter: Termfilter(name: .subcategory, descriptiveString: "Unterkategorie", value: subcategory!.name))
        }        
        if let navVC = tabBarController?.childViewControllers[1] as? UINavigationController {
                tabBarController?.selectedViewController = navVC
                navVC.popToRootViewController(animated: true)
                _ = navigationController?.popToRootViewController(animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
    }
    

    
}
