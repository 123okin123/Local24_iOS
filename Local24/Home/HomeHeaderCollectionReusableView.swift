//
//  HomeHeaderCollectionReusableView.swift
//  Local24
//
//  Created by Local24 on 24/01/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import MapleBacon

private let featuredListingsCellID = "featuredListingsCellID"
private let loadFeaturedListingsCellID = "loadFeaturedListingsCellID"
class HomeHeaderCollectionReusableView: UICollectionReusableView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var featuredListingsCollectionView: UICollectionView!
    @IBOutlet weak var currentLocationButton: UIButton! {didSet {
        currentLocationButton.layer.cornerRadius = 5
        }}
    
    // MARK: Variables
    
    var homeViewController :HomeViewController!
    

    override func prepareForReuse() {   
        featuredListingsCollectionView.delegate = self
        featuredListingsCollectionView.dataSource = self
        featuredListingsCollectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if homeViewController.isLoadingFeaturedListings {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: loadFeaturedListingsCellID, for: indexPath) as UICollectionViewCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: featuredListingsCellID, for: indexPath) as! FeaturedListingsCell
            let listing = homeViewController.featuredListings[indexPath.item]
            cell.titleLabel.text = listing.title
            cell.priceLabel.text = listing.priceWithCurrency
            if listing.thumbImage == nil {
                if let thumbImageURL = listing.thumbImageURL {
                    if let imageUrl = URL(string: thumbImageURL) {
                        cell.imageView.setImage(withUrl: imageUrl, placeholder: UIImage(named: "home_Background"), crossFadePlaceholder: true, cacheScaled: true, completion: { instance, error in
                            if instance?.image != nil {
                                cell.imageView.layer.add(CATransition(), forKey: nil)
                                cell.imageView.image = instance?.image
                                listing.thumbImage = instance?.image
                            } else {
                                let image = UIImage(named: "home_Background")
                                cell.imageView.image = image
                            }
                        })
                    }
                } else {
                    let image = UIImage(named: "home_Background")
                    cell.imageView.image = image
                }
            } else {
                cell.imageView.image = listing.thumbImage
            }
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeViewController.featuredListings.count
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let listing = homeViewController.featuredListings[indexPath.item]
        if let detailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailViewControllerID") as? LocalDetailTableViewController {
            detailVC.listing = listing
            homeViewController.navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    
}





class FeaturedListingsCollectionViewFlowLayout :UICollectionViewFlowLayout {
    override func awakeFromNib() {
        self.itemSize = CGSize(width: 110, height: 175)
        self.minimumInteritemSpacing = 10
        self.minimumLineSpacing = 10
        self.scrollDirection = .horizontal
        self.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

}




