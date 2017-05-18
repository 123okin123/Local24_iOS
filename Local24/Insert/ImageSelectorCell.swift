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
import EquatableArray
import ImagePicker

// Custom Cell with value type: Bool
// The cell is defined using a .xib, so we can set outlets :)
class ImageSelectorCell: Cell<EquatableArray<UIImage>>, CellType, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {


    @IBOutlet weak var collectionView: UICollectionView!

    
    
    private var imageRow: ImageSelectorRow{ return row as! ImageSelectorRow }
    private var equatableImageArray: EquatableArray<UIImage>? {return imageRow.value}
    
    
    public override func setup() {
        super.setup()
        height = {return 150}
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: "imageCellID")
        collectionView.register(UINib(nibName: "AddImageCell", bundle: nil), forCellWithReuseIdentifier: "addImageCellID")
        backgroundColor = UIColor.clear
        
    }
    

    
    public override func update() {
        super.update()

    }
    

    // UICollectionView Delegate and DataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == equatableImageArray?.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addImageCellID", for: indexPath)
            return cell
        } else {
            let image = equatableImageArray?[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCellID", for: indexPath) as! InsertImageCollectionViewCell
            cell.tag = indexPath.row
            cell.imageView.image = image
            return cell
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (equatableImageArray?.count ?? 0) + 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130 , height: 130)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        imageRow.didSelectItemAt(indexPath)
    }
    
    
    
}


// Row<ImageSelectorCell>
// The custom Row also has the cell: CustomCell and its correspond value
final class ImageSelectorRow: SelectorRow<ImageSelectorCell, LocalImagePickerController>, RowType, ImagePickerDelegate {

    
    var imagePicker :LocalImagePickerController!
    
    required public init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .presentModally(controllerProvider: ControllerProvider.callback {
            return LocalImagePickerController()
            }, onDismiss: { vc in
                _ = vc.navigationController?.popViewController(animated: true)
        })
    
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ImageSelectorCell>(nibName: "ImageSelectorCell")
    }
    
    func didSelectItemAt(_ indexPath: IndexPath) {
        imagePicker = presentationMode?.makeController()
        imagePicker.delegate = self
        presentationMode?.present(imagePicker, row: self, presentingController: cell.formViewController()!)
    }
    
    // MARK: ImagePickerDelegate
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        guard value != nil else {return}
        value!.removeAll()
        cell.collectionView.reloadData()
        cell.collectionView.scrollToItem(at: IndexPath(item: value!.endIndex, section: 0), at: .right, animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        value = EquatableArray(images)
        cell.collectionView.reloadData()
        guard value != nil else {return}
        cell.collectionView.scrollToItem(at: IndexPath(item: value!.endIndex, section: 0), at: .right, animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
    }
}


