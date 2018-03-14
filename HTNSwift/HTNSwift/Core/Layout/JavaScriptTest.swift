//
//  JavaScriptTest.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/14.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

class JavaScriptTest {
    fileprivate var isInWidget = false
    
    func dealWithJSNodes(nodes:[Node]) {
        for aNode in nodes {
            recursionNode(node: aNode as! JSNode,level: 0)
        }
    }
    
    func recursionNode(node:JSNode, level: Int) {
        if node.type == .Literal {
            if node.data == "widgets" {
                
            }
        }
        if node.children.count > 0 {
            for aNode in node.children {
                recursionNode(node: aNode as! JSNode, level: level + 1)
            }
        }
    }
}
