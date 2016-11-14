//
//  AccountCollectionViewController.swift
//  Local24
//
//  Created by Local24 on 09/11/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import Alamofire
import MapleBacon

private let reuseIdentifier = "MyAdsCellID"

class AccountCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var userListings = [Listing]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func cellLongPressed(_ sender: UILongPressGestureRecognizer) {

    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if userToken == nil {
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewControllerID") {
                self.addViewControllerAsChildViewController(viewController: loginVC)
            }
        } else {
           
            Alamofire.request("https://cfw-api-11.azurewebsites.net/tokens/\(userToken!)/reads", method: .get, parameters: ["token": userToken!]).validate().responseJSON (completionHandler: {response in
                print(response)
                switch response.result {
                case .success:
                    self.getAds()
                case .failure:
                    if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewControllerID") {
                        self.addViewControllerAsChildViewController(viewController: loginVC)
                    }
                }
            })
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getAds() {
        userListings.removeAll()
        Alamofire.request("https://cfw-api-11.azurewebsites.net/ads/", method: .get, parameters: ["auth":userToken!]).validate().responseJSON (completionHandler: {response in
     
            switch response.result {
            case .success:

            let ads = response.result.value as! [[AnyHashable:Any]]
            if ads.count > 0 {
                for ad in ads {
                    let listing = Listing(value: ad)
                    self.userListings.append(listing)
                }
                }
            self.collectionView?.reloadData()
            case .failure:
             break
            }
            
            
  
        })
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        return userListings.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyAdsCollectionViewCell
        let listing = userListings[indexPath.row]
        cell.listing = listing
        cell.listingTitle.text = listing.title
        cell.listingPrice.text = listing.price
        cell.listingDate.text = listing.createdDate
        cell.listingImage.image = nil
        if listing.mainImage == nil {
            if let imagePathMedium = listing.imagePathMedium {
                if let imageUrl = URL(string: imagePathMedium) {
                    cell.listingImage.setImage(withUrl: imageUrl)
                }
            }
        } else {
            cell.listingImage.image = listing.mainImage
        }
        
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenwidth - 30)/2, height: 250)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
    
    func addViewControllerAsChildViewController(viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    
    
    @IBAction func backfromLocalDetailToAccountSegue(_ segue:UIStoryboardSegue) {
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AccountshowLocalDetailSegueID" {
            if let cell = sender as? MyAdsCollectionViewCell {
            if let navVC = segue.destination as? UINavigationController {
                if let localdetailVC = navVC.viewControllers[0] as? LocalDetailTableViewController {
                    localdetailVC.urlToShow = cell.listing?.url
                    
                }
            }
            }
            
        }
    }

    
    
    
    
    
    
    

    


}
