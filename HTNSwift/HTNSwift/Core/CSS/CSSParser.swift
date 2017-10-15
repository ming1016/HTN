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
    
    
    init(_ input: String) {
        self.styleSheet = CSSStyleSheet()
        _input = input
        _index = input.startIndex
        _bufferStr = ""
    }
    
    //解析 CSS 样式表
    public func parseSheet() -> CSSStyleSheet {
        let stateMachine = HTNStateMachine<S, E>(S.UnknownState)
        
        stateMachine.listen(E.SpaceEvent, transit: S.UnknownState, to: S.TagState) { (t) in
            //
        }
        
        while let aChar = currentChar {
            let aStr = aChar.description
            var hasAStrTrigger = false
            //deal with aStr
            if aStr == " " { hasAStrTrigger = stateMachine.trigger(E.SpaceEvent) }
            if aStr == "," { hasAStrTrigger = stateMachine.trigger(E.CommaEvent) }
            if aStr == "." { hasAStrTrigger = stateMachine.trigger(E.DotEvent) }
            if aStr == "#" { hasAStrTrigger = stateMachine.trigger(E.HashTagEvent) }
            if aStr == "{" { hasAStrTrigger = stateMachine.trigger(E.BraceLeftEvent) }
            if aStr == "}" { hasAStrTrigger = stateMachine.trigger(E.BraceRightEvent) }
            
            if !hasAStrTrigger {
                addBufferStr(aStr)
            }
        }
        
        return self.styleSheet
    }
    
    //tool
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
    
    enum S: HTNStateType {
        case UnknownState     //
        case TagState         // 比如 div
        case IdState          // #id
        case ClassState       // .class
        
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
    }
}
