//
//  HTMLToken.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/11.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

public class HTMLToken {
    public var type: tokenType
    public var data: String
    public var selfClosing: Bool
    public var attributeList: [Attribute]
    public var attributeDic: [String:String]
    public var currentAttribute: Attribute
    
    init() {
        self.type = tokenType.DocType
        self.data = ""
        self.selfClosing = false
        self.attributeList = [Attribute]()
        self.attributeDic = [String:String]()
        self.currentAttribute = Attribute()
    }
    
    public enum tokenType {
        case DocType
        case StartTag
        case EndTag
        case Comment
        case Char
        case EOF
    }
}
