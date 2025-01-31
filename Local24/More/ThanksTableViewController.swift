//
//  ThanksTableViewController.swift
//  Local24
//
//  Created by Local24 on 20/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class ThanksTableViewController: UITableViewController {

    
    
    let thanks = ["Alamofire",
                  "Bolts",
                  "Eureka",
                  "Facebook-iOS-SDK",
                  "ImagePicker",
                  "MapleBacon",
                  "MZFormSheetPresentationController",
                  "SwiftyJSON"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("More/ThanksOverview")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thanks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "thanksCellID", for: indexPath) as UITableViewCell
        cell.textLabel?.text = thanks[indexPath.row]
        cell.tag = indexPath.row
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            if let thanksVC = segue.destination as? ThanksViewController {
            thanksVC.title = cell.textLabel?.text
            thanksVC.textToShow = thanks[cell.tag]
            }
        }
    }
   

}
