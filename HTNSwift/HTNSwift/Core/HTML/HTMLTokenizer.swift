//
//  HTMLTokenizer.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/11.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

public class HTMLTokenizer {
    private let _input: String
    private var _index: String.Index
    private var _bufferStr: String
    private var _bufferToken: HTMLToken
    private var _tks: [HTMLToken]
    //TODO: add doctypeData for DOCTYPE
    public init(_ input: String) {
        _input = input
        _index = input.startIndex
        _bufferStr = ""
        _bufferToken = HTMLToken()
        _tks = [HTMLToken]()
    }
    public func parse() -> [HTMLToken]{
        //初始化状态机
        let stateMachine = HTNStateMachine<S, E>(S.DataState)
        
        //状态机监听 state
        //不同事件在来源是集合状态的转成统一状态的处理
        //TODO:根据 w3c 标准 https://dev.w3.org/html5/spec-preview/tokenization.html 来完善状态机，添加更多状态的处理
        let anglebracketRightEventFromStatesArray = [S.DOCTYPEState,
                                                     S.CommentEndState,
                                                     S.TagOpenState,
                                                     S.EndTagOpenState,
                                                     S.AfterAttributeValueQuotedState,
                                                     S.BeforeDOCTYPENameState,
                                                     S.AfterDOCTYPEPublicIdentifierState]
        stateMachine.listen(E.AngleBracketRight, transit: anglebracketRightEventFromStatesArray, to: S.DataState) { (t) in
            if t.fromState == S.TagOpenState || t.fromState == S.EndTagOpenState {
                if self._bufferStr.count > 0 {
                    self._bufferToken.data = self._bufferStr.lowercased()
                }
            }
            self.addHTMLToken()
            self.advanceIndexAndResetCurrentStr()
        }
        
        //DataState
        stateMachine.listen(E.AngleBracketLeft, transit: S.DataState, to: S.TagOpenState) { (t) in
            self._bufferStr = self._bufferStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if self._bufferStr.count > 0 {
                self._bufferToken.type = .Char
                self._bufferToken.data = self._bufferStr
                self.addHTMLToken()
            }
            self._bufferToken.type = .StartTag
            self.advanceIndexAndResetCurrentStr()
        }
        stateMachine.listen(E.And, transit: S.DataState, to: S.CharacterReferenceInDataState) { (t) in
            self.advanceIndexAndResetCurrentStr()
        }
        //TagOpenState
        stateMachine.listen(E.Exclamation, transit: S.TagOpenState, to: S.MarkupDeclarationOpenState) { (t) in
            self.advanceIndexAndResetCurrentStr()
        }
        //TODO:补上这种需要判断开始时字母，或者特定首字母集进入的状态，比如 TagNameState 和 BeforeAttributeNameState，但需要权衡下，如果不加这个状态会少不少检查
        stateMachine.listen(E.Space, transit: S.TagOpenState, to: S.AttributeNameState) { (t) in
            self._bufferToken.data = self._bufferStr.lowercased()
            self.advanceIndexAndResetCurrentStr()
        }
        stateMachine.listen(E.Slash, transit: S.TagOpenState, to: S.EndTagOpenState) { (t) in
            if self._bufferStr.count == 0 {
                self._bufferToken.type = .EndTag
            } else {
                self._bufferToken.data = self._bufferStr.lowercased()
                self._bufferToken.selfClosing = true
            }
            self.advanceIndexAndResetCurrentStr()
        }
        //AttributeNameState
        stateMachine.listen(E.Equal, transit: [S.AttributeNameState,S.AfterAttributeValueQuotedState], to: S.BeforeAttributeValueState) { (t) in
            self._bufferToken.currentAttribute.name = self._bufferStr.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.advanceIndexAndResetCurrentStr()
        }
        //BeforeAttributeValueState
        stateMachine.listen(E.Quotation, transit: S.BeforeAttributeValueState, to: S.AttributeValueDoubleQuotedState) { (t) in
            self.advanceIndexAndResetCurrentStr()
        }
        //AttributeValueDoubleQuotedState
        stateMachine.listen(E.Quotation, transit: S.AttributeValueDoubleQuotedState, to: S.AfterAttributeValueQuotedState) { (t) in
            self._bufferToken.currentAttribute.value = self._bufferStr
            self._bufferToken.attributeList.append(self._bufferToken.currentAttribute)
            self._bufferToken.attributeDic[self._bufferToken.currentAttribute.name] = self._bufferToken.currentAttribute.value
            self._bufferToken.currentAttribute = Attribute()
            self.advanceIndexAndResetCurrentStr()
        }
        //AfterAttributeValueQuotedState
        stateMachine.listen(E.Slash, transit: S.AfterAttributeValueQuotedState, to: S.EndTagOpenState) { (t) in
            self._bufferToken.selfClosing = true
            self.advanceIndexAndResetCurrentStr()
        }
        stateMachine.listen(E.InStyleOrScript, transit: S.AfterAttributeValueQuotedState, to: S.PLAINTEXTState) { (t) in
            self.addHTMLToken()
            self.advanceIndexAndResetCurrentStr()
        }
        //MarkupDeclarationOpenState
        stateMachine.listen(E.DocType, transit: S.MarkupDeclarationOpenState, to: S.DOCTYPEState) { (t) in
            self._bufferToken.type = .DocType
            self.advanceIndexAndResetCurrentStr()
        }
        stateMachine.listen(E.DoubleMinus, transit: S.MarkupDeclarationOpenState, to: S.CommentStartState) { (t) in
            self._bufferToken.type = .Comment
            self.advanceIndexAndResetCurrentStr()
        }
        //CommentStartState
        stateMachine.listen(E.Minus, transit: S.CommentStartState, to: S.CommentEndDashState) { (t) in
            self._bufferToken.data = self._bufferStr
            self.advanceIndexAndResetCurrentStr()
        }
        //CommentEndDashState
        stateMachine.listen(E.Minus, transit: S.CommentEndDashState, to: S.CommentEndState) { (t) in
            self.advanceIndexAndResetCurrentStr()
        }
        //DOCTYPEState
        stateMachine.listen(E.Space, transit: S.DOCTYPEState, to: S.BeforeDOCTYPENameState) { (t) in
            self.advanceIndexAndResetCurrentStr()
        }
        //BeforeDOCTYPENameState
        stateMachine.listen(E.Space, transit: S.BeforeDOCTYPENameState, to: S.AfterDOCTYPENameState) { (t) in
            self._bufferToken.data = self._bufferStr
            self.advanceIndexAndResetCurrentStr()
        }
        //AfterDOCTYPENameState
        stateMachine.listen(E.Public, transit: S.AfterDOCTYPENameState, to: S.AfterDOCTYPEPublicKeywordState) { (t) in
            self.advanceIndexAndResetCurrentStr()
        }
        //AfterDOCTYPEPublicKeywordState
        stateMachine.listen(E.Space, transit: S.AfterDOCTYPEPublicKeywordState, to: S.BeforeDOCTYPEPublicIdentifierState) { (t) in
            self.advanceIndexAndResetCurrentStr()
        }
        //BeforeDOCTYPEPublicIdentifierState
        //暂时仅仅记录 DoubleQuoted 状态，不区分单引号和双引号
        stateMachine.listen(E.Quotation, transit: S.BeforeDOCTYPEPublicIdentifierState, to: S.DOCTYPEPublicIdentifierDoubleQuotedState) { (t) in
            self.advanceIndexAndResetCurrentStr()
        }
        //DOCTYPEPublicIdentifierDoubleQuotedState
        stateMachine.listen(E.Quotation, transit: S.DOCTYPEPublicIdentifierDoubleQuotedState, to: S.AfterDOCTYPEPublicIdentifierState) { (t) in
            //TODO:记录 doctypeData
            self.advanceIndexAndResetCurrentStr()
        }
        //PLAINTEXTState
        stateMachine.listen(E.AngleBracketLeft, transit: S.PLAINTEXTState, to: S.TagOpenState) { (t) in
            if self._bufferStr.count > 0 {
                self._bufferToken.type = .Char
                self._bufferToken.data = self._bufferStr
                self.addHTMLToken()
            }
            self._bufferToken.type = .StartTag
            self.advanceIndexAndResetCurrentStr()
        }
        
        while let aChar = currentChar {
            
            let aStr = aChar.description
            var hasAStrTrigger = false
            var hasBufferStrTrigger = false
            //deal with aStr
            if aStr == "!" {
                hasAStrTrigger = stateMachine.trigger(E.Exclamation)
            }
            if aStr == "<" {
                hasAStrTrigger = stateMachine.trigger(E.AngleBracketLeft)
            }
            if aStr == ">" {
                if _bufferToken.type == .StartTag && (_bufferToken.data.lowercased() == "style" || _bufferToken.data.lowercased() == "script") {
                    hasAStrTrigger = stateMachine.trigger(E.InStyleOrScript)
                } else {
                    hasAStrTrigger = stateMachine.trigger(E.AngleBracketRight)
                }
                
            }
            if aStr == " " {
                hasAStrTrigger = stateMachine.trigger(E.Space)
            }
            if self.isQuotation(s: aStr) {
                hasAStrTrigger = stateMachine.trigger(E.Quotation)
            }
            if aStr == "-" {
                hasAStrTrigger = stateMachine.trigger(E.Minus)
            }
            if aStr == "=" {
                hasAStrTrigger = stateMachine.trigger(E.Equal)
            }
            if aStr == "/" {
                hasAStrTrigger = stateMachine.trigger(E.Slash)
            }

            //deal with bufferStr
            if !hasAStrTrigger {
                addBufferStr(aStr)
            } else {
                continue
            }
            
            if _bufferStr.lowercased() == "doctype" {
                hasBufferStrTrigger = stateMachine.trigger(E.DocType)
            }
            if _bufferStr.lowercased() == "public" {
                hasBufferStrTrigger = stateMachine.trigger(E.Public)
            }
            if _bufferStr.lowercased() == "--" {
                hasBufferStrTrigger = stateMachine.trigger(E.DoubleMinus)
            }
            if !hasBufferStrTrigger {
                self.advanceIndex()
            }
        }
        return _tks
    }
    
    //tiny tool
    var currentChar: Character? {
        return _index < _input.endIndex ? _input[_index] : nil
    }
    func addBufferStr(_ bufferStr: String) {
        _bufferStr += bufferStr
    }
    func isQuotation(s:String) -> Bool {
        if s == "\"" || s == "'" {
            return true
        }
        return false
    }
    //添加 token
    func addHTMLToken() {
        let tk = _bufferToken
        _tks.append(tk)
        _bufferToken = HTMLToken()
    }
    func advanceIndex() {
        _input.characters.formIndex(after: &_index)
    }
    func advanceIndexAndResetCurrentStr() {
        _bufferStr = ""
        advanceIndex()
    }
    
    //枚举
    enum S: HTNStateType {
        case DataState //half done
        case CharacterReferenceInDataState
        case RCDATAState
        case CharacterReferenceInRCDATAState
        case RAWTEXTState
        case ScriptDataState
        case PLAINTEXTState
        case TagOpenState //half done
        case EndTagOpenState
        case TagNameState //half done
        
        case RCDATALessThanSignState
        case RCDATAEndTagOpenState
        case RCDATAEndTagNameState
        
        case RAWTEXTLessThanSignState
        case RAWTEXTEndTagOpenState
        case RAWTEXTEndTagNameState
        
        //Script
        case ScriptDataLessThanSignState
        case ScriptDataEndTagOpenState
        case ScriptDataEndTagNameState
        case ScriptDataEscapeStartState
        case ScriptDataEscapeStartDashState
        case ScriptDataEscapedState
        case ScriptDataEscapedDashState
        case ScriptDataEscapedDashDashState
        case ScriptDataEscapedLessThanSignState
        case ScriptDataEscapedEndTagOpenState
        case ScriptDataEscapedEndTagNameState
        case ScriptDataDoubleEscapeStartState
        case ScriptDataDoubleEscapedState
        case ScriptDataDoubleEscapedDashState
        case ScriptDataDoubleEscapedDashDashState
        case ScriptDataDoubleEscapedLessThanSignState
        case ScriptDataDoubleEscapeEndState
        
        //Tag
        case BeforeAttributeNameState
        case AttributeNameState //half done
        case AfterAttributeNameState
        case BeforeAttributeValueState
        case AttributeValueDoubleQuotedState //half done
        case AttributeValueSingleQuotedState
        case AttributeValueUnquotedState
        case CharacterReferenceInAttributeValueState
        case AfterAttributeValueQuotedState //half done
        case SelfClosingStartTagState
        case BogusCommentState
        case ContinueBogusCommentState
        case MarkupDeclarationOpenState //half done
        
        //Comment
        case CommentStartState //half done
        case CommentStartDashState
        case CommentState
        case CommentEndDashState //half done
        case CommentEndState //half done
        case CommentEndBangState
        
        //DOCTYPE
        case DOCTYPEState //half done
        case BeforeDOCTYPENameState //half done
        case DOCTYPENameState
        case AfterDOCTYPENameState //half done
        case AfterDOCTYPEPublicKeywordState //half done
        case BeforeDOCTYPEPublicIdentifierState //half done
        case DOCTYPEPublicIdentifierDoubleQuotedState //half done
        case DOCTYPEPublicIdentifierSingleQuotedState
        case AfterDOCTYPEPublicIdentifierState //half done
        case BetweenDOCTYPEPublicAndSystemIdentifiersState
        case AfterDOCTYPESystemKeywordState
        case BeforeDOCTYPESystemIdentifierState
        case DOCTYPESystemIdentifierDoubleQuotedState
        case DOCTYPESystemIdentifierSingleQuotedState
        case AfterDOCTYPESystemIdentifierState
        case BogusDOCTYPEState
        
        case CDATASectionState
        case CDATASectionRightSquareBracketState
        case CDATASectionDoubleRightSquareBracketState
    }
    enum E: HTNEventType {
        case Advance
        case AngleBracketLeft // <
        case AngleBracketRight // >
        case And // &
        case Space // 空格
        case Exclamation // !
        case DocType // doctype
        case Public // public
        case Quotation // ' 或 "
        case DoubleMinus // --
        case Minus // -
        case Equal // =
        case Slash // /
        case InStyleOrScript //
        case MarkEndTagForSure //TODO: fix script 里可能出现 < 符号的问题，这个事件触发发生在 _bufferStr == "</" 时，这时才能确保 script 的内容是结束了
    }
}
