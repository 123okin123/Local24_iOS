//
//  TableViewController.swift
//  Local24
//
//  Created by Local24 on 08/03/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

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
    var adID = ""
    var detailLink = ""
    
    var listing :Listing!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.delegate = self
        messageTextView.text = "Nachricht*"
        messageTextView.textColor = UIColor(red: 206/255, green: 206/255, blue: 211/255, alpha: 1.0)
        
        street.text = listing.street
        city.text = listing.city
        zipCode.text = listing.zipcode
        houseNumber.text = listing.houseNumber
        telefonNumber.setTitle(listing.phoneNumber, for: UIControlState())

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
        let url = "https://www.local24.de/ajax/contact/"
        var request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        let name = "name=\(nameTextField.text!)"
        let email = "email=\(emailTextField.text!)"
        let message = "message=\(messageTextView.text!)"
        let copy = "on"
        let contactAdID = "ID=\(adID)"
        let contactdetailLink = "detailLink=\(detailLink)"
        let title = ""
            
            var bodyData = ""
            if copyForMe {
                bodyData = name + "&" + email + "&" + message + "&" + copy + "&" + contactAdID + "&" + contactdetailLink + "&" + title
            } else {
            bodyData = name + "&" + email + "&" + message +  "&" + contactAdID + "&" + contactdetailLink + "&" + title
            
            }
        
        request.httpBody = bodyData.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            let alert = UIAlertController(title: "Fehler", message: "Beim Senden der Nachricht ist ein Fehler aufgetreten.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            if error != nil {
                self.present(alert, animated: true, completion: nil)
            } else {
                DispatchQueue.main.async {
                    
                    if let responseBody = String(data: data!, encoding: String.Encoding.utf8) {
                    if responseBody.contains("{\"ResponseCode\":200") {
                        let successAlert = UIAlertController(title: "Nachricht wurde versendet", message: "Ihre Nachricht wurde per Mail an den Anbieter versendet.", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(successAlert, animated: true, completion: nil)
                        
                    } else {
                      self.present(alert, animated: true, completion: nil)
                    }
                    }

                    print(String(data: data!, encoding: String.Encoding.utf8)!)
                }
            }
            
        }) 
        
        task.resume()
            
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
