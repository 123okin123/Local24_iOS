//
//  LoginViewController.swift
//  Local24
//
//  Created by Local24 on 20/06/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var inputBGViewBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var inputBGView: UIView! {
        didSet {
        inputBGView.layer.cornerRadius = 3
        }
    }
    @IBOutlet weak var submitButton: UIButton!{
        didSet {
            submitButton.layer.cornerRadius = 3
        }
    }
    @IBAction func submitButtonPressed(_ sender: UIButton) {
            submitCredentials()
    }
    
    
    
    func submitCredentials() {
        let credentials = emailTextField.text! + ":" + passwordTextField.text!
        let utf8credentials = credentials.data(using: String.Encoding.utf8)
        if let base64Encoded = utf8credentials?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        {
            
            
            let url = "https://cfw-api-11.azurewebsites.net/tokens/\(base64Encoded)"
            var request = URLRequest(url: URL(string: url)!)
            let session = URLSession.shared
            request.httpMethod = "POST"
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                
                if error != nil {
                    print("thers an error in the log")
                } else {
                    DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse {
                        switch httpResponse.statusCode {
                        case 400:
                            let animation = CABasicAnimation(keyPath: "position")
                            animation.duration = 0.07
                            animation.repeatCount = 4
                            animation.autoreverses = true
                            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.inputBGView.center.x - 10, y: self.inputBGView.center.y))
                            animation.toValue = NSValue(cgPoint: CGPoint(x: self.inputBGView.center.x + 10, y: self.inputBGView.center.y))
                            self.inputBGView.layer.add(animation, forKey: "position")
                        case 201: break
                            
                        default: break
                        }
                        
                        }
                    }
                    
                }
            }) 
            task.resume()
            
            
            
            
        }
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)

        

        // Do any additional setup after loading the view.
    }
    
    func textFieldDidChange(_ textField :UITextField) {
        if emailTextField.text != "" && passwordTextField.text != "" {
        submitButton.isEnabled = true
        } else {
        submitButton.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func keyboardWillShow(_ notification: Notification) {
        inputBGViewBottomContraint.constant = 350
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    func keyboardWillHide(_ notification: Notification) {
        inputBGViewBottomContraint.constant = 190
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) 
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
