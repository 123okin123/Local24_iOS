//
//  MoreViewController.swift
//  Local24
//
//  Created by Locla24 on 26/11/15.
//  Copyright © 2015 Nikolai Kratz. All rights reserved.
//

import UIKit
import WebKit





class MoreTableViewController: UITableViewController {

    
    // MARK: Outlets & Variables
    
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buildString = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let versionBuildString = "Version: \(versionString) (\(buildString))"
        versionLabel.text = versionBuildString
        

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("More")
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows = Int()
        switch section {
        case 0:
            numberOfRows = 6
        case 1:
            numberOfRows = 1
        default: break
        }
        return numberOfRows
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.indexPathForSelectedRow as NSIndexPath?)?.section == 1 {
            if (tableView.indexPathForSelectedRow as NSIndexPath?)?.row == 0 {
                userToken = nil
                presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
   
   

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "showItem" {
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPath(for: cell)!
                if let dvc = segue.destination as? MoreViewController {
                        dvc.moreTag = (indexPath as NSIndexPath).row
                    print(dvc.moreTag)
                   
                }

            }
        }
        
                
    }
    

}





