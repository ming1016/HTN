//
//  StringExtension.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/26.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

extension String {
    // let s = "hello"
    // s[0..<3] // "hel"
    // s[3..<s.count] // "lo"
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: range.lowerBound)
        let idx2 = index(startIndex, offsetBy: range.upperBound)
        return String(self[idx1..<idx2])
    }
    
    // String 转 NSNumber
    var numberValue: NSNumber? {
        if let value = Int(self) {
            return NSNumber(value: value)
        }
        return nil
    }
    
    // 转义
    func escape() -> String {
        return self.replacingOccurrences(of: "\"", with: "\\\"")
    }
    
    // 过滤注释
    func filterAnnotationBlock() -> String {
        //过滤注释
        var newStr = ""
        let annotationBlockPattern = "/\\*[\\s\\S]*?\\*/" //匹配/*...*/这样的注释
        let regexBlock = try! NSRegularExpression(pattern: annotationBlockPattern, options: NSRegularExpression.Options(rawValue:0))
        newStr = regexBlock.stringByReplacingMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, self.count), withTemplate: "")
        return newStr
    }
    // 判断是否是整数
    func isInt() -> Bool {
        let scan:Scanner = Scanner(string: self)
        var val:Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
    // 判断是否是 Float
    func isFloat() -> Bool {
        let scan:Scanner = Scanner(string: self)
        var val:Float = 0
        return scan.scanFloat(&val) && scan.isAtEnd
    }
    
}
