//
//  RegisterViewController.swift
//  Local24
//
//  Created by Local24 on 19/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class RegisterViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var userTitleField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var familyNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordRepetionField: UITextField!
    @IBOutlet weak var telefonField: UITextField!
    @IBOutlet weak var streetField: UITextField!
    @IBOutlet weak var houseNumberField: UITextField!
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    
    @IBOutlet weak var acceptAGBSwitch: UISwitch!
    var salutation :(String, Int)?
    
    let pickerView = UIPickerView()
    let toolBar = UIToolbar()

    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        
        if validate() {
        
        let pendingAlertController = UIAlertController(title: "Registrieren\n\n\n", message: nil, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: pendingAlertController.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, . flexibleHeight]
        indicator.color = UIColor.darkGray
        pendingAlertController.view.addSubview(indicator)
        indicator.startAnimating()
        present(pendingAlertController, animated: true, completion: nil)
        
        var values = ["ID":"1",
                      "ID_Partner": "477",
                      "LoginEmail": emailField.text!,
                      "Password": passwordField.text!,
                      "PasswordRepetition": passwordRepetionField.text!,
                      "FirstName": firstNameField.text!,
                      "LastName": familyNameField.text!,
                      "City": cityField.text!,
                      "IsCommercial": "false",
                      "acceptAgb": "on",
                        "action": "register"
                      ]
            if telefonField.text != "" {
            values["PhoneNo"] = telefonField.text!
            }
            if streetField.text != "" {
            values["Street"] = streetField.text!
            }
            if houseNumberField.text != "" {
            values["HouseNumber"] = houseNumberField.text!
            }
            if zipCodeField.text != ""  {
            values["ZipCode"] = zipCodeField.text!
            }
            if salutation != nil {
            values["ID_Salutation"] = String(describing: salutation!.1)
            }
            
        
        NetworkManager.shared.registerUserWith(values: values, completion: { error in
            pendingAlertController.dismiss(animated: true, completion: {
            if error == nil {
               // let tracker = GAI.sharedInstance().defaultTracker
               // tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Registration", action: "registration", label: "", value: 0).build() as NSDictionary as! [AnyHashable: Any])
                let errorAlert = UIAlertController(title: "Registrierung erfolgreich", message: "Um Ihre Registrierung abzuschließen, klicken Sie bitte auf den Link in der an die angegebene Adresse versendete E-Mail", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { action in
                    self.dismiss(animated: true, completion: nil)})
                errorAlert.addAction(okAction)
                self.present(errorAlert, animated: true, completion: nil)
                
            } else {
                let errorAlert = UIAlertController(title: "Fehler", message: "Registrierung fehlgeschlagen.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                errorAlert.addAction(okAction)
                self.present(errorAlert, animated: true, completion: nil)
            }
            })
        })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = greencolor
        toolBar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Fertig", style: UIBarButtonItemStyle.plain, target: self, action: #selector(pickerDonePressed))
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        userTitleField.inputAccessoryView = toolBar
        userTitleField.inputView = pickerView
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       //gaUserTracking("Register")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("Register")
    }

    
        func validate() -> Bool {
            var success = true
            let failColor = UIColor(red: 244/255, green: 214/255, blue: 213/255, alpha: 1.0)
            if emailField.text == "" || !(emailField.text!.contains("@")) {
                success = false
                emailField.superview?.backgroundColor = failColor
            } else {
                emailField.superview?.backgroundColor = UIColor.white
            }
            if firstNameField.text == "" {
                success = false
                firstNameField.superview?.backgroundColor = failColor
            } else {
                firstNameField.superview?.backgroundColor = UIColor.white
            }
            if familyNameField.text == "" {
                success = false
                familyNameField.superview?.backgroundColor = failColor
            } else {
                familyNameField.superview?.backgroundColor = UIColor.white
            }
            if passwordField.text!.characters.count < 6 || passwordRepetionField.text != passwordField.text {
                success = false
                passwordField.superview?.backgroundColor = failColor
                passwordRepetionField.superview?.backgroundColor = failColor
            } else {
                passwordField.superview?.backgroundColor = UIColor.white
                passwordRepetionField.superview?.backgroundColor = UIColor.white
            }
            if cityField.text == "" || zipCodeField.text == "" {
                success = false
                cityField.superview?.superview?.backgroundColor = failColor
            } else {
                cityField.superview?.backgroundColor = UIColor.white
            }
            if !acceptAGBSwitch.isOn {
                acceptAGBSwitch.superview?.backgroundColor = failColor
            } else {
                acceptAGBSwitch.superview?.backgroundColor = UIColor.white
            }

            
            return success
        }
   
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    
    
    let pickerOptions = [("keine Angabe", 1), ("Herr", 2), ("Frau", 3)]
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row].0
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userTitleField.text = pickerOptions[row].0
        salutation = pickerOptions[row]
    }
    func pickerDonePressed() {
        view.endEditing(true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAGB" {
            if let dvc = segue.destination as? MoreViewController {
                dvc.moreTag = 5
            }
        }
    }

}
