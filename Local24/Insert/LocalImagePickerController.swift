//
//  LocalImagePickerController.swift
//  Local24
//
//  Created by Nikolai Kratz on 11.05.17.
//  Copyright © 2017 Nikolai Kratz. All rights reserved.
//

import Foundation
import ImagePicker
import Eureka
import EquatableArray

class LocalImagePickerController :ImagePickerController, TypedRowControllerType  {
    /// The row that pushed or presented this controller
    public var row: RowOf<EquatableArray<UIImage>>!
    
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
}
