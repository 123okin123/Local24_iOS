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
    
    let refreshControl = UIRefreshControl()

    

    var listingsArray = [Listing]()
    var facebookAdsArray = [FacebookAd]()
    
    struct FilterRange {
        var max : Int?
        var min : Int?
    }
    struct FilterTerm {
        var value :String?
    }
    
    var selectedRangeFilters = [FilterRange]()
    var selectedTermFilter = [FilterTerm]()
    
    var currentPage = 1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData(1)
        for _ in 0...10 {
        selectedTermFilter.append(FilterTerm(value: "TestFilter: TestWert"))
        }
        loadFilterStack()
        addPulltoRefresh()
        
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false


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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return listingsArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath as NSIndexPath).row % 10 == 0 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListingsAdCell", for: indexPath) as! SearchCollectionViewAdCell
            if facebookAdsArray.count - 1 >= (indexPath as NSIndexPath).row/10 {
            cell.adTitleLabel.text = facebookAdsArray[(indexPath as NSIndexPath).row/10].adBody
            cell.adImageView.image = facebookAdsArray[(indexPath as NSIndexPath).row/10].adIconImage
            cell.adCallToActionButton.setTitle(facebookAdsArray[(indexPath as NSIndexPath).row/10].adCallToActionString, for: UIControlState())
            let adView = facebookAdsArray[(indexPath as NSIndexPath).row/10].adView!
            adView.frame = cell.cellContentView.frame
            cell.cellContentView.addSubview(adView)
          
            
        }
        return cell
        } else {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListingsCell", for: indexPath) as! CollectionViewCell
            cell.listingTitle.text = listingsArray[(indexPath as NSIndexPath).row].title
            cell.listingPrice.text = listingsArray[(indexPath as NSIndexPath).row].price
            cell.listingDate.text = listingsArray[(indexPath as NSIndexPath).row].createdDate
            cell.listingImage.image = listingsArray[(indexPath as NSIndexPath).row].mainImage
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
        
        if (indexPath as NSIndexPath).row == listingsArray.count - 1 {
            loadData(currentPage + 1)
        }
        
       
        
    }
    
    
    
    func loadData(_ page: Int) {
        print("load page number: \(page)")
        let loadMoreActivityIndicator = UIActivityIndicatorView(frame: CGRect(x: screenwidth/2 - 10, y: screenheight - 30, width: 20, height: 20))
        loadMoreActivityIndicator.activityIndicatorViewStyle = .gray
        self.view.addSubview(loadMoreActivityIndicator)
        loadMoreActivityIndicator.startAnimating()

        let url = "https://cfw-api-11.azurewebsites.net/public/ads/?page=\(page)&pagesize=20&top=20"
        var request = URLRequest(url: URL(string: url)!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print("thers an error in the log")
                let alert = UIAlertController(title: "Fehler", message: "Local24 hat keine Verbindung zum Internet.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                DispatchQueue.main.async {
                    do {
                        
                        loadMoreActivityIndicator.stopAnimating()
                        

                        let  json = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions())
                        let array = json as! [[AnyHashable:Any]]
                        if array.count > 0 {
                            for i in 0...array.count - 1 {
                               
                                let listing = Listing(value: array[i])
                                self.listingsArray.append(listing)
                                
                                
                            }
     
                            self.collectionView?.reloadData()
                            self.currentPage = page
                            self.showNativeAd()
                        }
                        
    
                        
                        
                    } catch {
                        let alert = UIAlertController(title: "Fehler", message: "Artikel konnten nicht gefunden werden.", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    
                    
                }
            }
            
        }) 
        
        task.resume()
        
    }
    
    
    
    
    
    func loadImageOf(_ listing :Listing, index: Int) {
        var request = URLRequest(url: URL(string: listing.imagePathMedium!)!)
        let session = URLSession.shared
        request.httpMethod = "GET"
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print("thers an error in the log")
                let alert = UIAlertController(title: "Fehler", message: "Local24 hat keine Verbindung zum Internet.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                DispatchQueue.main.async {
                       let image = UIImage(data: data!)
                        let imageIndex = index + (20*(self.currentPage))
                        self.listingsArray[imageIndex].mainImage = image
                        self.collectionView?.reloadItems(at: [IndexPath(item: imageIndex, section: 0)])
                }
            }
            
        }) 
        task.resume()
    }
    
    
    
    func addPulltoRefresh() {
        refreshControl.addTarget(self, action: #selector(SearchCollectionViewController.refresh), for: UIControlEvents.valueChanged)
        collectionView!.addSubview(refreshControl)
    }
    
    func refresh() {
        listingsArray.removeAll()
        collectionView?.reloadData()
        currentPage = 0
        loadData(0)
        
        refreshControl.endRefreshing()
        
    }
    
    
    func loadFilterStack() {
        let selectedFilterView = UIView()
        selectedFilterView.frame.origin = CGPoint(x: 0, y: 64)
        selectedFilterView.frame.size = CGSize(width: screenwidth, height: 44)
        selectedFilterView.backgroundColor = UIColor(red: 190, green: 190, blue: 190, alpha: 0.9)
        self.view.addSubview(selectedFilterView)
        let selectedFilterScrollView = UIScrollView()
        selectedFilterScrollView.frame.origin = CGPoint(x: 0, y: 0)
        selectedFilterScrollView.frame.size = CGSize(width: screenwidth, height: 44)
        selectedFilterScrollView.showsHorizontalScrollIndicator = false
        selectedFilterScrollView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        selectedFilterView.addSubview(selectedFilterScrollView)
        
        
        let selectedFilterStackView = UIStackView()
        selectedFilterStackView.frame.origin = CGPoint(x: 0, y: 0)
        selectedFilterStackView.frame.size = CGSize(width: 0, height: 44)
        selectedFilterStackView.alignment = .center
        selectedFilterStackView.spacing = 10
        
        
        selectedFilterScrollView.addSubview(selectedFilterStackView)
        
        
        let filtercount = selectedTermFilter.count + selectedRangeFilters.count
        
        for i in 0...filtercount - 1 {
        let selectedFilterButton = SelectedFilterButton()
        selectedFilterButton.setTitle(selectedTermFilter[i].value, for: UIControlState())
        selectedFilterStackView.addArrangedSubview(selectedFilterButton)
        selectedFilterButton.sizeToFit()
        selectedFilterStackView.frame.size.width += selectedFilterButton.frame.size.width
        }
        selectedFilterScrollView.contentSize = selectedFilterStackView.frame.size
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
        self.collectionView?.reloadItems(at: [IndexPath(item: self.facebookAdsArray.endIndex - 1, section: 0)])
        })
        facebookAd.adCoverMediaView?.nativeAd = nativeAd

        // Add adChoicesView
        let adChoicesView = FBAdChoicesView(nativeAd: nativeAd)
        let adView = UIView()
        adView.addSubview(adChoicesView)
        facebookAd.adView = adView
        
        nativeAd.registerView(forInteraction: adView, with: self)
 
        
        
        facebookAdsArray.append(facebookAd)
        
        collectionView?.reloadItems(at: [IndexPath(item: facebookAdsArray.endIndex - 1, section: 0)])
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
