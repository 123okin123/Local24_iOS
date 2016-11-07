//
//  InsertViewController.swift
//  Local24
//
//  Created by Locla24 on 26/11/15.
//  Copyright © 2015 Nikolai Kratz. All rights reserved.
//

import UIKit
import WebKit

class InsertViewController: UIViewController, WKNavigationDelegate, WKUIDelegate  {

    
    // MARK: Outlets & Variables
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backButtonArrow: UIButton!
    @IBOutlet weak var backButtonLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var reloadLable: UILabel!
    
    var webView = WKWebView()
    let loaderView = UIView()
    let nav = WKNavigation()
    let navAction = WKNavigationAction()
    
    @IBAction func reloadButtonPressed(_ sender: UIButton) {
        webView.reload()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "http://\(mode).local24.de/anzeige-aufgeben") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "http://\(mode).local24.de/anzeige-aufgeben") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: "http://\(mode).local24.de/anzeige-aufgeben") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        // configure webView
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.frame.origin = CGPoint(x: 0, y: 0)
        webView.frame.size = CGSize(width: screenwidth, height: screenheight)
        webView.backgroundColor = UIColor.groupTableViewBackground
        webView.scrollView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 50, right: 0)
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.allowsBackForwardNavigationGestures = true
        view.insertSubview(webView, at: 0)
        
        // configure and hide loading views
        loaderView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: webView.frame.size.width, height: webView.frame.size.height))
        loaderView.backgroundColor = UIColor.groupTableViewBackground
        webView.addSubview(loaderView)
        activityIndicator.isHidden = true
        
        loaderView.isHidden = true
        let bluecolor = UIColor(red: 0, green: 90/255, blue: 144/255, alpha: 0.9)
        reloadButton.layer.borderColor = bluecolor.cgColor
        reloadButton.layer.borderWidth = 1
        reloadButton.layer.cornerRadius = 5.0
        reloadButton.isHidden = true
        reloadLable.isHidden = true
        addPullToRefreshToWebView()
    
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("Insert")
        showMode(webView,view: self.view)
        if !Reachability.isConnectedToNetwork() {
            let alert = UIAlertController(title: "Keine Internetverbindung", message: "Sie scheinen nicht mit dem Internet verbunden zu sein.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        if let urlString = webView.url?.absoluteString {
            if urlString.contains("catid") || urlString.contains("anzeige-bearbeiten") {
                
            } else {
                webView.reload()
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        reloadButton.isHidden = true
        reloadLable.isHidden = true
        self.loaderView.isHidden = false
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        let delay = 10.0 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            if !(self.loaderView.isHidden) {
                self.reloadButton.isHidden = false
                self.reloadLable.isHidden = false
                self.reloadButton.alpha = 0
                self.reloadLable.alpha = 0
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations:{ () -> Void in
                    self.reloadButton.alpha = 1
                    self.reloadLable.alpha = 1
                    }, completion: { (finished: Bool) -> Void in
                        
                })
            }
        }

        if let absoluteString = webView.url?.absoluteString {
            if absoluteString.contains("catid") || absoluteString.contains("agb") || absoluteString.contains("passwort-vergessen") || absoluteString.contains("registrieren") {
                adjustBackButton(false)
            } else {
                adjustBackButton(true)
            }
            if absoluteString.contains("registrieren") {
                let tracker = GAI.sharedInstance().defaultTracker
                let eventTracker: NSObject = GAIDictionaryBuilder.createEvent(
                    withCategory: "Registration",
                    action: "registrationStart",
                    label: "registration",
                    value: nil).build()
                tracker?.send(eventTracker as! [AnyHashable: Any])
            }
        }


    }

     func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){

        let loadMeta = "var meta = document.createElement('meta'); meta.name = 'viewport'; meta.content = 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0'; document.getElementsByTagName('head')[0].appendChild(meta);"
        self.webView.evaluateJavaScript(loadMeta, completionHandler: nil)
        
        var loadStylesString = ""
        if localCSS {
            if let path = Bundle.main.path(forResource: "iosApp", ofType: "css") {
                do {
                    var content = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                    content = content.replacingOccurrences(of: "\n", with: "")
                    loadStylesString = "var css = '" + content + "', head = document.head || document.getElementsByTagName('head')[0],style = document.createElement('style');style.type = 'text/css';if (style.styleSheet){style.styleSheet.cssText = css;}else{style.appendChild(document.createTextNode(css));}head.appendChild(style);"
                } catch  {
                    //print("error")
                }
            }
        } else {
            loadStylesString = "var script = document.createElement('link'); script.type = 'text/css'; script.rel = 'stylesheet'; script.media = 'all' ; script.href = 'https://\(mode).local24.de/assets/css/iosApp.css'; document.getElementsByTagName('head')[0].appendChild(script);"
            
            
        }
        self.webView.evaluateJavaScript(loadStylesString, completionHandler:{ (_, _) -> Void in
            // css Javascript Evaluation Complete
            let delay = 1.0 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time) {
                // hide loader Views
                self.loaderView.isHidden = true
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                
                self.reloadButton.isHidden = true
                self.reloadLable.isHidden = true
            }
        })
        
        // STAGE MODE
        showMode(webView,view: self.view)


        if backButton.isHidden {
            webView.allowsBackForwardNavigationGestures = false
        } else {
            webView.allowsBackForwardNavigationGestures = true
        }

        if let urlString = webView.url?.absoluteString {
            if urlString.contains("local24.de/anzeige-aufgeben/fertig") {
                adjustDoneButton(false)
                
                let tracker = GAI.sharedInstance().defaultTracker
                let eventTracker: NSObject = GAIDictionaryBuilder.createEvent(
                    withCategory: "Insertion",
                    action: "insertion",
                    label: "insertion",
                    value: nil).build()
                tracker?.send(eventTracker as! [AnyHashable: Any])
 
            }
            else {
                adjustDoneButton(true)
            }
        }
    }
    
    
    func adjustDoneButton(_ hide: Bool) {
        if hide {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations:{ () -> Void in
                self.doneButton.alpha = 0
                self.view.layoutIfNeeded()
                }, completion: { (finished: Bool) -> Void in
                    self.doneButton.isHidden = true
            })
            
        } else {
            doneButton.isHidden = false
            doneButton.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations:{ () -> Void in
                self.view.layoutIfNeeded()
                self.doneButton.alpha = 1
                }, completion: { (finished: Bool) -> Void in
            })
        }
        
    }
    
    
    func adjustBackButton(_ hide: Bool) {
        if hide {
            self.backButtonLeadingConstraint.constant = 20
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations:{ () -> Void in
                self.view.layoutIfNeeded()
                self.backButton.alpha = 0
                self.backButtonArrow.alpha = 0
                }, completion: { (finished: Bool) -> Void in
                    self.backButton.isHidden = true
                    self.backButtonArrow.isHidden = true
            })
            
        } else {
            self.backButtonLeadingConstraint.constant = -13
            self.backButton.isHidden = false
            self.backButtonArrow.isHidden = false
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations:{ () -> Void in
                self.view.layoutIfNeeded()
                self.backButton.alpha = 1
                self.backButtonArrow.alpha = 1
                }, completion: { (finished: Bool) -> Void in
            })
        }
        
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
 
        
        let urlString = (navigationAction.request as NSURLRequest).url?.absoluteString.lowercased()
        
        if navigationAction.navigationType.rawValue == 0 {
            if urlString!.contains("catid") || urlString!.contains("passwort-vergessen") || urlString!.contains("registrieren") {
                decisionHandler(WKNavigationActionPolicy.allow)
            } else {
                webView.customUserAgent = nil
                decisionHandler(WKNavigationActionPolicy.cancel)
                UIApplication.shared.openURL(navigationAction.request.url!)
            }
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
        
    }

    
    
    
    func addPullToRefreshToWebView(){
        let refreshController:UIRefreshControl = UIRefreshControl()
        
        refreshController.bounds = CGRect(x: 0, y: 40, width: refreshController.bounds.size.width, height: refreshController.bounds.size.height)
        refreshController.addTarget(self, action: #selector(self.refreshWebView(_:)), for: UIControlEvents.valueChanged)
        webView.scrollView.insertSubview(refreshController, at: 0)
    }
    func refreshWebView(_ refresh:UIRefreshControl){
        webView.reload()
        refresh.endRefreshing()
    }
    
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        //print("didReceiveAuthenticationChallenge")
        
        let credential = URLCredential(user: "CFW", password: "Local24Teraone", persistence: .forSession)
        completionHandler(.useCredential, credential)
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
