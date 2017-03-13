//
//  FilterCollectionViewDelegate.swift
//  Local24
//
//  Created by Nikolai Kratz on 15.02.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation
import UIKit

class FilterCollectionViewDelegate :NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //MARK: Variables
    
    var collectionViewController :UIViewController?
    
    
    init(collectionView: UICollectionView, viewController: UIViewController) {
        super.init()
        collectionView.delegate = self
        collectionViewController = viewController
    }
    
    //MARK: UICollectionViewDelegate
    
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





