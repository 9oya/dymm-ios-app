//
//  UIImage.swift
//  Dymm
//
//  Created by eunsang lee on 17/08/2019.
//  Copyright © 2019 9oya. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedTo1MB() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
//        let megaByte = 1000.0
        let megaByte = 700.0
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / megaByte // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > megaByte { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.5),
                let imageData = resizedImage.pngData() else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / megaByte // ! Or devide for 1024 if you need KB but not kB
        }
        
        return resizingImage
    }
    
    // Items
    static let item3dCube = UIImage(named: "item-3d-cube")!
    static let itemArrowCircle = UIImage(named: "item-arrow-circle")!
    static let itemArrowDown = UIImage(named: "item-arrow-down")!
    static let itemArrowLeft = UIImage(named: "item-arrow-left")!
    static let itemArrowMaximize = UIImage(named: "item-arrow-maximize")!
    static let itemArrowMinimize = UIImage(named: "item-arrow-minimize")!
    static let itemArrowRight = UIImage(named: "item-arrow-right")!
    static let itemBgIap = UIImage(named: "item-bg-iap")!
    static let itemBgWave = UIImage(named: "item-bg-wave")!
    static let itemBtnPlusTrans = UIImage(named: "item-btn-plus-trans")!
    static let itemBtnPlus = UIImage(named: "item-btn-plus")!
    static let itemCheckThin = UIImage(named: "item-check-thin")!
    static let itemCheck = UIImage(named: "item-check")!
    static let itemCircleAlmostEmpty = UIImage(named: "item-circle-almost-empty")!
    static let itemCircleAlmostFilled = UIImage(named: "item-circle-almost-filled")!
    static let itemCircleHalfEmpty = UIImage(named: "item-circle-half-empty")!
    static let itemCircleHalfFilled = UIImage(named: "item-circle-half-filled")!
    static let itemCircleQuarterEmpty = UIImage(named: "item-circle-quarter-empty")!
    static let itemCircleQuarterFilled = UIImage(named: "item-circle-quarter-filled")!
    static let itemCloseThin = UIImage(named: "item-close-thin")!
    static let itemClose = UIImage(named: "item-close")!
    static let itemDefActivity = UIImage(named: "item-def-activity")!
    static let itemDefDisease = UIImage(named: "item-def-disease")!
    static let itemDefFood = UIImage(named: "item-def-food")!
    static let itemDefPill = UIImage(named: "item-def-pill")!
    static let itemDivBig = UIImage(named: "item-div-big")!
    static let itemDivSmall = UIImage(named: "item-div-small")!
    static let itemGtMoon = UIImage(named: "item-gt-moon")!
    static let itemGtSun = UIImage(named: "item-gt-sun")!
    static let itemGtSunrise = UIImage(named: "item-gt-sunrise")!
    static let itemGtSunset = UIImage(named: "item-gt-sunset")!
    static let itemHeartbeat = UIImage(named: "item-heartbeat")!
    static let itemHome = UIImage(named: "item-home")!
    static let itemIllustGirl1 = UIImage(named: "item-illust-girl1")!
    static let itemIllustGirl2 = UIImage(named: "item-illust-girl2")!
    static let itemLogoMPurple = UIImage(named: "item-logo-m-purple")!
    static let itemLogoM = UIImage(named: "item-logo-m")!
    static let itemLogoS = UIImage(named: "item-logo-s")!
    static let itemMedicalCross = UIImage(named: "item-medical-cross")!
    static let itemNoteGrayM = UIImage(named: "item-note-gray-m")!
    static let itemNoteGray = UIImage(named: "item-note-gray")!
    static let itemNoteGreenM = UIImage(named: "item-note-green-m")!
    static let itemNoteGreen = UIImage(named: "item-note-green")!
    static let itemNotes = UIImage(named: "item-notes")!
    static let itemOpinion = UIImage(named: "item-opinion")!
    static let itemPlusActivity = UIImage(named: "item-plus-activity")!
    static let itemPlusDisease = UIImage(named: "item-plus-disease")!
    static let itemPlusFood = UIImage(named: "item-plus-food")!
    static let itemPlusHistory = UIImage(named: "item-plus-history")!
    static let itemPlusPill = UIImage(named: "item-plus-pill")!
    static let itemProfileDef = UIImage(named: "item-profile-def")!
    static let itemReload = UIImage(named: "item-reload")!
    static let itemRemove = UIImage(named: "item-remove")!
    static let itemScoreAvg = UIImage(named: "item-score-avg")!
    static let itemScoreAwfulL = UIImage(named: "item-score-awful-l")!
    static let itemScoreAwfulM = UIImage(named: "item-score-awful-m")!
    static let itemScoreAwful = UIImage(named: "item-score-awful")!
    static let itemScoreBadL = UIImage(named: "item-score-bad-l")!
    static let itemScoreBadM = UIImage(named: "item-score-bad-m")!
    static let itemScoreBad = UIImage(named: "item-score-bad")!
    static let itemScoreExcellentL = UIImage(named: "item-score-excellent-l")!
    static let itemScoreExcellentM = UIImage(named: "item-score-excellent-m")!
    static let itemScoreExcellent = UIImage(named: "item-score-excellent")!
    static let itemScoreGoodL = UIImage(named: "item-score-good-l")!
    static let itemScoreGoodM = UIImage(named: "item-score-good-m")!
    static let itemScoreGood = UIImage(named: "item-score-good")!
    static let itemScoreNoneL = UIImage(named: "item-score-none-l")!
    static let itemScoreNoneM = UIImage(named: "item-score-none-m")!
    static let itemScoreNone = UIImage(named: "item-score-none")!
    static let itemScoreSosoL = UIImage(named: "item-score-soso-l")!
    static let itemScoreSosoM = UIImage(named: "item-score-soso-m")!
    static let itemScoreSoso = UIImage(named: "item-score-soso")!
    static let itemSearch = UIImage(named: "item-search")!
    static let itemStarEmpty = UIImage(named: "item-star-empty")!
    static let itemStarFilled = UIImage(named: "item-star-filled")!
    static let itemStarWhite = UIImage(named: "item-star-white")!
    static let itemTrendDown = UIImage(named: "item-trend-down")!
    static let itemTrendUpGray = UIImage(named: "item-trend-up-gray")!
    static let itemTrendUp = UIImage(named: "item-trend-up")!
    static let itemTriangleDown = UIImage(named: "item-triangle-down")!
    
    static let itemStarWhiteSPill = UIImage(named: "item-star-white-s-fill")!
}
