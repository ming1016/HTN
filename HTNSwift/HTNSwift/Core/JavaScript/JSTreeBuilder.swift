//
//  JSTreeBuilder.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/30.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

public class JSTreeBuilder {
    var tokenizer: JSTokenizer
    public var currentToken: JSToken?
    
    private var _lastNode: JSNode       //上一个节点
    private var _currentNode: JSNode    //当前节点
    private var _currentParent: JSNode? // 当前父节点
    
    init(_ input: String) {
        tokenizer = JSTokenizer(input)
        _lastNode = JSNode()
        _currentNode = JSNode()
    }
    
    func parser() {
//        let combinedKeywordArray = ["*=","/=","%=","+=","-=","<<=",">>=",">>>=","&=","^=","|="]
        let tks = tokenizer.parse()
        var stackNode = [JSNode]()
        let stateMachine = HTNStateMachine<S,E>(S.UnknownState)
        
        stateMachine.listen(E.VarEvent, transit: S.UnknownState, to: S.BeforeJScriptVarStatementState) { (t) in
            self._currentNode = JSNode.JScriptVarStatementNode()
            if self._currentNode is JSNode.JScriptVarStatementNode {
                
            }
        }
        
        for tk in tks {
            //
            if tk.type == .KeyWords {
                //JScriptVarStatement
                if tk.data == "var" {
                    _ = stateMachine.trigger(E.VarEvent)
                }
            }
        }
    }
    
    enum S: HTNStateType {
        case UnknownState
        case BeforeJScriptVarStatementState
    }
    enum E: HTNEventType {
        case VarEvent
    }
    
    
}
