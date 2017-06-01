//
//  MutiplePushRow.swift
//  Local24
//
//  Created by Nikolai Kratz on 18.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka
import EquatableArray

final class MutiplePushRow: SelectorRow<PushSelectorCell<String>, MutiStepSelectorViewController>, RowType {
    
    /// Number of steps the multiple Selection has
    var numberOfSteps = 1
    /// Callback providing options for the selectorviewcontroller based on the choosen option of the previous selectorviewcontroller and the step
    var optionsForOption: ((_ option: String, _ step: Int) -> [String])?
    /// Array of selected values in which values are added while going through the steps
    var selectedValues = [String]()
    
    var stepsTaken = 0
    
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return MutiStepSelectorViewController()
            }, onDismiss: { vc in
                guard let navVC = vc.navigationController else {return}
                let formVCIndex = navVC.viewControllers.count - (vc as! MutiStepSelectorViewController).stepsTaken - 1
                let firstStepVCIndex = navVC.viewControllers.count - (vc as! MutiStepSelectorViewController).stepsTaken
                
                let formVC = navVC.viewControllers[formVCIndex]
                let firstStepVC = navVC.viewControllers[firstStepVCIndex] as! MutiStepSelectorViewController
                
                firstStepVC.mutiplePushRow.selectedValues.removeAll()
                firstStepVC.mutiplePushRow.selectedValues = self.selectedValues
                firstStepVC.mutiplePushRow.value = self.value
                _ = vc.navigationController?.popToViewController(formVC, animated: true)
        })
    }
}
