//
//  Home2ViewController.swift
//  Local24
//
//  Created by Local24 on 23/01/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit

private let reuseIdentifier = "HomeCatCell"

class HomeViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    var homeCategories = [CategoryModel]()
    var searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = searchBar
        configureSearchBar()
        
        if let idString = remoteConfig["homeCategories"].stringValue {
            let idStrings = idString.characters.split(separator: ",").map(String.init)
            let ids = idStrings.map({Int($0)})
            for id in ids {
                if let category = categoryBuilder.mainCategories.first(where: {$0.id == id}) {
                    homeCategories.append(category)
                }
            }
        }
    }
    
    
    
    func configureSearchBar() {
        searchBar.delegate = self
        searchBar.tintColor = UIColor.white
        searchBar.searchBarStyle = .minimal
        searchBar.setImage(UIImage(named: "lupe_gruen"), for: UISearchBarIcon.search, state: UIControlState())
        let searchTextField: UITextField? = searchBar.value(forKey: "searchField") as? UITextField
        if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
            let font = UIFont(name: "OpenSans", size: 13.0)
            let attributeDict = [
                NSFontAttributeName: font!,
                NSForegroundColorAttributeName: UIColor(red: 132/255, green: 168/255, blue: 77/255, alpha: 1)
            ]
            searchTextField!.attributedPlaceholder = NSAttributedString(string: "Wonach suchst du?", attributes: attributeDict)
        }
        searchTextField?.textColor = UIColor.white
        let textField :UITextField? = searchBar.value(forKey: "searchField") as? UITextField
        textField!.clearButtonMode = .never
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("Home")
        collectionView?.reloadData()
        
        
//        if filter.searchLocationString == "Deutschland" {
//            searchLocationButton.setTitle("Suchen in: \(filter.searchLocationString)", for: UIControlState())
//        } else {
//            let radiusString = String(filter.searchRadius)
//            searchLocationButton.setTitle("Suchen in: (\(radiusString)km) \(filter.searchZip) \(filter.searchLocationString)", for: UIControlState())
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeCategories.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
 
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeHeader", for: indexPath) as! HomeHeaderCollectionReusableView
        
        if let geofilterValue = FilterManager.shared.getValueOffilter(withName: .geo_distance, filterType: .geo_distance) {
            headerView.currentLocationButton.setTitle(geofilterValue, for: .normal)
        } else {
            headerView.currentLocationButton.setTitle("Deutschland", for: .normal)
        }
        return headerView
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
                FilterManager.shared.setfilter(newfilter: Stringfilter(value: searchBar.text!))
                tabBarController?.selectedViewController = navVC
                searchBar.text = ""
            }
        }
    }
    
 
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
  
            searchBar.resignFirstResponder()
        
    }
    
    
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
