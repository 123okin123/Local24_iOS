//
//  SearchCollectionViewController.swift
//  Local24
//
//  Created by Local24 on 09/05/16.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import FBAudienceNetwork



class SearchCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, FBNativeAdDelegate {
    
    

    

    var listings = [Listing]()
    var facebookAds = [FacebookAd]()
    
    var refreshControl = UIRefreshControl()
    var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPulltoRefresh()
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listings.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath as NSIndexPath).row % 10 == 0 {
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
        } else {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListingsCell", for: indexPath) as! CollectionViewCell
            cell.listingTitle.text = listings[(indexPath as NSIndexPath).row].title
            cell.listingPrice.text = listings[(indexPath as NSIndexPath).row].price
            cell.listingDate.text = listings[(indexPath as NSIndexPath).row].createdDate
            cell.listingImage.image = listings[(indexPath as NSIndexPath).row].mainImage
            return cell
        }

    
        
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {


        return CGSize(width: screenwidth/2 - 20, height: 200)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 54, left: 10, bottom: 50, right: 10)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == listings.count - 1 {
            loadListings()
        }
        
       
        
    }
    
    
    
    
    
    
    
//    
//    func loadImageOf(_ listing :Listing, index: Int) {
//        var request = URLRequest(url: URL(string: listing.imagePathMedium!)!)
//        let session = URLSession.shared
//        request.httpMethod = "GET"
//        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
//            if error != nil {
//                print("thers an error in the log")
//                let alert = UIAlertController(title: "Fehler", message: "Local24 hat keine Verbindung zum Internet.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//            } else {
//                DispatchQueue.main.async {
//                       let image = UIImage(data: data!)
//                        let imageIndex = index + (20*(self.currentPage))
//                        self.listingsArray[imageIndex].mainImage = image
//                        self.collectionView?.reloadItems(at: [IndexPath(item: imageIndex, section: 0)])
//                }
//            }
//            
//        }) 
//        task.resume()
//    }
    
    
    
    func addPulltoRefresh() {
        refreshControl.addTarget(self, action: #selector(SearchCollectionViewController.refresh), for: UIControlEvents.valueChanged)
        collectionView!.addSubview(refreshControl)
    }
    
    func refresh() {
        listings.removeAll()
        collectionView?.reloadData()
        
        
        
        refreshControl.endRefreshing()
        
    }
    
    
  
    func loadListings() {
        networkController.getAdsSatisfying(filterArray: nil, completion: { (listings, error) in
            if error != nil {
                
            } else {
                print(error?.localizedDescription)
            }
        })
    }

    
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
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
