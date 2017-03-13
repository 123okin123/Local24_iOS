//
//  SelectCategoryTableViewController.swift
//  Local24
//
//  Created by Local24 on 23/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class SelectCategoryTableViewController: UITableViewController {

    
    
    var mainCategories = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            mainCategories = CategoryManager.shared.mainCategories.filter {
                    $0.name != "Kontaktanzeigen" &&
                    $0.name != "Flirt & Abenteuer" &&
                    $0.name != "Job" &&
                    $0.adclass != "AdTruck" &&
                    $0.adclass != "AdCat" &&
                    $0.adclass != "AdCommune" &&
                    $0.adclass != "AdDating" &&
                    $0.adclass != "AdDog" &&
                    $0.adclass != "AdHorse" &&
                    $0.adclass != "AdJob" &&
                    $0.adclass != "AdMotorcycle" &&
                    $0.adclass != "AdOtherProperty"
                }
            mainCategories.sort(by: {$0.name! < $1.name!})
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("Insert/SelectMainCategory")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mainCategories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCategoryCellID", for: indexPath)
        cell.textLabel?.text = mainCategories[indexPath.row].name
        cell.tag = indexPath.row
        return cell
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SelectSubCategoryTableViewController {
            let cell = sender as! UITableViewCell
            destinationVC.parentCategoryID =  mainCategories[cell.tag].id
            destinationVC.parentCategoryName = mainCategories[cell.tag].name
        }
    }
    

}
