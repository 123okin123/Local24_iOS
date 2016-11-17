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

class AccountCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var userListings = [Listing]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func cellLongPressed(sender: UILongPressGestureRecognizer) {
        if let listing = (sender.view as! MyAdsCollectionViewCell).listing {
            let optionMenu = UIAlertController(title: listing.title, message: nil, preferredStyle: .actionSheet)
            if listing.adState == .active {
            let pauseAction = UIAlertAction(title: "Anzeige pausieren", style: .default, handler: {alert in self.changeAdStateOf(listing: listing, to: "pause")})
                            optionMenu.addAction(pauseAction)
            }else {
            let activeAction = UIAlertAction(title: "Anzeige aktivieren", style: .default, handler: {alert in self.changeAdStateOf(listing: listing, to: "active")})
                            optionMenu.addAction(activeAction)
            }
            let editAction = UIAlertAction(title: "Anzeige bearbeiten", style: .default, handler: {alert in })
            let deleteAction = UIAlertAction(title: "Anzeige löschen", style: .destructive, handler: {alert in self.delete(listing: listing)})
            let cancleAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: {alert in })

            optionMenu.addAction(editAction)
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancleAction)
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    func changeAdStateOf(listing :Listing, to adState: String) {
        var values = [
                         "ID": listing.adID!,
                         "ID_Advertiser": listing.advertiserID!,
                         "ID_Category" : listing.catID!,
                         "EntityType" : listing.entityType!,
                         "AdState": adState,
                         "AdType": listing.adType!.rawValue,
                         "Title":listing.title!,
                         "Body": listing.description!,
                         "City": listing.city!,
                         "ZipCode": listing.zipcode!
        ] as [String : Any]
        if listing.priceType != nil {
        values["PriceType"] = listing.priceType!
        }
        Alamofire.request("https://cfw-api-11.azurewebsites.net/ads/\(listing.adID!)/?auth=\(userToken!)&id=\(listing.adID!)", method: .put, parameters: values, encoding: JSONEncoding.default).responseJSON(completionHandler: {response in
            switch response.result {
            case .success:
                self.getAds()
            case .failure:
                let errorMenu = UIAlertController(title: "Fehler", message: "Da ist leider etwas schief gegangen, das Pausieren der Anzeige war nicht erfolgreich.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: {alert in})
                errorMenu.addAction(confirmAction)
                self.present(errorMenu, animated: true, completion: nil)
            }
        })

        
    }
    
    func delete(listing: Listing) {
        let confirmMenu = UIAlertController(title: "Anzeige Löschen", message: "Bist du sicher, dass du diese Anzeige löschen möchtest?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: {alert in
            Alamofire.request("https://cfw-api-11.azurewebsites.net/ads/\(listing.adID)", method: .delete,
                              parameters:
                ["auth": userToken!,
                 "id": listing.adID as Any,
                 "finally": "true"
                ]).response {response in
                    if response.error == nil {
                        let successMenu = UIAlertController(title: "Anzeige wurde gelöscht", message: "Die Anzeige wurde erfolgreich gelöscht.", preferredStyle: .alert)
                        let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: {alert in})
                        successMenu.addAction(confirmAction)
                        self.present(successMenu, animated: true, completion: nil)
                    } else {
                        let errorMenu = UIAlertController(title: "Fehler", message: "Da ist leider etwas schief gegangen, das Löschen der Anzeige war nicht erfolgreich.", preferredStyle: .alert)
                        let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: {alert in})
                        errorMenu.addAction(confirmAction)
                        self.present(errorMenu, animated: true, completion: nil)
                    }
            }
        })
        let cancleAction = UIAlertAction(title: "Abbrechen", style: .default, handler: {alert in})
        confirmMenu.addAction(confirmAction)
        confirmMenu.addAction(cancleAction)
        self.present(confirmMenu, animated: true, completion: nil)

    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if userToken == nil {
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewControllerID") {
                self.addViewControllerAsChildViewController(viewController: loginVC)
            }
        } else {
           
            Alamofire.request("https://cfw-api-11.azurewebsites.net/me", method: .get, parameters: ["auth": userToken!]).validate().responseJSON (completionHandler: {response in
                print(userToken)
                print(response.result.value)
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
                    print(ad)
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
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))
        gestureRecognizer.delegate = self
        cell.addGestureRecognizer(gestureRecognizer)
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
        return CGSize(width: (screenwidth - 30)/2, height: 230)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
    
    func addViewControllerAsChildViewController(viewController: UIViewController) {
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParentViewController: self)
    }
    
    
    
    @IBAction func backfromLocalDetailToAccountSegue(_ segue:UIStoryboardSegue) {
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AccountshowLocalDetailSegueID" {
            if let cell = sender as? MyAdsCollectionViewCell {
                if cell.listing.adState == .active {
                    if let navVC = segue.destination as? UINavigationController {
                        if let localdetailVC = navVC.viewControllers[0] as? LocalDetailTableViewController {
                            localdetailVC.urlToShow = cell.listing.url
                            
                        }
                    }
                }
            }
            
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "AccountshowLocalDetailSegueID" {
            if let cell = sender as? MyAdsCollectionViewCell {
                if cell.listing.adState != .active {
                return false
                }
            }
        }
        return true
       
    }
    
    
    
    
    
    
    

    


}
