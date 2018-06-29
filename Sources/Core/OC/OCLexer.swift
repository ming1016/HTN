//
//  OCLexer.swift
//  HTN
//
//  Created by DaiMing on 2018/6/10.
//

import Foundation

public class OCLexer {
    private let text: String
    private var currentIndex: Int
    private var currentCharacter: Character?
    
    public init(_ input: String) {
        if input.count == 0 {
            fatalError("Error! input can't be empty")
        }
        self.text = input
        currentIndex = 0
        currentCharacter = text[text.startIndex]
    }
    
    // 流程函数
    func nextTk() -> OCToken {
        if currentIndex > self.text.count - 1 {
            return .eof
        }
        
        if CharacterSet.whitespacesAndNewlines.contains((currentCharacter?.unicodeScalars.first!)!) {
            skipWhiteSpaceAndNewLines()
            return .whiteSpaceAndNewLine
        }
        
        if CharacterSet.decimalDigits.contains((currentCharacter?.unicodeScalars.first!)!) {
            return number()
        }
        
        if currentCharacter == "+" {
            advance()
            return .operation(.plus)
        }
        if currentCharacter == "-" {
            advance()
            return .operation(.minus)
        }
        if currentCharacter == "*" {
            advance()
            return .operation(.mult)
        }
        if currentCharacter == "/" {
            advance()
            return .operation(.intDiv)
        }
        if currentCharacter == "(" {
            advance()
            return .paren(.left)
        }
        if currentCharacter == ")" {
            advance()
            return .paren(.right)
        }
        if currentCharacter == "@" {
            
        }
        advance()
        return .eof
    }
    // @符号的处理
    private func at() -> OCToken {
        advance()
        var atStr = ""
        while let character = currentCharacter,  CharacterSet.whitespacesAndNewlines.contains((character.unicodeScalars.first!)) {
            atStr += String(character)
            advance()
        }
        if atStr == "interface" {
            return .atInterface
        }
        fatalError("Error: at string not support")
    }
    // 数字处理
    private func number() -> OCToken {
        var numStr = ""
        while let character = currentCharacter,  CharacterSet.decimalDigits.contains((character.unicodeScalars.first!)) {
            numStr += String(character)
            advance()
        }
        return .constant(.integer(Int(numStr)!))
    }
    
    // 辅助函数
    private func advance() {
        currentIndex += 1
        guard currentIndex < text.count else {
            currentCharacter = nil
            return
        }
        currentCharacter = text[text.index(text.startIndex, offsetBy: currentIndex)]
    }
    
    // 往前探一个字符，不改变当前字符
    private func peek() -> Character? {
        let peekIndex = currentIndex + 1
        guard peekIndex < text.count else {
            return nil
        }
        return text[text.index(text.startIndex, offsetBy: peekIndex)]
    }
    
    private func skipWhiteSpaceAndNewLines() {
        while let character = currentCharacter, CharacterSet.whitespacesAndNewlines.contains((character.unicodeScalars.first!)) {
            advance()
        }
    }
}
