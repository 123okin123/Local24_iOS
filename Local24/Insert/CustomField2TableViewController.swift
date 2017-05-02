//
//  CustomField2TableViewController.swift
//  Local24
//
//  Created by Local24 on 28/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class CustomField2TableViewController: UITableViewController {

    
    var catID :Int!
    var entityType :AdClass!
    var independetField :(name: String, descriptiveString: String)!
    var independetFieldValue :String!
    

    var dependentField :(name: String, descriptiveString: String)! {get{
        switch entityType! {
        case .AdCar: return ("Model", "Model")
        case .AdApartment: return ("PriceTypeProperty", "Preisart")
        case .AdHouse: return ("PriceTypeProperty", "Preisart")
        default: return nil
        }
        }}
    var dependentFieldOptions = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = independetFieldValue
        let indicator = UIActivityIndicatorView(frame: view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, . flexibleHeight]
        indicator.color = UIColor.darkGray
        view.addSubview(indicator)
        indicator.startAnimating()
        NetworkManager.shared.getValuesForDepending(field: dependentField.0, independendField: independetField.0, value: independetFieldValue, entityType: entityType, completion: {(values, error)in
            if error == nil && values != nil {
                self.dependentFieldOptions = values!
                self.dependentFieldOptions.remove(at: 0)
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
        return dependentFieldOptions.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for vcs in navigationController!.viewControllers {
            if let insertVC = vcs as? InsertTableViewController {
                insertVC.listing.specialFields?.append(SpecialField(name: independetField.name, descriptiveString: independetField.descriptiveString, type: .string, value: independetFieldValue))
                insertVC.listing.specialFields?.append(SpecialField(name: dependentField.name, descriptiveString: dependentField.descriptiveString, type: .string, value: dependentFieldOptions[indexPath.row]))
                insertVC.independentFieldLabel.text = independetFieldValue
                insertVC.dependentFieldLabel.text = dependentFieldOptions[indexPath.row]
                insertVC.populateCustomFields()
                for cell in insertVC.customFieldCellCollection {
                cell.textField.text = ""
                }
                _ = navigationController?.popToViewController(insertVC, animated: true)
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customField2ChooseCellID", for: indexPath)
        cell.textLabel?.text = dependentFieldOptions[indexPath.row]
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
