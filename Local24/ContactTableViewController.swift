//
//  TableViewController.swift
//  Local24
//
//  Created by Local24 on 08/03/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class ContactTableViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var sendButton: UIButton! {didSet {
        sendButton.layer.cornerRadius = 5
        }}
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
    
    var locationStrings = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageTextView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        messageTextView.text = "Nachricht*"
        messageTextView.textColor = UIColor(red: 206/255, green: 206/255, blue: 211/255, alpha: 1.0)
        
        
        street.text = locationStrings["Straße"]
        
        city.text = locationStrings["Stadt"]
        zipCode.text = locationStrings["PLZ"]
        houseNumber.text = locationStrings["Hausnummer"]
        telefonNumber.setTitle(locationStrings["Telefonnummer"], for: UIControlState())

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
        let telefonNumberString = "tel:\(telefonNumber.currentTitle!)"
        print(telefonNumberString)
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


    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            let height = street.frame.size.height + city.frame.size.height + telefonNumber.frame.size.height + 8
            return height
        case 1:
            switch (indexPath as NSIndexPath).row {
            case 0: return 44
            case 1: return 44
            case 2: return 130
            default: return 44
            }
        case 2: return 44
        default: return 44
        }
        
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
