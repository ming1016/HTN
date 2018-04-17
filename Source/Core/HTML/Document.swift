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
    
    //打印 Dom 树
    public func des() {
        for elm in self.children {
            desElement(elm: elm as! Element, level: 0)
        }
    }
    
    private func desElement(elm:Element, level:Int) {
        var propertyStr = ""
        var attributeStr = ""
        if elm.startTagToken != nil {
            if elm.startTagToken!.attributeList.count > 0 {
                attributeStr = "[ATTR]:"
                for attr in (elm.startTagToken?.attributeList)! {
                    attributeStr += " \(attr.name):\(attr.value)"
                }
            }
        }
        if elm.propertyMap.count > 0 {
            propertyStr = "[CSS]:"
            for property in elm.propertyMap {
                propertyStr += " \(property.key):\(property.value)"
            }
        }
        var frontStr = "";
        for _ in 0...level {
            if level > 0 {
                frontStr += "    "
            }
        }
        print("\(frontStr)[\(elm.startTagToken?.data.uppercased() ?? "CHAR")] \(attributeStr) \(propertyStr)")
        if elm.children.count > 0 {
            for child in elm.children {
                self.desElement(elm: child as! Element, level: level + 1)
            }
        }
    }
    
}










