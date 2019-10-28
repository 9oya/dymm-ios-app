//
//  Utilities.swift
//  Dymm
//
//  Created by Eido Goya on 2019/10/20.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit

class Utilities: NSObject {

    func showAlertContrller(title:String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        return alertController
    }
}
