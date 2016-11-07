//
//  MoreViewController.swift
//  Local24
//
//  Created by Locla24 on 26/11/15.
//  Copyright © 2015 Nikolai Kratz. All rights reserved.
//

import UIKit
import WebKit





class MoreTableViewController: UITableViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    
    // MARK: Outlets & Variables
    
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
        let webView = WKWebView()
    let contentController = WKUserContentController()
    let config = WKWebViewConfiguration()
    var logoutPressed = false    
    var loginStatus = false

    
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buildString = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        let versionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let versionBuildString = "Version: \(versionString) (\(buildString))"
        versionLabel.text = versionBuildString
        

        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.frame.origin = CGPoint(x: 0, y: 0)
        webView.frame.size = CGSize(width: screenwidth, height: screenheight)
        webView.isHidden = true
        webView.scrollView.showsVerticalScrollIndicator = false
        
        config.userContentController = contentController
        
        contentController.add(
            self,
            name: "callbackHandler"
        )
        //view.insertSubview(webView, atIndex: 0)
        view.addSubview(webView)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("More")
        //if let url = NSURL(string: "https://cfw:Local24Teraone@stage.local24.de/ajax/loginstatus/") {
        if let url = URL(string: "https://www.local24.de/ajax/loginstatus/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            print("JavaScript is sending a message \(message.body)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        var numberOfRows = Int()
        switch section {
        case 0:
            numberOfRows = 6
        case 1:
            if loginStatus {
                
                numberOfRows = 1
                
            } else {
                
                    numberOfRows = 0
            
            }
        default: break
        }
        return numberOfRows
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAtIndexPath")
        // logout-login
        if (tableView.indexPathForSelectedRow as NSIndexPath?)?.section == 1 {
            if (tableView.indexPathForSelectedRow as NSIndexPath?)?.row == 0 {
                if let url = URL(string: "https://www.local24.de/mein-local24/?logout=logout") {
                    print("logging out")
                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    let oKAction = UIAlertAction(title: "Ausloggen", style: .destructive) { (action) in
                        let request = URLRequest(url: url)
                        self.webView.load(request)
                        self.logoutPressed = true
                    }
                    let cancleAction = UIAlertAction(title: "Abbrechen", style: .cancel) { (action) in
                        
                    }
                    alertController.addAction(oKAction)
                    alertController.addAction(cancleAction)
                    self.present(alertController, animated: true) {}
                    

                }

                
                
                
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finished with url: \(webView.url)")
        if logoutPressed {
            
            let accountVC = presentingViewController!.childViewControllers[3] as! AccountViewController
            let insertVC = presentingViewController!.childViewControllers[2] as! InsertViewController

            accountVC.dismiss(animated: true, completion: {
                if let url = URL(string: "https://www.local24.de/mein-local24/?logout=logout") {
                    let request = URLRequest(url: url)
                    accountVC.webView.load(request)
                }
                if let url = URL(string: "https://www.local24.de/anzeige-aufgeben/?logout=logout") {
                    let request = URLRequest(url: url)
                    insertVC.webView.load(request)
                }
                
                
                self.logoutPressed = false
            
            
            })

        }
    }
   

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let credential = URLCredential(user: "CFW", password: "Local24Teraone", persistence: .forSession)
        completionHandler(.useCredential, credential)
    }
    

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print("loginStatus\(message)")
        switch message {
        case "true":
        loginStatus = true
        tableView.reloadData()
        case "false":
        loginStatus = false
        tableView.reloadData()
        default: break
        
        }
    
        completionHandler()
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "showItem" {
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPath(for: cell)!
                if let dvc = segue.destination as? MoreViewController {
                        dvc.moreTag = (indexPath as NSIndexPath).row
                    print(dvc.moreTag)
                   
                }

            }
        }
        
                
    }
    

}





