//
//  File.swift
//  HTN
//
//  Created by DaiMing on 2018/5/9.
//

import Foundation

public protocol JNode {}
// A literal token. May or may not represent an expression.
public protocol JNodeLiterals: JNode {}
public protocol JNodePattern: JNode {}
public protocol JNodeStatement: JNode {}
// Any expression node. Since the left-hand side of an assignment may be any expression in general, an expression can also be a pattern.
public protocol JNodeExpression: JNode {}
// Any declaration node. Note that declarations are considered statements; this is because declarations can appear in any statement context.
public protocol JNodeDeclaration: JNodeStatement {}

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

// An identifier. Note that an identifier may be an expression or a destructuring pattern.
public class JNodeIdentifier: JNode {
    let type = "Identifier"
    let name: String
    init(name: String) {
        self.name = name
    }
}

// A Private Name Identifier.
public class JNodePrivateName: JNode {
    let type = "PrivateName"
    let id: JNodeIdentifier
    init(id: JNodeIdentifier) {
        self.id = id
    }
}

public class JNodeRegExpLiteral: JNodeLiterals {
    let type = "RegExpLiteral"
    let pattern: String
    let flags: String
    init(pattern: String, flags: String) {
        self.pattern = pattern
        self.flags = flags
    }
}

public class JNodeNullLiteral: JNodeLiterals {
    let type = "NullLiteral"
}

public class JNodeStringLiteral: JNodeLiterals {
    var type = "StringLiteral"
    var value: String
    init(value: String) {
        self.value = value
    }
}

public class JNodeBooleanLiteral: JNodeLiterals {
    let type = "BooleanLiteral"
    let value: Bool
    init(value: Bool) {
        self.value = value
    }
}

public class JNodeNumericLiteral: JNodeLiterals {
    let type = "NumericLiteral"
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
    let type = "program"
    let sourceType: JNodeSourceType
    // body: [ Statement | ModuleDeclaration ];
    // TODO: 能够支持 ModuleDeclaration
    let body: [JNodeStatement]
    let directives: [JNodeDirective]
    init(sourceType: JNodeSourceType, body: [JNodeStatement], directives: [JNodeDirective]) {
        self.sourceType = sourceType
        self.body = body
        self.directives = directives
    }
}

// A function [declaration](#functiondeclaration) or [expression](#functionexpression).
public class JNodeFunction: JNodeFunctionP {
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
    let type = "ExpressionStatement"
    let expression: JNodeExpression
    init(expression: JNodeExpression) {
        self.expression = expression
    }
}

// A block statement, i.e., a sequence of statements surrounded by braces.
public class JNodeBlockStatement: JNodeStatement {
    let type = "BlockStatement"
    let body: [JNodeStatement]
    let directives: [JNodeDirective]
    init(body: [JNodeStatement], directives: [JNodeDirective]) {
        self.body = body
        self.directives = directives
    }
}

// An empty statement, i.e., a solitary semicolon.
public class JNodeEmptyStatement: JNodeStatement {
    let type = "EmptyStatement"
}

// A `debugger` statement.
public class JNodeDebuggerStatement: JNodeStatement {
    let type = "DebuggerStatement"
}

// A `with` statement.
public class JNodeWithStatement: JNodeStatement {
    let type = "WithStatement"
    let object: JNodeExpression
    let body: JNodeStatement
    init(object: JNodeExpression, body: JNodeStatement) {
        self.object = object
        self.body = body
    }
}

// Control flow

public class JNodeReturnStatement: JNodeStatement {
    let type = "ReturnStatement"
    let argument: JNodeExpression?
    init(argument: JNodeExpression?) {
        self.argument = argument
    }
}

// A labeled statement, i.e., a statement prefixed by a `break`/`continue` label.
public class JNodeLabeledStatement: JNodeStatement {
    let type = "LabeledStatement"
    let label: JNodeIdentifier
    let body: JNodeStatement
    init(label: JNodeIdentifier, body: JNodeStatement) {
        self.label = label
        self.body = body
    }
}

public class JNodeBreakStatement: JNodeStatement {
    let type = "BreakStatement"
    let label: JNodeIdentifier?
    init(label: JNodeIdentifier?) {
        self.label = label
    }
}

public class JNodeContinueStatement: JNodeStatement {
    let type = "ContinueStatement"
    let label: JNodeIdentifier?
    init(label: JNodeIdentifier?) {
        self.label = label
    }
}

// Choice

public class JNodeIfStatement: JNodeStatement {
    let type = "IfStatement"
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
    let type = "SwitchStatement"
    let discriminant: JNodeExpression
    let cases: [JNodeSwitchCase]
    init(discriminant: JNodeExpression, cases: [JNodeSwitchCase]) {
        self.discriminant = discriminant
        self.cases = cases
    }
}

// A `case` (if `test` is an `Expression`) or `default` (if `test === null`) clause in the body of a `switch` statement.
public class JNodeSwitchCase: JNode {
    let type = "SwitchCase"
    let test: JNodeExpression?
    let consequent: [JNodeStatement]
    init(test: JNodeExpression?, consequent: [JNodeStatement]) {
        self.test = test
        self.consequent = consequent
    }
}

// Exceptions

public class JNodeThrowStatement: JNodeStatement {
    let type = "ThrowStatement"
    let argument: JNodeExpression
    init(argument: JNodeExpression) {
        self.argument = argument
    }
}

// A `try` statement. If `handler` is `null` then `finalizer` must be a `BlockStatement`.
public class JNodeTryStatement: JNodeStatement {
    let type = "TryStatement"
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
    let type = "CatchClause"
    let param: JNodePattern?
    let body: JNodeBlockStatement
    init(param: JNodePattern?, body: JNodeBlockStatement) {
        self.param = param
        self.body = body
    }
}

// Loops

public class JNodeWhileStatement: JNodeStatement {
    let type = "WhileStatement"
    let test: JNodeExpression
    let body: JNodeStatement
    init(test: JNodeExpression, body: JNodeStatement) {
        self.test = test
        self.body = body
    }
}

// A `do`/`while` statement.
public class JNodeDoWhileStatement: JNodeStatement {
    let type = "DoWhileStatement"
    let body: JNodeStatement
    let test: JNodeExpression
    init(body: JNodeStatement, test: JNodeExpression) {
        self.body = body
        self.test = test
    }
}

public class JNodeForStatement: JNodeStatement {
    let type = "ForStatement"
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
    var type = "ForInStatement"
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
    let type = "FunctionDeclaration"
    init(identifier: JNodeIdentifier, params: [JNodePattern], body: JNodeBlockStatement, generator: Bool, async: Bool) {
        super.init(id: identifier, params: params, body: body, generator: generator, async: async)
        self.id = identifier
    }
}

public enum JNodeVariableDeclarationKind {
    case `var`, `let`, `const`
}
public class JNodeVariableDeclaration: JNodeDeclaration {
    let type = "VariableDeclaration"
    let declarations: [JNodeVariableDeclarator]
    let kind: JNodeVariableDeclarationKind
    init(declarations: [JNodeVariableDeclarator], kind: JNodeVariableDeclarationKind) {
        self.declarations = declarations
        self.kind = kind
    }
}

public class JNodeVariableDeclarator: JNode {
    let type = "VariableDeclarator"
    let id: JNodePattern
    let initialization: JNodeExpression?
    init(id: JNodePattern, initialization: JNodeExpression?) {
        self.id = id
        self.initialization = initialization
    }
}

// Misc

public class JNodeDecorator: JNode {
    let type = "Decorator"
    let expression: JNodeExpression
    init(expression: JNodeExpression) {
        self.expression = expression
    }
}

public class JNodeDirective: JNode {
    let type = "Directive"
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
    let type = "Super"
}

public class JNodeImport: JNode {
    let type = "Import"
}

public class JNodeThisExpression: JNodeExpression {
    let type = "ThisExpression"
}

// A fat arrow function expression, e.g., `let foo = (bar) => { /* body */ }`.
public class JNodeArrowFunctionExpression: JNodeFunction, JNodeExpression {
    override init(id: JNodeIdentifier, params: [JNodePattern], body: JNodeBlockStatement, generator: Bool, async: Bool) {
        super.init(id: id, params: params, body: body, generator: generator, async: async)
    }
}

public class JNodeYieldExpression: JNodeExpression {
    let type = "YieldExpression"
    let argument: JNodeExpression?
    let delegate: Bool
    init(argument: JNodeExpression?, delegate: Bool) {
        self.argument = argument
        self.delegate = delegate
    }
}

public class JNodeAwaitExpression: JNodeExpression {
    let type = "AwaitExpression"
    let argument: JNodeExpression?
    init(argument: JNodeExpression?) {
        self.argument = argument
    }
}

public class JNodeArrayExpression: JNodeExpression {
    let type = "ArrayExpression"
    // elements: [ Expression | SpreadElement | null ];
    // TODO: SpreadElement
    let elements: [JNode?]
    init(elements: [JNodeExpression?]) {
        self.elements = elements
    }
}

public class JNodeObjectExpression: JNodeExpression {
    let type = "ObjectExpression"
    // properties: [ ObjectProperty | ObjectMethod | SpreadElement ];
    let properties: [JNode]
    init(properties: [JNode]) {
        self.properties = properties
    }
}

public class JNodeObjectMember: JNodeObjectMemberP {
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
    let type = "ObjectProperty"
    let shorthand: Bool
    let value: JNodeExpression
    init(key: JNodeExpression, computed: Bool, decorators: JNodeDecorator, shorthand: Bool, value: JNodeExpression) {
        self.shorthand = shorthand
        self.value = value
        super.init(key: key, computed: computed, decorators: decorators)
    }
}

public class JNodeObjectMethod: JNodeObjectMemberP, JNodeFunctionP {
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
    let type = "FunctionExpression"
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
    let type = "UnaryExpression"
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
    let type = "UpdateExpression"
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
    let type = "BinaryExpression"
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
    let type = "AssignmentExpression"
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
    let type = "LogicalExpression"
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
    let type = "SpreadElement"
    let argument: JNodeExpression
    init(argument: JNodeExpression) {
        self.argument = argument
    }
}

// A member expression. If `computed` is `true`, the node corresponds to a computed (`a[b]`) member expression and `property` is an `Expression`. If `computed` is `false`, the node corresponds to a static (`a.b`) member expression and `property` is an `Identifier`. The `optional` flags indicates that the member expression can be called even if the object is null or undefined. If this is the object value (null/undefined) should be returned.
public class JNodeMemberExpression: JNodeExpression, JNodePattern {
    let type = "MemberExpression"
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
    let type = "BindExpression"
    let object: JNodeExpression?
    let callee: JNodeExpression
    init(object: JNodeExpression?, callee: JNodeExpression) {
        self.object = object
        self.callee = callee
    }
}

public class JNodeConditionalExpression: JNodeExpression {
    let type = "ConditionalExpression"
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
    var type = "CallExpression"
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
    let type = "SequenceExpression"
    let expressions: [JNodeExpression]
    init(expressions: [JNodeExpression]) {
        self.expressions = expressions
    }
}

public class JNodeDoExpression: JNodeExpression {
    let type = "DoExpression"
    let body: JNodeBlockStatement
    init(body: JNodeBlockStatement) {
        self.body = body
    }
}

// Template Literals
public class JNodeTemplateLiteral: JNodeExpression {
    let type = "TemplateLiteral"
    let quasis: [JNodeTemplateElement]
    let expressions: [JNodeExpression]
    init(quasis: [JNodeTemplateElement], expressions: [JNodeExpression]) {
        self.quasis = quasis
        self.expressions = expressions
    }
}

public class JNodeTaggedTemplateExpression: JNodeExpression {
    let type = "TaggedTemplateExpression"
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
    let type = "TemplateElement"
    let tail: Bool
    let value: ValueStruct
    init(tail: Bool, value: ValueStruct) {
        self.tail = tail
        self.value = value
    }
}



// ------------ 以前的 --------------
//// Base
//public enum JNodeType:String {
//    case None
//    case Root
//    case Identifier
//    case NumberLiteral
//    case CallExpression
//    case ExpressionStatement
//}
//public protocol JNodeBase {
//    var type: JNodeType {get}
//}
//// NumberLiteral
//public enum JNumberType:String {
//    case int,float
//}
//public protocol JNodeNumberLiteral {
//    var numberType: JNumberType {get}
//    var intValue: Int {get}
//    var floatValue: Float {get}
//}
//// CallExpression 测试用，未定结构
//public protocol JNodeCallExpression {
//    //TODO: 将 add subtract 做成枚举类型加到这里
//    var name: String {get}
//    var params: [JNode] {get}
//    
//    // other ast 用
//    //    var callee: JNodeCallee {get}
//    //    var arguments: [JNode] {get}
//}
//
//// ExpressionStatement
//public protocol JNodeExpressionStatement {
//    var expressions: [JNode] {get} //可以改成字典结构，比如 [String:JNode]，这里 String 为 expression，后面类似的处理调整下
//}
//// Struct
//public class JNode:JNodeBase,
//    JNodeNumberLiteral,
//    JNodeCallExpression,
//JNodeExpressionStatement {
//    public var type = JNodeType.None
//    // CallExpression
//    public var name = ""
//    public var params = [JNode]()
//    
//    // NumberLiteral
//    public var numberType = JNumberType.int
//    public var intValue:Int = 0
//    public var floatValue:Float = 0
//    // ExpressionStatement
//    public var expressions = [JNode]()
//    // Expression
//    public var callee = JNodeCallee()
//    public var arguments = [JNode]()
//}
//// Callee
//public class JNodeCallee:JNodeBase {
//    public var type = JNodeType.None
//    public var name = ""
//}

