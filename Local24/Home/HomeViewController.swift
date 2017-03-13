//
//  Home2ViewController.swift
//  Local24
//
//  Created by Local24 on 23/01/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import FirebaseAnalytics

public var hasSeenAppRatingInSession = false
public var checkedForAppRating = false
public var forceShowAppRating = false

private let reuseIdentifier = "HomeCatCell"

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UICollectionViewDelegate {

    // MARK: IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
 
    // MARK: Variables
    
    var homeCategories = [Category]()
    var featuredListings = [Listing]()
    var isLoadingFeaturedListings = true
    
    var searchBar = UISearchBar()

    // MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        navigationItem.titleView = searchBar
        
        getFeaturedListings(completion: {_ in
            self.isLoadingFeaturedListings = false
            self.collectionView?.reloadData()
        })
        configureSearchBar()
  
        if let idString = remoteConfig["homeCategories"].stringValue {
            let idStrings = idString.characters.split(separator: ",").map(String.init)
            let ids = idStrings.map({Int($0)})
            for id in ids {
                if let category = CategoryManager.shared.mainCategories.first(where: {$0.id == id}) {
                    homeCategories.append(category)
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("Home")
   
    }
    
    // MARK: Methods
    
    func getFeaturedListings(completion: @escaping (_ error:Error?) -> Void) {
        _ = NetworkManager.shared.getAdsSatisfying(filterArray: FilterManager.shared.filters, page: 0, completion: {(listings, error) in
            if error == nil && listings != nil {
                if listings!.count < 3 {
                    _ = NetworkManager.shared.getAdsSatisfying(filterArray: [Filter](), page: 0, completion: {(listings, error) in
                        self.featuredListings = listings!
                        completion(nil)
                    })
                } else {
                    self.featuredListings = listings!
                    completion(nil)
                }
            } else {
                completion(error)
            }
        })
    }
    

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeCategories.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeCatCell
        if indexPath.item == homeCategories.count {
            cell.title.text = "Alle Anzeigen"
            cell.imageView.image = UIImage(named: "alleAnzeigen")
            cell.catID = nil
        } else {
            if let id = homeCategories[indexPath.item].id {
                cell.imageView.image = UIImage(named: String(id))
            }
            cell.title.text = homeCategories[indexPath.item].name
            cell.catID = homeCategories[indexPath.item].id
        }
        return cell
            
    }

    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenwidth - 30)/2, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
 
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeHeader", for: indexPath) as! HomeHeaderCollectionReusableView
        headerView.homeViewController = self
        if let geofilterValue = FilterManager.shared.getValueOffilter(withName: .geo_distance, filterType: .geo_distance) {
            headerView.currentLocationButton.setTitle(geofilterValue, for: .normal)
        } else {
            headerView.currentLocationButton.setTitle("Deutschland", for: .normal)
        }
        return headerView
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: SearchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text != "" {
            if searchBar.text != nil {
                FIRAnalytics.logEvent(withName: kFIREventSearch, parameters: [
                    kFIRParameterSearchTerm: searchBar.text! as NSObject,
                    "screen": "home" as NSObject
                    ])
            }
            if let navVC = tabBarController?.childViewControllers[1] as? UINavigationController {
                FilterManager.shared.setfilter(newfilter: Stringfilter(value: searchBar.text!))
                tabBarController?.selectedViewController = navVC
                searchBar.text = ""
            }
        }
    }
    
    func configureSearchBar() {
        searchBar.tintColor = UIColor.white
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        let searchTextField = searchBar.value(forKey: "searchField") as! UITextField
        if searchTextField.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
            let font = UIFont(name: "OpenSans", size: 13.0)
            let attributeDict = [
                NSFontAttributeName: font!,
                NSForegroundColorAttributeName: greencolor
            ]
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Wonach suchst du?", attributes: attributeDict)
        }
        searchTextField.textColor = UIColor.white
        searchTextField.clearButtonMode = .never
        if let glassIconView = searchTextField.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            glassIconView.tintColor = greencolor
        }
    }
    
    // MARK: Navigation
    
    @IBAction func backfromLocationSegue(_ segue:UIStoryboardSegue) {
        if let sVC = segue.source as? LocationViewController {
            sVC.searchController.searchBar.resignFirstResponder()
            sVC.searchController.isActive = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sender = sender as? HomeCatCell {
            if let catId = sender.catID  {
                if let dVC = segue.destination as? NewCatTableViewController {
                    dVC.mainCatID = catId
                }
            }
        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let sender = sender as? HomeCatCell {
            if sender.catID != nil {
                return true
            } else {
                FilterManager.shared.removeAllfilters()
                if let navVC = tabBarController?.childViewControllers[1] as? UINavigationController {
                    tabBarController?.selectedViewController = navVC
                    navVC.popToRootViewController(animated: true)
                }
                return false
            }
        }
        return true
    }

}
