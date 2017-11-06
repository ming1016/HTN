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
    public var rootNode: JSNode
    
    private var _currentToken = JSToken() //当前的 token
    private var _lastNode: JSNode       //上一个节点
    private var _currentNode: JSNode    //当前节点
    private var _currentParent: JSNode? // 当前父节点
    
    
    init(_ input: String) {
        tokenizer = JSTokenizer(input)
        rootNode = JSNode()
        _lastNode = JSNode()
        _currentNode = JSNode()
    }
    
    func parser() {
//        let combinedKeywordArray = ["*=","/=","%=","+=","-=","<<=",">>=",">>>=","&=","^=","|="]
        let tks = tokenizer.parse()
        var stackNode = [JSNode]()
        let stateMachine = HTNStateMachine<S,E>(S.UnknownState)
        
        _currentParent = rootNode
        
        //碰到 var 需要创建新节点
        stateMachine.listen(E.VarEvent, transit: S.UnknownState, to: S.StartVarState) { (t) in
            self._currentNode = JSNode()
            self._currentNode.type = .VariableDeclaration
            stackNode.append(self._currentNode)
            self.parentAppendChild()
        }
        stateMachine.listen(E.CharEvent, transit: S.StartVarState, to: S.StartVarIdentifierState) { (t) in
            self._currentNode = JSNode()
            self._currentNode.type = .Identifier
            self._currentNode.data = self._currentToken.data
            stackNode.append(self._currentNode)
        }
        
        
        _currentParent = rootNode
        for tk in tks {
            //
            _currentToken = tk
            if tk.type == .KeyWords {
                //开始 JScriptVarDeclarationNode
                if tk.data == "var" {
                    _ = stateMachine.trigger(E.VarEvent)
                }
            }
            if tk.type == .Char {
                _ = stateMachine.trigger(E.CharEvent)
            }
        }
    }
    
    //help
    func parentAppendChild() {
        _currentNode.parent = _currentParent
        _currentParent?.children.append(_currentNode)
        _currentParent = _currentNode
    }
    
    enum S: HTNStateType {
        case UnknownState
        case StartRoundBracketLeftState
        
        case StartVarState
        case StartVarIdentifierState
        
        case StartFunctionState
        case InFunctionBodyState
        case StartEqualState
        case StartForState
    }
    enum E: HTNEventType {
        //char
        case CharEvent        // char 类型
        //可能会开始新 Node 的事件
        case RoundBracketLeftEvent // (
        case VarEvent         // var
        case FunctionEvent    // function
        case EqualEvent       // =
        case ForEvent         // for
        case WhileEvent       // while
        case IfEvent          // if
        case TryEvent         // try
        case ReturnEvent      // return
        case typeofEvent      // typeof
        
    }
}
