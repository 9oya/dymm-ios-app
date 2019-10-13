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
        let megaByte = 1000.0
        
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
    static let itemRectangleLine = UIImage(named: "item-Rectangle-line")!
    static let itemArrowCircle = UIImage(named: "item-arrow-circle")!
    static let itemArrowDown = UIImage(named: "item-arrow-down")!
    static let itemArrowLeft = UIImage(named: "item-arrow-left")!
    static let itemArrowMaximize = UIImage(named: "item-arrow-maximize")!
    static let itemArrowMinimize = UIImage(named: "item-arrow-minimize")!
    static let itemArrowRight = UIImage(named: "item-arrow-right")!
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
    static let itemDivBig = UIImage(named: "item-div-big")!
    static let itemDivSmall = UIImage(named: "item-div-small")!
    static let itemFingerClick = UIImage(named: "item-finger-click")!
    static let itemGtMoon = UIImage(named: "item-gt-moon")!
    static let itemGtSun = UIImage(named: "item-gt-sun")!
    static let itemGtSunrise = UIImage(named: "item-gt-sunrise")!
    static let itemGtSunset = UIImage(named: "item-gt-sunset")!
    static let itemHeartbeat = UIImage(named: "item-heartbeat")!
    static let itemHome = UIImage(named: "item-home")!
    static let itemLoading = UIImage(named: "item-loading")!
    static let itemLogoM = UIImage(named: "item-logo-m")!
    static let itemLogoS = UIImage(named: "item-logo-s")!
    static let itemNoteGray = UIImage(named: "item-note-gray")!
    static let itemNoteYellow = UIImage(named: "item-note-yellow")!
    static let itemNotes = UIImage(named: "item-notes")!
    static let itemProfileDef = UIImage(named: "item-profile-def")!
    static let itemRemove = UIImage(named: "item-remove")!
    static let itemScoreAvg = UIImage(named: "item-score-avg")!
    static let itemScoreAwful = UIImage(named: "item-score-awful")!
    static let itemScoreBad = UIImage(named: "item-score-bad")!
    static let itemScoreExcellent = UIImage(named: "item-score-excellent")!
    static let itemScoreGood = UIImage(named: "item-score-good")!
    static let itemScoreNone = UIImage(named: "item-score-none")!
    static let itemScoreSoso = UIImage(named: "item-score-soso")!
    static let itemStarEmpty = UIImage(named: "item-star-empty")!
    static let itemStarFilled = UIImage(named: "item-star-filled")!
    static let itemTrendDown = UIImage(named: "item-trend-down")!
    static let itemTrendUpGray = UIImage(named: "item-trend-up-gray")!
    static let itemTrendUp = UIImage(named: "item-trend-up")!
    static let itemTriangleDown = UIImage(named: "item-triangle-down")!
    
    static let itemScoreAwfulL = UIImage(named: "item-score-awful-l")!
    static let itemScoreBadL = UIImage(named: "item-score-bad-l")!
    static let itemScoreExcellentL = UIImage(named: "item-score-excellent-l")!
    static let itemScoreGoodL = UIImage(named: "item-score-good-l")!
    static let itemScoreNoneL = UIImage(named: "item-score-none-l")!
    static let itemScoreSosoL = UIImage(named: "item-score-soso-l")!
    
    static let itemAgingGray = UIImage(named: "item-aging-gray")!
    static let itemAgingPurple = UIImage(named: "item-aging-purple")!
    static let itemAgingTomato = UIImage(named: "item-aging-tomato")!
    static let itemAgingOrange = UIImage(named: "item-aging-orange")!
    static let itemAgingGreen = UIImage(named: "item-aging-green")!
    static let itemAgingBlue = UIImage(named: "item-aging-blue")!
    
    static let itemAiGray = UIImage(named: "item-ai-gray")!
    static let itemAiGreen = UIImage(named: "item-ai-green")!
    
    static let itemBatteryGray = UIImage(named: "item-battery-gray")
    static let itemBatteryGreen = UIImage(named: "item-battery-green")
}
