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
    let _case_1 = """
const tokens = ["this","is","case1 content is const tokens = [bulabula,\\"bulabula\\"]"];
if (/[0-9]/.test(currentChar)) {

}
"""
    
    func LetTestBegin() {
        
        
        checkCase_1()
    }
    
    // 检查 Case
    func checkCase_1() {
        let case1 = JTokenizer(_case_1).tokenizer()
        if isPrintable {
            print("Case1 String is:\(_case_1)")
            printJTokens(case1)
        }
    }
    
    // 打印的方法
    func printJTokens(_ tks:[JToken]) {
        for tk in tks {
            //print("Token is:")
            print(tk.value)
            
//            print(" is \"\(tk.value)\" type is \(tk.type.rawValue)")
        }
    }
}
