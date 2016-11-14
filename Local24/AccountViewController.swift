//
//  AccountViewController.swift
//  Local24
//
//  Created by Locla24 on 26/11/15.
//  Copyright © 2015 Nikolai Kratz. All rights reserved.
//

import UIKit
import WebKit

class AccountViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    
    // MARK: Outlets & Variables
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var backButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var profilSegControl: UISegmentedControl!
    @IBOutlet weak var backButtonArrow: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var infoButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var reloadLable: UILabel!
    
    let webView = WKWebView()
    let loaderView = UIView()
    let nav = WKNavigation()
    let navAction = WKNavigationAction()
    var currentNavigationActionRequestURL : URL?
    
    // MARK: IBActions
    
    @IBAction func reloadButtonPressed(_ sender: UIButton) {
        webView.reload()
    }

    @IBAction func profileSegControlPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if let url = URL(string: "https://\(mode).local24.de/mein-local24/") {
            let request = URLRequest(url: url)
            webView.load(request)
            }
        case 1:
            if let url = URL(string: "https://\(mode).local24.de/mein-local24/meine-daten/") {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        default: break
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    // MARK: ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("Profil")
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
    override func viewDidLoad() {
        super.viewDidLoad()
        

            // configure webView
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.frame.origin = CGPoint(x: 0, y: 0)
            webView.frame.size = CGSize(width: screenwidth, height: screenheight)
            webView.backgroundColor = UIColor.groupTableViewBackground
            webView.scrollView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 50, right: 0)
            webView.scrollView.showsVerticalScrollIndicator = false
            webView.allowsBackForwardNavigationGestures = true
            webView.scrollView.backgroundColor = UIColor.groupTableViewBackground
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
        
        
        
        if let url = URL(string: "http://\(mode).local24.de/mein-local24/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
      }
 
    
    func addPullToRefreshToWebView(){
        let refreshController:UIRefreshControl = UIRefreshControl()
        
        refreshController.bounds = CGRect(x: 0, y: 40, width: refreshController.bounds.size.width, height: refreshController.bounds.size.height)
        refreshController.addTarget(self, action: #selector(AccountViewController.refreshWebView(_:)), for: UIControlEvents.valueChanged)
        webView.scrollView.insertSubview(refreshController, at: 0)
        
        
    }
    func refreshWebView(_ refresh:UIRefreshControl){
        webView.reload()
        refresh.endRefreshing()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url {
            if url.absoluteString.contains("meine-daten") {
                profilSegControl.selectedSegmentIndex = 1
            } else {
                profilSegControl.selectedSegmentIndex = 0
            }
        }
        let absoluteString = webView.url?.path
        if absoluteString! == "/mein-local24" || absoluteString! == "/mein-local24/meine-daten" || absoluteString! == "/registrieren" {
            adjustBackButton(true)
            adjustSegControl(false)
        } else {
            adjustSegControl(true)
            adjustBackButton(false)
        }
        print("didStartProvisionalNavigation with URL:\n \(webView.url)\n\n")
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

    }
    
    func adjustSegControl(_ hide: Bool) {
        if hide {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations:{ () -> Void in
                self.view.layoutIfNeeded()
                self.profilSegControl.alpha = 0
                self.infoButton.tintColor = UIColor.clear
                }, completion: { (finished: Bool) -> Void in
                    self.profilSegControl.isHidden = true
                    self.infoButton.isEnabled = false
            })
        } else {
            self.profilSegControl.isHidden = false
            self.infoButton.isEnabled = true
            UIView.animate(withDuration: 0.3, delay: 0.5, options: UIViewAnimationOptions.curveEaseIn, animations:{ () -> Void in
                self.view.layoutIfNeeded()
                self.profilSegControl.alpha = 1
                self.infoButton.tintColor = UIColor.white
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

    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
print(webView.customUserAgent)
        if let url = webView.url {
            if url.absoluteString.contains("anzeige-aufgeben/fertig") {
                let insertButton = "var insertDonebutton = document.createElement('a');" +
                "insertDonebutton.href = 'http://\(mode).local24.de/mein-local24/';" +
                "insertDonebutton.className = 'button button-large button-secondary insertion_success_back';" +
                "var node = document.createTextNode('Zurück zu meinen Anzeigen');" +
                "insertDonebutton.appendChild(node);" +
                "var element = document.getElementById('insertion_success_container');" +
                "element.appendChild(insertDonebutton);"
                self.webView.evaluateJavaScript(insertButton, completionHandler: nil)
            }
        }
        
        if let url = webView.url {
            if url.absoluteString.contains("local24.de/registrieren") {
                let regDoneButton = "var regDonebutton = document.createElement('a');" +
                    "regDonebutton.href = 'http://\(mode).local24.de/mein-local24/';" +
                    "regDonebutton.className = 'button button-large button-secondary insertion_success_back';" +
                    "var node = document.createTextNode('Zurück zu meinen Anzeigen');" +
                    "regDonebutton.appendChild(node);" +
                    "var loginContent = document.getElementById('registerPage);" +
                "loginContent.appendChild(regDonebutton);"
                self.webView.evaluateJavaScript(regDoneButton, completionHandler: nil)
            }
        }
        
        
        let moveCancleButton = "navmenu = document.getElementsByClassName('buttonList');" +
            "navset = document.getElementById('search_setNavigators');" +
            "newchild = document.getElementsByClassName('mobile-edit-button');" +
            "navmenu.insertBefore(newchild,navset);" +
            "sortheader = document.createElement('div');" +
            "sortheader.innerHTML = '<h4>Sortierung</h4>';" +
            "sortheader.id = 'search_sortHeadline';" +
        "navmenu.insertBefore(sortheader,newchild);"
        self.webView.evaluateJavaScript(moveCancleButton, completionHandler:  nil)

        
        let loadMeta = "var meta = document.createElement('meta'); meta.name = 'viewport'; meta.content = 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0'; document.getElementsByTagName('head')[0].appendChild(meta);"
        self.webView.evaluateJavaScript(loadMeta, completionHandler: nil)
  
        if backButton.isHidden {
        webView.allowsBackForwardNavigationGestures = false
        } else {
        webView.allowsBackForwardNavigationGestures = true
        }
        
        if let urlString = webView.url?.absoluteString {
            if urlString.contains("anzeige-aufgeben/fertig") {
                adjustBackButton(true)
                navBar.title = "Fertig"
            } else {
                navBar.title = ""
            }
            
        }
     
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
        
        let urlString = (navigationAction.request as NSURLRequest).url?.absoluteString.lowercased()
        
        if navigationAction.navigationType.rawValue == 0 {
            if urlString!.contains("mein-local") || urlString!.contains("registrieren") || urlString!.contains("detail") {
                if urlString!.contains("detail") {
                decisionHandler(WKNavigationActionPolicy.cancel)
                currentNavigationActionRequestURL = navigationAction.request.url!
                performSegue(withIdentifier: "AccountshowLocalDetailSegueID", sender: self)
                } else {
                decisionHandler(WKNavigationActionPolicy.allow)
                }
                
            } else {
                webView.customUserAgent = nil
                decisionHandler(WKNavigationActionPolicy.cancel)
                UIApplication.shared.openURL(navigationAction.request.url!)
            }
        } else {
           
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
    
    

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print("runJavaScriptConfirmPanelWithMessage")
        let alertController = UIAlertController(title: "Anzeige Löschen", message: "Möchten Sie diese Anzeige wirklich löschen?", preferredStyle: .alert)
        let oKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            completionHandler(true)
        }
        let cancleAction = UIAlertAction(title: "Abbrechen", style: .cancel) { (action) in
            completionHandler(false)
        }
        alertController.addAction(oKAction)
        alertController.addAction(cancleAction)
        self.present(alertController, animated: true) {}
    }


    

    
    // MARK: - Navigation
    
    
    @IBAction func backfromMore(_ segue:UIStoryboardSegue) {
    }
    

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AccountshowLocalDetailSegueID" {
            if let navVC = segue.destination as? UINavigationController {
                if let localdetailVC = navVC.viewControllers[0] as? LocalDetailTableViewController {
                    localdetailVC.urlToShow = currentNavigationActionRequestURL
                    
                }
            }

        }
    }
    

}
