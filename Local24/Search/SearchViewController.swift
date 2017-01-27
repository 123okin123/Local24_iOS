//
//  HomeViewController.swift
//  Local24
//
//  Created by Locla24 on 26/11/15.
//  Copyright © 2015 Nikolai Kratz. All rights reserved.
//

import UIKit
import WebKit
import NVActivityIndicatorView
/*
class SearchViewController: UIViewController, UISearchBarDelegate, UIScrollViewDelegate, WKNavigationDelegate, WKUIDelegate {
    
    // MARK: Outlets & Variables
    
    @IBOutlet weak var selectedfiltersBGView: UIView! {didSet {
        selectedfiltersBGView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        selectedfiltersBGView.layer.borderWidth = 1
        }}
    @IBOutlet weak var selectedfiltersScrollView: UIScrollView!
    var searchBar = UISearchBar()
    func configureSearchBar() {
        searchBar.delegate = self
        
        // searchBar.setImage(UIImage(named: "lupe"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
        let searchTextField: UITextField? = searchBar.value(forKey: "searchField") as? UITextField
        if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
            let font = UIFont(name: "OpenSans", size: 13.0)
            let attributeDict = [
                NSFontAttributeName: font!,
                NSForegroundColorAttributeName: UIColor.lightGray
            ]
            searchTextField!.attributedPlaceholder = NSAttributedString(string: "Was suchen Sie?", attributes: attributeDict)
        }
        searchBar.tintColor = UIColor.darkGray
        searchTextField?.textColor = UIColor.darkGray
        searchBar.setBackgroundImage(
            UIImage(),
            for: .any,
            barMetrics: .default)
        }
    

    @IBOutlet weak var reloadButton: UIButton! {didSet {
        reloadButton.layer.cornerRadius = 5.0
        reloadButton.isHidden = true
        }}
    @IBOutlet weak var reloadLable: UILabel! {didSet {
        reloadLable.isHidden = true
        }}
    
    var indicator = NVActivityIndicatorView(frame: CGRect(x: screenwidth/2 - 25, y: screenheight/2 - 80, width: 50, height: 50))

    var currentNavigationActionRequestURL :URL!
    var webView = WKWebView()
    var loaderView =  UIView()
    var nav = WKNavigation()
    var navAction = WKNavigationAction()
    
    

    var filter = (UIApplication.shared.delegate as! AppDelegate).filter
    var categories = Categories()
    let selectedfilterStackView = UIStackView()

    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            print("filter \(keyPath!) changed from \(change![NSKeyValueChangeKey.oldKey]) to \(change![NSKeyValueChangeKey.newKey])")
            if let url = URL(string: filter.urlFromfilters()) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
        
    }
    
    
    func updatefilterButtons() {
        if selectedfilterStackView.arrangedSubviews.count > 0 {
        for buttonToRemove in selectedfilterStackView.arrangedSubviews {
        buttonToRemove.removeFromSuperview()
        }
        }
        selectedfilterStackView.frame.size = CGSize(width: 0, height: 44)
        selectedfiltersScrollView.contentSize = CGSize(width: 0, height: 44)
        if filter.searchLocationString != "" {
            let selectedfilterButton = SelectedfilterButton()
            var titleOfButton = "\(filter.searchLocationString) (\(filter.searchRadius) km)"
            if filter.searchLocationString == "Deutschland" {
            titleOfButton = "Deutschland"
            }
            selectedfilterButton.filterName = "searchLocationString"
            selectedfilterButton.removeable = false
            selectedfilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedfilterStackView.addArrangedSubview(selectedfilterButton)
            selectedfilterButton.sizeToFit()
            selectedfilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedfilterButton.backgroundColor = UIColor.white
            selectedfilterButton.clipsToBounds = true
            selectedfilterStackView.frame.size.width += selectedfilterButton.frame.width
        }
        if filter.minPrice != "" {
            let selectedfilterButton = SelectedfilterButton()
            let titleOfButton = "Preis von: \(filter.minPrice) €"
            selectedfilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedfilterButton.filterName = "minPrice"
            selectedfilterStackView.addArrangedSubview(selectedfilterButton)
            selectedfilterButton.sizeToFit()
            selectedfilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedfilterButton.backgroundColor = UIColor.white
            selectedfilterButton.clipsToBounds = true
            selectedfilterStackView.frame.size.width += selectedfilterButton.frame.width
            selectedfilterStackView.frame.size.width += 10
        }
        if filter.maxPrice != "" {
            let selectedfilterButton = SelectedfilterButton()
            let titleOfButton = "Preis bis: \(filter.maxPrice) €"
            selectedfilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedfilterButton.filterName = "maxPrice"
            selectedfilterStackView.addArrangedSubview(selectedfilterButton)
            selectedfilterButton.sizeToFit()
            selectedfilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedfilterButton.backgroundColor = UIColor.white
            selectedfilterButton.clipsToBounds = true
            selectedfilterStackView.frame.size.width += selectedfilterButton.frame.width
            selectedfilterStackView.frame.size.width += 10
        }
        if filter.searchString != "" {
            let selectedfilterButton = SelectedfilterButton()
            let titleOfButton = "\u{0022}\(filter.searchString)\u{0022}"
            selectedfilterButton.filterName = "searchString"
            selectedfilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedfilterStackView.addArrangedSubview(selectedfilterButton)
            selectedfilterButton.sizeToFit()
            selectedfilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedfilterButton.backgroundColor = UIColor.white
            selectedfilterButton.clipsToBounds = true
            selectedfilterStackView.frame.size.width += selectedfilterButton.frame.width
            selectedfilterStackView.frame.size.width += 10
        }
        if filter.mainCategoryID != 99 {
            let selectedfilterButton = SelectedfilterButton()
            let titleOfButton = "Hauptkategorie: \(categories.mainCatsStrings[filter.mainCategoryID])"
            selectedfilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedfilterButton.filterName = "mainCategoryID"
            selectedfilterStackView.addArrangedSubview(selectedfilterButton)
            selectedfilterButton.sizeToFit()
            selectedfilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedfilterButton.backgroundColor = UIColor.white
            selectedfilterButton.clipsToBounds = true
            selectedfilterStackView.frame.size.width += selectedfilterButton.frame.width
            selectedfilterStackView.frame.size.width += 10
        }
        if filter.subCategoryID != 99 {
            let selectedfilterButton = SelectedfilterButton()
            let titleOfButton = "Unterkategorie: \(categories.cats[filter.mainCategoryID][filter.subCategoryID])"
            selectedfilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedfilterButton.filterName = "subCategoryID"
            selectedfilterStackView.addArrangedSubview(selectedfilterButton)
            selectedfilterButton.sizeToFit()
            selectedfilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedfilterButton.backgroundColor = UIColor.white
            selectedfilterButton.clipsToBounds = true
            selectedfilterStackView.frame.size.width += selectedfilterButton.frame.width
            selectedfilterStackView.frame.size.width += 10
        }
        if filter.mainCategoryID == 0 && filter.subCategoryID == 1 {
        if filter.minMileAge != 0 {
            let selectedfilterButton = SelectedfilterButton()
            let titleOfButton = "Laufleistung von: \(filter.minMileAge) km"
            selectedfilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedfilterButton.filterName = "minMileAge"
            selectedfilterStackView.addArrangedSubview(selectedfilterButton)
            selectedfilterButton.sizeToFit()
            selectedfilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedfilterButton.backgroundColor = UIColor.white
            selectedfilterButton.clipsToBounds = true
            selectedfilterStackView.frame.size.width += selectedfilterButton.frame.width
            selectedfilterStackView.frame.size.width += 10
        }
        if filter.maxMileAge != 500000 {
            let selectedfilterButton = SelectedfilterButton()
            let titleOfButton = "Laufleistung bis: \(filter.maxMileAge) km"
            selectedfilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedfilterButton.filterName = "maxMileAge"
            selectedfilterStackView.addArrangedSubview(selectedfilterButton)
            selectedfilterButton.sizeToFit()
            selectedfilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedfilterButton.backgroundColor = UIColor.white
            selectedfilterButton.clipsToBounds = true
            selectedfilterStackView.frame.size.width += selectedfilterButton.frame.width
            selectedfilterStackView.frame.size.width += 10
        }
        }
        
        selectedfiltersScrollView.contentSize = selectedfilterStackView.frame.size

        

  
        
    }
    
    func filterButtonPressed(_ sender: SelectedfilterButton) {
        switch sender.filterName {
            case "minPrice": filter.minPrice = ""
            case "maxPrice": filter.maxPrice = ""
            case "searchString": filter.searchString = ""
            case "searchLocationString":
            performSegue(withIdentifier: "segueFromSearchToLocationID", sender: self)
            case "mainCategoryID":
                filter.mainCategoryID = 99
                filter.subCategoryID = 99
            case "subCategoryID":
                filter.subCategoryID = 99
            case "minMileAge":
                filter.minMileAge = 0
        case "maxMileAge":
            filter.maxMileAge = 500000
        default: break
        }
        updatefilterButtons()
    }
    

    func startObservingfilter() {
        filter.addObserver(self, forKeyPath: "subCategoryID", options: .new, context: &myContext)
        filter.addObserver(self, forKeyPath: "mainCategoryID", options: .new, context: &myContext)
        filter.addObserver(self, forKeyPath: "searchString", options: .new, context: &myContext)
        filter.addObserver(self, forKeyPath: "minPrice", options: .new, context: &myContext)
        filter.addObserver(self, forKeyPath: "maxPrice", options: .new, context: &myContext)
        filter.addObserver(self, forKeyPath: "searchLong", options: .new, context: &myContext)
        filter.addObserver(self, forKeyPath: "searchLat", options: .new, context: &myContext)
        filter.addObserver(self, forKeyPath: "searchRadius", options: .new, context: &myContext)
        filter.addObserver(self, forKeyPath: "sortingChanged", options: .new, context: &myContext)
        filter.addObserver(self, forKeyPath: "onlyLocalListings", options: .new, context: &myContext)
        filter.addObserver(self, forKeyPath: "minMileAge", options: .new, context: &myContext)
        filter.addObserver(self, forKeyPath: "maxMileAge", options: .new, context: &myContext)
    }

    
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = self.searchBar
        configureSearchBar()
        
        startObservingfilter()
        
        selectedfilterStackView.frame.origin = CGPoint(x: 0, y: 0)
        selectedfilterStackView.frame.size = CGSize(width: 0, height: 44)
        selectedfilterStackView.alignment = .center
        selectedfilterStackView.spacing = 8
        selectedfilterStackView.distribution = .fillProportionally
        selectedfiltersScrollView.addSubview(selectedfilterStackView)
        selectedfiltersScrollView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        selectedfiltersScrollView.scrollsToTop = false
        
        indicator.color = greencolor
        indicator.type = .ballPulse
        

        // configure webView
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.frame.origin = CGPoint(x: 0, y: 0)
        webView.frame.size = CGSize(width: screenwidth, height: screenheight)
        view.backgroundColor = UIColor.groupTableViewBackground
        webView.backgroundColor = UIColor.groupTableViewBackground
        webView.scrollView.backgroundColor = UIColor.groupTableViewBackground
        webView.scrollView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 114, right: 0)
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.scrollsToTop = true
        webView.scrollView.delegate = self
        webView.scrollView.bounces = true
        webView.configuration.suppressesIncrementalRendering = true
        view.insertSubview(webView, at: 0)
        
        loaderView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: webView.frame.size.width, height: webView.frame.size.height))
        loaderView.backgroundColor = UIColor.groupTableViewBackground
        webView.addSubview(loaderView)
        loaderView.isHidden = true
        addPullToRefreshToWebView()
        
        if let url = URL(string: filter.urlFromfilters()) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func addPullToRefreshToWebView(){
        let refreshController:UIRefreshControl = UIRefreshControl()
        refreshController.bounds = CGRect(x: 0, y: 30, width: refreshController.bounds.size.width, height: refreshController.bounds.size.height)
        refreshController.addTarget(self, action: #selector(SearchViewController.refreshWebView(_:)), for: UIControlEvents.valueChanged)
        webView.scrollView.insertSubview(refreshController, at: 0)
    }
    
    func refreshWebView(_ refresh:UIRefreshControl){
        webView.reload()
        refresh.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatefilterButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    


    
    // MARK: SearchBar
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        filter.searchString = searchBar.text!
        searchBar.text = ""
        if let url = URL(string: filter.urlFromfilters()) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        updatefilterButtons()

            let tracker = GAI.sharedInstance().defaultTracker
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Search", action: "searchInListings", label: filter.searchString, value: 0).build() as NSDictionary as! [AnyHashable: Any])
        
 
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    
    

    
    // MARK: WebView

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        reloadButton.isHidden = true
        reloadLable.isHidden = true
        self.loaderView.isHidden = false
        self.view.addSubview(indicator)
        indicator.startAnimating()
        
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
         print("webViewURL:\(webView.url!.absoluteString)")
        if filter.mainCategoryID != 99 {
        gaUserTracking("Search/\(filter.categories.mainCatsStrings[filter.mainCategoryID])")
        } else {
        gaUserTracking("Search/AlleAnzeigen")
        }
        
        let loadMeta = "var meta = document.createElement('meta'); meta.name = 'viewport'; meta.content = 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0'; document.getElementsByTagName('head')[0].appendChild(meta); var local24shopping24 = document.getElementById('shopping_24').parentElement; local24shopping24.style.display = 'none';"
        self.webView.evaluateJavaScript(loadMeta, completionHandler: nil)

        var loadStylesString = ""
        if localCSS {
            if let path = Bundle.main.path(forResource: "iosApp", ofType: "css") {
                var content: String
                do {
                    content = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                } catch {
                    content = ""
                }
                    content = content.replacingOccurrences(of: "\n", with: "")
                    loadStylesString = "var css = '" + content + "', head = document.head || document.getElementsByTagName('head')[0],style = document.createElement('style');style.type = 'text/css';if (style.styleSheet){style.styleSheet.cssText = css;}else{style.appendChild(document.createTextNode(css));}head.appendChild(style);"

            }
        } else {
            loadStylesString = "var script = document.createElement('link'); script.type = 'text/css'; script.rel = 'stylesheet'; script.media = 'all' ; script.href = 'https://\(mode).local24.de/assets/css/iosApp.css'; document.getElementsByTagName('head')[0].appendChild(script);"
        }
        self.webView.evaluateJavaScript(loadStylesString, completionHandler:{ (_, _) -> Void in
            // css Javascript Evaluation Complete
            let delay = 1.5 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time) {
                // hide loader Views
                self.loaderView.isHidden = true
                self.webView.scrollView.setContentOffset(CGPoint(x: 0,y: -40), animated: false)
                self.indicator.stopAnimating()
                self.indicator.removeFromSuperview()
                self.reloadButton.isHidden = true
                self.reloadLable.isHidden = true
            }
        })
    
        
        // STAGE MODE
        showMode(webView,view: self.view)

    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        var navigationString = ""
        var ads = false
        var local = false
        var localHomepage = false
        var localDetails = false
        var otherlocalDetails = false
        var kalaydo = false
        var quoka = false
        var immo = false
        var auto = false
        var germanp = false
        
        if let url = navigationAction.request.url {
            if url.absoluteString.lowercased().contains("tpc.googlesyndication.com") ||
                url.absoluteString.lowercased().contains(".g.doubleclick.net") ||
                url.absoluteString.lowercased().contains("www.google.com/pagead") ||
                url.absoluteString.lowercased().contains("about:blank") {
                    ads = true
                navigationString = "ads"
            }
        
            if url.absoluteString.lowercased().contains("local24") {
                local = true
                navigationString = "local"
            }
            if url.absoluteString == "https://www.local24.de/" {
                localHomepage = true
            }
            if url.absoluteString.lowercased().contains("local24.de/detail") {
                
               let lastpathComp = url.pathComponents.last
                if lastpathComp!.contains("mps") {
                 localDetails = true
                } else {
                otherlocalDetails = true
                }
            }
            if url.absoluteString.lowercased().contains("kalaydo") {
                kalaydo = true
                navigationString = "Kalaydo"
            }
            if url.absoluteString.lowercased().contains("quoka") {
                quoka = true
                navigationString = "Quoka"
            }
            if url.absoluteString.lowercased().contains("immobilienscout24") {
                immo = true
                navigationString = "IS24"
            }
            if url.absoluteString.lowercased().contains("autoscout24.de") {
                auto = true
                navigationString = "AS24"
            }
            if  url.absoluteString.lowercased().contains("germanpersonnel") {
                germanp = true
                navigationString = "Germanpersonnel"
            }
        }
        if ads || local || kalaydo || quoka || immo || auto || germanp {
            
            
            if ads {
                if navigationAction.navigationType.rawValue == 0 {
                    decisionHandler(WKNavigationActionPolicy.cancel)
                    UIApplication.shared.openURL(navigationAction.request.url!)
                } else {
                    decisionHandler(WKNavigationActionPolicy.allow)
                }
            }
            
            if local {
                if localDetails || otherlocalDetails || localHomepage {

                    if otherlocalDetails {
                        decisionHandler(WKNavigationActionPolicy.cancel)
                        currentNavigationActionRequestURL = navigationAction.request.url!
                        performSegue(withIdentifier: "showDetailSegueID", sender: self)
                    } else if localDetails {
                    decisionHandler(WKNavigationActionPolicy.cancel)
                    currentNavigationActionRequestURL = navigationAction.request.url!
                    performSegue(withIdentifier: "showLocalDetailSegueID", sender: self)
                    } else {
                    decisionHandler(WKNavigationActionPolicy.cancel)
                    }
                    
                } else {
                    decisionHandler(WKNavigationActionPolicy.allow)
                }
                
            }
            
            
            
            if kalaydo || quoka || immo || auto || germanp {
                decisionHandler(WKNavigationActionPolicy.cancel)
                let tracker = GAI.sharedInstance().defaultTracker
                var trackerActionString = "clickout_in_AlleAnzeigen"
                if filter.mainCategoryID != 99 {
                trackerActionString = "clickout_in_\(filter.categories.mainCatsStrings[filter.mainCategoryID])"
                }
                let eventTracker: NSObject = GAIDictionaryBuilder.createEvent(
                    withCategory: "Clickout",
                    action: trackerActionString,
                    label: "\(navigationString)",
                    value: nil).build()
                tracker?.send(eventTracker as! [AnyHashable: Any])
                
                currentNavigationActionRequestURL = navigationAction.request.url!
                performSegue(withIdentifier: "showDetailSegueID", sender: self)
            }
            
        
        
        } else {
            if navigationAction.navigationType.rawValue == 0 {
                decisionHandler(WKNavigationActionPolicy.cancel)
                UIApplication.shared.openURL(navigationAction.request.url!)
            } else {
                decisionHandler(WKNavigationActionPolicy.allow)
                print("dont know")
            }
        }

        
        
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let credential = URLCredential(user: "CFW", password: "Local24Teraone", persistence: .forSession)
        completionHandler(.useCredential, credential)
    }
    

    
    

    
    // MARK: - Navigation
    
    @IBAction func backfromLocationToSearchSegue(_ segue:UIStoryboardSegue) {
        if let sVC = segue.source as? LocationViewController {
            sVC.searchController.searchBar.resignFirstResponder()
            sVC.searchController.isActive = false
        }
    }
    
    @IBAction func backfromfilterSegue(_ segue:UIStoryboardSegue) {

    }
    
    @IBAction func reloadButtonPressed(_ sender: UIButton) {
        webView.reload()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSegueID" {
            if let detailVC = segue.destination as? DetailViewController {
            detailVC.urlToShow = currentNavigationActionRequestURL!
            
            }
        }

        
        
        if segue.identifier == "showLocalDetailSegueID" {
            if let localdetailVC = segue.destination as? LocalDetailTableViewController {
                localdetailVC.urlToShow = currentNavigationActionRequestURL!
                
            }
        }
    }


}

*/





