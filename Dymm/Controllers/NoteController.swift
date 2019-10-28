//
//  NoteController.swift
//  Dymm
//
//  Created by Eido Goya on 03/09/2019.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit
import Alamofire

private let noteTableCellId = "noteTableCell"

class NoteController: UIViewController {
    
    // MARK: - Properties
    
    // UITableView
    var noteTableView: UITableView!
    
    // UIButton
    var closeButton: UIButton!
    
    // Non-view properties
    var lang: LangPack!
    var retryFunction: (() -> Void)?
    var logGroups: [BaseModel.LogGroup]?
    var selectedLogGroup: BaseModel.LogGroup?
    var newNote: String?
    var lastContentOffset: CGFloat = 0.0
    var isScrollToLoading: Bool = false
    var currPageNum: Int = 1
    var minimumCnt: Int = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        loadLogGroupNotes()
    }
    
    // MARK: - Actions
    
    @objc func alertError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: lang.titleYes, style: .default) { _ in
            self.retryFunction!()
        })
        alert.addAction(UIAlertAction(title: lang.titleNo, style: .cancel) { _ in })
        alert.view.tintColor = .mediumSeaGreen
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
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
            _textView.backgroundColor = .hex_fffede
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
                self.currPageNum = 1
                self.minimumCnt = 20
                self.lastContentOffset = 0.0
                self.isScrollToLoading = false
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
        alert.view.tintColor = .mediumSeaGreen
        self.present(alert, animated: true, completion: nil)
    }
}

extension NoteController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfRows = logGroups?.count else {
            return 0
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: noteTableCellId, for: indexPath) as? NoteTableCell else {
            fatalError()
        }
        let logGroup = logGroups![indexPath.row]
        cell.titleLabel.text = logGroup.note
        var subTitle = ""
        switch lang.currentLanguageId {
        case LanguageId.eng:
            subTitle = "\(lang.getLogGroupTypeName(logGroup.group_type)) \(LangHelper.getEngNameOfMM(monthNumber: logGroup.month_number))/\(logGroup.day_number)/\(logGroup.year_number)"
        case LanguageId.kor:
            subTitle = "\(lang.getLogGroupTypeName(logGroup.group_type)) \(LangHelper.getKorNameOfMonth(monthNumber: logGroup.month_number, engMMM: nil))/\(logGroup.day_number)/\(logGroup.year_number)"
        case LanguageId.jpn:
            // TODO
            print("")
        default: fatalError() }
        cell.subTitleLabel.text = subTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        currPageNum = 1
        minimumCnt = 20
        lastContentOffset = 0.0
        isScrollToLoading = false
        selectedLogGroup = logGroups![indexPath.row]
        newNote = ""
        updateLogGroupNote()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLogGroup = logGroups![indexPath.row]
        alertNoteTextView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let _logGroups = logGroups else {
            return
        }
        
        if lastContentOffset > scrollView.contentOffset.y {
            // Case scolled up
            return
        }
        if scrollView.contentSize.height < 0 {
            // Case view did initialized
            return
        } else {
            lastContentOffset = scrollView.contentOffset.y
        }
        if (scrollView.frame.size.height + scrollView.contentOffset.y) > (scrollView.contentSize.height - 200) {
            if _logGroups.count == minimumCnt {
                isScrollToLoading = true
                currPageNum += 1
                minimumCnt += 20
                loadLogGroupNotes()
            }
        }
    }
}

extension NoteController {
    
    // MARK: - Private methods
    
    private func setupLayout() {
        // Initialize super view
        lang = LangPack(UserDefaults.standard.getCurrentLanguageId()!)
        navigationItem.title = lang.titleNotes
        view.backgroundColor = UIColor.whiteSmoke
        
        // Initialize subveiw properties
        closeButton = getCloseButton()
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        noteTableView = {
            let _tableView = UITableView(frame: CGRect.zero, style: .plain)
            _tableView.backgroundColor = .hex_fffede
            _tableView.separatorStyle = .singleLine
            _tableView.register(NoteTableCell.self, forCellReuseIdentifier: noteTableCellId)
            _tableView.translatesAutoresizingMaskIntoConstraints = false
            return _tableView
        }()
        
        noteTableView.dataSource = self
        noteTableView.delegate = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        view.addSubview(noteTableView)
        
        // Setup subveiw constraints
        noteTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        noteTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        noteTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        noteTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    private func loadLogGroupNotes() {
        let service = Service(lang: lang)
        service.getLogGroupNotes(page: currPageNum, popoverAlert: { (message) in
            self.retryFunction = self.loadLogGroupNotes
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.loadLogGroupNotes()
        }) { (logGroups) in
            if self.isScrollToLoading {
                self.isScrollToLoading = false
                if logGroups.count > 0 {
                    self.logGroups!.append(contentsOf: logGroups)
                }
                self.noteTableView.reloadData()
                return
            } else {
                self.logGroups = logGroups
                UIView.animate(withDuration: 0.5, animations: {
                    self.noteTableView.reloadData()
                })
            }
        }
    }
    
    private func updateLogGroupNote() {
        let params: Parameters = [
            "note_txt": newNote!
        ]
        let service = Service(lang: lang)
        service.putLogGroup(logGroupId: selectedLogGroup!.id, option: LogGroupOption.note, params: params, popoverAlert: { (message) in
            self.retryFunction = self.updateLogGroupNote
            self.alertError(message)
        }, tokenRefreshCompletion: {
            self.updateLogGroupNote()
        }) {
            self.loadLogGroupNotes()
        }
    }
}
