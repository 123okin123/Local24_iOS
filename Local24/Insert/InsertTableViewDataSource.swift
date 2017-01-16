//
//  InsertTableViewDataSource.swift
//  Local24
//
//  Created by Local24 on 27/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import SwiftyJSON

//InsertTableViewDataSource

extension InsertTableViewController: InsertImageCellDelegate {

    
    
    func populateCustomFields() {
        self.customFields.removeAll()
        if let path = Bundle.main.path(forResource: "specialFields", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json = JSON(data: data)
                if json != JSON.null {
                    
                    guard let entityType = listing.entityType else {return}
                    
                    if let fields = json[entityType].dictionary {
                        for field in fields {
                            let specialField = SpecialField(entityType: entityType, name: field.key)
                            if !specialField.hasDependentField {
                                self.customFields.append(specialField)
                            }
                            
                            
                            
                            if entityType == "AdApartment" && self.independentFieldLabel.text == "Verkauf"{
                                if let index = self.customFields.index(where: {$0.name == "AdditionalCosts"}) {self.customFields.remove(at: index)}
                                if let index = self.customFields.index(where: {$0.name == "DepositAmount"}) {self.customFields.remove(at: index)}
                            }
                            if entityType == "AdHouse" && self.independentFieldLabel.text == "Verkauf"{
                                if let index = self.customFields.index(where: {$0.name == "AdditionalCosts"}) {self.customFields.remove(at: index)}
                                if let index = self.customFields.index(where: {$0.name == "DepositAmount"}) {self.customFields.remove(at: index)}
                            }
                        }
                        if self.customFields.count > 0 {
                            for i in 0...self.customFields.count - 1 {
                                self.customFieldCellCollection[i].textLabel?.text = self.customFields[i].descriptiveString
                                self.customFieldCellCollection[i].textField.placeholder = self.customFields[i].possibleStringValues?[0]
                            }
                        }
                        self.tableView.reloadData()
                    } else {
                        print("entitytype not in json")
                        self.customFields.removeAll()
                        self.independentFieldLabel.text = ""
                        self.dependentFieldLabel.text = ""
                        self.tableView.reloadData()
                    }
                } else {
                    print("Could not get json from file, make sure that file contains valid json.")
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return customFields.count
        case 3: return 1
        case 4: return 3
        case 5: return 1
        case 6: return 1
        default: return 0
        }
    }
      
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if shouldHideSection((indexPath as NSIndexPath).section) {
            return 0
        } else {
            if shouldHideCell(atIndexPath: indexPath) {
                return 0
            } else {
                return super.tableView(tableView, heightForRowAt: indexPath)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if shouldHideSection(section) {
            return 0.1
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if shouldHideSection(section) {
            return 0.1
        } else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        if shouldHideSection(section) {
            headerView.textLabel!.textColor = UIColor.clear
        } else {
            headerView.textLabel!.textColor = UIColor.darkGray
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footerView = view as! UITableViewHeaderFooterView
        if shouldHideSection(section) {
            footerView.textLabel!.textColor = UIColor.clear
        } else {
            footerView.textLabel!.textColor = UIColor.darkGray
        }
    }
    
    
    func shouldHideSection(_ section: Int) -> Bool {
        switch section {
        case 2: 
            if listing.entityType == "AdPlain" || listing.entityType == nil {
                return true
            } else {
                return false
            }
    

        default: return false
        }
    }
    func shouldHideCell(atIndexPath indexPath: IndexPath) -> Bool {
        if indexPath == IndexPath(row: 1, section: 4) {
            if listing.entityType == "AdApartment" || listing.entityType == "AdHouse" {
            return true
            } else {return false}
        } else {return false}
    }
    
    
    //  MARK: CellSubclassDelegate
    
    func buttonTapped(cell: InsertImageCollectionViewCell) {
        guard let indexPath = self.imageCollectionView.indexPath(for: cell) else {return}
        print("Button tapped on item \(indexPath.row)")
        
        // imageArray.remove(at: indexPath.row)
        // imageCollectionView.deleteItems(at: [indexPath])
    }


}
