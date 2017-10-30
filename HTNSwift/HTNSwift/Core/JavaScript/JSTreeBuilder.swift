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
        let combinedKeywordArray = ["*=","/=","%=","+=","-=","<<=",">>=",">>>=","&=","^=","|="]
    }
}
