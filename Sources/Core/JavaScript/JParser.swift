//
//  JParser.swift
//  HTN
//
//  Created by DaiMing on 2018/4/28.
//

import Foundation

public class JParser {
    private var _tkIndex = 0
    private var _tks = [JToken]()
    
    private var _currentTk: JToken {
        if _tkIndex < _tks.count {
            return _tks[_tkIndex]
        }
        return JToken()
    }
    
    private var _nextTk: JToken {
        if _tkIndex + 1 < _tks.count {
            return _tks[_tkIndex + 1]
        }
        return JToken()
    }
    
    private func eat(_ tkType: JTokenType) -> Bool {
        if _currentTk.type == tkType {
            _tkIndex += 1
            return true
        } else {
            fatalError("Error, next token not expect as \(tkType.rawValue)")
            return false
        }
    }
    
    // TODO: 未完成时用的，完成时应该去掉这个方法。每个 token 的前进都需要通过 eat 函数来
    private func advance() {
        _tkIndex += 1
    }
    
    public init(_ input: String) {
        _tks = JTokenizer(input).tokenizer()
        var eofTk = JToken()
        eofTk.type = .eof
        _tks.append(eofTk)
        print(_tks)
    }
    
    // 文件 parse 的起始函数
    public func parser() -> JNodeProgram {
        let programNode = JNodeProgram(sourceType: .module, body: [JNodeStatement](), directives: [JNodeDirective]())
        parseBlockBody(program: programNode, end: .eof)
        return programNode
    }
    
    private func parseBlockBody(program: JNodeProgram, end: JTokenType) {
        parseBlockOrModuleBlockBody(program: program, end: end)
    }
    
    private func parseBlockOrModuleBlockBody(program: JNodeProgram, end: JTokenType) {
//        while !eat(.eof) {
//
//        }
        var end = false
        while !end {
            let stmt = parseStatement()
            if stmt.type == "" {
                end = true
            } else {
                program.body.append(stmt)
            }
            
        }
        
    }
    
    private func parseStatement() -> JNodeStatement {
        // TODO * decorator
        return parseStatementContent()
    }
    
    private func parseStatementContent() -> JNodeStatement {
        let startType = _currentTk.type
        var node:JNodeStatement = JNodeStatementBase()
        guard startType != .none else {
            node.type = ""
            return node
        }
        
        print("\(_currentTk)")
        switch startType {
        case .break, .continue:
            node = parseBreakContinueStatement()
        case .debugger:
            node = parseDebuggerStatement()
        case .do:
            node = parseDoStatement()
        case .for:
            node = parseForStatement()
        case .function:
            // TODO: 需要通过查找前一个 token 看看类型是否是 dot，如果是就 break
            node = parseFunctionStatement()
        case .class:
            node = parseClass()
        case .if:
            node = parseIfStatement()
        case .return:
            node = parseReturnStatement()
        case .switch:
            node = parseSwitchStatement()
        case .throw:
            node = parseThrowStatement()
        case .try:
            node = parseTryStatement()
        case .let, .const, .var:
            node = parseVarStatement(kind: startType)
        case .while:
            node = parseWhileStatement()
        case .with:
            node = parseWithStatement()
        case .braceL:
            node = parseBlock()
        case .semi: // ;
            node = parseEmptyStatement()
        case .export:
            node = parseExport()
        case .import:
            node = parseImport()
        case .name:
            doNothing()
        default:
            doNothing()
        }
        
        let exp = parseExpression()
        
        if exp.type == "Identifier" {
            node = parseLabeledStatement()
        } else {
            node = parseExpressionStatement()
        }
        
        advance()
        return node
    }
    
    // ------ 不同节点类型 Parser --------
    func parseBreakContinueStatement() -> JNodeContinueStatement {
        return JNodeContinueStatement(label: JNodeIdentifier(name: ""))
    }
    
    func parseDebuggerStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseDoStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseForStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseFunctionStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseClass() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseIfStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseReturnStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseSwitchStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseThrowStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseTryStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseVarStatement(kind: JTokenType) -> JNodeVariableDeclaration {
        advance()
        let node = parseVar(kind: kind)
        _ = eat(.eof)
        return node
    }
    
    func parseVar(kind: JTokenType) -> JNodeVariableDeclaration {
        let declarations = [JNodeVariableDeclarator]()
        
        var end = false
        while !end {
            let pt = parseVarHead()
            if eat(.eq) {
                
            }
//            let decl = JNodeVariableDeclarator(id: JNodePattern(, initialization: )
        }
        
        return JNodeVariableDeclaration(declarations: declarations, kind: kind.rawValue)
    }
    
    func parseVarHead() -> JNodePattern {
        return parseBindingAtom()
    }
    
    func parseBindingAtom() -> JNodePattern {
        switch _currentTk.type {
        case .yield, .name:
            return parseBindingIdentifier()
        default:
            doNothing()
        }
        return parseBindingIdentifier()
    }
    
    func parseBindingIdentifier() -> JNodeIdentifier {
        var name = ""
        if eat(.name) {
            name = _currentTk.value
        }
        return JNodeIdentifier(name: name)
    }
    
    func parseWhileStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseWithStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseBlock() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseEmptyStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseImport() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseExport() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseExpression() -> JNodeExpression {
        return JNodeExpressionBase()
    }
    
    func parseExpressionStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseLabeledStatement() -> JNodeLabeledStatement {
        return JNodeLabeledStatement(label: JNodeIdentifier(name: ""), body: parseStatement())
    }
    
    
    // 临时占位
    private func doNothing() {
        
    }
}


