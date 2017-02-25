//
//  SearchViewController.swift
//  Local24
//
//  Created by Local24 on 09/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import FBAudienceNetwork
import Alamofire

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout ,/*FBNativeAdsManagerDelegate,*/ FilterManagerDelegate, UISearchBarDelegate, UIScrollViewDelegate  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterCollectionView: UICollectionView!

    @IBOutlet weak var noListingsLabel: UILabel!
    
    var listings = [Listing]()
//    var ads = [FacebookAd]()
//    var numberOfAds :Int {
//    return min(listings.count/adDensity, ads.count)
//    }
    
//    var fbNativeAdsManager :FBNativeAdsManager!
//    var adDensity = 5
    
    var isloading = false
    var refresher = UIRefreshControl()
    var currentPage = 0
    var currentRequest :DataRequest?
    
    var filterflowLayout: UICollectionViewFlowLayout {
        return self.filterCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
    }
    var filterCollectionViewDelegate :FilterCollectionViewDelegate?
    var filterCollectionViewDataSource :FilterCollectionViewDataSource?
    var searchBar = UISearchBar()
    
    var collectionViewDataSource :CollectionViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config collectionView
        collectionView.delegate = self
        collectionViewDataSource = CollectionViewDataSource(collectionView: collectionView, viewController: self)
        collectionView.dataSource = collectionViewDataSource
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        addPulltoRefresh()
        
        // config filterCollectionView
        filterCollectionViewDelegate = FilterCollectionViewDelegate(collectionView: filterCollectionView, viewController: self)
        filterCollectionView.delegate = filterCollectionViewDelegate
        filterCollectionViewDataSource = FilterCollectionViewDataSource(collectionView: filterCollectionView, viewController: self)
        filterCollectionView.dataSource = filterCollectionViewDataSource
        if #available(iOS 10.0, *) {
            filterCollectionView.isPrefetchingEnabled = false
        }
        filterflowLayout.estimatedItemSize = CGSize(width: 100, height: 30)
        
        
        navigationItem.titleView = searchBar
        configureSearchBar()
        FilterManager.shared.delegate = self
        refresh()
//        FBAdSettings.addTestDevice("4531d3286eb720f69250ec7525e4d32a27020a58")
//        FBAdSettings.clearTestDevices()
//        fbNativeAdsManager = FBNativeAdsManager(placementID: "1737515613173620_1740640836194431", forNumAdsRequested: 10)
//        fbNativeAdsManager.delegate = self
//        fbNativeAdsManager.mediaCachePolicy = .all
//        fbNativeAdsManager.loadAds()
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
        gaUserTracking("Search")
        filterCollectionView.reloadData()
        filterCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func filtersDidChange() {
        if listings.count > 0 {
            collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
        }
        refresh()
    }

    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" && searchBar.text != nil {
            let tracker = GAI.sharedInstance().defaultTracker
            tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "Search", action: "searchInSearch", label: searchBar.text!, value: 0).build() as NSDictionary as! [AnyHashable: Any])
            if FilterManager.shared.filters.contains(where: {$0.name == .sorting}) {
                FilterManager.shared.setfilter(newfilter: Stringfilter(value: searchBar.text!))
                filterCollectionView.reloadData()
            } else {
                FilterManager.shared.setfilter(newfilter: Stringfilter(value: searchBar.text!))
                if let index = FilterManager.shared.filters.index(where: {$0.name == .sorting}) {
                    filterCollectionView.insertItems(at: [IndexPath(item: index, section: 0)])
                }
            }
            filterCollectionView.collectionViewLayout.invalidateLayout()

        }
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        searchBar.resignFirstResponder()
    }



    
    

    
    func addPulltoRefresh() {
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView!.addSubview(refresher)
    }
    
    func refresh() {
        
        noListingsLabel.isHidden = true
        if listings.isEmpty {
            for _ in 0...10 {
                let dummyListing = Listing()
                listings.append(dummyListing)
            }
        }
        currentPage = 0
        currentRequest?.cancel()
        isloading = true
        collectionView.reloadData()
        loadListings(page: 0, completion: {
            self.listings.removeAll()
            self.refresher.endRefreshing()
            self.isloading = false
        })
    }
  
    func loadListings(page :Int, completion: @escaping (() -> Void)) {
        
        currentRequest = networkManager.getAdsSatisfying(filterArray: FilterManager.shared.filters, page: page, completion: { (listings, error) in
            completion()
            if error == nil && listings != nil {
               self.listings.append(contentsOf: listings!)
                if self.listings.count == 0 {
                    self.noListingsLabel.text = "Leider konnten keine Anzeigen zu deiner Suche gefunden werden."
                    self.noListingsLabel.isHidden = false
                } else {
                    self.noListingsLabel.isHidden = true
                }
                if self.listings.contains(where: {$0.containsAdultContent == true}) {
                    print("ping")
                }
            } else {
                print(error!.localizedDescription)
                self.noListingsLabel.text = "Leider ist beim Abrufen der Anzeigen ein Fehler aufgetreten."
                self.noListingsLabel.isHidden = false
            }
            
            self.collectionView?.reloadData()
        })
        
    }
    
    // MARK: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenwidth - 30)/2, height: screenheight * 0.4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 50, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == listings.count - 1 /*+ numberOfAds*/ {
            if listings.count >= 20 * (currentPage + 1) {
            loadListings(page: listings.count/20, completion: {
            self.currentPage += 1
            })
            }
        }
    }
    
    //MARK: Navigation
    
    @IBAction func backfromLocationToSearchSegue(_ segue:UIStoryboardSegue) {}
    
    @IBAction func backfromfilterSegue(_ segue:UIStoryboardSegue) {}
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        searchBar.resignFirstResponder()
        if segue.identifier == "showDetailSeagueID" {
            if let cell = sender as? CollectionViewCell {
                if let dvc = segue.destination as? LocalDetailTableViewController {
                    dvc.listing = cell.listing
                }
            }
        }
    }
    

    /*
    
    // MARK: Ads
    
    func showNativeAd() {
    let nativeAd = FBNativeAd(placementID: "1737515613173620_1740640836194431")
    nativeAd.delegate = self
    FBAdSettings.addTestDevice("4531d3286eb720f69250ec7525e4d32a27020a58")
    nativeAd.load()
    }
    
    func nativeAdDidLoad(_ nativeAd: FBNativeAd) {
      let facebookAd = FacebookAd()
        facebookAd.adBody = nativeAd.body
        facebookAd.adCallToActionString = nativeAd.callToAction
        nativeAd.icon?.loadAsync(block: { (image :UIImage?) -> Void in
        facebookAd.adIconImage = image
        self.collectionView?.reloadItems(at: [IndexPath(item: self.facebookAds.endIndex - 1, section: 0)])
        })
        facebookAd.adCoverMediaView?.nativeAd = nativeAd

        // Add adChoicesView
        let adChoicesView = FBAdChoicesView(nativeAd: nativeAd)
        let adView = UIView()
        adView.addSubview(adChoicesView)
        facebookAd.adView = adView
        
        nativeAd.registerView(forInteraction: adView, with: self)
 
        
        
        facebookAds.append(facebookAd)
        
        collectionView?.reloadItems(at: [IndexPath(item: facebookAds.endIndex - 1, section: 0)])
    }
    
    func nativeAdDidClick(_ nativeAd: FBNativeAd) {
        print("FB CLick")
    }
    
    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
        print("FB Log Impression")
    }
    func nativeAd(_ nativeAd: FBNativeAd, didFailWithError error: Error) {
        print(error)
    }
*/
  
//    func nativeAdsLoaded() {
//        print("successfully loaded ads")
//        for _ in 0...fbNativeAdsManager.uniqueNativeAdCount {
//            if let nextFBAd = fbNativeAdsManager.nextNativeAd {
//                let facebookAd = FacebookAd()
//                facebookAd.delegate = nextFBAd.delegate
//                facebookAd.delegate = self
//                facebookAd.adBody = nextFBAd.body
//                facebookAd.adCallToActionString = nextFBAd.callToAction
//                facebookAd.icon = nextFBAd.icon
//                facebookAd.adCoverMediaView?.nativeAd = nextFBAd
//                
//                // Add adChoicesView
//                let adChoicesView = FBAdChoicesView(nativeAd: nextFBAd)
//                let adView = UIView()
//                adView.addSubview(adChoicesView)
//                facebookAd.adView = adView
//                facebookAd.adCoverMediaView?.nativeAd.registerView(forInteraction: adView, with: self)
//                ads.append(facebookAd)
//            }
//        }
//        collectionView.reloadData()
//    }
// 
//    func nativeAdsFailedToLoadWithError(_ error: Error) {
//        print(error.localizedDescription)
//    }
//    
//    func nativeAdWillLogImpression(_ nativeAd: FBNativeAd) {
//        print("\(nativeAd) will log impression")
//    }

}



