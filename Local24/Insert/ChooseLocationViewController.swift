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
import Eureka

class ChooseLocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UINavigationControllerDelegate, MKMapViewDelegate, TypedRowControllerType {

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerView: UIView! {didSet {
        centerView.layer.cornerRadius = 25
        }}
    
    // MARK: - Variables
    
    /// Array of possible addresses based on user location, searchField and saved location
    var addresses = [CLPlacemark]()
    /// The row that pushed or presented this controller. Is of type RowOf<Bool>, where Bool represents the changed placemark.
    var row: RowOf<Bool>!
    /// A closure to be called when the controller disappears.
    var onDismissCallback : ((UIViewController) -> ())?
    /// currently set placemark for listing
    var currentLocationPlacemark :CLPlacemark?
    
    private var mapViewInitiallyCentered = false
    private let geocoder = CLGeocoder()
    private var locationManager = CLLocationManager()
    
    

    
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
        checkLocationAuthorizationStatus()
        
        if let userPlacemark = user?.placemark {
            addresses.append(userPlacemark)
        }
        if currentLocationPlacemark != nil {
            addresses.append(currentLocationPlacemark!)
        }
        if !(self.addresses.isEmpty) {
            if let location = self.addresses[0].location {
                self.centerMapViewOnCoordinate(coordinate: location.coordinate)
                currentLocationPlacemark = self.addresses[0]
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("Insert/ChooseLocation")
        
        
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
        let center = CLLocationCoordinate2D(latitude: 50.428453, longitude: 10.256778)
        let region = CLCircularRegion(center: center, radius: 600000, identifier: "searchRegion")
        geocoder.geocodeAddressString(string, in: region, completionHandler: {(placemarks, error) in
            self.activityIndicator.stopAnimating()
            if error == nil && placemarks != nil {
                self.updateAddressesWhith(placemarks!)
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
                if error == nil && placemarks != nil {
                    if !self.addresses.contains(placemarks![0]) {
                        self.updateAddressesWhith(placemarks!)
                    }
                    
                }
            })
        }
    }
    

    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapViewRegionDidChangeFromUserInteraction() {
            activityIndicator.startAnimating()
            geocoder.reverseGeocodeLocation(CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude), completionHandler: { (placemarks, error) in
                self.activityIndicator.stopAnimating()
                if error == nil && placemarks != nil {
                    self.updateAddressesWhith(placemarks!)
                }
            })
    }
    }
    
    func updateAddressesWhith(_ newAddresses: [CLPlacemark]) {
        addresses = newAddresses.filter {placemark in
            if  placemark.addressDictionary?["City"] != nil &&
                placemark.addressDictionary?["Thoroughfare"] != nil &&
                placemark.addressDictionary?["SubThoroughfare"] != nil &&
                placemark.postalCode != nil {
                return true
            } else {
                return false
            }
            
        }
        currentLocationPlacemark = nil
        if let userPlacemark = user?.placemark {
            addresses.append(userPlacemark)
        }
        if !(addresses.isEmpty) {
            if let location = self.addresses[0].location {
                mapView.setCenter(location.coordinate, animated: true)
            }
        }
        tableView.reloadData()
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
        if currentLocationPlacemark != nil {
            let index = addresses.index(of: currentLocationPlacemark!)
            if indexPath.row == index {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {cell.accessoryType = .none}
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
        
        currentLocationPlacemark = addresses[indexPath.row]
        if let location = currentLocationPlacemark?.location {
            centerMapViewOnCoordinate(coordinate: location.coordinate)
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
        onDismissCallback!(self)
    }

    

}
