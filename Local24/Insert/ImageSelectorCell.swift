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
import Photos

// Custom Cell with value type: Bool
// The cell is defined using a .xib, so we can set outlets :)
class ImageSelectorCell: Cell<EquatableArray<UIImage>>, CellType, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, ImageCellDelegate {


    @IBOutlet weak var collectionView: UICollectionView!

    
    
    private var imageRow: ImageSelectorRow{ return row as! ImageSelectorRow }
    private var equatableImageArray: EquatableArray<UIImage>? {return imageRow.value}
    
    
    public override func setup() {
        super.setup()
        height = {return 130}
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
    

    // MARK: - UICollectionView Delegate and DataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row == equatableImageArray?.count || equatableImageArray == nil) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addImageCellID", for: indexPath)
            return cell
        } else {
            let image = equatableImageArray?[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCellID", for: indexPath) as! ImageCell
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
        return (equatableImageArray?.count ?? 0) + 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130 , height: 130)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        imageRow.didSelectItemAt(indexPath)
    }
    
    // MARK: - ImageCellDelegate
    func deleteButtonTapped(cell: ImageCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {return}
        imageRow.value?.remove(at: indexPath.item)
        imageRow.assetStack.remove(at: indexPath.item)
        collectionView.deleteItems(at: [indexPath])
    }
    
}



// The custom Row also has the cell: CustomCell and its correspond value
final class ImageSelectorRow: SelectorRow<ImageSelectorCell, LocalImagePickerController>, RowType, ImagePickerDelegate {

    var assetStack = [PHAsset]()
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
        imagePicker.stack.assets = assetStack
        presentationMode?.present(imagePicker, row: self, presentingController: cell.formViewController()!)
    }
    
    // MARK: ImagePickerDelegate
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        assetStack = imagePicker.stack.assets
        cell.collectionView.reloadData()
        imagePicker.dismiss(animated: true, completion: nil)
        guard let value = value else {return}
        cell.collectionView.scrollToItem(at: IndexPath(item: value.endIndex, section: 0), at: .right, animated: true)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        value = EquatableArray(images)
        assetStack = imagePicker.stack.assets
        cell.collectionView.reloadData()
        guard value != nil else {return}
        cell.collectionView.scrollToItem(at: IndexPath(item: value!.endIndex, section: 0), at: .right, animated: true)
        imagePicker.dismiss(animated: true, completion: nil)
    }
}


