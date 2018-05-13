//
//  VueTest.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/5/10.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation
import HTN

class VueTest {
    var isPrintable = true
    let _case_tmp = """
var a _= c
var b = ${}
var d = a / 34.3 + 3 * k
"""
    let _case_1 = """
const tokens = [45,34.5,"this","is","case1 content is const tokens = [\\"bulabula\\"]"];
if (/[0-9]/.test(currentChar)) {
    var num = 1244.7 % 889;
}
"""
    let _case_1_hash = """
const|const:tokens|none:=|eq:[|braceL:45|float:,|comma:34.5|float:,|comma:this|string:,|comma:is|string:,|comma:case1 content is const tokens = [slash"bulabulaslash"]|string:]|braceR:if|if:(|parenL:/[0-9]/|regular:.|dot:test|none:(|parenL:currentChar|none:)|parenR:)|parenR:{|braceL:var|var:num|none:=|eq:1244.7|float:%|modulo:889|float:}|braceR:
"""
    
    func LetTestBegin() {
        checkCase_1()
        checkCase_2()
    }
    
    // 检查 Case
    // Case2
    func checkCase_2() {
        let tks = JTokenizer(_case_tmp).tokenizer()
        let hash = hashFrom(tokens: tks)
    }
    // Case1 包含了字符串，正则，数字还有基本的 token 的测试
    func checkCase_1() {
        let tks = JTokenizer(_case_1).tokenizer()
        if isPrintable {
            print("Case1 String is:\(_case_1)")
        }
        let hash = hashFrom(tokens: tks)
        caseResultPrint(hash: hash, rightHash: _case_1_hash, caseStr: "case1")
    }
    
    // 打印的方法
    func caseResultPrint(hash: String, rightHash: String, caseStr: String) {
        if hash == rightHash {
            print("\(caseStr) ✅")
        } else {
            print("\(caseStr) ❌")
        }
    }
    // 打印 token 并返回 hash 的 token
    func hashFrom(tokens:[JToken]) -> String {
        var hash = ""
        for tk in tokens {
            if isPrintable {
                print("\(tk.value)      :::    \(tk.type.rawValue)")
            }
            hash.append("\(tk.value)|\(tk.type.rawValue):")
        }
        let reHash = hash.replacingOccurrences(of: "\\", with: "slash")
        if isPrintable {
            print(reHash)
        }
        return reHash
    }
}
