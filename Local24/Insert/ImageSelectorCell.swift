//
//  ImageSelectorCell.swift
//  Local24
//
//  Created by Nikolai Kratz on 11.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation
import UIKit
import Eureka

// Custom Cell with value type: Bool
// The cell is defined using a .xib, so we can set outlets :)
class ImageSelectorCell: Cell<EquatableImageArray>, CellType {


    @IBOutlet weak var collectionView: UICollectionView!

    
    
    private var imageRow: ImageSelectorRow{ return row as! ImageSelectorRow }
    private var images: [UIImage] {return imageRow.images}
    
    
    public override func setup() {
        super.setup()
        height = {return 200}
//        collectionView.dataSource = self
//        collectionView.delegate = self
        //collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "insertImageCellID")
        //collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "insertAddImageCellID")
        print(images.count)
    }
    

    
    public override func update() {
        super.update()

    }
    
    
    
    
//    
//    
//    // UICollectionView Delegate and DataSource
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return UICollectionViewCell()
//      //  if indexPath.row == images.count {
//          //  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "insertAddImageCellID", for: indexPath) as! AddImageCollectionViewCell
//        //    return cell
//      //  } else {
////            let image = images[indexPath.row]
////            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "insertImageCellID", for: indexPath) as! InsertImageCollectionViewCell
////            cell.tag = indexPath.row
////            cell.imageView.image = image as? UIImage
////            return cell
//        //}
//    }
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 130 , height: 130)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath)
//        //present(imagePicker, animated: true, completion: nil)
//        
//    }
//    
//    
    
}




















// The custom Row also has the cell: CustomCell and its correspond value
final class ImageSelectorRow: Row<ImageSelectorCell>, RowType {
    
    open var images: [UIImage]!
    
    required public init(tag: String?) {
        super.init(tag: tag)
//        presentationMode = .presentModally(controllerProvider: ControllerProvider.callback {
//            return LocalImagePickerController()
//            }, onDismiss: { vc in
//                _ = vc.navigationController?.popViewController(animated: true)
//        })
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ImageSelectorCell>(nibName: "ImageSelectorCell")
    }
}


class EquatableImageArray :Equatable {

    var values = [UIImage]()
    
    static func == (lhs: EquatableImageArray, rhs: EquatableImageArray) -> Bool {
        return lhs.values == rhs.values
    }
}


