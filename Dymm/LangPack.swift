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
    
    var titleAccountInvalid: String!
    var titleAge: String!
    var titleAgeGroup: String!
    var titleAll: String!
    var titleAvgMoodScoreWeek: String!
    var titleAvgMoodScoreMonth: String!
    var titleBackHome: String!
    var titleCamera: String!
    var titleCancel: String!
    var titleChooseColor: String!
    var titleChangeProfileImg: String!
    var titleClose: String!
    var titleComplete: String!
    var titleMoodScore: String!
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
    var titleEmailValidCode: String!
    var titleEndDate: String!
    var titleFirstName: String!
    var titleFold: String!
    var titleForgotPassword: String!
    var titleForgotPasswordAlert: String!
    var titleFreeTrial: String!
    var titleGender: String!
    var titleGuest: String!
    var titleIncorrectEmailCode: String!
    var titleIncorrectOldPassword: String!
    var titleIntro: String!
    var titleLastMonth: String!
    var titleLastName: String!
    var titleLastWeek: String!
    var titleLogGroups: [String]!
    var titleMembership: String!
    var titleMyAvtCond: String!
    var titleMyCondScore: String!
    var titleNo: String!
    var titleNote: String!
    var titleNotes: String!
    var titleFeedback: String!
    var titlePassword: String!
    var titlePasswordChange: String!
    var titlePasswordChangeCompl: String!
    var titlePasswordConfirm: String!
    var titlePasswordNew: String!
    var titlePasswordOld: String!
    var titlePhoneNum: String!
    var titlePhotolibrary: String!
    var titlePrivaryPolocy: String!
    var titlePurchaseCompl: String!
    var titlePurchaseFail: String!
    var titlePurchaseDisable: String!
    var titlePremiumMember: String!
    var titlePremiumMemberShip: String!
    var titleProfile: String!
    var titleRanking: String!
    var titleReLifespanAndAge: String!
    var titleRestoreCompl: String!
    var titleRestoreProduct: String!
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
    var titleStartingPoint: String!
    var titleStay: String!
    var titleSubmit: String!
    var titleSubscribe: String!
    var titleTerms: String!
    var titleToday: String!
    var titleThisMonth: String!
    var titleThisWeek: String!
    var titleVerifCode: String!
    var titleVerifMail: String!
    var titleWeekdays: [String]!
    var titleYes: String!
    
    var msgAccountInvalid: String!
    var msgAvgScoreDownMonth: ((String) -> String)!
    var msgAvgScoreDownWeek: String!
    var msgAvgScoreEqualWeek: String!
    var msgAvgScoreEqualMonth: ((String) -> String)!
    var msgAvgScoreUpWeek: String!
    var msgAvgScoreUpMonth: ((String) -> String)!
    var msgCameraDisable: String!
    var msgChangePasswordCompl: String!
    var msgCondScoreNone: String!
    var msgDateOfBirthNone: String!
    var msgDiarySelect: String!
    var msgDuplicatedEmail: String!
    var msgEmptyEmail: String!
    var msgEmptyName: String!
    var msgEmptyPassword: String!
    var msgFloatingInvalidEmail: String!
    var msgFloatingInvalidPassword: String!
    var msgFloatingMismatchConfirmPassword: String!
    var msgFreeTrialExpired: String!
    var msgInactiveFood: String!
    var msgInvalidEmail: String!
    var msgLifeSpan: String!
    var msgLogComplete: String!
    var msgMailEnter: String!
    var msgMailModified: String!
    var msgMailNotConfirmed: String!
    var msgMailSendAgainComplete: String!
    var msgMailSendValidCode: ((String) -> String)!
    var msgMismatchConfirmPassword: String!
    var msgNetworkFailure: String!
    var msgOpinionCompl: String!
    var msgPremiumRestored: String!
    var msgPriceDesc: String!
    var msgProductDesc1: String!
    var msgProductDesc2_1: String!
    var msgProductDesc2_2: String!
    var msgProductPurchased: String!
    var msgPurchaseCompl: String!
    var msgPurchaseDisable: String!
    var msgRestoreCompl: String!
    var msgShortPassword: String!
    var msgSignUpYet: String!
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
    func getCondScoreName(_ key: Float) -> String {
        var idx = 0
        if key < 1 {
            idx = 0
        } else if key < 2.5 {
            idx = 1
        } else if key < 4.5 {
            idx = 2
        } else if key < 6.5 {
            idx = 3
        } else if key < 8.5 {
            idx = 4
        } else {
            idx = 5
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
        
        self.titleAccountInvalid = {
            switch currentLanguageId {
            case LanguageId.eng: return "\u{26A0}Unauthorized account"
            case LanguageId.kor: return "\u{26A0}권한이 없는 계정"
            case LanguageId.jpn: return ""
            default: fatalError()}
        }()
        self.titleAge = {
            switch currentLanguageId {
            case LanguageId.eng: return "AGE"
            case LanguageId.kor: return "나이"
            case LanguageId.jpn: return ""
            default: fatalError()}
        }()
        self.titleAgeGroup = {
            switch currentLanguageId {
            case LanguageId.eng: return "Age Group"
            case LanguageId.kor: return "나이 그룹"
            case LanguageId.jpn: return ""
            default: fatalError()}
        }()
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
        self.titleAvgMoodScoreMonth = {
            switch currentLanguageId {
            case LanguageId.eng: return "My Monthly Mood Score"
            case LanguageId.kor: return "나의 월간 기분점수"
            default: fatalError()}
        }()
        self.titleAvgMoodScoreWeek = {
            switch currentLanguageId {
            case LanguageId.eng: return "My Weekly Mood Score"
            case LanguageId.kor: return "나의 주간 기분점수"
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
        self.titleChooseColor = {
            switch currentLanguageId {
            case LanguageId.eng: return "Choose color"
            case LanguageId.kor: return "색상 선택"
            default: fatalError()}
        }()
        self.titleChangeProfileImg = {
            switch currentLanguageId {
            case LanguageId.eng: return "Change profile image"
            case LanguageId.kor: return "프로필 이미지를 변경합니다"
            default: fatalError()}
        }()
        self.titleClose = {
            switch currentLanguageId {
            case LanguageId.eng: return "Close"
            case LanguageId.kor: return "닫기"
            default: fatalError()}
        }()
        self.titleComplete = {
            switch currentLanguageId {
            case LanguageId.eng: return "Complete!"
            case LanguageId.kor: return "전송완료!"
            default: fatalError()}
        }()
        self.titleMoodScore = {
            switch currentLanguageId {
            case LanguageId.eng: return "Mood score"
            case LanguageId.kor: return "기분점수"
            default: fatalError()}
        }()
        self.titleCondScores = {
            switch currentLanguageId {
            case LanguageId.eng: return ["", "AWFUL", "BAD", "SOSO", "GOOD", "EXCELLENT!"]
            case LanguageId.kor: return ["", "최악", "나쁨", "보통", "좋음", "최고!"]
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
            case LanguageId.eng: return "Lifestyle"
            case LanguageId.kor: return "라이프스타일"
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
            case LanguageId.kor: return "일치하는 계정을 찾았어요."
            default: fatalError()}
        }()
        self.titleEmailNotFound = {
            switch currentLanguageId {
            case LanguageId.eng: return "\u{26A0}Email address not found."
            case LanguageId.kor: return "\u{26A0}메일주소를 찾을 수 없습니다."
            default: fatalError()}
        }()
        self.titleEmailValidCode = {
            switch currentLanguageId {
            case LanguageId.eng: return "A verification code has been sent."
            case LanguageId.kor: return "인증 코드를 발송했습니다."
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
        self.titleFold = {
            switch currentLanguageId {
            case LanguageId.eng: return "Fold"
            case LanguageId.kor: return "접기"
            default: fatalError()}
        }()
        self.titleForgotPassword = {
            switch currentLanguageId {
            case LanguageId.eng: return "Forgot password?"
            case LanguageId.kor: return "비밀번호를 잊으셨나요?"
            default: fatalError()}
        }()
        self.titleForgotPasswordAlert = {
            switch currentLanguageId {
            case LanguageId.eng: return "I forgot my Dymm password"
            case LanguageId.kor: return "딤 비밀번호를 분실했어요."
            default: fatalError()}
        }()
        self.titleFreeTrial = {
            switch currentLanguageId {
            case LanguageId.eng: return "Free trial"
            case LanguageId.kor: return "무료 체험"
            default: fatalError()}
        }()
        self.titleGender = {
            switch currentLanguageId {
            case LanguageId.eng: return "GENDER"
            case LanguageId.kor: return "성별"
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
        self.titleMembership = {
            switch currentLanguageId {
            case LanguageId.eng: return "Membership"
            case LanguageId.kor: return "멤버쉽"
            default: fatalError()}
        }()
        self.titleMyAvtCond = {
            switch currentLanguageId {
            case LanguageId.eng: return "My Disease History"
            case LanguageId.kor: return "나의 질병 히스토리"
            default: fatalError()}
        }()
        self.titleMyCondScore = {
            switch currentLanguageId {
            case LanguageId.eng: return "MY MOOD SCORE"
            case LanguageId.kor: return "나의 평균 기분점수"
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
        self.titleFeedback = {
            switch currentLanguageId {
            case LanguageId.eng: return "Send your feedback to Dymm."
            case LanguageId.kor: return "딤에게 피드백을 보내주세요."
            default: fatalError()}
        }()
        self.titlePassword = {
            switch currentLanguageId {
            case LanguageId.eng: return "Password"
            case LanguageId.kor: return "비밀번호"
            default: fatalError()}
        }()
        self.titlePasswordChange = {
            switch currentLanguageId {
            case LanguageId.eng: return "Change Password"
            case LanguageId.kor: return "비밀번호 변경"
            default: fatalError()}
        }()
        self.titlePasswordChangeCompl = {
            switch currentLanguageId {
            case LanguageId.eng: return "Password Change Complete!"
            case LanguageId.kor: return "비밀번호 변경이 완료되었습니다!"
            default: fatalError()}
        }()
        self.titlePasswordConfirm = {
            switch currentLanguageId {
            case LanguageId.eng: return "Confirm Password"
            case LanguageId.kor: return "비밀번호 확인"
            default: fatalError()}
        }()
        self.titlePasswordNew = {
            switch currentLanguageId {
            case LanguageId.eng: return "New Password"
            case LanguageId.kor: return "새 비밀번호"
            default: fatalError()}
        }()
        self.titlePasswordOld = {
            switch currentLanguageId {
            case LanguageId.eng: return "Old Password"
            case LanguageId.kor: return "이전 비밀번호"
            default: fatalError()}
        }()
        self.titlePhoneNum = {
            switch currentLanguageId {
            case LanguageId.eng: return "Phone number"
            case LanguageId.kor: return "전화번호"
            default: fatalError()}
        }()
        self.titlePhotolibrary = {
            switch currentLanguageId {
            case LanguageId.eng: return "Photo library"
            case LanguageId.kor: return "사진 앨범"
            default: fatalError()}
        }()
        self.titlePrivaryPolocy = {
            switch currentLanguageId {
            case LanguageId.eng: return "Privacy Policy"
            case LanguageId.kor: return "개인정보처리방침"
            default: fatalError()}
        }()
        self.titlePurchaseCompl = {
            switch currentLanguageId {
            case LanguageId.eng: return "Purchase complete"
            case LanguageId.kor: return "구매 완료"
            default: fatalError()}
        }()
        self.titlePurchaseFail = {
            switch currentLanguageId {
            case LanguageId.eng: return "Purchase failure!"
            case LanguageId.kor: return "구매 실패!"
            default: fatalError()}
        }()
        self.titlePurchaseDisable = {
            switch currentLanguageId {
            case LanguageId.eng: return "Oops!"
            case LanguageId.kor: return "Oops!"
            default: fatalError()}
        }()
        self.titlePremiumMember = {
            switch currentLanguageId {
            case LanguageId.eng: return "Premium Member"
            case LanguageId.kor: return "프리미엄 멤버"
            default: fatalError()}
        }()
        self.titlePremiumMemberShip = {
            switch currentLanguageId {
            case LanguageId.eng: return "Dymm Premium Membership"
            case LanguageId.kor: return "딤 프리미엄 멤버쉽"
            default: fatalError()}
        }()
        self.titleProfile = {
            switch currentLanguageId {
            case LanguageId.eng: return "Profile"
            case LanguageId.kor: return "프로필"
            default: fatalError()}
        }()
        self.titleRanking = {
            switch currentLanguageId {
            case LanguageId.eng: return "Ranking"
            case LanguageId.kor: return "순위"
            default: fatalError()}
        }()
        self.titleReLifespanAndAge = {
            switch currentLanguageId {
            case LanguageId.eng: return "Health Points"
            case LanguageId.kor: return "생명력"
            default: fatalError()}
        }()
        self.titleRestoreCompl = {
            switch currentLanguageId {
            case LanguageId.eng: return "Restore Complete"
            case LanguageId.kor: return "복원 완료"
            default: fatalError()}
        }()
        self.titleRestoreProduct = {
            switch currentLanguageId {
            case LanguageId.eng: return "Restore Membership"
            case LanguageId.kor: return "멤버쉽 복원하기"
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
            case LanguageId.eng: return "Send it again"
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
        self.titleStartingPoint = {
            switch currentLanguageId {
            case LanguageId.eng: return "Range of Ranking"
            case LanguageId.kor: return "랭킹 범위"
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
        self.titleTerms = {
            switch currentLanguageId {
            case LanguageId.eng: return "Terms and Conditions"
            case LanguageId.kor: return "서비스이용약관"
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
        self.titleVerifMail = {
            switch currentLanguageId {
            case LanguageId.eng: return "Verify your email address."
            case LanguageId.kor: return "이메일 주소를 확인해 주세요."
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
        
        self.msgAccountInvalid = {
            switch currentLanguageId {
            case LanguageId.eng: return "Try sign-in again. If you get the same error contact Dymm customer service."
            case LanguageId.kor: return "다시 로그인을 시도해 보세요. 만일 같은 오류가 발생한다면 딤 고객센터에 문의해 주세요."
            default: fatalError()}
        }()
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
        self.msgCondScoreNone = {
            switch currentLanguageId {
            case LanguageId.eng: return "I can't find your mood score log."
            case LanguageId.kor: return "현재 당신의 기분점수 로그를 찾을 수 없어요."
            default: fatalError()}
        }()
        self.msgDateOfBirthNone = {
            switch currentLanguageId {
            case LanguageId.eng: return "Please select your date of birth on the Profile tab."
            case LanguageId.kor: return "프로필 탭에서 당신의 생년월일을 선택해주세요."
            default: fatalError()}
        }()
        self.msgDiarySelect = {
            switch currentLanguageId {
            case LanguageId.eng: return "Select a calendar date or a below group."
            case LanguageId.kor: return "달력에 일자또는 아래 그룹중에 선택해 주세요."
            default: fatalError()}
        }()
        self.msgDuplicatedEmail = {
            switch currentLanguageId {
            case LanguageId.eng: return "That email address is already in use. Please try another email."
            case LanguageId.kor: return "이미 사용중인 이메일 주소 입니다. 다른 이메일을 시도해 보세요."
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
        self.msgFreeTrialExpired = {
            switch currentLanguageId {
            case LanguageId.eng: return "Your free trial has expired. Please renew your membership."
            case LanguageId.kor: return "무료 체험이 만료되었습니다. 멤버쉽을 갱신해 주세요."
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
            case LanguageId.kor: return "사용이 정지된 푸드에 접근을 시도하였습니다."
            default: fatalError()}
        }()
        self.msgLifeSpan = {
            switch currentLanguageId {
            case LanguageId.eng: return "I predicted your remaining lifespan :)"
            case LanguageId.kor: return "당신의 남은 수명을 예측했어요 :)"
            default: fatalError()}
        }()
        self.msgLogComplete = {
            switch currentLanguageId {
            case LanguageId.eng: return "Successfully recorded!\n\nWant to back Home?"
            case LanguageId.kor: return "성공적으로 기록되었습니다!\n\n홈으로 이동하시겠습니까?"
            default: fatalError()}
        }()
        self.msgMailEnter = {
            switch currentLanguageId {
            case LanguageId.eng: return "Enter your account email address"
            case LanguageId.kor: return "이메일 주소를 입력해 주세요."
            default: fatalError()}
        }()
        self.msgMailModified = {
            switch currentLanguageId {
            case LanguageId.eng: return "Your email address has changed.\nPlease verify your new email."
            case LanguageId.kor: return "메일주소가 변경되었습니다.\n새 메일을 확인해 주세요."
            default: fatalError()}
        }()
        self.msgMailNotConfirmed = {
            switch currentLanguageId {
            case LanguageId.eng: return "Your email address is not verified. \nPlease verify your email."
            case LanguageId.kor: return "메일주소가 검증되지 않았습니다.\n메일을 확인해 주세요."
            default: fatalError()}
        }()
        self.msgMailSendAgainComplete = {
            switch currentLanguageId {
            case LanguageId.eng: return "Your account verification email has been resent.\nPlease verify your new email."
            case LanguageId.kor: return "계정 확인 메일이 다시 보내졌습니다.\n새 메일을 확인해 주세요."
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
        self.msgOpinionCompl = {
            switch currentLanguageId {
            case LanguageId.eng: return "Thank you for your precious opinion."
            case LanguageId.kor: return "소중한 의견 감사드립니다."
            default: fatalError()}
        }()
        self.msgPremiumRestored = {
            switch currentLanguageId {
            case LanguageId.eng: return "Premium Membership Restored."
            case LanguageId.kor: return "프리미엄 맴버쉽이 복원되었습니다."
            default: fatalError()}
        }()
        self.msgPriceDesc = {
            switch currentLanguageId {
            case LanguageId.eng: return "+1 Month Free Trial"
            case LanguageId.kor: return "+1 달 무료 체험"
            default: fatalError()}
        }()
        self.msgProductDesc1 = {
            switch currentLanguageId {
            case LanguageId.eng: return """
                Your membership starts as soon as you set up payment and subscribe with iTunes. Your monthly charge will occur on the last day of the current billing period.
                We’ll renew your membership for you (unless auto-renew is turned off 24 hours before the end of your billing cycle). Once you’re a member, you can manage your subscription or turn off auto-renewal under Account Settings.
            """
            case LanguageId.kor: return """
                결제를 설정하고 iTunes로 구독하는 즉시 멤버십을 이용할 수 있습니다. 월별 요금은 현재 결제 주기의 마지막 날에 청구됩니다.
                결제 주기가 끝나기 24시간 전에 자동 갱신을 사용 중지하지 않는 한 멤버십이 자동으로 갱신됩니다. 회원은 계정 설정에서 구독을 관리하거나 자동 갱신을 사용 중지할 수 있습니다.
            """
            default: fatalError()}
        }()
        self.msgProductDesc2_1 = {
            switch currentLanguageId {
            case LanguageId.eng: return """
                * After 7 days of free trial, service usage will be limited.
                * You can still browse your diary.
                
                * Get your membership and enjoy all the features. We will always try to reward you with the best service.
                
                Dymm ©
            """
            case LanguageId.kor: return """
                * 무료체험기간 7일이 종료 후 서비스이용이 제한됩니다.
                * 일기장은 여전히 이용가능합니다.
                
                * 멤버쉽을 등록하고 모든 서비스를 자유롭게 이용하세요. 최고의 서비스로 보답하도록 항상 노력하겠습니다.

                딤 ©
            """
            default: fatalError()}
        }()
        self.msgProductDesc2_2 = {
            switch currentLanguageId {
            case LanguageId.eng: return """
                * You are currently subscribed to a premium membership.
                * All the features and services of Dymm are available.
                
                Dymm ©
            """
            case LanguageId.kor: return """
                * 현재 프리미엄 멤버쉽에 가입되어 있습니다.
                * 딤의 모든 기능과 서비스 이용이 가능합니다.

                딤 ©
            """
            default: fatalError()}
        }()
        self.msgProductPurchased = {
            switch currentLanguageId {
            case LanguageId.eng: return "You are now a premium member!"
            case LanguageId.kor: return "프리미엄 멤버가 되었습니다!"
            default: fatalError()}
        }()
        self.msgPurchaseCompl = {
            switch currentLanguageId {
            case LanguageId.eng: return "You've successfully purchased!"
            case LanguageId.kor: return "성공적으로 구매하셨습니다!"
            default: fatalError()}
        }()
        self.msgPurchaseDisable = {
            switch currentLanguageId {
            case LanguageId.eng: return "Purchases aren't available on your device!"
            case LanguageId.kor: return "해당 기기에서 구매를 사용을 할 수 없습니다!"
            default: fatalError()}
        }()
        self.msgRestoreCompl = {
            switch currentLanguageId {
            case LanguageId.eng: return "You've successfully restored your purchase!"
            case LanguageId.kor: return "구매를 성공적으로 복원했습니다!"
            default: fatalError()}
        }()
        self.msgShortPassword = {
            switch currentLanguageId {
            case LanguageId.eng: return "Use 8 characters or more"
            case LanguageId.kor: return "패스워드가 8자리이상 입력되어야 합니다."
            default: fatalError()}
        }()
        self.msgSignUpYet = {
            switch currentLanguageId {
            case LanguageId.eng: return "I can't find an account logged in."
            case LanguageId.kor: return "로그인된 계정을 찾지 못했어요."
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
//        TODO: case "jp": return LanguageId.jpn
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
    
    static func getStartingPickName(key: Int) -> String {
        switch key {
        case 1: return "#1 ~ "
        case 2: return "#100 ~ "
        case 3: return "#500 ~ "
        case 4: return "#1000 ~ "
        default: fatalError()}
    }
    
    static func getAgeGroupEngPickName(key: Int) -> String {
        switch key {
        case 1: return "All Ages"
        case 2: return "   ~ 30"
        case 3: return "30 ~ 50"
        case 4: return "50 ~ 70"
        case 5: return "70 ~   "
        default: fatalError()}
    }
    
    static func getAgeGroupKorPickName(key: Int) -> String {
        switch key {
        case 1: return "모든 나이"
        case 2: return "   ~ 30"
        case 3: return "30 ~ 50"
        case 4: return "50 ~ 70"
        case 5: return "70 ~   "
        default: fatalError()}
    }
}
