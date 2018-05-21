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
    
    private func match(_ tkType: JTokenType) -> Bool {
        return _currentTk.type == tkType
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
    
    // DONE
    private func parseBlockBody(program: JNodeProgram, end: JTokenType) {
        parseBlockOrModuleBlockBody(program: program, end: end)
    }
    
    // DONE
    private func parseBlockOrModuleBlockBody(program: JNodeProgram, end: JTokenType) {

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
    
    // DONE
    private func parseStatement() -> JNodeStatement {
        // TODO * decorator
        return parseStatementContent()
    }
    
    // TODO:
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
    
    // DONE
    func parseVarStatement(kind: JTokenType) -> JNodeVariableDeclaration {
        advance()
        let node = parseVar(kind: kind)
        _ = eat(.eof)
        return node
    }
    
    // DONE
    func parseVar(kind: JTokenType) -> JNodeVariableDeclaration {
        var declarations = [JNodeVariableDeclarator]()
        var end = false
        while !end {
            let id = parseVarHead()
            var initialization:JNodeExpression? = nil
            if eat(.eq) {
                initialization = parseMaybeAssign()
            }
            declarations.append(JNodeVariableDeclarator(id: id, initialization: initialization))
            if !eat(.comma) {
                end = true
            }
        }
        
        return JNodeVariableDeclaration(declarations: declarations, kind: kind.rawValue)
    }
    
    // DONE
    func parseVarHead() -> JNodePattern{
        return parseBindingAtom()
    }
    
    // DONE
    func parseBindingAtom() -> JNodePattern {
        switch _currentTk.type {
        case .yield, .name:
            return parseBindingIdentifier()
        case .bracketL:
            // TODO: ArrayPattern 的处理
            _ = eat(.bracketL)
            let elements = parseBindingList(close: .bracketR)
            return JNodeArrayPattern(elements: elements)
        case .braceL:
            // { 大括号处理
            return parseObj(isPattern: true)
        default:
            fatalError("parseBindingAtom expect legal token")
        }
    }
    
    // TODO: 类型复杂处理里面的元素后再回头过来处理不同类型的返回
    func parseObj<T>(isPattern: Bool) -> T {
        
        // TODO: propHash
        var first = true
        var properties = [JNode]()
        advance()
        
        while !eat(.braceR) {
            var prop = JNodeSpreadElement(argument: JNodeExpressionBase())
            var decorators = [JNodeDecorator]()
            if first {
                first = false
            } else {
                _ = eat(.comma)
                if eat(.braceR) {
                    break
                }
            }
            
            // deal with decorator
            if match(.at) {
                while match(.at) {
                    decorators.append(parseDecorator())
                }
            }
            
            // deal with ...
            if match(.ellipsis) {
                let sp = parseSpread()
                properties.append(sp)
                if isPattern {
                    if eat(.braceR) {
                        break
                    } else {
                        continue
                    }
                } else {
                    continue
                }
            }
            
            // to be continue
            var method = false
            var isGenerator = false
            
            if !isPattern {
                isGenerator = eat(.star)
            }
            let key = parsePropertyName()
            let val = parseObjPropValue(left:key, isPattern: isPattern)
            
            // TODO: 返回的 key 和 val 需要根据返回的类型进行不同的处理，返回不同的 properties。
            // properties 需要根据上面的结果继续添加
            
        }
        
        return JNodeObjectPattern(properties: properties) as! T
    }
    
    // DONE
    func parsePropertyName() -> JNode {
        var key:JNodeExpression = JNodeExpressionBase()
        if eat(.bracketL) {
            key = parseMaybeAssign()
            _ = eat(.bracketR)
        } else {
            if match(.int) || match(.float) || match(.string) {
                key = parseExprAtom()
            } else {
                return parseMaybePrivateName()
            }
        }
        
        return key
    }
    
    // DONE
    func parseObjPropValue(left: JNode, isPattern: Bool) -> JNode {
        var node:JNode? = parseObjectMethod()
        if node == nil {
            node = parseObjectProperty(left: left, isPattern: isPattern) // 返回 value
            if node == nil {
                fatalError("parseObjPropValue error")
            }
        }
        
        return node!
    }
    
    // DONE
    func parseObjectProperty(left: JNode, isPattern: Bool) -> JNode {
        if eat(.colon) {
            if isPattern {
                return parseMaybeDefault(left: left as? JNodePattern)
            } else {
                return parseMaybeAssign()
            }
        }
        
        if isPattern || match(.eq) {
            return parseMaybeDefault(left: left as? JNodePattern)
        } else {
            fatalError("parseObjectProperty wrong")
        }
    }
    
    // DONE
    func parseObjectMethod() -> JNodeFunction? {
        if match(.parenL) {
            return parseMethod()
        }
        return nil
    }
    
    // DONE
    func parseMethod() -> JNodeFunction {
        return JNodeFunction(id: JNodeIdentifier(name: ""), params: parseFunctionParams(), body: parseFunctionBodyAndFinish(), generator: false, async: false)
    }
    
    // DONE 暂时用不着
    func initFunction() {
        //
    }
    
    // DONE
    func parseFunctionParams() -> [JNodePattern] {
        _ = eat(.parenL)
        return parseBindingList(close: .parenR) as! [JNodePattern]
    }
    
    // DONE
    func parseFunctionBodyAndFinish() -> JNodeBlockStatement {
        return parseFunctionBody()
    }
    
    // DONE
    func parseFunctionBody() -> JNodeBlockStatement {
        return parseBlock()
    }
    
    // TODO:
    func parseSpread() -> JNodeSpreadElement {
        return JNodeSpreadElement(argument: JNodeExpressionBase())
    }
    
    // TODO:
    func parseDecorator() -> JNodeDecorator {
        return JNodeDecorator(expression: JNodeExpressionBase())
    }
    
    // DONE
    func parseBindingIdentifier() -> JNodeIdentifier {
        var name = ""
        if eat(.name) {
            name = _currentTk.value
        }
        return JNodeIdentifier(name: name)
    }
    
    // DONE
    // 数组 []
    func parseBindingList(close: JTokenType, allowEmpty:Bool = true) -> [JNodePattern?] {
        var elts = [JNodePattern?]()
        var first = true
        
        while !eat(close) {
            if first {
                first = false
            } else {
                _ = eat(.comma)
            }
            
            if allowEmpty && eat(.comma) {
                elts.append(nil)
            } else if eat(close) {
                break
            } else if match(.ellipsis) {
                // TODO: parseAssignableListItemTypes
                elts.append(parseAssignableListItemTypes(param: parseRest()))
                _ = eat(close)
                break
            } else {
                // TODO: decorators
                elts.append(parseAssignableListItem())
            }
        }
        
        return elts
    }
    
    // DONE
    func parseRest() -> JNodeRestElement {
        advance()
        let argument = parseBindingAtom()
        return JNodeRestElement(argument: argument)
    }
    
    // DONE
    func parseAssignableListItem() -> JNodePattern {
        var left = parseMaybeDefault(left: nil)
        // TODO: 通过 parseAssignableListItemTypes 来转换为 JNodePattern 类型
        left = parseAssignableListItemTypes(param: left)
        let elt = parseMaybeDefault(left: left)
        return elt
    }
    
    // DONE
    func parseAssignableListItemTypes(param: JNodePattern) -> JNodePattern {
        return param
    }
    
    // DONE 没有 = 号的只返回左边
    func parseMaybeDefault(left: JNodePattern?) -> JNodePattern {
        var mLeft = left
        if left == nil {
            mLeft = parseBindingAtom()
        }
        if !eat(.eq) {
            return mLeft!
        }
        return JNodeAssignmentPattern(left: mLeft!, right: parseMaybeAssign())
    }
    
    // DONE
    func parseMaybeAssign() -> JNodeExpression {
        // TODO: yield afterLeftParse
        let left = parseMaybeConditional()
        
        if _currentTk.isAssign {
            let opt = _currentTk.value
            
            if match(.eq) {
                toAssignable(node: left)
            }
            advance()
            let right = parseMaybeAssign()
            return JNodeAssignmentExpression(operator: opt, left: left, right: right)
        }
        
        return left
    }
    
    // DONE
    func parseMaybeConditional() -> JNodeExpression {
        let expr = parseExprOps()
        if expr.type == "ArrowFunctionExpression" {
            return expr
        }
        return parseConditional(expr: expr)
    }
    
    // DONE
    func parseMaybePrivateName() -> JNode {
        let isPrivate = match(.hash) // #
        if isPrivate {
            advance()
            return JNodePrivateName(id: parseIdentifier())
        } else {
            return parseIdentifier()
        }
    }
    
    // DONE
    func parseIdentifier() -> JNodeIdentifier {
        let name = parseIdentifierName()
        return JNodeIdentifier(name: name)
    }
    
    // DONE
    func parseIdentifierName() -> String {
        var name = ""
        if match(.name) ||  _currentTk.isKeyword {
            name = _currentTk.value
        }
        
        advance()
        
        return name
        
    }
    
    // TODO:
    func parseConditional(expr: JNodeExpression) -> JNodeExpression {
        return JNodeExpressionBase()
    }
    
    // DONE
    func parseExprOps() -> JNodeExpression {
        let expr = parseMaybeUnary()
        if expr.type == "ArrowFunctionExpression" {
            return expr
        }
        return parseExprOp(left: expr)
    }
    
    // TODO:
    func parseExprOp(left: JNodeExpression) -> JNodeExpression {
        return JNodeExpressionBase()
    }
    
    // DONE
    func parseMaybeUnary() -> JNodeExpression {
        if _currentTk.prefix {
            let update = match(.incDec)
            let opt = _currentTk.value
            let prefix = true
            
            advance()
            let argument = parseMaybeUnary()
            
            if update {
                return JNodeUpdateExpression(operator: opt, argument: argument, prefix: prefix)
            } else {
                return JNodeUnaryExpression(operator: opt, prefix: prefix, argument: argument)
            }
        }
        
        var expr = parseExprSubscripts()
        
        while _currentTk.postfix && !canInsertSemicolon() {
            let opt = _currentTk.value
            let prefix = false
            let argument = expr
            advance()
            expr = JNodeUpdateExpression(operator: opt, argument: argument, prefix: prefix)
        }
        return expr
    }
    
    // DONE
    func parseExprSubscripts() -> JNodeExpression {
        // TODO: potential arrow function
        let expr = parseExprAtom()
        
        if expr.type == "ArrowFunctionExpression" {
            return expr
        }
        
        return parseSubscripts(base: expr)
    }
    
    // DONE
    func parseSubscripts(base: JNodeExpression) -> JNodeExpression {
        var reBase = base
        let state = ParseSubscriptState()
        while !state.stop {
            //
            reBase = parseSubscript(expr: reBase, state: state)
        }
        return reBase
    }
    
    // TODO:
    func parseSubscript(expr: JNodeExpression, state: ParseSubscriptState) -> JNodeExpression {
        
        return JNodeExpressionBase()
    }
    
    // TODO:
    func parseExprAtom() -> JNodeExpression {
        return JNodeExpressionBase()
    }
    
    
    func parseWhileStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseWithStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    // TODO:
    func parseBlock() -> JNodeBlockStatement {
        return JNodeBlockStatement(body: [JNodeStatement](), directives: [JNodeDirective]())
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
    
    // TODO:
    func toAssignable(node: JNode) -> JNode {
        return JNodeBase()
    }
    
    // 工具函数
    // DONE
    func canInsertSemicolon() -> Bool {
        // TODO: hasPrecedingLineBreak
        return match(.eof) || match(.braceR)
    }
    
    // 临时占位
    private func doNothing() {
        
    }
}

// Other

public class ParseSubscriptState {
    var optionalChainMember = false
    var stop = false
}
