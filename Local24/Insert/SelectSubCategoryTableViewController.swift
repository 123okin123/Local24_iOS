//
//  SelectCategoryTableViewController.swift
//  Local24
//
//  Created by Local24 on 23/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class SelectSubCategoryTableViewController: UITableViewController {
    
    
    
    var subCategories = [Category]()
    var parentCategoryID :Int!
    var parentCategoryName :String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = parentCategoryName
        subCategories = CategoryManager.shared.subCategories.filter({
                $0.idParentCategory == parentCategoryID &&
                        $0.adclass != .AdTruck &&
                        $0.adclass != .AdCat &&
                        $0.adclass != .AdCommune &&
                        $0.adclass != .AdDating &&
                        $0.adclass != .AdDog &&
                        $0.adclass != .AdHorse &&
                        $0.adclass != .AdJob &&
                        $0.adclass != .AdMotorcycle &&
                        $0.adclass != .AdOtherProperty
                })
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // gaUserTracking("Insert/SelectSubCategory")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("Insert/SelectSubCategory")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return subCategories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subCategoryCellID", for: indexPath)
        cell.textLabel?.text = subCategories[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for vcs in navigationController!.viewControllers {
            if let insertVC = vcs as? InsertTableViewController {
                insertVC.listing.catID = subCategories[indexPath.row].id!
                insertVC.listing.entityType = subCategories[indexPath.row].adclass!
                insertVC.categoryLabel.text = subCategories[indexPath.row].name
                insertVC.categoryLabel.textColor = UIColor.black
                insertVC.populateCustomFields()
                
                if subCategories[indexPath.row].adclass != .AdPlain {
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let customFieldVCID = storyboard.instantiateViewController(withIdentifier: "customFieldVCID") as! CustomFieldTableViewController
                    customFieldVCID.catID = subCategories[indexPath.row].id!
                    customFieldVCID.entityType = subCategories[indexPath.row].adclass!
                    
                    navigationController?.pushViewController(customFieldVCID, animated: true)
                } else {

                _ = navigationController?.popToViewController(insertVC, animated: true)
                }
 
            }
        }

        
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
    

    
    
}
