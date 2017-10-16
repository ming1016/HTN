//
//  CSSSelector.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/15.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

public class CSSSelector {
    public var path : String {
        get {
            return String()
        }
        set(newPath) {
            self.identifier = newPath.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.matchList = self.identifier.components(separatedBy: " ")
        }
    }
    public var matchList = [String]()
    public var identifier = ""
}
