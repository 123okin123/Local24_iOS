//
//  InsertTableViewController.swift
//  Local24
//
//  Created by Local24 on 23/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import Alamofire
import ImagePicker
import SwiftyJSON


class InsertTableViewController: UITableViewController {

    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet var customFieldCellCollection: [InsertCustomFieldCell]! {didSet {
        var i = 1
        for cell in customFieldCellCollection {
            cell.textField.delegate = self
            cell.textField.tag = i
            i += 1
        }
        }}

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var independentFieldLabel: UILabel!
    @IBOutlet weak var dependentFieldLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceTypeTextField: UITextField! {didSet {priceTypeTextField.delegate = self}}
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var adTypeTextField: UITextField! {didSet {adTypeTextField.delegate = self}}
    @IBOutlet weak var insertButton: UIButton! {didSet {insertButton.layer.cornerRadius = 10}}
    
    @IBOutlet weak var cityLabel: UILabel! 
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var houseNumberLabel: UILabel!
    
    
    var listingExists = false

    var imageArray = [UIImage]()
    var imagePicker  = ImagePickerController()
    var listing = Listing() {didSet {
        if let location = user?.placemark?.location {
            listing.adLat = location.coordinate.latitude
            listing.adLong = location.coordinate.longitude
        }
        }}
    
    
   
    var customFields = [SpecialField]()
    
    var pickerView = UIPickerView()
    var toolBar = UIToolbar()
    var currentPickerArray = [String]()
    var currentTextField  = UITextField()
    
    
    
    // MARK: - IBActions
    @IBAction func insertListing(_ sender: UIButton) {
        if validate() {
            let tracker = GAI.sharedInstance().defaultTracker
            if listingExists {
                tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Insertion", action: "edited", label: categoryLabel.text!, value: 0).build() as NSDictionary as! [AnyHashable: Any])
            } else {
                tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Insertion", action: "insertion", label: categoryLabel.text!, value: 0).build() as NSDictionary as! [AnyHashable: Any])
            }
            submitAd()
        }
    }
 
    

    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if listingExists { prePopulate() }
        pickerView.delegate = self
        pickerView.dataSource = self
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        imagePicker.delegate = self
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = greencolor
        toolBar.sizeToFit()
        
        toolBar.isUserInteractionEnabled = true
     
        if let placemark = user?.placemark  {
            cityLabel.text = placemark.addressDictionary?["City"] as! String?
            zipLabel.text = placemark.addressDictionary?["ZIP"] as! String?
            streetLabel.text = placemark.addressDictionary?["Thoroughfare"] as! String?
            houseNumberLabel.text = placemark.addressDictionary?["SubThoroughfare"] as! String?
        }
        

    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if listingExists {
            gaUserTracking("Insert(editExisting)")
            navigationItem.setHidesBackButton(false, animated: false)
        } else {
            gaUserTracking("Insert")
            navigationItem.setHidesBackButton(true, animated: false)
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
        networkManager.getUserProfile(userToken: userToken!, completion: {(fetchedUser, statusCode) in
            user = fetchedUser
        })
       
        
       
        
        
        
       
    }
    
    
    

    
    
    func clearAll() {
        imageArray.removeAll()
        imageCollectionView.reloadData()
        titleTextField.text = ""
        descriptionTextView.text = ""
        priceTextField.text = ""
        priceTypeTextField.text = "Festpreis"
        adTypeTextField.text = "Angebot"
        categoryLabel.text = "Bitte wählen Sie ein Kategorie"
        categoryLabel.textColor = UIColor.lightGray
        independentFieldLabel.text = ""
        dependentFieldLabel.text = ""
        customFields.removeAll()
        listing = Listing()
        tableView.reloadData()
        
        
    }
    
    func prePopulate() {
        
        titleTextField.text = listing.title
        categoryLabel.text  = categoryBuilder.allCategories.filter({$0.id == listing.catID})[0].name
        descriptionTextView.text = listing.adDescription
        if listing.price == "-, €" {
            priceTextField.text = ""
        } else {
            priceTextField.text = listing.price
        }
        priceTypeTextField.text = listing.priceType
        adTypeTextField.text = listing.adType?.rawValue
        categoryLabel.textColor = UIColor.black
        
        independentFieldLabel.text = listing.specialFields?.first(where: {$0.dependingField != nil})?.valueString
        dependentFieldLabel.text = listing.specialFields?.first(where: {$0.dependsOn != nil})?.valueString
        if let specialFields = listing.specialFields?.filter({$0.dependingField == nil && $0.dependsOn == nil}) {
            if specialFields.count > 0 {
            customFields = specialFields
            for i in 0...customFields.count - 1 {
                customFieldCellCollection[i].textField.text = customFields[i].valueString
                customFieldCellCollection[i].textLabel?.text = customFields[i].descriptiveString
                if let path = Bundle.main.path(forResource: "specialFields", ofType: "json") {
                    do {
                        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                        let json = JSON(data: data)
                        if json != JSON.null {
                            if let entityType = listing.entityType {
                                if let fields = json[entityType].dictionary {
                                    if let field = fields[customFields[i].name!] {
                                        if let possibleValues = field["possibleValues"].arrayObject as [Any]! {
                                        customFields[i].possibleValues = possibleValues
                                        }
                                    }
                                }
                            }
                        } else {
                            print("Could not get json from file, make sure that file contains valid json.")
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
                
                
                
            }
            }
        }
        cityLabel.text = listing.city
        zipLabel.text = listing.zipcode
        streetLabel.text = listing.street
        houseNumberLabel.text = listing.houseNumber
    }

 


    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    

    
    // MARK: Validation
    
    
    
    func validate() -> Bool {
        var success = true
        let failColor = UIColor(red: 224/255, green: 60/255, blue: 49/255, alpha: 0.5).cgColor
        if titleTextField.text == nil {
            success = false
            titleTextField.superview?.layer.borderColor = failColor
            titleTextField.superview?.layer.borderWidth = 2
        } else if titleTextField.text!.characters.count < 3 {
            success = false
            titleTextField.superview?.layer.borderColor = failColor
            titleTextField.superview?.layer.borderWidth = 2
        } else {
            titleTextField.superview?.layer.borderWidth = 0
        }
        if categoryLabel.text == "Bitte wählen Sie ein Kategorie" {
            success = false
            categoryLabel.textColor = UIColor(cgColor: failColor)
        } else {
            categoryLabel.textColor = UIColor.black
        }
        if descriptionTextView.text.characters.count < 10  {
            success = false
            descriptionTextView.superview?.layer.borderColor = failColor
            descriptionTextView.superview?.layer.borderWidth = 2
        } else {
            descriptionTextView.superview?.layer.borderWidth = 0
        }
        if priceTextField.text == "" || priceTextField.text == nil {
            priceTextField.text = "0"
        }
        if cityLabel.text == "..." || zipLabel.text == "Artikelstandort" {
            success = false
            zipLabel.textColor = UIColor(cgColor: failColor)
            cityLabel.textColor = UIColor(cgColor: failColor)
        } else {
            zipLabel.textColor = UIColor.darkGray
            cityLabel.textColor = UIColor.darkGray
        }

        return success
    }
    
    
    func submitAd() {
        
        let pendingAlertController = UIAlertController(title: "Anzeige wird erstellt\n\n\n", message: nil, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: pendingAlertController.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, . flexibleHeight]
        indicator.color = UIColor.darkGray
        pendingAlertController.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false
        let cancleAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: { _ in networkManager.cancelCurrentRequest()})
        
        pendingAlertController.addAction(cancleAction)
        indicator.startAnimating()
        present(pendingAlertController, animated: true, completion: nil)
        
        
        
        
        var values = [
            "ID_Advertiser": user!.id!,
            "ID_Category" : listing.catID!,
            "EntityType" : listing.entityType!,
            "AdType": adTypeTextField.text!,
            "Title":titleTextField.text!,
            "Body": descriptionTextView.text!,
            "PriceType": priceTypeTextField.text!,
            "Price": priceTextField.text!,
            "City": cityLabel.text!,
            "ZipCode": zipLabel.text!,
            ] as [String : Any]
        
        if listingExists {
        values["ID"] = String(listing.adID!)
        }
        
        // Optional Values
        if let adLat = listing.adLat {
        values["Latitude"] = adLat
        }
        if let adLong = listing.adLong {
            values["Longitude"] = adLong
        }
        if let street = streetLabel.text {
            values["Street"] = street
        }
        if let houseNumber = houseNumberLabel.text {
            values["HouseNumber"] = houseNumber
        }
        if let houseNumber = houseNumberLabel.text {
            values["HouseNumber"] = houseNumber
        }
        
        listing.specialFields = [SpecialField]()
        listing.specialFields?.append(contentsOf: customFields)
        
        switch listing.entityType! {
        case "AdCar":
            let independetField = SpecialField(name: "Make", descriptiveString: "Marke", value: independentFieldLabel.text, possibleValues: nil, type :nil)
            let dependentField = SpecialField(name: "Model", descriptiveString: "Model", value: dependentFieldLabel.text, possibleValues: nil, type :nil)
            listing.specialFields?.append(independetField)
            listing.specialFields?.append(dependentField)
        case "AdApartment", "AdHouse":
            let independetField = SpecialField(name: "SellOrRent", descriptiveString: "Verkauf oder Vermietung", value: independentFieldLabel.text, possibleValues: nil, type :nil)
            let dependentField = SpecialField(name: "PriceTypeProperty", descriptiveString: "Preisart", value: dependentFieldLabel.text, possibleValues: nil, type :nil)
            listing.specialFields?.append(independetField)
            listing.specialFields?.append(dependentField)
        default:
            break
        }
        
        if listing.specialFields!.count > 0 {
        for specialField in listing.specialFields! {
            if let name = specialField.name {
                if let value = specialField.value {
                    values[name] = value
                } 
            }
        }
        }
        // End of Optional Values
        
         networkManager.insertAdWith(values: values, images: imageArray, existing: listingExists, userToken: userToken!, completion: { errorString in
            pendingAlertController.dismiss(animated: true, completion: {
            if errorString == nil {

                let successMenu = UIAlertController(title: "Anzeige aufgegeben", message: "Herzlichen Glückwunsch Ihre Anzeige wurde erfolgreich aufgegeben.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Ok", style: .cancel, handler: {alert in
                self.clearAll()
                _ = self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                })
                successMenu.addAction(confirmAction)
                self.present(successMenu, animated: true, completion: nil)
            } else {
                let errorMenu = UIAlertController(title: "Fehler", message: errorString, preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                errorMenu.addAction(confirmAction)
                self.present(errorMenu, animated: true, completion: nil)
            }
            })
        })
        
        
    }
    

  
    
    }





