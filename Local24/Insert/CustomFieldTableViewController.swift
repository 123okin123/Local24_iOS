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
    
    var independetField :(name: String, descriptiveString: String)! {get{
        switch entityType {
        case "AdCar": return ("Make", "Marke")
        case "AdApartment": return ("SellOrRent", "Verkauf oder Vermietung")
        case "AdHouse": return ("SellOrRent", "Verkauf oder Vermietung")
        default: return nil
        }
        }}
    var independentFieldOptions = [String]()
    

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = independetField.1
        let indicator = UIActivityIndicatorView(frame: view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, . flexibleHeight]
        indicator.color = UIColor.darkGray
        view.addSubview(indicator)
        indicator.startAnimating()
        let specialField = SpecialField(entityType: entityType, name: independetField.name)
        if let values = specialField.possibleStringValues {
            indicator.removeFromSuperview()
            independentFieldOptions = values
            tableView.reloadData()
        }        
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
        return independentFieldOptions.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let customField2VCID = storyboard.instantiateViewController(withIdentifier: "customField2VCID") as! CustomField2TableViewController
        customField2VCID.catID = catID
        customField2VCID.entityType = entityType
        customField2VCID.independetFieldValue = independentFieldOptions[indexPath.row]
        customField2VCID.independetField = independetField
        navigationController?.pushViewController(customField2VCID, animated: true)

    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customFieldChooseCellID", for: indexPath)
        cell.textLabel?.text = independentFieldOptions[indexPath.row]
        return cell
    }
    


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
