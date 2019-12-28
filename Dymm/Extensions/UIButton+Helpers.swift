//
//  UIButton+Helpers.swift
//  Dymm
//
//  Created by Eido Goya on 2019/12/29.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit

extension UIButton {
    func addUnderline() {
        guard let title = self.titleLabel else { return }
        guard let tittleText = title.text else { return }
        let attributedString = NSMutableAttributedString(string: (tittleText))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: (tittleText.count)))
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
