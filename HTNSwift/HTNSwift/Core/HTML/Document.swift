//
//  Document.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/11.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

public class Document : Element {
    public var styleList = [Element]()
    public var scriptList = [Element]()
    
    public func allStyle() -> String {
        var allStyle = ""
        for style in styleList {
            guard let str = style.charToken?.data else {
                continue
            }
            allStyle += str
        }
        return allStyle
    }
    
    public func allScript() -> String {
        var allScript = ""
        for script in scriptList {
            guard let str = script.charToken?.data else {
                continue
            }
            allScript += str
        }
        return allScript
    }
    
}


