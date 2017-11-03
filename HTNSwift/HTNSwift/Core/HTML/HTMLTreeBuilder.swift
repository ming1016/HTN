//
//  HTMLTreeBuilder.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/11.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

public class HTMLTreeBuilder {
    var tokenizer: HTMLTokenizer
    public var doc: Document
    public var currentToken: HTMLToken?
    
    private var _lastElement: Element //TODO: 上一个元素，暂时无用
    private var _currentElement: Element //当前元素
    private var _currentParent: Element? //当前元素父元素
    
    init(_ input: String) {
        doc = Document()
        tokenizer = HTMLTokenizer(input)
        _lastElement = Element()
        _currentElement = Element()
    }
    
    func parse() -> [HTMLToken] {
        
        let tks = tokenizer.parse() //词法分析
        
        var stackElement = [Element]() //为了父子级别而记录深度的堆栈
        let stateMachine = HTNStateMachine<S,E>(S.BeforeHTMLState)
        
        stateMachine.listen(E.StartTagEvent, transit: S.InitialModeState, to: S.BeforeHTMLState) { (t) in
            //TODO:暂时只支持 html 标签内，所以外部的定义先不处理
        }
        stateMachine.listen(E.StartTagEvent, transit: S.BeforeHTMLState, to: S.BeforeHeadState) { (t) in
            //TODO:根 Node Document
        }
        stateMachine.listen(E.StartTagEvent, transit: S.BeforeHeadState, to: S.InHeadState) { (t) in
            //
        }
        stateMachine.listen(E.CharEvent, transit: S.InHeadState, to: S.InHeadState) { (t) in
            //在 head 里
            if self._currentParent?.startTagToken?.data == "style" {
                self.doc.styleList.append(self._currentElement)
            }
            if self._currentParent?.startTagToken?.data == "script" {
                self.doc.scriptList.append(self._currentElement)
            }
        }
        
        //InHeadState
        stateMachine.listen(E.EndHeadTagEvent, transit: S.InHeadState, to: S.AfterHeadState) { (t) in
            //
        }
        
        //AfterHeadState
        stateMachine.listen(E.StartTagEvent, transit: S.AfterHeadState, to: S.InBodyState) { (t) in
            //
        }
        stateMachine.listen(E.StartTagEvent, transit: S.InBodyState, to: S.InBodyState) { (t) in
            //TODO: 处理 inline style
        }
        
        //TODO: AfterBodyState 和 AfterAfterBodyState 的情况
        
        for tk in tks {
            var hasTrigger = false
            //TODO：现将无关的过滤之，以后再做处理
            if tk.type == .StartTag || tk.type == .Char || tk.type == .EndTag {
            } else {
                continue
            }
            _currentElement = Element(token: tk)
            //根元素的处理
            if tk.data == "html" && tk.type == .StartTag {
                _currentElement = Document(token: tk)
                doc = _currentElement as! Document
            }
            
            //StartTag
            if tk.type == .StartTag {
                stackElement.append(_currentElement) //堆栈添加
                
                //子关闭标签的情况
                if tk.selfClosing {
                    _ = stackElement.popLast()
                    _currentParent = stackElement.last
                    self.parentAppendChild()
                } else {
                    self.parentAppendChild()
                    _currentParent = _currentElement
                }
                
                hasTrigger = stateMachine.trigger(E.StartTagEvent)
            }
            
            //Char
            if tk.type == .Char {
                //添加子结点
                self.parentAppendChild()
                hasTrigger = stateMachine.trigger(E.CharEvent)
            }
            
            //EndTag
            if tk.type == .EndTag {
                //pop 出堆栈
                _ = stackElement.popLast()
                _currentParent = stackElement.last
                if tk.data == "head" {
                    hasTrigger = stateMachine.trigger(E.EndHeadTagEvent)
                } else {
                    hasTrigger = stateMachine.trigger(E.EndTagEvent)
                }
            }
            if hasTrigger {
                
            }
        }
        
        return tks
    }
    
    func parentAppendChild() {
        _currentElement.parent = _currentParent
        _currentParent?.children.append(_currentElement)
    }
    
    //TODO: 按照 w3c 的状态来。
    //w3c 的定义：https://www.w3.org/TR/html5/syntax.html#html-parser
    enum S: HTNStateType {
        case InitialModeState
        case BeforeHTMLState
        case BeforeHeadState
        case InHeadState
        case AfterHeadState
        case InBodyState
        case AfterBodyState
        case AfterAfterBodyState
    }
    
    enum E: HTNEventType {
        case StartTagEvent
        case CharEvent
        case EndTagEvent
        case EndHeadTagEvent // </head>
        case EndBodyTagEvent //TODO: 先不处理 </body> 标签后的情况
    }
    
}
