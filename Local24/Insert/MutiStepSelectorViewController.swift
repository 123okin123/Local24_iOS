//
//  MutiStepSelectorViewController.swift
//  Local24
//
//  Created by Nikolai Kratz on 18.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import UIKit
import Eureka
import EquatableArray

class MutiStepSelectorViewController: UINavigationController, TypedRowControllerType {
    /// The row that pushed or presented this controller
    public var row: RowOf<EquatableArray<String>>!
    
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [FormViewController(), FormViewController()]
    }
}
