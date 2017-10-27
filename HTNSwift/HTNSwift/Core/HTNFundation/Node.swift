//
//  Node.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/11.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

public class Node {
    public weak var parent: Node?
    public var children = [Node]()
    
    init() {
        
    }
}
