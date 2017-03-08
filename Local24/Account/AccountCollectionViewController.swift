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
private let insertListingIdentifier = "InsertListingCellID"

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
        NetworkManager.shared.changeAdWith(adID: listing.adID!, to: adState, userToken: userToken!, completion: {error in
            if error == nil {
                if let index = self.userListings.index(where: {$0.adID == listing.adID}) {
                    self.userListings[index].adState = AdState(rawValue: adState)
                    self.collectionView?.reloadItems(at: [IndexPath(item: index, section: 0)])
                    self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0))?.layer.add(CATransition(), forKey: nil)
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
            NetworkManager.shared.deleteAdWith(adID: listing.adID!, userToken: userToken!, completion: { error in
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
        getAds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //gaUserTracking("Profil")
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        NetworkManager.shared.getUserProfile(userToken: userToken!, completion: {(fetchedUser, statusCode) in
            user = fetchedUser
            self.collectionView?.reloadData()
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackScreen("Profil")
//        if userListings.count == 0 {
//        if collectionView!.contentOffset.y == 0 {
//            UIView.animate(withDuration: 0.25, animations: {
//            self.collectionView?.contentOffset.y = -self.refresher.frame.size.height
//            }, completion: { _ in
//            self.refresher.beginRefreshing()
//            })
//            self.getAds()
//        }
//        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getAds() {
        if !(isLoading) {
            isLoading = true
            NetworkManager.shared.getOwnAds(userToken: userToken!, completion: {(error, listings) in
                self.refresher.endRefreshing()
                if error == nil {
                    self.userListings.removeAll()
                    if listings != nil {
                        self.userListings = listings!
                    }
                } else {
                    let errorMenu = UIAlertController(title: "Fehler", message: "Da ist leider etwas schief gegangen, das Laden der Anzeige war nicht erfolgreich.", preferredStyle: .alert)
                    let confirmAction = UIAlertAction(title: "Ok", style: .default, handler: {alert in})
                    errorMenu.addAction(confirmAction)
                    self.present(errorMenu, animated: true, completion: nil)
                    
                }
                self.collectionView?.reloadData()
                self.isLoading = false
            })
            
        }
    }
    
    



    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return userListings.count + 1
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item <= userListings.count - 1 {
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
        
        if listing.thumbImage == nil {
            if let thumbImageURL = listing.thumbImageURL {
                if let imageUrl = URL(string: thumbImageURL) {
                    cell.listingImage.setImage(withUrl: imageUrl, placeholder: UIImage(named: "home_Background"), crossFadePlaceholder: true, cacheScaled: true, completion: { instance, error in
                        cell.listingImage.layer.add(CATransition(), forKey: nil)
                        self.userListings[indexPath.row].thumbImage = instance?.image
                    })
                    
                }
            } else {
                let image = UIImage(named: "home_Background")
                cell.listingImage.image = image
            }
        } else {
            cell.listingImage.image = listing.thumbImage
        }
        NetworkManager.shared.getImagesFor(adID: listing.adID, completion: { images in
        self.userListings[indexPath.row].images = images
        cell.listing.images = images
        })
        return cell
        } else {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: insertListingIdentifier, for: indexPath) as! InsertListingCell
        return cell
        }

    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
     
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! AccountHeaderView
            if user != nil {
                if user!.firstName != nil && user!.lastName != nil {
                    headerView.userNameLabel.text = user!.firstName! + " " + user!.lastName!
                    if let firstCharacter = user?.firstName?.characters.first {
                        if let secondCharacter = user?.lastName?.characters.first {
                            headerView.userInitialsLabel.text = String(describing: firstCharacter) + String(describing: secondCharacter)
                        }
                    }
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
    
    @IBAction func backFromEditProfileToProfil(_ segue: UIStoryboardSegue) {
    }
    @IBAction func saveAndBackFromEditProfileToProfil(_ segue: UIStoryboardSegue) {
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == userListings.count {
            if let tabBarVC = tabBarController as? TabBarController {
            tabBarVC.insertButtonAction()
            }
        }
    }
    

    //  MARK: CellSubclassDelegate
    
    func buttonTapped(cell: MyAdsCollectionViewCell) {
        guard let indexPath = self.collectionView?.indexPath(for: cell) else {return}
        print("Button tapped on item \(indexPath.row)")
        showOptionsFor(listing: cell.listing)
    }
    


}
