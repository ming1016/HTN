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
    private var _lastTK = JToken()
    
    // 返回当前 token
    private var _currentTk: JToken {
        if _tkIndex < _tks.count {
            return _tks[_tkIndex]
        }
        return JToken()
    }
    
    // 下一个 token
    private var _nextTk: JToken {
        if _tkIndex + 1 < _tks.count {
            return _tks[_tkIndex + 1]
        }
        return JToken()
    }
    
    // 当前 token 如果符合入参指定类型就 eat 掉，同时当前 token 变为下一个 token
    private func eat(_ tkType: JTokenType) -> Bool {
        if _currentTk.type == tkType {
            advance()
            return true
        } else {
            print("Error, next token not expect as \(tkType.rawValue)")
            return false
            //fatalError("Error, next token not expect as \(tkType.rawValue)")
        }
    }
    
    // 和 eat 一样，但是没有返回布尔值，如果不匹配直接报错
    private func expect(_ tkType: JTokenType) {
        if _currentTk.type == tkType {
            advance()
        } else {
            fatalError("Error, next token not expect as \(tkType.rawValue)")
        }
    }
    
    // 判断当前 token 是否和入参类型一样，返回布尔值，不匹配不会中断报错
    private func match(_ tkType: JTokenType) -> Bool {
        return _currentTk.type == tkType
    }
    
    // 直接跳到下一个 token
    private func advance() {
        _lastTK = _currentTk
        _tkIndex += 1
        
    }
    
    // 判断是否是结束 token 不是就报错
    private func semicolon() {
        if _currentTk.type != .eof {
            fatalError("Error: Unexpected token, expected semi")
        }
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
    private func parseBlockBody(program: JNodeStatement, end: JTokenType) {
        parseBlockOrModuleBlockBody(program: program, end: end)
    }
    
    // DONE
    private func parseBlockOrModuleBlockBody(program: JNodeStatement, end: JTokenType) {

        var end = false
        while !end {
            let stmt = parseStatement()
            if stmt.type == "" {
                end = true
            } else {
                if program.type == "program" {
                    (program as! JNodeProgram).body.append(stmt)
                } else if program.type == "BlockStatement" {
                    (program as! JNodeBlockStatement).body.append(stmt)
                }
            } // end if
        } // end while
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
            // DONE
            node = parseBreakContinueStatement()
        case .debugger:
            // DONE
            node = parseDebuggerStatement()
        case .do:
            // DONE
            node = parseDoStatement()
        case .for:
            // DONE
            node = parseForStatement()
        case .function:
            // DONE
            if _lastTK.type == .dot {
                break
            }
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
            // DONE
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
    // DONE
    func parseBreakContinueStatement() -> JNodeStatement {
        let isBreak = _currentTk.type == .break
        advance()
        
        var label:JNodeIdentifier? = nil
        
        if _currentTk.type == .eof {
            
        } else if !match(.name) {
            fatalError("Error: parseBreakContinueStatement not match name token type")
        } else {
            label = parseIdentifier()
            semicolon()
        }
        
        if isBreak {
            return JNodeBreakStatement(label: label)
        } else {
            return JNodeContinueStatement(label: label)
        }
    }
    
    // DONE
    func parseDebuggerStatement() -> JNodeDebuggerStatement {
        advance()
        semicolon()
        return JNodeDebuggerStatement()
    }
    
    // DONE
    func parseDoStatement() -> JNodeDoWhileStatement {
        advance()
        let body = parseStatement()
        expect(.while)
        let test = parseParenExpression()
        _ = eat(.eof)
        return JNodeDoWhileStatement(body: body, test: test)
    }
    
    // DONE
    func parseParenExpression() -> JNodeExpression {
        expect(.parenL)
        let val = parseExpression()
        expect(.parenR)
        return val
    }
    
    // DONE
    func parseForStatement() -> JNodeStatement {
        advance()
        expect(.parenL)
        
        if match(.eof) {
            return parseFor(initialization: nil)
        }
        
        if match(.var) || match(.let) || match(.const) {
            let varKind = _currentTk.type
            advance()
            let initialization = parseVar(kind: varKind)
            
            if match(.in) {
                if initialization.declarations.count == 1 {
                    let declaration = initialization.declarations[0]
                    let isForInInitializer = varKind == .var && (declaration.initialization != nil) && declaration.id.type != "ObjectPattern" && declaration.id.type != "ArrayPattern"
                    if isForInInitializer {
                        fatalError("Error: parseForStatement for-in initializer in strict mode")
                    } else if isForInInitializer || !(declaration.initialization != nil) {
                        return parseForIn(initialization: initialization)
                    } // end if
                } // end if
            } // end if
            
            return parseFor(initialization: initialization)
        }
        
        let initialization = parseExpression()
        if match(.in) {
            return parseForIn(initialization: initialization)
        }
        
        return parseFor(initialization: initialization)
    }
    
    // DONE
    func parseForIn(initialization: JNodeExpression) -> JNodeForInStatement {
        //let type = match(.in) ? "ForInStatement" : "ForOfStatement"
        // TODO: forAwait
        advance()
        let left = initialization
        let right = parseExpression()
        expect(.parenR)
        let body = parseStatement()
        return JNodeForInStatement(left: left, right: right, body: body)
    }
    
    // DONE
    func parseFor(initialization: JNodeExpression?) -> JNodeForStatement {
        expect(.eof)
        let test = match(.eof) ? nil : parseExpression()
        expect(.eof)
        let update = match(.parenR) ? nil : parseExpression()
        expect(.parenR)
        let body = parseStatement()
        return JNodeForStatement(initialization: initialization, test: test, update: update, body: body)
    }
    
    // DONE
    func parseFunctionStatement() -> JNodeFunction {
        advance()
        return parseFunction(isStatement: true)
    }
    
    // TODO
    func parseClass() -> JNodeClass {
        advance()
        let id = parseClassId()
        let sp = parseClassSuper()
        let body = parseClassBody()
        return JNodeClass(id: id, superClass: sp, body: body, decorators: [JNodeDecorator]())
    }
    
    // DONE
    func parseClassId() -> JNodeIdentifier? {
        if match(.name) {
            return parseIdentifier()
        } else {
            return nil
        }
    }
    
    // DONE
    func parseClassSuper() -> JNodeExpression? {
        if eat(.extends) {
            return parseExprSubscripts()
        } else {
            return nil
        }
    }
    
    // TODO:
    func parseClassBody() -> JNodeClassBody {
        expect(.braceL)
        
        while !eat(.braceR) {
            if eat(.eof) {
                continue
            }
            // TODO:
        }
        
        return JNodeClassBody(body: [JNode]())
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
        expect(.eof)
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
            expect(.bracketL)
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
                expect(.comma)
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
            expect(.bracketR)
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
        expect(.parenL)
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
    
    // DONE
    func parseSpread() -> JNodeSpreadElement {
        advance()
        return JNodeSpreadElement(argument: parseMaybeAssign())
    }
    
    // DONE
    func parseDecorator() -> JNodeDecorator {
        advance()
        return JNodeDecorator(expression: parseMaybeAssign())
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
                expect(close)
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
                // TODO: 检查用
                //_ = toAssignable(node: left)
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
    
    // DONE
    func parseConditional(expr: JNodeExpression) -> JNodeExpression {
        if eat(.question) {
            let consequent = parseMaybeAssign()
            expect(.colon)
            let alternate = parseMaybeAssign()
            return JNodeConditionalExpression(test: expr, alternate: alternate, consequent: consequent)
        }
        return expr
    }
    
    // DONE
    func parseExprOps(noIn: Bool = false) -> JNodeExpression {
        let expr = parseMaybeUnary()
        if expr.type == "ArrowFunctionExpression" {
            return expr
        }
        return parseExprOp(left: expr, minPrec: -1)
    }
    
    // DONE
    func parseExprOp(left: JNodeExpression, minPrec: Int, noIn: Bool = false) -> JNodeExpression {
        let prec = _currentTk.binop
        if !noIn || !match(.in) {
            if prec > minPrec {
                let opt = _currentTk.value
                
                advance()
                
                var rightPrec = prec
                if _currentTk.rightAssociative {
                    rightPrec = prec - 1
                }
                
                let right = parseExprOp(left: parseMaybeUnary(), minPrec: rightPrec, noIn: noIn)
                
                let tkType = _currentTk.type
                if tkType == .logicalOR || tkType == .logicalAND || tkType == .nullishCoalescing {
                    return parseExprOp(left: JNodeLogicalExpression(operator: opt, left: left, right: right), minPrec: minPrec, noIn: noIn)
                } else {
                    return parseExprOp(left: JNodeBinaryExpression(operator: opt, left: left, right: right), minPrec: minPrec, noIn: noIn)
                }
            }
        }
        return left
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
            reBase = parseSubscript(base: reBase, state: state)
        }
        return reBase
    }
    
    // DONE
    func parseSubscript(base: JNodeExpression, state: ParseSubscriptState) -> JNodeExpression {
        if eat(.doubleColon) {
            state.stop = true
            let exp = JNodeBindExpression(object: base, callee: parseNoCallExpr())
            return parseSubscripts(base: exp)
        } else if match(.questiondot) {
            fatalError("Error: questiondot not support now in parseSubscript")
        } else if eat(.dot) {
            let pro = parseMaybePrivateName()
            // TODO: optionalChainMember 状态
            return JNodeMemberExpression(object: base, property: pro as! JNodeExpression, computed: false, optional: false)
        } else if eat(.bracketL) {
            let pro = parseExpression()
            expect(.bracketR)
            return JNodeMemberExpression(object: base, property: pro, computed: true, optional: false)
        } else if match(.parenL) {
            // TODO: Async 会调用 atPossibleAsync
            advance()
            let arg = parseCallExpressionArguments(close: .parenR)
            return JNodeCallExpression(callee: base, arguments: arg, optional: false)
        } else if match(.backQuote) {
            fatalError("Error: template not support now in parseSubscript")
        } else {
            state.stop = true
            return base
        }
        return JNodeExpressionBase()
    }
    
    // DONE
    func parseCallExpressionArguments(close: JTokenType) -> [JNodeExpression] {
        var elts = [JNodeExpression]()
        var first = true
        
        while !eat(close) {
            if first {
                first = false
            } else {
                expect(.comma)
                if eat(close) {
                    break
                }
            }
            elts.append(parseExprListItem(allowEmpty: false)!)
        }
        
        return elts
    }
    
    // DONE
    func parseExprListItem(allowEmpty: Bool = false) -> JNodeExpression? {
        if allowEmpty && match(.comma) {
            return nil
        } else if match(.ellipsis) {
            return parseSpread() as? JNodeExpression
        } else {
            return parseMaybeAssign()
        }
    }
    
    // DONE
    func parseNoCallExpr() -> JNodeExpression {
        return parseSubscripts(base: parseExprAtom())
    }
    
    // DONE
    func parseExprAtom() -> JNodeExpression {
        switch _currentTk.type {
        case .super:
            advance()
            return JNodeSuper()
        case .import:
            if _nextTk.type == .dot {
                return parseImportMetaProperty()
            }
            advance()
            return JNodeImport()
        case .this:
            advance()
            return JNodeThisExpression()
        case .yield:
            fatalError("Error: parseExprAtom not support yield")
        case .name:
            return parseIdentifier()
        case .do:
            advance()
            return JNodeDoExpression(body: parseBlock())
        case .regular:
            fatalError("Error: parseExprAtom not support regular")
        case .int, .float, .bigint:
            let value = _currentTk.value.numberValue!
            advance()
            return JNodeNumericLiteral(value: value)
        case .string:
            let value = _currentTk.value
            advance()
            return JNodeStringLiteral(value: value)
        case .null:
            advance()
            return JNodeNullLiteral()
        case .true, .false:
            return parseBooleanLiteral()
        case .parenL:
            return parseParenAndDistinguishExpression()
        case .bracketL:
            advance()
            return JNodeArrayExpression(elements: parseExprList(close: .bracketR, allowEmpty: true))
        case .braceL:
            return parseObj(isPattern: false)
        case .function:
            return parseFunctionExpression()
        case .at:
            fatalError("Error: parseExprAtom not support Decorator")
        case .class:
            // TODO: 处理 Decorator
            return parseClass()
        case .new:
            return parseNew()
        case .backQuote:
            fatalError("Error: parseExprAtom not support parseTemplate for now")
        case .doubleColon:
            advance()
            let callee = parseNoCallExpr()
            if callee.type == "MemberExpression" {
                return JNodeBindExpression(object: nil, callee: callee)
            } else {
                fatalError("Error: parseExprAtom Binding should be performed on object property.")
            }
        default:
            fatalError("Error: parseExprAtom no case here")
        }
        
        return JNodeExpressionBase()
    }
    
    // DONE
    func parseNew() -> JNodeExpression {
        let meta = parseIdentifier() // 暂时就 advance 跳过
        if eat(.dot) {
            let metaProp = parseMetaProperty(meta: meta)
            return metaProp
        }
        
        let callee = parseNoCallExpr()
        if callee.type == "OptionalMemberExpression" || callee.type == "OptionalCallExpression" {
            fatalError("Error: parseNew constructors in/after an Optional Chain are not allowed")
        }
        
        if eat(.questiondot) {
            fatalError("Error: parseNew constructors in/after an Optional Chain are not allowed")
        }
        
        return JNodeNewExpression(callee: callee, arguments: parseNewArguments() as! [JNode], optional: false)
    }
    
    // DONE
    func parseNewArguments() -> [JNodeExpression?] {
        if eat(.parenL) {
            return parseExprList(close: .parenR)
        } else {
            return [JNodeExpression?]()
        }
    }
    
    // DONE
    func parseMetaProperty(meta: JNodeIdentifier) -> JNodeMetaProperty {
        return JNodeMetaProperty(meta: meta, property: parseIdentifier())
    }
    
    // DONE
    func parseFunctionExpression() -> JNodeExpression {
        let meta = parseIdentifier()
        if eat(.dot) {
            return parseMetaProperty(meta: meta)
        }
        return parseFunction(isStatement: false)
    }
    
    // DONE
    func parseFunction(isStatement: Bool) -> JNodeFunction {
        return JNodeFunction(id: JNodeIdentifier(name: ""), params: parseFunctionParams(), body: parseFunctionBodyAndFinish(), generator: false, async: false)
    }
    
    // DONE
    // 用于逗号分隔的表达式，close 是结束的符号
    func parseExprList(close: JTokenType, allowEmpty: Bool = false) -> [JNodeExpression?] {
        var elts = [JNodeExpression?]()
        var first = true
        
        while !eat(close) {
            if first {
                first = false
            } else {
                expect(.comma)
                if eat(close) {
                    break
                }
            }
            elts.append(parseExprListItem(allowEmpty: allowEmpty))
        }
        return elts
    }
    
    // DONE
    func parseParenAndDistinguishExpression() -> JNodeExpression {
        expect(.parenL)
        var exprList = [JNodeExpression]()
        var first = true
        
        while !match(.parenR) {
            if first {
                first = false
            } else {
                expect(.comma)
                if match(.parenR) {
                    break
                }
            }
            
            if match(.ellipsis) {
                exprList.append(parseRest())
                break
            } else {
                exprList.append(parseMaybeAssign())
            }
            
        }
        
        expect(.parenR)
        
        if exprList.count > 1 {
            return JNodeSequenceExpression(expressions: exprList)
        } else {
            return exprList[0]
        }
        
    }
    
    // DONE
    func parseBooleanLiteral() -> JNodeBooleanLiteral {
        let value = match(.true)
        advance()
        return JNodeBooleanLiteral(value: value)
    }
    
    // DONE
    func parseImportMetaProperty() -> JNodeMetaProperty {
        let id = parseIdentifier()
        expect(.dot)
        return parseMetaProperty(meta: id)
    }
    
    func parseWhileStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    func parseWithStatement() -> JNodeStatement {
        return JNodeStatementBase()
    }
    
    // DONE
    func parseBlock() -> JNodeBlockStatement {
        expect(.braceL)
        let blockStatement = JNodeBlockStatement(body: [JNodeStatement](), directives: [JNodeDirective]())
        parseBlockBody(program: blockStatement, end: .braceR)
        return blockStatement
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
