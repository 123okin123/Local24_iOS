//
//  HomeViewController.swift
//  Local24
//
//  Created by Locla24 on 26/11/15.
//  Copyright © 2015 Nikolai Kratz. All rights reserved.
//

import UIKit
import WebKit

class SearchViewController: UIViewController, UISearchBarDelegate, UIScrollViewDelegate, WKNavigationDelegate, WKUIDelegate {
    
    // MARK: Outlets & Variables
    
    @IBOutlet weak var selectedFiltersBGView: UIView! {didSet {
        selectedFiltersBGView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        selectedFiltersBGView.layer.borderWidth = 1
        }}
    @IBOutlet weak var selectedFiltersScrollView: UIScrollView!
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
    

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {didSet {
        activityIndicator.isHidden = true
        }}
    @IBOutlet weak var reloadButton: UIButton! {didSet {
        reloadButton.layer.borderColor = bluecolor.cgColor
        reloadButton.layer.borderWidth = 1
        reloadButton.layer.cornerRadius = 5.0
        reloadButton.isHidden = true
        }}
    @IBOutlet weak var reloadLable: UILabel! {didSet {
        reloadLable.isHidden = true
        }}

    var currentNavigationActionRequestURL :URL!
    var webView = WKWebView()
    var loaderView =  UIView()
    var nav = WKNavigation()
    var navAction = WKNavigationAction()
    

    var filter = (UIApplication.shared.delegate as! AppDelegate).filter
    var categories = Categories()
    let selectedFilterStackView = UIStackView()

    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            print("Filter \(keyPath!) changed from \(change![NSKeyValueChangeKey.oldKey]) to \(change![NSKeyValueChangeKey.newKey])")
            if let url = URL(string: filter.urlFromFilters()) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
        
    }
    
    
    func updateFilterButtons() {
        if selectedFilterStackView.arrangedSubviews.count > 0 {
        for buttonToRemove in selectedFilterStackView.arrangedSubviews {
        buttonToRemove.removeFromSuperview()
        }
        }
        selectedFilterStackView.frame.size = CGSize(width: 0, height: 44)
        selectedFiltersScrollView.contentSize = CGSize(width: 0, height: 44)
        if filter.searchLocationString != "" {
            let selectedFilterButton = SelectedFilterButton()
            var titleOfButton = "\(filter.searchLocationString) (\(filter.searchRadius) km)"
            if filter.searchLocationString == "Deutschland" {
            titleOfButton = "Deutschland"
            }
            selectedFilterButton.filterName = "searchLocationString"
            selectedFilterButton.removeable = false
            selectedFilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedFilterStackView.addArrangedSubview(selectedFilterButton)
            selectedFilterButton.sizeToFit()
            selectedFilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedFilterButton.backgroundColor = UIColor.white
            selectedFilterButton.clipsToBounds = true
            selectedFilterStackView.frame.size.width += selectedFilterButton.frame.width
        }
        if filter.minPrice != "" {
            let selectedFilterButton = SelectedFilterButton()
            let titleOfButton = "Preis von: \(filter.minPrice) €"
            selectedFilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedFilterButton.filterName = "minPrice"
            selectedFilterStackView.addArrangedSubview(selectedFilterButton)
            selectedFilterButton.sizeToFit()
            selectedFilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedFilterButton.backgroundColor = UIColor.white
            selectedFilterButton.clipsToBounds = true
            selectedFilterStackView.frame.size.width += selectedFilterButton.frame.width
            selectedFilterStackView.frame.size.width += 10
        }
        if filter.maxPrice != "" {
            let selectedFilterButton = SelectedFilterButton()
            let titleOfButton = "Preis bis: \(filter.maxPrice) €"
            selectedFilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedFilterButton.filterName = "maxPrice"
            selectedFilterStackView.addArrangedSubview(selectedFilterButton)
            selectedFilterButton.sizeToFit()
            selectedFilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedFilterButton.backgroundColor = UIColor.white
            selectedFilterButton.clipsToBounds = true
            selectedFilterStackView.frame.size.width += selectedFilterButton.frame.width
            selectedFilterStackView.frame.size.width += 10
        }
        if filter.searchString != "" {
            let selectedFilterButton = SelectedFilterButton()
            let titleOfButton = "\u{0022}\(filter.searchString)\u{0022}"
            selectedFilterButton.filterName = "searchString"
            selectedFilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedFilterStackView.addArrangedSubview(selectedFilterButton)
            selectedFilterButton.sizeToFit()
            selectedFilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedFilterButton.backgroundColor = UIColor.white
            selectedFilterButton.clipsToBounds = true
            selectedFilterStackView.frame.size.width += selectedFilterButton.frame.width
            selectedFilterStackView.frame.size.width += 10
        }
        if filter.mainCategoryID != 99 {
            let selectedFilterButton = SelectedFilterButton()
            let titleOfButton = "Hauptkategorie: \(categories.mainCatsStrings[filter.mainCategoryID])"
            selectedFilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedFilterButton.filterName = "mainCategoryID"
            selectedFilterStackView.addArrangedSubview(selectedFilterButton)
            selectedFilterButton.sizeToFit()
            selectedFilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedFilterButton.backgroundColor = UIColor.white
            selectedFilterButton.clipsToBounds = true
            selectedFilterStackView.frame.size.width += selectedFilterButton.frame.width
            selectedFilterStackView.frame.size.width += 10
        }
        if filter.subCategoryID != 99 {
            let selectedFilterButton = SelectedFilterButton()
            let titleOfButton = "Unterkategorie: \(categories.cats[filter.mainCategoryID][filter.subCategoryID])"
            selectedFilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedFilterButton.filterName = "subCategoryID"
            selectedFilterStackView.addArrangedSubview(selectedFilterButton)
            selectedFilterButton.sizeToFit()
            selectedFilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedFilterButton.backgroundColor = UIColor.white
            selectedFilterButton.clipsToBounds = true
            selectedFilterStackView.frame.size.width += selectedFilterButton.frame.width
            selectedFilterStackView.frame.size.width += 10
        }
        if filter.mainCategoryID == 0 && filter.subCategoryID == 1 {
        if filter.minMileAge != 0 {
            let selectedFilterButton = SelectedFilterButton()
            let titleOfButton = "Laufleistung von: \(filter.minMileAge) km"
            selectedFilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedFilterButton.filterName = "minMileAge"
            selectedFilterStackView.addArrangedSubview(selectedFilterButton)
            selectedFilterButton.sizeToFit()
            selectedFilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedFilterButton.backgroundColor = UIColor.white
            selectedFilterButton.clipsToBounds = true
            selectedFilterStackView.frame.size.width += selectedFilterButton.frame.width
            selectedFilterStackView.frame.size.width += 10
        }
        if filter.maxMileAge != 500000 {
            let selectedFilterButton = SelectedFilterButton()
            let titleOfButton = "Laufleistung bis: \(filter.maxMileAge) km"
            selectedFilterButton.setTitle(titleOfButton, for: UIControlState())
            selectedFilterButton.filterName = "maxMileAge"
            selectedFilterStackView.addArrangedSubview(selectedFilterButton)
            selectedFilterButton.sizeToFit()
            selectedFilterButton.addTarget(self, action: #selector(SearchViewController.filterButtonPressed), for: .touchUpInside)
            selectedFilterButton.backgroundColor = UIColor.white
            selectedFilterButton.clipsToBounds = true
            selectedFilterStackView.frame.size.width += selectedFilterButton.frame.width
            selectedFilterStackView.frame.size.width += 10
        }
        }
        
        selectedFiltersScrollView.contentSize = selectedFilterStackView.frame.size

        

  
        
    }
    
    func filterButtonPressed(_ sender: SelectedFilterButton) {
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
        updateFilterButtons()
    }
    

    func startObservingFilter() {
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
        
        startObservingFilter()
        
        selectedFilterStackView.frame.origin = CGPoint(x: 0, y: 0)
        selectedFilterStackView.frame.size = CGSize(width: 0, height: 44)
        selectedFilterStackView.alignment = .center
        selectedFilterStackView.spacing = 8
        selectedFilterStackView.distribution = .fillProportionally
        selectedFiltersScrollView.addSubview(selectedFilterStackView)
        selectedFiltersScrollView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        selectedFiltersScrollView.scrollsToTop = false
    

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
        webView.allowsBackForwardNavigationGestures = true
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
        
        if let url = URL(string: filter.urlFromFilters()) {
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
        updateFilterButtons()
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
        if let url = URL(string: filter.urlFromFilters()) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        updateFilterButtons()

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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
         print("webViewURL:\(webView.url!.absoluteString)")
        if filter.mainCategoryID != 99 {
        gaUserTracking("Search/\(filter.categories.mainCatsStrings[filter.mainCategoryID])")
        } else {
        gaUserTracking("Search/AlleAnzeigen")
        }
        
        let loadMeta = "var meta = document.createElement('meta'); meta.name = 'viewport'; meta.content = 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0'; document.getElementsByTagName('head')[0].appendChild(meta);"
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
    
    @IBAction func backfromFilterSegue(_ segue:UIStoryboardSegue) {

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







