//
//  Patterns.swift
//  Flava
//
//  Created by eunsang lee on 23/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import Foundation
import UIKit

struct URI {
    static let host: String = "http://127.0.0.1:5000"
    //    static let apiServerHost: String = "https://flava-api-test4.herokuapp.com"
    static let avatar = "/api/avatar"
    static let diary = "/api/diary"
    static let mail = "/api/mail"
    static let tag = "/api/tag"
    static let log = "/api/log"
    static let banner = "/api/banner"
    static let profile = "/api/profile"
}

struct ForbiddenType {
    static let tokenInvalid = 11
    static let tokenExpr = 12
    static let tokenNeedFresh = 13
}

struct UnauthType {
    static let mailNeedConf = 21
    static let mailDuplicated = 22
    
    static let userInvalid = 31
    static let mailInvalid = 32
    static let passwordInvalid = 33
}

struct TagType {
    static let activity = 7
    static let condition = 8
    static let drug = 9
    static let food = 10
    static let character = 11
    static let category = 12
    static let bookmark = 13
    static let diary = 14
    static let history = 15
}

struct LanguageId {
    static let eng = 30
    static let kor = 35
    static let jpn = 34
}

struct SortType {
    static let priority = "priority"
    static let eng = "eng"
    static let kor = "kor"
    static let jpn = "jpn"
}

struct CalScope {
    static let week = 1
    static let month = 2
}

struct LogType {
    static let food = 1
    static let drug = 1
    static let act = 1
    static let condScore = 1
}

struct CondLogType {
    static let startDate = 1
    static let endDate = 2
}

struct LogGroupType {
    static let morning = 1
    static let daytime = 2
    static let evening = 3
    static let nighttime = 4
}

struct TagId {
    static let diary = 17
    static let bookmarks = 18
}

struct DiaryMode {
    static let logger = 1
    static let editor = 2
}

struct ButtonType {
    static let home = 1
    static let close = 2
}

struct AvatarInfoTarget {
    static let firstName = 11
    static let lastName = 12
    static let email = 13
    static let phNumber = 14
    static let intro = 15
    static let profile_type = 16
}

func getLogGroupTypeImage(_ groupType: Int) -> UIImage? {
    switch groupType {
    case LogGroupType.morning: return UIImage(named: "item-gt-sunrise")
    case LogGroupType.daytime: return UIImage(named: "item-gt-sun")
    case LogGroupType.evening: return UIImage(named: "item-gt-sunset")
    case LogGroupType.nighttime: return UIImage(named: "item-gt-moon")
    default: return nil
    }
}

func getCondScoreImage(_ condScore: Int) -> UIImage? {
    if condScore < 4 {
        return UIImage(named: "item-score-bad")
    } else if condScore < 7 {
        return UIImage(named: "item-score-soso")
    } else if condScore < 9 {
        return UIImage(named: "item-score-good")
    } else {
        return UIImage(named: "item-score-awesome")
    }
}

func getLanguageId(alpha2: String) -> Int {
    switch alpha2 {
    case "en": return LanguageId.eng
    case "kr": return LanguageId.kor
    case "jp": return LanguageId.jpn
    default: return LanguageId.eng
    }
}

struct CountryId {
    static let australia = 358
    static let canada = 236
    static let ireland = 316
    static let japan = 263
    static let newZealand = 368
    static let southKorea = 265
    static let unitedKingdom = 322
    static let unitedStates = 240
}

func getProfileUIColor(key: Int) -> UIColor {
    switch key {
    case 1: return UIColor.dodgerBlue
    case 2: return UIColor.indianRed
    case 3: return UIColor.coral
    case 4: return UIColor.tomato
    case 5: return UIColor.yellowGreen
    case 6: return UIColor.darkTurquoise
    case 7: return UIColor.cadetBlue
    case 8: return UIColor.rosyBrown
    case 9: return UIColor.darkGray
    case 10: return UIColor.hex_666699
    case 11: return UIColor.hex_6699cc
    case 12: return UIColor.hex_99cc99
    case 13: return UIColor.hex_9999ff
    case 14: return UIColor.hex_cccc66
    // TODO: case 999 -> Photo
    default: fatalError("Wrong ProfileColor key has been passed")}
}

func getEngNameOfMonth(monthNumber: Int) -> String {
    switch monthNumber {
    case 1: return "January"
    case 2: return "February"
    case 3: return "March"
    case 4: return "April"
    case 5: return "May"
    case 6: return "June"
    case 7: return "July"
    case 8: return "August"
    case 9: return "September"
    case 10: return "October"
    case 11: return "November"
    case 12: return "December"
    default: fatalError("Wrong MonthNumber has been passed")}
}
