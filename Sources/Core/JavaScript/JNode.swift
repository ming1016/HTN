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



