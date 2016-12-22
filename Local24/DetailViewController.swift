//
//  DetailViewController.swift
//  Local24
//
//  Created by Local24 on 17/02/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    // MARK: Outlets & Variables

    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var reloadLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var urlToShow : URL!
    let webView = WKWebView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: screenwidth, height: screenheight)), configuration: WKWebViewConfiguration())
    let navAction = WKNavigationAction()
    let loaderView = UIView()
    
    
    @IBAction func reloadButtonPressed(_ sender: UIButton) {
        webView.reload()
    }
    
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure webView
    
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.frame.origin = CGPoint(x: 0, y: 0)
        webView.frame.size = CGSize(width: screenwidth, height: screenheight)
        webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 114, right: 0)
        webView.scrollView.showsVerticalScrollIndicator = false
        
        
        view.insertSubview(webView, at: 0)
        webView.allowsBackForwardNavigationGestures = false
        
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
        reloadLabel.isHidden = true

        
        let request = URLRequest(url: urlToShow)
        webView.load(request)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showMode(webView,view: self.view)
        gaUserTracking("Detail_Partneranzeige")
        self.navigationController?.hidesBarsOnSwipe = false
        if !(urlToShow.absoluteString.lowercased().contains("local24.de/detail/")) {
        self.title = "Partneranzeige"
    
        }
        if !Reachability.isConnectedToNetwork() {
            let alert = UIAlertController(title: "Keine Internetverbindung", message: "Sie scheinen nicht mit dem Internet verbunden zu sein.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        reloadButton.isHidden = true
        reloadLabel.isHidden = true
        self.loaderView.isHidden = false
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        let delay = 10.0 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            if !(self.loaderView.isHidden) {
                self.reloadButton.isHidden = false
                self.reloadLabel.isHidden = false
                self.reloadButton.alpha = 0
                self.reloadLabel.alpha = 0
                UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations:{ () -> Void in
                    self.reloadButton.alpha = 1
                    self.reloadLabel.alpha = 1
                    }, completion: { (finished: Bool) -> Void in
                        
                })
            }
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //print("didFinishNavigation with URL:\n \(webView.URL)\n\n")
        let url = webView.url?.absoluteString.lowercased()
        if url!.contains("local24.de/detail") {
        self.title = webView.title
        }
        
        
        

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
                print("error")
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
                self.reloadLabel.isHidden = true
            }
        })
        
        
        let absoluteString = webView.url?.absoluteString
        if absoluteString!.contains("local24.de/detail") {
            let js2 = "detailContent = document.getElementById('detailContent');" + "detailImageHolder = document.getElementById('detailImageHolder');" + "detailContent.insertBefore(detailImageHolder, detailContent.childNodes[0]);"
            self.webView.evaluateJavaScript(js2) { (_, error) in
                //print(error)
            }
        }

        // STAGE MODE
        showMode(webView,view: self.view)
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        switch message {
        case "Bitte geben Sie Ihren Namen an.":
            let alertController = UIAlertController(title: "Fehlende Angaben", message: "Bitte geben Sie Ihren Namen an.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                completionHandler()
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true) {}
            
        case "Bitte geben Sie Ihre E-Mail Adresse an":
            let alertController = UIAlertController(title: "Fehlende Angaben", message: "Bitte geben Sie Ihre E-Mail Adresse an.", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                completionHandler()
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true) {}
            
        case "Ihre Anfrage wurde verschickt":
            let alertController = UIAlertController(title: "Ihre Anfrage wurde verschickt.", message: nil, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                completionHandler()
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true) {}
            

            
        default:
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            completionHandler()
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true) {}
            
            
        }
        
    }
    
    
    
     func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        let urlString = (navigationAction.request as NSURLRequest).url?.absoluteString.lowercased()
       
        
        if navigationAction.navigationType.rawValue == 0 {
            if urlString!.contains("local24.de/detail") {
            webView.customUserAgent = "Local24iOSApp"
            decisionHandler(WKNavigationActionPolicy.allow)
            }
            if urlString!.contains("quoka") || urlString!.contains("kalaydo")  || urlString!.contains("autoscout24") || urlString!.contains("immobilienscout24") || urlString!.contains("germanpersonell") || urlString!.contains("local24") {
                webView.customUserAgent = nil
                if navigationAction.targetFrame == nil {
                    decisionHandler(WKNavigationActionPolicy.allow)
                    webView.load(navigationAction.request)
                    decisionHandler(WKNavigationActionPolicy.allow)
                }
                decisionHandler(WKNavigationActionPolicy.allow)
              
            } else {
            webView.customUserAgent = nil
            decisionHandler(WKNavigationActionPolicy.cancel)
            UIApplication.shared.openURL(navigationAction.request.url!)
            }
        } else {
            webView.customUserAgent = nil
        decisionHandler(WKNavigationActionPolicy.allow)
        }
            if urlString!.contains("tel:") {
                UIApplication.shared.openURL(navigationAction.request.url!)
                decisionHandler(WKNavigationActionPolicy.cancel)
            }
        
        
    }
    
    
    
    
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
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
