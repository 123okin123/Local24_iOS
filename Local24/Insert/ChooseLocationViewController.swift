//
//  ChooseLocationViewController.swift
//  Local24
//
//  Created by Local24 on 12/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ChooseLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UINavigationControllerDelegate, MKMapViewDelegate {

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerView: UIView! {didSet {
        centerView.layer.cornerRadius = 25
        }}
    
    // MARK: - Variables
    
    var addresses = [CLPlacemark]()
    let geocoder = CLGeocoder()
    var locationManager = CLLocationManager()
    var selectedIndex :Int?
    var currentLocationPlacemark :CLPlacemark?
    var mapViewInitiallyCentered = false
    
    // MARK: - IBActions

    @IBAction func searchButtonPressed(_ sender: UIButton) {
        if let string = searchBar.text {
            searchForAddressString(string: string)
        }
    }
    
    
    // MARK: - ViewController LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        mapView.delegate = self
        navigationController?.delegate = self
        


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //gaUserTracking("Insert/ChooseLocation")
        checkLocationAuthorizationStatus()
        if let userPlacemark = user?.placemark {
            addresses.append(userPlacemark)
        }
        if currentLocationPlacemark != nil {
            addresses.append(currentLocationPlacemark!)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("Insert/ChooseLocation")
        if !(self.addresses.isEmpty) {
            if let location = self.addresses[0].location {
                self.centerMapViewOnCoordinate(coordinate: location.coordinate)
                self.selectedIndex = 0
                tableView.reloadData()
            }
        }
        
    }

    

    
    func configureSearchBar() {
        searchBar.delegate = self
        searchBar.setImage(UIImage(named: "lupe_grau"), for: UISearchBarIcon.search, state: UIControlState())
        let searchTextField: UITextField? = searchBar.value(forKey: "searchField") as? UITextField
        if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
            let font = UIFont(name: "OpenSans", size: 13.0)
            let attributeDict = [
                NSFontAttributeName: font!,
                NSForegroundColorAttributeName: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            ]
            searchTextField!.attributedPlaceholder = NSAttributedString(string: "Bitte gib deine Adresse ein", attributes: attributeDict)
        }
        searchTextField?.textColor = UIColor.gray
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
   
    }
    
    
    // MARK: - SearchBar

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
        activityIndicator.startAnimating()
            selectedIndex = nil
            let center = CLLocationCoordinate2D(latitude: 50.428453, longitude: 10.256778)
            let region = CLCircularRegion(center: center, radius: 600000, identifier: "searchRegion")
            geocoder.geocodeAddressString(string, in: region, completionHandler: {(placemarks, error) in
                self.activityIndicator.stopAnimating()
                if error == nil && placemarks != nil {
                    self.addresses.removeAll()
                    for placemark in placemarks! {
                        if placemark.addressDictionary?["City"] != nil {
                        if placemark.addressDictionary?["Thoroughfare"] != nil &&
                            placemark.addressDictionary?["SubThoroughfare"] != nil &&
                            placemark.postalCode != nil
                            {
                                self.addresses.append(placemark)
                                if !(self.addresses.isEmpty) {
                                    if let location = self.addresses[0].location {
                                        self.centerMapViewOnCoordinate(coordinate: location.coordinate)
                                    }
                                }
                        }
                        }
                    }
                    if let userPlacemark = user?.placemark {
                        self.addresses.append(userPlacemark)
                    }
                    if self.currentLocationPlacemark != nil {
                        self.addresses.append(self.currentLocationPlacemark!)
                    }

                    self.tableView.reloadData()
                }
            })
    }
    

    // MARK: - MapView
    
    func centerMapViewOnCoordinate(coordinate :CLLocationCoordinate2D) {
        let region = self.mapView.regionThatFits(MKCoordinateRegionMakeWithDistance(coordinate, 500, 500))
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let location = mapView.userLocation.location {
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if let placemark = placemarks?[0] {
                    if placemark.addressDictionary?["City"] != nil &&
                        placemark.addressDictionary?["Thoroughfare"] != nil &&
                        placemark.addressDictionary?["SubThoroughfare"] != nil &&
                        placemark.postalCode != nil {
                    self.currentLocationPlacemark = placemark
                    if  !self.mapViewInitiallyCentered && self.addresses.isEmpty {
                        if let location = self.currentLocationPlacemark?.location {
                            self.addresses.append(self.currentLocationPlacemark!)
                            self.centerMapViewOnCoordinate(coordinate: location.coordinate)
                            self.mapViewInitiallyCentered = true
                            self.tableView.reloadData()
                        }
                    }
                    }
                }
            })
        }
    }
    

    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapViewRegionDidChangeFromUserInteraction() {
        selectedIndex = nil
        geocoder.reverseGeocodeLocation(CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude), completionHandler: { (placemarks, error) in
            if error == nil && placemarks != nil {
                self.addresses.removeAll()
                for placemark in placemarks! {
                    if placemark.addressDictionary?["City"] != nil &&
                        placemark.addressDictionary?["Thoroughfare"] != nil &&
                        placemark.addressDictionary?["SubThoroughfare"] != nil &&
                        placemark.postalCode != nil {
                        
                            self.addresses.append(placemark)
                        
                    }
                }
                if !(self.addresses.isEmpty) {
                    if let location = self.addresses[0].location {
                        self.mapView.setCenter(location.coordinate, animated: true)
                    }
                }
                if let userPlacemark = user?.placemark {
                    self.addresses.append(userPlacemark)
                }
                if self.currentLocationPlacemark != nil {
                    self.addresses.append(self.currentLocationPlacemark!)
                }

                self.tableView.reloadData()
            }
        })
    }
    }
    
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == .began || recognizer.state == .ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    
    
    // MARK: - TableView DataSource

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
    
    // MARK: - TableView Delegate

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChooseLocationTableViewCell
        guard (cell.cityLabel != nil && cell.cityLabel.text != "") else {return}
        guard (cell.houseNumberLabel != nil && cell.houseNumberLabel.text != "") else {return}
        guard (cell.streetLabel != nil && cell.streetLabel.text != "") else {return}
        guard (cell.zipCodeLabel != nil && cell.zipCodeLabel.text != "") else {return}
        selectedIndex = indexPath.row
        if let selectedLocation = addresses[selectedIndex!].location {
            centerMapViewOnCoordinate(coordinate: selectedLocation.coordinate)
        }
        view.endEditing(true)
        tableView.reloadData()
    }

    // MARK: - Other Delegates
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
            
        }
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
