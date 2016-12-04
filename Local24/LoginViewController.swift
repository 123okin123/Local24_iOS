//
//  LoginViewController.swift
//  Local24
//
//  Created by Local24 on 20/06/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import Alamofire

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
            view.endEditing(true)
            submitCredentials()
    }
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    
    func submitCredentials() {
        let credentials = emailTextField.text! + ":" + passwordTextField.text!
        let utf8credentials = credentials.data(using: String.Encoding.utf8)
        if let base64Encoded = utf8credentials?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        {
            Alamofire.request("https://cfw-api-11.azurewebsites.net/tokens/\(base64Encoded)", method: .post).validate().responseJSON (completionHandler: {response in
                switch response.result {
                case .success:
                    userToken = String(describing: response.result.value!)
                    tokenValid = true
                    if self.tabBarController?.selectedIndex == 3 {
                        self.performSegue(withIdentifier: "fromLoginToProfilSegueID", sender: nil)
                    }
                    if self.tabBarController?.selectedIndex == 2 {
                        self.performSegue(withIdentifier: "fromLoginToInsertSegueID", sender: nil)
                    }
                case .failure:
                    let animation = CABasicAnimation(keyPath: "position")
                    animation.duration = 0.07
                    animation.repeatCount = 4
                    animation.autoreverses = true
                    animation.fromValue = NSValue(cgPoint: CGPoint(x: self.inputBGView.center.x - 10, y: self.inputBGView.center.y))
                    animation.toValue = NSValue(cgPoint: CGPoint(x: self.inputBGView.center.x + 10, y: self.inputBGView.center.y))
                    self.inputBGView.layer.add(animation, forKey: "position")
                }
            })
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
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("loginvc viewWillAppear")
        print("token: \(userToken)")
        print("tokenValid: \(tokenValid)")
        navigationController?.setNavigationBarHidden(true, animated: false)
        if userToken != nil && tokenValid {
            if (tabBarController as! TabBarController).willSelectedIndex == 3 {
                performSegue(withIdentifier: "fromLoginToProfilSegueID", sender: nil)
            }
            if (tabBarController as! TabBarController).willSelectedIndex == 2 {
                performSegue(withIdentifier: "fromLoginToInsertSegueID", sender: nil)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
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



}
