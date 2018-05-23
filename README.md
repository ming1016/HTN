# HTN 开发日志

![htnbluemap](https://github.com/ming1016/HTN/blob/master/htnbluemap.png?raw=true)

## 待完成

* 延后解析 decorators，directives，await，async，arrow，parseArrowExpression，yield，containsEsc，regexp（regular）
* 依据 antlr 里 grammars-v4
 <https://github.com/antlr/grammars-v4/blob/master/objc/ObjectiveCParser.g4> 设计对应 OC 的 ONode 用作 AST 转换，该语法规则已在 AFNetworking，SDWebImage，ReactiveCocoa，AsyncDisplayKit 和 fmdb 等大型开源库上 parsed，正确率超过 95%。
* 设计 JState 结构来管理处理过程中的状态，async 语法的分析和支持
* 正则处理注释方式替换成 skipComment 方法，以便保留注释内容
* 一元 操作符
* 变量，函数，绑定，调用对应oc
* 实现 lexical scoping，及闭包结构体设计
* 研究 vue 模版
* htn 的 html 和 css 来解析器来解析 vue 模版的 html 标签
* 设计 HObject 作为基类适配js弱类型，值类型作为属性，对象类型继承这个基类
* vue 数据响应式 v-model 和原生响应式 kvo 对应
* 完善异常处理
* 写40个不重复情况测试用例，保证后面增加修改删除时输入和输出不受影响，或局部影响可控，用于测试各个过程
* babel 工具链和终端程序的结合，调用和输出的获取，使用 Process 和 Pipe
* 研究 facebook 的 Flow 的实现原理，改库用于将 js 的类型固定：[GitHub - facebook/flow: Adds static typing to JavaScript to improve developer productivity and code quality.](https://github.com/facebook/flow)
* 调研抽象解释器
* ES6 解析支持
* 测试 Case 的编写可以参考：[grammars-v4/javascript/examples at master · antlr/grammars-v4 · GitHub](https://github.com/antlr/grammars-v4/tree/master/javascript/examples)。ES5 和 ES6 各种语法比较（全） [ECMAScript 6: New Features: Overview and Comparison](http://es6-features.org/#Constants)
* ES6 各种语法的 token 测试 Case 编写
* ES6 各种语法的 AST 测试 Case 编写
* Vue 模版编写

## 已完成

* 不要返回的 eat 函数替换成 expect
* tokenizer 里添加 peek 方法，完善 token 处理
* 使用 babel 转 es7 和 es6 到 es5，按 ES5 <https://github.com/estree/estree/blob/master/es5.md> 节点标准来设计 JNode
* 完成 Token 类型 es 标准的设计以及字符串的获取，正则的获取，空格换行和 ; 符号，数字，关键字，符号和操作符的处理。
* 编写了 Case1，其主要包含了字符串，正则，数字和基本操作符关键字等的测试 Case 编写。
* 完成，代码 -> AST -> 新 AST -> 代码，及 JTokenizer，JParser，JTraverser，JTransformer，CodeGeneratorFromJSToOC 主程序架子搭建和表达式转换雏形流程跑通。
* 基本运算符对应oc，雏形。
* Babel 插件研究。

## 待添加的 case

```js
const callee = (node.callee = this.parseNoCallExpr());
```

## 18.5.23

### JParser 里的工具函数

```swift
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
        _tkIndex += 1
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
        _tkIndex += 1
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
    _tkIndex += 1
}

// 判断是否是结束 token 不是就报错
private func semicolon() {
    if _currentTk.type != .eof {
        fatalError("Error: Unexpected token, expected semi")
    }
}
```

## 18.5.18

### JNode 设计

设计按照的 ES6 规范来的。 依据的是 Babylon AST 节点的标准规范进行的设计。

```swift
//
//  JNode.swift
//  HTN
//
//  Created by DaiMing on 2018/5/9.

//  Babylon AST node types
//  https://github.com/babel/babel/blob/master/packages/babylon/ast/spec.md#node-objects
//  last Commits on Apr 5, 2018

import Foundation

public protocol JNode {
    var type: String {get set}
}
// A literal token. May or may not represent an expression.
public protocol JNodeLiteral: JNode {}
public protocol JNodePattern: JNode {}
public protocol JNodeStatement: JNode {}
// Any expression node. Since the left-hand side of an assignment may be any expression in general, an expression can also be a pattern.
public protocol JNodeExpression: JNode {}
// Any declaration node. Note that declarations are considered statements; this is because declarations can appear in any statement context.
public protocol JNodeDeclaration: JNodeStatement {}
// A module `import` or `export` declaration.
public protocol JNodeModuleDeclaration: JNode {}

// 多重继承
public protocol JNodeObjectMemberP: JNode {
    var key: JNodeExpression {get}
    var computed: Bool {get}
    var decorators: JNodeDecorator {get}
}
public protocol JNodeFunctionP: JNode {
    var id: JNodeIdentifier {get}
    var params: [JNodePattern] {get}
    var body: JNodeBlockStatement {get}
    var generator: Bool {get}
    var async: Bool {get}
}

// 以下 base 是开发时占位用
public class JNodeBase:JNode {
    public var type = "Base"
}

public class JNodeStatementBase: JNodeStatement {
    public var type = "StatementBase"
}

public class JNodeExpressionBase: JNodeExpression {
    public var type = "ExpressionBase"
}

// An identifier. Note that an identifier may be an expression or a destructuring pattern.
public class JNodeIdentifier: JNodePattern, JNodeExpression {
    public var type = "Identifier"
    let name: String
    init(name: String) {
        self.name = name
    }
}

// A Private Name Identifier.
public class JNodePrivateName: JNodePattern, JNodeExpression {
    public var type = "PrivateName"
    let id: JNodeIdentifier
    init(id: JNodeIdentifier) {
        self.id = id
    }
}

public class JNodeRegExpLiteral: JNodeLiteral {
    public var type = "RegExpLiteral"
    let pattern: String
    let flags: String
    init(pattern: String, flags: String) {
        self.pattern = pattern
        self.flags = flags
    }
}

public class JNodeNullLiteral: JNodeLiteral {
    public var type = "NullLiteral"
}

public class JNodeStringLiteral: JNodeLiteral {
    public var type = "StringLiteral"
    var value: String
    init(value: String) {
        self.value = value
    }
}

public class JNodeBooleanLiteral: JNodeLiteral {
    public var type = "BooleanLiteral"
    let value: Bool
    init(value: Bool) {
        self.value = value
    }
}

public class JNodeNumericLiteral: JNodeLiteral {
    public var type = "NumericLiteral"
    let value: NSNumber
    init(value: NSNumber) {
        self.value = value
    }
}

public enum JNodeSourceType {
    case script, module
}
// A complete program source tree.
// ES6 指定为 module，其它的使用 script
public class JNodeProgram: JNode {
    public var type = "program"
    let sourceType: JNodeSourceType
    // body: [ Statement | ModuleDeclaration ];
    // TODO: 能够支持 ModuleDeclaration
    var body: [JNodeStatement]
    let directives: [JNodeDirective] // TODO:
    init(sourceType: JNodeSourceType, body: [JNodeStatement], directives: [JNodeDirective]) {
        self.sourceType = sourceType
        self.body = body
        self.directives = directives
    }
}

// A function [declaration](#functiondeclaration) or [expression](#functionexpression).
public class JNodeFunction: JNodeFunctionP {
    public var type = "Function"
    public var id: JNodeIdentifier
    public let params: [JNodePattern]
    public let body: JNodeBlockStatement
    public let generator: Bool
    public let async: Bool
    init(id: JNodeIdentifier, params: [JNodePattern], body: JNodeBlockStatement, generator: Bool, async: Bool) {
        self.id = id
        self.params = params
        self.body = body
        self.generator = generator
        self.async = async
    }
}

// An expression statement, i.e., a statement consisting of a single expression.
public class JNodeExpressionStatement: JNodeStatement {
    public var type = "ExpressionStatement"
    let expression: JNodeExpression
    init(expression: JNodeExpression) {
        self.expression = expression
    }
}

// A block statement, i.e., a sequence of statements surrounded by braces.
public class JNodeBlockStatement: JNodeStatement {
    public var type = "BlockStatement"
    let body: [JNodeStatement]
    let directives: [JNodeDirective]
    init(body: [JNodeStatement], directives: [JNodeDirective]) {
        self.body = body
        self.directives = directives
    }
}

// An empty statement, i.e., a solitary semicolon.
public class JNodeEmptyStatement: JNodeStatement {
    public var type = "EmptyStatement"
}

// A `debugger` statement.
public class JNodeDebuggerStatement: JNodeStatement {
    public var type = "DebuggerStatement"
}

// A `with` statement.
public class JNodeWithStatement: JNodeStatement {
    public var type = "WithStatement"
    let object: JNodeExpression
    let body: JNodeStatement
    init(object: JNodeExpression, body: JNodeStatement) {
        self.object = object
        self.body = body
    }
}

// Control flow

public class JNodeReturnStatement: JNodeStatement {
    public var type = "ReturnStatement"
    let argument: JNodeExpression?
    init(argument: JNodeExpression?) {
        self.argument = argument
    }
}

// A labeled statement, i.e., a statement prefixed by a `break`/`continue` label.
public class JNodeLabeledStatement: JNodeStatement {
    public var type = "LabeledStatement"
    let label: JNodeIdentifier
    let body: JNodeStatement
    init(label: JNodeIdentifier, body: JNodeStatement) {
        self.label = label
        self.body = body
    }
}

public class JNodeBreakStatement: JNodeStatement {
    public var type = "BreakStatement"
    let label: JNodeIdentifier?
    init(label: JNodeIdentifier?) {
        self.label = label
    }
}

public class JNodeContinueStatement: JNodeStatement {
    public var type = "ContinueStatement"
    let label: JNodeIdentifier?
    init(label: JNodeIdentifier?) {
        self.label = label
    }
}

// Choice

public class JNodeIfStatement: JNodeStatement {
    public var type = "IfStatement"
    let test: JNodeExpression
    let consequent: JNodeStatement
    let alternate: JNodeStatement?
    init(test: JNodeExpression, consequent: JNodeStatement, alternate:JNodeStatement?) {
        self.test = test
        self.consequent = consequent
        self.alternate = alternate
    }
}

public class JNodeSwitchStatement: JNodeStatement {
    public var type = "SwitchStatement"
    let discriminant: JNodeExpression
    let cases: [JNodeSwitchCase]
    init(discriminant: JNodeExpression, cases: [JNodeSwitchCase]) {
        self.discriminant = discriminant
        self.cases = cases
    }
}

// A `case` (if `test` is an `Expression`) or `default` (if `test === null`) clause in the body of a `switch` statement.
public class JNodeSwitchCase: JNode {
    public var type = "SwitchCase"
    let test: JNodeExpression?
    let consequent: [JNodeStatement]
    init(test: JNodeExpression?, consequent: [JNodeStatement]) {
        self.test = test
        self.consequent = consequent
    }
}

// Exceptions

public class JNodeThrowStatement: JNodeStatement {
    public var type = "ThrowStatement"
    let argument: JNodeExpression
    init(argument: JNodeExpression) {
        self.argument = argument
    }
}

// A `try` statement. If `handler` is `null` then `finalizer` must be a `BlockStatement`.
public class JNodeTryStatement: JNodeStatement {
    public var type = "TryStatement"
    let block: JNodeBlockStatement
    let handler: JNodeCatchClause?
    let finalizer: JNodeBlockStatement?
    init(block: JNodeBlockStatement, handler: JNodeCatchClause?, finalizer: JNodeBlockStatement?) {
        self.block = block
        self.handler = handler
        self.finalizer = finalizer
    }
}

// A `catch` clause following a `try` block.
public class JNodeCatchClause: JNode {
    public var type = "CatchClause"
    let param: JNodePattern?
    let body: JNodeBlockStatement
    init(param: JNodePattern?, body: JNodeBlockStatement) {
        self.param = param
        self.body = body
    }
}

// Loops

public class JNodeWhileStatement: JNodeStatement {
    public var type = "WhileStatement"
    let test: JNodeExpression
    let body: JNodeStatement
    init(test: JNodeExpression, body: JNodeStatement) {
        self.test = test
        self.body = body
    }
}

// A `do`/`while` statement.
public class JNodeDoWhileStatement: JNodeStatement {
    public var type = "DoWhileStatement"
    let body: JNodeStatement
    let test: JNodeExpression
    init(body: JNodeStatement, test: JNodeExpression) {
        self.body = body
        self.test = test
    }
}

public class JNodeForStatement: JNodeStatement {
    public var type = "ForStatement"
    // init: VariableDeclaration | Expression | null;
    // TODO: VariableDeclaration
    let initialization: JNodeExpression?
    let test: JNodeExpression?
    let update: JNodeExpression?
    init(initialization: JNodeExpression?, test: JNodeExpression?, update: JNodeExpression?) {
        self.initialization = initialization
        self.test = test
        self.update = update
    }
}

// A `for`/`in` statement.
public class JNodeForInStatement: JNodeStatement {
    public var type = "ForInStatement"
    // left: VariableDeclaration |  Expression;
    // TODO: VariableDeclaration
    var left: JNodeExpression
    var right: JNodeExpression
    var body: JNodeStatement
    init(left: JNodeExpression, right: JNodeExpression, body: JNodeStatement) {
        self.left = left
        self.right = right
        self.body = body
    }
}

public class JNodeForOfStatement: JNodeForInStatement {
    let await: Bool
    init(left: JNodeExpression, right: JNodeExpression, body: JNodeStatement, await: Bool) {
        self.await = await
        super.init(left: left, right: right, body: body)
        self.type = "ForOfStatement"
    }
}

// A function declaration. Note that unlike in the parent interface `Function`, the `id` cannot be `null`, except when this is the child of an `ExportDefaultDeclaration`.
public class JNodeFunctionDeclaration: JNodeFunction, JNodeDeclaration {
    init(identifier: JNodeIdentifier, params: [JNodePattern], body: JNodeBlockStatement, generator: Bool, async: Bool) {
        super.init(id: identifier, params: params, body: body, generator: generator, async: async)
        self.id = identifier
        self.type = "FunctionDeclaration"
    }
}

// TODO: 暂时不用
public enum JNodeVariableDeclarationKind {
    case `var`, `let`, `const`
}
public class JNodeVariableDeclaration: JNodeDeclaration {
    public var type = "VariableDeclaration"
    let declarations: [JNodeVariableDeclarator]
    let kind: String
    init(declarations: [JNodeVariableDeclarator], kind: String) {
        self.declarations = declarations
        self.kind = kind
    }
}

public class JNodeVariableDeclarator: JNode {
    public var type = "VariableDeclarator"
    let id: JNodePattern
    let initialization: JNodeExpression?
    init(id: JNodePattern, initialization: JNodeExpression?) {
        self.id = id
        self.initialization = initialization
    }
}

// Misc

public class JNodeDecorator: JNode {
    public var type = "Decorator"
    let expression: JNodeExpression
    init(expression: JNodeExpression) {
        self.expression = expression
    }
}

public class JNodeDirective: JNode {
    public var type = "Directive"
    let value: JNodeDirectiveLiteral
    init(value: JNodeDirectiveLiteral) {
        self.value = value
    }
}

public class JNodeDirectiveLiteral: JNodeStringLiteral {
    override init(value: String) {
        super.init(value: value)
        self.type = "DirectiveLiteral"
    }
}

// Express
public class JNodeSuper: JNode {
    public var type = "Super"
}

public class JNodeImport: JNode {
    public var type = "Import"
}

public class JNodeThisExpression: JNodeExpression {
    public var type = "ThisExpression"
}

// A fat arrow function expression, e.g., `let foo = (bar) => { /* body */ }`.
public class JNodeArrowFunctionExpression: JNodeFunction, JNodeExpression {
    override init(id: JNodeIdentifier, params: [JNodePattern], body: JNodeBlockStatement, generator: Bool, async: Bool) {
        super.init(id: id, params: params, body: body, generator: generator, async: async)
    }
}

public class JNodeYieldExpression: JNodeExpression {
    public var type = "YieldExpression"
    let argument: JNodeExpression?
    let delegate: Bool
    init(argument: JNodeExpression?, delegate: Bool) {
        self.argument = argument
        self.delegate = delegate
    }
}

public class JNodeAwaitExpression: JNodeExpression {
    public var type = "AwaitExpression"
    let argument: JNodeExpression?
    init(argument: JNodeExpression?) {
        self.argument = argument
    }
}

public class JNodeArrayExpression: JNodeExpression {
    public var type = "ArrayExpression"
    // elements: [ Expression | SpreadElement | null ];
    // TODO: SpreadElement
    let elements: [JNode?]
    init(elements: [JNodeExpression?]) {
        self.elements = elements
    }
}

public class JNodeObjectExpression: JNodeExpression {
    public var type = "ObjectExpression"
    // properties: [ ObjectProperty | ObjectMethod | SpreadElement ];
    let properties: [JNode]
    init(properties: [JNode]) {
        self.properties = properties
    }
}

public class JNodeObjectMember: JNodeObjectMemberP {
    public var type = "ObjectMember"
    public let key: JNodeExpression
    public let computed: Bool
    public let decorators: JNodeDecorator
    init(key: JNodeExpression, computed: Bool, decorators: JNodeDecorator) {
        self.key = key
        self.computed = computed
        self.decorators = decorators
    }
}

public class JNodeObjectProperty: JNodeObjectMember {
    let shorthand: Bool
    // value 可能是 JNodeExpression 或者 JNodePattern（JNodeAssignmentProperty 里）
    let value: JNode
    init(key: JNodeExpression, computed: Bool, decorators: JNodeDecorator, shorthand: Bool, value: JNodeExpression) {
        self.shorthand = shorthand
        self.value = value
        super.init(key: key, computed: computed, decorators: decorators)
        self.type = "ObjectProperty"
    }
}

public class JNodeObjectMethod: JNodeObjectMemberP, JNodeFunctionP {
    public var type = "ObjectMethod"
    public let key: JNodeExpression
    public let computed: Bool
    public let decorators: JNodeDecorator
    public let id: JNodeIdentifier
    public let params: [JNodePattern]
    public let body: JNodeBlockStatement
    public let generator: Bool
    public let async: Bool
    init(key: JNodeExpression, computed: Bool, decorators: JNodeDecorator, id: JNodeIdentifier, params: [JNodePattern], body: JNodeBlockStatement, generator: Bool, async: Bool) {
        self.key = key
        self.computed = computed
        self.decorators = decorators
        self.id = id
        self.params = params
        self.body = body
        self.generator = generator
        self.async = async
    }
}

public class JNodeFunctionExpression: JNodeFunctionP, JNodeExpression {
    public var type = "FunctionExpression"
    public let id: JNodeIdentifier
    public let params: [JNodePattern]
    public let body: JNodeBlockStatement
    public let generator: Bool
    public let async: Bool
    init(id: JNodeIdentifier, params: [JNodePattern], body: JNodeBlockStatement, generator: Bool, async: Bool) {
        self.id = id
        self.params = params
        self.body = body
        self.generator = generator
        self.async = async
    }
}

// Unary operations

public enum JNodeUnaryOperator:String {
    case min = "-"
    case plus = "+"
    case bang = "!"
    case tilde = "~"
    case typeof = "typeof"
    case void = "void"
    case delete = "delete"
    case `throw` = "throw"
    
}

public class JNodeUnaryExpression: JNodeExpression {
    public var type = "UnaryExpression"
    let `operator`: JNodeUnaryOperator
    let prefix: Bool
    let argument: JNodeExpression
    init(operator: JNodeUnaryOperator, prefix: Bool, argument: JNodeExpression) {
        self.operator = `operator`
        self.prefix = prefix
        self.argument = argument
    }
}

public enum JNodeUpdateOperator:String {
    case inc = "++"
    case dec = "--"
}
// An update (increment or decrement) operator expression.
public class JNodeUpdateExpression: JNodeExpression {
    public var type = "UpdateExpression"
    let `operator`: JNodeUpdateOperator
    let argument: JNodeExpression
    let prefix: Bool
    init(operator: JNodeUpdateOperator, argument: JNodeExpression, prefix: Bool) {
        self.operator = `operator`
        self.argument = argument
        self.prefix = prefix
    }
}

// Binary operations
public enum JNodeBinaryOperator: String {
    case equal = "=="
    case noEqual = "!="
    case identity = "==="
    case noIdentity = "!=="
    case lessThan = "<"
    case lessThanEqual = "<="
    case greaterThan = ">"
    case greaterThanEqual = ">="
    case bitShiftLeft = "<<"
    case bitShiftRight = ">>"
    case unsignedRightShift = ">>>"
    case plus = "+"
    case min = "-"
    case star = "*"
    case slash = "/"
    case modulo = "%"
    case exponent = "**"
    case bitwiseOR = "|"
    case bitwiseXOR = "^"
    case bitwiseAND = "&"
    case `in` = "in"
    case instanceof = "instanceof"
    case piple = "|>"
}

public class JNodeBinaryExpression: JNodeExpression {
    public var type = "BinaryExpression"
    let `operator`: JNodeBinaryOperator
    let left: JNodeExpression
    let right: JNodeExpression
    init(operator: JNodeBinaryOperator, left: JNodeExpression, right: JNodeExpression) {
        self.operator = `operator`
        self.left = left
        self.right = right
    }
}

public enum JNodeAssignmentOperator: String {
    case equal = "="
    case plusEqual = "+="
    case minEqual = "-="
    case starEqual = "*="
    case slashEqual = "/="
    case modulo = "%="
    case doubleStarEqual = "**="
    case leftBitShiftEqual = "<<="
    case rightBitShiftEqual = ">>="
    case unsignedRightShiftEqual = ">>>="
    case bitwiseOREqual = "|="
    case bitwiseXOREqual = "^="
    case bitwiseANDEqual = "&="
}
public class JNodeAssignmentExpression: JNodeExpression {
    public var type = "AssignmentExpression"
    let `operator`: JNodeAssignmentOperator
    // left: Pattern | Expression;
    // TODO: Pattern | Expression;
    let left: JNode
    let right: JNodeExpression
    init(operator: JNodeAssignmentOperator, left: JNode, right: JNodeExpression) {
        self.operator = `operator`
        self.left = left
        self.right = right
    }
}

public enum JNodeLogicalOperator: String {
    case logicalOR = "||"
    case logicalAND = "&&"
    case nullishCoalescing = "??"
}
public class JNodeLogicalExpression: JNodeExpression {
    public var type = "LogicalExpression"
    let `operator`: JNodeLogicalOperator
    let left: JNodeExpression
    let right: JNodeExpression
    init(operator: JNodeLogicalOperator, left: JNodeExpression, right: JNodeExpression) {
        self.operator = `operator`
        self.left = left
        self.right = right
    }
}

public class JNodeSpreadElement: JNode {
    public var type = "SpreadElement"
    let argument: JNodeExpression
    init(argument: JNodeExpression) {
        self.argument = argument
    }
}

// A member expression. If `computed` is `true`, the node corresponds to a computed (`a[b]`) member expression and `property` is an `Expression`. If `computed` is `false`, the node corresponds to a static (`a.b`) member expression and `property` is an `Identifier`. The `optional` flags indicates that the member expression can be called even if the object is null or undefined. If this is the object value (null/undefined) should be returned.
public class JNodeMemberExpression: JNodeExpression, JNodePattern {
    public var type = "MemberExpression"
    // object: Expression | Super;
    // TODO:
    let object: JNode
    let property: JNodeExpression
    let computed: Bool
    let optional: Bool?
    init(object: JNode, property: JNodeExpression, computed: Bool, optional: Bool?) {
        self.object = object
        self.property = property
        self.computed = computed
        self.optional = optional
    }
}

public class JNodeBindExpression: JNodeExpression {
    public var type = "BindExpression"
    let object: JNodeExpression?
    let callee: JNodeExpression
    init(object: JNodeExpression?, callee: JNodeExpression) {
        self.object = object
        self.callee = callee
    }
}

public class JNodeConditionalExpression: JNodeExpression {
    public var type = "ConditionalExpression"
    let test: JNodeExpression
    let alternate: JNodeExpression
    let consequent: JNodeExpression
    init(test: JNodeExpression, alternate: JNodeExpression, consequent: JNodeExpression) {
        self.test = test
        self.alternate = alternate
        self.consequent = consequent
    }
}

// A function or method call expression.
public class JNodeCallExpression: JNodeExpression {
    public var type = "CallExpression"
    // callee: Expression | Super | Import;
    // TODO:
    let callee: JNode
    // arguments: [ Expression | SpreadElement ];
    // TODO:
    let arguments: [JNode]
    let optional: Bool?
    init(callee: JNode, arguments: [JNode], optional: Bool?) {
        self.callee = callee
        self.arguments = arguments
        self.optional = optional
    }
}

public class JNodeNewExpression: JNodeCallExpression {
    override init(callee: JNode, arguments: [JNode], optional: Bool?) {
        super.init(callee: callee, arguments: arguments, optional: optional)
        self.type = "NewExpression"
    }
}

// A sequence expression, i.e., a comma-separated sequence of expressions.
public class JNodeSequenceExpression: JNodeExpression {
    public var type = "SequenceExpression"
    let expressions: [JNodeExpression]
    init(expressions: [JNodeExpression]) {
        self.expressions = expressions
    }
}

public class JNodeDoExpression: JNodeExpression {
    public var type = "DoExpression"
    let body: JNodeBlockStatement
    init(body: JNodeBlockStatement) {
        self.body = body
    }
}

// Template Literals
public class JNodeTemplateLiteral: JNodeExpression {
    public var type = "TemplateLiteral"
    let quasis: [JNodeTemplateElement]
    let expressions: [JNodeExpression]
    init(quasis: [JNodeTemplateElement], expressions: [JNodeExpression]) {
        self.quasis = quasis
        self.expressions = expressions
    }
}

public class JNodeTaggedTemplateExpression: JNodeExpression {
    public var type = "TaggedTemplateExpression"
    let tag: JNodeExpression
    let quasi: JNodeTemplateLiteral
    init(tag: JNodeExpression, quasi: JNodeTemplateLiteral) {
        self.tag = tag
        self.quasi = quasi
    }
}

public class JNodeTemplateElement: JNode {
    struct ValueStruct {
        let cooked: String?
        let raw: String
    }
    public var type = "TemplateElement"
    let tail: Bool
    let value: ValueStruct
    init(tail: Bool, value: ValueStruct) {
        self.tail = tail
        self.value = value
    }
}

// ObjectPattern

public class JNodeAssignmentProperty: JNodeObjectProperty {
    override init(key: JNodeExpression, computed: Bool, decorators: JNodeDecorator, shorthand: Bool, value: JNodeExpression) {
        super.init(key: key, computed: computed, decorators: decorators, shorthand: shorthand, value: value)
    }
}

public class JNodeObjectPattern: JNodePattern {
    public var type = "ObjectPattern"
    // properties: [ AssignmentProperty | RestElement ];
    // TODO:
    let properties: [JNode]
    init(properties: [JNode]) {
        self.properties = properties
    }
}

public class JNodeArrayPattern: JNodePattern {
    public var type = "ArrayPattern"
    let elements: [JNodePattern?]
    init(elements: [JNodePattern?]) {
        self.elements = elements
    }
}

public class JNodeRestElement: JNodePattern {
    public var type = "RestElement"
    let argument: JNodePattern
    init(argument: JNodePattern) {
        self.argument = argument
    }
}

public class JNodeAssignmentPattern: JNodePattern {
    public var type = "AssignmentPattern"
    let left: JNodePattern
    let right: JNodeExpression
    init(left: JNodePattern, right: JNodeExpression) {
        self.left = left
        self.right = right
    }
}

public class JNodeClass: JNode {
    public var type = "Class"
    let id: JNodeIdentifier?
    let superClass: JNodeExpression?
    let body: JNodeClassBody
    let decorators: [JNodeDecorator]
    init(id: JNodeIdentifier?, superClass: JNodeExpression?, body: JNodeClassBody, decorators: [JNodeDecorator]) {
        self.id = id
        self.superClass = superClass
        self.body = body
        self.decorators = decorators
    }
}

public class JNodeClassBody: JNode {
    public var type = "ClassBody"
    // body: [ ClassMethod | ClassPrivateMethod | ClassProperty | ClassPrivateProperty ];
    // TODO:
    let body: [JNode]
    init(body: [JNode]) {
        self.body = body
    }
}

enum JNodeClassMethodKind: String {
    case constructor, method, get, set
}
public class JNodeClassMethod: JNodeFunctionP {
    public var type = "ClassMethod"
    let key: JNodeExpression
    let kind: JNodeClassMethodKind
    let computed: Bool
    let `static`: Bool
    let decorators: [JNodeDecorator]
    public let id: JNodeIdentifier
    public let params: [JNodePattern]
    public let body: JNodeBlockStatement
    public let generator: Bool
    public let async: Bool
    init(key: JNodeExpression, kind: JNodeClassMethodKind, computed: Bool, static: Bool, decorators: [JNodeDecorator], id: JNodeIdentifier, params: [JNodePattern], body: JNodeBlockStatement, generator: Bool, async: Bool) {
        self.key = key
        self.kind = kind
        self.computed = computed
        self.static = `static`
        self.decorators = decorators
        self.id = id
        self.params = params
        self.body = body
        self.generator = generator
        self.async = async
    }
}

public class JNodeClassPrivateMethod: JNodeFunctionP {
    public var type = "ClassPrivateMethod"
    let key: JNodePrivateName
    let kind: JNodeClassMethodKind
    let `static`: Bool
    let decorators: [JNodeDecorator]
    public let id: JNodeIdentifier
    public let params: [JNodePattern]
    public let body: JNodeBlockStatement
    public let generator: Bool
    public let async: Bool
    init(key: JNodePrivateName, kind: JNodeClassMethodKind, computed: Bool, static: Bool, decorators: [JNodeDecorator], id: JNodeIdentifier, params: [JNodePattern], body: JNodeBlockStatement, generator: Bool, async: Bool) {
        self.key = key
        self.kind = kind
        self.static = `static`
        self.decorators = decorators
        self.id = id
        self.params = params
        self.body = body
        self.generator = generator
        self.async = async
    }
}

public class JNodeClassProperty: JNode {
    public var type = "ClassProperty"
    let key: JNodeExpression
    let value: JNodeExpression
    let `static`: Bool
    let computed: Bool
    init(key: JNodeExpression, value: JNodeExpression, static: Bool, computed: Bool) {
        self.key = key
        self.value = value
        self.static = `static`
        self.computed = computed
    }
}

public class JNodeClassPrivateProperty: JNode {
    public var type = "ClassPrivateProperty"
    let key: JNodePrivateName
    let value: JNodeExpression
    let `static`: Bool
    init(key: JNodePrivateName, value: JNodeExpression, static: Bool) {
        self.key = key
        self.value = value
        self.static = `static`
    }
}

public class JNodeClassDeclaration: JNodeClass, JNodeDeclaration {
    override init(id: JNodeIdentifier?, superClass: JNodeExpression?, body: JNodeClassBody, decorators: [JNodeDecorator]) {
        // id: Identifier;
        // TODO: id 做成非可选
        super.init(id: id, superClass: superClass, body: body, decorators: decorators)
        self.type = "ClassDeclaration"
    }
}

public class JNodeClassExpression: JNodeClass, JNodeExpression {
    override init(id: JNodeIdentifier?, superClass: JNodeExpression?, body: JNodeClassBody, decorators: [JNodeDecorator]) {
        super.init(id: id, superClass: superClass, body: body, decorators: decorators)
        self.type = "ClassExpression"
    }
}

public class JNodeMetaProperty: JNodeExpression {
    public var type = "MetaProperty"
    let meta: JNodeIdentifier
    let property: JNodeIdentifier
    init(meta: JNodeIdentifier, property: JNodeIdentifier) {
        self.meta = meta
        self.property = property
    }
}

// Modules

// A specifier in an import or export declaration.
public class JNodeModuleSpecifier: JNode {
    public var type = "ModuleSpecifier"
    let local: JNodeIdentifier
    init(local: JNodeIdentifier) {
        self.local = local
    }
}

// An import declaration, e.g., `import foo from "mod";`.
public class JNodeImportDeclaration: JNodeModuleDeclaration {
    public var type = "ImportDeclaration"
    // specifiers: [ ImportSpecifier | ImportDefaultSpecifier | ImportNamespaceSpecifier ];
    // TODO:
    let specifiers: [JNode]
    let source: JNodeLiteral
    init(specifiers: [JNode], source: JNodeLiteral) {
        self.specifiers = specifiers
        self.source = source
    }
}

/*
 An imported variable binding, e.g., `{foo}` in `import {foo} from "mod"` or `{foo as bar}` in `import {foo as bar} from "mod"`. The `imported` field refers to the name of the export imported from the module. The `local` field refers to the binding imported into the local module scope. If it is a basic named import, such as in `import {foo} from "mod"`, both `imported` and `local` are equivalent `Identifier` nodes; in this case an `Identifier` node representing `foo`. If it is an aliased import, such as in `import {foo as bar} from "mod"`, the `imported` field is an `Identifier` node representing `foo`, and the `local` field is an `Identifier` node representing `bar`.
 */
public class JNodeImportSpecifier: JNodeModuleSpecifier {
    let imported: JNodeIdentifier
    init(local: JNodeIdentifier, imported: JNodeIdentifier) {
        self.imported = imported
        super.init(local: local)
        self.type = "ImportSpecifier"
    }
}

// A default import specifier, e.g., `foo` in `import foo from "mod.js"`.
public class JNodeImportDefaultSpecifier: JNodeModuleSpecifier {
    override init(local: JNodeIdentifier) {
        super.init(local: local)
        self.type = "ImportDefaultSpecifier"
    }
}

// A namespace import specifier, e.g., `* as foo` in `import * as foo from "mod.js"`.
public class JNodeImportNamespaceSpecifier: JNodeModuleSpecifier {
    override init(local: JNodeIdentifier) {
        super.init(local: local)
        self.type = "ImportNamespaceSpecifier"
    }
}

/*
 An export named declaration, e.g., `export {foo, bar};`, `export {foo} from "mod";`, `export var foo = 1;` or `export * as foo from "bar";`.
 
 _Note: Having `declaration` populated with non-empty `specifiers` or non-null `source` results in an invalid state._
 */
public class JNodeExportNamedDeclaration: JNodeModuleDeclaration {
    public var type = "ExportNamedDeclaration"
    let declaration: JNodeDeclaration?
    let specifiers: [JNodeExportSpecifier]
    let source: JNodeLiteral?
    init(declaration: JNodeDeclaration?, specifier: [JNodeExportSpecifier], source: JNodeLiteral?) {
        self.declaration = declaration
        self.specifiers = specifier
        self.source = source
    }
}

/*
 An exported variable binding, e.g., `{foo}` in `export {foo}` or `{bar as foo}` in `export {bar as foo}`. The `exported` field refers to the name exported in the module. The `local` field refers to the binding into the local module scope. If it is a basic named export, such as in `export {foo}`, both `exported` and `local` are equivalent `Identifier` nodes; in this case an `Identifier` node representing `foo`. If it is an aliased export, such as in `export {bar as foo}`, the `exported` field is an `Identifier` node representing `foo`, and the `local` field is an `Identifier` node representing `bar`.
 */
public class JNodeExportSpecifier: JNodeModuleSpecifier {
    let exported: JNodeIdentifier
    init(local: JNodeIdentifier, exported: JNodeIdentifier) {
        self.exported = exported
        super.init(local: local)
        self.type = "ExportSpecifier"
    }
}

// ExportDefaultDeclaration

public class JNodeOptFunctionDeclaration: JNodeFunctionDeclaration {
    override init(identifier: JNodeIdentifier, params: [JNodePattern], body: JNodeBlockStatement, generator: Bool, async: Bool) {
        super.init(identifier: identifier, params: params, body: body, generator: generator, async: async)
    }
}

public class JNodeOptClassDeclaration: JNodeClassDeclaration {
    override init(id: JNodeIdentifier?, superClass: JNodeExpression?, body: JNodeClassBody, decorators: [JNodeDecorator]) {
        super.init(id: id, superClass: superClass, body: body, decorators: decorators)
    }
}

// An export default declaration, e.g., `export default function () {};` or `export default 1;`.
public class JNodeExportDefaultDeclaration: JNodeModuleDeclaration {
    public var type = "ExportDefaultDeclaration"
    // declaration: OptFunctionDeclaration | OptClassDeclaration | Expression;
    // TODO:
    let declaration: JNode
    init(declaration: JNode) {
        self.declaration = declaration
    }
}

// An export batch declaration, e.g., `export * from "mod";`.
public class JNodeExportAllDeclaration: JNodeModuleDeclaration {
    public var type = "ExportAllDeclaration"
    let source: JNodeLiteral
    init(source: JNodeLiteral) {
        self.source = source
    }
}

```

### 开始 JParser 初版设计

先添加两个属性，一个是用来存储 tokens 的下标记录，一个用来存放全部的 token 数组集合。

```swift
private var _tkIndex = 0
private var _tks = [JToken]()
```

添加获取当前 token 的属性 _currentTk，下一个 token 的属性 _nextTk，用来得到 token 的详细信息。

```swift
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
```

eat 函数是保证能够得到预期合法语法的关键函数，达到预期才会返回真，从而进入下一个 token。

```swift
private func eat(_ tkType: JTokenType) -> Bool {
    if _currentTk.type == tkType {
        _tkIndex += 1
        return true
    } else {
        fatalError("Error, next token not expect as \(tkType.rawValue)")
        return false
    }
}
```

初始化里添加一个 eof 的 token 防止文件最后一个 token 后没有换行或者 ; 来结束。

```swift
public init(_ input: String) {
    _tks = JTokenizer(input).tokenizer()
    var eofTk = JToken()
    eofTk.type = .eof
    _tks.append(eofTk)
    print(_tks)
}
```

开始 parse 并返回 JNodeProgram 类型节点。

```swift
public func parser() -> JNodeProgram {
    let programNode = JNodeProgram(sourceType: .module, body: [JNodeStatement](), directives: [JNodeDirective]())
    parseBlockBody(program: programNode, end: .eof)
    return programNode
}
```

下面是 JNodeProgram 节点结构：
```swift
public class JNodeProgram: JNode {
    public var type = "program"
    let sourceType: JNodeSourceType
    // body: [ Statement | ModuleDeclaration ];
    // TODO: 能够支持 ModuleDeclaration
    var body: [JNodeStatement]
    let directives: [JNodeDirective] // TODO:
    init(sourceType: JNodeSourceType, body: [JNodeStatement], directives: [JNodeDirective]) {
        self.sourceType = sourceType
        self.body = body
        self.directives = directives
    }
}
```

sourceType 按照 ES6 来使用 module 类型，body 使用 parseBlockBody 函数来处理，这个函数主要是调用了 parseBlockOrModuleBlockBody 函数：

```swift
private func parseBlockBody(program: JNodeProgram, end: JTokenType) {
    parseBlockOrModuleBlockBody(program: program, end: end)
}

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
```

parseBlockOrModuleBlockBody 函数会不断调 parseStatement 函数，没有匹配到，即类型为空为止，这里的结束条件后面还会调整。现在只是将 Statement 的 type 设置为空来结束。

那么看看 parseStatement 函数是如何处理的：

```swift
private func parseStatement() -> JNodeStatement {
    // TODO * decorator
    return parseStatementContent()
}
```

这里对于 decorator 的处理会放在后面处理，目前先处理主内容，parseStatementContent 函数里面会处理各种关键字和非关键字，这是整个 parser 的入口。内容很多，目前先针对 let, const 和 var 关键字开始，对应的函数是 parseVarStatement，其它的函数先预留下来，后面一个一个补全。

```swift
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
```

## 18.5.12

### peek

处理 ${ 和 _= 组成符号的情况需要 `瞥一眼` 功能，先创建个函数

```swift
// 访问下当前字符的下一个字符，而不更新当前字符位置
var peek: Character? {
    if _index < _input.endIndex {
        let nextIndex =  _input.index(after: _index)
        return nextIndex < _input.endIndex ? _input[nextIndex] : nil
    } else {
        return nil
    }
}
```

再更新下 tokenizer 方法，在处理普通字符时加上 peek，这样就可以把 ${ 和 _= 提取出来了。

```swift
// 处理关键字和其它定义字符集
var word = ""
// 处理 ${ 和 _= 组成符号的情况
if currentChar?.description == "$" && self.peek == "{" {
    word = "${"
    advanceIndex()
} else if currentChar?.description == "_" && self.peek == "=" {
    word = "_="
    advanceIndex()
} else {
```

## 18.5.10 Case1

### es 标准的分词

创建 JToken.swift 定义一个枚举类型的，包含符号，操作符和关键字

```swift
// ES 标准
public enum JTokenType:String {
    case none
    
    case float
    case int
    case bingint
    
    case string    // 字符
    case name      // 命名
    case eof       // 间隔，包括空格和换行
    case regular   // 正则
    
    // 标点符号
    case bracketL  // [
    case bracketR  // ]
    case braceL    // {
    case braceBarL // {|
    case braceR    // }
    case braceBarR // |}
    case parenL    // (
    case parenR    // )
    case comma     // ,
    case semi      // ;
    case colon     // :
    case doubleColon // ::
    case dot       // .
    case question  // ?
    case questiondot // ?.
    case arrow     // =>
    case ellipsis  // ...
    case backQuote // `
    case dollarBraceL // ${
    case at        // @
    case hash      // #
    
    // 操作符
    case eq        // =
    case assign    // _=
    case incDec    // ++ / --
    case bang      // !
    case tilde     // ~
    
    // 有优先级的操作符
    case pipleline // |>
    case nullishCoalescing // ??
    case logicalOR // ||
    case logicalAND // &&
    case bitwiseOR  // |
    case bitwiseXOR // ^
    case bitwiseAND // &
    case equality   // == / !=
    case relational // < / >
    case bitShift   // << / >>
    case plusMin    // + / -
    case modulo     // %
    case star       // *
    case slash      // /
    case exponent   // **
    
    // 关键字
    case template  // template
    case `break`
    case `case`
    case `catch`
    case `continue`
    case `debugger`
    case `default`
    case `do`
    case `else`
    case `finally`
    case `for`
    case `function`
    case `if`
    case `return`
    case `switch`
    case `throw`
    case `try`
    case `var`
    case `let`
    case `const`
    case `while`
    case `with`
    case `new`
    case `this`
    case `super`
    case `class`
    case `extends`
    case `export`
    case `import`
    case `yield`
    case `null`
    case `true`
    case `false`
    case `in`
    case `instanceof`
    case `typeof`
    case `void`
    case `delete`
}
```

在 JTokenizer.swift 里设计一个 JToken，操作符的话会有大于0的 priority，表示操作符的优先级，类型使用的是前面写的枚举类型 JTokenType，options 后面再处理，构建 AST 的使用。下面是 JToken 的结构：

```swift
public struct JToken {
    public var type = JTokenType.none
    public var value = ""
    public var options = [JTokenOption]()
    public var priority:Int = 0
}
```

接下来分析下分词，处理顺序从情况的包含关系出发，当出现字符串标识引号时，后面那些正则的表达，关键字，操作符和数字等都会被包含进去，所以字符串是优先处理的。

### 处理 String

String 的处理需要注意这样几个问题

* 引号：引号需要注意的是当遇到第一个引号时就开始不断累加后面的字符到字符集里知道遇到闭合的那个引号。同时开始和结束的引号都不需要添加到 token 里。
* 转移符号 \：这个可以通过设计一个布尔值 escaped，当遇到这个符号时标记下，后面的引号就直接累加到 token 里。

处理 String 类型 token 的代码如下：

```swift
if s == "\"" || s == "'" {
    let closer = s
    var cSb = ""
    var escaped = false
    while currentChar != nil {
        // token 里不用记录 " 或者 '
        advanceIndex()
        if escaped {
            escaped = false
        } else if currentChar?.description == "\\" {
            escaped = true
        } else if currentChar?.description == closer {
            advanceIndex()
            break
        }
        if let currentStr = currentChar?.description {
            cSb.append(currentStr)
        }
    }
    var tk = JToken()
    tk.type = .string
    tk.value = cSb
    tokens.append(tk)
    continue
}
```

### 正则分词

字符串处理完就是正则的处理，正则开始的标示是 /[，和字符串的处理不同的是需要判断两个字符才能确定是正则的处理。其它的处理和字符串类似，具体实现如下：

```swift
// 处理 / 符号，这个是正则的处理，比如 if (/[0-9\.]/.test(currentChar)) {
if s == "/" {
    var cSb = ""
    var escaped = false
    var tk = JToken()
    tk.type = .regular

    while let cChar = currentChar {
        let str = cChar.description
        cSb.append(str)
        advanceIndex()
        if escaped {
            escaped = false
        } else if str == "\\" {
            escaped = true
        } else if str == "]" {
            if currentChar?.description == s {
                cSb.append(s)
                advanceIndex()
                break
            }
        }
        // 下个不是 [ 及不满足正则表达式，直接把 / 作为 token
        if currentChar?.description != "[" && !escaped && str == "/" {
            tk.type = .slash
            break
        }
    }

    tk.value = cSb
    tokens.append(tk)
    continue
}
```

### 空格换行和 ; 符号等间隔符号

这些都直接跳过：

```swift
// 处理 " ", "\n", ";"
if eofs.contains(s) {
    // 空格
    advanceIndex()
    continue
}
```

### 保留符号和操作符

这里需要注意下面几个问题

* 先创建一个集合，通过判断当前字符是否在那个集合里进行处理。
* 跳出处理的两个条件，第一个是空字符和结束符时跳出，第二个是加上这个符号后是否满足组合保留符号
* 保留符号设计时会考虑到避免多个字符的保留符号会包含保留符号的情况。比如 === 包含了 == 所以这样的情况会在后面的 parser 阶段去处理

完整实现如下：

```swift
if symbols.contains(s) {
    // 处理保留符号
    var cSb = ""
    while let cChar = currentChar {
        let sb = cChar.description
        if eofs.contains(sb) {
            break //空字符和结束符时跳出
        }
        let checkForwardStr = cSb + sb
        if symbols.contains(checkForwardStr) {
            cSb = checkForwardStr
        } else {
            break //检查加上这个符号后是否满足组合保留符号
        }
        advanceIndex()
        continue
    }
    tokens.append(tokenFrom(cSb))
    continue
```

### 数字的处理

数字的跳出条件是遇到空格，换行，结束符号，除点符号外的非数字符号都会跳出。数字和点符号都会累加最后形成完整的一个数字 token。最后判断下数字的类型是整形还是浮点。下面是数字处理的完整实现：

```swift
} else if (s.isInt()) {
    // 处理数字
    // 在 else 条件里处理数字 0.1 这样的，当第一个是数字时，连续开始处理数字，有 . 符号也不 break，除非是碰到非数字或者其它符号
    var numStr = ""
    while let cChar = currentChar {
        let str = cChar.description
        if str.isInt() || str == "." {
            numStr.append(str)
        } else {
            break
        }
        advanceIndex()
    }
    var tk = JToken()
    // 判断数字类型
    if numStr.isInt() {
        tk.type = .int
    }
    if numStr.isFloat() {
        tk.type = .float
    }
    tk.value = numStr
    tokens.append(tk)
    continue
```

### 关键字，变量，函数名和方法等

老规矩找出跳出条件，这些的通性在于遇到保留符号和空格那些间隔符号时跳出。设计一个 tokenFrom 函数统一处理 token 的生成，还有操作符的优先级设置等，里面把 token 的类型和入参字符串绑定，如果不是关键字字符串就将类型设置为 none，在语义分析环节进行类别分析。

```swift
} else {
    // 处理关键字
    // TODO: 允许 $ 和 _ 符号作为开头，或者在 parser 环节处理。
    var word = ""
    while let sChar = currentChar {
        let str = sChar.description
        if symbols.contains(str) || eofs.contains(str) {
            break
        }
        word.append(str)
        advanceIndex()
        continue
    }
    //开始把连续字符进行 token 存储
    if word.count > 0 {
        // 这里返回的 token 类型如果是 none 表示的就是非关键字的变量，函数名和方法什么的
        tokens.append(tokenFrom(word))
    }
    continue
```

### 测试 Case1

将前面做的做个测试 case，用来跟踪后面的修改是否会影响前面的开发。总的思想是 hash 保留正确的结果，后面通过和动态得到的结果进行比较来看是否能够通过。这个 case 主要的关注点是字符串，正则，数字。

先写个需要测试的代码：

```swift
let _case_1 = """
const tokens = [45,34.5,"this","is","case1 content is const tokens = [\\"bulabula\\"]"];
if (/[0-9]/.test(currentChar)) {
    var num = 1244.7 % 889;
}
"""
```

编写一个函数用来返回 hash 的结果，入参是 token 集合

```swift
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
```

看看打印出来的结果：

```bash
Case1 String is:const tokens = [45,34.5,"this","is","case1 content is const tokens = [\"bulabula\"]"];
if (/[0-9]/.test(currentChar)) {
    var num = 1244.7 % 889;
}
const      :::    const
tokens      :::    none
=      :::    eq
[      :::    braceL
45      :::    float
,      :::    comma
34.5      :::    float
,      :::    comma
this      :::    string
,      :::    comma
is      :::    string
,      :::    comma
case1 content is const tokens = [\"bulabula\"]      :::    string
]      :::    braceR
if      :::    if
(      :::    parenL
/[0-9]/      :::    regular
.      :::    dot
test      :::    none
(      :::    parenL
currentChar      :::    none
)      :::    parenR
)      :::    parenR
{      :::    braceL
var      :::    var
num      :::    none
=      :::    eq
1244.7      :::    float
%      :::    modulo
889      :::    float
}      :::    braceR
const|const:tokens|none:=|eq:[|braceL:45|float:,|comma:34.5|float:,|comma:this|string:,|comma:is|string:,|comma:case1 content is const tokens = [slash"bulabulaslash"]|string:]|braceR:if|if:(|parenL:/[0-9]/|regular:.|dot:test|none:(|parenL:currentChar|none:)|parenR:)|parenR:{|braceL:var|var:num|none:=|eq:1244.7|float:%|modulo:889|float:}|braceR:
```

正确的结果我们先记录下来：

```swift
let _case_1_hash = """
const|const:tokens|none:=|eq:[|braceL:45|float:,|comma:34.5|float:,|comma:this|string:,|comma:is|string:,|comma:case1 content is const tokens = [slash"bulabulaslash"]|string:]|braceR:if|if:(|parenL:/[0-9]/|regular:.|dot:test|none:(|parenL:currentChar|none:)|parenR:)|parenR:{|braceL:var|var:num|none:=|eq:1244.7|float:%|modulo:889|float:}|braceR:
"""
```

后面编写个 case1 的函数用来比较后面跑的结果是否和预期正确的结果是否相等。

```swift
// Case1 包含了字符串，正则，数字还有基本的 token 的测试
func checkCase_1() {
    let tks = JTokenizer(_case_1).tokenizer()
    if isPrintable {
        print("Case1 String is:\(_case_1)")
    }
    let hash = hashFrom(tokens: tks)
    if hash == _case_1_hash {
        print("case1 ✅")
    } else {
        print("case1 ❌")
    }
}
```

这样如果 case1 通过就会打印

```bash
case1 ✅
```

没通过

```bash
case1 ❌
```

## 18.5.4

* Babel 插件调研。总结
* OC 的 BNF 参考 antlr 里 grammars-v4
 <https://github.com/antlr/grammars-v4/blob/master/objc/ObjectiveCParser.g4>

## 18.5.2 完成代码到代码架构雏形

### 雏形需要达成的样子，lisp 代码，c 代码和它们的 AST

```bash
 *                  LISP                      C
 *
 *   2 + 2          (add 2 2)                 add(2, 2)
 *   4 - 2          (subtract 4 2)            subtract(4, 2)
 *   2 + (4 - 2)    (add 2 (subtract 4 2))    add(2, subtract(4, 2))


 * ----------------------------------------------------------------------------
 *            原始的 AST               |               转换后的 AST
 * ----------------------------------------------------------------------------
 *   {                                |   {
 *     type: 'Program',               |     type: 'Program',
 *     body: [{                       |     body: [{
 *       type: 'CallExpression',      |       type: 'ExpressionStatement',
 *       name: 'add',                 |       expression: {
 *       params: [{                   |         type: 'CallExpression',
 *         type: 'NumberLiteral',     |         callee: {
 *         value: '2'                 |           type: 'Identifier',
 *       }, {                         |           name: 'add'
 *         type: 'CallExpression',    |         },
 *         name: 'subtract',          |         arguments: [{
 *         params: [{                 |           type: 'NumberLiteral',
 *           type: 'NumberLiteral',   |           value: '2'
 *           value: '4'               |         }, {
 *         }, {                       |           type: 'CallExpression',
 *           type: 'NumberLiteral',   |           callee: {
 *           value: '2'               |             type: 'Identifier',
 *         }]                         |             name: 'subtract'
 *       }]                           |           },
 *     }]                             |           arguments: [{
 *   }                                |             type: 'NumberLiteral',
 *                                    |             value: '4'
 * ---------------------------------- |           }, {
 *                                    |             type: 'NumberLiteral',
 *                                    |             value: '2'
 *                                    |           }]
 *         (那一边比较长/w\)            |         }]
 *                                    |       }
 *                                    |     }]
 *                                    |   }
 * ----------------------------------------------------------------------------
 */
```

### 遍历器

昨天已将 lisp 代码生成了 AST。

今天对生成的 AST 进行遍历，设计一个 JTraverser 的类，用一个 key value 结构来记录不同类型节点的回调处理闭包，作为入参。

```swift
public func traverser(visitor:[String:VisitorClosure])
```

在遍历到对应的节点时，通过对应类型的 key 去执行对应的闭包，完整 traverser 函数：

```swift
public func traverser(visitor:[String:VisitorClosure]) {

    func traverseChildNode(childrens:[JNode], parent:JNode) {
        for child in childrens {
            traverseNode(node: child, parent: parent)
        }
    }

    func traverseNode(node:JNode, parent:JNode) {
        //会执行外部传入的 Closure
        if visitor.keys.contains(node.type.rawValue) {
            if let closure:VisitorClosure = visitor[node.type.rawValue] {
                closure(node,parent)
            }
        }
        //看是否有子节点需要继续遍历
        if node.params.count > 0 {
            traverseChildNode(childrens: node.params, parent: node)
        }
    }
    let rootNode = JNode()
    rootNode.type = .Root
    traverseChildNode(childrens: _ast, parent: rootNode)
}
```

### 从一个 AST 到另外一个语言 AST 的雏形

先起个名字 JTransformer 作为执行该任务的类，在构造函数里去执行 JTraverser 的 traverser 遍历函数，改函数需要的回调闭包在这里写好。先看看 NumberLiteral 这个类型的闭包做的事情，由于这个节点是没有子节点的，那么就不需要将 currentParent 设置为这个节点。

这时它的父节点有几种情况，一种是 ExpressionStatement，一种是 CallExpression，这两种情况都需要将当前 NumberLiteral 这种类型节点添加到它们的 arguments 里。实现如下：

```swift
let numberLiteralClosure:VisitorClosure = { (node,parent) in
    if currentParent.type == .ExpressionStatement {
        currentParent.expressions[0].arguments.append(node)
    }
    if currentParent.type == .CallExpression {
        currentParent.arguments.append(node)
    }
}
```

接下来是对 CallExpression 这种类型节点的处理，它分为两种情况，一种是父节点也是 CallExpression 类型的，一种不是，如果不是就需要判断是否是 Root 类型的根结点了。

首先如果不是 CallExpression 类型就需要新生成一个类型是 ExpressionStatement 的节点，在父节点是 Root 的情况下将其添加到新的 AST 的根下，然后把 currentParent 设为新生成的 ExpressionStatement 类型节点。

如果是 CallExpression 类型，那么父节点在这个 case 里就是 ExpressionStatement 的，那么这个 CallExpression 类型的节点在这个 case 里就一定是个参数。我们只需要将其添加到 ExpressionStatement 的 expression 的 arguments 里即可，具体代码实现如下：

```swift
let callExpressionClosure:VisitorClosure = { (node,parent) in
    let exp = JNode()
    exp.type = .CallExpression

    let callee = JNodeCallee()
    callee.type = .Identifier
    callee.name = node.name
    exp.callee = callee

    if parent.type != .CallExpression {
        let exps = JNode()
        exps.type = .ExpressionStatement
        exps.expressions.append(exp)
        if parent.type == .Root {
            self.ast.append(exps)
        }
        currentParent = exps
    } else {
        currentParent.expressions[0].arguments.append(exp)
        currentParent = exp
    }
}
```

### 代码生成雏形

这里后面肯定会完善，先粗略的用递归方式将转好的语法树转成代码就好：

```swift
public init(_ input:String) {
    let ast = JTransformer(input).ast
    for aNode in ast {
        code.append(recGeneratorCode(aNode))
    }
    print("The code generated:")
    print(code)
}

public func recGeneratorCode(_ node:JNode) -> String {
    var code = ""
    if node.type == .ExpressionStatement {
        for aExp in node.expressions {
            code.append(recGeneratorCode(aExp))
        }
    }
    if node.type == .CallExpression {
        code.append(node.callee.name)
        code.append("(")
        if node.arguments.count > 0 {
            for (index,arg) in node.arguments.enumerated() {
                code.append(recGeneratorCode(arg))
                if index != node.arguments.count - 1 {
                    code.append(", ")
                }
            }
        }
        code.append(")")
    }
    if node.type == .Identifier {
        code.append(node.name)
    }
    if node.type == .NumberLiteral {
        switch node.numberType {
        case .float:
            code.append(String(node.floatValue))
        case .int:
            code.append(String(node.intValue))
        }
    }

    return code
}
```

这个类就可以完成从一个语言代码转换成一个新语言代码，把过程和结果打印出来如下：

```swift
Input code is:
(add 2 (subtract 4.4 2))
Before transform AST:
 CallExpression expression is CallExpression(add)
       NumberLiteral number type is int number is 2
       CallExpression expression is CallExpression(subtract)
          NumberLiteral number type is float number is 4.4
          NumberLiteral number type is int number is 2
After transform AST:
 ExpressionStatement 
       CallExpression expression is CallExpression(add)
          NumberLiteral number type is int number is 2
          CallExpression expression is CallExpression(subtract)
             NumberLiteral number type is float number is 4.4
             NumberLiteral number type is int number is 2
The code generated:
add(2, subtract(4.4, 2))
```

## 18.4.28

### 解析器 Token 解析雏形

解析器需要进行优化，先从一个小型解析器开始，后期方便回顾。
那么先从 token 的解析开始，创建一个 JToken 结构体：

```swift
public struct JToken {
    var type = ""
    var value = ""
}
```

在创建一个 JTokenizer 来切 token

```swift
public class JTokenizer {
    private var _input: String
    private var _index: String.Index

    public init(_ input: String) {
        _input = input.filterAnnotationBlock()
        _index = _input.startIndex
    }

    public func tokenizer() -> [JToken] {
        var tokens = [JToken]()
        while let aChar = currentChar {
            let s = aChar.description
            let symbols = ["(",")"," "]
            if symbols.contains(s) {
                if s == " " {
                    //空格
                    advanceIndex()
                    continue
                }
                //特殊符号
                tokens.append(JToken(type: "paren", value: s))
                advanceIndex()
                continue
            } else {
                var word = ""
                while let sChar = currentChar {
                    let str = sChar.description
                    if symbols.contains(str) {
                        break
                    }
                    word.append(str)
                    advanceIndex()
                    continue
                }
                //开始把连续字符进行 token 存储
                if word.count > 0 {
                    var tkType = "char"
                    if word.isFloat() {
                        tkType = "float"
                    }
                    if word.isInt() {
                        tkType = "int"
                    }

                    tokens.append(JToken(type: tkType, value: word))
                }
                continue
            } // end if
        } // end while

        return tokens
    }

    //parser tool
    var currentChar: Character? {
        return _index < _input.endIndex ? _input[_index] : nil
    }
    func advanceIndex() {
        _input.formIndex(after: &_index)
    }
}
```

这段代码和先前处理不同的组合字符，在 while 里会再开启一个 while 去连续获取组合字符。非单个的连续关键字比如 += 这样的后面再完善。代码如下：

```swift
var word = ""
while let sChar = currentChar {
    let str = sChar.description
    if symbols.contains(str) {
        break
    }
    word.append(str)
    advanceIndex()
    continue
}
//开始把连续字符进行 token 存储
if word.count > 0 {
    var tkType = "char"
    if word.isFloat() {
        tkType = "float"
    }
    if word.isInt() {
        tkType = "int"
    }

    tokens.append(JToken(type: tkType, value: word))
}
continue
```

对 String 的扩展里三个方法，分别是

### 过滤注释，判断是否是 Int 和判断是否是 Float

```swift
//过滤注释
func filterAnnotationBlock() -> String {
    //过滤注释
    var newStr = ""
    let annotationBlockPattern = "/\\*[\\s\\S]*?\\*/" //匹配/*...*/这样的注释
    let regexBlock = try! NSRegularExpression(pattern: annotationBlockPattern, options: NSRegularExpression.Options(rawValue:0))
    newStr = regexBlock.stringByReplacingMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, self.count), withTemplate: "")
    return newStr
}
//判断是否是整数
func isInt() -> Bool {
    let scan:Scanner = Scanner(string: self)
    var val:Int = 0
    return scan.scanInt(&val) && scan.isAtEnd
}
//判断是否是 Float
func isFloat() -> Bool {
    let scan:Scanner = Scanner(string: self)
    var val:Float = 0
    return scan.scanFloat(&val) && scan.isAtEnd
}
```

接下来输入一个代码看看解析的效果

```swift
let a = JTokenizer("(add 2 (subtract 4.4 2))").tokenizer()
print("\(a)")
```

结果

```swift
[HTN.JToken(type: "paren", value: "("),
HTN.JToken(type: "char", value: "add"), 
HTN.JToken(type: "int", value: "2"), 
HTN.JToken(type: "paren", value: "("), 
HTN.JToken(type: "char", value: "subtract"), 
HTN.JToken(type: "float", value: "4.4"), 
HTN.JToken(type: "int", value: "2"), 
HTN.JToken(type: "paren", value: ")"), 
HTN.JToken(type: "paren", value: ")")]
```

### 组合关键字的处理

和组合字符思路是类似的，先定义一个集合记录哪些符号是可以组合的

```swift
let combinedSymbols = ["+","="]
```

再开始组合这些符号

```swift
if combinedSymbols.contains(s) {
    var cSb = ""
    while let cChar = currentChar {
        let sb = cChar.description
        if !combinedSymbols.contains(sb) {
            break
        }
        cSb.append(sb)
        advanceIndex()
        continue
    }
    tokens.append(JToken(type: "paren", value: cSb))
    continue
}
```

### 设计 JNode 的雏形

采用协议式的思路能够将不同节点类型进行一个归类

```swift
// Base
public enum JNodeType {
    case None
    case NumberLiteral
    case CallExpression
}
public protocol JNodeBase {
    var type: JNodeType {get}
    var name: String {get}
    var params: [JNode] {get}
}
// NumberLiteral
public enum JNumberType {
    case int,float
}
public protocol JNodeNumberLiteral {
    var numberType: JNumberType {get}
    var intValue: Int {get}
    var floatValue: Float {get}
}
// CallExpression
public protocol JNodeCallExpression {}

// Struct
public struct JNode:JNodeBase,JNodeNumberLiteral {
    public var type = JNodeType.None
    public var name = ""
    public var params = [JNode]()
    public var numberType = JNumberType.int
    public var intValue:Int = 0
    public var floatValue:Float = 0
}
```

### 开发 AST 生成

这块就不多说了，主要是递归下降思想

```swift
// 解析类
public class JParser {
    private var _tokens: [JToken]
    private var _current: Int

    public init(_ input:String) {
        _tokens = JTokenizer(input).tokenizer()
        _current = 0
    }
    public func parser() -> [JNode] {
        _current = 0
        var nodeTree = [JNode]()
        while _current < _tokens.count {
            nodeTree.append(walk())
        }
        _current = 0 //用完重置
        return nodeTree
    }

    private func walk() -> JNode {
        var tk = _tokens[_current]
        var jNode = JNode()
        //检查是不是数字类型节点
        if tk.type == "int" || tk.type == "float" {
            _current += 1
            jNode.type = .NumberLiteral
            if tk.type == "int", let intV = Int(tk.value) {
                jNode.intValue = intV
                jNode.numberType = .int
            }
            if tk.type == "float", let floatV = Float(tk.value) {
                jNode.floatValue = floatV
                jNode.numberType = .float
            }
            return jNode

        }
        //检查是否是 CallExpressions 类型
        if tk.type == "paren" && tk.value == "(" {
            //跳过符号
            _current += 1
            tk = _tokens[_current]

            jNode.type = .CallExpression
            jNode.name = tk.value
            _current += 1
            while tk.type != "paren" || (tk.type == "paren" && tk.value != ")") {
                //递归下降
                jNode.params.append(walk())
                tk = _tokens[_current]
            }
            //跳到下一个
            _current += 1
            return jNode
        }
        _current += 1
        return jNode
    }
}
```

### 美化打印可视化，方便后面的调试

不过随着这个雏形的增加和完善，这里也需要同步开发

```swift
// --------- 打印 AST，方便调试 ---------
private func astPrintable(_ tree:[JNode]) {
    for aNode in tree {
        recDesNode(aNode, level: 0)
    }
}
private func recDesNode(_ node:JNode, level:Int) {
    let nodeTypeStr = node.type
    var preSpace = ""
    for _ in 0...level {
        if level > 0 {
            preSpace += "   "
        }
    }
    var dataStr = ""
    switch node.type {
    case .NumberLiteral:
        var numberStr = ""
        if node.numberType == .float {
            numberStr = "\(node.floatValue)"
        }
        if node.numberType == .int {
            numberStr = "\(node.intValue)"
        }
        dataStr = "number type is \(node.numberType) number is \(numberStr)."
    case .CallExpression:
        dataStr = "expression is \(node.type)(\(node.name))"
    case .None:
        dataStr = ""
    }
    print("\(preSpace) \(nodeTypeStr) \(dataStr)")

    if node.params.count > 0 {
        for aNode in node.params {
            recDesNode(aNode, level: level + 1)
        }
    }
}
```

打印的结果如下

```bash
CallExpression expression is CallExpression(add)
      NumberLiteral number type is int number is 2
      CallExpression expression is CallExpression(subtract)
         NumberLiteral number type is float number is 4.4
         NumberLiteral number type is int number is 2
```

## 18.4.26

### babel-cli 工具链

安装了 babel-cli 工具链，使用工具链将能够降级 es6 到 es5 输出 ast 的 json

```js
var babel = require('babel-core');
let ast = babel.transformFileSync('weektest.js', {"presets": ["env"]}).ast.program.body;
let prettyAst = JSON.stringify(ast, null, 4);
console.log(prettyAst)
```

bebel-node 命令能够执行上面的 js 脚本，在 package.json 里能够方便的定义别名，json 文件完成如下：

```json
{
  "name": "my-project",
  "version": "1.0.0",
  "scripts": {
    "b": "babel es6fortest.js",
    "bt": "babel es6fortest.js --out-file compiledEs6fortest.js",
    "bast": "babel-node usebabelcore.js"
  },
  "devDependencies": {
    "babel-cli": "^6.26.0",
    "babel-preset-env": "^1.6.1",
    "babel-preset-es2015": "^6.24.1"
  }
}
```

这样只用执行

```shell
npm run bast
```

### Swift 处理 shell

swift 工具方面做了个 shell 封装，能够调起 babel 命令。

```swift
func shell(_ args: String...) -> String {
    let process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = args

    let pipe = Pipe()
    process.standardOutput = pipe

    process.launch()
    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = String(data: data, encoding: .utf8)!

    return output
}

let result = shell("npm","run","bast")
print("ls result:\n\(result)")
```

得到的 output 需要转成 Dictionary

```swift
let jsonStringClear = json.replacingOccurrences(of: "\n", with: "")
let jsonData = jsonStringClear.data(using: .utf8)!

let decoder = JSONDecoder()
do {
    let a = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! [Dictionary<String, Any>]
    for c in a {
        print(c["type"] ?? "")
    }
} catch let error as NSError { print(error) }
```

Vue 方面的简单实用可以看官方的介绍部分，了解了组件，Vue 的一些接口，实例的属性和实例的生命周期。

## 以下归档（历史）

## 前言

HTN 是一个将HTML 转换为原生Swift 和 Objective-C组件的项目，本文主要是记录 HTN 项目开发的过程。关于这个项目先前在 Swift 开发者大会上我曾经演示过，不过当时项目结构不完善，不易扩展，也没有按照标准来。所以这段时间，我研究了下 W3C 的标准和 WebKit 的一些实现，对于这段时间的研究也写了篇文章[深入剖析 WebKit](http://www.starming.com/2017/10/11/deeply-analyse-webkit/)。重构了下这个项目，我可以先说下已经完成的部分，最后列下后面的规划。项目已经放到了 Github 上：[https://github.com/ming1016/HTN](https://github.com/ming1016/HTN) 后面可以对着代码看。

## 项目使用介绍

通过解析 html 生成 DOM 树，解析 CSS，生成渲染树，计算布局，最终生成原生 Textrue 代码。下面代码可以看到完整的过程的各个方法。

```swift
let treeBuilder = HTMLTreeBuilder(htmlStr) //htmlStr 就是 需要转的 html 代码
_ = treeBuilder.parse() //解析 html 生成 DOM 树
let cssStyle = CSSParser(treeBuilder.doc.allStyle()).parseSheet() //解析 CSS
let document = StyleResolver().resolver(treeBuilder.doc, styleSheet: cssStyle) //生成渲染树

//转 Textrue
let layoutElement = LayoutElement().createRenderer(doc: document) //计算布局
_ = HTMLToTexture(nodeName:"Flexbox").converter(layoutElement); //生成原生 Textrue 代码
```

比如有下面的 html

![04](https://ming1016.github.io/uploads/html-to-native-htn-development-record/04.png)

在浏览器里显示是这样

![06](https://ming1016.github.io/uploads/html-to-native-htn-development-record/06.png)

通过 HTN 生成的原生代码

![05](https://ming1016.github.io/uploads/html-to-native-htn-development-record/05.png)

在 iPhone X 模拟器的效果如下

![07](https://ming1016.github.io/uploads/html-to-native-htn-development-record/07.png)

下面详细介绍下具体的实现关键点

## HTML

这部分最关键的部分是在 HTML/HTMLTokenizer.swift 里。首先会根据 W3C 里的 Tokenization 的标准 [https://dev.w3.org/html5/spec-preview/tokenization.html](https://dev.w3.org/html5/spec-preview/tokenization.html) 来定义一个状态的枚举，如下，可以目前完成这些状态的情况
```swift
//枚举
    enum S: HTNStateType {
        case DataState //half done
        case CharacterReferenceInDataState
        case RCDATAState
        case CharacterReferenceInRCDATAState
        case RAWTEXTState
        case ScriptDataState
        case PLAINTEXTState
        case TagOpenState //half done
        case EndTagOpenState
        case TagNameState //half done
        
        case RCDATALessThanSignState
        case RCDATAEndTagOpenState
        case RCDATAEndTagNameState
        
        case RAWTEXTLessThanSignState
        case RAWTEXTEndTagOpenState
        case RAWTEXTEndTagNameState
        
        //Script
        case ScriptDataLessThanSignState
        case ScriptDataEndTagOpenState
        case ScriptDataEndTagNameState
        case ScriptDataEscapeStartState
        case ScriptDataEscapeStartDashState
        case ScriptDataEscapedState
        case ScriptDataEscapedDashState
        case ScriptDataEscapedDashDashState
        case ScriptDataEscapedLessThanSignState
        case ScriptDataEscapedEndTagOpenState
        case ScriptDataEscapedEndTagNameState
        case ScriptDataDoubleEscapeStartState
        case ScriptDataDoubleEscapedState
        case ScriptDataDoubleEscapedDashState
        case ScriptDataDoubleEscapedDashDashState
        case ScriptDataDoubleEscapedLessThanSignState
        case ScriptDataDoubleEscapeEndState
        
        //Tag
        case BeforeAttributeNameState
        case AttributeNameState //half done
        case AfterAttributeNameState
        case BeforeAttributeValueState
        case AttributeValueDoubleQuotedState //half done
        case AttributeValueSingleQuotedState
        case AttributeValueUnquotedState
        case CharacterReferenceInAttributeValueState
        case AfterAttributeValueQuotedState //half done
        case SelfClosingStartTagState
        case BogusCommentState
        case ContinueBogusCommentState
        case MarkupDeclarationOpenState //half done
        
        //Comment
        case CommentStartState //half done
        case CommentStartDashState
        case CommentState
        case CommentEndDashState //half done
        case CommentEndState //half done
        case CommentEndBangState
        
        //DOCTYPE
        case DOCTYPEState //half done
        case BeforeDOCTYPENameState //half done
        case DOCTYPENameState
        case AfterDOCTYPENameState //half done
        case AfterDOCTYPEPublicKeywordState //half done
        case BeforeDOCTYPEPublicIdentifierState //half done
        case DOCTYPEPublicIdentifierDoubleQuotedState //half done
        case DOCTYPEPublicIdentifierSingleQuotedState
        case AfterDOCTYPEPublicIdentifierState //half done
        case BetweenDOCTYPEPublicAndSystemIdentifiersState
        case AfterDOCTYPESystemKeywordState
        case BeforeDOCTYPESystemIdentifierState
        case DOCTYPESystemIdentifierDoubleQuotedState
        case DOCTYPESystemIdentifierSingleQuotedState
        case AfterDOCTYPESystemIdentifierState
        case BogusDOCTYPEState
        
        case CDATASectionState
        case CDATASectionRightSquareBracketState
        case CDATASectionDoubleRightSquareBracketState
    }
```

处理这些状态采用的是状态机原理。根据状态机数学模型提取出需要的状态集合，事件集合，事件集合在这里是所遇字符的集合做了一个状态机，具体实现在 HTNFundation/HTNStateMachine.swift。状态转移函数我定义的是 func listen(_ event: E, transit fromState: S, to toState: S, callback: @escaping (HTNTransition<S, E>) -> Void) ，这里的 block 是在状态转移时需要做的事情定义 。为了能够减少状态转移太多太碎，也多写了几个函数来处理比如一组来源状态到同一个转移状态和针对某些事件状态不变的函数。

有了状态机后面的处理就会很方便，这里的事件就是一个一个的字符，不同字符在不同的状态下的处理。下面可以举个多状态转同一状态的实现，具体代码如下：

```swift
let anglebracketRightEventFromStatesArray = [S.DOCTYPEState,
                                             S.CommentEndState,
                                             S.TagOpenState,
                                             S.EndTagOpenState,
                                             S.AfterAttributeValueQuotedState,
                                             S.BeforeDOCTYPENameState,
                                             S.AfterDOCTYPEPublicIdentifierState]
stateMachine.listen(E.AngleBracketRight, transit: anglebracketRightEventFromStatesArray, to: S.DataState) { (t) in
    if t.fromState == S.TagOpenState || t.fromState == S.EndTagOpenState {
        if self._bufferStr.count > 0 {
            self._bufferToken.data = self._bufferStr.lowercased()
        }
    }
    self.addHTMLToken()
    self.advanceIndexAndResetCurrentStr()
}
```

W3C 也定义每个状态的处理，非常详细完整，WebKit 基本把这些定义都实现了，HTN 目前只实现了能够满足构建 DOM 树的部分。W3C 的定义可以举个 StartTags 的状态如下图
![01](https://ming1016.github.io/uploads/html-to-native-htn-development-record/01.png)

在进入构建 DOM 树之前我们需要设计一些类和结构来记录我们的内容，这里采用了 WebKit 类似的类结构设计，下图是 WebKit 的 DOM 树相关的类设计图
![02](https://ming1016.github.io/uploads/html-to-native-htn-development-record/02.png)

完成了这些状态处理，接下来就可以根据这些 HTMLToken 来组装我们的 DOM 树了。这部分的实现在 HTML/HTMLTreeBuilder.swift 里。构建 DOM 树同样使用了先前的写的状态机，只是这里的状态集和事件集不同而已，W3C 也定义一些状态可以用

```swift
enum S: HTNStateType {
    case InitialModeState
    case BeforeHTMLState
    case BeforeHeadState
    case InHeadState
    case AfterHeadState
    case InBodyState
    case AfterBodyState
    case AfterAfterBodyState
}
```

从名字就能很方便的看出每个状态的意思。这里的事件集使用的是 HTMLToken 里的类型，根据不同类型来放置到合适的位置。树的父级子级是通过定义的一个堆栈来控制，具体构建实现可以看 func parse() -> [HTMLToken] 这个函数。

## CSS

解析 CSS 需要先了解下 CSS 的 BNF，它的定义如下：

```
ruleset
  : selector [ ',' S* selector ]*
    '{' S* declaration [ ';' S* declaration ]* '}' S*
  ;
selector
  : simple_selector [ combinator selector | S+ [ combinator selector ] ]
  ;
simple_selector
  : element_name [ HASH | class | attrib | pseudo ]*
  | [ HASH | class | attrib | pseudo ]+
  ;
class
  : '.' IDENT
  ;
element_name
  : IDENT | '*'
  ;
attrib
  : '[' S* IDENT S* [ [ '=' | INCLUDES | DASHMATCH ] S*
    [ IDENT | STRING ] S* ] ']'
  ;
pseudo
  : ':' [ IDENT | FUNCTION S* [IDENT S*] ')' ]
  ;
```

根据 BNF 来确定状态集和事件集。下面是我定义的状态集和事件集

```swift
enum S: HTNStateType {
    case UnknownState     //
    case SelectorState    // 比如 div p, #id
    case PropertyKeyState   // 属性的 key
    case PropertyValueState // 属性的 value
    
    //TODO:以下后期支持，优先级2
    case PseudoClass      // :nth-child(2)
    case PseudoElement    // ::first-line
    
    //TODO:以下后期支持，优先级3
    case PagePseudoClass
    case AttributeExact   // E[attr]
    case AttributeSet     // E[attr|="value"]
    case AttributeHyphen  // E[attr~="value"]
    case AttributeList    // E[attr*="value"]
    case AttributeContain // E[attr^="value"]
    case AttributeBegin   // E[attr$="value"]
    case AttributeEnd
    //TODO:@media 这类 @规则 ，后期支持，优先级4
}
enum E: HTNEventType {
    case SpaceEvent   //空格
    case CommaEvent   // ,
    case DotEvent     // .
    case HashTagEvent // #
    case BraceLeftEvent  // {
    case BraceRightEvent // }
    case ColonEvent // :
    case SemicolonEvent  // ;
}
```

同样在状态的处理过程中也需要一个合理的类结构关系设计来满足，这里也参考了 WebKit 里的设计，如下：
![03](https://ming1016.github.io/uploads/html-to-native-htn-development-record/03.png)

## 布局

布局处理目前 HTN 主要是将样式属性和 DOM 树里的 Element 对应上。具体实现是在 Layout/StyleResolver.swift 里。思路是先将所有 CSSRule 和对应的 CSSSelector 做好映射，接着在递归 DOM 树的过程中与每个 Element 对应上。主要代码实现如下：

```swift
public func resolver(_ doc:Document, styleSheet:CSSStyleSheet) -> Document{
    //样式映射表
    //这种结构能够支持多级 Selector
    var matchMap = [String:[String:[String:String]]]()
    for rule in styleSheet.ruleList {
        for selector in rule.selectorList {
            guard let matchLast = selector.matchList.last else {
                continue
            }
            var matchDic = matchMap[matchLast]
            if matchDic == nil {
                matchDic = [String:[String:String]]()
                matchMap[matchLast] = matchDic
            }
            
            //这里可以按照后加入 rulelist 的优先级更高的原则进行覆盖操作
            if matchMap[matchLast]![selector.identifier] == nil {
                matchMap[matchLast]![selector.identifier] = [String:String]()
            }
            for a in rule.propertyList {
                matchMap[matchLast]![selector.identifier]![a.key] = a.value
            }
        }
    }
    for elm in doc.children {
        self.attach(elm as! Element, matchMap: matchMap)
    }
    
    return doc
}
//递归将样式属性都加上
func attach(_ element:Element, matchMap:[String:[String:[String:String]]]) {
    guard let token = element.startTagToken else {
        return
    }
    if matchMap[token.data] != nil {
        //TODO: 还不支持 selector 里多个标签名组合，后期加上
        addProperty(token.data, matchMap: matchMap, element: element)
    }
    
    //增加 property 通过处理 token 里的属性列表里的 class 和 id 在 matchMap 里找
    for attr in token.attributeList {
        if attr.name == "class" {
            addProperty("." + attr.value.lowercased(), matchMap: matchMap, element: element)
        }
        if attr.name == "id" {
            addProperty("#" + attr.value.lowercased(), matchMap: matchMap, element: element)
        }
    }
    
    if element.children.count > 0 {
        for element in element.children {
            self.attach(element as! Element, matchMap: matchMap)
        }
    }
}

func addProperty(_ key:String, matchMap:[String:[String:[String:String]]], element:Element) {
    guard let dic = matchMap[key] else {
        return
    }
    for aDic in dic {
        var selectorArr = aDic.key.components(separatedBy: " ")
        if selectorArr.count > 1 {
            //带多个 selector 的情况
            selectorArr.removeLast()
            if !recursionSelectorMatch(selectorArr, parentElement: element.parent as! Element) {
                continue
            }
        }
        guard let ruleDic = dic[aDic.key] else {
            continue
        }
        //将属性加入 element 的属性列表里
        for property in ruleDic {
            element.propertyMap[property.key] = property.value
        }
    }
    
}
```

这里通过 recursionSelectorMatch 来按照 CSS Selector 从右到左的递归出是否匹配路径，具体实现代码如下：

```swift
//递归找出匹配的多路径
func recursionSelectorMatch(_ selectors:[String], parentElement:Element) -> Bool {
    var selectorArr = selectors
    guard var last = selectorArr.last else {
        //表示全匹配了
        return true
    }
    guard let parent = parentElement.parent else {
        return false
    }
    
    var isMatch = false

    if last.hasPrefix(".") {
        last.characters.removeFirst()
        //TODO:这里还需要考虑attribute 空格多个 class 名的情况
        guard let startTagToken = parentElement.startTagToken else {
            return false
        }
        if startTagToken.attributeDic["class"] == last {
            isMatch = true
        }
    } else if last.hasPrefix("#") {
        last.characters.removeFirst()
        guard let startTagToken = parentElement.startTagToken else {
            return false
        }
        if startTagToken.attributeDic["id"] == last {
            isMatch = true
        }
    } else {
        guard let startTagToken = parentElement.startTagToken else {
            return false
        }
        if startTagToken.data == last {
            isMatch = true
        }
    }

    if isMatch {
        //匹配到会继续往前去匹配
        selectorArr.removeLast()
    }
    return recursionSelectorMatch(selectorArr, parentElement: parent as! Element)

}
```
































