//
//  HomeController.swift
//  Flava
//
//  Created by eunsang lee on 17/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

//private let bannerCellId = "BannerCollectionCell"
private let bannerHeightInt = 250
let marginInt = 7

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    // UIView
    var scoreboardView: UIView!
    
    // UICollectionView
    var tagCollectionView: UICollectionView!
//    var bannerCollectionView: UICollectionView!
    
    // UIPageControl
//    var pageControl: UIPageControl!
    
    // UILabel
    var scoreTitleLabel: UILabel!
    var scoreNumberLabel: UILabel!
    var scoreMessageLabel: UILabel!
    
    // UIImageView
    var titleImageView: UIImageView!
    var profileImageView: UIImageView!
    var loadingImageView: UIImageView!
    var scoreEmoImageView: UIImageView!
    
    // UIButton
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
//        loadBanners()
        loadScoreboard()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        UIView.transition(with: tagCollectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {
//            self.bannerCollectionView.reloadData()
            self.tagCollectionView.reloadData()
        })
        if UserDefaults.standard.isSignIn() {
            loadScoreboard()
            loadAvatar()
        } else {
            UIView.transition(with: profileButton, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.profileButton.setTitleColor(UIColor.clear, for: .normal)
                self.profileButton.backgroundColor = UIColor.clear
                self.profileButton.setBackgroundImage(.itemProfileDef, for: .normal)
            })
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: profileButton)]
        }
    }
    
    // MARK: - Actions
    
    @objc func alertError(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.titleYes, style: .default) { _ in
            self.retryFunction!()
        }
        let cancelAction = UIAlertAction(title: lang.titleClose, style: .cancel) { _ in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = UIColor.cornflowerBlue
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func presentDiaryNavigation() {
        let vc = DiaryViewController()
        vc.superTag = self.selectedTag!
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil)
    }
    
    @objc func presentCategoryNavigation() {
        let vc = CategoryViewController()
        vc.superTag = self.selectedTag!
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil)
    }
    
    @objc func presentAuthNavigation() {
        let vc = AuthViewController()
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil)
    }
    
    @objc func presentProfileNavigation() {
        let vc = ProfileViewController()
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true, completion: nil)
    }
    
    @objc func profileButtonTapped() {
        if UserDefaults.standard.isSignIn() {
            presentProfileNavigation()
        } else {
            presentAuthNavigation()
        }
    }
    
//    @objc private func handleNextBanner() {
//        var nextIdx = pageControl.currentPage + 1
//        if nextIdx == banners!.count {
//            nextIdx = 0
//        }
//        let indexPath = IndexPath(item: (banners!.count - 1) - nextIdx, section: 0)
//        bannerCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        UIView.transition(with: pageControl, duration: 0.5, options: .transitionCrossDissolve, animations: {
//            self.pageControl.currentPage = nextIdx
//        })
//    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        switch collectionView {
//        case bannerCollectionView:
//            guard let number = banners?.count else {
//                return 0
//            }
//            return number
//        case tagCollectionView:
//            guard let number = tags?.count else {
//                return 0
//            }
//            return number
//        default:
//            fatalError()
//        }
        guard let number = tags?.count else {
            return 0
        }
        return number
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch collectionView {
//        case bannerCollectionView:
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bannerCellId, for: indexPath) as? BannerCollectionCell else {
//                fatalError()
//            }
//            cell.backgroundColor = UIColor(hex: banners![indexPath.item].bg_color)
//            cell.titleLabel.textColor = UIColor(hex: banners![indexPath.item].txt_color)
//            cell.subtitleLabel.textColor = UIColor(hex: banners![indexPath.item].txt_color)
//            cell.imageView.image = UIImage.itemRectangleLine.withRenderingMode(.alwaysOriginal)
//            switch lang.currentLanguageId {
//            case LanguageId.eng:
//                cell.titleLabel.text = banners![indexPath.item].eng_title
//                cell.subtitleLabel.text = banners![indexPath.item].eng_subtitle
//            case LanguageId.kor:
//                cell.titleLabel.text = banners![indexPath.item].kor_title
//                cell.subtitleLabel.text = banners![indexPath.item].kor_subtitle
//            case LanguageId.jpn:
//                cell.titleLabel.text = banners![indexPath.item].jpn_title
//                cell.subtitleLabel.text = banners![indexPath.item].jpn_subtitle
//            default:
//                fatalError()
//            }
//            return cell
//        case tagCollectionView:
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId, for: indexPath) as? TagCollectionCell else {
//                fatalError()
//            }
//            if let tag = tags?[indexPath.item] {
//                switch lang.currentLanguageId {
//                case LanguageId.eng: cell.label.text = tag.eng_name
//                case LanguageId.kor: cell.label.text = tag.kor_name
//                default: fatalError()}
//                cell.imageView.image = UIImage(named: "tag-\(tag.id)")!.withRenderingMode(.alwaysOriginal)
//
//                switch tag.id {
//                case TagId.diary:
//                    cell.label.textColor = .hex_fe4c4c
//                case TagId.bookmarks:
//                    cell.label.textColor = .gold
//                default:
//                    cell.label.textColor = .black
//                }
//            }
//            return cell
//        default:
//            fatalError()
//        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tagCellId, for: indexPath) as? TagCollectionCell else {
            fatalError()
        }
        if let tag = tags?[indexPath.item] {
            switch lang.currentLanguageId {
            case LanguageId.eng: cell.label.text = tag.eng_name
            case LanguageId.kor: cell.label.text = tag.kor_name
            default: fatalError()}
            cell.imageView.image = UIImage(named: "tag-\(tag.id)")!.withRenderingMode(.alwaysOriginal)
            
            switch tag.id {
            case TagId.diary:
                cell.label.textColor = .hex_fe4c4c
            case TagId.bookmarks:
                cell.label.textColor = .gold
            default:
                cell.label.textColor = .black
            }
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        switch collectionView {
//        case bannerCollectionView:
//            return
//        case tagCollectionView:
//            guard let tag = tags?[indexPath.item] else {
//                return
//            }
//            self.selectedTag = tag
//            if tag.id == TagId.diary {
//                if UserDefaults.standard.isSignIn() {
//                    presentDiaryNavigation()
//                } else {
//                    presentAuthNavigation()
//                }
//            } else if tag.id == TagId.bookmarks {
//                if UserDefaults.standard.isSignIn() == false {
//                    presentAuthNavigation()
//                }
//            }
//            presentCategoryNavigation()
//        default:
//            fatalError()
//        }
        
        guard let tag = tags?[indexPath.item] else {
            return
        }
        self.selectedTag = tag
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
        presentCategoryNavigation()
    }
    
    // MARK: - UICollectionView DelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        switch collectionView {
//        case bannerCollectionView:
//            return CGSize(width: UIScreen.main.bounds.width, height: CGFloat(bannerHeightInt))
//        case tagCollectionView:
//            return CGSize(width: (UIScreen.main.bounds.width / 2) - 10.5, height: CGFloat(tagCellHeightInt))
//        default:
//            fatalError()
//        }
        
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 10.5, height: CGFloat(tagCellHeightInt))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        switch collectionView {
//        case bannerCollectionView:
//            return 0
//        case tagCollectionView:
//            return 7
//        default:
//            fatalError()
//        }
        
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        switch collectionView {
//        case bannerCollectionView:
//            return 0
//        case tagCollectionView:
//            return 7
//        default:
//            fatalError()
//        }
        
        return 7
    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        pageControl.currentPage = Int(targetContentOffset.pointee.x / view.frame.width)
//    }
}

extension HomeViewController {
    
    // MARK: - Private methods
    
    private func setupLayout() {
        // Initialize view
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        view.backgroundColor = UIColor.whiteSmoke
        
        // Initialize subveiw properties
        tagCollectionView = getCategoryCollectionView()
//        bannerCollectionView = {
//            let layout = UICollectionViewFlowLayout()
//            layout.scrollDirection = .horizontal
//            let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
//            _collectionView.backgroundColor = UIColor.clear
//            _collectionView.register(BannerCollectionCell.self, forCellWithReuseIdentifier: bannerCellId)
//            _collectionView.isPagingEnabled = true
//            _collectionView.semanticContentAttribute = .forceRightToLeft
//            _collectionView.showsHorizontalScrollIndicator = false
//            _collectionView.decelerationRate = .fast
//            _collectionView.translatesAutoresizingMaskIntoConstraints = false
//            return _collectionView
//        }()
//        pageControl = {
//            let _pageControl = UIPageControl()
//            _pageControl.currentPage = 0
//            _pageControl.currentPageIndicatorTintColor = .white
//            _pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.4)
//            _pageControl.translatesAutoresizingMaskIntoConstraints = false
//            return _pageControl
//        }()
        scoreboardView = {
            let _view = UIView()
            _view.backgroundColor = .lightGray
            _view.addShadowView()
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        scoreEmoImageView = {
            let _imageView = UIImageView()
            _imageView.contentMode = .scaleAspectFit
            _imageView.addShadowView()
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        scoreTitleLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 40, weight: .medium)
            _label.textColor = .white
            _label.textAlignment = .center
            _label.addShadowView()
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        scoreNumberLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 40, weight: .medium)
            _label.textColor = .white
            _label.textAlignment = .center
            _label.addShadowView()
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        scoreMessageLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 20, weight: .medium)
            _label.textColor = .white
            _label.textAlignment = .center
            _label.numberOfLines = 2
            _label.addShadowView()
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        titleImageView = {
            let _imageView = UIImageView(image: .itemLogoS)
            _imageView.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
            _imageView.contentMode = .scaleAspectFit
            return _imageView
        }()
        profileImageView = {
            let _imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 31, height: 31))
            _imageView.layer.cornerRadius = 31 / 2
            _imageView.contentMode = .scaleAspectFill
            _imageView.clipsToBounds = true
            _imageView.image = UIImage.itemProfileDef
            _imageView.isUserInteractionEnabled = true
            _imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileButtonTapped)))
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        profileButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemProfileDef.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 31, height: 31)
            _button.layer.cornerRadius = _button.frame.width/2
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        loadingImageView = getLoadingImageView(isHidden: false)
        
        navigationItem.titleView = titleImageView
        profileImageView.widthAnchor.constraint(equalToConstant: 31).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 31).isActive = true
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: profileImageView)]
//        bannerCollectionView.dataSource = self
//        bannerCollectionView.delegate = self
        tagCollectionView.dataSource = self
        tagCollectionView.delegate = self
        
        // Setup subviews
//        view.addSubview(bannerCollectionView)
        view.addSubview(scoreboardView)
        view.addSubview(tagCollectionView)
//        view.addSubview(pageControl)
        view.addSubview(loadingImageView)
        
        scoreboardView.addSubview(scoreTitleLabel)
        scoreboardView.addSubview(scoreEmoImageView)
        scoreboardView.addSubview(scoreNumberLabel)
        scoreboardView.addSubview(scoreMessageLabel)
        
        // Setup constraints
//        bannerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
//        bannerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
//        bannerCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
//        bannerCollectionView.heightAnchor.constraint(equalToConstant: CGFloat(bannerHeightInt)).isActive = true
        
//        pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
//        pageControl.bottomAnchor.constraint(equalTo: bannerCollectionView.bottomAnchor, constant: 3).isActive = true
        
        
        scoreboardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        scoreboardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        scoreboardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        scoreboardView.heightAnchor.constraint(equalToConstant: CGFloat(bannerHeightInt)).isActive = true
        
        scoreTitleLabel.centerXAnchor.constraint(equalTo: scoreboardView.centerXAnchor, constant: 0).isActive = true
        scoreTitleLabel.topAnchor.constraint(equalTo: scoreboardView.topAnchor, constant: 20).isActive = true
        
        scoreEmoImageView.centerXAnchor.constraint(equalTo: scoreboardView.centerXAnchor, constant: 0).isActive = true
        scoreEmoImageView.topAnchor.constraint(equalTo: scoreTitleLabel.bottomAnchor, constant: 10).isActive = true
        
        scoreNumberLabel.centerXAnchor.constraint(equalTo: scoreboardView.centerXAnchor, constant: 0).isActive = true
        scoreNumberLabel.topAnchor.constraint(equalTo: scoreEmoImageView.bottomAnchor, constant: 7).isActive = true
        
        scoreMessageLabel.centerXAnchor.constraint(equalTo: scoreboardView.centerXAnchor, constant: 0).isActive = true
        scoreMessageLabel.topAnchor.constraint(equalTo: scoreNumberLabel.bottomAnchor, constant: 10).isActive = true
        
        tagCollectionView.topAnchor.constraint(equalTo: scoreboardView.bottomAnchor, constant: 7).isActive = true
        tagCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        tagCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        tagCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        loadingImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        loadingImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 0).isActive = true
    }
    
//    private func startTimer() {
//        Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(handleNextBanner), userInfo: nil, repeats: true)
//    }
    
    private func retryFunctionSet() {
        if UserDefaults.standard.isSignIn() {
            loadAvatar()
        }
        loadScoreboard()
//        loadBanners()
        loadCategories()
    }
    
//    private func loadBanners() {
//        let service = Service(lang: lang)
//        service.getBannerList(popoverAlert: { (message) in
//            self.retryFunction = self.retryFunctionSet
//            self.alertError(message)
//        }) { (banners) in
//            self.banners = banners
//            self.bannerCollectionView.reloadData()
//            self.pageControl.numberOfPages = banners.count
//            self.startTimer()
//        }
//    }
    
    private func loadScoreboard() {
        let service = Service(lang: lang)
        service.getAvgCondScore(yearNumber: "2019", monthNumber: nil, weekOfYear: nil, popoverAlert: { (message) in
            self.retryFunction = self.retryFunctionSet
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadScoreboard()
        }) { (avgCondScoreSet) in
            let formatter = NumberFormatter()
            let thisAvgScore = formatter.number(from: avgCondScoreSet.this_avg_score)!.floatValue
            UIView.animate(withDuration: 0.5) {
                self.scoreboardView.backgroundColor = getCondScoreColor(thisAvgScore)
                self.scoreTitleLabel.text = self.lang.getCondScoreName(thisAvgScore)
                self.scoreEmoImageView.image = getCondScoreImageLarge(thisAvgScore)
                self.scoreNumberLabel.text = String(format: "%.1f", thisAvgScore)
                self.scoreMessageLabel.text = "My Condition Score"
            }
        }
    }
    
    private func loadCategories() {
        let service = Service(lang: lang)
        service.getTagSetList(tagId: TagId.home, sortType: SortType.priority, popoverAlert: { (message) in
            self.retryFunction = self.retryFunctionSet
            self.alertError(message)
        }) { (tagSet) in
            self.tags = tagSet.sub_tags
            UIView.transition(with: self.tagCollectionView, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.tagCollectionView.reloadData()
                self.loadingImageView.isHidden = true
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
            UIView.animate(withDuration: 0.5, animations: {
                if avatar.photo_name != nil && avatar.color_code == 0 {
                    print(avatar.photo_name!)
                    let url = "\(URI.host)\(URI.avatar)/\(avatar.id)/profile/photo/\(avatar.photo_name!)"
                    Alamofire.request(url).responseImage { response in
                        if let data = response.data {
                            self.profileImageView.image = UIImage(data: data)
                            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: self.profileImageView)]
                        }
                    }
                } else {
                    let index = firstName.index(firstName.startIndex, offsetBy: 0)
                    self.profileButton.setImage(nil, for: .normal)
                    self.profileButton.setTitle(String(firstName[index]), for: .normal)
                    self.profileButton.setTitleColor(.white, for: .normal)
                    self.profileButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
                    self.profileButton.backgroundColor = getProfileUIColor(key: avatar.color_code)
                    self.profileButton.setBackgroundImage(nil, for: .normal)
                    self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: self.profileButton)]
                }
            })
        }
    }
}
