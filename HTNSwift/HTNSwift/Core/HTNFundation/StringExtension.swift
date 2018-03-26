//
//  StringExtension.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/26.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation


extension String {
    //let s = "hello"
    //s[0..<3] // "hel"
    //s[3..<s.count] // "lo"
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: range.lowerBound)
        let idx2 = index(startIndex, offsetBy: range.upperBound)
        return String(self[idx1..<idx2])
    }
//    var count: Int { return self.count }
}
