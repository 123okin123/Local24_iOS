//
//  InsertTableViewController.swift
//  Local24
//
//  Created by Local24 on 23/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import Alamofire
import SwiftValidator
import ImagePicker


class InsertTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, InsertImageCellDelegate, ImagePickerDelegate {

    @IBOutlet weak var imageCollectionView: UICollectionView!

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceTypeTextField: UITextField! {didSet {priceTypeTextField.delegate = self}}
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var adTypeTextField: UITextField! {didSet {adTypeTextField.delegate = self}}
    @IBOutlet weak var insertButton: UIButton! {didSet {insertButton.layer.cornerRadius = 10}}
    
    @IBOutlet weak var cityLabel: UILabel! 
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var houseNumberLabel: UILabel!
    
    
    var imageArray = [UIImage]()
    var listingExists = false
    
    let imagePicker = ImagePickerController()
    
    var listing = Listing() {didSet {
        if let location = user?.placemark?.location {
            listing.adLat = location.coordinate.latitude
            listing.adLong = location.coordinate.longitude
        }
        }}
    
    let pickerView = UIPickerView()
    let toolBar = UIToolbar()
   

    
    
    @IBAction func insertListing(_ sender: UIButton) {
        if validate() {
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
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Fertig", style: UIBarButtonItemStyle.plain, target: self, action: #selector(pickerDonePressed))
        toolBar.setItems([spaceButton, doneButton], animated: false)
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
        print("insertvc viewWillAppear")
        if listingExists {
        navigationItem.setHidesBackButton(false, animated: false)
        } else {
        navigationItem.setHidesBackButton(true, animated: false)
        }
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        NetworkController.getUserProfile(userToken: userToken!, completion: {(fetchedUser, statusCode) in
            user = fetchedUser
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func clearAll() {
        imageArray.removeAll()
        titleTextField.text = ""
        descriptionTextView.text = ""
        priceTextField.text = ""
        priceTypeTextField.text = "Festpreis"
        adTypeTextField.text = "Angebot"
        categoryLabel.text = "Bitte wählen Sie ein Kategorie"
        categoryLabel.textColor = UIColor.lightGray
        listing = Listing()
    }
    
    func prePopulate() {
        titleTextField.text = listing.title
        categoryLabel.text  = categoryBuilder.allCategories.filter({$0.id == listing.catID})[0].name
        descriptionTextView.text = listing.description
        priceTextField.text = listing.price
        priceTypeTextField.text = listing.priceType
        adTypeTextField.text = listing.adType?.rawValue
        categoryLabel.textColor = UIColor.black
        cityLabel.text = listing.city
        zipLabel.text = listing.zipcode
        streetLabel.text = listing.street
        houseNumberLabel.text = listing.houseNumber
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }



    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    

    var currentPickerArray = [String]()
    var currentTextField = UITextField()
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case adTypeTextField:
            currentTextField = adTypeTextField
            adTypeTextField.inputView = pickerView
            adTypeTextField.inputAccessoryView = toolBar
            currentPickerArray = Array(AdType.allValues.values)
            adTypeTextField.text = currentPickerArray[0]
        case priceTypeTextField:
            currentTextField = priceTypeTextField
            priceTypeTextField.inputView = pickerView
            priceTypeTextField.inputAccessoryView = toolBar
            currentPickerArray = Array(PriceType.allValues.values)
            priceTypeTextField.text = currentPickerArray[0]
        default: break
        }
       pickerView.reloadAllComponents()
        return true
    }


    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentPickerArray.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentPickerArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        currentTextField.text = currentPickerArray[row]
    }
    func pickerDonePressed() {
    view.endEditing(true)
    }
    

    // :MARK ImageCollectionView

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == imageArray.count {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "insertAddImageCellID", for: indexPath) as! AddImageCollectionViewCell
        return cell
        } else {
        let image = imageArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "insertImageCellID", for: indexPath) as! InsertImageCollectionViewCell
        cell.tag = indexPath.row
        cell.imageView.image = image
        cell.delegate = self
        return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130 , height: 130)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
      //  if indexPath.row == imageArray.count {
            present(imagePicker, animated: true, completion: nil)
       // }
    }
    
    
    // MARK: ImagePickerDelegate
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imageArray.removeAll()
        imageCollectionView.reloadData()
        imageCollectionView.scrollToItem(at: IndexPath(item: imageArray.endIndex, section: 0), at: .right, animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {

    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imageArray = images
        imageCollectionView.reloadData()
        imageCollectionView.scrollToItem(at: IndexPath(item: imageArray.endIndex, section: 0), at: .right, animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
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
        if priceTextField.text == nil {
            success = false
            priceTextField.superview?.layer.borderColor = failColor
            priceTextField.superview?.layer.borderWidth = 2
        } else {
            priceTextField.superview?.layer.borderWidth = 0
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
        // End of Optional Values
        NetworkController.insertAdWith(values: values, images: imageArray, existing: listingExists, userToken: userToken!, completion: { error in
            pendingAlertController.dismiss(animated: true, completion: nil)
            if error == nil {
                self.clearAll()
                let successMenu = UIAlertController(title: "Anzeige aufgegeben", message: "Herzlichen Glückwunsch Ihre Anzeige wurde erfolgreich aufgegeben.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: {alert in
                self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                })
                successMenu.addAction(confirmAction)
                self.present(successMenu, animated: true, completion: nil)
            } else {
                let errorMenu = UIAlertController(title: "Fehler", message: "Da ist leider etwas schief gegangen, das Inserieren der Anzeige war nicht erfolgreich.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                errorMenu.addAction(confirmAction)
                self.present(errorMenu, animated: true, completion: nil)
            }
        })
    }
    

    
    
    //  MARK: CellSubclassDelegate
    
    func buttonTapped(cell: InsertImageCollectionViewCell) {
        guard let indexPath = self.imageCollectionView.indexPath(for: cell) else {return}
        print("Button tapped on item \(indexPath.row)")
        
       // imageArray.remove(at: indexPath.row)
       // imageCollectionView.deleteItems(at: [indexPath])
    }
    
    
}





