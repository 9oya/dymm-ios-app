//
//  Patterns.swift
//  Flava
//
//  Created by eunsang lee on 23/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import Foundation
import UIKit

private let localHost = "http://127.0.0.1:5000"
private let productHost = "https://dymm-api-01.appspot.com"

struct URI {
//    static let host = localHost
    static let host = productHost
    static let avatar = "/api/avatar"
    static let banner = "/api/banner"
    static let mail = "/api/mail"
    static let tag = "/api/tag"
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
    
    static let scoreNone = 41
    static let birthNone = 42
}

struct TagType {
    static let activity = 7
    static let disease = 8
    static let drug = 9
    static let food = 10
    static let character = 11
    static let category = 12
    static let bookmark = 13
    static let diary = 14
    static let history = 15
}

struct SortType {
    static let priority = "priority"
    static let eng = "eng"
    static let kor = "kor"
    static let jpn = "jpn"
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

struct LogGroupOption {
    static let score = "score"
    static let note = "note"
    static let remove = "remove"
}

struct MailOption {
    static let find = "find"
    static let verify = "verify"
    static let code = "code"
}

struct DiaryMode {
    static let logger = 1
    static let editor = 2
}

struct ButtonType {
    static let home = 1
    static let close = 2
    static let back = 3
}

struct CalScope {
    static let week = 1
    static let month = 2
}

struct AvatarInfoTarget {
    static let firstName = 11
    static let lastName = 12
    static let email = 13
    static let phNumber = 14
    static let intro = 15
    static let color_code = 16
}

struct TagId {
    static let activity = 2
    static let disease = 3
    static let pill = 4
    static let food = 5
    static let home = 16
    static let diary = 17
    static let bookmarks = 18
    static let language = 20
    static let dateOfBirth = 23
    static let history = 24
    static let subscription = 14641
    static let password = 14642
    static let ranking = 14644
    static let supplements = 1040
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

struct LanguageId {
    static let eng = 30
    static let kor = 35
    static let jpn = 34
}

func getDeviceLanguage() -> Int {
    guard let regionCode = Locale.current.regionCode else {
        return LangHelper.getLanguageIdByRegion(alpha2: "EN")
    }
    return LangHelper.getLanguageIdByRegion(alpha2: regionCode)
//    return LangHelper.getLanguageId(alpha2: String(Locale.preferredLanguages[0].prefix(2)))
}

func getUserCountryCode() -> String {
    let locale = NSLocale.autoupdatingCurrent
    return locale.regionCode ?? "US"
//    return ((Locale.current as NSLocale).object(forKey: .countryCode) as? String)!
}

func getLogGroupTypeImage(_ groupType: Int) -> UIImage? {
    switch groupType {
    case LogGroupType.morning: return .itemGtSunrise
    case LogGroupType.daytime: return .itemGtSun
    case LogGroupType.evening: return .itemGtSunset
    case LogGroupType.nighttime: return .itemGtMoon
    default: return nil
    }
}

func getCondScoreImageSmall(_ condScore: Int) -> UIImage? {
    if condScore < 3 {
        return .itemScoreAwful
    } else if condScore < 5 {
        return .itemScoreBad
    } else if condScore < 7 {
        return .itemScoreSoso
    } else if condScore < 9 {
        return .itemScoreGood
    } else {
        return .itemScoreExcellent
    }
}

func getCondScoreImageLarge(_ condScore: Float) -> UIImage? {
    if condScore < 1 {
        return .itemScoreNoneL
    } else if condScore < 2.5 {
        return .itemScoreAwfulL
    } else if condScore < 4.5 {
        return .itemScoreBadL
    } else if condScore < 6.5 {
        return .itemScoreSosoL
    } else if condScore < 8.5 {
        return .itemScoreGoodL
    } else {
        return .itemScoreExcellentL
    }
}

func getCondScoreColor(_ condScore: Float) -> UIColor? {
    if condScore < 1 {
        return .dimGray
    } else if condScore < 2.5 {
        return .purple_A45FAC
    } else if condScore < 4.5 {
        return .tomato
    } else if condScore < 6.5 {
        return UIColor(hex: "#FEA32A")
    } else if condScore < 8.5 {
        return .green_41B275
    } else {
        return .dodgerBlue
    }
}

func getProfileUIColor(key: Int) -> UIColor {
    switch key {
    case 1: return UIColor(hex: "RosyBrown")
    case 2: return UIColor(hex: "IndianRed")
    case 3: return UIColor(hex: "Coral")
    case 4: return UIColor(hex: "#FFB757")
    case 5: return UIColor(hex: "#D2D372")
    case 6: return UIColor(hex: "#6AA8AA")
    case 7: return UIColor(hex: "#ACD9AB")
    case 8: return UIColor(hex: "#7FD9D9")
    case 9: return UIColor(hex: "#5DB5FF")
    case 10: return UIColor(hex: "LightSkyBlue")
    case 11: return UIColor(hex: "CornflowerBlue")
    case 12: return UIColor(hex: "MediumPurple")
    case 13: return UIColor(hex: "#989CFB")
    case 14: return UIColor(hex: "Violet")
    case 15: return UIColor(hex: "HotPink")
    default: return UIColor(hex: "HotPink")}
}
