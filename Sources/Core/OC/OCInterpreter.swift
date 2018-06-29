//
//  OCInterpreter.swift
//  HTN
//
//  Created by DaiMing on 2018/6/5.
//

import Foundation

public class OCInterpreter {
    
    private var lexer: OCLexer
    private var currentTk: OCToken
    
    public init(_ input: String) {
        lexer = OCLexer(input)
        currentTk = lexer.nextTk()
    }
    
    // eval
    public func eval(node: OCAST) -> OCValue {
        switch node {
        case let number as OCNumber:
            return eval(number: number)
        case let unaryOperation as OCUnaryOperation:
            return eval(unaryOperation: unaryOperation)
        case let binOp as OCBinOp:
            return eval(binOp: binOp)
        default:
            return .none
        }
    }
    
    func eval(number: OCNumber) -> OCValue {
        return .number(number)
    }
    
    func eval(binOp: OCBinOp) -> OCValue {
        guard case let .number(leftResult) = eval(node: binOp.left), case let .number(rightResult) = eval(node: binOp.right) else {
            fatalError("Error! binOp is wrong")
        }
        
        switch binOp.operation {
        case .plus:
            return .number(leftResult + rightResult)
        case .minus:
            return .number(leftResult - rightResult)
        case .mult:
            return .number(leftResult * rightResult)
        case .intDiv:
            return .number(leftResult / rightResult)
        }
    }
    
    func eval(unaryOperation: OCUnaryOperation) -> OCValue {
        guard case let .number(result) = eval(node: unaryOperation.operand) else {
            fatalError("Error: eval unaryOperation")
        }
        switch unaryOperation.operation {
        case .plus:
            return .number(+result)
        case .minus:
            return .number(-result)
        }
    }
    
    public func expr() -> OCAST {
        var node = term()
        
        while [.operation(.plus), .operation(.minus)].contains(currentTk) {
            let tk = currentTk
            eat(currentTk)
            if tk == .operation(.plus) {
                node = OCBinOp(left: node, operation: .plus, right: term())
            } else if tk == .operation(.minus) {
                node = OCBinOp(left: node, operation: .minus, right: term())
            }
        }
        return node
    }
    
    // 语法解析中对数字的处理
    private func term() -> OCAST {
        var node = factor()
        
        while [.operation(.mult), .operation(.intDiv)].contains(currentTk) {
            let tk = currentTk
            eat(currentTk)
            if tk == .operation(.mult) {
                node = OCBinOp(left: node, operation: .mult, right: factor())
            } else if tk == .operation(.intDiv) {
                node = OCBinOp(left: node, operation: .intDiv, right: factor())
            }
        }
        return node
    }
    
    private func factor() -> OCAST {
        let tk = currentTk
        switch tk {
        case .operation(.plus):
            eat(.operation(.plus))
            return OCUnaryOperation(operation: .plus, operand: factor())
        case .operation(.minus):
            eat(.operation(.minus))
            return OCUnaryOperation(operation: .minus, operand: factor())
        case let .constant(.integer(result)):
            eat(.constant(.integer(result)))
            return OCNumber.integer(result)
        case .paren(.left):
            eat(.paren(.left))
            let result = expr()
            eat(.paren(.right))
            return result
        default:
            return OCNumber.integer(0)
        }
    }
    
    private func eat(_ token: OCToken) {
        if  currentTk == token {
            currentTk = lexer.nextTk()
            if currentTk == OCToken.whiteSpaceAndNewLine {
                currentTk = lexer.nextTk()
            }
        } else {
            error()
        }
    }
    
    func error() {
        fatalError("Error!")
    }
    
    
}
