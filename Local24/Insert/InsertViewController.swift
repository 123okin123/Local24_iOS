//
//  InsertViewController.swift
//  Local24
//
//  Created by Nikolai Kratz on 11.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAnalytics
import EquatableArray
import CoreLocation
import Contacts

class InsertViewController: FormViewController {

    var listingExists = false
    var listing = Listing()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if listingExists {
            navigationItem.setHidesBackButton(false, animated: false)
        } else {
            navigationItem.setHidesBackButton(true, animated: false)
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
        NetworkManager.shared.getUserProfile(userToken: userToken!, completion: {(fetchedUser, statusCode) in
            user = fetchedUser
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TextRow.defaultCellUpdate = { cell, row in cell.textLabel?.font = UIFont(name: "OpenSans", size: 17.0) }
        SwitchRow.defaultCellUpdate = { cell, row in cell.switchControl?.onTintColor = greencolor }
        tableView?.backgroundColor = local24grey
        tableView?.separatorColor = local24grey
        navigationAccessoryView.tintColor = greencolor
      
        
        form
            +++ Section()
            <<< ImageSelectorRow() {
                if let images = listing.images {
                    $0.value = EquatableArray(images)
                }
                }.cellUpdate { cell, row in
                    
                }.onChange { row in
                    self.listing.images = row.value?.map({return $0})
            }
            
            
            +++ Section()
            
            <<< TextRow() {
                $0.placeholder = "Titel"
                $0.add(rule: RuleMinLength(minLength: 5))
                $0.add(rule: RuleRequired())
                $0.value = listing.title
                }.cellUpdate { (cell, row) in
                    self.showValidationStatusOfCell(cell, andRow: row)
                }.onChange {
                    self.listing.title = $0.value
            }
            
            <<< MutiplePushRow() {
                $0.title = "Kategorie"
                $0.add(rule: RuleRequired())
                $0.numberOfSteps = 2
                if let subCat = CategoryManager.shared.subCategories.first(where: {$0.id == listing.catID}) {
                    if let mainCat = CategoryManager.shared.mainCategories.first(where: {subCat.idParentCategory == $0.id}) {
                        $0.selectedValues = [mainCat.name, subCat.name]
                        $0.value = subCat.name
                    }
                }
                $0.options = CategoryManager.shared.mainCategories.map({$0.name})
                $0.optionsForOption = {(option, step) in
                    guard let currentMainCatID = CategoryManager.shared.mainCategories.first(where: {$0.name == option})?.id else {return [""]}
                    let subCats = CategoryManager.shared.subCategories.filter({$0.idParentCategory == currentMainCatID})
                    return subCats.map({$0.name})
                    }
                }.cellUpdate { (cell, row) in
                    self.showValidationStatusOfCell(cell, andRow: row)
                    let category = CategoryManager.shared.subCategories.first(where: {$0.name == row.value})
                    self.listing.entityType = category?.adclass
                    self.listing.catID = category?.id
                }.onPresent { from, to in
                    to.multiStepCellUpdate = {(cell, row, step) in
                        cell.textLabel?.font = UIFont(name: "OpenSans", size: 17.0)
                        cell.tintColor = greencolor
                    }
            }
            
            
            
            
            +++ Section("Beschreibung")
            <<< TextAreaRow() {
                $0.placeholder = "Beschreibung des Artikels"
                $0.value = listing.adDescription
                $0.add(rule: RuleMinLength(minLength: 10))
                $0.add(rule: RuleRequired())
                }.onChange { row in
                    self.listing.adDescription = row.value
                }.cellUpdate { (cell, row) in
                    self.showValidationStatusOfCell(cell, andRow: row)
            }
            
            
            +++ Section("Preisinformationen")

            <<< SegmentedRow<String>() {
                $0.options = ["Ich biete", "Ich suche"]
                if let adType = listing.adType {
                    switch adType {
                    case .Gesuch:   $0.value = "Ich suche"
                    case .Angebot:  $0.value = "Ich biete"
                    }
                } else {$0.value = "Ich biete"; listing.adType = .Angebot}
                }.cellUpdate { cell, row in
                    if let adType = self.listing.adType {
                        switch adType {
                        case .Gesuch:   row.value = "Ich suche"
                        case .Angebot:  row.value = "Ich biete"
                        }
                    } else {row.value = "Ich biete"; self.listing.adType = .Angebot}
                }.onChange {
                    guard let value = $0.value else {return}
                    (value == "Ich suche") ? (self.listing.adType = .Gesuch) : (self.listing.adType = .Angebot)
            }
            <<< ActionSheetRow<String>() {
                $0.title = "Preisart"
                $0.selectorTitle = "Bitte wähle deine Preisart"
                $0.options = Array(PriceType.allValues.values)
                $0.value = listing.priceType ?? "VHB"
                }.cellUpdate { (cell, row) in
                    self.listing.priceType = row.value
            }
            <<< DecimalRow(){
                $0.useFormatterDuringInput = true
                $0.title = "Preis"
                $0.add(rule: RuleRequired())
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
                if let price = self.listing.price {
                    $0.value = Double(price)
                }
                }.cellUpdate {cell, row in
                    self.showValidationStatusOfCell(cell, andRow: row)
                }.onChange {
                    guard let value = $0.value else {return}
                    self.listing.price = String(describing: value)
            }
            
        
            +++ Section()
            <<< LocationRow() {
                    $0.add(rule: RuleRequired())
                    guard let adLat = self.listing.adLat else {return}
                    guard let adLong = self.listing.adLong else {return}
                    $0.city = self.listing.city
                    $0.location = CLLocation(latitude: adLat, longitude: adLong)
                    $0.street = self.listing.street
                    $0.houseNumber = self.listing.houseNumber
                    $0.zipCode = self.listing.zipcode
                }.onChange { row in
                    guard let location = row.location else {return}
                    self.listing.adLat = location.coordinate.latitude
                    self.listing.adLong = location.coordinate.longitude
                    self.listing.city = row.city
                    self.listing.street = row.street
                    self.listing.houseNumber = row.houseNumber
                    self.listing.zipcode = row.zipCode
            }
        
        
            +++ Section()
            <<< BasicButtonRow() {
                $0.buttonPressedCallback = {cell, row in
                    if self.form.validate().isEmpty {
                        self.insertListing()
                    }
                }
                }

    }
    
    
    func showValidationStatusOfCell(_ cell: BaseCell, andRow row: BaseRow) {
        if !row.isValid {
            cell.layer.borderColor = UIColor(red: 224/255, green: 60/255, blue: 49/255, alpha: 0.5).cgColor
            cell.layer.borderWidth = 2
        } else {
            cell.layer.borderColor = nil
            cell.layer.borderWidth = 0
        }
    }
    
    func insertListing() {
            let pendingAlertController = UIAlertController(title: "Anzeige wird erstellt\n\n\n", message: nil, preferredStyle: .alert)
            let indicator = UIActivityIndicatorView(frame: pendingAlertController.view.bounds)
            indicator.autoresizingMask = [.flexibleWidth, . flexibleHeight]
            indicator.color = UIColor.darkGray
            pendingAlertController.view.addSubview(indicator)
            indicator.isUserInteractionEnabled = false
            let cancleAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: { _ in NetworkManager.shared.cancelCurrentRequest()})
            pendingAlertController.addAction(cancleAction)
            indicator.startAnimating()
            present(pendingAlertController, animated: true, completion: nil)
            
            
            
            
            var values = [
                "ID_Advertiser": user!.id!,
                "ID_Category" : listing.catID!,
                "EntityType" : listing.entityType!.rawValue,
                "AdType": listing.adType!.rawValue,
                "Title": listing.title!,
                "Body": listing.adDescription!,
                "PriceType": listing.priceType!,
                "Price": listing.price!,
                "City": listing.city!,
                "ZipCode": listing.zipcode!
                ] as [String : Any]
            
            if listingExists {
                values["ID"] = String(listing.adID!)
            }
            
            // Optional Values
            if let adLat = listing.adLat {
                values["Latitude"] = adLat
            }
            if let adLong = listing.adLong {
                values["Longitude"] = adLong
            }
            if let street = listing.street {
                values["Street"] = street
            }
            if let houseNumber = listing.houseNumber {
                values["HouseNumber"] = houseNumber
            }

            
//            listing.specialFields = [SpecialField]()
//            listing.specialFields?.append(contentsOf: customFields)
//            
//            switch listing.entityType! {
//            case .AdCar:
//                let independetField = SpecialField(name: "Make", descriptiveString: "Marke",type: .string, value: independentFieldLabel.text)
//                let dependentField = SpecialField(name: "Model", descriptiveString: "Model",type: .string, value: dependentFieldLabel.text)
//                listing.specialFields?.append(independetField)
//                listing.specialFields?.append(dependentField)
//            case .AdApartment, .AdHouse:
//                let independetField = SpecialField(name: "SellOrRent", descriptiveString: "Verkauf oder Vermietung",type: .string, value: independentFieldLabel.text)
//                let dependentField = SpecialField(name: "PriceTypeProperty", descriptiveString: "Preisart",type: .string, value: dependentFieldLabel.text)
//                listing.specialFields?.append(independetField)
//                listing.specialFields?.append(dependentField)
//            default:
//                break
//            }
//            
//            if listing.specialFields!.count > 0 {
//                for specialField in listing.specialFields! {
//                    if let name = specialField.name {
//                        if let value = specialField.value {
//                            values[name] = value
//                        }
//                    }
//                }
//            }
            // End of Optional Values
            
            print(values)
            NetworkManager.shared.insertAdWith(values: values, images: listing.images, existing: listingExists, userToken: userToken!, completion: { errorString in
                pendingAlertController.dismiss(animated: true, completion: {
                    if errorString == nil {
                        
                        let successMenu = UIAlertController(title: "Anzeige aufgegeben", message: "Herzlichen Glückwunsch Ihre Anzeige wurde erfolgreich aufgegeben.", preferredStyle: .alert)
                        let confirmAction = UIAlertAction(title: "Ok", style: .cancel, handler: {alert in
                            _ = self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                        })
                        successMenu.addAction(confirmAction)
                        self.present(successMenu, animated: true, completion: nil)
                    } else {
                        let errorMenu = UIAlertController(title: "Fehler", message: errorString, preferredStyle: .alert)
                        let confirmAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                        errorMenu.addAction(confirmAction)
                        self.present(errorMenu, animated: true, completion: nil)
                    }
                })
            })
            
            
        
        

    }


}
