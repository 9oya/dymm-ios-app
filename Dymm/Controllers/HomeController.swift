//
//  HomeController.swift
//  Flava
//
//  Created by eunsang lee on 17/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit

private let bannerCellId = "BannerCell"
private let tagCellId = "TagCell"

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    var loadingImageView: UIImageView!
    var scrollView: UIScrollView!
    var categoryCollectionView: UICollectionView!
    var categoryCollectionViewHeight: NSLayoutConstraint!
    let bannerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        _collectionView.backgroundColor = UIColor.clear
        _collectionView.register(BannerCollectionCell.self, forCellWithReuseIdentifier: bannerCellId)
        _collectionView.isPagingEnabled = true
        _collectionView.semanticContentAttribute = .forceRightToLeft
        _collectionView.showsHorizontalScrollIndicator = false
        _collectionView.translatesAutoresizingMaskIntoConstraints = false
        return _collectionView
    }()
    lazy var pageControl: UIPageControl = {
        let _pageControl = UIPageControl()
        _pageControl.currentPage = 0
        _pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        _pageControl.pageIndicatorTintColor = UIColor.whiteSmoke
        _pageControl.translatesAutoresizingMaskIntoConstraints = false
        return _pageControl
    }()
    let titleImageView: UIImageView = {
        let _imageView = UIImageView(image: UIImage(named: "symbol-logo-small"))
        _imageView.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        _imageView.contentMode = .scaleAspectFit
        return _imageView
    }()
    let profileButton: UIButton = {
        let _button = UIButton(type: .system)
        _button.setImage(UIImage(named: "button-profile")!.withRenderingMode(.alwaysOriginal), for: .normal)
        _button.frame = CGRect(x: 0, y: 0, width: 31, height: 31)
        _button.showsTouchWhenHighlighted = true
        _button.translatesAutoresizingMaskIntoConstraints = false
        return _button
    }()
    
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    var banners: [BaseModel.Banner]?
    var tags: [BaseModel.Tag]?
    var avatar: BaseModel.Avatar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayoutStyles()
        setupLayoutSubviews()
        bannerCollectionView.dataSource = self
        bannerCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        setupLayoutConstraints()
        setupProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lang = getLanguagePack(UserDefaults.standard.getCurrentLanguageId()!)
        UIView.transition(with: categoryCollectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.bannerCollectionView.reloadData()
            self.categoryCollectionView.reloadData()
        })
        if UserDefaults.standard.isSignIn() {
            loadAvatar()
        } else {
            UIView.transition(with: profileButton, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.profileButton.setTitleColor(UIColor.clear, for: .normal)
                self.profileButton.backgroundColor = UIColor.clear
                self.profileButton.setBackgroundImage(UIImage(named: "button-profile"), for: .normal)
            })
        }
    }
    
    // MARK: - Actions
    
    @objc func profileButtonTapped() {
        if UserDefaults.standard.isSignIn() {
            presentProfileNavigation()
        } else {
            presentAuthNavigation()
        }
    }
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.bannerCollectionView {
            guard let number = banners?.count else {
                return 0
            }
            return number
        } else if collectionView == self.categoryCollectionView {
            guard let number = tags?.count else {
                return 0
            }
            return number
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.bannerCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bannerCellId, for: indexPath) as? BannerCollectionCell else {
                fatalError()
            }
            cell.backgroundColor = UIColor(hex: banners![indexPath.item].bg_color)
            cell.titleLabel.textColor = UIColor(hex: banners![indexPath.item].txt_color)
            cell.subtitleLabel.textColor = UIColor(hex: banners![indexPath.item].txt_color)
            switch lang.currentLanguageId {
            case LanguageId.eng:
                cell.titleLabel.text = banners![indexPath.item].eng_title
                cell.subtitleLabel.text = banners![indexPath.item].eng_subtitle
            case LanguageId.kor:
                cell.titleLabel.text = banners![indexPath.item].kor_title
                cell.subtitleLabel.text = banners![indexPath.item].eng_subtitle
            case LanguageId.jpn:
                cell.titleLabel.text = banners![indexPath.item].jpn_title
                cell.subtitleLabel.text = banners![indexPath.item].eng_subtitle
            default:
                fatalError()
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId, for: indexPath) as? TagCollectionCell else {
                fatalError()
            }
            if let tag = tags?[indexPath.row] {
                switch lang.currentLanguageId {
                case LanguageId.eng: cell.label.text = tag.eng_name
                case LanguageId.kor: cell.label.text = tag.kor_name
                default: fatalError()}
                cell.imageView.image = UIImage(named: "tagId-\(tag.id)")
            }
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == bannerCollectionView {
            return
        } else {
            guard let tag = tags?[indexPath.row] else {
                return
            }
            if tag.id == TagId.diary {
                if UserDefaults.standard.isSignIn() {
                    presentDiaryNavigation()
                } else {
                    presentAuthNavigation()
                }
            }
            presentCategoryNavigation(tag: tag)
        }
    }
    
    // MARK: - UICollectionView DelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        if collectionView == bannerCollectionView {
            return CGSize(width: screenWidth, height: 160)
        } else {
            return CGSize(width: (screenWidth / 2) - 10.5, height: CGFloat(45))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == bannerCollectionView {
            return 0
        } else {
            return 7
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == bannerCollectionView {
            return 0
        } else {
            return 7
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let x = targetContentOffset.pointee.x
        pageControl.currentPage = Int(x / view.frame.width)
    }
}

extension HomeViewController {
    
    // MARK: - Private methods
    
    private func setupLayoutStyles() {
        view.backgroundColor = UIColor(hex: "WhiteSmoke")
    }
    
    private func setupLayoutSubviews() {
        loadingImageView = getLoadingImageView(isHidden: false)
        
        scrollView = getScrollView()
        categoryCollectionView = getCategoryCollectionView()
        
        view.addSubview(scrollView)
        view.addSubview(loadingImageView)
        
        scrollView.addSubview(bannerCollectionView)
        scrollView.addSubview(categoryCollectionView)
        scrollView.addSubview(pageControl)
    }
    
    // MARK: - SetupLayoutConstraints
    
    private func setupLayoutConstraints() {
        // loadingImageView, alertBlindView
        loadingImageView.widthAnchor.constraint(equalToConstant: 62).isActive = true
        loadingImageView.heightAnchor.constraint(equalToConstant: 62).isActive = true
        loadingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        loadingImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
        // scrollView
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        bannerCollectionView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 1).isActive = true
        bannerCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
        bannerCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
        bannerCollectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 0).isActive = true
        bannerCollectionView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        pageControl.centerXAnchor.constraint(equalTo: bannerCollectionView.centerXAnchor, constant: 0).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: bannerCollectionView.bottomAnchor, constant: 3).isActive = true
        
        categoryCollectionView.topAnchor.constraint(equalTo: bannerCollectionView.bottomAnchor, constant: 7).isActive = true
        categoryCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 7).isActive = true
        categoryCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -7).isActive = true
        categoryCollectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
        categoryCollectionViewHeight = categoryCollectionView.heightAnchor.constraint(equalToConstant: 45 + 7)
        categoryCollectionViewHeight.priority = UILayoutPriority(rawValue: 999)
        categoryCollectionViewHeight.isActive = true
    }
    
    // MARK: - SetupProperties
    
    private func setupProperties() {
        lang = getLanguagePack(UserDefaults.standard.getCurrentLanguageId()!)
        navigationItem.titleView = titleImageView
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: profileButton)]
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        loadBanners()
        loadCategories()
    }

    private func alertError(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.btnDone, style: .default) { _ in
            self.retryFunction!()
        }
        let cancelAction = UIAlertAction(title: lang.btnCancel, style: .cancel) { _ in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func presentDiaryNavigation() {
        let vc = DiaryViewController()
        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true, completion: nil)
    }
    
    private func presentCategoryNavigation(tag: BaseModel.Tag) {
        let vc = CategoryViewController()
        vc.superTag = tag
        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true, completion: nil)
    }
    
    private func presentAuthNavigation() {
        let vc = AuthViewController()
        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true, completion: nil)
    }
    
    private func presentProfileNavigation() {
        let vc = ProfileViewController()
        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true, completion: nil)
    }
    
    private func afterFetchCategoriesTransition(_ tags: [BaseModel.Tag]) {
        self.tags = tags
        let tagsCnt = tags.count
        UIView.transition(with: self.categoryCollectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.categoryCollectionView.reloadData()
            self.categoryCollectionViewHeight.constant = self.getCategoryCollectionViewHeight(tagsCnt)
            self.loadingImageView.isHidden = true
        })
    }
    
    private func loadBanners() {
        let service = Service(lang: lang)
        service.fetchBanners(popoverAlert: { (message) in
            self.retryFunction = self.loadBanners
            self.alertError(message)
        }) { (banners) in
            self.banners = banners
            UIView.transition(with: self.bannerCollectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.bannerCollectionView.reloadData()
            })
            self.pageControl.numberOfPages = banners.count
        }
    }
    
    private func loadCategories() {
        let service = Service(lang: lang)
        let homeTagId = 16
        service.fetchTagSets(tagId: homeTagId, sortType: SortType.score, popoverAlert: { (message) in
            self.retryFunction = self.loadCategories
            self.alertError(message)
        }) { (tagSet) in
            self.afterFetchCategoriesTransition(tagSet.sub_tags)
            print("Load home categories complete.")
        }
    }
    
    private func loadAvatar() {
        let service = Service(lang: lang)
        service.fetchAvatar(popoverAlert: { (message) in
            self.retryFunction = self.loadAvatar
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadAvatar()
        }) { (avatar) in
            self.avatar = avatar
            let firstName = avatar.first_name
            let index = firstName.index(firstName.startIndex, offsetBy: 0)
            UIView.animate(withDuration: 0.2, animations: {
                self.profileButton.setImage(nil, for: .normal)
                self.profileButton.setTitle(String(firstName[index]), for: .normal)
                self.profileButton.setTitleColor(UIColor.white, for: .normal)
                self.profileButton.layer.cornerRadius = self.profileButton.frame.width/2
                self.profileButton.backgroundColor = getProfileUIColor(key: avatar.profile_type)
                self.profileButton.setBackgroundImage(nil, for: .normal)
            })
        }
    }
}
