//
//  AbuseReportViewController.swift
//  Local24
//
//  Created by Local24 on 20/04/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class AbuseReportViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var reportButton: UIBarButtonItem!
    
    @IBOutlet weak var abuseText: UITextView!
    var abuseID :String?
    
    @IBAction func reportButtonPressed(_ sender: UIBarButtonItem) {

            let url = "https://www.local24.de/ajax/api/"
            var request = URLRequest(url: URL(string: url)!)
            let session = URLSession.shared
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            
            let cause = "Cause=iOSApp"
            let message = "Message=\(abuseText.text)"
            let id = "id=\(abuseID!)"
            let collection = "collection=mps"
            let method = "method=reportAbuse"

            var bodyData = ""

            bodyData = cause + "&" + message + "&" + id +  "&" + collection + "&" + method
                
        
            
            request.httpBody = bodyData.data(using: String.Encoding.utf8)
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                let alert = UIAlertController(title: "Fehler", message: "Beim Senden des Verstoßes ist ein Fehler aufgetreten.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                if error != nil {
                    self.present(alert, animated: true, completion: nil)
                } else {
                    DispatchQueue.main.async {
                        
                        if let responseBody = String(data: data!, encoding: String.Encoding.utf8) {
                            if responseBody.contains(",\"ResponseCode\":200}") {
                                
                                self.dismiss(animated: true, completion: nil)
                                
                            } else {
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        
                        print(String(data: data!, encoding: String.Encoding.utf8))
                    }
                }
                
            }) 
            
            task.resume()
            
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        abuseText.resignFirstResponder()
    }
    
    


 
    func textViewDidChange(_ textView: UITextView) {
        if abuseText.text.isEmpty {
        reportButton.isEnabled = false
        abuseText.textColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0)
        abuseText.text = "Gegen welche Regel verstößt diese Anzeige?"
        abuseText.selectedRange = NSMakeRange(0, 0)
        } else {
        abuseText.textColor = UIColor.darkGray
        reportButton.isEnabled = true
        abuseText.text = abuseText.text.replacingOccurrences(of: "Gegen welche Regel verstößt diese Anzeige?", with: "")
        }
    }

 
    override func viewDidLoad() {
        super.viewDidLoad()
        abuseText.delegate = self
        abuseText.becomeFirstResponder()
        abuseText.text = "Gegen welche Regel verstößt diese Anzeige?"
        abuseText.textColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0)
        abuseText.selectedRange = NSMakeRange(0, 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AbuseReportViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AbuseReportViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

       
    }
    
    func keyboardDidShow(_ notification: Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print(keyboardSize)
            print(abuseText.frame)
            abuseText.frame.size.height -= keyboardSize.height
            print(abuseText.frame)
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            abuseText.frame.size.height += keyboardSize.height
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
