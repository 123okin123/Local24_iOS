//
//  filterSelectTableViewController.swift
//  Local24
//
//  Created by Local24 on 25/04/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class filterSelectTableViewController: UITableViewController {

    //MARK: Variables
    
    var selectType :SelectType!
    var options = [String]()
    
    enum SelectType {
        case sorting
        case categories
    }

    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch selectType! {
        case .categories:
            self.title = "Kategorien"
            for category in CategoryManager.shared.mainCategories {
                options.append(category.name)
            }
        case .sorting:
            self.title = "Sortierung"
            for value in sortingOptions {
                options.append(value.descriptiveString)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let title = self.title {
            trackScreen("Filter/\(title)")
        } else {
            trackScreen("Filter/NotSet")
        }
    }



    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        switch selectType! {
        case .categories:
            return 2
        case .sorting:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectType! {
        case .categories:
            if section == 1 {
            return options.count
            } else {
            return 1
            }
        case .sorting:
            return options.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var defaultCell = UITableViewCell()
        switch selectType! {
        case .categories:
            if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "morefilterOptionsCellID", for: indexPath)
                cell.textLabel?.text = options[indexPath.row]
                defaultCell = cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "nomorefilterOptionsCellID", for: indexPath)
                cell.textLabel?.text = "Alle Anzeigen"
                if options[indexPath.row] == FilterManager.shared.getValueOffilter(withName: .category, filterType: .term) {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
                defaultCell = cell
            }
        case .sorting:
            let cell = tableView.dequeueReusableCell(withIdentifier: "nomorefilterOptionsCellID", for: indexPath)
            cell.textLabel?.text = options[indexPath.row]
            
            if options[indexPath.row] == FilterManager.shared.getValueOffilter(withName: .sorting, filterType: .sort) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            defaultCell = cell
        }
        defaultCell.tag = indexPath.row

        return defaultCell
    }
    
    //MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filterVC = self.navigationController?.viewControllers[0] as! FilterViewController
        switch selectType! {
        case .categories:
            if indexPath.section == 0 {
                FilterManager.shared.removefilterWithName(name: .category)
                FilterManager.shared.removefilterWithName(name: .subcategory)
                filterVC.tableView.reloadData()
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
        case .sorting:
            let sorting = sortingOptions[indexPath.row]
                FilterManager.shared.setfilter(newfilter: Sortfilter(criterium: sorting.criterium, order: sorting.order))
                _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showfilterSubCatSegueID" {
            if let filterMoreSelect = segue.destination as? filterMoreSelectTableViewController {
                if let cell = sender as? UITableViewCell {
                    filterMoreSelect.mainCatID = CategoryManager.shared.mainCategories.first(where: {$0.name == cell.textLabel!.text!})!.id

                }
            
            }
        }
    }
    
    
    

}
