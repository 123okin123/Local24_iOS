//
//  SearchViewController.swift
//  Local24
//
//  Created by Local24 on 09/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import FBAudienceNetwork



class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FBNativeAdDelegate, FilterManagerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterCollectionView: UICollectionView!

    var listings = [Listing]()
    var facebookAds = [FacebookAd]()
    
    var refresher = UIRefreshControl()
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        addPulltoRefresh()
        FilterManager.shared.delegate = self
        loadListings(page: 0, completion: {})
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        let listing = listings[indexPath.item]
//        if (indexPath as NSIndexPath).row % 10 == 0 {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListingsAdCell", for: indexPath) as! SearchCollectionViewAdCell
//            if facebookAds.count - 1 >= (indexPath as NSIndexPath).row/10 {
//            cell.adTitleLabel.text = facebookAds[(indexPath as NSIndexPath).row/10].adBody
//            cell.adImageView.image = facebookAds[(indexPath as NSIndexPath).row/10].adIconImage
//            cell.adCallToActionButton.setTitle(facebookAds[(indexPath as NSIndexPath).row/10].adCallToActionString, for: UIControlState())
//            let adView = facebookAds[(indexPath as NSIndexPath).row/10].adView!
//            adView.frame = cell.cellContentView.frame
//            cell.cellContentView.addSubview(adView)
//          
//            
//        }
//        return cell
//        } else {
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
                        self.listings[indexPath.item].thumbImage = instance?.image
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
//        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenwidth - 30)/2, height: screenheight * 0.4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 60, left: 10, bottom: 50, right: 10)
    }
    
     func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == listings.count - 1 {
            loadListings(page: listings.count/20, completion: {})
        }
        
       
        
    }
    
    
    
    
    func addPulltoRefresh() {
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView!.addSubview(refresher)
    }
    
    func refresh() {
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
            } else {
                print(error!.localizedDescription)
            }
            self.collectionView?.reloadData()
        })
    }
    
    // MARK: UICollectionViewDelegate
    
    
    //MARK: Navigation
    
    @IBAction func backfromfilterSegue(_ segue:UIStoryboardSegue) {
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSeagueID" {
            if let cell = sender as? CollectionViewCell {
                if let dvc = segue.destination as? LocalDetailTableViewController {
                    dvc.listing = cell.listing
                }
            }
        }
    }
    

    
    
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

}
