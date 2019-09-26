//
//  UIViewControllerExtension.swift
//  Dymm
//
//  Created by eunsang lee on 15/05/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    // MARK: - Get value methods
    
    func getButtonWidth() -> CGFloat {
        return (view.frame.width / 2) - 30
    }
    
    func getTagCollectionViewHeight(_ numberOfItems: Int) -> CGFloat {
        let cellHeight = 45 + 7
        let numberOfRows = (numberOfItems / 2) + (numberOfItems % 2 > 0 ? 1:0)
        return CGFloat(cellHeight * numberOfRows)
    }
    
    // MARK: - Get UI component methods
    
    func getAlertBlindView() -> UIView {
        let _view = UIView()
        _view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
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
        let _imageView = UIImageView(image: .itemLoading)
        _imageView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        _imageView.contentMode = .scaleAspectFit
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
        _view.backgroundColor = .white
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }
    func getBasicTextButton(_ titleColor: UIColor? = nil) -> UIButton {
        let _button = UIButton(type: .system)
        if let titleColor = titleColor {
            _button.setTitleColor(titleColor, for: .normal)
        } else {
            _button.setTitleColor(.black, for: .normal)
        }
        _button.titleLabel?.font = .systemFont(ofSize: 15)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }
    func getCloseButton() -> UIButton {
        let _button = UIButton(type: .system)
        _button.setImage(UIImage.itemCloseThin.withRenderingMode(.alwaysOriginal), for: .normal)
        _button.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }
    func getCancelButton() -> UIButton {
        let _button = UIButton(type: .system)
        _button.setImage(UIImage.itemClose.withRenderingMode(.alwaysOriginal), for: .normal)
        //        _button.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }
    func getCheckButton() -> UIButton {
        let _button = UIButton(type: .system)
        _button.setImage(UIImage.itemCheck.withRenderingMode(.alwaysOriginal), for: .normal)
        //        _button.frame = CGRect(x: 0, y: 0, width: 26, height: 21)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }
    func getGrayLineView() -> UIView {
        let _view = UIView(frame: CGRect.zero)
        _view.backgroundColor = .whiteSmoke
        _view.translatesAutoresizingMaskIntoConstraints = false
        return _view
    }
}
