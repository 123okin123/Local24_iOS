//
//  InsertPicker.swift
//  Local24
//
//  Created by Local24 on 27/12/2016.
//  Copyright © 2016 Nikolai Kratz. All rights reserved.
//

import UIKit

//InsertPicker
extension InsertTableViewController: UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        currentTextField = textField
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Fertig", style: .plain, target: self, action: #selector(pickerDonePressed))
        let previousButton  = UIBarButtonItem(image: UIImage(named: "previousArrow"), style: .plain, target: self, action: #selector(pickerPreviousPressed))
        previousButton.width = 50.0
        let nextButton  = UIBarButtonItem(image: UIImage(named: "nextArrow"), style: .plain, target: self, action: #selector(pickerNextPressed))
        nextButton.width = 50.0
        
        if let index = customFieldCellCollection.index(where:{$0.textField == currentTextField}) {
            currentPickerArray = customFields[index].possibleStringValues!
            toolBar.setItems([previousButton, nextButton, spaceButton, doneButton], animated: false)
            customFieldCellCollection[index].textField.inputView = pickerView
            customFieldCellCollection[index].textField.inputAccessoryView = toolBar
            if let selectedIndex = currentPickerArray.index(where: {$0 == customFieldCellCollection[index].textField.text}) {
                pickerView.selectRow(selectedIndex, inComponent: 0, animated: true)
                customFields[index].value = customFields[index].possibleValues?[selectedIndex]
            } else {
                pickerView.selectRow(0, inComponent: 0, animated: true)
                currentTextField.text = currentPickerArray[0]
                customFields[index].value = customFields[index].possibleValues?[0]
            }
        }
        
        switch currentTextField {
        case adTypeTextField:
            toolBar.setItems([spaceButton, doneButton], animated: false)
            adTypeTextField.inputView = pickerView
            adTypeTextField.inputAccessoryView = toolBar
            currentPickerArray = Array(AdType.allValues.values)
        case priceTypeTextField:
            toolBar.setItems([spaceButton, doneButton], animated: false)
            priceTypeTextField.inputView = pickerView
            priceTypeTextField.inputAccessoryView = toolBar
            currentPickerArray = Array(PriceType.allValues.values)
        default: break
        }
        
        
        pickerView.reloadAllComponents()
        return true
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentPickerArray.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentPickerArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if let index = customFieldCellCollection.index(where:{$0.textField == currentTextField}) {
            customFields[index].value = customFields[index].possibleValues?[row]
        }
        currentTextField.text = currentPickerArray[row]

    }
    func pickerDonePressed() {
        view.endEditing(true)
    }
    func pickerPreviousPressed() {
        currentTextField.resignFirstResponder()
        if let previousTextField = view.viewWithTag(currentTextField.tag - 1) as? UITextField {
            previousTextField.becomeFirstResponder()
        }
    }
    func pickerNextPressed() {
        currentTextField.resignFirstResponder()
        if let nextTextField = view.viewWithTag(currentTextField.tag + 1) as? UITextField {
           nextTextField.becomeFirstResponder()
        }
        
    }
    
}
