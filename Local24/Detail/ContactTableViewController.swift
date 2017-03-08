//
//  TableViewController.swift
//  Local24
//
//  Created by Local24 on 08/03/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import Alamofire


class ContactTableViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var sendButton: UIButton! {didSet { sendButton.layer.cornerRadius = 10}}
    @IBOutlet weak var copyForMeSwitch: UISwitch!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var street: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var zipCode: UILabel!
    @IBOutlet weak var houseNumber: UILabel!
    @IBOutlet weak var telefonNumber: UIButton!
    
    var copyForMe = true
   
   
    var listing :Listing!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.delegate = self
        messageTextView.text = "Nachricht*"
        messageTextView.textColor = UIColor(red: 206/255, green: 206/255, blue: 211/255, alpha: 1.0)
        
        // Inserent
        street.text = listing.street
        city.text = listing.city
        zipCode.text = listing.zipcode
        houseNumber.text = listing.houseNumber
        telefonNumber.setTitle(listing.phoneNumber, for: UIControlState())

        // User
        nameTextField.text = user?.fullName
        emailTextField.text = user?.email
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("ContactUser")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messageTextView.resignFirstResponder()
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if messageTextView.textColor == UIColor(red: 206/255, green: 206/255, blue: 211/255, alpha: 1.0) {
            messageTextView.text = ""
            messageTextView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if messageTextView.text.isEmpty {
            messageTextView.text = "Nachricht*"
            messageTextView.textColor = UIColor(red: 206/255, green: 206/255, blue: 211/255, alpha: 1.0)
        }
    }


    @IBAction func copySwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
        copyForMe = true
        } else {
        copyForMe = false
        }
    }
        
   

    @IBAction func telephonNumberClicked(_ sender: UIButton) {
        if telefonNumber.currentTitle != nil {
            let telefonNumberString = "tel:\(telefonNumber.currentTitle!.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "/", with: ""))"
            if let url = URL(string: telefonNumberString) {
                UIApplication.shared.openURL(url)
            }
        }
    }

    
    @IBAction func sendMessage(_ sender: UIButton) {
        var requiredFieldsSet = false
        if nameTextField.text != "" && emailTextField.text != "" && messageTextView.text != "" {
            requiredFieldsSet = true
        }
        
        
        if requiredFieldsSet {
            
            let pendingAlertController = UIAlertController(title: "Nachricht wird versendet.\n\n\n", message: nil, preferredStyle: .alert)
            let indicator = UIActivityIndicatorView(frame: pendingAlertController.view.bounds)
            indicator.autoresizingMask = [.flexibleWidth, . flexibleHeight]
            indicator.color = UIColor.darkGray
            pendingAlertController.view.addSubview(indicator)
            indicator.isUserInteractionEnabled = false
            indicator.startAnimating()
            present(pendingAlertController, animated: true, completion: nil)
            
            
            var parameters = [
                "name" : nameTextField.text!,
                "email" : emailTextField.text!,
                "message" : messageTextView.text!,
                "ID" : String(listing.adID),
                "detailLink" : listing!.url!.absoluteString,
                "title" : listing.title!
            ]
            if copyForMe {
                parameters["copy"] = "on"
            }
            let headers: HTTPHeaders = [
                "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                "Referer": listing!.url!.absoluteString,
                ]
            
            Alamofire.request("https://www.local24.de/ajax/contact/", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON(completionHandler: {response in
                debugPrint(response)
                pendingAlertController.dismiss(animated: true, completion: {
                    
                    let alert = UIAlertController(title: "Fehler", message: "Beim Senden der Nachricht ist ein Fehler aufgetreten.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    guard response.result.isSuccess else {self.present(alert, animated: true, completion: nil); return}
                    guard let value = response.result.value as? NSDictionary else {self.present(alert, animated: true, completion: nil); return}
                    guard value["ResponseCode"] as! Int == 200 else {self.present(alert, animated: true, completion: nil); return}
                    
                    let successAlert = UIAlertController(title: "Nachricht wurde versendet", message: "Ihre Nachricht wurde per Mail an den Anbieter versendet.", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(successAlert, animated: true, completion: nil)
                    
                    if let mainCat = self.listing.mainCatString {
                        if let subCat = self.listing.subCatString {
                            FIRAnalytics.logEvent(withName: "contact", parameters: [
                                "mainCategory": mainCat as NSObject,
                                "subCategory": subCat as NSObject
                                ])
                        }
                    }
                })
            })
        } else {
            let requiredFieldsAlert = UIAlertController(title: "Fehler", message: "Bitte füllen Sie alle als Pflichtfeld markierten Felder aus.", preferredStyle: .alert)
            requiredFieldsAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(requiredFieldsAlert, animated: true, completion: nil)
            
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    


}
