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


class LocalDetailTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var fixedPriceCell: UIView!
        {didSet {
            fixedPriceCell.layer.borderColor = UIColor(red: 0.783922, green: 0.780392, blue: 0.8, alpha: 1).cgColor
            fixedPriceCell.layer.borderWidth = 0.5
        }}
    
    @IBOutlet weak var fixedPriceCellPriceContactButton: UIButton!
        {didSet {
            fixedPriceCellPriceContactButton.layer.cornerRadius = 5
        }}
    @IBOutlet weak var fixedPriceCellPriceLabel: UILabel!
    @IBOutlet weak var fixedPriceCellPhoneButton: UIButton!
        {didSet {
            fixedPriceCellPhoneButton.layer.cornerRadius = 5
        }}
    
    var urlToShow : URL!
    var adID: String {
        var IDstring = urlToShow.pathComponents.last
        IDstring = IDstring?.substring(to: IDstring!.characters.index(IDstring!.endIndex, offsetBy: -3))
        return IDstring!
    }
    var adMainCat :String {return (urlToShow.pathComponents[2])}
    var adSubCat :String {return (urlToShow.pathComponents[3])}
    var categories = Categories()
    
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
    
    var adDescription = String()
    var adPrice = String()
    var adTitle = String()
    var infos = [[String]]()
    var locationStrings = [String : String]()
    var adLat = Double()
    var adLong = Double()
    var adPhoneNumber = String() {
        didSet {
            let priceCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as!PriceTableViewCell
            if adPhoneNumber == "" {
                priceCell.phoneButton.isHidden = true
                fixedPriceCellPhoneButton.isHidden = true
            } else {
                priceCell.phoneButton.isHidden = false
                fixedPriceCellPhoneButton.isHidden = false
            }
        }
    }
    
    let activityIndi = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var image2BottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    
    
    
    @IBAction func actionButtonPressed(_ sender: UIBarButtonItem) {
        
        let actionActionController = UIAlertController(title: "Was möchten Sie tun?", message: "", preferredStyle: .actionSheet)
        
        let abuseAction = UIAlertAction(title: "Anzeige melden", style: .default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "showAbuseReportSegueID", sender: self)
        })
        let emailAction = UIAlertAction(title: "per E-Mail teilen", style: .default, handler: { (UIAlertAction) in
            
            let emailTitle = "Anzeige auf Local24"
            let messageBody = "Hallo,\n\nDiese Kleinanzeige bei Local24.de könnte dich interressieren.\n\n\(self.adTitle)\n\n\(self.urlToShow.absoluteString)\n\nViele Grüße\n"
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setMessageBody(messageBody, isHTML: false)
            mc.navigationBar.tintColor = UIColor.white
            
            self.present(mc, animated: true, completion: {
                UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
            })
            
        })
        let fbshareAction = UIAlertAction(title: "über Facebook teilen", style: .default, handler: { (UIAlertAction) in
            let fbshareContent = FBSDKShareLinkContent()
            fbshareContent.contentURL = self.urlToShow
            fbshareContent.contentTitle = "Anzeige auf Local24"
            fbshareContent.contentDescription = "Diese Kleinanzeige bei Local24.de könnte euch interressieren.\n\n\(self.adTitle)"
            FBSDKShareDialog.show(from: self, with: fbshareContent, delegate: nil)
            
        })
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
        actionActionController.addAction(abuseAction)
        actionActionController.addAction(cancelAction)
        actionActionController.addAction(emailAction)
        actionActionController.addAction(fbshareAction)
        self.present(actionActionController, animated: true, completion: nil)
        
    }
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
        case MFMailComposeResult.saved:
            print("Mail saved")
        case MFMailComposeResult.sent:
            print("Mail sent")
        case MFMailComposeResult.failed:
            print("Mail sent failure: \(error?.localizedDescription)")
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func phoneButtonPressed(_ sender: UIButton) {
        
        let phoneActionController = UIAlertController(title: "Anrufen", message: "", preferredStyle: .actionSheet)
        let phoneNumberAction = UIAlertAction(title: adPhoneNumber, style: .default, handler: { (UIAlertAction) in
            let telNumber = self.adPhoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "/", with: "")
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
        let mapActionController = UIAlertController(title: "Anzeigen in", message: "", preferredStyle: .actionSheet)
        let appleMapsAction = UIAlertAction(title: "Apple Karten", style: .default, handler: { UIAlertAction in
            
            let latitute:CLLocationDegrees =  self.adLat
            let longitute:CLLocationDegrees =  self.adLong
            
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            
            if let plz = self.locationStrings["PLZ"] {
                if let stadt = self.locationStrings["Stadt"] {
                    mapItem.name = plz + " " + stadt
                }
            } else {
                mapItem.name = self.adTitle
            }
            mapItem.openInMaps(launchOptions: options)
        })
        let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default, handler: { UIAlertAction in
            
            
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.openURL(URL(string:
                    "comgooglemaps://?saddr=&daddr=\(self.adLat),\(self.adLong)&directionsmode=driving")!)
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
        loadData()
        getImagesURL()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("DetailInMainCategory_\(adMainCat)")
        navigationController?.hidesBarsOnSwipe = false
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let priceCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        if images.count > 0 {
            if tableView.contentOffset.y > 187 {
                priceCell?.contentView.isHidden = true
                fixedPriceCell.isHidden = false
            } else {
                priceCell?.contentView.isHidden = false
                fixedPriceCell.isHidden = true
            }
        } else {
            if tableView.contentOffset.y > (-63) {
                priceCell?.contentView.isHidden = true
                fixedPriceCell.isHidden = false
            } else {
                priceCell?.contentView.isHidden = false
                fixedPriceCell.isHidden = true
            }
        }
        
        
        print(tableView.contentOffset.y)
        
        if tableView.contentOffset.y < (-64) {
            
            image1.frame.size.height = 250 - tableView.contentOffset.y - 64
            image1.frame.origin.y = tableView.contentOffset.y + 64
            
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
    
    
    func loadData() {
        Alamofire.request("https://cfw-api-11.azurewebsites.net/public/ads/\(adID)/").responseJSON(completionHandler: { response in
            switch response.result {
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "Fehler", message: "Local24 hat keine Verbindung zum Internet.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .success:
                
                if let json = response.result.value as? [AnyHashable: Any] {
                    if let body = json["Body"] as? String {
                        self.adDescription = body
                    }
                    if let body = json["Title"] as? String {
                        self.adTitle = body
                    }
                    
                    if let adPriceFloat = json["Price"] as? Float {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .currency
                        
                        self.adPrice = formatter.string(from: NSNumber(value: adPriceFloat))!
                    } else {
                        if let pricetype = json["PriceType"] as? String {
                            self.adPrice = pricetype
                        } else {
                            self.adPrice = "k.A."
                        }
                    }
                    if let pricetype = json["PriceType"] as? String {
                        self.infos.append(["Preisart", pricetype])
                    }
                    
                    if let latitude = json["Latitude"] as? Double {
                        self.adLat = latitude
                    }
                    if let longitude = json["Longitude"] as? Double {
                        self.adLong = longitude
                    }
                    
                    
                    
                    if var createdAt = json["CreatedAt"] as? String {
                        let createdAtYear = createdAt[Range(createdAt.startIndex ..< createdAt.characters.index(createdAt.startIndex, offsetBy: 4))]
                        let createdAtMonth = createdAt[Range(createdAt.characters.index(createdAt.startIndex, offsetBy: 5) ..< createdAt.characters.index(createdAt.startIndex, offsetBy: 7))]
                        let createdAtDay = createdAt[Range(createdAt.characters.index(createdAt.startIndex, offsetBy: 8) ..< createdAt.characters.index(createdAt.startIndex, offsetBy: 10))]
                        createdAt = "\(createdAtDay).\(createdAtMonth).\(createdAtYear)"
                        self.infos.append(["Datum", createdAt])
                    }
                    if var updatedAt = json["UpdatedAt"] as? String {
                        let updatedAtYear = updatedAt[Range(updatedAt.startIndex ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 4))]
                        let updatedAtMonth = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 5) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 7))]
                        let updatedAtDay = updatedAt[Range(updatedAt.characters.index(updatedAt.startIndex, offsetBy: 8) ..< updatedAt.characters.index(updatedAt.startIndex, offsetBy: 10))]
                        updatedAt = "\(updatedAtDay).\(updatedAtMonth).\(updatedAtYear)"
                        self.infos.append(["Aktualisiert", updatedAt])
                    }
                    if let street = json["Street"] as? String {
                        self.locationStrings["Straße"] = street
                    }
                    if let houseNumber = json["HouseNumber"] as? String {
                        self.locationStrings["Hausnummer"] = houseNumber
                    }
                    if let city = json["City"] as? String {
                        self.locationStrings["Stadt"] = city
                    }
                    if let zipCode = json["ZipCode"] as? String {
                        self.locationStrings["PLZ"] = zipCode
                    }
                    if let phone = json["Phone"] as? String {
                        self.locationStrings["Telefonnummer"] = phone
                        self.adPhoneNumber = phone
                    }
                    
                    
                    
                    
                    //Autos
                    if let condition = json["Condition"] as? String {
                        self.infos.append(["Zustand", condition])
                    }
                    if let make = json["Make"] as? String {
                        self.infos.append(["Marke", make])
                    }
                    if let model = json["Model"] as? String {
                        self.infos.append(["Model", model])
                    }
                    if let mileage = json["Mileage"] as? Float {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        let mileageString = formatter.string(from: NSNumber(value: mileage))! + " km"
                        self.infos.append(["Kilometerstand", mileageString])
                    }
                    if let initialRegistration = json["InitialRegistration"] as? String {
                        self.infos.append(["Erstzulassung", initialRegistration])
                    }
                    if let fuelType = json["FuelType"] as? String {
                        self.infos.append(["Kraftstoffart", fuelType])
                    }
                    if let fuelConsumption = json["FuelConsumption"] as? Float {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .none
                        let fuelConsumptionString = formatter.string(from: NSNumber(value: fuelConsumption))! + " l/100km (kombiniert)"
                        self.infos.append(["Verbrauch", fuelConsumptionString])
                    }
                    if let power = json["Power"] as? Float {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .none
                        let kWpower = power * 0.735499
                        let powerString = formatter.string(from: NSNumber(value: power))! + "PS / " + formatter.string(from: NSNumber(value: kWpower))! + "kW"
                        self.infos.append(["Leistung", powerString])
                    }
                    if let gearType = json["GearType"] as? String {
                        self.infos.append(["Getriebe", gearType])
                    }
                    
                    // Immobilien
                    if let priceTypeProperty = json["PriceTypeProperty"] as? String {
                        self.infos.append(["Preisart", priceTypeProperty])
                    }
                    if var additionalCostsFloat = json["AdditionalCosts"] as? Float {
                        additionalCostsFloat = (additionalCostsFloat * 1000)/1000
                        let additionalCosts = "\(String(format: "%.2f", additionalCostsFloat).replacingOccurrences(of: ".", with: ",")) €"
                        self.infos.append(["Nebenkosten", additionalCosts])
                    }
                    if var depositAmountFloat = json["DepositAmount"] as? Float {
                        depositAmountFloat = (depositAmountFloat * 1000)/1000
                        let depositAmount = "\(String(format: "%.2f", depositAmountFloat).replacingOccurrences(of: ".", with: ",")) €"
                        self.infos.append(["Kaution", depositAmount])
                    }
                    if var sizeFloat = json["Size"] as? Float {
                        sizeFloat = (sizeFloat * 1000)/1000
                        let size = "\(String(format: "%.2f", sizeFloat).replacingOccurrences(of: ".", with: ",")) m²"
                        self.infos.append(["Wohnfläche", size])
                    }
                    if let totalRoomsInt = json["TotalRooms"] as? Int {
                        let totalRooms = String(totalRoomsInt)
                        self.infos.append(["Zimmer", totalRooms])
                    }
                    if let apartmentType = json["ApartmentType"] as? String {
                        self.infos.append(["Wohnungstyp", apartmentType])
                    }
                    
                    self.tableView.reloadData()
                    
                    
                    self.title = self.adTitle
                    
                } else {
                    let alert = UIAlertController(title: "Fehler", message: "Der Artikel konnte nicht gefunden werden.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)}
   
            }
        })
        
    }
    
    
    func getImagesURL() {
        Alamofire.request("https://cfw-api-11.azurewebsites.net/public/ads/\(adID)/images/").responseJSON(completionHandler: { response in
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
                    print(error)
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
                
                cell?.adPriceLabel.text = adPrice
                fixedPriceCellPriceLabel.text = adPrice
                
                defaultcell = cell!
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCellID") as! TitleTableViewCell!
                
                cell?.adTitleLabel.text = adTitle
                
                defaultcell = cell!
            default: break
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "infoCellID") as UITableViewCell!
            cell?.textLabel!.text! = infos[(indexPath as NSIndexPath).row][0]
            cell?.detailTextLabel!.text! = infos[(indexPath as NSIndexPath).row][1]
            defaultcell = cell!
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "desriptionCellID") as! DescriptionTableViewCell!
            
            cell?.adDescriptionLabel.text = adDescription
            
            defaultcell = cell!
        case 3:
            switch (indexPath as NSIndexPath).row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationMapCellID") as! LocationMapTableViewCell!
                
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: adLat, longitude: adLong), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
                cell?.mapView.setRegion(region, animated: false)
                
                defaultcell = cell!
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "locationStringsCellID") as UITableViewCell!
                if let plz = locationStrings["PLZ"] {
                    if let stadt = locationStrings["Stadt"] {
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
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    @IBAction func backfromContact(_ segue:UIStoryboardSegue) {
        
        
    }
    @IBAction func backfromDetailImage(_ segue:UIStoryboardSegue) {
        
        
    }
    @IBAction func backfromAbuseReport(_ segue:UIStoryboardSegue) {
        
        
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactSegueID" {
            if let navVC = segue.destination as? UINavigationController {
                if let contactVC = navVC.viewControllers[0] as? ContactTableViewController {
                    contactVC.locationStrings = self.locationStrings
                    contactVC.adID = self.adID
                    contactVC.detailLink = self.urlToShow.absoluteString
                    
                    
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
                    abuseVC.abuseID = adID
                    
                }
                
            }
            
            
        }
        
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        return true
        
    }
    
    
    
}
