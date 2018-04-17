//
//  StyleResolver.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/15.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

public class StyleResolver {
    public init() {
        
    }
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
        guard let dic = matchMap[key] else {
            return
        }
        for aDic in dic {
            var selectorArr = aDic.key.components(separatedBy: " ")
            if selectorArr.count > 1 {
                //带多个 selector 的情况
                selectorArr.removeLast()
                if !recursionSelectorMatch(selectorArr, parentElement: element.parent as! Element) {
                    continue
                }
            }
            guard let ruleDic = dic[aDic.key] else {
                continue
            }
            //将属性加入 element 的属性列表里
            for property in ruleDic {
                element.propertyMap[property.key] = property.value
            }
        }
        
    }
    
    //递归找出匹配的多路径
    func recursionSelectorMatch(_ selectors:[String], parentElement:Element) -> Bool {
        var selectorArr = selectors
        guard var last = selectorArr.last else {
            //表示全匹配了
            return true
        }
        guard let parent = parentElement.parent else {
            return false
        }
        
        var isMatch = false
        
        if last.hasPrefix(".") {
            last.removeFirst()
            //TODO:这里还需要考虑attribute 空格多个 class 名的情况
            guard let startTagToken = parentElement.startTagToken else {
                return false
            }
            if startTagToken.attributeDic["class"] == last {
                isMatch = true
            }
        } else if last.hasPrefix("#") {
            last.removeFirst()
            guard let startTagToken = parentElement.startTagToken else {
                return false
            }
            if startTagToken.attributeDic["id"] == last {
                isMatch = true
            }
        } else {
            guard let startTagToken = parentElement.startTagToken else {
                return false
            }
            if startTagToken.data == last {
                isMatch = true
            }
        }
        
        if isMatch {
            //匹配到会继续往前去匹配
            selectorArr.removeLast()
        }
        return recursionSelectorMatch(selectorArr, parentElement: parent as! Element)
        
    }
}
