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

private let tagCellHeight: CGFloat = 45
private let bannerHeight: CGFloat = 160

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    var tagCollectionView: UICollectionView!
    var bannerCollectionView: UICollectionView!
    var pageControl: UIPageControl!
    var titleImageView: UIImageView!
    var profileButton: UIButton!
    
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    var banners: [BaseModel.Banner]?
    var tags: [BaseModel.Tag]?
    var avatar: BaseModel.Avatar?
    var selectedTag: BaseModel.Tag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadBanners()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lang = getLanguagePack(UserDefaults.standard.getCurrentLanguageId()!)
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
    
    @objc func alertError(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.btnYes, style: .default) { _ in
            self.retryFunction!()
        }
        let cancelAction = UIAlertAction(title: lang.btnClose, style: .cancel) { _ in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = UIColor.cornflowerBlue
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func presentDiaryNavigation() {
        let vc = DiaryViewController()
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @objc func presentCategoryNavigation() {
        let vc = CategoryViewController()
        vc.superTag = self.selectedTag!
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @objc func presentAuthNavigation() {
        let vc = AuthViewController()
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @objc func presentProfileNavigation() {
        let vc = ProfileViewController()
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @objc func profileButtonTapped() {
        if UserDefaults.standard.isSignIn() {
            presentProfileNavigation()
        } else {
            presentAuthNavigation()
        }
    }
    
    @objc private func handleNextBanner() {
        var nextIdx = pageControl.currentPage + 1
        if nextIdx == banners!.count {
            nextIdx = 0
        }
        let indexPath = IndexPath(item: (banners!.count - 1) - nextIdx, section: 0)
        bannerCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        UIView.transition(with: self.pageControl, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.pageControl.currentPage = nextIdx
        })
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
        } else if collectionView == self.tagCollectionView {
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
            } else if tag.id == TagId.bookmarks {
                if UserDefaults.standard.isSignIn() == false {
                    presentAuthNavigation()
                }
            }
            self.selectedTag = tag
            presentCategoryNavigation()
        }
    }
    
    // MARK: - UICollectionView DelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        if collectionView == bannerCollectionView {
            return CGSize(width: screenWidth, height: bannerHeight)
        } else {
            return CGSize(width: (screenWidth / 2) - 10.5, height: tagCellHeight)
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

    private func setupLayout() {
        // Initialize view
        lang = getLanguagePack(UserDefaults.standard.getCurrentLanguageId()!)
        view.backgroundColor = UIColor(hex: "WhiteSmoke")
        
        // Initialize subveiw properties
        tagCollectionView = getCategoryCollectionView()
        bannerCollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            _collectionView.backgroundColor = UIColor.clear
            _collectionView.register(BannerCollectionCell.self, forCellWithReuseIdentifier: bannerCellId)
            _collectionView.isPagingEnabled = true
            _collectionView.semanticContentAttribute = .forceRightToLeft
            _collectionView.showsHorizontalScrollIndicator = false
            _collectionView.decelerationRate = .fast
            _collectionView.translatesAutoresizingMaskIntoConstraints = false
            return _collectionView
        }()
        pageControl = {
            let _pageControl = UIPageControl()
            _pageControl.currentPage = 0
            _pageControl.currentPageIndicatorTintColor = UIColor.lightGray
            _pageControl.pageIndicatorTintColor = UIColor.whiteSmoke
            _pageControl.translatesAutoresizingMaskIntoConstraints = false
            return _pageControl
        }()
        titleImageView = {
            let _imageView = UIImageView(image: UIImage(named: "symbol-logo-small"))
            _imageView.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
            _imageView.contentMode = .scaleAspectFit
            return _imageView
        }()
        profileButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage(named: "button-profile")!.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 31, height: 31)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        
        navigationItem.titleView = titleImageView
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: profileButton)]
        bannerCollectionView.dataSource = self
        bannerCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        
        view.addSubview(bannerCollectionView)
        view.addSubview(tagCollectionView)
        view.addSubview(pageControl)
        
        // Setup constraints
        bannerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        bannerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        bannerCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        bannerCollectionView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: bannerCollectionView.bottomAnchor, constant: 3).isActive = true
        
        tagCollectionView.topAnchor.constraint(equalTo: bannerCollectionView.bottomAnchor, constant: 7).isActive = true
        tagCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        tagCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        tagCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }

    private func startTimer() {
        Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(handleNextBanner), userInfo: nil, repeats: true)
    }
    
    private func retryFunctionSet() {
        loadAvatar()
        loadBanners()
        loadCategories()
    }
    
    private func loadBanners() {
        let service = Service(lang: lang)
        service.getBannerList(popoverAlert: { (message) in
            self.retryFunction = self.retryFunctionSet
            self.alertError(message)
        }) { (banners) in
            self.banners = banners
            self.bannerCollectionView.reloadData()
            self.pageControl.numberOfPages = banners.count
            self.startTimer()
        }
    }
    
    private func loadCategories() {
        let service = Service(lang: lang)
        let homeTagId = 16
        service.getTagSetList(tagId: homeTagId, sortType: SortType.priority, popoverAlert: { (message) in
            self.retryFunction = self.retryFunctionSet
            self.alertError(message)
        }) { (tagSet) in
            self.tags = tagSet.sub_tags
            UIView.transition(with: self.tagCollectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.tagCollectionView.reloadData()
            })
        }
    }
    
    private func loadAvatar() {
        let service = Service(lang: lang)
        service.getAvatar(popoverAlert: { (message) in
            self.retryFunction = self.retryFunctionSet
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
