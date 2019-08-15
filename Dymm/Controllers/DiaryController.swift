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

private let logGroupCellHeightVal = 52
private let logTableCellHeightVal = 45
private let pickerCollectionHeightVal = 32
private let logCollectionCellHeightVal = 30

private let marginVal = 7

class DiaryViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    var blindView: UIView!
    var pickerContainerView: UIView!
    var pickerGrayLineView: UIView!
    var condContainerView: UIView!
    
    var calendarView: FSCalendar!
    var logGroupTableView: UITableView!
    var condCollectionView: UICollectionView!
    var pickerCollectionView: UICollectionView!
    var groupTypePickerView: UIPickerView!
    
    var loadingImageView: UIImageView!
    var pickerDateLabel: UILabel!
    var condTitleLabel: UILabel!
    
    var toggleButton: UIButton!
    var pickerCancelButton: UIButton!
    var pickerCheckButton: UIButton!
    var homeButton: UIButton!
    var condButton: UIButton!
    var condLeftButton: UIButton!
    var condRightButton: UIButton!
    
    var calendarViewHeight: NSLayoutConstraint!
    var pickerContainerHeight: NSLayoutConstraint!
    var pickerCollectionHeight: NSLayoutConstraint!
    var condContainerHeight: NSLayoutConstraint!
    var condCollectionHeight: NSLayoutConstraint!
    
    var scopeGesture: UIPanGestureRecognizer!
    var dateFormatter: DateFormatter!
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    var retryFunctionName: String?
    var retryCompletion: ((CustomModel.GroupOfLogSet) -> Void)?
    
    var diaryMode: Int = DiaryMode.editor
    
    // [dayOfyear:[groupType:IntakeLogGroup]]
    var logGroupDictTwoDimArr = [Int:[Int:BaseModel.LogGroup]]()
    var logGroupSectTwoDimArr = [[CustomModel.LogGroupSection]]()
    var logGroups: [BaseModel.LogGroup]? // For event marking
    var avtCondList: [BaseModel.AvatarCond]?
    var selectedLogGroup: BaseModel.LogGroup?
    var groupOfLogSet: CustomModel.GroupOfLogSet?
    
    var selectedLogGroupId: Int?
    var selectedCalScope: Int?
    var selectedWeekOfYear: Int?
    var selectedTag: BaseModel.Tag?
    var selectedDate: String?
    var selectedOnceCellIdxPath: IndexPath?
    var yearNumber: Int?
    var monthNumber: Int?
    var dayNumber: Int?
    var groupType: Int?
    var weekOfYear: Int?
    var dayOfYear: Int?
    var logType: Int?
    var x_val: Int?
    var y_val: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadLogGroups()
    }
    
    // MARK: - Actions
    
    @objc func alertError(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.btnDone, style: .default) { _ in
            if self.retryFunctionName == "loadGroupOfLogs" {
                self.loadGroupOfLogs(self.retryCompletion!)
                return
            }
            self.retryFunction!()
        }
        let cancelAction = UIAlertAction(title: lang.btnCancel, style: .cancel) { _ in }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func alertCompl(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: lang.btnYes, style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: lang.btnNo, style: .cancel) { _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        alertController.view.tintColor = UIColor.tomato
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func toggleButtonTapped() {
        if calendarView.scope == .month {
            calendarView.setScope(.week, animated: true)
            toggleButton.setImage(UIImage(named: "button-maximize")!.withRenderingMode(.alwaysOriginal), for: .normal)
            selectedCalScope = CalScope.week
            selectedWeekOfYear = Calendar.current.component(.weekOfYear, from: calendarView.currentPage)
            loadLogGroups()
        } else {
            calendarView.setScope(.month, animated: true)
            toggleButton.setImage(UIImage(named: "button-minimize")!.withRenderingMode(.alwaysOriginal), for: .normal)
            selectedCalScope = CalScope.month
            selectedWeekOfYear = nil
            loadLogGroups()
        }
    }
    
    @objc func pickerCancelButtonTapped() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            UIView.transition(with: self.blindView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.blindView.isHidden = true
            })
        })
    }
    
    @objc func pickerCheckButtonTapped() {
        UIView.transition(with: pickerContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.pickerContainerView.isHidden = true
            self.loadingImageView.isHidden = false
        })
        postAGroupOfLog()
    }
    
    @objc func condRightButtonTapped() {
        print("")
    }
    
    @objc func condLeftButtonTapped() {
        UIView.transition(with: self.blindView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.blindView.isHidden = true
            self.condLeftButton.setTitleColor(UIColor.clear, for: .normal)
        }, completion: { (_) in
            self.condLeftButton.isHidden = true
        })
    }
    
    @objc func homeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func condButtonTapped() {
        loadAvatarCondList()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    // MARK: - CalendarViewDataSource
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarViewHeight.constant = bounds.height
        view.layoutIfNeeded()
    }
    
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
        if diaryMode == DiaryMode.editor {
            return
        }
        let selectedDateArr = dateFormatter.string(from: date).components(separatedBy: "-")
        yearNumber = Int(selectedDateArr[0])
        monthNumber = Int(selectedDateArr[1])
        dayNumber = Int(selectedDateArr[2])
        weekOfYear = Calendar.current.component(.weekOfYear, from: date)
        dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date)!
        selectedDate = dateFormatter.string(from: date)
        if let logGroupDictArr = logGroupDictTwoDimArr[dayOfYear!] {
            // logGrouDictArr: [groupType:LogGroup]
            // Case selected calendar date has some of logGroups,
            // display last log group.
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
                let collectionViewHeight = logCollectionCellHeightVal * self.getGroupOfLogsTotalCnt(groupOfLogSet)
                self.afterLoadGroupOfLogs(collectionViewHeight)
            }
        } else {
            // Case any log group not existed in selected date section
            groupOfLogSet = nil
            groupType = LogGroupType.morning
            pickerContainerTransition(pickerCollectionHeightVal)
        }
        groupTypePickerView.selectRow(LogGroupType.nighttime - groupType!, inComponent: 0, animated: true)
        UIView.transition(with: self.pickerContainerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.pickerDateLabel.text = "\(self.monthNumber!)월 \(self.dayNumber!)일"
            self.blindView.isHidden = false
            self.pickerContainerView.isHidden = false
        })
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let weekOfYear = Calendar.current.component(.weekOfYear, from: calendar.currentPage)
        if calendar.scope == .week {
            selectedCalScope = CalScope.week
            selectedWeekOfYear = weekOfYear
            loadLogGroups()
        } else {
            selectedCalScope = CalScope.month
            selectedWeekOfYear = nil
            loadLogGroups()
        }
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
        if diaryMode == DiaryMode.editor {
            return rowCnt
        }
        return rowCnt + 1  // Add +1 for 'Create new group' button
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if logGroupSectTwoDimArr.count <= 0 {
            return nil
        } else {
            let logGroup = logGroupSectTwoDimArr[section][0].logGroup
            let label = UILabel()
            let strDate = "\(logGroup.year_number)-\(logGroup.month_number)-\(logGroup.day_number)"
            let date = dateFormatter.date(from: strDate)
            var weekday = lang.getWeekdayName(Calendar.current.component(.weekday, from: date!))
            
            // Case current section date is calendar today
            let strTodayDateArr = dateFormatter.string(from: calendarView.today!).components(separatedBy: "-")
            let _monthNumber = Int(strTodayDateArr[1])
            let _dayNumber = Int(strTodayDateArr[2])
            if _monthNumber == logGroup.month_number && _dayNumber == logGroup.day_number {
                weekday = lang.labelToday
            }
            
            label.text = "\(weekday), \(lang.calendarSection(logGroup.month_number, logGroup.day_number))"
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
        if diaryMode == DiaryMode.editor {
            let logGroup = logGroupSectTwoDimArr[indexPath.section][indexPath.row].logGroup
            let intakeGroupTitle = lang.getLogGroupTypeName(logGroup.group_type)
            cell.arrowImageView.isHidden = false
            cell.nameLabel.text = intakeGroupTitle
            cell.groupTypeImageView.image = getLogGroupTypeImage(logGroup.group_type)
            cell.nameLabel.textColor = UIColor.black
            if logGroup.has_food {
                cell.foodLogBulletView.isHidden = false
            }
            if logGroup.has_act {
                cell.actLogBulletView.isHidden = false
            }
            if logGroup.has_drug {
                cell.drugLogBulletView.isHidden = false
            }
            return cell
        }
        if indexPath.row == 0 {
            cell.nameLabel.text = lang.labelCreateNewGroup
            cell.nameLabel.textColor = UIColor.tomato
            return cell
        } else {
            let logGroup = logGroupSectTwoDimArr[indexPath.section][indexPath.row - 1].logGroup
            let intakeGroupTitle = lang.getLogGroupTypeName(logGroup.group_type)
            cell.nameLabel.text = intakeGroupTitle
            cell.groupTypeImageView.image = getLogGroupTypeImage(logGroup.group_type)
            cell.nameLabel.textColor = UIColor.tomato
            if logGroup.has_food {
                cell.foodLogBulletView.isHidden = false
            }
            if logGroup.has_act {
                cell.actLogBulletView.isHidden = false
            }
            if logGroup.has_drug {
                cell.drugLogBulletView.isHidden = false
            }
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if diaryMode == DiaryMode.editor {
            selectedLogGroup = logGroupSectTwoDimArr[indexPath.section][indexPath.row].logGroup
            groupType = selectedLogGroup!.group_type
            selectedLogGroupId = selectedLogGroup!.id
            loadGroupOfLogs { (groupOfLogSet) in
                guard let cell = tableView.cellForRow(at: indexPath) as? LogGroupTableCell else {
                    fatalError()
                }
                cell.selectedLogGroup = self.selectedLogGroup!
                cell.groupOfLogSet = self.groupOfLogSet!
                cell.groupOfLogsTableView.reloadData()
                if indexPath == self.selectedOnceCellIdxPath {
                    // Case select already selected cell
                    self.selectedOnceCellIdxPath = nil
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.containerViewHight.constant = 45
                        cell.groupOfLogsTableView.isHidden = true
                        cell.arrowImageView.transform = CGAffineTransform.identity
                        self.view.layoutIfNeeded()
                    }, completion: { _ in
                        UIView.transition(with: cell.foodLogBulletView, duration: 0.1, options: .transitionCrossDissolve, animations: {
                            if self.selectedLogGroup!.has_food {
                                cell.foodLogBulletView.isHidden = false
                            }
                            if self.selectedLogGroup!.has_act {
                                cell.actLogBulletView.isHidden = false
                            }
                            if self.selectedLogGroup!.has_drug {
                                cell.drugLogBulletView.isHidden = false
                            }
                        })
                    })
                } else {
                    // Case select cell tapped at first time
                    self.selectedOnceCellIdxPath = indexPath
                    let total = self.getGroupOfLogsTotalCnt(groupOfLogSet)
                    UIView.animate(withDuration: 0.5, animations: {
                        cell.groupOfLogsTableHeight.constant = CGFloat((total * logTableCellHeightVal))
                        cell.containerViewHight.constant = CGFloat((total * logTableCellHeightVal) + logGroupCellHeightVal + marginVal)
                        cell.arrowImageView.transform = CGAffineTransform(rotationAngle: (.pi / 2))
                        self.view.layoutIfNeeded()
                    }, completion: { _ in
                        UIView.transition(with: cell.groupOfLogsTableView, duration: 0.1, options: .transitionCrossDissolve, animations: {
                            cell.groupOfLogsTableView.isHidden = false
                            cell.foodLogBulletView.isHidden = true
                            cell.actLogBulletView.isHidden = true
                            cell.drugLogBulletView.isHidden = true
                        })
                    })
                }
                self.logGroupTableView.beginUpdates()
                self.logGroupTableView.endUpdates()
            }
            return
        }
        if indexPath.row <= 0 {
            // User tapped 'Create new group' cell
            let lastLogGroup = logGroupSectTwoDimArr[indexPath.section].first!.logGroup
            selectedLogGroup = lastLogGroup
            if LogGroupType.nighttime > groupType! {
                // Case nighttime groupType has not been created yet,
                // Display next groupType of logGroup and set parameters.
                groupType = lastLogGroup.group_type + 1
                groupOfLogSet = nil
                selectedLogGroupId = nil
                afterLoadGroupOfLogs(pickerCollectionHeightVal)
            } else {
                // Case nighttime groupType already exist,
                // Display last existing logGroup and set parameters.
                selectedLogGroupId = lastLogGroup.id
                loadGroupOfLogs { (groupOfLogSet) in
                    let collectionViewHeight = logCollectionCellHeightVal * self.getGroupOfLogsTotalCnt(groupOfLogSet)
                    self.afterLoadGroupOfLogs(collectionViewHeight)
                }
            }
        } else {
            // User tapped already existed logGroup table cell
            selectedLogGroup = logGroupSectTwoDimArr[indexPath.section][indexPath.row - 1].logGroup
            groupType = selectedLogGroup!.group_type
            selectedLogGroupId = selectedLogGroup!.id
            loadGroupOfLogs { (groupOfLogSet) in
                let collectionViewHeight = logCollectionCellHeightVal * self.getGroupOfLogsTotalCnt(groupOfLogSet)
                self.afterLoadGroupOfLogs(collectionViewHeight)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
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
            return CGFloat((total * logTableCellHeightVal) + logGroupCellHeightVal + marginVal + 7)
        } else {
            if let cell = tableView.cellForRow(at: indexPath) as? LogGroupTableCell {
                cell.containerViewHight.constant = CGFloat(logGroupCellHeightVal - 7)
                cell.arrowImageView.transform = CGAffineTransform.identity
                cell.groupOfLogsTableView.isHidden = true
                let logGroup = logGroupSectTwoDimArr[indexPath.section][indexPath.row].logGroup
                if logGroup.has_food {
                    cell.foodLogBulletView.isHidden = false
                }
                if logGroup.has_act {
                    cell.actLogBulletView.isHidden = false
                }
                if logGroup.has_drug {
                    cell.drugLogBulletView.isHidden = false
                }
            }
            return CGFloat(logGroupCellHeightVal)
        }
    }
}

extension DiaryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == pickerCollectionView {
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
        } else if collectionView == condCollectionView {
            return avtCondList?.count ?? 0
        } else {
            fatalError()
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == condCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: condCollectionCellId, for: indexPath) as? CondCollectionCell else {
                fatalError()
            }
            let avtCond = avtCondList![indexPath.item]
            switch lang.currentLanguageId {
            case LanguageId.eng: cell.titleLabel.text = avtCond.eng_name
            case LanguageId.kor: cell.titleLabel.text = avtCond.kor_name
            case LanguageId.jpn: cell.titleLabel.text = avtCond.jpn_name
            default: fatalError()}
            if let start_date = avtCond.start_date {
                cell.startDateLabel.text = "\u{021E2}\(start_date)"
            }
            if let end_date = avtCond.end_date {
                cell.endDateLabel.text = "\u{2713}\(end_date)"
            }
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: logCollectionCellId, for: indexPath) as? LogCollectionCell else {
            fatalError()
        }
        if ((groupOfLogSet!.food_logs?.count) != nil && ((groupOfLogSet!.food_logs?.count)!) > 0) {
            let foodLog = groupOfLogSet!.food_logs!.popLast()
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
            cell.bulletView.backgroundColor = UIColor.yellowGreen
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
            cell.bulletView.backgroundColor = UIColor.dodgerBlue
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
    }
    
    // MARK: - UICollectionView DelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        if collectionView == condCollectionView {
            return CGSize(width: screenWidth - (screenWidth / 7), height: CGFloat(45))
        }
        return CGSize(width: screenWidth - (screenWidth / 5), height: CGFloat(30))
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
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 60))
        let imageView = UIImageView(frame: CGRect(x: pickerView.bounds.midX - 80, y: 15, width: 33, height: 33))
        let label = UILabel(frame: CGRect(x: pickerView.bounds.midX - 15, y: 0, width: pickerView.bounds.width - 50, height: 60))
        imageView.image = getLogGroupTypeImage(4 - row)
        label.text = lang.getLogGroupTypeName(4 - row)
        containerView.addSubview(imageView)
        containerView.addSubview(label)
        return containerView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        groupType = LogGroupType.nighttime - row
        if let logGroupDict = logGroupDictTwoDimArr[dayOfYear!] {
            if let logGroup = logGroupDict[groupType!] {
                // Case pick existing logGroup
                selectedLogGroupId = logGroup.id
                selectedLogGroup = logGroup
                loadGroupOfLogs { (groupOfLogSet) in
                    let collectionViewHeight = logCollectionCellHeightVal * self.getGroupOfLogsTotalCnt(groupOfLogSet)
                    self.afterLoadGroupOfLogs(collectionViewHeight)
                }
            } else {
                // Case there is any groupOfLogs in picked logGroup.
                groupOfLogSet = nil
                selectedLogGroupId = nil
                selectedLogGroup = nil
                pickerContainerTransition(pickerCollectionHeightVal)
            }
        } else {
            // Case there is any logGroup in section(date).
            groupOfLogSet = nil
            selectedLogGroupId = nil
            selectedLogGroup = nil
            pickerContainerTransition(pickerCollectionHeightVal)
        }
    }
}

extension DiaryViewController {
    
    // MARK: Private methods

    private func setupLayout() {
        // Initialize view
        lang = getLanguagePack(UserDefaults.standard.getCurrentLanguageId()!)
        navigationItem.title = lang.titleDiary
        view.backgroundColor = UIColor(hex: "WhiteSmoke")
        
        // Initialize subveiw properties
        blindView = getAlertBlindView()
        loadingImageView = getLoadingImageView(isHidden: false)
        pickerGrayLineView = getGrayLineView()
        pickerContainerView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.layer.cornerRadius = 10.0
            _view.isHidden = true
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        condContainerView = {
            let _view = UIView()
            _view.backgroundColor = UIColor.white
            _view.layer.cornerRadius = 10.0
            _view.isHidden = true
            _view.translatesAutoresizingMaskIntoConstraints = false
            return _view
        }()
        calendarView = {
            let _calendar = FSCalendar()
            _calendar.appearance.headerTitleColor = UIColor.black
            _calendar.appearance.weekdayTextColor = UIColor.black
            _calendar.appearance.titleDefaultColor = UIColor.hex_fe4c4c
            _calendar.appearance.titlePlaceholderColor = UIColor.lightGray
            _calendar.appearance.eventDefaultColor = UIColor.tomato
            _calendar.appearance.eventSelectionColor = UIColor.hex_fe4c4c
            _calendar.appearance.selectionColor = UIColor.hex_fe4c4c
            _calendar.backgroundColor = UIColor.white
            _calendar.addShadowView()
            
            _calendar.clipsToBounds = true
            _calendar.appearance.headerDateFormat = lang.calendarHeaderDateFormat
            _calendar.appearance.caseOptions = FSCalendarCaseOptions.weekdayUsesUpperCase
            _calendar.select(Date())
            _calendar.scope = .week
            
            _calendar.translatesAutoresizingMaskIntoConstraints = false
            return _calendar
        }()
        dateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: getUserCountryCode())  // TODO ko_kr
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
        logGroupTableView = {
            let _tableView = UITableView(frame: CGRect.zero, style: .grouped)
            _tableView.backgroundColor = UIColor.clear
            _tableView.separatorStyle = .none
            _tableView.register(LogGroupTableCell.self, forCellReuseIdentifier: logGroupTableCellId)
            _tableView.translatesAutoresizingMaskIntoConstraints = false
            return _tableView
        }()
        pickerCollectionView = {
            let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
            _collectionView.backgroundColor = UIColor.clear
            _collectionView.register(LogCollectionCell.self, forCellWithReuseIdentifier: logCollectionCellId)
            _collectionView.translatesAutoresizingMaskIntoConstraints = false
            return _collectionView
        }()
        condCollectionView = {
            let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
            _collectionView.backgroundColor = UIColor.clear
            _collectionView.register(CondCollectionCell.self, forCellWithReuseIdentifier: condCollectionCellId)
            _collectionView.translatesAutoresizingMaskIntoConstraints = false
            return _collectionView
        }()
        groupTypePickerView = {
            let _pickerView = UIPickerView()
            _pickerView.translatesAutoresizingMaskIntoConstraints = false
            return _pickerView
        }()
        pickerDateLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 18, weight: .regular)
            _label.textColor = UIColor.black
            _label.textAlignment = .center
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        condTitleLabel = {
            let _label = UILabel()
            _label.font = .systemFont(ofSize: 18, weight: .regular)
            _label.textColor = UIColor.black
            _label.textAlignment = .left
            _label.text = lang.titleMyAvtCond
            _label.translatesAutoresizingMaskIntoConstraints = false
            return _label
        }()
        pickerCancelButton = getCancelButton()
        pickerCancelButton.addTarget(self, action: #selector(pickerCancelButtonTapped), for: .touchUpInside)
        pickerCheckButton = getCheckButton()
        pickerCheckButton.addTarget(self, action: #selector(pickerCheckButtonTapped), for: .touchUpInside)
        toggleButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage(named: "button-maximize")!.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(toggleButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        homeButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage(named: "button-home")!.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action:#selector(homeButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        condButton = {
            let _button = UIButton(type: .system)
            _button.setImage(UIImage(named: "button-heartbeat")!.withRenderingMode(.alwaysOriginal), for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 27, height: 25)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action:#selector(condButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        condLeftButton = {
            let _button = UIButton(type: .system)
            _button.setTitle(lang.btnClose, for: .normal)
            _button.setTitleColor(UIColor.clear, for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
            _button.showsTouchWhenHighlighted = true
            _button.isHidden = true
            _button.addTarget(self, action:#selector(condLeftButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        condRightButton = {
            let _button = UIButton(type: .system)
            _button.setTitle(lang.btnEdit, for: .normal)
            _button.frame = CGRect(x: 0, y: 0, width: 21, height: 21)
            _button.showsTouchWhenHighlighted = true
            _button.addTarget(self, action: #selector(condRightButtonTapped), for: .touchUpInside)
            _button.translatesAutoresizingMaskIntoConstraints = false
            return _button
        }()
        
        if diaryMode == DiaryMode.editor {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: homeButton)
            calendarView.appearance.titleDefaultColor = UIColor.black
        }
        
        calendarView.dataSource = self
        calendarView.delegate = self
        logGroupTableView.dataSource = self
        logGroupTableView.delegate = self
        pickerCollectionView.dataSource = self
        pickerCollectionView.delegate = self
        condCollectionView.dataSource = self
        condCollectionView.delegate = self
        groupTypePickerView.dataSource = self
        groupTypePickerView.delegate = self
        
        // Setup subviews
        view.addSubview(logGroupTableView)
        view.addSubview(calendarView)
        view.addSubview(condButton)
        view.addSubview(toggleButton)
        view.addSubview(loadingImageView)
        view.addSubview(blindView)
        view.addSubview(condLeftButton)
        view.addGestureRecognizer(scopeGesture)
        
        blindView.addSubview(pickerContainerView)
        blindView.addSubview(condContainerView)
        
        pickerContainerView.addSubview(pickerDateLabel)
        pickerContainerView.addSubview(groupTypePickerView)
        pickerContainerView.addSubview(pickerCollectionView)
        pickerContainerView.addSubview(pickerGrayLineView)
        pickerContainerView.addSubview(pickerCancelButton)
        pickerContainerView.addSubview(pickerCheckButton)
        
        condContainerView.addSubview(condTitleLabel)
        condContainerView.addSubview(condCollectionView)
        condContainerView.addSubview(condRightButton)
        
        // Setup constraints
        // loadingImageView, blindView
        loadingImageView.widthAnchor.constraint(equalToConstant: 62).isActive = true
        loadingImageView.heightAnchor.constraint(equalToConstant: 62).isActive = true
        loadingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        loadingImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        
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
        
        condContainerView.leadingAnchor.constraint(equalTo: blindView.leadingAnchor, constant: 7).isActive = true
        condContainerView.trailingAnchor.constraint(equalTo: blindView.trailingAnchor, constant: -7).isActive = true
        condContainerView.centerXAnchor.constraint(equalTo: blindView.centerXAnchor, constant: 0).isActive = true
        condContainerView.centerYAnchor.constraint(equalTo: blindView.centerYAnchor, constant: 0).isActive = true
        condContainerHeight = condContainerView.heightAnchor.constraint(equalToConstant: 105 + 45)
        condContainerHeight.priority = UILayoutPriority(rawValue: 999)
        condContainerHeight.isActive = true
        
        pickerDateLabel.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: 10).isActive = true
        pickerDateLabel.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: 20).isActive = true
        
        condTitleLabel.topAnchor.constraint(equalTo: condContainerView.topAnchor, constant: 10).isActive = true
        condTitleLabel.leadingAnchor.constraint(equalTo: condContainerView.leadingAnchor, constant: 20).isActive = true
        
        groupTypePickerView.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: 0).isActive = true
        groupTypePickerView.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: 0).isActive = true
        groupTypePickerView.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor, constant: 0).isActive = true
        groupTypePickerView.heightAnchor.constraint(equalToConstant: 215).isActive = true
        
        pickerCollectionView.topAnchor.constraint(equalTo: pickerContainerView.topAnchor, constant: 170).isActive = true
        pickerCollectionView.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: 0).isActive = true
        pickerCollectionView.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor, constant: 0).isActive = true
        pickerCollectionHeight = pickerCollectionView.heightAnchor.constraint(equalToConstant: 210)
        pickerCollectionHeight.priority = UILayoutPriority(rawValue: 999)
        pickerCollectionHeight.isActive = true
        
        condCollectionView.topAnchor.constraint(equalTo: condContainerView.topAnchor, constant: 45).isActive = true
        condCollectionView.leadingAnchor.constraint(equalTo: condContainerView.leadingAnchor, constant: 0).isActive = true
        condCollectionView.trailingAnchor.constraint(equalTo: condContainerView.trailingAnchor, constant: 0).isActive = true
        condCollectionHeight = condCollectionView.heightAnchor.constraint(equalToConstant: 45)
        condCollectionHeight.priority = UILayoutPriority(rawValue: 999)
        condCollectionHeight.isActive = true
        
        pickerGrayLineView.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: (view.frame.width / 13)).isActive = true
        pickerGrayLineView.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor, constant: -(view.frame.width / 13)).isActive = true
        pickerGrayLineView.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor, constant: -50).isActive = true
        pickerGrayLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        pickerCancelButton.leadingAnchor.constraint(equalTo: pickerContainerView.leadingAnchor, constant: (view.frame.width / 10)).isActive = true
        pickerCancelButton.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor, constant: -15).isActive = true
        
        pickerCheckButton.trailingAnchor.constraint(equalTo: pickerContainerView.trailingAnchor, constant: -(view.frame.width / 10)).isActive = true
        pickerCheckButton.bottomAnchor.constraint(equalTo: pickerContainerView.bottomAnchor, constant: -15).isActive = true
        
        condLeftButton.leadingAnchor.constraint(equalTo: condContainerView.leadingAnchor, constant: (view.frame.width / 10)).isActive = true
        condLeftButton.bottomAnchor.constraint(equalTo: condContainerView.bottomAnchor, constant: -15).isActive = true
        
        condRightButton.trailingAnchor.constraint(equalTo: condContainerView.trailingAnchor, constant: -(view.frame.width / 10)).isActive = true
        condRightButton.bottomAnchor.constraint(equalTo: condContainerView.bottomAnchor, constant: -15).isActive = true
        
        calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        calendarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        calendarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        calendarViewHeight = calendarView.heightAnchor.constraint(equalToConstant: 225)
        calendarViewHeight.priority = UILayoutPriority(rawValue: 999)
        calendarViewHeight.isActive = true
        
        condButton.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 8).isActive = true
        condButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        
        toggleButton.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 8).isActive = true
        toggleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        logGroupTableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 0).isActive = true
        logGroupTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 7).isActive = true
        logGroupTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -7).isActive = true
        logGroupTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        logGroupTableView.panGestureRecognizer.require(toFail: scopeGesture)
        
        selectedWeekOfYear = Calendar.current.component(.weekOfYear, from: calendarView.today!)
        selectedCalScope = CalScope.week
        groupType = LogGroupType.morning
    }
    
    private func pickerContainerTransition(_ collectionViewHeightVal: Int) {
        pickerCollectionView.reloadData()
        UIView.animate(withDuration: 0.5) {
            self.pickerCollectionHeight.constant = CGFloat(collectionViewHeightVal)
            self.pickerContainerHeight.constant = CGFloat(collectionViewHeightVal + 220)
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
        monthNumber = logGroup.month_number
        dayNumber = logGroup.day_number
        weekOfYear = logGroup.week_of_year
        dayOfYear = logGroup.day_of_year
        selectedDate = "\(logGroup.year_number)-\(logGroup.month_number)-\(logGroup.day_number)"
        pickerContainerTransition(collectionViewHeightVal)
        if blindView.isHidden {
            groupTypePickerView.selectRow(LogGroupType.nighttime - (groupType!), inComponent: 0, animated: true)
            UIView.transition(with: blindView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.pickerDateLabel.text = self.lang.calendarSection!(logGroup.month_number, logGroup.day_number)
                self.pickerContainerView.isHidden = false
                self.condContainerView.isHidden = true
                self.blindView.isHidden = false
            })
        }
    }
    
    private func loadLogGroups() {
        UIView.transition(with: logGroupTableView, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.blindView.isHidden = true
            self.logGroupTableView.isHidden = true
            self.loadingImageView.isHidden = false
        })
        let selectedDateArr = dateFormatter.string(from: calendarView.currentPage).components(separatedBy: "-")
        let yearNumber = selectedDateArr[0]
        let monthNumber = Int(selectedDateArr[1])!
        let service = Service(lang: lang)
        service.fetchLogGroups(yearNumber: yearNumber, monthNumber: monthNumber, weekOfYear: selectedWeekOfYear, popoverAlert: { message in
            self.retryFunction = self.loadLogGroups
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadLogGroups()
        }) { (logGroups) in
            self.logGroups = logGroups
            self.logGroupSectTwoDimArr = service.convertLogGroupsIntoTwoDimLogGroupSectArr(logGroups)
            self.logGroupDictTwoDimArr = service.convertSortedLogGroupSectTwoDimArrIntoLogGroupDictTwoDimArr(self.logGroupSectTwoDimArr)
            self.logGroupTableView.reloadData()
            self.calendarView.reloadData()
            UIView.transition(with: self.logGroupTableView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.logGroupTableView.isHidden = false
                self.loadingImageView.isHidden = true
            })
        }
    }
    
    private func loadGroupOfLogs(_ completion: @escaping (CustomModel.GroupOfLogSet) -> Void) {
        let service = Service(lang: lang)
        service.fetchGroupOfLogs(self.selectedLogGroupId!, popoverAlert: { (message) in
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
    
    private func loadAvatarCondList() {
        let service = Service(lang: lang)
        service.fetchAvatarCondList(popoverAlert: { (message) in
            self.retryFunction = self.loadAvatarCondList
            self.pickerContainerView.isHidden = true
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadAvatarCondList()
        }) { (avtCondList) in
            self.avtCondList = avtCondList
            self.condCollectionView.reloadData()
            self.condLeftButton.setTitleColor(UIColor.tomato, for: .normal)
            UIView.transition(with: self.condLeftButton, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.condLeftButton.isHidden = false
            })
            UIView.transition(with: self.blindView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.pickerContainerView.isHidden = true
                self.condContainerView.isHidden = false
                self.blindView.isHidden = false
            }, completion: { (_) in
                UIView.animate(withDuration: 0.5) {
                    self.condCollectionHeight.constant = CGFloat(45 * self.avtCondList!.count)
                    self.condContainerHeight.constant = CGFloat(45 * self.avtCondList!.count + 105)
                    self.view.layoutIfNeeded()
                }
            })
        }
    }
    
    private func postAGroupOfLog() {
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        var params = Parameters()
        params = [
            "avatar_id": avatarId,
            "tag_id": selectedTag!.id,
            "year_number": yearNumber!,
            "month_number": monthNumber!,
            "week_of_year": weekOfYear!,
            "day_of_year": dayOfYear!,
            "group_type": groupType!,
            "log_date": selectedDate!,
            "x_val": x_val!,
            "y_val": y_val!,
        ]
        if let logGroupId = selectedLogGroupId {
            params["log_group_id"] = logGroupId
        }
        let service = Service(lang: lang)
        service.dispatchASingleLog(params: params, popoverAlert: { (message) in
            self.retryFunction = self.postAGroupOfLog
            self.pickerContainerView.isHidden = true
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.postAGroupOfLog()
        }) {
            UIView.transition(with: self.loadingImageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.pickerContainerView.isHidden = true
                self.loadingImageView.isHidden = true
            }, completion: { (_) in
                switch self.lang.currentLanguageId {
                case LanguageId.eng: self.alertCompl(self.lang.msgIntakeLogComplete(self.selectedTag!.eng_name))
                case LanguageId.kor: self.alertCompl(self.lang.msgIntakeLogComplete(self.selectedTag!.kor_name!))
                case LanguageId.jpn: self.alertCompl(self.lang.msgIntakeLogComplete(self.selectedTag!.jpn_name!))
                default: fatalError()}
            })
        }
    }
}