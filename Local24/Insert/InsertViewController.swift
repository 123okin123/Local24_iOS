//
//  InsertViewController.swift
//  Local24
//
//  Created by Nikolai Kratz on 11.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAnalytics
import EquatableArray

class InsertViewController: FormViewController {

    var listingExists = false
    var listing = Listing()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if listingExists {
            navigationItem.setHidesBackButton(false, animated: false)
        } else {
            navigationItem.setHidesBackButton(true, animated: false)
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
        NetworkManager.shared.getUserProfile(userToken: userToken!, completion: {(fetchedUser, statusCode) in
            user = fetchedUser
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TextRow.defaultCellUpdate = { cell, row in cell.textLabel?.font = UIFont(name: "OpenSans", size: 17.0) }
        SwitchRow.defaultCellUpdate = { cell, row in cell.switchControl?.onTintColor = greencolor }
        tableView?.backgroundColor = local24grey
        tableView?.separatorColor = local24grey
        navigationAccessoryView.tintColor = greencolor
      
        
        form
            +++ Section()
            <<< ImageSelectorRow() {
                if let images = listing.images {
                $0.value = EquatableArray(images)
                }
            }
            +++ Section()
            <<< SegmentedRow<String>() {
                $0.options = ["Ich suche","Ich biete"]
                $0.value = "Ich suche"
            }
            <<< TextRow() {
                $0.placeholder = "Titel"
            }
            <<< MutiplePushRow<String>() {
                $0.title = "Kategorie"
            }
            +++ Section("Beschreibung")
            <<< TextAreaRow()
        
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Anzeige aufgeben"
            }
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
