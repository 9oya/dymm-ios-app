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
    
    // MARK: - Helpers
    
    func badRequest(_ responseData: Data) {
        guard let decodedData = try? self.decoder.decode(BadRequest.self, from: responseData) else {
            fatalError("Decode \(BadRequest.self) failed")
        }
        fatalError("\(decodedData.message)")
    }
    
    func unexpectedResponse(_ statusCode: Int, _ data: Data, _ name: String) {
        print("Request \(name) failed \nStatus Code: \(statusCode)")
        guard let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) as [String : Any]??) else {
            fatalError("Decode error message failed")
        }
        fatalError(String(describing: json))
    }
    
    func convertLogGroupsIntoTwoDimLogGroupSectArr(_ logGroups: [BaseModel.LogGroup]) -> [[CustomModel.LogGroupSection]] {
        var logGroupSectArr = [CustomModel.LogGroupSection]()
        for logGroup in logGroups {
            logGroupSectArr.append(CustomModel.LogGroupSection(dayOfYear: logGroup.day_of_year, logGroup: logGroup))
        }
        let groupedLogGroupSectArr = Dictionary(grouping: logGroupSectArr) { (element) -> Int in
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
                    self.unexpectedResponse(statusCode, responseData, "refreshAccessToken()")
                    return
                }
        }
    }
    
    // MARK: - GET services
    
    func getAvatar(unauthorized: @escaping (_ pattern: Int) -> Void, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ data: CustomModel.Auth) -> Void) {
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
                    guard let decodedData = try? self.decoder.decode(Ok<CustomModel.Auth>.self, from: responseData) else {
                        fatalError("jsonDecoder.decode(Ok<[UserModel.Avatar]>.self, from: responseData)")
                    }
                    guard let data = decodedData.data else {
                        fatalError("decodedData.data")
                    }
                    completion(data)
                case 400:
                    self.badRequest(responseData)
                case 401:
                    guard let decodedData = try? self.decoder.decode(Unauthorized.self, from: responseData) else {
                        fatalError()
                    }
                    unauthorized(decodedData.pattern)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.unexpectedResponse(statusCode, responseData, "validateUser()")
                    return
                }
        }
    }
    
    func getProfile(popoverAlert: @escaping (_ message: String) -> Void, emailNotConfirmed: @escaping (_ email: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ avatarAndFacts: CustomModel.Profile) -> Void) {
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
                        fatalError()
                    }
                    guard let data = decodedData.data else {
                        fatalError()
                    }
                    completion(data)
                case 400:
                    self.badRequest(responseData)
                case 401:
                    guard let decodedData = try? self.decoder.decode(Unauthorized.self, from: responseData) else {
                        fatalError()
                    }
                    emailNotConfirmed(decodedData.message)
                    return
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.unexpectedResponse(statusCode, responseData, "fetchProfile()")
                    return
                }
        }
    }
    
    func getAvatarCondList(popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ data: [BaseModel.AvatarCond]) -> Void) {
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
                    self.unexpectedResponse(statusCode, responseData, "validateUser()")
                    return
                }
        }
    }
    
    func getRemainingLifeSpan(popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, unauthorized: @escaping (_ pattern: Int) -> Void, completion: @escaping (_ lifeSpan: Int) -> Void) {
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
        Alamofire.request("\(URI.host)\(URI.avatar)/\(avatarId)/life-span", method: .get, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<Int>.self, from: responseData) else {
                        fatalError()
                    }
                    guard let lifeSpan = decodedData.data else {
                        fatalError()
                    }
                    completion(lifeSpan)
                case 400:
                    self.badRequest(responseData)
                case 401:
                    guard let decodedData = try? self.decoder.decode(Unauthorized.self, from: responseData) else {
                        fatalError()
                    }
                    unauthorized(decodedData.pattern)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.unexpectedResponse(statusCode, responseData, "validateUser()")
                    return
                }
        }
    }
    
    func getLogGroups(yearNumber: Int, yearForWeekOfYear: Int, monthNumber: Int, weekOfYear: Int?, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping ([BaseModel.LogGroup]) -> Void) {
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
        // TODO: Remove /new
        var url = "\(URI.host)\(URI.avatar)/new/\(avatarId)/group/\(yearNumber)/\(monthNumber)"
        if let weekOfYear = weekOfYear {
            url = "\(URI.host)\(URI.avatar)/new/\(avatarId)/group/\(yearForWeekOfYear)/\(monthNumber)/\(weekOfYear)"
        }
        Alamofire.request(url, headers: headers)
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
                    self.unexpectedResponse(statusCode, responseData, "fetchLogGroups()")
                    return
                }
        }
    }
    
    func getLogGroupNotes(page: Int, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping ([BaseModel.LogGroup]) -> Void) {
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
        // TODO: Remove /new
        Alamofire.request("\(URI.host)\(URI.avatar)/new/\(avatarId)/group-note/\(page)", headers: headers)
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
                    self.unexpectedResponse(statusCode, responseData, "fetchLogGroups()")
                    return
                }
        }
    }
    
    func getAvgCondScore(yearNumber: Int, yearForWeekOfYear: Int, monthNumber: Int?, weekOfYear: Int?, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (CustomModel.AvgCondScoreSet) -> Void) {
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
        // TODO: Remove /new
        var url = "\(URI.host)\(URI.avatar)/new/\(avatarId)/group/\(yearNumber)/avg-score"
        if monthNumber != nil {
            url = "\(URI.host)\(URI.avatar)/new/\(avatarId)/group/\(yearNumber)/\(monthNumber!)/avg-score"
            if weekOfYear != nil && weekOfYear! > 0 {
                url = "\(URI.host)\(URI.avatar)/new/\(avatarId)/group/\(yearForWeekOfYear)/\(monthNumber!)/\(weekOfYear!)/avg-score"
            }
        }
        
        Alamofire.request(url, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<CustomModel.AvgCondScoreSet>.self, from: responseData) else {
                        fatalError()
                    }
                    guard let avgCondScoreSet = decodedData.data else {
                        fatalError()
                    }
                    completion(avgCondScoreSet)
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.unexpectedResponse(statusCode, responseData, "getAvgCondScore()")
                    return
                }
        }
    }
    
    func getScoreBoard(yearNumber: String, monthNumber: Int?, unauthorized: @escaping (_ pattern: Int) -> Void, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (CustomModel.ScoreBoardSet) -> Void) {
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
        var url = "\(URI.host)\(URI.avatar)/\(avatarId)/group/\(yearNumber)/score-board"
        if monthNumber != nil {
            url = "\(URI.host)\(URI.avatar)/\(avatarId)/group/\(yearNumber)/\(monthNumber!)/score-board"
        }
        
        Alamofire.request(url, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<CustomModel.ScoreBoardSet>.self, from: responseData) else {
                        fatalError()
                    }
                    guard let scoreBoardSet = decodedData.data else {
                        fatalError()
                    }
                    completion(scoreBoardSet)
                case 400:
                    self.badRequest(responseData)
                case 401:
                    guard let decodedData = try? self.decoder.decode(Unauthorized.self, from: responseData) else {
                        fatalError()
                    }
                    unauthorized(decodedData.pattern)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.unexpectedResponse(statusCode, responseData, "getScoreBoard()")
                    return
                }
        }
    }
    
    func getGroupOfLogs(logGroupId: Int, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (CustomModel.GroupOfLogSet) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/group/\(logGroupId)/log", headers: headers)
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
                    self.unexpectedResponse(statusCode, responseData, "getGroupOfLogs()")
                    return
                }
        }
    }
    
    func getBannerList(popoverAlert: @escaping (_ message: String) -> Void ,completion: @escaping (_ banners: [BaseModel.Banner]) -> Void) {
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
                    self.unexpectedResponse(statusCode, responseData, "getBannerList()")
                    return
                }
        }
    }
    
    func getTagSetList(tagId: Int, sortType: String, pageNum: Int? = nil, perPage: Int? = nil, langId: Int? = nil, popoverAlert: @escaping (_ message: String) -> Void ,completion: @escaping (_ tagSet: CustomModel.TagSet) -> Void) {
        // TODO: Remove "/new"
        var url = "\(URI.host)\(URI.tag)/new/\(tagId)/set/\(sortType)"
        if let _pageNum = pageNum {
            if UserDefaults.standard.getAvatarId() != nil && UserDefaults.standard.getAvatarId() != 0 {
                let avatarId = UserDefaults.standard.getAvatarId()
                url += "/avt/\(avatarId!)/page/\(_pageNum)/\(perPage!)/lang/\(langId!)"
            } else {
                url += "/page/\(_pageNum)/\(perPage!)/lang/\(langId!)"
            }
        }
        Alamofire.request(url)
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
                    self.unexpectedResponse(statusCode, responseData, "getTagSetList()")
                    return
                }
        }
    }
    
    func getProfileTagSets(tagId: Int, isSelected: Bool, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ profileTagSet: CustomModel.ProfileTagSet) -> Void) {
//        guard let accessToken = UserDefaults.standard.getAccessToken() else {
//            UserDefaults.standard.setIsSignIn(value: false)
//            fatalError()
//        }
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(accessToken)"
//        ]
//        Alamofire.request("\(URI.host)\(URI.tag)/\(tagId)/set/match/\(isSelected)", method: .get, headers: headers)
        // TODO: Remove "/new
        Alamofire.request("\(URI.host)\(URI.tag)/new/\(tagId)/set/match/\(isSelected)", method: .get)
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
                    self.unexpectedResponse(statusCode, responseData, "getProfileTagSets()")
                    return
                }
        }
    }
    
    func getRankings(ageRange: Int, startPoint: Int, pageNum: Int, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ rankingSet: CustomModel.RankingSet) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/ranking/\(ageRange)/\(startPoint)/\(pageNum)", method: .get, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<CustomModel.RankingSet>.self, from: responseData) else {
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
                    self.unexpectedResponse(statusCode, responseData, "getRankings()")
                    return
                }
        }
    }
    
    func getARanking(ageRange: Int, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ ranking: CustomModel.Ranking) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        Alamofire.request("\(URI.host)\(URI.avatar)/\(avatarId)/ranking/\(ageRange)", method: .get, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<CustomModel.Ranking>.self, from: responseData) else {
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
                    self.unexpectedResponse(statusCode, responseData, "getARanking()")
                    return
                }
        }
    }
    
    // MARK: - POST services
    
    func authOldAvatar(params: Parameters, unauthorized: @escaping (_ pattern: Int) -> Void, popoverAlert: @escaping (_ message: String) -> Void, completion: @escaping (_ auth: CustomModel.Auth) -> Void) {
        Alamofire.request("\(URI.host)\(URI.avatar)/auth", method: .post, parameters: params, encoding: JSONEncoding.default)
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
                    self.unexpectedResponse(statusCode, responseData, "authOldAvatar()")
                    return
                }
        }
    }
    
    func createNewAvatar(params: Parameters, unauthorized: @escaping (_ pattern: Int) -> Void, popoverAlert: @escaping (_ message: String) -> Void, completion: @escaping (_ auth: CustomModel.Auth) -> Void) {
        Alamofire.request("\(URI.host)\(URI.avatar)/create", method: .post, parameters: params, encoding: JSONEncoding.default)
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
                    self.unexpectedResponse(statusCode, responseData, "createNewAccount()")
                    return
                }
        }
    }
    
    func postAvatarCond(params: Parameters, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping () -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            print("Load UserDefaults.standard.getAccessToken() failed")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/cond", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
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
                    self.unexpectedResponse(statusCode, responseData, "postAvatarCond()")
                    return
                }
        }
    }
    
    func postABookmark(params: Parameters, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ postBookmark: CustomModel.PostBookmark) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            print("Load UserDefaults.standard.getAccessToken() failed")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/bookmark", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<CustomModel.PostBookmark>.self, from: responseData) else {
                        fatalError()
                    }
                    guard let postBookmark = decodedData.data else {
                        fatalError()
                    }
                    completion(postBookmark)
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.unexpectedResponse(statusCode, responseData, "postABookmark()")
                    return
                }
        }
    }
    
    func postASingleLog(params: Parameters, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping () -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            print("Load UserDefaults.standard.getAccessToken() failed")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        // TODO: Remove /new
        Alamofire.request("\(URI.host)\(URI.avatar)/new/log", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
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
                    self.unexpectedResponse(statusCode, responseData, "postASingleLog()")
                    return
                }
        }
    }
    
    func sendMailConfLinkAgain(params: Parameters, popoverAlert: @escaping (_ message: String) -> Void ,completion: @escaping () -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            print("Load UserDefaults.standard.getAccessToken() failed")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.mail)/conf-link", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
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
                case 401:
                    UserDefaults.standard.setIsSignIn(value: false)
                    fatalError()
                default:
                    self.unexpectedResponse(statusCode, responseData, "sendMailConfLinkAgain()")
                    return
                }
        }
    }
    
    func sendUserOpinionMail(params: Parameters, popoverAlert: @escaping (_ message: String) -> Void ,completion: @escaping () -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            print("Load UserDefaults.standard.getAccessToken() failed")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.mail)/opinion", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
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
                case 401:
                    UserDefaults.standard.setIsSignIn(value: false)
                    return
                case 403:
                    UserDefaults.standard.setIsSignIn(value: false)
                    return
                default:
                    self.unexpectedResponse(statusCode, responseData, "sendMailConfLinkAgain()")
                    return
                }
        }
    }
    
    func searchTags(tagId: Int, keyWord: String, page: Int, perPage: Int, popoverAlert: @escaping (_ message: String) -> Void ,completion: @escaping (_ tagSet: CustomModel.TagSet) -> Void) {
        let params: Parameters = [
            "key_word": keyWord
        ]
        // TODO: Remove "/new"
        let url = "\(URI.host)\(URI.tag)/new/\(tagId)/search/page/\(page)/\(perPage)"
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
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
                    self.unexpectedResponse(statusCode, responseData, "searchTags()")
                    return
                }
        }
    }
    
    func solveAvatarEmail(option: String, params: Parameters, unauthorized: @escaping () -> Void, popoverAlert: @escaping (_ message: String) -> Void ,completion: @escaping () -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            print("Load UserDefaults.standard.getAccessToken() failed")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/email/\(option)", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
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
                case 401:
                    unauthorized()
                default:
                    self.unexpectedResponse(statusCode, responseData, "findEmailAddress()")
                    return
                }
        }
    }

    func postProfilePhoto(avatarId: Int, image: Data, popoverAlert: @escaping (_ message: String) -> Void ,completion: @escaping () -> Void) {
        let url = "\(URI.host)\(URI.avatar)/\(avatarId)/profile-img"
        Alamofire.upload(multipartFormData: { (form) in
            form.append(image, withName: "file", fileName: "file.jpg", mimeType: "image/jpg")
        }, to: url, encodingCompletion: { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseString { response in
                    completion()
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    func verifyReceipt(params: Parameters, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ isReceiptVerif: Bool) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            print("Load UserDefaults.standard.getAccessToken() failed")
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/receipt", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<Bool>.self, from: responseData) else {
                        fatalError()
                    }
                    guard let isReceiptVerif = decodedData.data else {
                        fatalError()
                    }
                    completion(isReceiptVerif)
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.unexpectedResponse(statusCode, responseData, "verifyReceipt()")
                    return
                }
        }
    }
    
    // MARK: - PUT services
    
    func putAvatarInfo(params: Parameters, unauthorized: @escaping (_ pattern: Int) -> Void, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ newInfoTxt: String) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
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
                    completion(params["new_info"] as! String)
                case 400:
                    self.badRequest(responseData)
                case 401:
                    guard let decodedData = try? self.decoder.decode(Unauthorized.self, from: responseData) else {
                        fatalError()
                    }
                    unauthorized(decodedData.pattern)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.unexpectedResponse(statusCode, responseData, "fetchLogs()")
                    return
                }
        }
    }
    
    
    func putProfileTag(profile_tag_id: Int, tag_id: Int, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping () -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/profile/\(profile_tag_id)/\(tag_id)", method: .put, headers: headers)
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
                    self.unexpectedResponse(statusCode, responseData, "validateUser()")
                    return
                }
        }
    }
    
    func putAvatarCond(avatarCondId: Int, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping () -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/cond/\(avatarCondId)", method: .put, encoding: JSONEncoding.default, headers: headers)
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
                    self.unexpectedResponse(statusCode, responseData, "fetchLogs()")
                    return
                }
        }
    }
    
    func putABookmark(bookmark_id: Int, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping (_ bookmarksTotal: Int) -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            print("Load UserDefaults.standard.getAccessToken() failed")
            return
        }
        guard let avatarId = UserDefaults.standard.getAvatarId() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/\(avatarId)/bookmark/\(bookmark_id)", method: .put, encoding: JSONEncoding.default, headers: headers)
            .validate(contentType: ["application/json"])
            .responseData { response in
                guard let responseData = response.result.value, let statusCode = response.response?.statusCode else {
                    popoverAlert(self.lang.msgNetworkFailure)
                    return
                }
                switch statusCode {
                case 200:
                    guard let decodedData = try? self.decoder.decode(Ok<Int>.self, from: responseData) else {
                        fatalError()
                    }
                    print(decodedData.message)
                    completion(decodedData.data!)
                case 400:
                    self.badRequest(responseData)
                case 403:
                    _ = self.forbiddenRequest(responseData, popoverAlert) { (message, pattern) in
                        tokenRefreshCompletion()
                    }
                    return
                default:
                    self.unexpectedResponse(statusCode, responseData, "fetchLogs()")
                    return
                }
        }
    }
    
    func putLogGroup(logGroupId: Int, option: String, params: Parameters?, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping () -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        let url = "\(URI.host)\(URI.avatar)/group/\(logGroupId)/\(option)"
        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
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
                    self.unexpectedResponse(statusCode, responseData, "fetchLogs()")
                    return
                }
        }
    }
    
    func putGroupOfALog(tagLogId: Int, popoverAlert: @escaping (_ message: String) -> Void, tokenRefreshCompletion: @escaping () -> Void, completion: @escaping () -> Void) {
        guard let accessToken = UserDefaults.standard.getAccessToken() else {
            UserDefaults.standard.setIsSignIn(value: false)
            fatalError()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
        ]
        Alamofire.request("\(URI.host)\(URI.avatar)/log/\(tagLogId)", method: .put, encoding: JSONEncoding.default, headers: headers)
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
                    self.unexpectedResponse(statusCode, responseData, "fetchLogs()")
                    return
                }
        }
    }
}
