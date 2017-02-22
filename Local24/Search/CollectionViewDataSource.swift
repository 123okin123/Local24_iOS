//
//  CollectionViewDataSource.swift
//  Local24
//
//  Created by Local24 on 22/02/2017.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation
import UIKit


class CollectionViewDataSource :NSObject, UICollectionViewDataSource {
    
    var searchViewController :SearchViewController!
    
    init(collectionView: UICollectionView, viewController: SearchViewController) {
        super.init()
        collectionView.dataSource = self
        self.searchViewController = viewController
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchViewController.listings.count/* + numberOfAds*/
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if searchViewController.isloading {
            return configureLoadingCell(collectionView: collectionView, indexPath: indexPath)
        } else {
            //                if
            //                    (indexPath.row + 1) % adDensity == 0
            //                    // is ad available at index
            //                    && (indexPath.item % (adDensity - 1)) < numberOfAds {
            //                    return configureAdCellAt(indexPath: indexPath)
            //                } else {
            return configureListingCellAt(collectionView: collectionView, indexPath: indexPath)
            //                }
        }
    }
    
    func configureLoadingCell(collectionView: UICollectionView, indexPath :IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
        UIView.animate(withDuration: 0.6, delay: 0, options: [.autoreverse, .curveEaseInOut, .repeat], animations: {
            cell.titleLoadingView.alpha = 0.5
            cell.dateLoadingView.alpha = 0.5
            cell.distanceLoadingView.alpha = 0.5
        }, completion: { done in
            cell.titleLoadingView.alpha = 1
            cell.dateLoadingView.alpha = 1
            cell.distanceLoadingView.alpha = 1
        })
        return cell
    }
    
    
    
    
    
    func configureListingCellAt(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListingsCell", for: indexPath) as! CollectionViewCell
        var index:Int!
        //        if (indexPath.item % (adDensity - 1)) < numberOfAds {
        //            index = indexPath.item - (indexPath.item / adDensity)
        //        } else {
        index = indexPath.item
        //        }
        let listing = searchViewController.listings[index]
        
        cell.listingTitle.text = listing.title
        cell.listingPrice.text = listing.priceWithCurrency
        cell.listingDate.text = listing.createdDate
        cell.listing = listing
        if let distance = listing.distance {
            if let city = listing.city {
                cell.listingDistance.text = city + " (" + String(Int(distance)) + "km)"
            }
        } else {
            cell.listingDistance.text = listing.city
        }
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
    
    //    func configureAdCellAt(indexPath: IndexPath) -> UICollectionViewCell {
    //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListingsAdCell", for: indexPath) as! SearchCollectionViewAdCell
    //
    //            let ad = ads[indexPath.item % (adDensity - 1)]
    //            cell.adTitleLabel.text = ad.adBody
    //            cell.adImageView.image = ad.adIconImage
    //            cell.adCallToActionButton.setTitle(ad.adCallToActionString, for: UIControlState())
    //            let adView = ad.adView!
    //            adView.frame = cell.cellContentView.frame
    //            cell.cellContentView.addSubview(adView)
    //            ad.icon?.loadAsync(block: { (image :UIImage?) -> Void in
    //            ad.adIconImage = image
    //            cell.adImageView.image = image
    //            })
    //        
    //        return cell
    //    }
    
    

}
