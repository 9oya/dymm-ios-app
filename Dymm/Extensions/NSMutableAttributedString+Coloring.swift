//
//  NSMutableAttributedString.swift
//  Dymm
//
//  Created by eunsang lee on 21/08/2019.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        
        // Swift 4.2 and above
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
}
