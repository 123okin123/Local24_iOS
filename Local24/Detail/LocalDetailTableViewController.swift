//
//  LocalDetailTableViewController.swift
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
import MapleBacon
import SafariServices

class LocalDetailTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fixedPriceCell: UIView!
        {didSet {
            fixedPriceCell.layer.borderColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1).cgColor
            fixedPriceCell.layer.borderWidth = 0.5
            fixedPriceCell.isHidden = true
        }}
    
    @IBOutlet weak var fixedPriceCellPriceContactButton: UIButton!
        {didSet {
            fixedPriceCellPriceContactButton.tintColor = UIColor.white
            fixedPriceCellPriceContactButton.layer.cornerRadius = 10
            if let source = listing?.source {
                switch source {
                case "AS","ASBikes":
                    fixedPriceCellPriceContactButton.setTitle(" Ansehen", for: .normal)
                    fixedPriceCellPriceContactButton.setImage(UIImage(named: "AS24"), for: .normal)
                case "IS":
                    fixedPriceCellPriceContactButton.setTitle(" Ansehen", for: .normal)
                    fixedPriceCellPriceContactButton.setImage(UIImage(named: "IS24"), for: .normal)
                case "Quo":
                    fixedPriceCellPriceContactButton.setTitle("Auf Quoka ansehen", for: .normal)
                case "Germanpersonnel":
                    fixedPriceCellPriceContactButton.setTitle("Auf Germanpersonnel ansehen", for: .normal)
                case "Adzuna":
                    fixedPriceCellPriceContactButton.setTitle("Auf Adzuna ansehen", for: .normal)
                case "KAL":
                    fixedPriceCellPriceContactButton.setTitle("Auf Kalaydo ansehen", for: .normal)
                case "MPS":
                    fixedPriceCellPriceContactButton.setTitle("Nachricht", for: .normal)
                default:
                    fixedPriceCellPriceContactButton.setTitle("Auf Partnerportal ansehen", for: .normal)
                }
            }
        }}
    @IBOutlet weak var fixedPriceCellPriceLabel: UILabel!
    @IBOutlet weak var fixedPriceCellPhoneButton: UIButton!
        {didSet {
            fixedPriceCellPhoneButton.layer.cornerRadius = 10
            if listing.phoneNumber == nil {
            fixedPriceCellPhoneButton.isHidden = true
            } else {
            fixedPriceCellPhoneButton.isHidden = false
            }
        }}
    
    var listing :Listing!
    
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
    
    
    var images = [UIImage]() {didSet {
            image1.isUserInteractionEnabled = true
            image2.isUserInteractionEnabled = true
            image3.isUserInteractionEnabled = true
        }}
    

    let activityIndi = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var image2BottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image1widthConstraint: NSLayoutConstraint!

    
    
    
    @IBAction func actionButtonPressed(_ sender: UIBarButtonItem) {
        
        let actionActionController = UIAlertController(title: "Was möchten Sie tun?", message: nil, preferredStyle: .actionSheet)
        
        let abuseAction = UIAlertAction(title: "Anzeige melden", style: .destructive, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "showAbuseReportSegueID", sender: self)
        })
        
        let shareAction = UIAlertAction(title: "Anzeige teilen", style: .default, handler: {_  in
            if let url = self.listing.url {
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
    
        
        actionActionController.addAction(shareAction)
        if let source = listing.source {
            if source == "MPS" {
                actionActionController.addAction(abuseAction)
            }
        }
        actionActionController.addAction(cancelAction)
        self.present(actionActionController, animated: true, completion: nil)
        
    }

    
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
        guard let phoneNumber = listing?.phoneNumber else {return}
        let phoneActionController = UIAlertController(title: "Anrufen", message: nil, preferredStyle: .actionSheet)
        let phoneNumberAction = UIAlertAction(title: phoneNumber, style: .default, handler: { (UIAlertAction) in
            let telNumber = phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "/", with: "")
            if let url = URL(string: "tel://\(telNumber)") {
                UIApplication.shared.openURL(url)
            }
            
        })
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
        phoneActionController.addAction(phoneNumberAction)
        phoneActionController.addAction(cancelAction)
        self.present(phoneActionController, animated: true, completion: nil)
    }
    
    
    @IBAction func mapViewPressed(_ sender: UITapGestureRecognizer) {
        sendUserToMapApp()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        title = listing.title

        if !listing.hasImages {
        tableView.tableHeaderView?.frame.size.height = 0
        } else {
        activityIndi.startAnimating()
        if listing.source == "MPS" {
            NetworkManager.shared.getImagesFor(adID: listing.adID, completion: {images in
                if images != nil {
                self.images = images!
                    self.displayImages()
                }
                self.activityIndi.stopAnimating()

            })
        } else {
            
                NetworkManager.shared.getImageFor(paths: listing.imageURLs, completion: {(images, error) in
                    if error == nil && images != nil {
                        self.images = images!
                        self.displayImages()
                    }
                    self.activityIndi.stopAnimating()

                })
            
            
        }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if let categoryName = categoryBuilder.allCategories.first(where: {$0.id == listing.catID})?.name {
//            gaUserTracking("Search/\(categoryName)/Detail")
//        } else {
//            gaUserTracking("Search/Detail")
//        }
        navigationController?.hidesBarsOnSwipe = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndi.hidesWhenStopped = true
        activityIndi.center = tableView.tableHeaderView!.center
        tableView.tableHeaderView!.addSubview(activityIndi)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let priceCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        if listing.imageURLs.count > 0 {
            if tableView.contentOffset.y > 250 {
                priceCell?.contentView.isHidden = true
                fixedPriceCell.isHidden = false
            } else {
                priceCell?.contentView.isHidden = false
                fixedPriceCell.isHidden = true
            }
        } else {
            if tableView.contentOffset.y > (36) {
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
    
    
   
    
    func displayImages() {
        
        switch images.count {
        case 0: break
        case 1:
            image1widthConstraint.constant = -(screenwidth/2)
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
    
 
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
                cell?.contactButton.tintColor = UIColor.white
                if let source = listing?.source {
                    switch source {
                    case "AS","ASBikes":
                        cell?.contactButton.setTitle(" Ansehen", for: .normal)
                        cell?.contactButton.setImage(UIImage(named: "AS24"), for: .normal)
                    case "IS":
                        cell?.contactButton.setTitle(" Ansehen", for: .normal)
                        cell?.contactButton.setImage(UIImage(named: "IS24"), for: .normal)
                    case "Quo":
                        cell?.contactButton.setTitle("Auf Quoka ansehen", for: .normal)
                    case "Germanpersonnel":
                        cell?.contactButton.setTitle("Auf Germanpersonnel ansehen", for: .normal)
                    case "Adzuna":
                        cell?.contactButton.setTitle("Auf Adzuna ansehen", for: .normal)
                    case "KAL":
                        cell?.contactButton.setTitle("Auf Kalaydo ansehen", for: .normal)
                    default:
                        break
                    }
                }
                if self.listing?.phoneNumber != nil {
                    cell?.phoneButton.isHidden = false
                    
                } else {
                    cell?.phoneButton.isHidden = true
                    cell?.phoneButton.frame.size.width = 0
                }
                defaultcell = cell!
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCellID") as! TitleTableViewCell!
                cell?.adTitleLabel.text = listing.title
                defaultcell = cell!
            default: break
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCellID") as UITableViewCell!
            cell?.textLabel?.text = infos[(indexPath as NSIndexPath).row].name
            cell?.detailTextLabel?.text = infos[(indexPath as NSIndexPath).row].value
            defaultcell = cell!
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "desriptionCellID") as! DescriptionTableViewCell!
            cell?.adDescriptionLabel.text = listing.adDescription
            defaultcell = cell!
        case 3:
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationMapCellID") as! LocationMapTableViewCell!
                if let latitude = listing.adLat {
                    if let longitude = listing.adLong {
                        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        cell?.mapView.setRegion(region, animated: false)
                    }
                }
                defaultcell = cell!
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationStringsCellID") as UITableViewCell!
                if let plz = listing?.zipcode {
                    if let stadt = listing?.city {
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
    
    @IBAction func backfromContact(_ segue:UIStoryboardSegue) {
        
    }
    @IBAction func backfromDetailImage(_ segue:UIStoryboardSegue) {
        
        
    }
    @IBAction func backfromAbuseReport(_ segue:UIStoryboardSegue) {
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactSegueID" {
            if let navVC = segue.destination as? UINavigationController {
                if let contactVC = navVC.viewControllers[0] as? ContactTableViewController {
                    contactVC.listing = self.listing
                    contactVC.adID = String(describing: listing!.adID)
                    contactVC.detailLink = listing!.url!.absoluteString
                }
                
            }
        }
        if segue.identifier == "detailImageSegueID" {
            if let imgVC = segue.destination as? DetailImageViewController {
                let imageViewTapGestureRecognizer = sender as! UITapGestureRecognizer
                imgVC.touchedImageTag = imageViewTapGestureRecognizer.view!.tag
                imgVC.images = self.images

            }
        }
        
        
        if segue.identifier == "showAbuseReportSegueID" {
            if let navVC = segue.destination as? UINavigationController {
                if let abuseVC = navVC.viewControllers[0] as? AbuseReportViewController {
                    abuseVC.abuseID = String(listing!.adID!)
                    
                }
                
            }
        }
        
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "contactSegueID" {
            if let source = listing.source {
                if source != "MPS" {
                    if let url = listing.url {
                        let svc = SFSafariViewController(url: url)
                        if #available(iOS 10.0, *) {
                            svc.preferredControlTintColor = greencolor
                        } else {
                            svc.view.tintColor = greencolor
                        }
                        self.present(svc, animated: true, completion: nil)
                        return false
                    }
                }
            }
        }
        return true
    }
  
    
    
    func sendUserToMapApp() {
        let mapActionController = UIAlertController(title: "Anzeigen in", message: nil, preferredStyle: .actionSheet)
        guard let latitute:CLLocationDegrees =  self.listing.adLat else {return}
        guard let longitute:CLLocationDegrees =  self.listing.adLong else {return}
        
        let appleMapsAction = UIAlertAction(title: "Apple Karten", style: .default, handler: { UIAlertAction in
            
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
                    "comgooglemaps://?saddr=&daddr=\(latitute),\(longitute)&directionsmode=driving")!)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
        
        mapActionController.addAction(appleMapsAction)
        mapActionController.addAction(googleMapsAction)
        mapActionController.addAction(cancelAction)
        self.present(mapActionController, animated: true) {}
    }
    
}
