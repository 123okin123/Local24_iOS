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

final class MutiplePushRow<T: Equatable>: SelectorRow<PushSelectorCell<EquatableArray<String>>, MutiStepSelectorViewController>, RowType {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return MutiStepSelectorViewController()
            }, onDismiss: { vc in
                _ = vc.navigationController?.popViewController(animated: true)
        })
    }
}
