//
//  InsertTableViewDataSource.swift
//  Local24
//
//  Created by Local24 on 27/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit


//InsertTableViewDataSource

extension InsertTableViewController: InsertImageCellDelegate {

    
    
    func populateCustomFields() {
        if listing.entityType != nil {
            if listing.entityType != "AdPlain" {
                var customFieldNames = [(String, String)]()
                switch listing.entityType! {
                case "AdCar":
                    customFieldNames = [
                        ("Condition", "Zustand"),
                        ("BodyColor", "Außenfarbe"),
                        ("BodyForm", "Karosserieform"),
                        ("GearType", "Getriebeart"),
                        ("FuelType", "Kraftstoffart"),
                        ("InitialRegistration", "Erstzulassung"),
                        ("Mileage", "Kilometerstand in km"),
                        ("Power", "Leistung in PS")
                    ]
                case "AdApartment":
                    customFieldNames = [
                        ("Size", "Wohnfläche in m2"),
                        ("AvailableFrom", "Verfügbar ab"),
                        ("Commission", "Provision"),
                        ("CommissionAmount", "Provisionshöhe in €"),
                        ("AdditionalCosts", "Nebenkosten in €"),
                        ("DepositAmount", "Kaution in €"),
                        ("TotalRooms", "Anzahl Räume"),
                        ("ApartmentType", "Wohnungstyp"),
                        ("ConditionOfProperty", "Objektzustand")
                    ]
                default: break
                    
                }
                NetworkController.getOptionsFor(customFields: customFieldNames, entityType: listing.entityType!, completion: {(fields, error) in
                    if error == nil && fields != nil {
                        self.customFields = fields!
                    }
                    if self.customFields.count > 0 {
                        for i in 0...self.customFields.count - 1 {
                            self.customFieldCellCollection[i].textLabel?.text = self.customFields[i].descriptiveString
                            self.customFieldCellCollection[i].textField.placeholder = self.customFields[i].possibleValues?[0]
                        }
                    }
                    var indexPaths = [IndexPath]()
                    for i in 0...self.customFields.count - 1 {
                        let indexPath = IndexPath(row: i, section: 2)
                        indexPaths.append(indexPath)
                    }
                    self.tableView.reloadData()
                    
                })
                
            } else {
                self.customFields.removeAll()
                self.independentFieldLabel.text = ""
                self.dependentFieldLabel.text = ""
                self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
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
            return super.tableView(tableView, heightForRowAt: indexPath)
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
        if shouldHideSection(section) {
            let headerView = view as! UITableViewHeaderFooterView
            headerView.textLabel!.textColor = UIColor.clear
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if shouldHideSection(section) {
            let footerView = view as! UITableViewHeaderFooterView
            footerView.textLabel!.textColor = UIColor.clear
        }
    }
    
    
    func shouldHideSection(_ section: Int) -> Bool {
        switch section {
        case 2:
            return true
            // Work in Progress
//            if listing.entityType == "AdPlain" || listing.entityType == nil
//                {
//                return true
//            } else {
//                return false
//            }
        default: return false
        }
        
    }
    
    
    //  MARK: CellSubclassDelegate
    
    func buttonTapped(cell: InsertImageCollectionViewCell) {
        guard let indexPath = self.imageCollectionView.indexPath(for: cell) else {return}
        print("Button tapped on item \(indexPath.row)")
        
        // imageArray.remove(at: indexPath.row)
        // imageCollectionView.deleteItems(at: [indexPath])
    }


}
