//
//  JState.swift
//  HTN
//
//  Created by DaiMing on 2018/5/16.
//

import Foundation

class JState {
    var input:String = ""
    
    var inMethod = false
    var inFunction = false
    var inParameters = false
    var maybeInArrowParameters = false
    var inGenerator = false
    var inAsync = false
    var inPropertyName = false
    var inType = false
    var inClassProperty = false
    var isIterator = false
}
