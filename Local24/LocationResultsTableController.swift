//
//  ResultsTableController.swift
//  Local24
//
//  Created by Locla24 on 02/02/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import MapKit

class LocationResultsTableController: UITableViewController {

   
    
    var filteredZipGeos = [ZipGeo]()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "pcellID")
        
        self.view = tableView
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var n = 0
        switch section {
        case 0: n = 1
        case 1: n = filteredZipGeos.count
        default: break
        }
        return n
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var n = ""
        if section == 1 {
        n = "Suchergebnisse"
        }
        return n
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.textColor = UIColor.lightGray
        header.textLabel!.font = UIFont(name: "OpenSans", size: 13)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if (indexPath as NSIndexPath).section == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pcellID", for: indexPath)
        cell.textLabel?.text = "Aktueller Ort"
        cell.imageView?.image = UIImage(named: "locationArrow_green")
        cell.imageView?.contentMode = .scaleAspectFit
        return cell
            
        } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        cell.textLabel?.text = filteredZipGeos[(indexPath as NSIndexPath).row].name
        return cell
        }

    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            if let lVC = self.presentingViewController as? LocationViewController {
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                    if lVC.mapView.isUserLocationVisible {
                    lVC.mapView.setRegion(MKCoordinateRegion(center: lVC.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)), animated: true)
                    presentingViewController?.dismiss(animated: true, completion: nil)
                    }
                } else {
                    let alertController = UIAlertController(title: "Kein Standort verfügbar", message: "Anscheinend gewähren Sie Local24 keinen Zugriff auf Ihren Standort. Dies können Sie in den Einstellungen ändern.", preferredStyle: .alert)
                    let oKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        alertController.dismiss(animated: true, completion: nil)
                    }
                    alertController.addAction(oKAction)
                    self.present(alertController, animated: true) {}
                }

            
            }
            tableView.deselectRow(at: indexPath, animated: true)
            
        } else {
        if let lVC = self.presentingViewController as? LocationViewController {
            
                let lat = filteredZipGeos[(indexPath as NSIndexPath).row].lat
            let long = filteredZipGeos[(indexPath as NSIndexPath).row].long
            let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
            var span = MKCoordinateSpan()
            switch filteredZipGeos[(indexPath as NSIndexPath).row].name {
            case "Deutschland":
                span = MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)
            case "Bayern":
                span = MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
            default: span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            }
            lVC.mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)
            lVC.searchController.searchBar.text = filteredZipGeos[(indexPath as NSIndexPath).row].name
  
            
                presentingViewController?.dismiss(animated: true, completion: nil)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        }
    }


    
    

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
