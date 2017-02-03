//
//  SearchViewController.swift
//  Local24
//
//  Created by Local24 on 09/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import FBAudienceNetwork
import NVActivityIndicatorView



class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout , FBNativeAdDelegate, FilterManagerDelegate, UISearchBarDelegate, UIScrollViewDelegate  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterCollectionView: UICollectionView!

    @IBOutlet weak var noListingsLabel: UILabel!
    
    var listings = [Listing]()
   // var facebookAds = [FacebookAd]()
    
    var refresher = UIRefreshControl()
    var currentPage = 0
    
    var filterflowLayout: UICollectionViewFlowLayout {
        return self.filterCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
    }
    var filterCollectionViewDelegate :FilterCollectionViewDelegate?
    
    var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        filterCollectionViewDelegate = FilterCollectionViewDelegate(collectionView: filterCollectionView, viewController: self)
        filterCollectionView.delegate = filterCollectionViewDelegate
        filterCollectionView.dataSource = self
        if #available(iOS 10.0, *) {
            filterCollectionView.isPrefetchingEnabled = false
        }
        filterflowLayout.estimatedItemSize = CGSize(width: 100, height: 30)
        addPulltoRefresh()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        let searchTextField: UITextField? = searchBar.value(forKey: "searchField") as? UITextField
        if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
            let font = UIFont(name: "OpenSans", size: 13.0)
            let attributeDict = [
                NSFontAttributeName: font!,
            ]
            searchTextField!.attributedPlaceholder = NSAttributedString(string: "Wonach suchst du?", attributes: attributeDict)
        }
        searchTextField?.textColor = UIColor.gray
        FilterManager.shared.delegate = self
        loadListings(page: 0, completion: {})
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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

    // MARK: UICollectionViewDataSource

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == filterCollectionView {
        return FilterManager.shared.filters.count
        } else {
        return listings.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == filterCollectionView {
            return configureFilterCellAt(indexPath: indexPath)
        } else {
//            if (indexPath as NSIndexPath).row % 10 == 0 {
//                return configureAdCellAt(indexPath: indexPath)
//            } else {
                return configureListingCellAt(indexPath: indexPath)
//            }
        }
    }

    

    
    func configureFilterCellAt(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCollectionViewCell
        cell.filtername.text = FilterManager.shared.filters[indexPath.row].descriptiveString
        let filter = FilterManager.shared.filters[indexPath.row]
        switch filter.filterType! {
            case .sort:
            let sortFilter = filter as! Sortfilter
            cell.filtervalue.text = sortingOptions.first(where: {$0.order == sortFilter.order && $0.criterium == sortFilter.criterium})?.descriptiveString
            cell.imageViewWidthConstraint.constant = 0
        case .term:
            let termFilter = filter as! Termfilter
            cell.filtervalue.text = termFilter.value
            cell.imageViewWidthConstraint.constant = 10
        case .geo_distance:
            let geoFilter = filter as! Geofilter
            cell.filtervalue.text = geoFilter.value
            cell.imageViewWidthConstraint.constant = 0
        case .search_string:
            let searchFilter = filter as! Stringfilter
            cell.filtervalue.text = searchFilter.queryString
            cell.imageViewWidthConstraint.constant = 10
        case .range:
            let rangeFilter = filter as! Rangefilter
            var value = ""
            if let gte = rangeFilter.gte {
                value += "von \(Int(gte))€ "
            }
            if let lte = rangeFilter.lte {
                value += "bis \(Int(lte))€"
            }
            cell.filtervalue.text = value
            cell.imageViewWidthConstraint.constant = 10
        }
        
        return cell
    }
    func configureListingCellAt(indexPath: IndexPath) -> UICollectionViewCell {
        let listing = listings[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListingsCell", for: indexPath) as! CollectionViewCell
        cell.listingTitle.text = listing.title
        cell.listingPrice.text = listing.priceWithCurrency
        cell.listingDate.text = listing.createdDate
        cell.listing = listing
        if listing.thumbImage == nil {
            if let thumbImageURL = listing.thumbImageURL {
                if let imageUrl = URL(string: thumbImageURL) {
                    cell.listingImage.setImage(withUrl: imageUrl, placeholder: UIImage(named: "home_Background"), crossFadePlaceholder: true, cacheScaled: true, completion: { instance, error in
                        cell.listingImage.layer.add(CATransition(), forKey: nil)
                        cell.listingImage.image = instance?.image
                        listing.thumbImage = instance?.image
                    })
                }
            } else {
                let image = UIImage(named: "home_Background")
                cell.listingImage.image = image
            }
        } else {
            cell.listingImage.image = listing.thumbImage
        }
        
        return cell
    }
    /*
    func configureAdCellAt(indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListingsAdCell", for: indexPath) as! SearchCollectionViewAdCell
        if facebookAds.count - 1 >= (indexPath as NSIndexPath).row/10 {
            cell.adTitleLabel.text = facebookAds[(indexPath as NSIndexPath).row/10].adBody
            cell.adImageView.image = facebookAds[(indexPath as NSIndexPath).row/10].adIconImage
            cell.adCallToActionButton.setTitle(facebookAds[(indexPath as NSIndexPath).row/10].adCallToActionString, for: UIControlState())
            let adView = facebookAds[(indexPath as NSIndexPath).row/10].adView!
            adView.frame = cell.cellContentView.frame
            cell.cellContentView.addSubview(adView)
        }
        return cell
    }
    */
    
    
    

    
    func addPulltoRefresh() {
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView!.addSubview(refresher)
    }
    
    func refresh() {
        currentPage = 0
        loadListings(page: 0, completion: {
            self.listings.removeAll()
            self.refresher.endRefreshing()
        })
    }
  
    func loadListings(page :Int, completion: @escaping (() -> Void)) {
        
        networkManager.getAdsSatisfying(filterArray: FilterManager.shared.filters, page: page, completion: { (listings, error) in
            completion()
            if error == nil && listings != nil {
               self.listings.append(contentsOf: listings!)
                if self.listings.count == 0 {
                    self.noListingsLabel.isHidden = false
                } else {
                    self.noListingsLabel.isHidden = true
                }
                if self.listings.contains(where: {$0.containsAdultContent == true}) {
                    print("ping")
                }
            } else {
                print(error!.localizedDescription)
            }
            
            self.collectionView?.reloadData()
        })
    }
    
    // MARK: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenwidth - 30)/2, height: screenheight * 0.4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 60, left: 10, bottom: 50, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == listings.count - 1 {
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
}



class FilterCollectionViewDelegate :NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var collectionViewController :UIViewController?
    
    init(collectionView: UICollectionView, viewController: UIViewController) {
        super.init()
        collectionView.delegate = self
        collectionViewController = viewController
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = FilterManager.shared.filters[indexPath.row]
        if filter.filterType! != .sort &&  filter.filterType! != .geo_distance {
            FilterManager.shared.removefilterWithIndex(index: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
            collectionView.collectionViewLayout.invalidateLayout()
        }
        if filter.filterType == .geo_distance {
            collectionViewController?.performSegue(withIdentifier: "fromSearchToLocationSegueID", sender: nil)
        }
        if filter.filterType == .sort {
            collectionViewController?.performSegue(withIdentifier: "fromSearchToFilterSegueID", sender: nil)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}





