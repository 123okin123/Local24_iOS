//
//  MyAdsDetailViewController.swift
//  Local24
//
//  Created by Local24 on 03/03/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import MapKit
import MessageUI
import FBSDKShareKit
import Alamofire


class MyAdsDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fixedPriceCell: UIView!
        {didSet {
            fixedPriceCell.layer.borderColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1).cgColor
            fixedPriceCell.layer.borderWidth = 0.5
            fixedPriceCell.isHidden = true
        }}
    @IBOutlet weak var fixedPriceCellPriceLabel: UILabel!


    var images = [UIImage]() {didSet {
        if images.count == imgURLArray.count {
            activityIndi.stopAnimating()
            showImages()
            image1.isUserInteractionEnabled = true
            image2.isUserInteractionEnabled = true
            image3.isUserInteractionEnabled = true
        }
        }}
    
    var imgURLArray = [String]()
    
    
    var listing = Listing()

    var infos : [(name: String?, value: String?)] {
        var infos = [(name: String?, value: String?)]()
        infos.append(("Erstellt am",listing.createdDate))
        infos.append(("Aktuallisiert am",listing.updatedDate))
        if let specialFields = listing.specialFields {
            for specialField in specialFields {
                infos.append((specialField.descriptiveString, specialField.valueString))
                
            }
        }

        return infos
    }
    
    let activityIndi = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var image2BottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    
 
    @IBAction func mapViewPressed(_ sender: UITapGestureRecognizer) {
        let mapActionController = UIAlertController(title: "Anzeigen in", message: nil, preferredStyle: .actionSheet)
        let appleMapsAction = UIAlertAction(title: "Apple Karten", style: .default, handler: { UIAlertAction in
            
            guard let latitute:CLLocationDegrees =  self.listing.adLat else {return}
            guard let longitute:CLLocationDegrees =  self.listing.adLong else {return}
            
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            
            if let plz = self.listing.zipcode {
                if let stadt = self.listing.city {
                    mapItem.name = plz + " " + stadt
                }
            } else {
                mapItem.name = self.listing.title
            }
            mapItem.openInMaps(launchOptions: options)
        })
        let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default, handler: { UIAlertAction in
            
            
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.openURL(URL(string:
                    "comgooglemaps://?saddr=&daddr=\(self.listing.adLat),\(self.listing.adLong)&directionsmode=driving")!)
            }
        })
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
        
        
        mapActionController.addAction(appleMapsAction)
        mapActionController.addAction(googleMapsAction)
        mapActionController.addAction(cancelAction)
        self.present(mapActionController, animated: true) {}
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        title = listing.title
        getImagesURL()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //gaUserTracking("Profil/MyAdsDetail")
        navigationController?.hidesBarsOnSwipe = false
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("Profil/MyAdsDetail")
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let priceCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        if images.count > 0 {
            if tableView.contentOffset.y > 249 {
                priceCell?.contentView.isHidden = true
                fixedPriceCell.isHidden = false
            } else {
                priceCell?.contentView.isHidden = false
                fixedPriceCell.isHidden = true
            }
        } else {
            if tableView.contentOffset.y > 36 {
                priceCell?.contentView.isHidden = true
                fixedPriceCell.isHidden = false
            } else {
                priceCell?.contentView.isHidden = false
                fixedPriceCell.isHidden = true
            }
        }

        if tableView.contentOffset.y < 0 {
            
            image1.frame.size.height = 250 - tableView.contentOffset.y 
            image1.frame.origin.y = tableView.contentOffset.y
            
            switch images.count {
            case 2:
                image2.frame.size.height = 250 - tableView.contentOffset.y
                image2.frame.origin.y = tableView.contentOffset.y
            default:
                image2.frame.size.height = 125 + (-tableView.contentOffset.y)/2
                image2.frame.origin.y = tableView.contentOffset.y
                
                image3.frame.size.height = 125 + (-tableView.contentOffset.y)/2 + 0.25
                image3.frame.origin.y = image3.frame.size.height + tableView.contentOffset.y - 0.5
                
            }
            
            
        } else {
            image1.frame.size.height = 250
            switch images.count {
            case 2:
                image2.frame.size.height = 250
                image3.frame.size.height = 0
            default:
                image2.frame.size.height = 125
                image3.frame.size.height = 125
            }
            image1.frame.origin.y = 0
            image2.frame.origin.y = 0
            image3.frame.origin.y = 125
        }
        
    }
    

    
    
    func getImagesURL() {
        Alamofire.request("https://cfw-api-11.azurewebsites.net/public/ads/\(listing.adID!)/images/").responseJSON(completionHandler: { response in
            switch response.result {
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Fehler", message: "Local24 hat keine Verbindung zum Internet.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .success:
                if let json = response.result.value as? [[AnyHashable: Any]] {
                    if json.count > 0 {
                        for i in 0...json.count - 1 {
                            let url = json[i]["ImagePathLarge"] as! String
                            self.imgURLArray.append(url)
                        }
                        self.loadImages()
                    } else {
                        self.tableView.tableHeaderView?.frame.size.height = 0
                        self.tableView.reloadData()
                        
                    }
                }
            }
        })
        }
    
    
    func loadImages() {
        activityIndi.center = tableView.tableHeaderView!.center
        activityIndi.startAnimating()
        tableView.tableHeaderView!.addSubview(activityIndi)
        for i in 0...imgURLArray.count - 1 {
            var request = URLRequest(url: URL(string: imgURLArray[i])!)
            let session = URLSession.shared
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print(error!)
                } else {
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data!) {
                            self.images.append(image)
                            
                        }
                    }
                }
            })
            task.resume()
            
        }
        
    }
    
    
    func showImages() {
        switch images.count {
            
            
        case 1:
            image1.frame.size.width  = screenwidth
            image1.image = images[0]
        case 2:
            image2BottomConstraint.constant = 0
            image1.image = images[0]
            image2.image = images[1]
        default:
            image1.image = images[0]
            image2.image = images[1]
            image3.image = images[2]
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return nil
        case 1:
            if infos.count > 0 {
                return "Info"
            } else {
                return nil
            }
        case 2:
            return "Details"
        case 3:
            return "Ort"
        default:
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows = Int()
        switch section {
        case 0:
            numberOfRows = 2
        case 1:
            numberOfRows = infos.count
        case 2:
            numberOfRows = 1
        case 3:
            numberOfRows = 2
        default: break
        }
        return numberOfRows
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var defaultcell = UITableViewCell()
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "priceCellID") as! PriceTableViewCell!
                
                cell?.adPriceLabel.text = listing.priceWithCurrency
                fixedPriceCellPriceLabel.text = listing.priceWithCurrency
                
                defaultcell = cell!
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCellID") as! TitleTableViewCell!
                
                cell?.adTitleLabel.text = listing.title
                
                defaultcell = cell!
            default: break
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCellID") as UITableViewCell!
            cell?.textLabel?.text = infos[indexPath.row].name
            cell?.detailTextLabel?.text = infos[indexPath.row].value
            defaultcell = cell!
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "desriptionCellID") as! DescriptionTableViewCell!
            
            cell?.adDescriptionLabel.text = listing.adDescription
            
            defaultcell = cell!
        case 3:
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationMapCellID") as! LocationMapTableViewCell!
                if listing.adLat != nil && listing.adLong != nil {
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: listing.adLat!, longitude: listing.adLong!), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                cell?.mapView.setRegion(region, animated: false)
                }
                defaultcell = cell!
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationStringsCellID") as UITableViewCell!
                if let plz = listing.zipcode {
                    if let stadt = listing.city {
                        cell?.textLabel?.text = plz + " " + stadt
                    }
                }
                
                defaultcell = cell!
            default: break
            }
        default: break
        }
        
        
        return defaultcell
        
    }
    
    
  
    
    
    // MARK: - Navigation

    @IBAction func backfromDetailImage(_ segue:UIStoryboardSegue) {}


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "detailImageSegueID" {
            if let imgVC = segue.destination as? DetailImageViewController {
                let imageViewTapGestureRecognizer = sender as! UITapGestureRecognizer
                imgVC.touchedImageTag = imageViewTapGestureRecognizer.view!.tag
                imgVC.images = self.images
            }
        }
        if segue.identifier == "editAdSegueID" {
            if let editVC = segue.destination as? InsertTableViewController {
            editVC.listingExists = true
            editVC.listing = listing
            editVC.imageArray = images
            }
        }
  
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        return true
        
    }
    
    
    
}
