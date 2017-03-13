//
//  FilterCollectionViewDataSource.swift
//  Local24
//
//  Created by Nikolai Kratz on 16.02.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation
import UIKit

class FilterCollectionViewDataSource :NSObject, UICollectionViewDataSource {
    
    //MARK: Variables
    
    var collectionViewController :UIViewController?
    
    
    
    init(collectionView: UICollectionView, viewController: UIViewController) {
        super.init()
        collectionView.dataSource = self
        collectionViewController = viewController
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCollectionViewCell
        cell.filtername.text = FilterManager.shared.filters[indexPath.row].descriptiveString
        
        let filter = FilterManager.shared.filters[indexPath.row]
        switch filter.filterType! {
        case .sort:
            let sortFilter = filter as! Sortfilter
            cell.filtervalue.text = sortingOptions.first(where: {$0.order == sortFilter.order && $0.criterium == sortFilter.criterium})?.descriptiveString
            cell.imageViewWidthConstraint.constant = 0
        case .term:
            let termFilter = filter as! Termfilter
            if termFilter.name == .sourceId {
                cell.filtervalue.text = ""
            } else {
                cell.filtervalue.text = termFilter.value
            }
            cell.imageViewWidthConstraint.constant = 10
        case .geo_distance:
            let geoFilter = filter as! Geofilter
            cell.filtervalue.text = geoFilter.value
            cell.imageViewWidthConstraint.constant = 0
        case .search_string:
            let searchFilter = filter as! Stringfilter
            cell.filtervalue.text = searchFilter.queryString
            cell.imageViewWidthConstraint.constant = 10
        case .range:
            let rangeFilter = filter as! Rangefilter
            var value = ""
            if let gte = rangeFilter.gte {
                value += "von \(Int(gte))€ "
            }
            if let lte = rangeFilter.lte {
                value += "bis \(Int(lte))€"
            }
            cell.filtervalue.text = value
            cell.imageViewWidthConstraint.constant = 10
        }
        
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FilterManager.shared.filters.count
    }
}
