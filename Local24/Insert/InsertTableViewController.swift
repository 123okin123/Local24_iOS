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

class InsertTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, ValidationDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var listing = Listing()
    var imageArray = [UIImage]()
    
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var priceTypeTextField: UITextField! {didSet {priceTypeTextField.delegate = self}}
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var adTypeTextField: UITextField! {didSet {adTypeTextField.delegate = self}}
    @IBOutlet weak var insertButton: UIButton! {didSet {insertButton.layer.cornerRadius = 10}}
    
    
    @IBAction func insertListing(_ sender: UIButton) {
        validator.validate(self)
        
    }
    // ValidationDelegate methods
    
    func validationSuccessful() {
        
        let values = [
            "ID_Advertiser": user!.id!,
            "ID_Category" : listing.catID!,
            "EntityType" : listing.entityType!,
            "AdType": adTypeTextField.text!,
            "Title":titleTextField.text!,
            "Body": descriptionTextView.text!,
            "PriceType": priceTypeTextField.text!,
            "Price": priceTextField.text!,
            "City": user!.city!,
            "ZipCode": user!.zipCode!
            ] as [String : Any]
        
        Alamofire.request("https://cfw-api-11.azurewebsites.net/ads?auth=\(userToken!)", method: .post, parameters: values, encoding: JSONEncoding.default).responseString (completionHandler: {response in
            print(response.result.value)
            switch response.result {
            case .success:
                let successMenu = UIAlertController(title: "Anzeige aufgegeben", message: "Herzlichen Glückwunsch Ihre Anzeige wurde erfolgreich aufgegeben.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: {alert in})
                successMenu.addAction(confirmAction)
                self.present(successMenu, animated: true, completion: nil)
                
                Alamofire.request("https://cfw-api-11.azurewebsites.net/ads/", method: .get, parameters: ["auth":userToken!, "pagesize":1]).validate().responseJSON (completionHandler: {response in
                
                })
                
                
            case .failure:
                let errorMenu = UIAlertController(title: "Fehler", message: "Da ist leider etwas schief gegangen, das Inserieren der Anzeige war nicht erfolgreich.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: {alert in})
                errorMenu.addAction(confirmAction)
                self.present(errorMenu, animated: true, completion: nil)
             
            }
            
        })
        
    }
    
    func uploadImagesFor(adID :String) {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                for image in imageArray {
                    multipartFormData.append(image, withName: "unicorn")
                }
        },
            to: "https://cfw-api-11.azurewebsites.net/ads/\(adID)/images",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                if let contentView = field.superview {
                    contentView.layer.backgroundColor = UIColor(red: 224/255, green: 60/255, blue: 49/255, alpha: 0.5).cgColor
                }
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
        }
    }
    
    
    let pickerView = UIPickerView()
    let toolBar = UIToolbar()
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        validator.registerField(titleTextField, rules: [RequiredRule()])
        validator.registerField(priceTypeTextField, rules: [RequiredRule()])
        validator.registerField(priceTextField, rules: [RequiredRule()])
        validator.registerField(adTypeTextField, rules: [RequiredRule()])


    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("insertvc viewWillAppear")
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)

        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
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
        cell.imageView.image = image
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
        if indexPath.row == imageArray.count {
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageArray.append(pickedImage)
            let indexPath = IndexPath(item: imageArray.endIndex - 1, section: 0)
            
            imageCollectionView.insertItems(at: [indexPath])
            imageCollectionView.scrollToItem(at: IndexPath(item: imageArray.endIndex, section: 0), at: .right, animated: true)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
}





