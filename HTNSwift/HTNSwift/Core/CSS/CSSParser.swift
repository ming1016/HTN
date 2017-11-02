//
//  CSSParser.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/15.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

public class CSSParser {
    
    public var styleSheet: CSSStyleSheet
    
    private var _input: String
    private var _index: String.Index
    private var _bufferStr: String
    private var _currentSelector: CSSSelector
    private var _currentProperty: CSSProperty
    private var _currentRule: CSSRule
    
    init(_ input: String) {
        self.styleSheet = CSSStyleSheet()
        //过滤注释
        var newStr = ""
        let annotationBlockPattern = "/\\*[\\s\\S]*?\\*/" //匹配/*...*/这样的注释
        let regexBlock = try! NSRegularExpression(pattern: annotationBlockPattern, options: NSRegularExpression.Options(rawValue:0))
        newStr = regexBlock.stringByReplacingMatches(in: input, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, input.characters.count), withTemplate: "")
        //默认样式
        //TODO: 考虑后面需要考虑样式属性需要支持优先级，这里的处理还需要考虑记录更多信息支持后面根据类型判断优先级
        let defaultCSSString = CSSDefault.htnCSSDefault()
//        let defaultCSSString = ""
        newStr = defaultCSSString + newStr
        _input = newStr
        
        //初始化
        _index = _input.startIndex
        _bufferStr = ""
        _currentSelector = CSSSelector()
        _currentProperty = CSSProperty()
        _currentRule = CSSRule()
    }
    
    //解析 CSS 样式表
    public func parseSheet() -> CSSStyleSheet {
        
        let stateMachine = HTNStateMachine<S, E>(S.UnknownState)
        
        stateMachine.listen(E.CommaEvent, transit: [S.UnknownState, S.SelectorState], to: S.SelectorState) { (t) in
            self._currentSelector.path = self._bufferStr
            self.addSelector()
            self.advanceIndexAndResetCurrentStr()
        }
        stateMachine.listen(E.BraceLeftEvent, transit: [S.UnknownState, S.SelectorState], to: S.PropertyKeyState) { (t) in
            self._currentSelector.path = self._bufferStr
            self.addSelector()
            self.advanceIndexAndResetCurrentStr()
        }
        stateMachine.listen(E.ColonEvent, transit: S.PropertyKeyState, to: S.PropertyValueState) { (t) in
            self._currentProperty.key = self._bufferStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
            self.advanceIndexAndResetCurrentStr()
        }
        stateMachine.listen(E.SemicolonEvent, transit: S.PropertyValueState, to: S.PropertyKeyState) { (t) in
            self._currentProperty.value = self._bufferStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
            self.addProperty()
            self.advanceIndexAndResetCurrentStr()
        }
        //加上 PropertyValueState 的原因是需要支持 property 最后一个不需要写 ; 的情况
        stateMachine.listen(E.BraceRightEvent, transit: [S.PropertyKeyState,S.PropertyValueState], to: S.UnknownState) { (t) in
            if self._bufferStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 {
                self._currentProperty.value = self._bufferStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
                self.addProperty()
            }
            self.addRule()
            self.advanceIndexAndResetCurrentStr()
        }
        
        while let aChar = currentChar {
            let aStr = aChar.description
            var hasAStrTrigger = false
            //deal with aStr
            if aStr == "," { hasAStrTrigger = stateMachine.trigger(E.CommaEvent) }
            if aStr == "." { hasAStrTrigger = stateMachine.trigger(E.DotEvent) }
            if aStr == "#" { hasAStrTrigger = stateMachine.trigger(E.HashTagEvent) }
            if aStr == "{" { hasAStrTrigger = stateMachine.trigger(E.BraceLeftEvent) }
            if aStr == "}" { hasAStrTrigger = stateMachine.trigger(E.BraceRightEvent) }
            if aStr == ":" { hasAStrTrigger = stateMachine.trigger(E.ColonEvent) }
            if aStr == ";" { hasAStrTrigger = stateMachine.trigger(E.SemicolonEvent) }
            
            if !hasAStrTrigger {
                addBufferStr(aStr)
                advanceIndex()
            }
        }
        
        return self.styleSheet
    }
    
    //parser tool
    var currentChar: Character? {
        return _index < _input.endIndex ? _input[_index] : nil
    }
    func addBufferStr(_ bufferStr: String) {
        _bufferStr += bufferStr
    }
    func advanceIndex() {
        _input.characters.formIndex(after: &_index)
    }
    func advanceIndexAndResetCurrentStr() {
        _bufferStr = ""
        advanceIndex()
    }
    //add
    func addSelector() {
        let selector = _currentSelector
        _currentRule.selectorList.append(selector)
        _currentSelector = CSSSelector()
    }
    func addProperty() {
        let property = _currentProperty
        _currentRule.propertyList.append(property)
        _currentRule.propertyMap[property.key] = property.value
        _currentProperty = CSSProperty()
    }
    func addRule() {
        let rule = _currentRule
        styleSheet.ruleList.append(rule)
        _currentRule = CSSRule()
    }
    
    enum S: HTNStateType {
        case UnknownState     //
        case SelectorState    // 比如 div p, #id
        case PropertyKeyState   // 属性的 key
        case PropertyValueState // 属性的 value
        
        //TODO:以下后期支持，优先级2
        case PseudoClass      // :nth-child(2)
        case PseudoElement    // ::first-line
        
        //TODO:以下后期支持，优先级3
        case PagePseudoClass
        case AttributeExact   // E[attr]
        case AttributeSet     // E[attr|="value"]
        case AttributeHyphen  // E[attr~="value"]
        case AttributeList    // E[attr*="value"]
        case AttributeContain // E[attr^="value"]
        case AttributeBegin   // E[attr$="value"]
        case AttributeEnd
        //TODO:@media 这类 @规则 ，后期支持，优先级4
    }
    enum E: HTNEventType {
        case SpaceEvent   //空格
        case CommaEvent   // ,
        case DotEvent     // .
        case HashTagEvent // #
        case BraceLeftEvent  // {
        case BraceRightEvent // }
        case ColonEvent // :
        case SemicolonEvent  // ;
    }
}
