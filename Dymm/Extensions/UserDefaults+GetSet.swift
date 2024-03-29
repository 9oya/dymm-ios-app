//
//  UserDefaultsExtention.swift
//  Dymm
//
//  Created by eunsang lee on 15/05/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum UserDefaultsKeys: String {
        case isSignIn
        case isSignInChanged
        case isEmailConfirmed
        case isFreeTrial
        case isPurchased
        case isCreateNewLog
        case accessToken
        case refreshToken
        case avatarId
        case currentLanguageId
    }
    
    // MARK: - Setters
    
    func setIsSignIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isSignIn.rawValue)
        synchronize()
    }
    
    func setIsSignInChanged(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isSignInChanged.rawValue)
        synchronize()
    }
    
    func setIsEmailConfirmed(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isEmailConfirmed.rawValue)
        synchronize()
    }
    
    func setIsFreeTrial(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isFreeTrial.rawValue)
        synchronize()
    }
    
    func setIsPurchased(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isPurchased.rawValue)
        synchronize()
    }
    
    func setIsCreateNewLog(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isCreateNewLog.rawValue)
        synchronize()
    }
    
    func setAccessToken(value: String) {
        set(value, forKey: UserDefaultsKeys.accessToken.rawValue)
        synchronize()
    }
    
    func setRefreshToken(value: String) {
        set(value, forKey: UserDefaultsKeys.refreshToken.rawValue)
        synchronize()
    }
    
    func setAvatarId(value: Int) {
        set(value, forKey: UserDefaultsKeys.avatarId.rawValue)
        synchronize()
    }
    
    func setCurrentLanguageId(value: Int) {
        set(value, forKey: UserDefaultsKeys.currentLanguageId.rawValue)
        synchronize()
    }
    
    // MARK: - Getters
    
    func isSignIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isSignIn.rawValue)
    }
    
    func isSignInChanged() -> Bool {
        return bool(forKey: UserDefaultsKeys.isSignInChanged.rawValue)
    }
    
    func isEmailConfirmed() -> Bool {
        return bool(forKey: UserDefaultsKeys.isEmailConfirmed.rawValue)
    }
    
    func isFreeTrial() -> Bool {
        return bool(forKey: UserDefaultsKeys.isFreeTrial.rawValue)
    }
    
    func isPurchased() -> Bool {
        return bool(forKey: UserDefaultsKeys.isPurchased.rawValue)
    }
    
    func isCreateNewLog() -> Bool {
        return bool(forKey: UserDefaultsKeys.isCreateNewLog.rawValue)
    }
    
    func getAccessToken() -> String? {
        guard let token = string(forKey: UserDefaultsKeys.accessToken.rawValue) else {
            return nil
        }
        return token
    }
    
    func getRefreshToken() -> String? {
        guard let token = string(forKey: UserDefaultsKeys.refreshToken.rawValue) else {
            return nil
        }
        return token
    }
    
    func getAvatarId() -> Int? {
        return integer(forKey: UserDefaultsKeys.avatarId.rawValue)
    }
    
    func getCurrentLanguageId() -> Int? {
        let currentLanguageId = integer(forKey: UserDefaultsKeys.currentLanguageId.rawValue)
        if currentLanguageId <= 0 {
            guard let regionCode = Locale.current.regionCode else {
                return LangHelper.getLanguageIdByRegion(alpha2: "EN")
            }
            return LangHelper.getLanguageIdByRegion(alpha2: regionCode)
        }
        return currentLanguageId
    }
}
