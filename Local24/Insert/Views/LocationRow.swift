//
//  LocationRow.swift
//  Local24
//
//  Created by Nikolai Kratz on 23.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka
import CoreLocation


// Location Cell with value type: Bool
class LocationCell: Cell<ListingLocation>, CellType {

    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var houseNumberLabel: UILabel!
    @IBOutlet weak var zipCodeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    //private var locationRow: LocationRow{ return row as! LocationRow }
    
    public override func setup() {
        super.setup()
        backgroundColor = UIColor.clear
        height = {return 70}
        accessoryType = .disclosureIndicator
        editingAccessoryType = accessoryType
    }
    

    
    public override func update() {
        super.update()

        if row.value != nil {
            cityLabel.text = row.value?.city
            streetLabel.text = row.value?.street
            houseNumberLabel.text = row.value?.houseNumber
            zipCodeLabel.text = row.value?.zipCode
        } else {
            cityLabel.text = nil
            streetLabel.text = "Artikelstandort wählen..."
            houseNumberLabel.text = nil
            zipCodeLabel.text = nil
        }
    }
    
    
}

// The custom Row also has the cell: CustomCell and its correspond value
final class LocationRow: SelectorRow<LocationCell, ChooseLocationViewController>, RowType {

    
    //var listingLocation :ListingLocation?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        
        presentationMode = .show(controllerProvider: ControllerProvider.storyBoard(storyboardId: "ChooseLocationViewControllerID", storyboardName: "Main", bundle: nil), onDismiss: { vc in
            guard let vc = vc as? ChooseLocationViewController else {return}
            self.value = vc.listingLocation
            self.updateCell()
        })
        cellProvider = CellProvider<LocationCell>(nibName: "LocationCell")
    }
 
    

}
