//
//  InsertImageCollection.swift
//  Local24
//
//  Created by Local24 on 27/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit
import ImagePicker

// InsertImageCollection
extension InsertTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ImagePickerDelegate {
    


    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == imageArray.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "insertAddImageCellID", for: indexPath) as! AddImageCollectionViewCell
            return cell
        } else {
            let image = imageArray[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "insertImageCellID", for: indexPath) as! InsertImageCollectionViewCell
            cell.tag = indexPath.row
            cell.imageView.image = image
            cell.delegate = self
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130 , height: 130)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    
    
    // MARK: ImagePickerDelegate
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imageArray.removeAll()
        imageCollectionView.reloadData()
        imageCollectionView.scrollToItem(at: IndexPath(item: imageArray.endIndex, section: 0), at: .right, animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imageArray = images
        imageCollectionView.reloadData()
        imageCollectionView.scrollToItem(at: IndexPath(item: imageArray.endIndex, section: 0), at: .right, animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    


}
