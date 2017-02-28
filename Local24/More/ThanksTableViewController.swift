//
//  ThanksTableViewController.swift
//  Local24
//
//  Created by Local24 on 20/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class ThanksTableViewController: UITableViewController {

    
    
    let thanks = ["Alamofire", "Bolts", "Facebook-iOS-SDK", "MapleBacon", "MZFormSheetPresentationController"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //gaUserTracking("More/ThanksOverview")
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            if let thanksVC = segue.destination as? ThanksViewController {
            thanksVC.title = cell.textLabel?.text
            thanksVC.textToShow = thanks[cell.tag]
            }
        }
    }
   

}
