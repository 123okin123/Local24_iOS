//
//  ImprintViewController.swift
//  Local24
//
//  Created by Locla24 on 26/11/15.
//  Copyright © 2015 Nikolai Kratz. All rights reserved.
//

import UIKit
import WebKit

class MoreViewController: UIViewController, WKNavigationDelegate {

    
    
    // MARK: - Outlets & Variables


    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadLable: UILabel!
    @IBOutlet weak var reloadButton: UIButton! {didSet {
        reloadButton.layer.borderColor = bluecolor.cgColor
        reloadButton.layer.borderWidth = 1
        reloadButton.layer.cornerRadius = 5.0
        reloadButton.isHidden = true
        }}
    
    let webView = WKWebView()
    let loaderView = UIView()
    var moreTag = 1
    let screenwidth = UIScreen.main.bounds.size.width
    let screenheight = UIScreen.main.bounds.size.height
    
    
    
    
    
    @IBAction func reloadButtonPressed(_ sender: UIButton) {
        webView.reload()
    }
    
    
    
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // set the delegate
        webView.navigationDelegate = self
        
       
        
        
        // configure webView
        webView.frame.origin = CGPoint(x: 0, y: 0)
        webView.frame.size = CGSize(width: view.frame.size.width, height: view.frame.size.height - 64)
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        view.insertSubview(webView, at: 0)
        let previousVC = navigationController!.viewControllers[navigationController!.viewControllers.endIndex - 2]
        if previousVC is RegisterViewController {
        webView.frame.size.width -= 20
        }
        
        // configure and hide loading views
        loaderView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: webView.frame.size.width, height: webView.frame.size.height))
        loaderView.backgroundColor = UIColor.white
        webView.addSubview(loaderView)

        
   
        loaderView.isHidden = true
        
       
        switch moreTag {
        case 0:
            if let url = URL(string: "https://www.local24.de/kleinanzeigensuche/impressum/") {
                let request = URLRequest(url: url)
                webView.load(request)
            }
            navigationItem.title = "Impressum"
        case 1:
            if let url = URL(string: "https://www.local24.de/kleinanzeigensuche/kontakt/") {
                let request = URLRequest(url: url)
                webView.load(request)
            }
            navigationItem.title = "Kontakt"
        case 2:
            if let url = URL(string: "https://www.local24.de/kleinanzeigensuche/ueberuns/") {
                let request = URLRequest(url: url)
                webView.load(request)
            }
            navigationItem.title = "Über uns"
        case 3:
            if let url = URL(string: "https://www.local24.de/kleinanzeigensuche/hilfe/") {
                let request = URLRequest(url: url)
                webView.load(request)
            }
            navigationItem.title = "Hilfe"
        case 4:
            if let url = URL(string: "https://www.local24.de/kleinanzeigensuche/datenschutz/") {
                let request = URLRequest(url: url)
                webView.load(request)
            }
            navigationItem.title = "Datenschutz"
        case 5:
            if let url = URL(string: "https://www.local24.de/kleinanzeigensuche/agb/") {
                let request = URLRequest(url: url)
                webView.load(request)
            }
            navigationItem.title = "AGB"

            
        default: break
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch moreTag {
        case 0:
            gaUserTracking("More/Imprint")
        case 1:
            gaUserTracking("More/Contact")
        case 2:
            gaUserTracking("More/About")
        case 3:
            gaUserTracking("More/Help")
        case 4:
            gaUserTracking("More/PrivacyPolicy")
        case 5:
            gaUserTracking("More/TermsAndConditions")
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation")
        self.loaderView.isHidden = false
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        reloadButton.isHidden = true
        reloadLable.isHidden = true
        let delay = 8.0 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            if !(self.loaderView.isHidden) {
                print("takes to long")
                self.reloadButton.isHidden = false
                self.reloadLable.isHidden = false
            }
        }
    }
    
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let loadMeta = "var meta = document.createElement('meta'); meta.name = 'viewport'; meta.content = 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0'; document.getElementsByTagName('head')[0].appendChild(meta);"
        self.webView.evaluateJavaScript(loadMeta, completionHandler: nil)
        
       
        var loadStylesString = ""
        if localCSS {
            if let path = Bundle.main.path(forResource: "iosApp", ofType: "css") {
                do {
                    var content = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                    content = content.replacingOccurrences(of: "\n", with: "")
                    loadStylesString = "var css = '" + content + "', head = document.head || document.getElementsByTagName('head')[0],style = document.createElement('style');style.type = 'text/css';if (style.styleSheet){style.styleSheet.cssText = css;}else{style.appendChild(document.createTextNode(css));}head.appendChild(style);"
                } catch _ as NSError {
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
    }

    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
         if navigationAction.navigationType.rawValue == 0 {
            print("1")
            if moreTag != 1 {
                print("2")
        decisionHandler(WKNavigationActionPolicy.cancel)
        UIApplication.shared.openURL(navigationAction.request.url!)
            } else {
                print("3")
            decisionHandler(WKNavigationActionPolicy.allow)
            }
         } else {
        decisionHandler(WKNavigationActionPolicy.allow)
        print("4")
        }
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            completionHandler()
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true) {}
        
        
    }
    
}
