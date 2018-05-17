//
//  JSToken.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/30.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

public class JSToken {
    public var type = tokenType.Unknown
    public var data = ""
    
    public enum tokenType {
        case Unknown
        case KeyWords
        case Char
    }
}
