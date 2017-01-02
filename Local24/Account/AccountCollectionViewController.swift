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

class AccountCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, MyAdsCellDelegate {
    
    var userListings = [Listing]()
    var refresher = UIRefreshControl()
    var isLoading = false



    
    
    func cellLongPressed(sender: UILongPressGestureRecognizer) {
        if let listing = (sender.view as! MyAdsCollectionViewCell).listing {
        showOptionsFor(listing: listing)
        }
    }
    func showOptionsFor(listing :Listing) {
            let optionMenu = UIAlertController(title: listing.title, message: nil, preferredStyle: .actionSheet)
            if listing.adState == .active {
                let pauseAction = UIAlertAction(title: "Anzeige pausieren", style: .default, handler: {alert in self.changeAdStateOf(listing: listing, to: "paused")})
                optionMenu.addAction(pauseAction)
            }else {
                let activeAction = UIAlertAction(title: "Anzeige aktivieren", style: .default, handler: {alert in self.changeAdStateOf(listing: listing, to: "active")})
                optionMenu.addAction(activeAction)
            }
            let editAction = UIAlertAction(title: "Anzeige bearbeiten", style: .default, handler: {alert in
                let editVC = self.storyboard?.instantiateViewController(withIdentifier: "insertViewControllerID") as! InsertTableViewController
                editVC.listing = listing
                if let images = listing.images {
                editVC.imageArray = images
                }
                
                editVC.listingExists = true
                self.navigationController?.pushViewController(editVC, animated: true)
            })
            let deleteAction = UIAlertAction(title: "Anzeige löschen", style: .destructive, handler: {alert in self.delete(listing: listing)})
            let cancleAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: {alert in })
            
            optionMenu.addAction(editAction)
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancleAction)
            self.present(optionMenu, animated: true, completion: nil)
        

    }
    
    func changeAdStateOf(listing :Listing, to adState: String) {
        NetworkController.changeAdWith(adID: listing.adID!, to: adState, userToken: userToken!, completion: {error in
            if error == nil {
                if let index = self.userListings.index(where: {$0.adID == listing.adID}) {
                    self.userListings[index].adState = AdState(rawValue: adState)
                    self.collectionView?.reloadItems(at: [IndexPath(item: index, section: 0)])
                }
            } else {
                debugPrint(error as Any)
                let errorMenu = UIAlertController(title: "Fehler", message: "Da ist leider etwas schief gegangen, das Pausieren oder Aktivieren der Anzeige war nicht erfolgreich.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: {alert in})
                errorMenu.addAction(confirmAction)
                self.present(errorMenu, animated: true, completion: nil)
            }
        })
 
    }
    
    func delete(listing :Listing) {
        let confirmMenu = UIAlertController(title: "Anzeige Löschen", message: "Bist du sicher, dass du diese Anzeige löschen möchtest?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Löschen", style: .destructive, handler: {alert in
            NetworkController.deleteAdWith(adID: listing.adID!, userToken: userToken!, completion: { error in
                if error == nil {
                    if let index = self.userListings.index(where: {$0.createdDate == listing.createdDate}) {
                        self.userListings.remove(at: index)
                        self.collectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])
                    }
                } else {
                    let errorMenu = UIAlertController(title: "Fehler", message: "Da ist leider etwas schief gegangen, das Löschen der Anzeige war nicht erfolgreich.", preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: {alert in})
                    errorMenu.addAction(confirmAction)
                    self.present(errorMenu, animated: true, completion: nil)
                }
            })
            
        })
        let cancleAction = UIAlertAction(title: "Abbrechen", style: .default, handler: nil)
        confirmMenu.addAction(cancleAction)
        confirmMenu.addAction(confirmAction)
        self.present(confirmMenu, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresher.addTarget(self, action: #selector(getAds), for: .valueChanged)
        collectionView!.addSubview(refresher)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gaUserTracking("Profil")
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        NetworkController.getUserProfile(userToken: userToken!, completion: {(fetchedUser, statusCode) in
        user = fetchedUser
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if userListings.count == 0 {
        if collectionView!.contentOffset.y == 0 {
            UIView.animate(withDuration: 0.25, animations: {
            self.collectionView?.contentOffset.y = -self.refresher.frame.size.height
            }, completion: { _ in
            self.refresher.beginRefreshing()
            })
        }
        }
        getAds()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getAds() {
        if !(isLoading) {
            isLoading = true

        Alamofire.request("https://cfw-api-11.azurewebsites.net/ads/", method: .get, parameters: ["auth":userToken!]).validate().responseJSON (completionHandler: {response in
            self.refresher.endRefreshing()
            if let statusCode = response.response?.statusCode {
            
            switch statusCode {
            case 200:
            let ads = response.result.value as! [[AnyHashable:Any]]
            self.userListings.removeAll()
            if ads.count > 0 {
                for ad in ads {
                    let listing = Listing(value: ad)
                    self.userListings.append(listing)
                }
            }
            self.collectionView?.reloadData()
            
            case 400, 401:
                let errorMenu = UIAlertController(title: "Fehler", message: "Da ist leider etwas schief gegangen, das Laden der Anzeige war nicht erfolgreich.", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: {alert in})
                errorMenu.addAction(confirmAction)
                self.present(errorMenu, animated: true, completion: nil)
            case 404:
            self.collectionView?.reloadData()
            // keine Inserate
            default: break
                }
            }
            self.isLoading = false
        })
        }
    }
    
    



    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userListings.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyAdsCollectionViewCell
        let listing = userListings[indexPath.row]
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed))
        gestureRecognizer.delegate = self
        cell.addGestureRecognizer(gestureRecognizer)
        cell.delegate = self
        cell.listing = listing
        cell.editButton.tag = indexPath.row
        cell.listingTitle.text = listing.title
        cell.listingPrice.text = listing.priceWithCurrency
        cell.listingDate.text = listing.createdDate
        cell.listingImage.image = nil
        if listing.mainImage == nil {
            if let imagePathMedium = listing.imagePathMedium {
                if let imageUrl = URL(string: imagePathMedium) {
                    cell.listingImage.setImage(withUrl: imageUrl)
                    cell.listingImage.layer.add(CATransition(), forKey: nil)
                }
            }
        } else {
            cell.listingImage.image = listing.mainImage
        }
        NetworkController.getImagesFor(adID: String(describing: listing.adID!), completion: { images in
        self.userListings[indexPath.row].images = images
        cell.listing.images = images
        })
        
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
     
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! AccountHeaderView
            if user != nil {
                if user!.firstName != nil && user!.lastName != nil {
                    headerView.userNameLabel.text = user!.firstName! + " " + user!.lastName!
                    headerView.userInitialsLabel.text = String(describing: user!.firstName!.characters.first!) + String(describing: user!.lastName!.characters.first!)
                }
      
                headerView.totalAdsCountLabel.text = "Anzahl Anzeigen: " + String(describing: userListings.count)
            }
            return headerView
            

    }
    

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenwidth - 30)/2, height: screenheight * 0.4)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
    

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AccountshowLocalDetailSegueID" {
            if let cell = sender as? MyAdsCollectionViewCell {
                if cell.listing.adState == .active {
                    if let detailVC = segue.destination as? MyAdsDetailViewController {
                   // detailVC.urlToShow = cell.listing.url
                        detailVC.listing = cell.listing
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
    

    //  MARK: CellSubclassDelegate
    
    func buttonTapped(cell: MyAdsCollectionViewCell) {
        guard let indexPath = self.collectionView?.indexPath(for: cell) else {return}
        print("Button tapped on item \(indexPath.row)")
        showOptionsFor(listing: cell.listing)
    }
    


}
