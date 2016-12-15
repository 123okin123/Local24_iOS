//
//  ChooseLocationViewController.swift
//  Local24
//
//  Created by Local24 on 12/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import MapKit

class ChooseLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var addresses = [CLPlacemark]()
    let geocoder = CLGeocoder()
    
    
    var selectedIndex :Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        navigationController?.delegate = self
        if let userPlacemark = user?.placemark {
        addresses.append(userPlacemark)
        selectedIndex = 0
        }
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
   
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.characters.count % 3) == 0 {
            searchForAddressString(string: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let string = searchBar.text {
            searchForAddressString(string: string)
        }
    }
    
    func searchForAddressString(string :String) {
            selectedIndex = nil
            let center = CLLocationCoordinate2D(latitude: 50.428453, longitude: 10.256778)
            let region = CLCircularRegion(center: center, radius: 600000, identifier: "searchRegion")
            geocoder.geocodeAddressString(string, in: region, completionHandler: {(placemarks, error) in
                if error == nil && placemarks != nil {
                    self.addresses.removeAll()
                    if let userPlacemark = user?.placemark {
                        self.addresses.append(userPlacemark)
                    }
                    for placemark in placemarks! {
                        if  placemark.addressDictionary?["City"] != nil &&
                            placemark.addressDictionary?["Thoroughfare"] != nil &&
                            placemark.addressDictionary?["SubThoroughfare"] != nil &&
                            placemark.postalCode != nil
                            {
                                self.addresses.append(placemark)
                        }
                    }
                    self.tableView.reloadData()
                }
            })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chooseLocationCellID", for: indexPath) as! ChooseLocationTableViewCell

            cell.cityLabel.text = addresses[indexPath.row].addressDictionary?["City"] as? String
            cell.streetLabel.text = addresses[indexPath.row].addressDictionary?["Thoroughfare"] as? String
            cell.houseNumberLabel.text = addresses[indexPath.row].addressDictionary?["SubThoroughfare"] as? String
            cell.zipCodeLabel.text = addresses[indexPath.row].postalCode
        
        if indexPath.row == selectedIndex {
        cell.accessoryType = .checkmark
        } else {
        cell.accessoryType = .none
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChooseLocationTableViewCell
        guard (cell.cityLabel != nil && cell.cityLabel.text != "") else {return}
        guard (cell.houseNumberLabel != nil && cell.houseNumberLabel.text != "") else {return}
        guard (cell.streetLabel != nil && cell.streetLabel.text != "") else {return}
        guard (cell.zipCodeLabel != nil && cell.zipCodeLabel.text != "") else {return}
        selectedIndex = indexPath.row
        view.endEditing(true)
        tableView.reloadData()
    }

    
    

    
    // MARK: - Navigation

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let insertVC = viewController as? InsertTableViewController {
            if selectedIndex != nil {
                let cell = tableView.cellForRow(at: IndexPath(row: selectedIndex!, section: 0)) as! ChooseLocationTableViewCell
                    insertVC.houseNumberLabel.text = cell.houseNumberLabel.text
                    insertVC.cityLabel.text = cell.cityLabel.text
                    insertVC.zipLabel.text = cell.zipCodeLabel.text
                    insertVC.streetLabel.text = cell.streetLabel.text
                if let location = addresses[selectedIndex!].location {
                    insertVC.listing.adLat = location.coordinate.latitude
                    insertVC.listing.adLong = location.coordinate.longitude
                }
                insertVC.zipLabel.textColor = UIColor.darkGray
                insertVC.cityLabel.textColor = UIColor.darkGray
                insertVC.houseNumberLabel.textColor = UIColor.darkGray
                insertVC.streetLabel.textColor = UIColor.darkGray
            }

        }
    }

    

}
