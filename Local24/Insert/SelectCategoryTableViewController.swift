//
//  SelectCategoryTableViewController.swift
//  Local24
//
//  Created by Local24 on 23/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class SelectCategoryTableViewController: UITableViewController {

    
    
    var mainCategories = [CategoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if categoryBuilder.mainCategories.isEmpty {
            let indicator = UIActivityIndicatorView(frame: view.bounds)
            indicator.autoresizingMask = [.flexibleWidth, . flexibleHeight]
            indicator.color = UIColor.darkGray
            view.addSubview(indicator)
            indicator.startAnimating()
            categoryBuilder.getCategories(completion: { (mainCat, subCat, error) in
                self.mainCategories = categoryBuilder.mainCategories.filter {
                        $0.name != "Immobilien" &&
                        $0.name != "Kontaktanzeigen" &&
                        $0.name != "Flirt & Abenteuer" &&
                        $0.name != "Job" &&
                        $0.adclass != "AdTruck" &&
                        $0.adclass != "AdApartment" &&
                        $0.adclass != "AdCat" &&
                        $0.adclass != "AdCommune" &&
                        $0.adclass != "AdDating" &&
                        $0.adclass != "AdDog" &&
                        $0.adclass != "AdHorse" &&
                        $0.adclass != "AdHouse" &&
                        $0.adclass != "AdJob" &&
                        $0.adclass != "AdMotorcycle" &&
                        $0.adclass != "AdOtherProperty"
                }

                indicator.removeFromSuperview()
                self.tableView.reloadData()
            })
        } else {
            mainCategories = categoryBuilder.mainCategories.filter {
                    $0.name != "Immobilien" &&
                    $0.name != "Kontaktanzeigen" &&
                    $0.name != "Flirt & Abenteuer" &&
                    $0.name != "Job" &&
                    $0.adclass != "AdTruck" &&
                    $0.adclass != "AdCat" &&
                    $0.adclass != "AdApartment" &&
                    $0.adclass != "AdCommune" &&
                    $0.adclass != "AdDating" &&
                    $0.adclass != "AdDog" &&
                    $0.adclass != "AdHorse" &&
                    $0.adclass != "AdHouse" &&
                    $0.adclass != "AdJob" &&
                    $0.adclass != "AdMotorcycle" &&
                    $0.adclass != "AdOtherProperty"
                }
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("Insert/SelectMainCategory")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SelectSubCategoryTableViewController {
            let cell = sender as! UITableViewCell
            destinationVC.parentCategoryID =  mainCategories[cell.tag].id
        }
    }
    

}
