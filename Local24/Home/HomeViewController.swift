//
//  HomeViewController.swift
//  Local24
//
//  Created by Locla24 on 27/01/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import QuartzCore
import FBSDKCoreKit
import FBSDKLoginKit

class HomeViewController: UIViewController, UISearchBarDelegate, UIScrollViewDelegate {
    
    
    // MARK: Outlets & Variables
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchLocationButton: UIButton!
    @IBOutlet weak var showAllCatsView: UIView! {
        didSet {
            showAllCatsView.layer.cornerRadius = 5
        }}

    var filter = (UIApplication.shared.delegate as! AppDelegate).filter
    

    @IBAction func showAllCatsButtonPressed(_ sender: UIButton) {
        filter.resetAllFilters()
        if let navVC = tabBarController?.childViewControllers[1] as? UINavigationController {
            tabBarController?.selectedViewController = navVC
            navVC.popToRootViewController(animated: true)
        }
    }
    
    
    
    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        scrollView.delegate = self
        configureSearchBar()
        let logo = UIImage(named: "logo.png")
        let imageView = UIImageView(image:logo)
        imageView.frame.size = CGSize(width: 0, height:37)
        imageView.contentMode = .scaleAspectFit
        
        self.navigationItem.titleView = imageView
        
        
        let contentheight :CGFloat = 600
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        stackView.frame.size = CGSize(width: screenwidth - 32, height: contentheight)
        scrollView.contentSize = stackView.frame.size
        scrollView.clipsToBounds = false
 
        for i in 0...1 {
        for n in 0...7 {
            let subView = stackView.subviews[i].subviews[n]
            subView.layer.cornerRadius = 5
        }
        }
       
    }
    
    
    func configureSearchBar() {
        searchBar.delegate = self
        searchBar.setImage(UIImage(named: "lupe_grau"), for: UISearchBarIcon.search, state: UIControlState())
        let searchTextField: UITextField? = searchBar.value(forKey: "searchField") as? UITextField
        if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
            let font = UIFont(name: "OpenSans", size: 13.0)
            let attributeDict = [
                NSFontAttributeName: font!,
                NSForegroundColorAttributeName: UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            ]
            searchTextField!.attributedPlaceholder = NSAttributedString(string: "Was suchen Sie?", attributes: attributeDict)
        }
        searchTextField?.textColor = UIColor.gray
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("Home")
        if filter.searchLocationString == "Deutschland" {
            searchLocationButton.setTitle("Suchen in: \(filter.searchLocationString)", for: UIControlState())
        } else {
            let radiusString = String(filter.searchRadius)
            searchLocationButton.setTitle("Suchen in: (\(radiusString)km) \(filter.searchZip) \(filter.searchLocationString)", for: UIControlState())
        }

    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollView.resignFirstResponder()
    }

    
    
    
    // MARK: SearchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text != "" {
        if searchBar.text != nil {
            let tracker = GAI.sharedInstance().defaultTracker
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Search", action: "searchInHome", label: searchBar.text!, value: 0).build() as NSDictionary as! [AnyHashable: Any])
        }
            if let navVC = tabBarController?.childViewControllers[1] as? UINavigationController {
                filter.searchString = searchBar.text!
                tabBarController?.selectedViewController = navVC
                searchBar.text = ""
                
            }

        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    
    
    
    // MARK: - Navigation

    
    @IBAction func backfromLocationSegue(_ segue:UIStoryboardSegue) {
        if let sVC = segue.source as? LocationViewController {
        sVC.searchController.searchBar.resignFirstResponder()
        sVC.searchController.isActive = false
        }
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let sender = sender as? UIButton {
            if let dVC = segue.destination as? NewCatTableViewController {
            dVC.mainCatTag = sender.tag
            }
        }
    }
    

    
    
}
