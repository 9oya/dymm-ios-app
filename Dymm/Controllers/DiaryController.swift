//
//  DiaryController.swift
//  Flava
//
//  Created by eunsang lee on 28/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import UIKit
import FSCalendar
import Alamofire

private let logGroupTableCellId = "LogGroupTableCell"
private let logCollectionCellId = "LogCollectionCell"
private let condCollectionCellId = "CondCollectionCell"

private let logGroupCellHeightInt = 52
private let logGroupSectionHeightInt = 45
let logGroupFooterHeightInt = 50
private let logTableCellHeightInt = 45
private let logCollectionCellHeightInt = 30
private let pickerCollectionHeightInt = 32
private let groupTypePickerRowHeightInt = 60
private let condScorePickerRowHeightInt = 40

class DiaryViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    // UIView
    var blindView: UIView!
    var pickerContainerView: UIView!
    var pickerGrayLineView: UIView!
    var diseaseContainer: UIView!
    
    // FSCalendar
    var calendarView: FSCalendar!
    
    // UITableView
    var logGroupTable: UITableView!
    
    // UICollectionView
    var diseaseCollection: UICollectionView!
    var pickerCollection: UICollectionView!
    
    // UIPickerView
    var groupTypePicker: UIPickerView!
    var moodScorePicker: UIPickerView!
    
    // UILabel
    var pickerDateLabel: UILabel!
    var diseaseTitleLabel: UILabel!
    var guideLabel: UILabel!
    var pullToRefreshLabel: UILabel!
    
    // UIButton
    var toggleBtn: UIButton!
    var pickerCancelBtn: UIButton!
    var pickerCheckBtn: UIButton!
    var homeBtn: UIButton!
    var notesBtn: UIButton!
    var avgScoreBtn: UIButton!
    var diseaseHistoryBtn: UIButton!
    var diseaseLeftBtn: UIButton!
    var diseaseRightBtn: UIButton!
    var diseaseRefreshBtn: UIButton!
    var foodBtn: UIButton!
    var pillBtn: UIButton!
    var activityBtn: UIButton!
    var diseaseBtn: UIButton!
    var plusBtn: UIButton!
    var foodPlusBtn: UIButton!
    var pillPlusBtn: UIButton!
    var activityPlusBtn: UIButton!
    var diseasePlusBtn: UIButton!
    var bookmarkPlusBtn: UIButton!
    var plusBtns: [UIButton]!
    
    // UI
    var plusBtnStackView: UIStackView!
    
    // UIImageView
    var guideIllustImgView: UIImageView!
    
    // NSLayoutConstraint
    var calendarViewHeight: NSLayoutConstraint!
    var pickerContainerHeight: NSLayoutConstraint!
    var pickerCollectionHeight: NSLayoutConstraint!
    var condContainerHeight: NSLayoutConstraint!
    var condCollectionHeight: NSLayoutConstraint!
    
    // Helpers
    var refreshControler: UIRefreshControl!
    var scopeGesture: UIPanGestureRecognizer!
    var dateFormatter: DateFormatter!
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    var retryFunctionName: String?
    var retryCompletion: ((CustomModel.GroupOfLogSet) -> Void)?
    
    // Models
    var diaryMode: Int = DiaryMode.editor
    var logGroupDictTwoDimArr = [Int:[Int:BaseModel.LogGroup]]() // [dayOfyear:[groupType:IntakeLogGroup]]
    var logGroupSectTwoDimArr = [[CustomModel.LogGroupSection]]()
    var logGroups: [BaseModel.LogGroup]? // For event marking
    var avtCondList: [BaseModel.AvatarCond]?
    var selectedLogGroup: BaseModel.LogGroup?
    var selectedTag: BaseModel.Tag?
    var groupOfLogSet: CustomModel.GroupOfLogSet?
    var tempStoredLogs = [BaseModel.TagLog]()
    let moodScores: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    // Non-view properties
    var selectedTableSection: Int?
    var selectedTableRow: Int?
    var selectedLogGroupId: Int?
    var selectedCalScope: Int?
    var selectedWeekOfYear: Int?
    var yearForWeekOfYear: Int?
    var selectedDate: String?
    var selectedOnceCellIdxPath: IndexPath?
    var selectedDiseasePickerIdx = 3
    var selectedMoodScore = 7
    var selectedAvatarDiseaseId: Int?
    let numberOfGroupType = 4
    var editedCellIdxPath: IndexPath?
    var yearNumber: Int?
    var monthNumber: Int?
    var dayNumber: Int?
    var groupType: Int?
    var weekOfYear: Int?
    var dayOfYear: Int?
    var xVal: Int?
    var yVal: Int?
    var newNote: String?
    var thisAvgScore: Float?
    var lastAvgScore: Float?
    var isToggleBtnTapped: Bool = false
    var isPullToRefresh: Bool = false
    var isLogGroupTableEdited: Bool = false
    var isCondEditBtnTapped: Bool = false
    var isFirstAppear: Bool = true
    var isPlusBtnTapped: Bool = false
    var superTag: BaseModel.Tag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadLogGroups()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        diseaseLeftBtnTapped()
        selectedOnceCellIdxPath = nil
        selectedTableSection = nil
        selectedTableRow = nil
        loadLogGroups()
    }
    
    // MARK: - Actions
    
    @objc func alertError(_ message: String) {
        view.hideSpinner()
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: lang.titleYes, style: .default) { _ in
            if self.retryFunctionName == "loadGroupOfLogs" {
                self.loadGroupOfLogs(self.retryCompletion!)
                return
            }
            self.retryFunction!()
        })
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertCompl(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: lang.titleStay, style: .cancel) { _ in
            _ = self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: lang.titleReturn, style: .default) { _ in
            let controller = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.count)! - 3]
            self.navigationController?.popToViewController(controller!, animated: true)
        })
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertCondScorePicker() {
        let alert = UIAlertController(title: lang.titleMoodScore, message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        alert.isModalInPopover = true
        if let condScore = selectedLogGroup?.cond_score {
            moodScorePicker.selectRow(10 - condScore, inComponent: 0, animated: false)
        } else {
            moodScorePicker.selectRow(3, inComponent: 0, animated: false)
            selectedMoodScore = 7
        }
        alert.view.addSubview(moodScorePicker)
        moodScorePicker.widthAnchor.constraint(equalTo: alert.view.widthAnchor, constant: 0).isActive = true
        alert.addAction(UIAlertAction(title: lang.titleClose, style: .cancel) { _ in })
        alert.addAction(UIAlertAction(title: lang.titleDone, style: .default) { _ in
            self.updateLogGroupCondScore()
        })
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil )
    }
    
    @objc func alertNoteTextView(_ sender: UITapGestureRecognizer? = nil) {
        var message = ""
        switch lang.currentLanguageId {
        case LanguageId.eng:
            message = "\(lang.getLogGroupTypeName(selectedLogGroup!.group_type)) \(LangHelper.getEngNameOfMM(monthNumber: selectedLogGroup!.month_number))/\(selectedLogGroup!.day_number)/\(selectedLogGroup!.year_number)"
        case LanguageId.kor:
            message = "\(lang.getLogGroupTypeName(selectedLogGroup!.group_type)) \(LangHelper.getKorNameOfMonth(monthNumber: selectedLogGroup!.month_number, engMMM: nil))/\(selectedLogGroup!.day_number)/\(selectedLogGroup!.year_number)"
        case LanguageId.jpn:
            // TODO
            print("")
        default: fatalError() }
        let alert = UIAlertController(title: lang.titleNote, message: message, preferredStyle: .alert)
        let noteTextView: UITextView = {
            let _textView = UITextView()
            _textView.backgroundColor = .green_00E9CC
            _textView.font = .systemFont(ofSize: 16, weight: .light)
            _textView.translatesAutoresizingMaskIntoConstraints = false
            return _textView
        }()
        noteTextView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let controller = UIViewController()
        noteTextView.frame = controller.view.frame
        if let oldNote = selectedLogGroup?.note {
            noteTextView.text = oldNote
        }
        controller.view.addSubview(noteTextView)
        alert.setValue(controller, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: lang.titleDone, style: .default) { _ in
            if let text = noteTextView.text {
                self.newNote = text
                if let oldNote = self.selectedLogGroup?.note {
                    if oldNote != self.newNote {
                        self.updateLogGroupNote()
                    }
                } else {
                    if self.newNote!.count > 0 {
                        self.updateLogGroupNote()
                    }
                }
            }
        })
        alert.addAction(UIAlertAction(title: lang.titleCancel, style: .cancel) { _ in })
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func alertAvgCondScore() {
        var message = ""
        var month = ""
        var heightInt = 0
        switch lang.currentLanguageId {
        case LanguageId.eng:
            month = LangHelper.getEngNameOfMonth(monthNumber: monthNumber!)
            heightInt = 210
        case LanguageId.kor:
            month = LangHelper.getKorNameOfMonth(monthNumber: monthNumber!, engMMM: nil)
            heightInt = 190
        case LanguageId.jpn:
            // TODO
            print("")
        default: fatalError() }
        let imageView: UIImageView = {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 12))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.addShadowView()
            return imageView
        }()
        let changedScorelabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 15))
            label.font = .systemFont(ofSize: 15, weight: .regular)
            label.textColor = .lightGray
            label.addShadowView()
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        if thisAvgScore! < lastAvgScore! {
            if calendarView.scope == .month {
                message = lang.msgAvgScoreDownMonth(month)
            } else {
                message = lang.msgAvgScoreDownWeek
            }
            imageView.image = UIImage.itemTrendDown.withRenderingMode(.alwaysOriginal)
            changedScorelabel.text = String(format: "-%.1f", (lastAvgScore! - thisAvgScore!))
        } else if thisAvgScore! == lastAvgScore! {
            if calendarView.scope == .month {
                message = lang.msgAvgScoreEqualMonth(month)
            } else {
                message = lang.msgAvgScoreEqualWeek
            }
            imageView.image = UIImage.itemTrendUpGray.withRenderingMode(.alwaysOriginal)
            changedScorelabel.text = "+0.0"
        } else {
            if calendarView.scope == .month {
                message = lang.msgAvgScoreUpMonth(month)
            } else {
                message = lang.msgAvgScoreUpWeek
            }
            imageView.image = UIImage.itemTrendUp.withRenderingMode(.alwaysOriginal)
            changedScorelabel.text = String(format: "+%.1f", (thisAvgScore! - lastAvgScore!))
        }
        var title = lang.titleAvgMoodScoreWeek
        if calendarView.scope == .month {
            title = lang.titleAvgMoodScoreMonth
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let thisAvgScorelabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 40, weight: .regular)
            label.text = String(format: "%.1f", thisAvgScore!)
            label.addShadowView()
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        let lastAvgScorelabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            label.font = .systemFont(ofSize: 30, weight: .regular)
            label.text = String(format: "%.1f", lastAvgScore!)
            label.textColor = UIColor.black.withAlphaComponent(0.6)
            label.addShadowView()
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        let thisAvgNamelabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 15))
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.textAlignment = .center
            label.textColor = .black
            label.addShadowView()
            if calendarView.scope == .month {
                label.text = lang.titleThisMonth
            } else {
                label.text = lang.titleThisWeek
            }
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        let lastAvgNamelabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 13, weight: .medium)
            label.textAlignment = .center
            label.textColor = .darkGray
            label.addShadowView()
            if calendarView.scope == .month {
                label.text = lang.titleLastMonth
            } else {
                label.text = lang.titleLastWeek
            }
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        alert.view.addSubview(imageView)
        alert.view.addSubview(changedScorelabel)
        alert.view.addSubview(thisAvgScorelabel)
        alert.view.addSubview(lastAvgScorelabel)
        alert.view.addSubview(thisAvgNamelabel)
        alert.view.addSubview(lastAvgNamelabel)
        
        imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor, constant: 0).isActive = true
        imageView.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor, constant: 10).isActive = true
        
        changedScorelabel.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor, constant: 0).isActive = true
        changedScorelabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -1).isActive = true
        
        thisAvgScorelabel.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor, constant: 10).isActive = true
        thisAvgScorelabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10).isActive = true
        
        thisAvgNamelabel.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor, constant: 35).isActive = true
        thisAvgNamelabel.centerXAnchor.constraint(equalTo: thisAvgScorelabel.centerXAnchor, constant: 0).isActive = true
        
        lastAvgScorelabel.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -10).isActive = true
        lastAvgScorelabel.bottomAnchor.constraint(equalTo: thisAvgScorelabel.bottomAnchor, constant: -5).isActive = true
        
        lastAvgNamelabel.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor, constant: 35).isActive = true
        lastAvgNamelabel.centerXAnchor.constraint(equalTo: lastAvgScorelabel.centerXAnchor, constant: -2).isActive = true
        
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: CGFloat(heightInt))
        alert.view.addConstraint(height)
        alert.addAction(UIAlertAction(title: lang.titleDone, style: .default) { _ in })
        alert.view.tintColor = .purple_B847FF
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func toggleButtonTapped() {
        selectedOnceCellIdxPath = nil
        selectedTableSection = nil
        selectedTableRow = nil
        isToggleBtnTapped = true
        if calendarView.scope == .month {
            calendarView.setScope(.week, animated: true)
            toggleBtn.setImage(UIImage.itemArrowMaximize.withRenderingMode(.alwaysOriginal), for: .normal)
            selectedCalScope = CalScope.week
            selectedWeekOfYear = Calendar.current.component(.weekOfYear, from: calendarView.currentPage)
            yearForWeekOfYear = Calendar.current.component(.yearForWeekOfYear, from: calendarView.currentPage)
            loadLogGroups()
        } else {
            calendarView.setScope(.month, animated: true)
            toggleBtn.setImage(UIImage.itemArrowMinimize.withRenderingMode(.alwaysOriginal), for: .normal)
            selectedCalScope = CalScope.month
            selectedWeekOfYear = nil
            loadLogGroups()
        }
        updateLogGroupTable()
    }
    
    @objc func refreshLogGroupTableView(sender:AnyObject) {
        selectedOnceCellIdxPath = nil
        selectedTableSection = nil
        selectedTableRow = nil
        isPullToRefresh = true
        refreshControler.endRefreshing()
    }
    
    @objc func pickerCancelButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            UIView.transition(with: self.blindView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.blindView.isHidden = true
            })
        })
    }
    
    @objc func pickerCheckButtonTapped() {
        self.view.showSpinner()
        UIView.transition(with: pickerContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.pickerContainerView.isHidden = true
        })
        createGroupOfALog()
    }
    
    @objc func diseaseRightBtnTapped() {
        if isCondEditBtnTapped {
            isCondEditBtnTapped = false
            diseaseRightBtn.setTitle(lang.titleEdit, for: .normal)
            diseaseRightBtn.setTitleColor(.purple_B847FF, for: .normal)
            UIView.animate(withDuration: 0.5) {
                self.diseaseCollection.reloadData()
            }
        } else {
            isCondEditBtnTapped = true
            diseaseRightBtn.setTitle(lang.titleDone, for: .normal)
            diseaseRightBtn.setTitleColor(.red_FF4779, for: .normal)
            UIView.animate(withDuration: 0.5) {
                self.diseaseCollection.reloadData()
            }
        }
    }
    
    @objc func diseaseLeftBtnTapped() {
        UIView.transition(with: self.blindView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.blindView.isHidden = true
            self.diseaseLeftBtn.setTitleColor(UIColor.clear, for: .normal)
        }, completion: { (_) in
            self.diseaseLeftBtn.isHidden = true
            self.isCondEditBtnTapped = false
            self.diseaseRightBtn.setTitle(self.lang.titleEdit, for: .normal)
            self.diseaseRightBtn.setTitleColor(.purple_B847FF, for: .normal)
        })
    }
    
    @objc func diseaseRefreshButtonTapped() {
        loadAvatarDiseasHistory()
    }
    
    @objc func homeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func avgScoreButtonTapped() {
        loadAvgCondScore()
    }
    
    @objc func presentNotesNavigation() {
        let vc = NoteController()
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true, completion: nil)
    }
    
    @objc func diseaseHistoryBtnTapped() {
        loadAvatarDiseasHistory()
    }
    
    @objc func removeAvatarCondBtnTapped() {
        updateAvatarCondRemove()
    }
    
    @objc func presentCategoryWhenGroupOfALogCellTapped(sender: UIButton) {
        let vc = CategoryViewController()
        vc.superTagId = sender.tag
        vc.topLeftButtonType = ButtonType.back
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func presentFoodCategory() {
        let vc = CategoryViewController()
        vc.superTagId = TagId.food
        vc.topLeftButtonType = ButtonType.back
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func presentPillCategory() {
        let vc = CategoryViewController()
        vc.superTagId = TagId.pill
        vc.topLeftButtonType = ButtonType.back
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func presentActivityCategory() {
        let vc = CategoryViewController()
        vc.superTagId = TagId.activity
        vc.topLeftButtonType = ButtonType.back
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func presentDiseaseCategory() {
        let vc = CategoryViewController()
        vc.superTagId = TagId.disease
        vc.topLeftButtonType = ButtonType.back
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func presentBookmarkCategory() {
        let vc = CategoryViewController()
        vc.superTagId = TagId.bookmarks
        vc.topLeftButtonType = ButtonType.back
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func plusBtnTapped() {
        UIView.animate(withDuration: 0.3, animations: {
            if self.isPlusBtnTapped {
                self.plusBtn.transform = CGAffineTransform(rotationAngle: 0)
                self.plusBtn.backgroundColor = .purple_921BEA
                self.isPlusBtnTapped = false
            } else {
                self.plusBtn.transform = CGAffineTransform(rotationAngle: (.pi / 2))
                self.plusBtn.backgroundColor = .green_3ED6A7
                self.isPlusBtnTapped = true
            }
            self.plusBtns.forEach { (button) in
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            }
        })
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    // MARK: - FSCalendarDataSource
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        guard let _logGroups = logGroups else {
            return 0
        }
        let currDateArr = dateFormatter.string(from: date).components(separatedBy: "-")
        let _monthNumber = Int(currDateArr[1])
        let _dayNumber = Int(currDateArr[2])
        for _logGroup in _logGroups {
            if _monthNumber == _logGroup.month_number && _dayNumber == _logGroup.day_number {
                return 1
            }
        }
        return 0
    }
    
    // FSCalendarDelegate
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        
        if diaryMode == DiaryMode.logger {
            popoverLogger(date)
        } else {
            return
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        selectedOnceCellIdxPath = nil
        selectedTableSection = nil
        selectedTableRow = nil
        let weekOfYear = Calendar.current.component(.weekOfYear, from: calendar.currentPage)
//        let month = Calendar.current.component(.month, from: calendar.currentPage)
        yearForWeekOfYear = Calendar.current.component(.yearForWeekOfYear, from: calendar.currentPage)
        if calendar.scope == .week {
            selectedCalScope = CalScope.week
            selectedWeekOfYear = weekOfYear
            loadLogGroups()
        } else {
            selectedCalScope = CalScope.month
            selectedWeekOfYear = nil
            loadLogGroups()
        }
        updateLogGroupTable()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarViewHeight.constant = bounds.height
        view.layoutIfNeeded()
    }
}

extension DiaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let sectionCnt = logGroupSectTwoDimArr.count
        return sectionCnt
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCnt = logGroupSectTwoDimArr[section].count
        switch diaryMode {
        case DiaryMode.editor:
            return rowCnt
        case DiaryMode.logger:
            // Add "Create new group" cell
            return rowCnt + 1
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if logGroupSectTwoDimArr.count <= 0 {
            return nil
        } else {
            // Set properties
            let logGroup = logGroupSectTwoDimArr[section][0].logGroup
            let date = dateFormatter.date(from: "\(logGroup.year_number)-\(logGroup.month_number)-\(logGroup.day_number)")
            var weekday = lang.getWeekdayName(Calendar.current.component(.weekday, from: date!))
            let strTodayDateArr = dateFormatter.string(from: calendarView.today!).components(separatedBy: "-")
            if Int(strTodayDateArr[1]) == logGroup.month_number && Int(strTodayDateArr[2]) == logGroup.day_number {
                // If the date of the currently selected section is today add the ✨ emoji in it to prefix
//                weekday = "\u{2728}" + weekday
                weekday = "\u{26A1}" + weekday
//                weekday = "\u{1F31F}" + weekday
            }
            
            // Set view layout
            let label = UILabel()
            label.text = "\(weekday), \(lang.getLogGroupSection(logGroup.month_number, logGroup.day_number))"
            label.textAlignment = .center
            label.frame = CGRect(x: 0, y: -30, width: 100, height: 45)
            label.sizeToFit()
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.textColor = UIColor.darkGray
            return label
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: logGroupTableCellId, for: indexPath) as? LogGroupTableCell else {
            fatalError()
        }
        switch diaryMode {
        case DiaryMode.editor:
            let logGroup = logGroupSectTwoDimArr[indexPath.section][indexPath.row].logGroup
            cell.arrowImageView.isHidden = false
            cell.moodScoreImageView.isHidden = false
            cell.nameLabel.text = lang.getLogGroupTypeName(logGroup.group_type)
            cell.groupTypeImageView.image = getLogGroupTypeImage(logGroup.group_type)
            cell.nameLabel.textColor = UIColor.black
            if logGroup.food_cnt > 0 {
                cell.foodLogBulletView.isHidden = false
            }
            if logGroup.act_cnt > 0 {
                cell.actLogBulletView.isHidden = false
            }
            if logGroup.drug_cnt > 0 {
                cell.drugLogBulletView.isHidden = false
            }
            if let condScore = logGroup.cond_score {
                cell.moodScoreImageView.image = getCondScoreImageSmall(condScore)
                cell.moodScoreButton.setImage(getCondScoreImageSmall(condScore), for: .normal)
                cell.moodBtnGuideLabel.textColor = .clear
            } else {
                cell.moodScoreImageView.image = .itemScoreNone
                cell.moodScoreButton.setImage(.itemScoreNone, for: .normal)
                cell.moodBtnGuideLabel.textColor = .purple_948BFF
            }
            if logGroup.note != nil {
                cell.noteImageView.isHidden = false
                cell.noteButton.setImage(.itemNoteYellow, for: .normal)
            } else {
                cell.noteImageView.isHidden = true
                cell.noteButton.setImage(.itemNoteGray, for: .normal)
            }
            cell.moodScoreButton.addTarget(self, action: #selector(alertCondScorePicker), for: .touchUpInside)
            cell.noteButton.addTarget(self, action: #selector(alertNoteTextView(_:)), for: .touchUpInside)
            
            cell.logCellButton.addTarget(self, action: #selector(presentCategoryWhenGroupOfALogCellTapped(sender:)), for: .touchUpInside)
            
            return cell
        case DiaryMode.logger:
            if indexPath.row == 0 {
                // Case 'Create new group' cell
                cell.nameLabel.text = lang.titleCreateNewGroup
                cell.nameLabel.textColor = .green_3ED6A7
                cell.groupTypeImageView.image = nil
                cell.foodLogBulletView.isHidden = true
                cell.actLogBulletView.isHidden = true
                cell.drugLogBulletView.isHidden = true
                cell.noteImageView.isHidden = true
                return cell
            } else {
                let logGroup = logGroupSectTwoDimArr[indexPath.section][indexPath.row - 1].logGroup
                cell.nameLabel.text = lang.getLogGroupTypeName(logGroup.group_type)
                cell.groupTypeImageView.image = nil
                cell.nameLabel.textColor = .green_3ED6A7
                return cell
            }
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if diaryMode == DiaryMode.logger {
            if indexPath.row == 0 {
                // Case "Create new group" cell disable swipe to delete.
                return
            }
        }
        selectedOnceCellIdxPath = nil
        selectedTableSection = nil
        selectedTableRow = nil
        editedCellIdxPath = indexPath
        updateLogGroupRemove()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch diaryMode {
        case DiaryMode.editor:
            selectedLogGroup = logGroupSectTwoDimArr[indexPath.section][indexPath.row].logGroup
            selectedTableSection = indexPath.section
            selectedTableRow = indexPath.row
            groupType = selectedLogGroup!.group_type
            selectedLogGroupId = selectedLogGroup!.id
            loadGroupOfLogs { (groupOfLogSet) in
                guard let cell = tableView.cellForRow(at: indexPath) as? LogGroupTableCell else {
                    fatalError()
                }
                if indexPath == self.selectedOnceCellIdxPath {
                    // Case did select row that has already been selected.
                    self.selectedOnceCellIdxPath = nil
                    self.selectedTableSection = nil
                    self.selectedTableRow = nil
                    let total = self.getGroupOfLogsTotalCnt(groupOfLogSet)
                    var duration = Double(total) * 0.05
                    if total < 3 {
                        duration = Double(total) * 0.12
                    } else if total < 5 {
                        duration = Double(total) * 0.1
                    }
                    UIView.animate(withDuration: duration, animations: {
                        cell.containerViewHight.constant = 45
                        cell.arrowImageView.transform = CGAffineTransform.identity
                        self.view.layoutIfNeeded()
                    }, completion: { _ in
                        UIView.transition(with: cell.groupOfLogsTableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                            cell.groupOfLogsTableView.isHidden = true
                            cell.moodScoreButton.isHidden = true
                            cell.moodBtnGuideLabel.isHidden = true
                            cell.noteButton.isHidden = true
                            cell.moodScoreImageView.isHidden = false
                            if self.selectedLogGroup!.food_cnt > 0 {
                                cell.foodLogBulletView.isHidden = false
                            }
                            if self.selectedLogGroup!.act_cnt > 0 {
                                cell.actLogBulletView.isHidden = false
                            }
                            if self.selectedLogGroup!.drug_cnt > 0 {
                                cell.drugLogBulletView.isHidden = false
                            }
                            if self.selectedLogGroup!.note != nil {
                                cell.noteImageView.isHidden = false
                            }
                        })
                    })
                    self.updateLogGroupTable()
                } else {
                    // Case did select row for the first time.
                    cell.selectedLogGroup = self.selectedLogGroup!
                    cell.groupOfLogSetForCnt = self.groupOfLogSet!
                    cell.groupOfLogSetForPop = self.groupOfLogSet!
                    cell.logsArray = []  // Reset logsArray, Do not chage this line!
                    cell.groupOfLogsTableView.reloadData()
                    self.selectedOnceCellIdxPath = indexPath
                    let total = self.getGroupOfLogsTotalCnt(groupOfLogSet)
                    let duration = Double(total) * 0.04
                    UIView.animate(withDuration: duration, animations: {
                        cell.groupOfLogsTableHeight.constant = CGFloat((total * logTableCellHeightInt))
                        cell.containerViewHight.constant = CGFloat((total * logTableCellHeightInt) + logGroupCellHeightInt + logGroupFooterHeightInt)
                        cell.arrowImageView.transform = CGAffineTransform(rotationAngle: (.pi / 2))
                        self.view.layoutIfNeeded()
                    }, completion: { _ in
                        UIView.transition(with: cell.groupOfLogsTableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                            cell.groupOfLogsTableView.isHidden = false
                            cell.moodScoreButton.isHidden = false
                            cell.moodBtnGuideLabel.isHidden = false
                            cell.noteButton.isHidden = false
                            cell.moodScoreImageView.isHidden = true
                            cell.foodLogBulletView.isHidden = true
                            cell.actLogBulletView.isHidden = true
                            cell.drugLogBulletView.isHidden = true
                            cell.noteImageView.isHidden = true
                        })
                    })
                    self.updateLogGroupTable(completion: {
                        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                    })
                }
            }
        case DiaryMode.logger:
            if indexPath.row == 0 {
                // Case did select row 'Create new group' cell
                let lastLogGroup = logGroupSectTwoDimArr[indexPath.section].first!.logGroup
                selectedLogGroup = lastLogGroup
                if LogGroupType.nighttime > lastLogGroup.group_type {
                    // Case the "Nighttime" groupType has not been created yet.
                    // Display next groupType of logGroup and set parameters.
                    groupType = lastLogGroup.group_type + 1
                    groupOfLogSet = nil
                    tempStoredLogs.removeAll()
                    selectedLogGroupId = nil
                    afterLoadGroupOfLogs(pickerCollectionHeightInt)
                } else {
                    // Case the "Nighttime" groupType has already been created.
                    // Display last existing logGroup and set parameters.
                    groupType = LogGroupType.nighttime
                    selectedLogGroupId = lastLogGroup.id
                    loadGroupOfLogs { (groupOfLogSet) in
                        let collectionViewHeight = logCollectionCellHeightInt * self.getGroupOfLogsTotalCnt(groupOfLogSet)
                        self.afterLoadGroupOfLogs(collectionViewHeight)
                    }
                }
            } else {
                // Case did select row that has already been created.
                selectedLogGroup = logGroupSectTwoDimArr[indexPath.section][indexPath.row - 1].logGroup
                groupType = selectedLogGroup!.group_type
                selectedLogGroupId = selectedLogGroup!.id
                loadGroupOfLogs { (groupOfLogSet) in
                    let collectionViewHeight = logCollectionCellHeightInt * self.getGroupOfLogsTotalCnt(groupOfLogSet)
                    self.afterLoadGroupOfLogs(collectionViewHeight)
                }
            }
        default:
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(logGroupSectionHeightInt)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == selectedOnceCellIdxPath {
            let total = getGroupOfLogsTotalCnt(groupOfLogSet!)
            return CGFloat((total * logTableCellHeightInt) + logGroupCellHeightInt + logGroupFooterHeightInt + marginInt)
        } else {
            if let cell = tableView.cellForRow(at: indexPath) as? LogGroupTableCell {
                // This code block will transform unselected cells back to default state when a tableView beginupdates.
                cell.containerViewHight.constant = CGFloat(logGroupCellHeightInt - 7)
                cell.arrowImageView.transform = CGAffineTransform.identity
                cell.groupOfLogsTableView.isHidden = true
                cell.moodScoreImageView.isHidden = false
                cell.moodScoreButton.isHidden = true
                cell.moodBtnGuideLabel.isHidden = true
                cell.noteButton.isHidden = true
                if diaryMode == DiaryMode.editor {
                    let logGroup = self.logGroupSectTwoDimArr[indexPath.section][indexPath.row].logGroup
                    if logGroup.food_cnt > 0 {
                        cell.foodLogBulletView.isHidden = false
                    } else {
                        cell.foodLogBulletView.isHidden = true
                    }
                    if logGroup.act_cnt > 0 {
                        cell.actLogBulletView.isHidden = false
                    } else {
                        cell.actLogBulletView.isHidden = true
                    }
                    if logGroup.drug_cnt > 0 {
                        cell.drugLogBulletView.isHidden = false
                    } else {
                        cell.drugLogBulletView.isHidden = true
                    }
                    if logGroup.note != nil {
                        cell.noteImageView.isHidden = false
                    } else {
                        cell.noteImageView.isHidden = true
                    }
                }
            }
            return CGFloat(logGroupCellHeightInt)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if diaryMode == DiaryMode.logger {
            return
        }
        // The cells has not store data itself.
        // So when they vanished from the screen, they lost view layout infos.
        // That means they need to resetting view layouts, when they reappear from vanishing.
        guard let cell = cell as? LogGroupTableCell else {
            return
        }
        if indexPath == selectedOnceCellIdxPath {
            cell.selectedLogGroup = selectedLogGroup!
            cell.groupOfLogSetForCnt = groupOfLogSet!
            cell.groupOfLogSetForPop = groupOfLogSet!
            cell.groupOfLogsTableView.reloadData()
            let total = getGroupOfLogsTotalCnt(groupOfLogSet!)
            cell.groupOfLogsTableHeight.constant = CGFloat((total * logTableCellHeightInt))
            cell.containerViewHight.constant = CGFloat((total * logTableCellHeightInt) + logGroupCellHeightInt + logGroupFooterHeightInt)
            cell.arrowImageView.transform = CGAffineTransform(rotationAngle: (.pi / 2))
            cell.groupOfLogsTableView.isHidden = false
            cell.moodScoreImageView.isHidden = true
            cell.foodLogBulletView.isHidden = true
            cell.actLogBulletView.isHidden = true
            cell.drugLogBulletView.isHidden = true
            cell.noteImageView.isHidden = true
            cell.moodScoreButton.isHidden = false
            cell.moodBtnGuideLabel.isHidden = false
            cell.noteButton.isHidden = false
        } else {
            cell.containerViewHight.constant = CGFloat(logGroupCellHeightInt - 7)
            cell.arrowImageView.transform = CGAffineTransform.identity
            cell.groupOfLogsTableView.isHidden = true
            cell.moodScoreImageView.isHidden = false
            cell.moodScoreButton.isHidden = true
            cell.moodBtnGuideLabel.isHidden = true
            cell.noteButton.isHidden = true
            let logGroup = logGroupSectTwoDimArr[indexPath.section][indexPath.row].logGroup
            if diaryMode == DiaryMode.editor {
                if logGroup.food_cnt > 0 {
                    cell.foodLogBulletView.isHidden = false
                } else {
                    cell.foodLogBulletView.isHidden = true
                }
                if logGroup.act_cnt > 0 {
                    cell.actLogBulletView.isHidden = false
                } else {
                    cell.actLogBulletView.isHidden = true
                }
                if logGroup.drug_cnt > 0 {
                    cell.drugLogBulletView.isHidden = false
                } else {
                    cell.drugLogBulletView.isHidden = true
                }
                if logGroup.note != nil {
                    cell.noteImageView.isHidden = false
                } else {
                    cell.noteImageView.isHidden = true
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if diaryMode == DiaryMode.editor && isPullToRefresh {
            loadLogGroups()
        }
    }
}

extension DiaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case pickerCollection:
            var total = 0
            if let foodLogs = groupOfLogSet?.food_logs {
                total += (foodLogs.count)
            }
            if let actLogs = groupOfLogSet?.act_logs {
                total += (actLogs.count)
            }
            if let drugLogs = groupOfLogSet?.drug_logs {
                total += (drugLogs.count)
            }
            return total
        case diseaseCollection:
            return avtCondList?.count ?? 0
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case pickerCollection:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: logCollectionCellId, for: indexPath) as? LogCollectionCell else {
                fatalError()
            }
            if ((groupOfLogSet!.food_logs?.count) != nil && ((groupOfLogSet!.food_logs?.count)!) > 0) {
                let foodLog = groupOfLogSet!.food_logs!.popLast()
                tempStoredLogs.append(foodLog!)
                
                cell.bulletView.backgroundColor = UIColor.tomato
                switch lang.currentLanguageId {
                case LanguageId.eng: cell.nameLabel.text = foodLog!.eng_name
                case LanguageId.kor: cell.nameLabel.text = foodLog!.kor_name
                case LanguageId.jpn: cell.nameLabel.text = foodLog!.jpn_name
                default: fatalError()}
                var x_val = ""
                if foodLog!.x_val! > 0 {
                    x_val = "\(foodLog!.x_val!)"
                }
                if foodLog!.y_val == 0 {
                    cell.quantityLabel.text = "\(x_val)"
                } else if foodLog!.y_val == 1 {
                    cell.quantityLabel.text = "\(x_val)¼"
                } else if foodLog!.y_val == 2 {
                    cell.quantityLabel.text = "\(x_val)½"
                } else if foodLog!.y_val == 3 {
                    cell.quantityLabel.text = "\(x_val)¾"
                }
            } else if ((groupOfLogSet!.act_logs?.count) != nil && ((groupOfLogSet!.act_logs?.count)!) > 0) {
                let actLog = groupOfLogSet!.act_logs!.popLast()
                tempStoredLogs.append(actLog!)
                
                cell.bulletView.backgroundColor = .cornflowerBlue
                switch lang.currentLanguageId {
                case LanguageId.eng: cell.nameLabel.text = actLog!.eng_name
                case LanguageId.kor: cell.nameLabel.text = actLog!.kor_name
                case LanguageId.jpn: cell.nameLabel.text = actLog!.jpn_name
                default: fatalError()}
                var hr = ""
                var min = ""
                if actLog!.x_val! > 0 {
                    hr = "\(actLog!.x_val!)hr"
                }
                if actLog!.y_val != 0 {
                    min = " \(actLog!.y_val!)min"
                }
                cell.quantityLabel.text = "\(hr)\(min)"
            } else if ((groupOfLogSet!.drug_logs?.count) != nil && ((groupOfLogSet!.drug_logs?.count)!) > 0) {
                let drugLog = groupOfLogSet!.drug_logs!.popLast()
                tempStoredLogs.append(drugLog!)
                
                cell.bulletView.backgroundColor = .green_72E5EA
                switch lang.currentLanguageId {
                case LanguageId.eng: cell.nameLabel.text = drugLog!.eng_name
                case LanguageId.kor: cell.nameLabel.text = drugLog!.kor_name
                case LanguageId.jpn: cell.nameLabel.text = drugLog!.jpn_name
                default: fatalError()}
                var x_val = ""
                if drugLog!.x_val! > 0 {
                    x_val = "\(drugLog!.x_val!)"
                }
                if drugLog!.y_val == 0 {
                    cell.quantityLabel.text = "\(x_val)"
                } else if drugLog!.y_val == 1 {
                    cell.quantityLabel.text = "\(x_val)¼"
                } else if drugLog!.y_val == 2 {
                    cell.quantityLabel.text = "\(x_val)½"
                } else if drugLog!.y_val == 3 {
                    cell.quantityLabel.text = "\(x_val)¾"
                }
            }
            return cell
        case diseaseCollection:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: condCollectionCellId, for: indexPath) as? CondCollectionCell,
                let avtCond = avtCondList?[indexPath.item] else {
                    fatalError()
            }
            if self.isCondEditBtnTapped {
                cell.titleLabel.textColor = UIColor.lightGray
                cell.stackView.isHidden = true
                cell.removeImageView.isHidden = false
            } else {
                cell.titleLabel.textColor = UIColor.black
                cell.stackView.isHidden = false
                cell.removeImageView.isHidden = true
            }
            switch lang.currentLanguageId {
            case LanguageId.eng:
                cell.titleLabel.text = avtCond.eng_name
                if let startDate = avtCond.start_date {
                    cell.startDateLabel.text = "\(startDate)\u{021E2}"
                }
                if let endDate = avtCond.end_date {
                    cell.endDateLabel.text = "\u{2713}\(endDate)"
                }
            case LanguageId.kor:
                cell.titleLabel.text = avtCond.kor_name
                if let startDate = avtCond.start_date {
                    let dateArr = startDate.split(separator: "/")
                    let month = LangHelper.getKorNameOfMonth(monthNumber: nil, engMMM: String(dateArr[0]))
                    cell.startDateLabel.text = "\(month)/\(dateArr[1])/\(dateArr[2])\u{021E2}"
                }
                if let endDate = avtCond.end_date {
                    let dateArr = endDate.split(separator: "/")
                    let month = LangHelper.getKorNameOfMonth(monthNumber: nil, engMMM: String(dateArr[0]))
                    cell.endDateLabel.text = "\u{2713}\(month)/\(dateArr[1])/\(dateArr[2])"
                }
            case LanguageId.jpn:
                cell.titleLabel.text = avtCond.jpn_name
            default:
                fatalError()
            }
            return cell
        default:
            fatalError()
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case pickerCollection:
            return
        case diseaseCollection:
            if isCondEditBtnTapped {
                selectedAvatarDiseaseId = avtCondList![indexPath.item].id
                updateAvatarCondRemove()
                return
            }
            let vc = CategoryViewController()
            vc.topLeftButtonType = ButtonType.close
            vc.superTagId = avtCondList![indexPath.item].tag_id
            vc.topLeftButtonType = ButtonType.back
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == diseaseCollection {
            // Prevent the display of non-existent dateLabels.
            guard let cell = cell as? CondCollectionCell,
                let avtCond = avtCondList?[indexPath.item] else {
                return
            }
            if self.isCondEditBtnTapped {
                cell.titleLabel.textColor = UIColor.lightGray
                cell.stackView.isHidden = true
                cell.removeImageView.isHidden = false
            } else {
                cell.titleLabel.textColor = UIColor.black
                cell.stackView.isHidden = false
                cell.removeImageView.isHidden = true
            }
            if avtCond.start_date != nil  {
                cell.startDateLabel.isHidden = false
            } else {
                cell.startDateLabel.isHidden = true
            }
            if avtCond.end_date != nil  {
                cell.endDateLabel.isHidden = false
            } else {
                cell.endDateLabel.isHidden = true
            }
        } else if collectionView == pickerCollection {
            // The cells has not store data itself.
            // So when they vanished from the screen, they lost view layout infos.
            // That means they need to resetting view layouts, when they reappear from vanishing.
            guard let cell = cell as? LogCollectionCell else {
                return
            }
            let tagLog = tempStoredLogs[indexPath.item]
            switch lang.currentLanguageId {
            case LanguageId.eng: cell.nameLabel.text = tagLog.eng_name
            case LanguageId.kor: cell.nameLabel.text = tagLog.kor_name
            default: fatalError() }
            if tagLog.tag_type == TagType.food {
                cell.bulletView.backgroundColor = .tomato
                var x_val = ""
                if tagLog.x_val! > 0 {
                    x_val = "\(tagLog.x_val!)"
                }
                if tagLog.y_val == 0 {
                    cell.quantityLabel.text = "\(x_val)"
                } else if tagLog.y_val == 1 {
                    cell.quantityLabel.text = "\(x_val)¼"
                } else if tagLog.y_val == 2 {
                    cell.quantityLabel.text = "\(x_val)½"
                } else if tagLog.y_val == 3 {
                    cell.quantityLabel.text = "\(x_val)¾"
                }
            } else if tagLog.tag_type == TagType.activity {
                cell.bulletView.backgroundColor = .cornflowerBlue
                var hr = ""
                var min = ""
                if tagLog.x_val! > 0 {
                    hr = "\(tagLog.x_val!)hr"
                }
                if tagLog.y_val != 0 {
                    min = " \(tagLog.y_val!)min"
                }
                cell.quantityLabel.text = "\(hr)\(min)"
            } else if tagLog.tag_type == TagType.drug {
                cell.bulletView.backgroundColor = .green_72E5EA
                var x_val = ""
                if tagLog.x_val! > 0 {
                    x_val = "\(tagLog.x_val!)"
                }
                if tagLog.y_val == 0 {
                    cell.quantityLabel.text = "\(x_val)"
                } else if tagLog.y_val == 1 {
                    cell.quantityLabel.text = "\(x_val)¼"
                } else if tagLog.y_val == 2 {
                    cell.quantityLabel.text = "\(x_val)½"
                } else if tagLog.y_val == 3 {
                    cell.quantityLabel.text = "\(x_val)¾"
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        switch collectionView {
        case pickerCollection:
//            return CGSize(width: screenWidth - (screenWidth / 5), height: CGFloat(30))
            return CGSize(width: screenWidth - (screenWidth / 7), height: CGFloat(30))
        case diseaseCollection:
            return CGSize(width: screenWidth - (screenWidth / 7), height: CGFloat(45))
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DiaryViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case groupTypePicker:
            return numberOfGroupType
        case moodScorePicker:
            return moodScores.count
        default:
            fatalError()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if pickerView == groupTypePicker {
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 60))
            let imageView = UIImageView(frame: CGRect(x: pickerView.bounds.midX - 80, y: 15, width: 33, height: 33))
            let label = UILabel(frame: CGRect(x: pickerView.bounds.midX - 15, y: 0, width: pickerView.bounds.width - 50, height: 60))
            imageView.image = getLogGroupTypeImage(4 - row)
            label.text = lang.getLogGroupTypeName(4 - row)
            containerView.addSubview(imageView)
            containerView.addSubview(label)
            return containerView
        } else if pickerView == moodScorePicker {
            let label = UILabel(frame: CGRect(x: pickerView.bounds.midX - 15, y: 0, width: 20, height: 40))
            label.textAlignment = .center
            label.text = "\(moodScores[9 - row])"
            return label
        } else {
            fatalError()
        }
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case groupTypePicker:
            groupType = LogGroupType.nighttime - row
            if let logGroupDict = logGroupDictTwoDimArr[dayOfYear!] {
                // Case found a logGroup in the section.
                if let logGroup = logGroupDict[groupType!] {
                    // Case found some groupOfLogs in the logGroup.
                    selectedLogGroupId = logGroup.id
                    selectedLogGroup = logGroup
                    tempStoredLogs.removeAll()
                    loadGroupOfLogs { (groupOfLogSet) in
                        let collectionViewHeight = logCollectionCellHeightInt * self.getGroupOfLogsTotalCnt(groupOfLogSet)
                        self.afterLoadGroupOfLogs(collectionViewHeight)
                    }
                } else {
                    // Case no groupOfLogs are found in the logGroup.
                    groupOfLogSet = nil
                    tempStoredLogs.removeAll()
                    selectedLogGroupId = nil
                    selectedLogGroup = nil
                    pickerContainerTransition(pickerCollectionHeightInt)
                }
            } else {
                // Case no logGroups are found in the section.
                groupOfLogSet = nil
                tempStoredLogs.removeAll()
                selectedLogGroupId = nil
                selectedLogGroup = nil
                pickerContainerTransition(pickerCollectionHeightInt)
            }
        case moodScorePicker:
            selectedDiseasePickerIdx = row
            selectedMoodScore = moodScores[9 - row]
            moodScorePicker.reloadAllComponents()
        default:
            fatalError()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        switch pickerView {
        case groupTypePicker:
            return CGFloat(groupTypePickerRowHeightInt)
        case moodScorePicker:
            return CGFloat(condScorePickerRowHeightInt)
        default:
            fatalError()
        }
    }
}

extension DiaryViewController {
    
    // MARK: Private methods
    
    private func setupLayout() {
        // Initialize view
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        
        if diaryMode == DiaryMode.editor {
            switch lang.currentLanguageId {
            case LanguageId.eng: navigationItem.title = superTag?.eng_name
            case LanguageId.kor: navigationItem.title = superTag?.kor_name
            case LanguageId.jpn: navigationItem.title = superTag?.jpn_name
            default: return }
        } else {
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)]
            navigationItem.title = lang.msgDiarySelect
        }
        view.backgroundColor = .whiteSmoke
        
        // Initialize subveiw properties
        blindView = getAlertBlindView()
        pickerGrayLineView = getGrayLineView()
        pickerContainerView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.layer.cornerRadius = 10.0
            _view.isHidden = true
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        diseaseContainer = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.layer.cornerRadius = 10.0
            _view.isHidden = true
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        calendarView = {
            let _calendar = FSCalendar()
            _calendar.appearance.headerTitleColor = .black
            _calendar.appearance.weekdayTextColor = .black
            _calendar.appearance.titleDefaultColor = .green_3ED6A7
            _calendar.appearance.titlePlaceholderColor = .lightGray
            _calendar.appearance.eventDefaultColor = .red_FF4779
            _calendar.appearance.eventSelectionColor = .red_FF4779
            _calendar.appearance.selectionColor = .red_FF4779
            _calendar.appearance.headerDateFormat = lang.calendarHeaderDateFormat
            _calendar.appearance.caseOptions = FSCalendarCaseOptions.weekdayUsesUpperCase
            _calendar.scope = .week
            _calendar.select(Date())
            _calendar.addShadowView()
            _calendar.backgroundColor = .white
            _calendar.clipsToBounds = true
            _calendar.translatesAutoresizingMaskIntoConstraints = false
            return _calendar
        }()
        dateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: getUserCountryCode())
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        scopeGesture = {
            [unowned self] in
            let panGesture = UIPanGestureRecognizer(target: self.calendarView, action: #selector(self.calendarView.handleScopeGesture(_:)))
            panGesture.delegate = self
            panGesture.minimumNumberOfTouches = 1
            panGesture.maximumNumberOfTouches = 2
            return panGesture
            }()
        logGroupTable = {
            let _tableView = UITableView(frame: CGRect.zero, style: .grouped)
            _tableView.backgroundColor = .clear
            _tableView.separatorStyle = .none
            _tableView.register(LogGroupTableCell.self, forCellReuseIdentifier: logGroupTableCellId)
            _tableView.translatesAutoresizingMaskIntoConstraints = false
            return _tableView
        }()
        pickerCollection = {
            let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
            _collectionView.backgroundColor = .clear
            _collectionView.register(LogCollectionCell.self, forCellWithReuseIdentifier: logCollectionCellId)
            _collectionView.translatesAutoresizingMaskIntoConstraints = false
            return _collectionView
        }()
        diseaseCollection = {
            let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
            _collectionView.backgroundColor = .clear
            _collectionView.register(CondCollectionCell.self, forCellWithReuseIdentifier: condCollectionCellId)
            _collectionView.dragInteractionEnabled = true
            _collectionView.translatesAutoresizingMaskIntoConstraints = false
            return _collectionView
        }()
        groupTypePicker = {
            let _pickerView = UIPickerView()
            _pickerView.translatesAutoresizingMaskIntoConstraints = false
            return _pickerView
        }()
        moodScorePicker = {
            let _pickerView = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
            _pickerView.translatesAutoresizingMaskIntoConstraints = false
            return _pickerView
        }()
        pickerDateLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 18, weight: .regular)
            _label.textColor = .black
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        diseaseTitleLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 18, weight: .regular)
            _label.textColor = .black
            _label.textAlignment = .left
            _label.text = lang.titleMyAvtCond
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        pickerCancelBtn = getCancelButton()
        pickerCancelBtn.addTarget(self, action: #selector(pickerCancelButtonTapped), for: .touchUpInside)
        pickerCheckBtn = getCheckButton()
        pickerCheckBtn.addTarget(self, action: #selector(pickerCheckButtonTapped), for: .touchUpInside)
        toggleBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemArrowMaximize.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        homeBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemHome.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action:#selector(homeButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        notesBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemNotes.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 45, height: 32)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action:#selector(presentNotesNavigation), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        avgScoreBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemScoreAvg.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action:#selector(avgScoreButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        diseaseHistoryBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemHeartbeat.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 27, height: 25)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action:#selector(diseaseHistoryBtnTapped), for: .touchUpInside)
            _button.isHidden = true
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        diseaseLeftBtn = {
            let _button = UIButton(type: .system)
            _button.setTitle(lang.titleClose, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
            _button.setTitleColor(UIColor.clear, for: .normal)
            _button.showsTouchWhenHighlighted = false
            _button.isHidden = true
            _button.addTarget(self, action:#selector(diseaseLeftBtnTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        diseaseRightBtn = {
            let _button = UIButton(type: .system)
            _button.setTitle(lang.titleEdit, for: .normal)
            _button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            _button.setTitleColor(.purple_B847FF, for: .normal)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(diseaseRightBtnTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        diseaseRefreshBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemReload.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(diseaseRefreshButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        refreshControler = {
            let _refresh = UIRefreshControl()
            _refresh.tintColor = UIColor(hex: "#95EDD2")
            _refresh.addTarget(self, action: #selector(refreshLogGroupTableView(sender:)), for: UIControl.Event.valueChanged)
            return _refresh
        }()
        pullToRefreshLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 16, weight: .bold)
            _label.textColor = .purple_948BFF
            _label.textAlignment = .center
            _label.text = lang.titlePullToRefresh
            _label.numberOfLines = 2
            _label.isHidden = true
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        guideLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 18, weight: .bold)
            _label.textColor = .green_3ED6A7
            _label.textAlignment = .center
            _label.text = lang.msgGuideDiary
            _label.isHidden = true
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        foodBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage(named: "tag-5")!.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.setTitle(lang.titleTagFood, for: .normal)
            _button.tintColor = .green_3ED6A7
            _button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
            _button.backgroundColor = .white
            _button.layer.cornerRadius = 10.0
            _button.addShadowView()
            _button.isHidden = true
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(presentFoodCategory), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        pillBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage(named: "tag-4")!.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.setTitle(lang.titleTagPill, for: .normal)
            _button.tintColor = .green_3ED6A7
            _button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
            _button.backgroundColor = .white
            _button.layer.cornerRadius = 10.0
            _button.addShadowView()
            _button.isHidden = true
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(presentPillCategory), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        activityBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage(named: "tag-2")!.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.setTitle(lang.titleTagActivity, for: .normal)
            _button.tintColor = .green_3ED6A7
            _button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
            _button.backgroundColor = .white
            _button.layer.cornerRadius = 10.0
            _button.addShadowView()
            _button.isHidden = true
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(presentActivityCategory), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        diseaseBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage(named: "tag-3")!.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.setTitle(lang.titleTagDisease, for: .normal)
            _button.tintColor = .green_3ED6A7
            _button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
            _button.backgroundColor = .white
            _button.layer.cornerRadius = 10.0
            _button.addShadowView()
            _button.isHidden = true
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(presentDiseaseCategory), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        plusBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemBtnPlusTrans.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.backgroundColor = .purple_921BEA
            _button.layer.cornerRadius = 13.0
            _button.addShadowView()
            _button.isHidden = true
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(plusBtnTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        foodPlusBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemPlusFood.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.isHidden = true
            _button.showsTouchWhenHighlighted = true
            _button.addShadowView()
            _button.addTarget(self, action: #selector(presentFoodCategory), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        pillPlusBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemPlusPill.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.isHidden = true
            _button.showsTouchWhenHighlighted = true
            _button.addShadowView()
            _button.addTarget(self, action: #selector(presentPillCategory), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        activityPlusBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemPlusActivity.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.isHidden = true
            _button.showsTouchWhenHighlighted = true
            _button.addShadowView()
            _button.addTarget(self, action: #selector(presentActivityCategory), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        diseasePlusBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemPlusDisease.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.isHidden = true
            _button.showsTouchWhenHighlighted = true
            _button.addShadowView()
            _button.addTarget(self, action: #selector(presentDiseaseCategory), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        bookmarkPlusBtn = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage.itemPlusBookmark.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.isHidden = true
            _button.showsTouchWhenHighlighted = true
            _button.addShadowView()
            _button.addTarget(self, action: #selector(presentBookmarkCategory), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        plusBtnStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.alignment = .center
            stackView.spacing = 10.0
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        guideIllustImgView = {
            let _imageView = UIImageView()
            _imageView.image = .itemIllustGirl2
            _imageView.contentMode = .scaleAspectFit
            _imageView.isHidden = true
            _imageView.translatesAutoresizingMaskIntoConstraints = false
            return _imageView
        }()
        
        if diaryMode == DiaryMode.editor {
//            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: homeBtn)
            navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: notesBtn), UIBarButtonItem(customView: avgScoreBtn)]
            calendarView.appearance.titleDefaultColor = UIColor.black
            diseaseHistoryBtn.isHidden = false
            plusBtn.isHidden = false
            plusBtns = [foodPlusBtn, pillPlusBtn, activityPlusBtn, diseasePlusBtn, bookmarkPlusBtn]
            
            plusBtnStackView.addArrangedSubview(bookmarkPlusBtn)
            plusBtnStackView.addArrangedSubview(diseasePlusBtn)
            plusBtnStackView.addArrangedSubview(activityPlusBtn)
            plusBtnStackView.addArrangedSubview(pillPlusBtn)
            plusBtnStackView.addArrangedSubview(foodPlusBtn)
            plusBtnStackView.addArrangedSubview(plusBtn)
        }
        
        calendarView.dataSource = self
        calendarView.delegate = self
        logGroupTable.dataSource = self
        logGroupTable.delegate = self
        pickerCollection.dataSource = self
        pickerCollection.delegate = self
        moodScorePicker.dataSource = self
        moodScorePicker.delegate = self
        diseaseCollection.dataSource = self
        diseaseCollection.delegate = self
        groupTypePicker.dataSource = self
        groupTypePicker.delegate = self
        
        selectedWeekOfYear = Calendar.current.component(.weekOfYear, from: calendarView.today!)
        yearNumber = Calendar.current.component(.year, from: calendarView.today!)
        yearForWeekOfYear = Calendar.current.component(.yearForWeekOfYear, from: calendarView.today!)
        selectedCalScope = CalScope.week
        groupType = LogGroupType.morning
        
        // Setup subviews
        view.addSubview(logGroupTable)
        view.addSubview(guideLabel)
        view.addSubview(foodBtn)
        view.addSubview(pillBtn)
        view.addSubview(activityBtn)
        view.addSubview(diseaseBtn)
        view.addSubview(guideIllustImgView)
        view.addSubview(pullToRefreshLabel)
        view.addSubview(calendarView)
        view.addSubview(diseaseHistoryBtn)
        view.addSubview(toggleBtn)
        view.addSubview(blindView)
        view.addSubview(diseaseLeftBtn)
        view.addSubview(plusBtnStackView)
        view.addGestureRecognizer(scopeGesture)
        
        // TODO
        logGroupTable.addSubview(refreshControler)
        
        blindView.addSubview(pickerContainerView)
        blindView.addSubview(diseaseContainer)
        
        pickerContainerView.addSubview(pickerDateLabel)
        pickerContainerView.addSubview(groupTypePicker)
        pickerContainerView.addSubview(pickerCollection)
        pickerContainerView.addSubview(pickerGrayLineView)
        pickerContainerView.addSubview(pickerCancelBtn)
        pickerContainerView.addSubview(pickerCheckBtn)
        
        diseaseContainer.addSubview(diseaseTitleLabel)
        diseaseContainer.addSubview(diseaseCollection)
        diseaseContainer.addSubview(diseaseRightBtn)
        diseaseContainer.addSubview(diseaseRefreshBtn)
        
        // Setup constraints
        blindView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        blindView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        blindView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        blindView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        pickerContainerView.leadingAnchor.constraint(equalTo: blindView.leadingAnchor, constant: 7).isActive = true
        pickerContainerView.trailingAnchor.constraint(equalTo: blindView.trailingAnchor, constant: -7).isActive = true
        pickerContainerView.centerXAnchor.constraint(equalTo: blindView.centerXAnchor, constant: 0).isActive = true
        pickerContainerView.centerYAnchor.constraint(equalTo: blindView.centerYAnchor, constant: 0).isActive = true
        pickerContainerHeight = pickerContainerView.heightAnchor.constraint(equalToConstant: 450)
        pickerContainerHeight.priority = UILayoutPriority(rawValue: 999)
        pickerContainerHeight.isActive = true
        
        diseaseContainer.leadingAnchor.constraint(equalTo: blindView.leadingAnchor, constant: 7).isActive = true
        diseaseContainer.trailingAnchor.constraint(equalTo: blindView.trailingAnchor, constant: -7).isActive = true
        diseaseContainer.centerXAnchor.constraint(equalTo: blindView.centerXAnchor, constant: 0).isActive = true
        diseaseContainer.centerYAnchor.constraint(equalTo: blindView.centerYAnchor, constant: 0).isActive = true
        condContainerHeight = diseaseContainer.heightAnchor.constraint(equalToConstant: 105 + 45)
        condContainerHeight.priority = UILayoutPriority(rawValue: 999)
        condContainerHeight.isActive = true
        
        pickerDateLabel.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: 10).isActive = true
        pickerDateLabel.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: 20).isActive = true
        
        diseaseTitleLabel.topAnchor.constraint(equalTo: diseaseContainer.topAnchor, constant: 10).isActive = true
        diseaseTitleLabel.leadingAnchor.constraint(equalTo: diseaseContainer.leadingAnchor, constant: 20).isActive = true
        
        groupTypePicker.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: 0).isActive = true
        groupTypePicker.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: 0).isActive = true
        groupTypePicker.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor, constant: 0).isActive = true
        groupTypePicker.heightAnchor.constraint(equalToConstant: 215).isActive = true
        
        pickerCollection.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: 170).isActive = true
        pickerCollection.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: 0).isActive = true
        pickerCollection.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor, constant: 0).isActive = true
        pickerCollectionHeight = pickerCollection.heightAnchor.constraint(equalToConstant: 210)
        pickerCollectionHeight.priority = UILayoutPriority(rawValue: 999)
        pickerCollectionHeight.isActive = true
        
        diseaseCollection.topAnchor.constraint(equalTo: diseaseContainer.topAnchor, constant: 45).isActive = true
        diseaseCollection.leadingAnchor.constraint(equalTo: diseaseContainer.leadingAnchor, constant: 0).isActive = true
        diseaseCollection.trailingAnchor.constraint(equalTo: diseaseContainer.trailingAnchor, constant: 0).isActive = true
        condCollectionHeight = diseaseCollection.heightAnchor.constraint(equalToConstant: 45)
        condCollectionHeight.priority = UILayoutPriority(rawValue: 999)
        condCollectionHeight.isActive = true
        
        pickerGrayLineView.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: (view.frame.width / 13)).isActive = true
        pickerGrayLineView.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor, constant: -(view.frame.width / 13)).isActive = true
        pickerGrayLineView.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor, constant: -50).isActive = true
        pickerGrayLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        pickerCancelBtn.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: 0).isActive = true
        pickerCancelBtn.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor, constant: 0).isActive = true
        pickerCancelBtn.widthAnchor.constraint(equalToConstant: view.frame.width / 4).isActive = true
        pickerCancelBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        pickerCheckBtn.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor, constant: 0).isActive = true
        pickerCheckBtn.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor, constant: 0).isActive = true
        pickerCheckBtn.widthAnchor.constraint(equalToConstant: view.frame.width / 4).isActive = true
        pickerCheckBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        diseaseLeftBtn.leadingAnchor.constraint(equalTo: diseaseContainer.leadingAnchor, constant: 0).isActive = true
        diseaseLeftBtn.bottomAnchor.constraint(equalTo: diseaseContainer.bottomAnchor, constant: -5).isActive = true
        diseaseLeftBtn.widthAnchor.constraint(equalToConstant: view.frame.width / 4).isActive = true
        diseaseLeftBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        plusBtnStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        plusBtnStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
        
        diseaseRightBtn.trailingAnchor.constraint(equalTo: diseaseContainer.trailingAnchor, constant: 0).isActive = true
        diseaseRightBtn.bottomAnchor.constraint(equalTo: diseaseContainer.bottomAnchor, constant: -5).isActive = true
        diseaseRightBtn.widthAnchor.constraint(equalToConstant: view.frame.width / 4).isActive = true
        diseaseRightBtn.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        diseaseRefreshBtn.topAnchor.constraint(equalTo: diseaseContainer.topAnchor, constant: 0).isActive = true
        diseaseRefreshBtn.trailingAnchor.constraint(equalTo: diseaseContainer.trailingAnchor, constant: 0).isActive = true
        
        calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        calendarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        calendarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        calendarViewHeight = calendarView.heightAnchor.constraint(equalToConstant: 225)
        calendarViewHeight.priority = UILayoutPriority(rawValue: 999)
        calendarViewHeight.isActive = true
        
        diseaseHistoryBtn.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 0).isActive = true
        diseaseHistoryBtn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        
        toggleBtn.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 0).isActive = true
        toggleBtn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        
        logGroupTable.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 0).isActive = true
        logGroupTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: CGFloat(marginInt)).isActive = true
        logGroupTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: CGFloat(-marginInt)).isActive = true
        logGroupTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        logGroupTable.panGestureRecognizer.require(toFail: scopeGesture)
        
        pullToRefreshLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120).isActive = true
        pullToRefreshLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        
        guideLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -(view.frame.height * 0.16)).isActive = true
        guideLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        
        foodBtn.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 20).isActive = true
        foodBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        foodBtn.widthAnchor.constraint(equalToConstant: view.frame.width / 2.5).isActive = true
        foodBtn.heightAnchor.constraint(equalToConstant: view.frame.height / 13).isActive = true
        
        pillBtn.topAnchor.constraint(equalTo: foodBtn.bottomAnchor, constant: 10).isActive = true
        pillBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        pillBtn.widthAnchor.constraint(equalToConstant: view.frame.width / 2.5).isActive = true
        pillBtn.heightAnchor.constraint(equalToConstant: view.frame.height / 13).isActive = true
        
        activityBtn.topAnchor.constraint(equalTo: pillBtn.bottomAnchor, constant: 10).isActive = true
        activityBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        activityBtn.widthAnchor.constraint(equalToConstant: view.frame.width / 2.5).isActive = true
        activityBtn.heightAnchor.constraint(equalToConstant: view.frame.height / 13).isActive = true
        
        diseaseBtn.topAnchor.constraint(equalTo: activityBtn.bottomAnchor, constant: 10).isActive = true
        diseaseBtn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        diseaseBtn.widthAnchor.constraint(equalToConstant: view.frame.width / 2.5).isActive = true
        diseaseBtn.heightAnchor.constraint(equalToConstant: view.frame.height / 13).isActive = true
        
        guideIllustImgView.topAnchor.constraint(equalTo: diseaseBtn.bottomAnchor, constant: -15).isActive = true
        guideIllustImgView.leadingAnchor.constraint(equalTo: diseaseBtn.trailingAnchor, constant: 2).isActive = true
    }
    
    private func updateLogGroupTable(completion: (() -> Void)? = nil) {
        self.logGroupTable.beginUpdates()
        self.logGroupTable.endUpdates()
        if let completion = completion {
            completion()
        }
    }
    
    private func pickerContainerTransition(_ collectionViewHeightVal: Int) {
        var dynamicHeightVal = CGFloat(collectionViewHeightVal)
        if CGFloat(collectionViewHeightVal + 220) > (UIScreen.main.bounds.height * 0.84) {
            dynamicHeightVal = UIScreen.main.bounds.height * 0.5
        }
        pickerCollection.reloadData()
        UIView.animate(withDuration: 0.5) {
            self.pickerCollectionHeight.constant = dynamicHeightVal
            self.pickerContainerHeight.constant = dynamicHeightVal + 220
            self.view.layoutIfNeeded()
        }
    }
    
    private func getGroupOfLogsTotalCnt(_ groupOfLogSet: CustomModel.GroupOfLogSet) -> Int {
        self.groupOfLogSet = groupOfLogSet
        var total = 0
        if let foodLogs = groupOfLogSet.food_logs {
            total += (foodLogs.count)
        }
        if let actLogs = groupOfLogSet.act_logs {
            total += (actLogs.count)
        }
        if let drugLogs = groupOfLogSet.drug_logs {
            total += (drugLogs.count)
        }
        return total
    }
    
    private func afterLoadGroupOfLogs(_ collectionViewHeightVal: Int) {
        let logGroup = selectedLogGroup!
        yearNumber = logGroup.year_number
        yearForWeekOfYear = logGroup.year_forweekofyear
        monthNumber = logGroup.month_number
        dayNumber = logGroup.day_number
        weekOfYear = logGroup.week_of_year
        dayOfYear = logGroup.day_of_year
        selectedDate = "\(logGroup.year_number)-\(logGroup.month_number)-\(logGroup.day_number)"
        pickerContainerTransition(collectionViewHeightVal)
        if blindView.isHidden {
            groupTypePicker.selectRow(LogGroupType.nighttime - (groupType!), inComponent: 0, animated: true)
            UIView.transition(with: blindView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.pickerDateLabel.text = self.lang.getLogGroupSection(logGroup.month_number, logGroup.day_number)
                self.pickerContainerView.isHidden = false
                self.diseaseContainer.isHidden = true
                self.blindView.isHidden = false
            })
        }
    }
    
    private func loadLogGroups() {
        let selectedDateArr = dateFormatter.string(from: calendarView.currentPage).components(separatedBy: "-")
        let service = Service(lang: lang)
        service.getLogGroups(yearNumber: Int(selectedDateArr[0])!, yearForWeekOfYear: yearForWeekOfYear!, monthNumber: Int(selectedDateArr[1])!, weekOfYear: selectedWeekOfYear, popoverAlert: { message in
            self.retryFunction = self.loadLogGroups
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadLogGroups()
        }) { (logGroups) in
            self.logGroups = logGroups
            self.logGroupSectTwoDimArr = service.convertLogGroupsIntoTwoDimLogGroupSectArr(logGroups)
            self.logGroupDictTwoDimArr = service.convertSortedLogGroupSectTwoDimArrIntoLogGroupDictTwoDimArr(self.logGroupSectTwoDimArr)
            self.calendarView.reloadData()
            self.logGroupTable.reloadData()
            
            if let section = self.selectedTableSection, let row = self.selectedTableRow {
                self.selectedLogGroup = self.logGroupSectTwoDimArr[section][row].logGroup
                self.updateLogGroupTable()
            }
            
            if self.isToggleBtnTapped && logGroups.count > 0 {
                self.isToggleBtnTapped = false
                self.updateLogGroupTable(completion: {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.logGroupTable.scrollToRow(at: indexPath, at: .top, animated: true)
                })
            }
            
            if self.isPullToRefresh && logGroups.count > 0 {
                DispatchQueue.main.async {
                    self.refreshControler.endRefreshing()
                }
                self.isPullToRefresh = false
                self.updateLogGroupTable()
            }
            
            if self.isLogGroupTableEdited {
                self.isLogGroupTableEdited = false
                self.updateLogGroupTable(completion: {
                    self.editedCellIdxPath = nil
                })
            }
            
            if self.isFirstAppear {
                self.isFirstAppear = false
                if self.diaryMode == DiaryMode.logger {
                    self.popoverLogger(self.calendarView.today!)
                }
            }
            
            if self.diaryMode == DiaryMode.editor {
                UIView.animate(withDuration: 0.5) {
                    if logGroups.count <= 0 {
                        self.pullToRefreshLabel.isHidden = false
                        self.guideLabel.isHidden = false
                        self.foodBtn.isHidden = false
                        self.pillBtn.isHidden = false
                        self.activityBtn.isHidden = false
                        self.diseaseBtn.isHidden = false
                        self.guideIllustImgView.isHidden = false
                    } else {
                        self.pullToRefreshLabel.isHidden = true
                        self.guideLabel.isHidden = true
                        self.foodBtn.isHidden = true
                        self.pillBtn.isHidden = true
                        self.activityBtn.isHidden = true
                        self.diseaseBtn.isHidden = true
                        self.guideIllustImgView.isHidden = true
                    }
                }
            }
        }
    }
    
    private func popoverLogger(_ date: Date) {
        let selectedDateArr = dateFormatter.string(from: date).components(separatedBy: "-")
        yearNumber = Int(selectedDateArr[0])
        monthNumber = Int(selectedDateArr[1])
        dayNumber = Int(selectedDateArr[2])
        weekOfYear = Calendar.current.component(.weekOfYear, from: date)
        dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date)!
        selectedDate = dateFormatter.string(from: date)
        // logGrouDictArr: [groupType:LogGroup]
        if let logGroupDictArr = logGroupDictTwoDimArr[dayOfYear!] {
            // Case found some logGroups in section.
            // Display last log group.
            let sortedGroupTypes = logGroupDictArr.keys.sorted(by: >)
            var sortedLogGourpArr = [BaseModel.LogGroup]()
            sortedGroupTypes.forEach { (key) in
                sortedLogGourpArr.append(logGroupDictArr[key]!)
            }
            let logGroup = sortedLogGourpArr.first!
            selectedLogGroupId = logGroup.id
            selectedLogGroup = logGroup
            groupType = logGroup.group_type
            loadGroupOfLogs { (groupOfLogSet) in
                let collectionViewHeight = logCollectionCellHeightInt * self.getGroupOfLogsTotalCnt(groupOfLogSet)
                self.afterLoadGroupOfLogs(collectionViewHeight)
            }
        } else {
            // Case no logGroups are found in the section
            selectedLogGroup = nil
            selectedLogGroupId = nil
            groupOfLogSet = nil
            tempStoredLogs.removeAll()
            groupType = LogGroupType.morning
            pickerContainerTransition(pickerCollectionHeightInt)
        }
        groupTypePicker.selectRow(LogGroupType.nighttime - groupType!, inComponent: 0, animated: true)
        UIView.transition(with: self.pickerContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.pickerDateLabel.text = "\(self.monthNumber!)월 \(self.dayNumber!)일"
            self.blindView.isHidden = false
            self.pickerContainerView.isHidden = false
        })
    }
    
    private func loadGroupOfLogs(_ completion: @escaping (CustomModel.GroupOfLogSet) -> Void) {
        let service = Service(lang: lang)
        service.getGroupOfLogs(logGroupId: self.selectedLogGroupId!, popoverAlert: { (message) in
            self.retryFunctionName = "loadGroupOfLogs"
            self.retryCompletion = completion
            self.pickerContainerView.isHidden = true
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadGroupOfLogs(completion)
        }) { (groupOfLogSet) in
            self.groupOfLogSet = groupOfLogSet
            completion(groupOfLogSet)
        }
    }
    
    private func loadAvatarDiseasHistory() {
        let service = Service(lang: lang)
        service.getAvatarCondList(popoverAlert: { (message) in
            self.retryFunction = self.loadAvatarDiseasHistory
            self.pickerContainerView.isHidden = true
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadAvatarDiseasHistory()
        }) { (avtCondList) in
            self.avtCondList = avtCondList
            self.diseaseCollection.reloadData()
            self.diseaseLeftBtn.setTitleColor(.purple_B847FF, for: .normal)
            
            var collectionViewHeight = CGFloat(45 * self.avtCondList!.count)
            if CGFloat(collectionViewHeight + 105) > (UIScreen.main.bounds.height * 0.84) {
                collectionViewHeight = UIScreen.main.bounds.height * 0.5
            }
            UIView.transition(with: self.diseaseLeftBtn, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.diseaseLeftBtn.isHidden = false
                self.condCollectionHeight.constant = collectionViewHeight
                self.condContainerHeight.constant = collectionViewHeight + 105
            })
            UIView.transition(with: self.blindView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.pickerContainerView.isHidden = true
                self.diseaseContainer.isHidden = false
                self.blindView.isHidden = false
            })
        }
    }
    
    private func createGroupOfALog() {
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        var params = Parameters()
        params = [
            "avatar_id": avatarId,
            "tag_id": selectedTag!.id,
            "year_number": yearNumber!,
            "year_forweekofyear": yearForWeekOfYear!,
            "month_number": monthNumber!,
            "week_of_year": weekOfYear!,
            "day_of_year": dayOfYear!,
            "group_type": groupType!,
            "log_date": selectedDate!,
            "x_val": xVal!,
            "y_val": yVal!,
        ]
        if let logGroupId = selectedLogGroupId {
            params["log_group_id"] = logGroupId
        }
        let service = Service(lang: lang)
        service.postASingleLog(params: params, popoverAlert: { (message) in
            self.retryFunction = self.createGroupOfALog
            self.pickerContainerView.isHidden = true
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.createGroupOfALog()
        }) {
            UIView.transition(with: self.pickerContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.pickerContainerView.isHidden = true
                self.view.hideSpinner()
            }, completion: { (_) in
                switch self.lang.currentLanguageId {
                case LanguageId.eng: self.alertCompl(self.selectedTag!.eng_name, self.lang.msgLogComplete)
                case LanguageId.kor: self.alertCompl(self.selectedTag!.kor_name!, self.lang.msgLogComplete)
                case LanguageId.jpn: self.alertCompl(self.selectedTag!.jpn_name!, self.lang.msgLogComplete)
                default: fatalError()}
            })
        }
    }
    
    private func updateLogGroupCondScore() {
        let params: Parameters = [
            "cond_score": selectedMoodScore
        ]
        let service = Service(lang: lang)
        service.putLogGroup(logGroupId: selectedLogGroupId!, option: LogGroupOption.score, params: params, popoverAlert: { (message) in
            self.retryFunction = self.updateLogGroupCondScore
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.updateLogGroupCondScore()
        }) {
            self.loadLogGroups()
        }
    }
    
    private func updateLogGroupNote() {
        let params: Parameters = [
            "note_txt": newNote!
        ]
        let service = Service(lang: lang)
        service.putLogGroup(logGroupId: selectedLogGroupId!, option: LogGroupOption.note, params: params, popoverAlert: { (message) in
            self.retryFunction = self.updateLogGroupNote
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.updateLogGroupNote()
        }) {
            self.loadLogGroups()
        }
    }
    
    private func updateLogGroupRemove() {
        var _logGroupId = 0
        if diaryMode == DiaryMode.logger {
            _logGroupId = self.logGroupSectTwoDimArr[editedCellIdxPath!.section][editedCellIdxPath!.row - 1].logGroup.id
        } else {
            _logGroupId = self.logGroupSectTwoDimArr[editedCellIdxPath!.section][editedCellIdxPath!.row].logGroup.id
        }
        let service = Service(lang: lang)
        service.putLogGroup(logGroupId: _logGroupId, option: LogGroupOption.remove, params: nil, popoverAlert: { (message) in
            self.retryFunction = self.updateLogGroupRemove
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.updateLogGroupRemove()
        }) {
            self.isLogGroupTableEdited = true
            self.loadLogGroups()
        }
    }
    
    private func updateAvatarCondRemove() {
        let service = Service(lang: lang)
        service.putAvatarCond(avatarCondId: self.selectedAvatarDiseaseId!, popoverAlert: { (message) in
            self.retryFunction = self.updateAvatarCondRemove
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.updateAvatarCondRemove()
        }) {
            self.loadAvatarDiseasHistory()
        }
    }
    
    private func loadAvgCondScore() {
        if calendarView.scope == .week {
            weekOfYear = Calendar.current.component(.weekOfYear, from: calendarView.currentPage)
        } else {
            weekOfYear = nil
        }
        let selectedDateArr = dateFormatter.string(from: calendarView.currentPage).components(separatedBy: "-")
        yearNumber = Int(selectedDateArr[0])!
        monthNumber = Int(selectedDateArr[1])!
        let service = Service(lang: lang)
        service.getAvgCondScore(yearNumber: yearNumber!, yearForWeekOfYear: yearForWeekOfYear!, monthNumber: monthNumber, weekOfYear: weekOfYear, popoverAlert: { (message) in
            self.retryFunction = self.loadAvgCondScore
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadAvgCondScore()
        }) { (avgScoreSet) in
            let formatter = NumberFormatter()
            self.thisAvgScore = formatter.number(from: avgScoreSet.this_avg_score)!.floatValue
            self.lastAvgScore = formatter.number(from: avgScoreSet.last_avg_score!)!.floatValue
            self.alertAvgCondScore()
        }
    }
}
