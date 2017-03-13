//
//  EditProfileViewController.swift
//  Local24
//
//  Created by Local24 on 22/02/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit

class EditProfileViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    //MARK: IBOutlets
    
    @IBOutlet weak var userTitleField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var telephoneField: UITextField!
    @IBOutlet weak var streetField: UITextField!
    @IBOutlet weak var houseNumberField: UITextField!
    @IBOutlet weak var zipCodeField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    
    //MARK: Variables
    
    var salutationID = 0
    let pickerView = UIPickerView()
    let toolBar = UIToolbar()
    
    //MARK: IBActions
    
    @IBAction func saveProfileInfo(_ sender: UIBarButtonItem) {
        saveProfileInfoAction()
    }

    //MARK: ViewController Lifecycle
    
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
        setUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("EditProfile")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    
    //MARK: Methods
    
    func validate() -> Bool {
        var success = true
        let failColor = UIColor(red: 244/255, green: 214/255, blue: 213/255, alpha: 1.0)
        if firstNameField.text == "" {
            success = false
            firstNameField.superview?.backgroundColor = failColor
        } else {
            firstNameField.superview?.backgroundColor = UIColor.white
        }
        if lastNameField.text == "" {
            success = false
            lastNameField.superview?.backgroundColor = failColor
        } else {
            lastNameField.superview?.backgroundColor = UIColor.white
        }
        if cityField.text == "" || zipCodeField.text == "" {
            success = false
            cityField.superview?.superview?.backgroundColor = failColor
        } else {
            cityField.superview?.backgroundColor = UIColor.white
        }
        return success
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func saveProfileInfoAction() {
        guard validate() else {return}
        guard user != nil else {return}
        user!.salutationID = salutationID
        user!.firstName = firstNameField.text
        user!.lastName = lastNameField.text
        user!.telephone = telephoneField.text
        user!.street = streetField.text
        user!.houseNumber = houseNumberField.text
        user!.zipCode = zipCodeField.text
        user!.city = cityField.text
        let pendingAlertController = UIAlertController(title: "Profil wird bearbeitet\n\n\n", message: nil, preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(frame: pendingAlertController.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, . flexibleHeight]
        indicator.color = UIColor.darkGray
        pendingAlertController.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false
        indicator.startAnimating()
        present(pendingAlertController, animated: true, completion: nil)
        
        NetworkManager.shared.editUserInfos(user: user!, userToken: userToken!, completion: {
            error in
            pendingAlertController.dismiss(animated: true, completion: {
                if error == nil {
                    self.performSegue(withIdentifier: "backFromEditProfileToProfilSeugueID", sender: nil)
                } else {
                    let errorMenu = UIAlertController(title: "Fehler", message: "Beim bearbeiten ist ein Fehler aufgetreten", preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    errorMenu.addAction(confirmAction)
                    self.present(errorMenu, animated: true, completion: nil)
                }
            })
        })
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
        salutationID = pickerOptions[row].1
    }
    func pickerDonePressed() {
        view.endEditing(true)
    }

    func setUserInfo() {
        if let salutationID = user?.salutationID {
            userTitleField.text = pickerOptions.first(where: {$0.1 == salutationID})?.0
            self.salutationID = salutationID
        }
        firstNameField.text = user?.firstName
        lastNameField.text = user?.lastName
        telephoneField.text = user?.telephone
        streetField.text = user?.street
        houseNumberField.text = user?.houseNumber
        zipCodeField.text = user?.zipCode
        cityField.text = user?.city
    }

}
