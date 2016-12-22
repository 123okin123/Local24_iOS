//
//  CustomFieldTableViewController.swift
//  Local24
//
//  Created by Local24 on 22/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class CustomFieldTableViewController: UITableViewController {

    var catID :Int!
    var entityType :String!
    var independetField :String! {get{
        switch entityType {
        case "AdCar": return "Make"
        default: return nil
        }
        }}
    var independetFieldVisibleString :String! {get{
        switch entityType {
        case "AdCar": return "Marke"
        default: return nil
        }
        }}
    var dependentField :String! {get{
        switch entityType {
        case "AdCar": return "Model"
        default: return nil
        }
        }}
    var customFieldOptions = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let indicator = UIActivityIndicatorView(frame: view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, . flexibleHeight]
        indicator.color = UIColor.darkGray
        view.addSubview(indicator)
        indicator.startAnimating()
        NetworkController.getOptionsFor(customFields: [(independetField, independetFieldVisibleString)], entityType: entityType, completion: {(fields ,error) in
            if error == nil && fields != nil {
                self.customFieldOptions = fields![0].1
                indicator.removeFromSuperview()
                self.tableView.reloadData()
            }
        })
        
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
        return customFieldOptions.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for vcs in navigationController!.viewControllers {
            if let insertVC = vcs as? InsertTableViewController {
                insertVC.independentFieldLabel.text = customFieldOptions[indexPath.row]
                _ = navigationController?.popToViewController(insertVC, animated: true)
            }
        }
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customFieldChooseCellID", for: indexPath)
        cell.textLabel?.text = customFieldOptions[indexPath.row]
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
