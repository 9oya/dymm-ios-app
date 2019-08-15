//
//  Service.swift
//  Flava
//
//  Created by eunsang lee on 23/06/2019.
//  Copyright © 2019 Future Planet. All rights reserved.
//

import Foundation
import Alamofire

struct Service {
    var lang: LangPack!
    let decoder = JSONDecoder()
   
    init(lang: LangPack) {
        self.lang = lang
    }
    
    func badRequest(_ responseData: Data) {
        guard let decodedData = try? self.decoder.decode(BadRequest.self, from: responseData) else {
            fatalError("Decode \(BadRequest.self) failed")
        }
        fatalError("\(decodedData.message)")
    }
    
    func upexpectedResponse(_ statusCode: Int, _ data: Data, _ name: String) {
        print("Request \(name) failed \nStatus Code: \(statusCode)")
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            fatalError("Decode error message failed")
        }
        fatalError(String(describing: json))
    }
    
    func convertLogGroupsIntoTwoDimLogGroupSectArr(_ logGroups: [BaseModel.LogGroup]) -> [[CustomModel.LogGroupSection]] {
        var logGroupSectArr = [CustomModel.LogGroupSection]()
        for logGroup in logGroups {
            logGroupSectArr.append(CustomModel.LogGroupSection(dayOfYear: logGroup.day_of_year, logGroup: logGroup))
        }
        var groupedLogGroupSectArr = Dictionary(grouping: logGroupSectArr) { (element) -> Int in
            return element.dayOfYear
        }
        var sortedLogGroupSectTwoDimArr = [[CustomModel.LogGroupSection]]()
        let sortedKeys = groupedLogGroupSectArr.keys.sorted(by: >)
        sortedKeys.forEach({ (key) in
            sortedLogGroupSectTwoDimArr.append(groupedLogGroupSectArr[key]!)
        })
        return sortedLogGroupSectTwoDimArr
    }
    
    func convertSortedLogGroupSectTwoDimArrIntoLogGroupDictTwoDimArr(_ sortedLogGroupSectTwoDimArr: [[CustomModel.LogGroupSection]]) -> [Int:[Int:BaseModel.LogGroup]] {
        var logGroupDictTwoDimArr = [Int:[Int:BaseModel.LogGroup]]()
        for logGroupSectArr in sortedLogGroupSectTwoDimArr {
            logGroupDictTwoDimArr[logGroupSectArr[0].dayOfYear] = [:]
        }
        for logGroupSectArr in sortedLogGroupSectTwoDimArr {
            for logGroupSect in logGroupSectArr {
                logGroupDictTwoDimArr[logGroupSectArr[0].dayOfYear]![logGroupSect.logGroup.group_type] = logGroupSect.logGroup
            }
        }
        return logGroupDictTwoDimArr
    }
    
    func forbiddenRequest(_ responseData: Data, _ popoverAlert: @escaping (_ message: String) -> Void, _ tokenRefreshCompletion: ((_ message: String, _ pattern: Int) -> Void)? = nil) -> Int {
        guard let decodedData = try? decoder.decode(Forbidden.self, from: responseData) else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError("Decode \(Forbidden.self) data failed")
        }
        switch decodedData.pattern {
        case ForbiddenType.tokenInvalid:
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError(decodedData.message)
        case ForbiddenType.tokenExpr:
            self.refreshAccessToken(popoverAlert) {
                tokenRefreshCompletion!(decodedData.message, decodedData.pattern)
            }
            return ForbiddenType.tokenExpr
        case ForbiddenType.tokenNeedFresh:
            return ForbiddenType.tokenNeedFresh
        default: fatalError("Unexpected forbidden pattern")}
    }
    
    func refreshAccessToken(_ popoverAlert: @escaping (_ message: String) -> Void, _ completion: @escaping () -> Void) {
        guard let refreshToken = UserDefaults.standard.getRefreshToken() else {
            print("Load UserDefaults.standard.getRefreshToken() failed")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(refreshToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/token/refresh", method: .post, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<String>.self, from: responseData) else {
                        UserDefaults.standard.setIsSignIn(value: false)
                        fatalError("Decode \(Ok<String>.self) data failed")
                    }
                    UserDefaults.standard.setAccessToken(value: decodedData.data!)
                    completion()
                case 400:
                    self.badRequest(responseData)
                default:
                    self.upexpectedResponse(statusCode, responseData, "refreshAccessToken()")
                    return
                }
        }
    }
    
    func fetchBanners(popoverAlert: @escaping (_ message: String) -> Void ,completion: @escaping (_ banners: [BaseModel.Banner]) -> Void) {
        Alamofire.request("\(URI.host)\(URI.banner)")
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? JSONDecoder().decode(Ok<[BaseModel.Banner]>.self, from: responseData) else {
                        fatalError()
                    }
                    guard let data = decodedData.data else {
                        fatalError()
                    }
                    completion(data)
                case 400:
                    self.badRequest(responseData)
                default:
                    self.upexpectedResponse(statusCode, responseData, "fetchTagSets()")
                    return
                }
        }
    }
    
    func fetchTagSets(tagId: Int, sortType:String, popoverAlert: @escaping (_ message: String) -> Void ,completion: @escaping (_ tagSet: CustomModel.TagSet) -> Void) {
        Alamofire.request("\(URI.host)\(URI.tag)/\(tagId)/set/\(sortType)")
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? JSONDecoder().decode(Ok<CustomModel.TagSet>.self, from: responseData) else {
                        fatalError()
                    }
                    guard let data = decodedData.data else {
                        fatalError()
                    }
                    completion(data)
                case 400:
                    self.badRequest(responseData)
                default:
                    self.upexpectedResponse(statusCode, responseData, "fetchTagSets()")
                    return
                }
        }
    }
    
    func authExistingAvatar(_ parameters: Parameters, unauthorized: @escaping (_ pattern: Int) -> Void, popoverAlert: @escaping (_ message: String) -> Void, completion: @escaping (_ auth: CustomModel.Auth) -> Void) {
        Alamofire.request("\(URI.host)\(URI.avatar)", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<CustomModel.Auth>.self, from: responseData) else {
                        fatalError("jsonDecoder.decode(Ok<UserModel.Auth>.self, from: responseData)")
                    }
                    guard let auth = decodedData.data else {
                        fatalError("decodedData.data")
                    }
                    completion(auth)
                case 400:
                    self.badRequest(responseData)
                case 401:
                    guard let decodedData = try? self.decoder.decode(Unauthorized.self, from: responseData) else {
                        fatalError("jsonDecoder.decode(Unauthorized.self, from: responseData)")
                    }
                    unauthorized(decodedData.pattern)
                default:
                    self.upexpectedResponse(statusCode, responseData, "authExistedAccount()")
                    return
                }
        }
    }
    
    func createNewAvatar(_ parameters: Parameters, unauthorized: @escaping (_ pattern: Int) -> Void, popoverAlert: @escaping (_ message: String) -> Void, completion: @escaping (_ auth: CustomModel.Auth) -> Void) {
        Alamofire.request("\(URI.host)\(URI.avatar)/create", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<CustomModel.Auth>.self, from: responseData) else {
                        fatalError()
                    }
                    guard let auth = decodedData.data else {
                        fatalError()
                    }
                    completion(auth)
                case 400:
                    self.badRequest(responseData)
                case 401:
                    guard let decodedData = try? self.decoder.decode(Unauthorized.self, from: responseData) else {
                        fatalError()
                    }
                    unauthorized(decodedData.pattern)
                default:
                    self.upexpectedResponse(statusCode, responseData, "createNewAccount()")
                    return
                }
        }
    }
    
    func fetchProfile(popoverAlert: @escaping (_ message: String) -> Void, emailNotConfirmed: @escaping (_ email: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ avatarAndFacts: CustomModel.Profile) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError("UserDefaults.standard.getAccessToken()")
        }
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError("UserDefaults.standard.getAvatarId()")
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/\(avatarId)/profile", method: .get, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<CustomModel.Profile>.self, from: responseData) else {
                        fatalError("jsonDecoder.decode(Ok<UserModel.Profile>.self, from: responseData)")
                    }
                    guard let data = decodedData.data else {
                        fatalError("decodedData.data")
                    }
                    completion(data)
                case 400:
                    self.badRequest(responseData)
                case 401:
                    guard let decodedData = try? self.decoder.decode(Unauthorized.self, from: responseData) else {
                        fatalError("Decode \(Unauthorized.self) failed")
                    }
                    emailNotConfirmed(decodedData.message)
                    return
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.upexpectedResponse(statusCode, responseData, "fetchProfile()")
                    return
                }
        }
    }
    
    func fetchProfileTagSets(tagId: Int, isSelected: Bool, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ profileTagSet: CustomModel.ProfileTagSet) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        Alamofire.request("\(URI.host)\(URI.tag)/\(tagId)/set/match/\(isSelected)", method: .get, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<CustomModel.ProfileTagSet>.self, from: responseData) else {
                        fatalError()
                    }
                    guard let data = decodedData.data else {
                        fatalError()
                    }
                    completion(data)
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.upexpectedResponse(statusCode, responseData, "fetchSetOfFacts()")
                    return
                }
        }
    }
    
    func fetchAvatar(popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ data: BaseModel.Avatar) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/\(avatarId)", method: .get, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<BaseModel.Avatar>.self, from: responseData) else {
                        fatalError("jsonDecoder.decode(Ok<[UserModel.Avatar]>.self, from: responseData)")
                    }
                    guard let data = decodedData.data else {
                        fatalError("decodedData.data")
                    }
                    completion(data)
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.upexpectedResponse(statusCode, responseData, "validateUser()")
                    return
                }
        }
    }
    
    func fetchAvatarCondList(popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ data: [BaseModel.AvatarCond]) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/\(avatarId)/cond", method: .get, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<[BaseModel.AvatarCond]>.self, from: responseData) else {
                        fatalError("jsonDecoder.decode(Ok<[UserModel.Avatar]>.self, from: responseData)")
                    }
                    guard let data = decodedData.data else {
                        fatalError("decodedData.data")
                    }
                    completion(data)
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.upexpectedResponse(statusCode, responseData, "validateUser()")
                    return
                }
        }
    }
    
    func updateProfileTag(profile_tag_id: Int, new_tag_id: Int, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping () -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        Alamofire.request("\(URI.host)\(URI.profile)/\(profile_tag_id)/\(new_tag_id)", method: .put, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    completion()
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.upexpectedResponse(statusCode, responseData, "validateUser()")
                    return
                }
        }
    }
    
    func updateAvatarInfo(target: String, newInfoStr: String, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ firstName: String) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let params: Parameters = [
            "avatar_id": avatarId,
            "target": target,
            "new_info": newInfoStr
            ]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    completion(newInfoStr)
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.upexpectedResponse(statusCode, responseData, "fetchLogs()")
                    return
                }
        }
    }
    
    func fetchLogGroups(yearNumber: String, monthNumber: Int, weekOfYear: Int?, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping ([BaseModel.LogGroup]) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        var params = "\(avatarId)/\(yearNumber)/\(monthNumber)"
        if let weekOfYear = weekOfYear {
            params += "/\(weekOfYear)"
        }
        Alamofire.request("\(URI.host)\(URI.log)/group/\(params)", headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<[BaseModel.LogGroup]>.self, from: responseData) else {
                        fatalError()
                    }
                    guard let logGroups = decodedData.data else {
                        fatalError()
                    }
                    completion(logGroups)
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.upexpectedResponse(statusCode, responseData, "fetchLogGroups()")
                    return
                }
        }
    }
    
    func fetchGroupOfLogs(_ logGroupId: Int, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (CustomModel.GroupOfLogSet) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.log)/group/\(logGroupId)/tag-log", headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<CustomModel.GroupOfLogSet>.self, from: responseData) else {
                        fatalError()
                    }
                    guard let groupOfLogSet = decodedData.data else {
                        fatalError()
                    }
                    completion(groupOfLogSet)
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.upexpectedResponse(statusCode, responseData, "fetchLogs()")
                    return
                }
        }
    }
    
    func dispatchASingleLog(params: Parameters, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping () -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            print("Load UserDefaults.standard.getAccessToken() failed")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.log)", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<String>.self, from: responseData) else {
                        fatalError()
                    }
                    print(decodedData.message)
                    completion()
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.upexpectedResponse(statusCode, responseData, "fetchLogs()")
                    return
                }
        }
    }
    
    func dispatchACondLog(params: Parameters, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping () -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            print("Load UserDefaults.standard.getAccessToken() failed")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.log)/cond", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<String>.self, from: responseData) else {
                        fatalError()
                    }
                    print(decodedData.message)
                    completion()
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.upexpectedResponse(statusCode, responseData, "fetchLogs()")
                    return
                }
        }
    }
}
