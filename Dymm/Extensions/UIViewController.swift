//
//  UIViewControllerExtension.swift
//  Dymm
//
//  Created by eunsang lee on 15/05/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import Foundation
import UIKit

private let tagCellId = "TagCell"

extension UIViewController {
    
    // MARK: - Get device info methods
    
    func getDeviceLanguage() -> Int {
        return getLanguageId(alpha2: String(Locale.preferredLanguages[0].prefix(2)))
    }
    
    func getUserCountryCode() -> String {
        return ((Locale.current as NSLocale).object(forKey: .countryCode) as? String)!
    }
    
    // MARK: - Get value methods
    
    func getButtonWidth() -> CGFloat {
        return (view.frame.width / 2) - 30
    }
    
    func getCategoryCollectionViewHeight(_ numberOfItems: Int) -> CGFloat {
        let cellHeight = 52
        let lineNumber = (numberOfItems / 2) + (numberOfItems % 2 > 0 ? 1:0)
        return CGFloat(cellHeight * lineNumber)
    }
    
    func getAvatarFactCollectionHeight(_ numberOfItems: Int) -> CGFloat {
        let cellHeight = 42
        let lineNumber = (numberOfItems / 2) + (numberOfItems % 2 > 0 ? 1:0)
        return CGFloat(cellHeight * lineNumber)
    }
    
    // MARK: - Get UI component methods
    
    func getAlertBlindView() -> UIView {
        let _view = UIView()
        _view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        _view.isHidden = true
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }
    func getAlertMsgContainerView(isHidden: Bool? = nil) -> UIView {
        let _view = UIView()
        _view.backgroundColor = UIColor.white
        if let isHidden = isHidden {
            _view.isHidden = isHidden
        }
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }
    func getAlertMsgLabel() -> UILabel {
        let _label = UILabel()
        _label.font = .systemFont(ofSize: 15, weight: .light)
        _label.textColor = UIColor.black
        _label.textAlignment = .center
        _label.numberOfLines = 4
        _label.translatesAutoresizingMaskIntoConstraints = false
        return _label
    }
    func getLoadingImageView(isHidden: Bool? = nil) -> UIImageView {
        let _imageView = UIImageView(image: UIImage(named: "item-loading"))
        _imageView.startRotating()
        if let isHidden = isHidden {
            _imageView.isHidden = isHidden
        }
        _imageView.translatesAutoresizingMaskIntoConstraints = false
        return _imageView
    }
    func getScrollView(isHidden: Bool? = nil) -> UIScrollView {
        let _scrollView = UIScrollView(frame: CGRect.zero)
        _scrollView.showsHorizontalScrollIndicator = false
        if let isHidden = isHidden {
            _scrollView.isHidden = isHidden
        }
        _scrollView.backgroundColor = UIColor.clear
        _scrollView.translatesAutoresizingMaskIntoConstraints = false
        return _scrollView
    }
    func getCategoryCollectionView() -> UICollectionView {
        let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        _collectionView.backgroundColor = UIColor.clear
        _collectionView.register(TagCollectionCell.self, forCellWithReuseIdentifier: tagCellId)
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        return _collectionView
    }
    func getAddtionalTopBarView() -> UIView {
        let _view = UIView()
        _view.backgroundColor = UIColor.white
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }
    func getBasicTextButton(_ titleColor: UIColor? = nil) -> UIButton {
        let _button = UIButton(type: .system)
        if let titleColor = titleColor {
            _button.setTitleColor(titleColor, for: .normal)
        } else {
            _button.setTitleColor(UIColor(hex: "Tomato"), for: .normal)
        }
        _button.titleLabel?.font = .systemFont(ofSize: 15)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }
    func getCloseButton() -> UIButton {
        let _button = UIButton(type: .system)
        _button.setImage(UIImage(named: "button-close")!.withRenderingMode(.alwaysOriginal), for: .normal)
        _button.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }
    func getCancelButton() -> UIButton {
        let _button = UIButton(type: .system)
        _button.setImage(UIImage(named: "button-cancel")!.withRenderingMode(.alwaysOriginal), for: .normal)
        _button.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }
    func getCheckButton() -> UIButton {
        let _button = UIButton(type: .system)
        _button.setImage(UIImage(named: "button-check")!.withRenderingMode(.alwaysOriginal), for: .normal)
        _button.frame = CGRect(x: 0, y: 0, width: 26, height: 21)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }
    func getGrayLineView() -> UIView {
        let _view = UIView(frame: CGRect.zero)
        _view.backgroundColor = UIColor(hex: "WhiteSmoke")
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }
}