//
//  LocationViewController.swift
//  Local24
//
//  Created by Locla24 on 02/02/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import MapKit


public var viewedRegion :MKCoordinateRegion?

class LocationViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, MKMapViewDelegate , UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var radiusLabel: UILabel!

    @IBOutlet weak var centerLocationButton: CenterLocationButton!
    @IBOutlet weak var radiusView: RadiusView!

    var resultsTableController: LocationResultsTableController!
    var searchController: UISearchController!
    


    
    @IBAction func centerLocationButton(_ sender: CenterLocationButton) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if mapView.showsUserLocation {
            let coordinate = mapView.userLocation.coordinate
                if coordinate.latitude != 0 &&  coordinate.longitude != 0 {
            mapView.setCenter(coordinate, animated: true)
                }
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            
        }
    }
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        resultsTableController = LocationResultsTableController()
        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.searchBarStyle = .minimal
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        configureSearchBar()

    }
    
    


    

    
    // MARK: - location manager to authorize user location for Maps app
    var locationManager = CLLocationManager()
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("SelectLocation")
        
        
        checkLocationAuthorizationStatus()
        if viewedRegion != nil {
        mapView.setRegion(viewedRegion!, animated: true)
        }
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func showRadiusInLabel() {
        let radiusPointY : CGFloat = mapView.bounds.size.height/2 - radiusView.bounds.height/2
                let radiusCoordinate = mapView.convert(CGPoint(x: mapView.bounds.size.width/2 , y: radiusPointY), toCoordinateFrom: self.mapView)
        let radiusLocation = CLLocation(latitude: radiusCoordinate.latitude, longitude: radiusCoordinate.longitude)
        let centerLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let radius = centerLocation.distance(from: radiusLocation)
        
        radiusLabel.text = "\(String(format: "%.0f", radius/1000)) km"

    
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations:{ () -> Void in
            self.radiusLabel.alpha = 0.5
            self.radiusView.alpha = 0.5
            }, completion: { (finished: Bool) -> Void in
                
                //self.radiusView.moves = true
                //self.radiusView.setNeedsDisplay()
        })
    

    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if round(mapView.centerCoordinate.latitude * 100) == round(mapView.userLocation.coordinate.latitude * 100) && round(mapView.centerCoordinate.longitude * 100) == round(mapView.userLocation.coordinate.longitude * 100) {
        centerLocationButton.isSelected = true
        } else {
        centerLocationButton.isSelected = false
        }
      
        
        
        let radiusPointY : CGFloat = mapView.bounds.size.height/2 - radiusView.bounds.height/2
        let radiusCoordinate = mapView.convert(CGPoint(x: mapView.bounds.size.width/2 , y: radiusPointY), toCoordinateFrom: self.mapView)
        let radiusLocation = CLLocation(latitude: radiusCoordinate.latitude, longitude: radiusCoordinate.longitude)
        let centerLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        let radius = centerLocation.distance(from: radiusLocation)
        
        
        
        let center2d = mapView.centerCoordinate
        let center3d = CLLocation(latitude: center2d.latitude, longitude: center2d.longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(center3d, completionHandler: {(placemarks, error) in
            if (error != nil) { print("reverse geodcode fail: \(error!.localizedDescription)")}
            else {
                let pm = placemarks! as [CLPlacemark]
                if pm.count > 0 {
                    guard let subAdminArea = pm[0].subAdministrativeArea else {return}
                    guard let zip = pm[0].postalCode else {return}
                    self.searchController.searchBar.text = subAdminArea
                    let lat = round(center2d.latitude*1000000)/1000000
                    let lon = round(center2d.longitude*1000000)/1000000
                    let radius = round(radius/1000)
                    
                    let geofilter = Geofilter(lat: lat, lon: lon, distance: radius, value: (zip + " " + subAdminArea + " (\(radius)km)"))
                    FilterManager.shared.setfilter(newfilter: geofilter)
                    viewedRegion = self.mapView.region
                }
            }
        })
        
        
        
        showRadiusInLabel()
        UIView.animate(withDuration: 0.3, delay: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations:{ () -> Void in
            self.radiusView.alpha = 1
            self.radiusLabel.alpha = 1
            
            }, completion: { (finished: Bool) -> Void in
                //self.radiusView.moves = false
                //self.radiusView.setNeedsDisplay()
        })
        
            
            
        
    }
    

    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    
    func configureSearchBar() {
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.setImage(UIImage(named: "lupe_gruen"), for: UISearchBarIcon.search, state: UIControlState())
        let searchTextField: UITextField? = searchController.searchBar.value(forKey: "searchField") as? UITextField
        if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
            let font = UIFont(name: "OpenSans", size: 13.0)
            let attributeDict = [
                NSFontAttributeName: font!,
                NSForegroundColorAttributeName: UIColor(red: 132/255, green: 168/255, blue: 77/255, alpha: 1)
            ]
            searchTextField!.attributedPlaceholder = NSAttributedString(string: "Nach einer Stadt oder PLZ suchen", attributes: attributeDict)
        }
        searchTextField?.textColor = UIColor.white
        let textField :UITextField? = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textField!.clearButtonMode = .never
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func updateSearchResults(for searchController: UISearchController) {

        var filteredResults = [
            ZipGeo(lat: 52.5234051, long: 13.4113999, zip: "", name: "Berlin"),
            ZipGeo(lat: 53.5496505, long: 9.99087729999999, zip: "", name: "Hamburg"),
            ZipGeo(lat: 48.139131, long: 11.5801882000001, zip: "", name: "München"),
            ZipGeo(lat: 50.940533, long: 6.9599054, zip: "", name: "Köln"),
            ZipGeo(lat: 48.7771056, long: 9.18076880000001, zip: "", name: "Stuttgart"),
            ZipGeo(lat: 50.110884, long: 8.67949219999998, zip: "", name: "Frankfurt am Main"),
            ZipGeo(lat: 49.45052, long: 11.08048, zip: "", name: "Nürnberg"),
            ZipGeo(lat: 51.2249429, long: 6.7756524, zip: "", name: "Düsseldorf"),
            ZipGeo(lat: 51.3396731, long: 12.3713639, zip: "", name: "Leipzig"),
            ZipGeo(lat: 51.5120542, long: 7.46357290000005, zip: "", name: "Dortmund"),
        ]
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(searchController.searchBar.text!, completionHandler: {
            (placemarks, error)->Void in
            if error == nil {
                if placemarks != nil {
                    var zipGeos = [ZipGeo]()
                for i in 0...placemarks!.count - 1 {
                    if let lat = placemarks![i].location?.coordinate.latitude {
                        if let long = placemarks![i].location?.coordinate.longitude {
                            if let zip = placemarks![i].country {
                                if let name = placemarks![i].name {
                                let zipGeo = ZipGeo(lat: lat, long: long, zip: zip, name: name)
                                zipGeos.append(zipGeo)

                            }
                            }
                        }
                    
                    }
                }
                filteredResults = zipGeos
                    
                }
            }
            let resultsController = searchController.searchResultsController as! LocationResultsTableController
            resultsController.filteredZipGeos = filteredResults
            resultsController.tableView.reloadData()
            resultsController.tableView.isHidden = false
        
        })

        
        

    }
    

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
