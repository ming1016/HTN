//
//  StyleResolver.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/15.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

public class StyleResolver {
    public func resolver(_ doc:Document, styleSheet:CSSStyleSheet) -> Document{
        //样式映射表
        //这种结构能够支持多级 Selector
        var matchMap = [String:[String:[String:String]]]()
        for rule in styleSheet.ruleList {
            for selector in rule.selectorList {
                guard let matchLast = selector.matchList.last else {
                    continue
                }
                var matchDic = matchMap[matchLast]
                if matchDic == nil {
                    matchDic = [String:[String:String]]()
                    matchMap[matchLast] = matchDic
                }
                
                //这里可以按照后加入 rulelist 的优先级更高的原则进行覆盖操作
//                let cssRule = matchMap[matchLast]![selector.identifier]
                if matchMap[matchLast]![selector.identifier] == nil {
                    matchMap[matchLast]![selector.identifier] = [String:String]()
                }
                for a in rule.propertyList {
                    matchMap[matchLast]![selector.identifier]![a.key] = a.value
                }
            }
        }
        for elm in doc.children {
            self.attach(elm as! Element, matchMap: matchMap)
        }
        
        return doc
    }
    //递归将样式属性都加上
    func attach(_ element:Element, matchMap:[String:[String:[String:String]]]) {
        guard let token = element.startTagToken else {
            return
        }
        if matchMap[token.data] != nil {
            //TODO: 还不支持 selector 里多个标签名组合，后期加上
            addProperty(token.data, matchMap: matchMap, element: element)
        }
        
        //增加 property 通过处理 token 里的属性列表里的 class 和 id 在 matchMap 里找
        for attr in token.attributeList {
            if attr.name == "class" {
                addProperty("." + attr.value.lowercased(), matchMap: matchMap, element: element)
            }
            if attr.name == "id" {
                addProperty("#" + attr.value.lowercased(), matchMap: matchMap, element: element)
            }
        }
        
        if element.children.count > 0 {
            for element in element.children {
                self.attach(element as! Element, matchMap: matchMap)
            }
        }
    }
    
    func addProperty(_ key:String, matchMap:[String:[String:[String:String]]], element:Element) {
        if matchMap[key] != nil {
            //TODO: 还不支持 selector 里多个标签名组合，后期加上
            if matchMap[key]![key] != nil {
                let ruleList = matchMap[key]![key]!
                //将属性加入 element 的属性列表里
                for property in ruleList {
                    element.propertyMap[property.key] = property.value
                }
            }
        }
    }
}
