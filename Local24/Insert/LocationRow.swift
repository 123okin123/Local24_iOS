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
public class LocationCell: Cell<Bool>, CellType {

    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var houseNumberLabel: UILabel!
    @IBOutlet weak var zipCodeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    private var locationRow: LocationRow{ return row as! LocationRow }
    
    public override func setup() {
        super.setup()
        backgroundColor = UIColor.clear
        height = {return 70}
        accessoryType = .disclosureIndicator
        editingAccessoryType = accessoryType
    }
    

    
    public override func update() {
        super.update()
//        if locationRow.placemark != nil {
//            cityLabel.text = locationRow.placemark?.addressDictionary?["City"] as? String
//            streetLabel.text = locationRow.placemark?.addressDictionary?["Thoroughfare"] as? String
//            houseNumberLabel.text = locationRow.placemark?.addressDictionary?["SubThoroughfare"] as? String
//            zipCodeLabel.text = locationRow.placemark?.postalCode
//        } else {
//            streetLabel.text = "Artikelstandort wählen..."
//        }
        
        if locationRow.location != nil {
            cityLabel.text = locationRow.city
            streetLabel.text = locationRow.street
            houseNumberLabel.text = locationRow.houseNumber
            zipCodeLabel.text = locationRow.zipCode
        } else {
            streetLabel.text = "Artikelstandort wählen..."
        }
    }
    
    
}

// The custom Row also has the cell: CustomCell and its correspond value
final class LocationRow: SelectorRow<LocationCell, ChooseLocationViewController>, RowType {
    
    var location: CLLocation?
    var city: String?
    var street :String?
    var houseNumber :String?
    var zipCode :String?
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.storyBoard(storyboardId: "ChooseLocationViewControllerID", storyboardName: "Main", bundle: nil), onDismiss: { vc in
            guard let vc = vc as? ChooseLocationViewController else {return}
      
            guard let placemark = vc.currentLocationPlacemark else {
                self.value = nil
                return
            }
            self.location = placemark.location
            self.city = placemark.addressDictionary?["City"] as? String
            self.street = placemark.addressDictionary?["Thoroughfare"] as? String
            self.houseNumber = placemark.addressDictionary?["SubThoroughfare"] as? String
            self.zipCode = placemark.postalCode
            
            if self.value != nil {
                self.value = !self.value!
            } else {
                self.value = true
            }
            self.updateCell()
        })
        cellProvider = CellProvider<LocationCell>(nibName: "LocationCell")
    }

}
