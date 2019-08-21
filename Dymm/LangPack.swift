//
//  LangPack.swift
//  Flava
//
//  Created by eunsang lee on 15/11/2018.
//  Copyright © 2018 Flava Inc. All rights reserved.
//

import Foundation

class LangPack {
    let currentLangErrorMsg = "Config.currentLanguage has not setting up"
    var currentLanguageId: Int!
    
    var titleProfile: String!
    var titleFoodLog: String!
    var titleDiary: String!
    var titleGuest: String!
    var titleLogGroup: [String]!
    var titleWeekday: [String]!
    var titleMyAvtCond: String!
    var titleCondScore: String!
    
    var txtFieldFirstName: String!
    var txtFieldLastName: String!
    var txtFieldEmail: String!
    var txtFieldPassword: String!
    var txtFieldConfirmPassword: String!
    var txtFieldSearch: String!
    
    var labelSignIn: String!
    var labelSignUp: String!
    var labelProfile: String!
    var labelCreateNewGroup: String!
    var labelAvatarFirstName: String!
    var labelAvatarLastName: String!
    var labelUserMail: String!
    var labelUserPhoneNum: String!
    var labelAvatarIntroduction: String!
    var labelToday: String!
    var labelCondScores: [String]!
    
    var btnSignOut: String!
    var btnForgotPassword: String!
    var btnSignUp: String!
    var btnSignIn: String!
    var btnCreateNew: String!
    var btnSubmit: String!
    var btnDone: String!
    var btnCancel: String!
    var btnRetry: String!
    var btnContinue: String!
    var btnBackHom: String!
    var btnStay: String!
    var btnSpread: String!
    var btnFold: String!
    var btnAll: String!
    var btnSendAgain: String!
    var btnYes: String!
    var btnNo: String!
    var btnStartDate: String!
    var btnEndDate: String!
    var btnEdit: String!
    var btnClose: String!
    
    var msgNetworkFailure: String!
    var msgForbiddenInvalidEmail: String!
    var msgForbiddenDuplicatedEmail: String!
    var msgForbiddenInvalidPassword: String!
    var msgForbiddenInvalidUser: String!
    var msgMailSnedAgainComplete: String!
    var msgMailNotConfirmedYet: String!
    var msgMailModified: String!
    var msgIntakeLogComplete: ((String) -> String)!
    var msgEmptyName: String!
    var msgEmptyEmail: String!
    var msgInvalidEmail: String!
    var msgEmptyPassword: String!
    var msgShortPassword: String!
    var msgMismatchConfirmPassword: String!
    var msgFloatingInvalidEmail: String!
    var msgFloatingInvalidPassword: String!
    var msgFloatingMismatchConfirmPassword: String!
    var msgInactiveFood: String!
    
    var alertEditFirstNameTitle: String!
    var alertEditFirstNamePlaceholder: String!
    var alertEditLastNameTitle: String!
    var alertEditLastNamePlaceholder: String!
    var alertEditEmailTitle: String!
    var alertEditEmailPlaceholder: String!
    var alertEditPhNumTitle: String!
    var alertEditPhNumPlaceholder: String!
    var alertEditIntroTitle: String!
    var alertEditIntroPlaceholder: String!
    
    var avatarDefaultBirthYeaer: String!
    
    var calendarHeaderDateFormat: String!
    var avatarCondDateFormat: String!
    var calendarSection: ((Int, Int) -> String)!
    
    func getLogGroupTypeName(_ key: Int) -> String {
        let idx = key - 1
        return titleLogGroup[idx]
    }
    
    func getCondScoreName(_ key: Int) -> String {
        var idx = 0
        if key < 4 {
            idx = 0
        } else if key < 7 {
            idx = 1
        } else if key < 9 {
            idx = 2
        } else {
            idx = 3
        }
        return labelCondScores[idx]
    }
    
    func getWeekdayName(_ key: Int) -> String {
        let idx = key - 1
        return titleWeekday[idx]
    }
}

func getLanguagePack(_ currentLanguageId: Int) -> LangPack {
    var lang = LangPack()
    lang.currentLanguageId = currentLanguageId
    
    // MARK: Navigation Title
    
    lang.titleProfile = {
        switch currentLanguageId {
        case LanguageId.eng: return "Profile"
        case LanguageId.kor: return "프로필"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.titleFoodLog = {
        switch currentLanguageId {
        case LanguageId.eng: return "Log What You Ate"
        case LanguageId.kor: return "섭취한 것 기록하기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.titleDiary = {
        switch currentLanguageId {
        case LanguageId.eng: return "Diary"
        case LanguageId.kor: return "다이어리"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.titleGuest = {
        switch currentLanguageId {
        case LanguageId.eng: return "Guest"
        case LanguageId.kor: return "게스트"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.titleLogGroup = {
        switch currentLanguageId {
        case LanguageId.eng:
            return ["Morning", "Daytitme", "Evening", "Nighttime"]
        case LanguageId.kor:
            return ["아침", "주간", "저녁", "야간"]
        default: fatalError("")}
    }()
    lang.titleWeekday = {
        switch currentLanguageId {
        case LanguageId.eng:
            return ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        case LanguageId.kor:
            return ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]
        default: fatalError("")}
    }()
    lang.titleMyAvtCond = {
        switch currentLanguageId {
        case LanguageId.eng: return "My Condtion History"
        case LanguageId.kor: return "나의 컨디션 히스토리"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.titleCondScore = {
        switch currentLanguageId {
        case LanguageId.eng: return "Condition score"
        case LanguageId.kor: return "컨디션 점수"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    
    // MARK: TextField
    
    lang.txtFieldFirstName = {
        switch currentLanguageId {
        case LanguageId.eng: return "First Name"
        case LanguageId.kor: return "이름"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.txtFieldLastName = {
        switch currentLanguageId {
        case LanguageId.eng: return "Last Name"
        case LanguageId.kor: return "성씨"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.txtFieldEmail = {
        switch currentLanguageId {
        case LanguageId.eng: return "Email"
        case LanguageId.kor: return "메일주소"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.txtFieldPassword = {
        switch currentLanguageId {
        case LanguageId.eng: return "Password"
        case LanguageId.kor: return "패스워드"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.txtFieldConfirmPassword = {
        switch currentLanguageId {
        case LanguageId.eng: return "Confirm Password"
        case LanguageId.kor: return "패스워드 확인"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.txtFieldSearch = {
        switch currentLanguageId {
        case LanguageId.eng: return "Search"
        case LanguageId.kor: return "검색"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    
    // MARK: Label
    
    lang.labelSignIn = {
        switch currentLanguageId {
        case LanguageId.eng: return "Sign In"
        case LanguageId.kor: return "로그인"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.labelSignUp = {
        switch currentLanguageId {
        case LanguageId.eng: return "Sign Up"
        case LanguageId.kor: return "회원가입"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.labelProfile = {
        switch currentLanguageId {
        case LanguageId.eng: return "PROFILE"
        case LanguageId.kor: return "프로필"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.labelCreateNewGroup = {
        switch currentLanguageId {
        case LanguageId.eng: return "Create New Group"
        case LanguageId.kor: return "새 그룹 만들기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.labelAvatarFirstName = {
        switch currentLanguageId {
        case LanguageId.eng: return "AVATAR FIRST NAME"
        case LanguageId.kor: return "아바타 이름"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.labelAvatarLastName = {
        switch currentLanguageId {
        case LanguageId.eng: return "AVATAR LAST NAME"
        case LanguageId.kor: return "아바타 성씨"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.labelUserMail = {
        switch currentLanguageId {
        case LanguageId.eng: return "EMAIL ADDRESS"
        case LanguageId.kor: return "메일주소"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.labelUserPhoneNum = {
        switch currentLanguageId {
        case LanguageId.eng: return "PHONE NUMBER"
        case LanguageId.kor: return "전화번호"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.labelAvatarIntroduction = {
        switch currentLanguageId {
        case LanguageId.eng: return "INTRODUCTION"
        case LanguageId.kor: return "자기소개"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.labelToday = {
        switch currentLanguageId {
        case LanguageId.eng: return "Today"
        case LanguageId.kor: return "오늘"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.labelCondScores = {
        switch currentLanguageId {
        case LanguageId.eng: return ["Bad", "Soso", "Good", "Awesome!"]
        case LanguageId.kor: return ["나쁨", "보통", "좋음", "최고!"]
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    
    // MARK: Button
    
    lang.btnSignOut = {
        switch currentLanguageId {
        case LanguageId.eng: return "Sign out"
        case LanguageId.kor: return "로그아웃"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnForgotPassword = {
        switch currentLanguageId {
        case LanguageId.eng: return "Forgot password?"
        case LanguageId.kor: return "비밀번호를 잊었나요?"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnSignIn = {
        switch currentLanguageId {
        case LanguageId.eng: return "Sign in"
        case LanguageId.kor: return "로그인"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnSignUp = {
        switch currentLanguageId {
        case LanguageId.eng: return "Sign up"
        case LanguageId.kor: return "새로 가입하기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnCreateNew = {
        switch currentLanguageId {
        case LanguageId.eng: return "Create New"
        case LanguageId.kor: return "새로 만들기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnSubmit = {
        switch currentLanguageId {
        case LanguageId.eng: return "Submit"
        case LanguageId.kor: return "보내기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnDone = {
        switch currentLanguageId {
        case LanguageId.eng: return "Done"
        case LanguageId.kor: return "확인"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnCancel = {
        switch currentLanguageId {
        case LanguageId.eng: return "Cancel"
        case LanguageId.kor: return "취소"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnRetry = {
        switch currentLanguageId {
        case LanguageId.eng: return "Retry"
        case LanguageId.kor: return "다시하기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnContinue = {
        switch currentLanguageId {
        case LanguageId.eng: return "Continue"
        case LanguageId.kor: return "계속하기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnBackHom = {
        switch currentLanguageId {
        case LanguageId.eng: return "Back to Home"
        case LanguageId.kor: return "홈으로 돌아가기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnStay = {
        switch currentLanguageId {
        case LanguageId.eng: return "Stay"
        case LanguageId.kor: return "머무르기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnSpread = {
        switch currentLanguageId {
        case LanguageId.eng: return "Spread"
        case LanguageId.kor: return "펼치기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnFold = {
        switch currentLanguageId {
        case LanguageId.eng: return "Fold"
        case LanguageId.kor: return "접기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnAll = {
        switch currentLanguageId {
        case LanguageId.eng: return "ALL"
        case LanguageId.kor: return "모두"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnSendAgain = {
        switch currentLanguageId {
        case LanguageId.eng: return "Send Again"
        case LanguageId.kor: return "다시 보내기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnYes = {
        switch currentLanguageId {
        case LanguageId.eng: return "Yes"
        case LanguageId.kor: return "예"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnNo = {
        switch currentLanguageId {
        case LanguageId.eng: return "No"
        case LanguageId.kor: return "아니오"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnStartDate = {
        switch currentLanguageId {
        case LanguageId.eng: return "Start date"
        case LanguageId.kor: return "시작 일자"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnEndDate = {
        switch currentLanguageId {
        case LanguageId.eng: return "End date"
        case LanguageId.kor: return "끝난 일자"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnEdit = {
        switch currentLanguageId {
        case LanguageId.eng: return "Edit"
        case LanguageId.kor: return "편집"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.btnClose = {
        switch currentLanguageId {
        case LanguageId.eng: return "Close"
        case LanguageId.kor: return "닫기"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    
    // MARK: Message
    
    lang.msgNetworkFailure = {
        switch currentLanguageId {
        case LanguageId.eng: return "Unable to access the server.\n\nWant to try again?"
        case LanguageId.kor: return "서버와의 통신이 원활하지 않습니다.\n\n다시 시도하시겠습니다?"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgForbiddenInvalidEmail = {
        switch currentLanguageId {
        case LanguageId.eng: return "Couldn't find your Account"
        case LanguageId.kor: return "일치하는 메일주소를 찾을 수 없습니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgForbiddenDuplicatedEmail = {
        switch currentLanguageId {
        case LanguageId.eng: return "That mail address is already taken. Try another"
        case LanguageId.kor: return "이미 사용중인 메일주소 입니다. 다르게 시도해보세요."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgForbiddenInvalidPassword = {
        switch currentLanguageId {
        case LanguageId.eng: return "Wrong password.\nTry again or click Lost account."
        case LanguageId.kor: return "패스워드가 잘못 입력되었습니다.\n다시 시도하거나 비밀번호변경을 클릭하세요."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgForbiddenInvalidUser = {
        switch currentLanguageId {
        case LanguageId.eng: return "User access has denied.\nTry log-in again please."
        case LanguageId.kor: return "사용이 정지된 계정으로 접근하셨습니다.\n로그인을 새로 해주세요."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgMailSnedAgainComplete = {
        switch currentLanguageId {
        case LanguageId.eng: return "Account email has been resent.\nPleas confirm Your email."
        case LanguageId.kor: return "계정 확인 메일이 다시 보내졌습니다.\n메일계정을 확인해 주세요."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgMailNotConfirmedYet = {
        switch currentLanguageId {
        case LanguageId.eng: return "Your email not confirmed yet. \nPleas confirm Your email."
        case LanguageId.kor: return "계정이 아직 확인되지 않았습니다.\n메일계정을 확인해 주세요."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgMailModified = {
        switch currentLanguageId {
        case LanguageId.eng: return "Your email address has been modified.\nPlease confirm Your new email."
        case LanguageId.kor: return "메일주소가 변경되었습니다.\n변경된 메일계정을 확인해 주세요."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    func _intakeLogComplete(intake: String) -> String {
        switch currentLanguageId {
        case LanguageId.eng: return "The \(intake) has been successfully recored!\n\nWant to back Home?"
        case LanguageId.kor: return "\(intake) 성공적으로 기록되었습니다!\n\n홈으로 이동하시겠습니까?"
        default: fatalError(lang.currentLangErrorMsg)}
    }
    lang.msgIntakeLogComplete = _intakeLogComplete
    lang.msgEmptyName = {
        switch currentLanguageId {
        case LanguageId.eng: return "Enter first name"
        case LanguageId.kor: return "이름이 입력되지 않았습니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgEmptyEmail = {
        switch currentLanguageId {
        case LanguageId.eng: return "Enter mail address"
        case LanguageId.kor: return "메일주소가 입력되지 않았습니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgInvalidEmail = {
        switch currentLanguageId {
        case LanguageId.eng: return "Invalid mail address"
        case LanguageId.kor: return "메일주소가 잘못 입력되었습니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgEmptyPassword = {
        switch currentLanguageId {
        case LanguageId.eng: return "Enter password"
        case LanguageId.kor: return "패스워드가 입력되지 않았습니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgShortPassword = {
        switch currentLanguageId {
        case LanguageId.eng: return "Use 8 characters or more"
        case LanguageId.kor: return "패스워드가 8자리이상 입력되어야 합니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgMismatchConfirmPassword = {
        switch currentLanguageId {
        case LanguageId.eng: return "Those password didn't match. Try again"
        case LanguageId.kor: return "패스워드가 일치하지 않습니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgFloatingInvalidEmail = {
        switch currentLanguageId {
        case LanguageId.eng: return "Invalid mail address"
        case LanguageId.kor: return "유효하지 않은 메일주소"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgFloatingInvalidPassword = {
        switch currentLanguageId {
        case LanguageId.eng: return "Invalid password"
        case LanguageId.kor: return "유효하지 않은 패스워드"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgFloatingMismatchConfirmPassword = {
        switch currentLanguageId {
        case LanguageId.eng: return "Password mismatch"
        case LanguageId.kor: return "패스워드 확인 불일치"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.msgInactiveFood = {
        switch currentLanguageId {
        case LanguageId.eng: return "You have tried to inactive food."
        case LanguageId.kor: return "사용이 정지된 음식에 접근을 시도하였습니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    
    // MARK: Alert
    
    lang.alertEditFirstNameTitle = {
        switch currentLanguageId {
        case LanguageId.eng: return "Edit Avatar's first name."
        case LanguageId.kor: return "아바타의 이름을 수정합니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.alertEditFirstNamePlaceholder = {
        switch currentLanguageId {
        case LanguageId.eng: return "First name"
        case LanguageId.kor: return "이름"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.alertEditLastNameTitle = {
        switch currentLanguageId {
        case LanguageId.eng: return "Edit Avatar's last name."
        case LanguageId.kor: return "아바타의 성을 수정합니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.alertEditLastNamePlaceholder = {
        switch currentLanguageId {
        case LanguageId.eng: return "Last name"
        case LanguageId.kor: return "성"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.alertEditEmailTitle = {
        switch currentLanguageId {
        case LanguageId.eng: return "Edit Your mail address."
        case LanguageId.kor: return "메일주소를 수정합니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.alertEditEmailPlaceholder = {
        switch currentLanguageId {
        case LanguageId.eng: return "Mail address"
        case LanguageId.kor: return "메일 주소"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.alertEditPhNumTitle = {
        switch currentLanguageId {
        case LanguageId.eng: return "Edit Your phone number."
        case LanguageId.kor: return "전화번호를 수정합니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.alertEditPhNumPlaceholder = {
        switch currentLanguageId {
        case LanguageId.eng: return "Phone number"
        case LanguageId.kor: return "전화번호"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.alertEditIntroTitle = {
        switch currentLanguageId {
        case LanguageId.eng: return "Edit Your introduction."
        case LanguageId.kor: return "소개 글을 수정합니다."
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    lang.alertEditIntroPlaceholder = {
        switch currentLanguageId {
        case LanguageId.eng: return "Introduction"
        case LanguageId.kor: return "소개 글"
        default: fatalError(lang.currentLangErrorMsg)}
    }()
    
    // MARK: Birth Year
    
    lang.avatarDefaultBirthYeaer = {
        switch currentLanguageId {
        case LanguageId.eng:
            return "Birth Year"
        case LanguageId.kor:
            return "태어난 해"
        default: fatalError("")}
    }()
    
    // MARK: Calendar
    
    lang.calendarHeaderDateFormat = {
        switch currentLanguageId {
        case LanguageId.eng:
            return "MMMM YYYY"
        case LanguageId.kor:
            return "MM월 YYYY"
        default: fatalError("")}
    }()
    lang.avatarCondDateFormat = {
        switch currentLanguageId {
        case LanguageId.eng:
            return "MMMM YYYY"
        case LanguageId.kor:
            return "MM월 YYYY"
        default: fatalError("")}
    }()
    func _calendarSection(monthNumber: Int, dayNumber: Int) -> String {
        switch currentLanguageId {
        case LanguageId.eng: return "\(dayNumber) \(getEngNameOfMonth(monthNumber: monthNumber))"
        case LanguageId.kor: return "\(dayNumber)일 \(monthNumber)월"
        default: fatalError(lang.currentLangErrorMsg)}
    }
    lang.calendarSection = _calendarSection

    return lang
}
