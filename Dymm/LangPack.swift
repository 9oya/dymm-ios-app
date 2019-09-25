//
//  LangPack.swift
//  Flava
//
//  Created by eunsang lee on 15/11/2018.
//  Copyright © 2018 Flava Inc. All rights reserved.
//

import Foundation

struct LangPack {
    var currentLanguageId: Int!
    
    var titleAll: String!
    var titleAvgScore: String!
    var titleBackHome: String!
    var titleCamera: String!
    var titleCancel: String!
    var titleChangeColor: String!
    var titleChangeProfileImg: String!
    var titleClose: String!
    var titleCondScore: String!
    var titleCondScores: [String]!
    var titleContinue: String!
    var titleCreateNew: String!
    var titleCreateNewGroup: String!
    var titleDiary: String!
    var titleDone: String!
    var titleEdit: String!
    var titleEditEmail: String!
    var titleEditFirstName: String!
    var titleEditIntro: String!
    var titleEditLastName: String!
    var titleEditPhoneNum: String!
    var titleEmail: String!
    var titleEmailFound: String!
    var titleEmailNotFound: String!
    var titleEmailUpper: String!
    var titleEmailValidCode: String!
    var titleEndDate: String!
    var titleFirstName: String!
    var titleFirstNameUpper: String!
    var titleFold: String!
    var titleFoodLog: String!
    var titleForgotPassword: String!
    var titleForgotPasswordAlert: String!
    var titleGuest: String!
    var titleIncorrectEmailCode: String!
    var titleIncorrectOldPassword: String!
    var titleIntro: String!
    var titleIntroUpper: String!
    var titleLastMonth: String!
    var titleLastName: String!
    var titleLastNameUpper: String!
    var titleLastWeek: String!
    var titleLogGroups: [String]!
    var titleMyAvtCond: String!
    var titleNo: String!
    var titleNote: String!
    var titleNotes: String!
    var titlePassword: String!
    var titlePasswordChange: String!
    var titlePasswordChangeCompl: String!
    var titlePasswordConfirm: String!
    var titlePasswordNew: String!
    var titlePasswordOld: String!
    var titlePhoneNum: String!
    var titlePhoneNumUpper: String!
    var titlePhotolibrary: String!
    var titleProfile: String!
    var titleProfileUpper: String!
    var titleRetry: String!
    var titleSearch: String!
    var titleSend: String!
    var titleSendAgain: String!
    var titleSignIn: String!
    var titleSignOut: String!
    var titleSignUp: String!
    var titleSorry: String!
    var titleSpread: String!
    var titleStartDate: String!
    var titleStay: String!
    var titleSubmit: String!
    var titleSubscribe: String!
    var titleToday: String!
    var titleThisMonth: String!
    var titleThisWeek: String!
    var titleVerifCode: String!
    var titleWeekdays: [String]!
    var titleYes: String!
    
    var msgAvgScoreDownMonth: ((String) -> String)!
    var msgAvgScoreDownWeek: String!
    var msgAvgScoreEqualWeek: String!
    var msgAvgScoreEqualMonth: ((String) -> String)!
    var msgAvgScoreUpWeek: String!
    var msgAvgScoreUpMonth: ((String) -> String)!
    var msgCameraDisable: String!
    var msgChangePasswordCompl: String!
    var msgEmptyEmail: String!
    var msgEmptyName: String!
    var msgEmptyPassword: String!
    var msgFloatingInvalidEmail: String!
    var msgFloatingInvalidPassword: String!
    var msgFloatingMismatchConfirmPassword: String!
    var msgInactiveFood: String!
    var msgInvalidEmail: String!
    var msgLogComplete: String!
    var msgMailEnter: String!
    var msgMailModified: String!
    var msgMailNotConfirmedYet: String!
    var msgMailSendAgainComplete: String!
    var msgMailSendValidCode: ((String) -> String)!
    var msgMismatchConfirmPassword: String!
    var msgNetworkFailure: String!
    var msgShortPassword: String!
    var msgUnauthDuplicatedEmail: String!
    var msgUnauthInvalidEmail: String!
    var msgUnauthInvalidPassword: String!
    var msgUnauthInvalidUser: String!
    var msgValidCodeEnter: String!
    
    var calendarHeaderDateFormat: String!
    
    var getLogGroupSection: ((Int, Int) -> String)!
    func getLogGroupTypeName(_ key: Int) -> String {
        let idx = key - 1
        return titleLogGroups[idx]
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
        return titleCondScores[idx]
    }
    func getWeekdayName(_ key: Int) -> String {
        let idx = key - 1
        return titleWeekdays[idx]
    }
    
    init(_ currentLanguageId: Int) {
        self.currentLanguageId = currentLanguageId
        
        // MARK: Titles
        
        self.titleAll = {
            switch currentLanguageId {
            case LanguageId.eng: return "ALL"
            case LanguageId.kor: return "모두"
            case LanguageId.jpn: return ""
            default: fatalError()}
        }()
//        func _titleAvgScore(_ month: String) -> String {
//            switch currentLanguageId {
//            case LanguageId.eng: return "My \(month) Condition Score"
//            case LanguageId.kor: return "나의 \(month) 컨디션 점수"
//            case LanguageId.jpn: return ""
//            default: fatalError()}
//        }
        self.titleAvgScore = {
            switch currentLanguageId {
            case LanguageId.eng: return "My Condition Score"
            case LanguageId.kor: return "나의 컨디션 점수"
            default: fatalError()}
        }()
        self.titleBackHome = {
            switch currentLanguageId {
            case LanguageId.eng: return "Back to Home"
            case LanguageId.kor: return "홈으로 돌아가기"
            default: fatalError()}
        }()
        self.titleCamera = {
            switch currentLanguageId {
            case LanguageId.eng: return "Camera"
            case LanguageId.kor: return "카메라"
            default: fatalError()}
        }()
        self.titleCancel = {
            switch currentLanguageId {
            case LanguageId.eng: return "Cancel"
            case LanguageId.kor: return "취소"
            default: fatalError()}
        }()
        self.titleChangeColor = {
            switch currentLanguageId {
            case LanguageId.eng: return "Change color"
            case LanguageId.kor: return "컬러 변경"
            default: fatalError()}
        }()
        self.titleChangeProfileImg = {
            switch currentLanguageId {
            case LanguageId.eng: return "Change profile image"
            case LanguageId.kor: return "프로파일 이미지를 변경합니다"
            default: fatalError()}
        }()
        self.titleClose = {
            switch currentLanguageId {
            case LanguageId.eng: return "Close"
            case LanguageId.kor: return "닫기"
            default: fatalError()}
        }()
        self.titleCondScore = {
            switch currentLanguageId {
            case LanguageId.eng: return "Condition score"
            case LanguageId.kor: return "컨디션 점수"
            default: fatalError()}
        }()
        self.titleCondScores = {
            switch currentLanguageId {
            case LanguageId.eng: return ["Awful", "Bad", "Soso", "Good", "Awesome!"]
            case LanguageId.kor: return ["최악", "나쁨", "보통", "좋음", "최고!"]
            default: fatalError()}
        }()
        self.titleContinue = {
            switch currentLanguageId {
            case LanguageId.eng: return "Continue"
            case LanguageId.kor: return "계속하기"
            default: fatalError()}
        }()
        self.titleCreateNew = {
            switch currentLanguageId {
            case LanguageId.eng: return "Create New"
            case LanguageId.kor: return "새로 만들기"
            default: fatalError()}
        }()
        self.titleCreateNewGroup = {
            switch currentLanguageId {
            case LanguageId.eng: return "Create New Group"
            case LanguageId.kor: return "새 그룹 만들기"
            default: fatalError()}
        }()
        self.titleDiary = {
            switch currentLanguageId {
            case LanguageId.eng: return "Diary"
            case LanguageId.kor: return "다이어리"
            default: fatalError()}
        }()
        self.titleDone = {
            switch currentLanguageId {
            case LanguageId.eng: return "Done"
            case LanguageId.kor: return "확인"
            default: fatalError()}
        }()
        self.titleEdit = {
            switch currentLanguageId {
            case LanguageId.eng: return "Edit"
            case LanguageId.kor: return "편집"
            default: fatalError()}
        }()
        self.titleEditEmail = {
            switch currentLanguageId {
            case LanguageId.eng: return "Edit Your mail address."
            case LanguageId.kor: return "메일주소를 수정합니다."
            default: fatalError()}
        }()
        self.titleEditFirstName = {
            switch currentLanguageId {
            case LanguageId.eng: return "Edit Avatar's first name."
            case LanguageId.kor: return "아바타의 이름을 수정합니다."
            default: fatalError()}
        }()
        self.titleEditIntro = {
            switch currentLanguageId {
            case LanguageId.eng: return "Edit Your introduction."
            case LanguageId.kor: return "소개 글을 수정합니다."
            default: fatalError()}
        }()
        self.titleEditLastName = {
            switch currentLanguageId {
            case LanguageId.eng: return "Edit Avatar's last name."
            case LanguageId.kor: return "아바타의 성을 수정합니다."
            default: fatalError()}
        }()
        self.titleEditPhoneNum = {
            switch currentLanguageId {
            case LanguageId.eng: return "Edit Your phone number."
            case LanguageId.kor: return "전화번호를 수정합니다."
            default: fatalError()}
        }()
        self.titleEmail = {
            switch currentLanguageId {
            case LanguageId.eng: return "Email"
            case LanguageId.kor: return "메일주소"
            default: fatalError()}
        }()
        self.titleEmailFound = {
            switch currentLanguageId {
            case LanguageId.eng: return "We found a matching account."
            case LanguageId.kor: return "일치하는 계정을 찾았습니다."
            default: fatalError()}
        }()
        self.titleEmailNotFound = {
            switch currentLanguageId {
            case LanguageId.eng: return "\u{26A0}Email address not found."
            case LanguageId.kor: return "\u{26A0}메일주소를 찾을 수 없습니다."
            default: fatalError()}
        }()
        self.titleEmailUpper = {
            switch currentLanguageId {
            case LanguageId.eng: return "EMAIL ADDRESS"
            case LanguageId.kor: return "메일주소"
            default: fatalError()}
        }()
        self.titleEmailValidCode = {
            switch currentLanguageId {
            case LanguageId.eng: return "A verification code has been sent."
            case LanguageId.kor: return "인증 코드를 발송하였습니다."
            default: fatalError()}
        }()
        self.titleEndDate = {
            switch currentLanguageId {
            case LanguageId.eng: return "End date"
            case LanguageId.kor: return "끝난 일자"
            default: fatalError()}
        }()
        self.titleFirstName = {
            switch currentLanguageId {
            case LanguageId.eng: return "First Name"
            case LanguageId.kor: return "이름"
            default: fatalError()}
        }()
        self.titleFirstNameUpper = {
            switch currentLanguageId {
            case LanguageId.eng: return "FIRST NAME"
            case LanguageId.kor: return "이름"
            default: fatalError()}
        }()
        self.titleFold = {
            switch currentLanguageId {
            case LanguageId.eng: return "Fold"
            case LanguageId.kor: return "접기"
            default: fatalError()}
        }()
        self.titleFoodLog = {
            switch currentLanguageId {
            case LanguageId.eng: return "Log What You Ate"
            case LanguageId.kor: return "섭취한 것 기록하기"
            default: fatalError()}
        }()
        self.titleForgotPassword = {
            switch currentLanguageId {
            case LanguageId.eng: return "Forgot password?"
            case LanguageId.kor: return "패스워드를 잊으셨나요?"
            default: fatalError()}
        }()
        self.titleForgotPasswordAlert = {
            switch currentLanguageId {
            case LanguageId.eng: return "I forgot my Dymm password"
            case LanguageId.kor: return "Dymm 패스워드를 분실하였습니다."
            default: fatalError()}
        }()
        self.titleGuest = {
            switch currentLanguageId {
            case LanguageId.eng: return "Guest"
            case LanguageId.kor: return "게스트"
            default: fatalError()}
        }()
        self.titleIncorrectEmailCode = {
            switch currentLanguageId {
            case LanguageId.eng: return "\u{26A0}Incorrect or expired verification code"
            case LanguageId.kor: return "\u{26A0}일치하지 않는 또는 만료된 인증 코드"
            default: fatalError()}
        }()
        self.titleIncorrectOldPassword = {
            switch currentLanguageId {
            case LanguageId.eng: return "\u{26A0}Incorrect old password."
            case LanguageId.kor: return "\u{26A0}이전 패스워드가 정확하지 않습니다."
            default: fatalError()}
        }()
        self.titleIntro = {
            switch currentLanguageId {
            case LanguageId.eng: return "Introduction"
            case LanguageId.kor: return "소개 글"
            default: fatalError()}
        }()
        self.titleIntroUpper = {
            switch currentLanguageId {
            case LanguageId.eng: return "INTRODUCTION"
            case LanguageId.kor: return "자기소개"
            default: fatalError()}
        }()
        self.titleLastMonth = {
            switch currentLanguageId {
            case LanguageId.eng: return "Last month"
            case LanguageId.kor: return "지난 달"
            default: fatalError()}
        }()
        self.titleLastName = {
            switch currentLanguageId {
            case LanguageId.eng: return "Last Name"
            case LanguageId.kor: return "성씨"
            default: fatalError()}
        }()
        self.titleLastNameUpper = {
            switch currentLanguageId {
            case LanguageId.eng: return "LAST NAME"
            case LanguageId.kor: return "성씨"
            default: fatalError()}
        }()
        self.titleLastWeek = {
            switch currentLanguageId {
            case LanguageId.eng: return "Last week"
            case LanguageId.kor: return "지난 주"
            default: fatalError()}
        }()
        self.titleLogGroups = {
            switch currentLanguageId {
            case LanguageId.eng:
                return ["Morning", "Daytitme", "Evening", "Nighttime"]
            case LanguageId.kor:
                return ["아침", "주간", "저녁", "야간"]
            default: fatalError("")}
        }()
        self.titleMyAvtCond = {
            switch currentLanguageId {
            case LanguageId.eng: return "My Condtion History"
            case LanguageId.kor: return "나의 컨디션 히스토리"
            default: fatalError()}
        }()
        self.titleNo = {
            switch currentLanguageId {
            case LanguageId.eng: return "No"
            case LanguageId.kor: return "아니오"
            default: fatalError()}
        }()
        self.titleNote = {
            switch currentLanguageId {
            case LanguageId.eng: return "Note"
            case LanguageId.kor: return "메모"
            default: fatalError()}
        }()
        self.titleNotes = {
            switch currentLanguageId {
            case LanguageId.eng: return "Notes"
            case LanguageId.kor: return "메모"
            default: fatalError()}
        }()
        self.titlePassword = {
            switch currentLanguageId {
            case LanguageId.eng: return "Password"
            case LanguageId.kor: return "패스워드"
            default: fatalError()}
        }()
        self.titlePasswordChange = {
            switch currentLanguageId {
            case LanguageId.eng: return "Change Password"
            case LanguageId.kor: return "패스워드 변경"
            default: fatalError()}
        }()
        self.titlePasswordChangeCompl = {
            switch currentLanguageId {
            case LanguageId.eng: return "Password Change Complete!"
            case LanguageId.kor: return "패스워드 변경이 완료되었습니다!"
            default: fatalError()}
        }()
        self.titlePasswordConfirm = {
            switch currentLanguageId {
            case LanguageId.eng: return "Confirm Password"
            case LanguageId.kor: return "패스워드 확인"
            default: fatalError()}
        }()
        self.titlePasswordNew = {
            switch currentLanguageId {
            case LanguageId.eng: return "New Password"
            case LanguageId.kor: return "새 패스워드"
            default: fatalError()}
        }()
        self.titlePasswordOld = {
            switch currentLanguageId {
            case LanguageId.eng: return "Old Password"
            case LanguageId.kor: return "이전 패스워드"
            default: fatalError()}
        }()
        self.titlePhoneNum = {
            switch currentLanguageId {
            case LanguageId.eng: return "Phone number"
            case LanguageId.kor: return "전화번호"
            default: fatalError()}
        }()
        self.titlePhoneNumUpper = {
            switch currentLanguageId {
            case LanguageId.eng: return "PHONE NUMBER"
            case LanguageId.kor: return "전화번호"
            default: fatalError()}
        }()
        self.titlePhotolibrary = {
            switch currentLanguageId {
            case LanguageId.eng: return "Photo library"
            case LanguageId.kor: return "사진 앨범"
            default: fatalError()}
        }()
        self.titleProfile = {
            switch currentLanguageId {
            case LanguageId.eng: return "Profile"
            case LanguageId.kor: return "프로필"
            default: fatalError()}
        }()
        self.titleProfileUpper = {
            switch currentLanguageId {
            case LanguageId.eng: return "PROFILE"
            case LanguageId.kor: return "프로필"
            default: fatalError()}
        }()
        self.titleRetry = {
            switch currentLanguageId {
            case LanguageId.eng: return "Retry"
            case LanguageId.kor: return "다시하기"
            default: fatalError()}
        }()
        self.titleSearch = {
            switch currentLanguageId {
            case LanguageId.eng: return "Search"
            case LanguageId.kor: return "검색"
            default: fatalError()}
        }()
        self.titleSend = {
            switch currentLanguageId {
            case LanguageId.eng: return "Send"
            case LanguageId.kor: return "전송"
            default: fatalError()}
        }()
        self.titleSendAgain = {
            switch currentLanguageId {
            case LanguageId.eng: return "Send Again"
            case LanguageId.kor: return "다시 보내기"
            default: fatalError()}
        }()
        self.titleSignIn = {
            switch currentLanguageId {
            case LanguageId.eng: return "Sign in"
            case LanguageId.kor: return "로그인"
            default: fatalError()}
        }()
        self.titleSignOut = {
            switch currentLanguageId {
            case LanguageId.eng: return "Sign out"
            case LanguageId.kor: return "로그아웃"
            default: fatalError()}
        }()
        self.titleSignUp = {
            switch currentLanguageId {
            case LanguageId.eng: return "Sign up"
            case LanguageId.kor: return "가입하기"
            default: fatalError()}
        }()
        self.titleSorry = {
            switch currentLanguageId {
            case LanguageId.eng: return "\u{1F62E}Sorry."
            case LanguageId.kor: return "\u{1F62E}죄송합니다."
            default: fatalError()}
        }()
        self.titleSpread = {
            switch currentLanguageId {
            case LanguageId.eng: return "Spread"
            case LanguageId.kor: return "펼치기"
            default: fatalError()}
        }()
        self.titleStartDate = {
            switch currentLanguageId {
            case LanguageId.eng: return "Start date"
            case LanguageId.kor: return "시작 일자"
            default: fatalError()}
        }()
        self.titleStay = {
            switch currentLanguageId {
            case LanguageId.eng: return "Stay"
            case LanguageId.kor: return "머무르기"
            default: fatalError()}
        }()
        self.titleSubmit = {
            switch currentLanguageId {
            case LanguageId.eng: return "Submit"
            case LanguageId.kor: return "보내기"
            default: fatalError()}
        }()
        self.titleSubscribe = {
            switch currentLanguageId {
            case LanguageId.eng: return "Subscribe"
            case LanguageId.kor: return "구독하기"
            default: fatalError()}
        }()
        self.titleToday = {
            switch currentLanguageId {
            case LanguageId.eng: return "Today"
            case LanguageId.kor: return "오늘"
            default: fatalError()}
        }()
        self.titleThisMonth = {
            switch currentLanguageId {
            case LanguageId.eng: return "This month"
            case LanguageId.kor: return "이번 달"
            default: fatalError()}
        }()
        self.titleThisWeek = {
            switch currentLanguageId {
            case LanguageId.eng: return "This week"
            case LanguageId.kor: return "이번 주"
            default: fatalError()}
        }()
        self.titleVerifCode = {
            switch currentLanguageId {
            case LanguageId.eng: return "Verification Code"
            case LanguageId.kor: return "인증 코드"
            default: fatalError()}
        }()
        self.titleWeekdays = {
            switch currentLanguageId {
            case LanguageId.eng:
                return ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            case LanguageId.kor:
                return ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]
            default: fatalError("")}
        }()
        self.titleYes = {
            switch currentLanguageId {
            case LanguageId.eng: return "Yes"
            case LanguageId.kor: return "예"
            default: fatalError()}
        }()
        
        // MARK: Messages
        
        self.msgAvgScoreDownWeek = {
            switch currentLanguageId {
            case LanguageId.eng: return "Your score has gone down this week."
            case LanguageId.kor: return "당신의 이번 주 점수가 하락했습니다."
            default: fatalError()}
        }()
        func _msgAvgScoreDownMonth(_ month: String) -> String {
            switch currentLanguageId {
            case LanguageId.eng: return "Your \(month) score has gone down."
            case LanguageId.kor: return "당신의 \(month) 점수가 하락했습니다."
            case LanguageId.jpn: return ""
            default: fatalError()}
        }
        self.msgAvgScoreDownMonth = _msgAvgScoreDownMonth
        self.msgAvgScoreEqualWeek = {
            switch currentLanguageId {
            case LanguageId.eng: return "Your score has been maintained this week."
            case LanguageId.kor: return "당신의 이번 주 점수가 유지되었습니다."
            default: fatalError()}
        }()
        func _msgAvgScoreEqualMonth(_ month: String) -> String {
            switch currentLanguageId {
            case LanguageId.eng: return "Your \(month) score has been maintained."
            case LanguageId.kor: return "당신의 \(month) 점수가 유지되었습니다."
            case LanguageId.jpn: return ""
            default: fatalError()}
        }
        self.msgAvgScoreEqualMonth = _msgAvgScoreEqualMonth
        self.msgAvgScoreUpWeek = {
            switch currentLanguageId {
            case LanguageId.eng: return "Your score has gone up this week."
            case LanguageId.kor: return "당신의 이번 주 점수가 상승했습니다."
            default: fatalError()}
        }()
        func _msgAvgScoreUpMonth(_ month: String) -> String {
            switch currentLanguageId {
            case LanguageId.eng: return "Your \(month) score has gone up."
            case LanguageId.kor: return "당신의 \(month) 점수가 상승했습니다."
            case LanguageId.jpn: return ""
            default: fatalError()}
        }
        self.msgAvgScoreUpMonth = _msgAvgScoreUpMonth
        self.msgCameraDisable = {
            switch currentLanguageId {
            case LanguageId.eng: return "Camera not available."
            case LanguageId.kor: return "카메라를 사용할 수 없습니다."
            default: fatalError()}
        }()
        self.msgChangePasswordCompl = {
            switch currentLanguageId {
            case LanguageId.eng: return "Your new password has been successfully changed."
            case LanguageId.kor: return "당신의 새 패스워드가 성공적으로 변경되었습니다."
            default: fatalError()}
        }()
        self.msgEmptyEmail = {
            switch currentLanguageId {
            case LanguageId.eng: return "Enter mail address"
            case LanguageId.kor: return "메일주소를 입력해 주세요."
            default: fatalError()}
        }()
        self.msgEmptyName = {
            switch currentLanguageId {
            case LanguageId.eng: return "Enter first name"
            case LanguageId.kor: return "이름이 입력되지 않았습니다."
            default: fatalError()}
        }()
        self.msgEmptyPassword = {
            switch currentLanguageId {
            case LanguageId.eng: return "Enter password"
            case LanguageId.kor: return "패스워드가 입력되지 않았습니다."
            default: fatalError()}
        }()
        self.msgFloatingInvalidEmail = {
            switch currentLanguageId {
            case LanguageId.eng: return "Invalid mail address"
            case LanguageId.kor: return "유효하지 않은 메일주소"
            default: fatalError()}
        }()
        self.msgFloatingInvalidPassword = {
            switch currentLanguageId {
            case LanguageId.eng: return "Invalid password"
            case LanguageId.kor: return "유효하지 않은 패스워드"
            default: fatalError()}
        }()
        self.msgFloatingMismatchConfirmPassword = {
            switch currentLanguageId {
            case LanguageId.eng: return "Password mismatch"
            case LanguageId.kor: return "패스워드 확인 불일치"
            default: fatalError()}
        }()
        self.msgInvalidEmail = {
            switch currentLanguageId {
            case LanguageId.eng: return "Invalid mail address"
            case LanguageId.kor: return "메일주소가 잘못 입력되었습니다."
            default: fatalError()}
        }()
        self.msgInactiveFood = {
            switch currentLanguageId {
            case LanguageId.eng: return "You have tried to inactive food."
            case LanguageId.kor: return "사용이 정지된 음식에 접근을 시도하였습니다."
            default: fatalError()}
        }()
        self.msgLogComplete = {
            switch currentLanguageId {
            case LanguageId.eng: return "Has been successfully recored!\n\nWant to back Home?"
            case LanguageId.kor: return "성공적으로 기록되었습니다!\n\n홈으로 이동하시겠습니까?"
            default: fatalError()}
        }()
        self.msgMailEnter = {
            switch currentLanguageId {
            case LanguageId.eng: return "Enter your account email address"
            case LanguageId.kor: return "이메일 주소를 입력하십시오."
            default: fatalError()}
        }()
        self.msgMailModified = {
            switch currentLanguageId {
            case LanguageId.eng: return "Your email address has been modified.\nPlease confirm Your new email."
            case LanguageId.kor: return "메일주소가 변경되었습니다.\n변경된 메일계정을 확인해 주세요."
            default: fatalError()}
        }()
        self.msgMailNotConfirmedYet = {
            switch currentLanguageId {
            case LanguageId.eng: return "Your email not confirmed yet. \nPleas confirm Your email."
            case LanguageId.kor: return "계정이 아직 확인되지 않았습니다.\n메일계정을 확인해 주세요."
            default: fatalError()}
        }()
        self.msgMailSendAgainComplete = {
            switch currentLanguageId {
            case LanguageId.eng: return "Account email has been resent.\nPleas confirm Your email."
            case LanguageId.kor: return "계정 확인 메일이 다시 보내졌습니다.\n메일계정을 확인해 주세요."
            default: fatalError()}
        }()
        func _msgMailSendValidCode(_ email: String) -> String {
            switch currentLanguageId {
            case LanguageId.eng: return "Email an account verification code to \n\(email)"
            case LanguageId.kor: return "이메일로 계정 인증 코드 발송하기 \n\(email)"
            default: fatalError()}
        }
        self.msgMailSendValidCode = _msgMailSendValidCode
        self.msgMismatchConfirmPassword = {
            switch currentLanguageId {
            case LanguageId.eng: return "Those password didn't match. Try again"
            case LanguageId.kor: return "패스워드가 일치하지 않습니다."
            default: fatalError()}
        }()
        self.msgNetworkFailure = {
            switch currentLanguageId {
            case LanguageId.eng: return "Unable to access the server.\n\nWant to try again?"
            case LanguageId.kor: return "서버와의 통신이 원활하지 않습니다.\n\n다시 시도하시겠습니다?"
            default: fatalError()}
        }()
        self.msgShortPassword = {
            switch currentLanguageId {
            case LanguageId.eng: return "Use 8 characters or more"
            case LanguageId.kor: return "패스워드가 8자리이상 입력되어야 합니다."
            default: fatalError()}
        }()
        self.msgUnauthDuplicatedEmail = {
            switch currentLanguageId {
            case LanguageId.eng: return "That mail address is already taken. Try another"
            case LanguageId.kor: return "이미 사용중인 메일주소 입니다. 다르게 시도해보세요."
            default: fatalError()}
        }()
        self.msgUnauthInvalidEmail = {
            switch currentLanguageId {
            case LanguageId.eng: return "Couldn't find your Account"
            case LanguageId.kor: return "일치하는 메일주소를 찾을 수 없습니다."
            default: fatalError()}
        }()
        self.msgUnauthInvalidPassword = {
            switch currentLanguageId {
            case LanguageId.eng: return "Wrong password.\nTry again or click Lost account."
            case LanguageId.kor: return "패스워드가 잘못 입력되었습니다.\n다시 시도하거나 비밀번호변경을 클릭하세요."
            default: fatalError()}
        }()
        self.msgUnauthInvalidUser = {
            switch currentLanguageId {
            case LanguageId.eng: return "You have tried to access inactive account.\nPlease try another email."
            case LanguageId.kor: return "사용이 정지된 계정으로 접근하셨습니다.\n다른 이메일로 시도해주세요."
            default: fatalError()}
        }()
        self.msgValidCodeEnter = {
            switch currentLanguageId {
            case LanguageId.eng: return "Enter the account verification code you received"
            case LanguageId.kor: return "보내드린 계정 인증 코드를 입력하세요."
            default: fatalError()}
        }()
        
        // MARK: Calendar
        
        self.calendarHeaderDateFormat = {
            switch currentLanguageId {
            case LanguageId.eng: return "MMMM YYYY"
            case LanguageId.kor: return "MM월 YYYY"
            default: fatalError("")}
        }()
        func _getLogGroupSection(monthNumber: Int, dayNumber: Int) -> String {
            switch currentLanguageId {
            case LanguageId.eng: return "\(dayNumber) \(LangHelper.getEngNameOfMonth(monthNumber: monthNumber))"
            case LanguageId.kor: return "\(dayNumber)일 \(monthNumber)월"
            default: fatalError()}
        }
        self.getLogGroupSection = _getLogGroupSection
    }
}

struct LangHelper {
    static func getLanguageId(alpha2: String) -> Int {
        switch alpha2 {
        case "en": return LanguageId.eng
        case "kr": return LanguageId.kor
        case "jp": return LanguageId.jpn
        default: return LanguageId.eng
        }
    }
    
    static func getLanguageName(_ id: Int) -> String {
        switch id {
        case 30: return "English"
        case 35: return "한글"
        case 34: return "日本語"
        default: fatalError()}
    }
    
    static func getEngNameOfMonth(monthNumber: Int) -> String {
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
        default: fatalError()}
    }
    
    static func getEngNameOfMM(monthNumber: Int) -> String {
        switch monthNumber {
        case 1: return "Jan"
        case 2: return "Feb"
        case 3: return "Mar"
        case 4: return "Apr"
        case 5: return "May"
        case 6: return "Jun"
        case 7: return "Jul"
        case 8: return "Aug"
        case 9: return "Sep"
        case 10: return "Oct"
        case 11: return "Nov"
        case 12: return "Dec"
        default: fatalError()}
    }
    
    static func getKorNameOfMonth(monthNumber: Int?, engMMM: String?) -> String {
        if monthNumber != nil {
            switch monthNumber {
            case 1: return "1월"
            case 2: return "2월"
            case 3: return "3월"
            case 4: return "4월"
            case 5: return "5월"
            case 6: return "6월"
            case 7: return "7월"
            case 8: return "8월"
            case 9: return "9월"
            case 10: return "10월"
            case 11: return "11월"
            case 12: return "12월"
            default: fatalError()}
        }
        switch engMMM {
        case "Jan": return "1월"
        case "Feb": return "2월"
        case "Mar": return "3월"
        case "Apr": return "4월"
        case "May": return "5월"
        case "Jun": return "6월"
        case "Jul": return "7월"
        case "Aug": return "8월"
        case "Sep": return "9월"
        case "Oct": return "10월"
        case "Nov": return "11월"
        case "Dec": return "12월"
        default: fatalError()}
    }
}
