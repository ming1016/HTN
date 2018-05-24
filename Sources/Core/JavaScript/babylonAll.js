// @flow

import type { Options } from "./options";
import Parser, { plugins } from "./parser";

import { types as tokTypes } from "./tokenizer/types";
import "./tokenizer/context";

import type { Expression, File } from "./types";

import estreePlugin from "./plugins/estree";
import flowPlugin from "./plugins/flow";
import jsxPlugin from "./plugins/jsx";
import typescriptPlugin from "./plugins/typescript";
plugins.estree = estreePlugin;
plugins.flow = flowPlugin;
plugins.jsx = jsxPlugin;
plugins.typescript = typescriptPlugin;

export function parse(input: string, options?: Options): File {
  if (options && options.sourceType === "unambiguous") {
    options = {
      ...options,
    };
    try {
      options.sourceType = "module";
      const parser = getParser(options, input);
      const ast = parser.parse();

      // Rather than try to parse as a script first, we opt to parse as a module and convert back
      // to a script where possible to avoid having to do a full re-parse of the input content.
      if (!parser.sawUnambiguousESM) ast.program.sourceType = "script";
      return ast;
    } catch (moduleError) {
      try {
        options.sourceType = "script";
        return getParser(options, input).parse();
      } catch (scriptError) {}

      throw moduleError;
    }
  } else {
    return getParser(options, input).parse();
  }
}

export function parseExpression(input: string, options?: Options): Expression {
  const parser = getParser(options, input);
  if (parser.options.strictMode) {
    parser.state.strict = true;
  }
  return parser.getExpression();
}

export { tokTypes };

function getParser(options: ?Options, input: string): Parser {
  const cls =
    options && options.plugins ? getParserClass(options.plugins) : Parser;
  return new cls(options, input);
}

const parserClassCache: { [key: string]: Class<Parser> } = {};

/** Get a Parser class with plugins applied. */
function getParserClass(
  pluginsFromOptions: $ReadOnlyArray<string>,
): Class<Parser> {
  if (
    pluginsFromOptions.indexOf("decorators") >= 0 &&
    pluginsFromOptions.indexOf("decorators2") >= 0
  ) {
    throw new Error("Cannot use decorators and decorators2 plugin together");
  }

  // Filter out just the plugins that have an actual mixin associated with them.
  let pluginList = pluginsFromOptions.filter(
    p => p === "estree" || p === "flow" || p === "jsx" || p === "typescript",
  );

  if (pluginList.indexOf("flow") >= 0) {
    // ensure flow plugin loads last
    pluginList = pluginList.filter(plugin => plugin !== "flow");
    pluginList.push("flow");
  }

  if (
    pluginList.indexOf("flow") >= 0 &&
    pluginList.indexOf("typescript") >= 0
  ) {
    throw new Error("Cannot combine flow and typescript plugins.");
  }

  if (pluginList.indexOf("typescript") >= 0) {
    // ensure typescript plugin loads last
    pluginList = pluginList.filter(plugin => plugin !== "typescript");
    pluginList.push("typescript");
  }

  if (pluginList.indexOf("estree") >= 0) {
    // ensure estree plugin loads first
    pluginList = pluginList.filter(plugin => plugin !== "estree");
    pluginList.unshift("estree");
  }

  const key = pluginList.join("/");
  let cls = parserClassCache[key];
  if (!cls) {
    cls = Parser;
    for (const plugin of pluginList) {
      cls = plugins[plugin](cls);
    }
    parserClassCache[key] = cls;
  }
  return cls;
}

// @flow

// A second optional argument can be given to further configure
// the parser process. These options are recognized:

export type Options = {
  sourceType: "script" | "module",
  sourceFilename?: string,
  startLine: number,
  allowAwaitOutsideFunction: boolean,
  allowReturnOutsideFunction: boolean,
  allowImportExportEverywhere: boolean,
  allowSuperOutsideMethod: boolean,
  plugins: $ReadOnlyArray<string>,
  strictMode: ?boolean,
  ranges: boolean,
  tokens: boolean,
};

export const defaultOptions: Options = {
  // Source type ("script" or "module") for different semantics
  sourceType: "script",
  // Source filename.
  sourceFilename: undefined,
  // Line from which to start counting source. Useful for
  // integration with other tools.
  startLine: 1,
  // When enabled, await at the top level is not considered an
  // error.
  allowAwaitOutsideFunction: false,
  // When enabled, a return at the top level is not considered an
  // error.
  allowReturnOutsideFunction: false,
  // When enabled, import/export statements are not constrained to
  // appearing at the top of the program.
  allowImportExportEverywhere: false,
  // TODO
  allowSuperOutsideMethod: false,
  // An array of plugins to enable
  plugins: [],
  // TODO
  strictMode: null,
  // Nodes have their start and end characters offsets recorded in
  // `start` and `end` properties (directly on the node, rather than
  // the `loc` object, which holds line/column data. To also add a
  // [semi-standardized][range] `range` property holding a `[start,
  // end]` array with the same numbers, set the `ranges` option to
  // `true`.
  //
  // [range]: https://bugzilla.mozilla.org/show_bug.cgi?id=745678
  ranges: false,
  // Adds all parsed tokens to a `tokens` property on the `File` node
  tokens: false,
};

// Interpret and default an options object

export function getOptions(opts: ?Options): Options {
  const options: any = {};
  for (const key in defaultOptions) {
    options[key] = opts && opts[key] != null ? opts[key] : defaultOptions[key];
  }
  return options;
}

// @flow

import type { Token } from "./tokenizer";
import type { SourceLocation } from "./util/location";

/*
 * If making any changes to the AST, update:
 * - This repository:
 *   - This file
 *   - `ast` directory
 * - Babel repository:
 *   - packages/babel-types/src/definitions
 *   - packages/babel-generators/src/generators
 */

export type Comment = {
  type: "CommentBlock" | "CommentLine",
  value: string,
  start: number,
  end: number,
  loc: SourceLocation,
};

export interface NodeBase {
  start: number;
  end: number;
  loc: SourceLocation;
  range: [number, number];
  leadingComments?: Array<Comment>;
  trailingComments?: Array<Comment>;
  innerComments?: Array<Comment>;

  extra: { [key: string]: any };
}

// Using a union type for `Node` makes type-checking too slow.
// Instead, add an index signature to allow a Node to be treated as anything.
export type Node = NodeBase & { [key: string]: any };
export type Expression = Node;
export type Statement = Node;
export type Pattern =
  | Identifier
  | ObjectPattern
  | ArrayPattern
  | RestElement
  | AssignmentPattern;
export type Declaration =
  | VariableDeclaration
  | ClassDeclaration
  | FunctionDeclaration
  | TsInterfaceDeclaration
  | TsTypeAliasDeclaration
  | TsEnumDeclaration
  | TsModuleDeclaration;
export type DeclarationBase = NodeBase & {
  // TypeScript allows declarations to be prefixed by `declare`.
  //TODO: a FunctionDeclaration is never "declare", because it's a TSDeclareFunction instead.
  declare?: true,
};

// TODO: Not in spec
export type HasDecorators = NodeBase & {
  decorators?: $ReadOnlyArray<Decorator>,
};

export type Identifier = PatternBase & {
  type: "Identifier",
  name: string,

  __clone(): Identifier,

  // TypeScript only. Used in case of an optional parameter.
  optional?: ?true,
};

export type PrivateName = NodeBase & {
  type: "PrivateName",
  id: Identifier,
};

// Literals

export type Literal =
  | RegExpLiteral
  | NullLiteral
  | StringLiteral
  | BooleanLiteral
  | NumericLiteral;

export type RegExpLiteral = NodeBase & {
  type: "RegExpLiteral",
  pattern: string,
  flags: RegExp$flags,
};

export type NullLiteral = NodeBase & {
  type: "NullLiteral",
};

export type StringLiteral = NodeBase & {
  type: "StringLiteral",
  value: string,
};

export type BooleanLiteral = NodeBase & {
  type: "BooleanLiteral",
  value: boolean,
};

export type NumericLiteral = NodeBase & {
  type: "NumericLiteral",
  value: number,
};

export type BigIntLiteral = NodeBase & {
  type: "BigIntLiteral",
  value: number,
};

// Programs

export type BlockStatementLike = Program | BlockStatement;

export type File = NodeBase & {
  type: "File",
  program: Program,
  comments: $ReadOnlyArray<Comment>,
  tokens: $ReadOnlyArray<Token | Comment>,
};

export type Program = NodeBase & {
  type: "Program",
  sourceType: "script" | "module",
  body: Array<Statement | ModuleDeclaration>, // TODO: $ReadOnlyArray
  directives: $ReadOnlyArray<Directive>, // TODO: Not in spec
};

// Functions

export type Function =
  | NormalFunction
  | ArrowFunctionExpression
  | ObjectMethod
  | ClassMethod;

export type NormalFunction = FunctionDeclaration | FunctionExpression;

export type BodilessFunctionOrMethodBase = HasDecorators & {
  // TODO: Remove this. Should not assign "id" to methods.
  // https://github.com/babel/babylon/issues/535
  id: ?Identifier,

  params: $ReadOnlyArray<Pattern | TSParameterProperty>,
  body: BlockStatement,
  generator: boolean,
  async: boolean,

  // TODO: All not in spec
  expression: boolean,
  typeParameters?: ?TypeParameterDeclarationBase,
  returnType?: ?TypeAnnotationBase,
};

export type BodilessFunctionBase = BodilessFunctionOrMethodBase & {
  id: ?Identifier,
};

export type FunctionBase = BodilessFunctionBase & {
  body: BlockStatement,
};

// Statements

export type ExpressionStatement = NodeBase & {
  type: "ExpressionStatement",
  expression: Expression,
};

export type BlockStatement = NodeBase & {
  type: "BlockStatement",
  body: Array<Statement>, // TODO: $ReadOnlyArray
  directives: $ReadOnlyArray<Directive>,
};

export type EmptyStatement = NodeBase & {
  type: "EmptyStatement",
};

export type DebuggerStatement = NodeBase & {
  type: "DebuggerStatement",
};

export type WithStatement = NodeBase & {
  type: "WithStatement",
  object: Expression,
  body: Statement,
};

export type ReturnStatement = NodeBase & {
  type: "ReturnStatement",
  argument: ?Expression,
};

export type LabeledStatement = NodeBase & {
  type: "LabeledStatement",
  label: Identifier,
  body: Statement,
};

export type BreakStatement = NodeBase & {
  type: "BreakStatement",
  label: ?Identifier,
};

export type ContinueStatement = NodeBase & {
  type: "ContinueStatement",
  label: ?Identifier,
};

// Choice

export type IfStatement = NodeBase & {
  type: "IfStatement",
  test: Expression,
  consequent: Statement,
  alternate: ?Statement,
};

export type SwitchStatement = NodeBase & {
  type: "SwitchStatement",
  discriminant: Expression,
  cases: $ReadOnlyArray<SwitchCase>,
};

export type SwitchCase = NodeBase & {
  type: "SwitchCase",
  test: ?Expression,
  consequent: $ReadOnlyArray<Statement>,
};

// Exceptions

export type ThrowStatement = NodeBase & {
  type: "ThrowStatement",
  argument: Expression,
};

export type TryStatement = NodeBase & {
  type: "TryStatement",
  block: BlockStatement,
  handler: CatchClause | null,
  finalizer: BlockStatement | null,

  guardedHandlers: $ReadOnlyArray<empty>, // TODO: Not in spec
};

export type CatchClause = NodeBase & {
  type: "CatchClause",
  param: Pattern,
  body: BlockStatement,
};

// Loops

export type WhileStatement = NodeBase & {
  type: "WhileStatement",
  test: Expression,
  body: Statement,
};

export type DoWhileStatement = NodeBase & {
  type: "DoWhileStatement",
  body: Statement,
  test: Expression,
};

export type ForLike = ForStatement | ForInOf;

export type ForStatement = NodeBase & {
  type: "ForStatement",
  init: ?(VariableDeclaration | Expression),
  test: ?Expression,
  update: ?Expression,
  body: Statement,
};

export type ForInOf = ForInStatement | ForOfStatement;

export type ForInOfBase = NodeBase & {
  type: "ForInStatement",
  left: VariableDeclaration | Expression,
  right: Expression,
  body: Statement,
};

export type ForInStatement = ForInOfBase & {
  type: "ForInStatement",
  // TODO: Shouldn't be here, but have to declare it because it's assigned to a ForInOf unconditionally.
  await: boolean,
};

export type ForOfStatement = ForInOfBase & {
  type: "ForOfStatement",
  await: boolean,
};

// Declarations

export type OptFunctionDeclaration = FunctionBase &
  DeclarationBase & {
    type: "FunctionDeclaration",
  };

export type FunctionDeclaration = OptFunctionDeclaration & {
  id: Identifier,
};

export type VariableDeclaration = DeclarationBase &
  HasDecorators & {
    type: "VariableDeclaration",
    declarations: $ReadOnlyArray<VariableDeclarator>,
    kind: "var" | "let" | "const",
  };

export type VariableDeclarator = NodeBase & {
  type: "VariableDeclarator",
  id: Pattern,
  init: ?Expression,

  // TypeScript only:
  definite?: true,
};

// Misc

export type Decorator = NodeBase & {
  type: "Decorator",
  expression: Expression,
  arguments?: Array<Expression | SpreadElement>,
};

export type Directive = NodeBase & {
  type: "Directive",
  value: DirectiveLiteral,
};

export type DirectiveLiteral = StringLiteral & { type: "DirectiveLiteral" };

// Expressions

export type Super = NodeBase & { type: "Super" };

export type Import = NodeBase & { type: "Import" };

export type ThisExpression = NodeBase & { type: "ThisExpression" };

export type ArrowFunctionExpression = FunctionBase & {
  type: "ArrowFunctionExpression",
  body: BlockStatement | Expression,
};

export type YieldExpression = NodeBase & {
  type: "YieldExpression",
  argument: ?Expression,
  delegate: boolean,
};

export type AwaitExpression = NodeBase & {
  type: "AwaitExpression",
  argument: ?Expression,
};

export type ArrayExpression = NodeBase & {
  type: "ArrayExpression",
  elements: $ReadOnlyArray<?(Expression | SpreadElement)>,
};

export type ObjectExpression = NodeBase & {
  type: "ObjectExpression",
  properties: $ReadOnlyArray<ObjectProperty | ObjectMethod | SpreadElement>,
};

export type ObjectOrClassMember = ClassMethod | ClassProperty | ObjectMember;

export type ObjectMember = ObjectProperty | ObjectMethod;

export type ObjectMemberBase = NodeBase & {
  key: Expression,
  computed: boolean,
  value: Expression,
  decorators: $ReadOnlyArray<Decorator>,
  kind?: "get" | "set" | "method",
  method: boolean, // TODO: Not in spec

  variance?: ?FlowVariance, // TODO: Not in spec
};

export type ObjectProperty = ObjectMemberBase & {
  type: "ObjectProperty",
  shorthand: boolean,
};

export type ObjectMethod = ObjectMemberBase &
  MethodBase & {
    type: "ObjectMethod",
    kind: "get" | "set" | "method", // Never "constructor"
  };

export type FunctionExpression = MethodBase & {
  kind?: void, // never set
  type: "FunctionExpression",
};

// Unary operations

export type UnaryExpression = NodeBase & {
  type: "UnaryExpression",
  operator: UnaryOperator,
  prefix: boolean,
  argument: Expression,
};

export type UnaryOperator =
  | "-"
  | "+"
  | "!"
  | "~"
  | "typeof"
  | "void"
  | "delete"
  | "throw";

export type UpdateExpression = NodeBase & {
  type: "UpdateExpression",
  operator: UpdateOperator,
  argument: Expression,
  prefix: boolean,
};

export type UpdateOperator = "++" | "--";

// Binary operations

export type BinaryExpression = NodeBase & {
  type: "BinaryExpression",
  operator: BinaryOperator,
  left: Expression,
  right: Expression,
};

export type BinaryOperator =
  | "=="
  | "!="
  | "==="
  | "!=="
  | "<"
  | "<="
  | ">"
  | ">="
  | "<<"
  | ">>"
  | ">>>"
  | "+"
  | "-"
  | "*"
  | "/"
  | "%"
  | "|"
  | "^"
  | "&"
  | "in"
  | "instanceof";

export type AssignmentExpression = NodeBase & {
  type: "AssignmentExpression",
  operator: AssignmentOperator,
  left: Pattern | Expression,
  right: Expression,
};

export type AssignmentOperator =
  | "="
  | "+="
  | "-="
  | "*="
  | "/="
  | "%="
  | "<<="
  | ">>="
  | ">>>="
  | "|="
  | "^="
  | "&=";

export type LogicalExpression = NodeBase & {
  type: "LogicalExpression",
  operator: LogicalOperator,
  left: Expression,
  right: Expression,
};

export type LogicalOperator = "||" | "&&";

export type SpreadElement = NodeBase & {
  type: "SpreadElement",
  argument: Expression,
};

export type MemberExpression = NodeBase & {
  type: "MemberExpression",
  object: Expression | Super,
  property: Expression,
  computed: boolean,
};

export type OptionalMemberExpression = NodeBase & {
  type: "OptionalMemberExpression",
  object: Expression | Super,
  property: Expression,
  computed: boolean,
  optional: boolean,
};

export type OptionalCallExpression = CallOrNewBase & {
  type: "OptionalCallExpression",
  optional: boolean,
};
export type BindExpression = NodeBase & {
  type: "BindExpression",
  object: $ReadOnlyArray<?Expression>,
  callee: $ReadOnlyArray<Expression>,
};

export type ConditionalExpression = NodeBase & {
  type: "ConditionalExpression",
  test: Expression,
  alternate: Expression,
  consequent: Expression,
};

export type CallOrNewBase = NodeBase & {
  callee: Expression | Super | Import,
  arguments: Array<Expression | SpreadElement>, // TODO: $ReadOnlyArray
  typeParameters?: ?TypeParameterInstantiationBase, // TODO: Not in spec
};

export type CallExpression = CallOrNewBase & {
  type: "CallExpression",
};

export type NewExpression = CallOrNewBase & {
  type: "NewExpression",
  optional?: boolean, // TODO: Not in spec
};

export type SequenceExpression = NodeBase & {
  type: "SequenceExpression",
  expressions: $ReadOnlyArray<Expression>,
};

// Template Literals

export type TemplateLiteral = NodeBase & {
  type: "TemplateLiteral",
  quasis: $ReadOnlyArray<TemplateElement>,
  expressions: $ReadOnlyArray<Expression>,
};

export type TaggedTmplateExpression = NodeBase & {
  type: "TaggedTemplateExpression",
  tag: Expression,
  quasi: TemplateLiteral,
};

export type TemplateElement = NodeBase & {
  type: "TemplateElement",
  tail: boolean,
  value: {
    cooked: string,
    raw: string,
  },
};

// Patterns

// TypeScript access modifiers
export type Accessibility = "public" | "protected" | "private";

export type PatternBase = HasDecorators & {
  // TODO: All not in spec
  // Flow/TypeScript only:
  typeAnnotation?: ?TypeAnnotationBase,
};

export type AssignmentProperty = ObjectProperty & {
  value: Pattern,
};

export type ObjectPattern = PatternBase & {
  type: "ObjectPattern",
  properties: $ReadOnlyArray<AssignmentProperty | RestElement>,
};

export type ArrayPattern = PatternBase & {
  type: "ArrayPattern",
  elements: $ReadOnlyArray<?Pattern>,
};

export type RestElement = PatternBase & {
  type: "RestElement",
  argument: Pattern,
};

export type AssignmentPattern = PatternBase & {
  type: "AssignmentPattern",
  left: Pattern,
  right: Expression,
};

// Classes

export type Class = ClassDeclaration | ClassExpression;

export type ClassBase = HasDecorators & {
  id: ?Identifier,
  superClass: ?Expression,
  body: ClassBody,
  decorators: $ReadOnlyArray<Decorator>,

  // TODO: All not in spec
  typeParameters?: ?TypeParameterDeclarationBase,
  superTypeParameters?: ?TypeParameterInstantiationBase,
  implements?:
    | ?$ReadOnlyArray<TsExpressionWithTypeArguments>
    | $ReadOnlyArray<FlowClassImplements>,
};

export type ClassBody = NodeBase & {
  type: "ClassBody",
  body: Array<ClassMember | TsIndexSignature>, // TODO: $ReadOnlyArray
};

export type ClassMemberBase = NodeBase &
  HasDecorators & {
    static: boolean,
    computed: boolean,
    // TypeScript only:
    accessibility?: ?Accessibility,
    abstract?: ?true,
    optional?: ?true,
  };

export type ClassMember =
  | ClassMethod
  | ClassPrivateMethod
  | ClassProperty
  | ClassPrivateProperty;

export type MethodLike =
  | ObjectMethod
  | FunctionExpression
  | ClassMethod
  | ClassPrivateMethod
  | TSDeclareMethod;

export type MethodBase = FunctionBase & {
  +kind: MethodKind,
};

export type MethodKind = "constructor" | "method" | "get" | "set";

export type ClassMethodOrDeclareMethodCommon = ClassMemberBase & {
  key: Expression,
  kind: MethodKind,
  static: boolean,
  decorators: $ReadOnlyArray<Decorator>,
};

export type ClassMethod = MethodBase &
  ClassMethodOrDeclareMethodCommon & {
    type: "ClassMethod",
    variance?: ?FlowVariance, // TODO: Not in spec
  };

export type ClassPrivateMethod = NodeBase &
  ClassMethodOrDeclareMethodCommon &
  MethodBase & {
    type: "ClassPrivateMethod",
    key: PrivateName,
    computed: false,
  };

export type ClassProperty = ClassMemberBase & {
  type: "ClassProperty",
  key: Expression,
  value: ?Expression, // TODO: Not in spec that this is nullable.

  typeAnnotation?: ?TypeAnnotationBase, // TODO: Not in spec
  variance?: ?FlowVariance, // TODO: Not in spec

  // TypeScript only: (TODO: Not in spec)
  readonly?: true,
  definite?: true,
};

export type ClassPrivateProperty = NodeBase & {
  type: "ClassPrivateProperty",
  key: PrivateName,
  value: ?Expression, // TODO: Not in spec that this is nullable.
  static: boolean,
  computed: false,
};

export type OptClassDeclaration = ClassBase &
  DeclarationBase &
  HasDecorators & {
    type: "ClassDeclaration",
    // TypeScript only
    abstract?: ?true,
  };

export type ClassDeclaration = OptClassDeclaration & {
  id: Identifier,
};

export type ClassExpression = ClassBase & { type: "ClassExpression" };

export type MetaProperty = NodeBase & {
  type: "MetaProperty",
  meta: Identifier,
  property: Identifier,
};

// Modules

export type ModuleDeclaration = AnyImport | AnyExport;

export type AnyImport = ImportDeclaration | TsImportEqualsDeclaration;

export type AnyExport =
  | ExportNamedDeclaration
  | ExportDefaultDeclaration
  | ExportAllDeclaration
  | TsExportAssignment;

export type ModuleSpecifier = NodeBase & {
  local: Identifier,
};

// Imports

export type ImportDeclaration = NodeBase & {
  type: "ImportDeclaration",
  // TODO: $ReadOnlyArray
  specifiers: Array<
    ImportSpecifier | ImportDefaultSpecifier | ImportNamespaceSpecifier,
  >,
  source: Literal,

  importKind?: "type" | "typeof" | "value", // TODO: Not in spec
};

export type ImportSpecifier = ModuleSpecifier & {
  type: "ImportSpecifier",
  imported: Identifier,
};

export type ImportDefaultSpecifier = ModuleSpecifier & {
  type: "ImportDefaultSpecifier",
};

export type ImportNamespaceSpecifier = ModuleSpecifier & {
  type: "ImportNamespaceSpecifier",
};

// Exports

export type ExportNamedDeclaration = NodeBase & {
  type: "ExportNamedDeclaration",
  declaration: ?Declaration,
  specifiers: $ReadOnlyArray<ExportSpecifier>,
  source: ?Literal,

  exportKind?: "type" | "value", // TODO: Not in spec
};

export type ExportSpecifier = NodeBase & {
  type: "ExportSpecifier",
  exported: Identifier,
};

export type ExportDefaultDeclaration = NodeBase & {
  type: "ExportDefaultDeclaration",
  declaration:
    | OptFunctionDeclaration
    | OptTSDeclareFunction
    | OptClassDeclaration
    | Expression,
};

export type ExportAllDeclaration = NodeBase & {
  type: "ExportAllDeclaration",
  source: Literal,
  exportKind?: "type" | "value", // TODO: Not in spec
};

// JSX (TODO: Not in spec)

export type JSXIdentifier = Node;
export type JSXNamespacedName = Node;
export type JSXMemberExpression = Node;
export type JSXEmptyExpression = Node;
export type JSXSpreadChild = Node;
export type JSXExpressionContainer = Node;
export type JSXAttribute = Node;
export type JSXOpeningElement = Node;
export type JSXClosingElement = Node;
export type JSXElement = Node;
export type JSXOpeningFragment = Node;
export type JSXClosingFragment = Node;
export type JSXFragment = Node;

// Flow/TypeScript common (TODO: Not in spec)

export type TypeAnnotationBase = NodeBase & {
  typeAnnotation: Node,
};

export type TypeAnnotation = NodeBase & {
  type: "TypeAnnotation",
  typeAnnotation: FlowTypeAnnotation,
};

export type TsTypeAnnotation = NodeBase & {
  type: "TSTypeAnnotation",
  typeAnnotation: TsType,
};

export type TypeParameterDeclarationBase = NodeBase & {
  params: $ReadOnlyArray<TypeParameterBase>,
};

export type TypeParameterDeclaration = TypeParameterDeclarationBase & {
  type: "TypeParameterDeclaration",
  params: $ReadOnlyArray<TypeParameter>,
};

export type TsTypeParameterDeclaration = TypeParameterDeclarationBase & {
  type: "TsTypeParameterDeclaration",
  params: $ReadOnlyArray<TsTypeParameter>,
};

export type TypeParameterBase = NodeBase & {
  name: string,
};

export type TypeParameter = TypeParameterBase & {
  type: "TypeParameter",
};

export type TsTypeParameter = TypeParameterBase & {
  type: "TSTypeParameter",
  constraint?: TsType,
  default?: TsType,
};

export type TypeParameterInstantiationBase = NodeBase & {
  params: $ReadOnlyArray<Node>,
};

export type TypeParameterInstantiation = TypeParameterInstantiationBase & {
  type: "TypeParameterInstantiation",
  params: $ReadOnlyArray<FlowType>,
};

export type TsTypeParameterInstantiation = TypeParameterInstantiationBase & {
  type: "TSTypeParameterInstantiation",
  params: $ReadOnlyArray<TsType>,
};

// Flow (TODO: Not in spec)

export type TypeCastExpressionBase = NodeBase & {
  expression: Expression,
  typeAnnotation: TypeAnnotationBase,
};

export type TypeCastExpression = NodeBase & {
  type: "TypeCastExpression",
  expression: Expression,
  typeAnnotation: TypeAnnotation,
};

export type TsTypeCastExpression = NodeBase & {
  type: "TSTypeCastExpression",
  expression: Expression,
  typeAnnotation: TsTypeAnnotation,
};

export type FlowType = Node;
export type FlowPredicate = Node;
export type FlowDeclare = Node;
export type FlowDeclareClass = Node;
export type FlowDeclareExportDeclaration = Node;
export type FlowDeclareFunction = Node;
export type FlowDeclareVariable = Node;
export type FlowDeclareModule = Node;
export type FlowDeclareModuleExports = Node;
export type FlowDeclareTypeAlias = Node;
export type FlowDeclareOpaqueType = Node;
export type FlowDeclareInterface = Node;
export type FlowInterface = Node;
export type FlowInterfaceExtends = Node;
export type FlowTypeAlias = Node;
export type FlowOpaqueType = Node;
export type FlowObjectTypeIndexer = Node;
export type FlowFunctionTypeAnnotation = Node;
export type FlowObjectTypeProperty = Node;
export type FlowObjectTypeSpreadProperty = Node;
export type FlowObjectTypeCallProperty = Node;
export type FlowObjectTypeAnnotation = Node;
export type FlowQualifiedTypeIdentifier = Node;
export type FlowGenericTypeAnnotation = Node;
export type FlowTypeofTypeAnnotation = Node;
export type FlowTupleTypeAnnotation = Node;
export type FlowFunctionTypeParam = Node;
export type FlowTypeAnnotation = Node;
export type FlowVariance = Node;
export type FlowClassImplements = Node;

// estree

export type EstreeProperty = NodeBase & {
  type: "Property",
  shorthand: boolean,
  key: Expression,
  computed: boolean,
  value: Expression,
  decorators: $ReadOnlyArray<Decorator>,
  kind?: "get" | "set" | "init",

  variance?: ?FlowVariance,
};

export type EstreeMethodDefinition = NodeBase & {
  type: "MethodDefinition",
  static: boolean,
  key: Expression,
  computed: boolean,
  value: Expression,
  decorators: $ReadOnlyArray<Decorator>,
  kind?: "get" | "set" | "method",

  variance?: ?FlowVariance,
};

// === === === ===
// TypeScript
// === === === ===

// Note: A type named `TsFoo` is based on TypeScript's `FooNode` type,
// defined in https://github.com/Microsoft/TypeScript/blob/master/src/compiler/types.ts
// Differences:
// * Change `NodeArray<T>` to just `$ReadOnlyArray<T>`.
// * Don't give nodes a "modifiers" list; use boolean flags instead,
//   and only allow modifiers that are not considered errors.
// * A property named `type` must be renamed to `typeAnnotation` to avoid conflict with the node's type.
// * Sometimes TypeScript allows to parse something which will be a grammar error later;
//   in babylon these cause exceptions, so the AST format is stricter.

// ================
// Misc
// ================

export type TSParameterProperty = HasDecorators & {
  // Note: This has decorators instead of its parameter.
  type: "TSParameterProperty",
  // At least one of `accessibility` or `readonly` must be set.
  accessibility?: ?Accessibility,
  readonly?: ?true,
  parameter: Identifier | AssignmentPattern,
};

export type OptTSDeclareFunction = BodilessFunctionBase &
  DeclarationBase & {
    type: "TSDeclareFunction",
  };

export type TSDeclareFunction = OptTSDeclareFunction & {
  id: Identifier,
};

export type TSDeclareMethod = BodilessFunctionOrMethodBase &
  ClassMethodOrDeclareMethodCommon & {
    type: "TSDeclareMethod",
    +kind: MethodKind,
  };

export type TsQualifiedName = NodeBase & {
  type: "TSQualifiedName",
  left: TsEntityName,
  right: Identifier,
};

export type TsEntityName = Identifier | TsQualifiedName;

export type TsSignatureDeclaration =
  | TsCallSignatureDeclaration
  | TsConstructSignatureDeclaration
  | TsMethodSignature
  | TsFunctionType
  | TsConstructorType;

export type TsSignatureDeclarationOrIndexSignatureBase = NodeBase & {
  // Not using TypeScript's "ParameterDeclaration" here, since it's inconsistent with regular functions.
  parameters: $ReadOnlyArray<Identifier | RestElement>,
  typeAnnotation: ?TsTypeAnnotation,
};

export type TsSignatureDeclarationBase = TsSignatureDeclarationOrIndexSignatureBase & {
  typeParameters: ?TsTypeParameterDeclaration,
};

// ================
// TypeScript type members (for type literal / interface / class)
// ================

export type TsTypeElement =
  | TsCallSignatureDeclaration
  | TsConstructSignatureDeclaration
  | TsPropertySignature
  | TsMethodSignature
  | TsIndexSignature;

export type TsCallSignatureDeclaration = TsSignatureDeclarationBase & {
  type: "TSCallSignatureDeclaration",
};

export type TsConstructSignatureDeclaration = TsSignatureDeclarationBase & {
  type: "TSConstructSignature",
};

export type TsNamedTypeElementBase = NodeBase & {
  // Not using TypeScript's `PropertyName` here since we don't have a `ComputedPropertyName` node type.
  // This is usually an Identifier but may be e.g. `Symbol.iterator` if `computed` is true.
  key: Expression,
  computed: boolean,
  optional?: true,
};

export type TsPropertySignature = TsNamedTypeElementBase & {
  type: "TSPropertySignature",
  readonly?: true,
  typeAnnotation?: TsTypeAnnotation,
  initializer?: Expression,
};

export type TsMethodSignature = TsSignatureDeclarationBase &
  TsNamedTypeElementBase & {
    type: "TSMethodSignature",
  };

// *Not* a ClassMemberBase: Can't have accessibility, can't be abstract, can't be optional.
export type TsIndexSignature = TsSignatureDeclarationOrIndexSignatureBase & {
  readonly?: true,
  type: "TSIndexSignature",
  // Note: parameters.length must be 1.
};

// ================
// TypeScript types
// ================

export type TsType =
  | TsKeywordType
  | TsThisType
  | TsFunctionOrConstructorType
  | TsTypeReference
  | TsTypeQuery
  | TsTypeLiteral
  | TsArrayType
  | TsTupleType
  | TsUnionOrIntersectionType
  | TsConditionalType
  | TsInferType
  | TsParenthesizedType
  | TsTypeOperator
  | TsIndexedAccessType
  | TsMappedType
  | TsLiteralType
  // TODO: This probably shouldn't be included here.
  | TsTypePredicate;

export type TsTypeBase = NodeBase;

export type TsKeywordTypeType =
  | "TSAnyKeyword"
  | "TSNumberKeyword"
  | "TSObjectKeyword"
  | "TSBooleanKeyword"
  | "TSStringKeyword"
  | "TSSymbolKeyword"
  | "TSVoidKeyword"
  | "TSUndefinedKeyword"
  | "TSNullKeyword"
  | "TSNeverKeyword";
export type TsKeywordType = TsTypeBase & {
  type: TsKeywordTypeType,
};

export type TsThisType = TsTypeBase & {
  type: "TSThisType",
};

export type TsFunctionOrConstructorType = TsFunctionType | TsConstructorType;

export type TsFunctionType = TsTypeBase &
  TsSignatureDeclarationBase & {
    type: "TSFunctionType",
    typeAnnotation: TypeAnnotation, // not optional
  };

export type TsConstructorType = TsTypeBase &
  TsSignatureDeclarationBase & {
    type: "TSConstructorType",
    typeAnnotation: TsTypeAnnotation,
  };

export type TsTypeReference = TsTypeBase & {
  type: "TSTypeReference",
  typeName: TsEntityName,
  typeParameters?: TsTypeParameterInstantiation,
};

export type TsTypePredicate = TsTypeBase & {
  type: "TSTypePredicate",
  parameterName: Identifier | TsThisType,
  typeAnnotation: TsTypeAnnotation,
};

// `typeof` operator
export type TsTypeQuery = TsTypeBase & {
  type: "TSTypeQuery",
  exprName: TsEntityName,
};

export type TsTypeLiteral = TsTypeBase & {
  type: "TSTypeLiteral",
  members: $ReadOnlyArray<TsTypeElement>,
};

export type TsArrayType = TsTypeBase & {
  type: "TSArrayType",
  elementType: TsType,
};

export type TsTupleType = TsTypeBase & {
  type: "TSTupleType",
  elementTypes: $ReadOnlyArray<TsType>,
};

export type TsUnionOrIntersectionType = TsUnionType | TsIntersectionType;

export type TsUnionOrIntersectionTypeBase = TsTypeBase & {
  types: $ReadOnlyArray<TsType>,
};

export type TsUnionType = TsUnionOrIntersectionTypeBase & {
  type: "TSUnionType",
};

export type TsIntersectionType = TsUnionOrIntersectionTypeBase & {
  type: "TSIntersectionType",
};

export type TsConditionalType = TsTypeBase & {
  type: "TSConditionalType",
  checkType: TsType,
  extendsType: TsType,
  trueType: TsType,
  falseType: TsType,
};

export type TsInferType = TsTypeBase & {
  type: "TSInferType",
  typeParameter: TypeParameter,
};

export type TsParenthesizedType = TsTypeBase & {
  type: "TSParenthesizedType",
  typeAnnotation: TsType,
};

export type TsTypeOperator = TsTypeBase & {
  type: "TSTypeOperator",
  operator: "keyof" | "unique",
  typeAnnotation: TsType,
};

export type TsIndexedAccessType = TsTypeBase & {
  type: "TSIndexedAccessType",
  objectType: TsType,
  indexType: TsType,
};

export type TsMappedType = TsTypeBase & {
  type: "TSMappedType",
  readonly?: true | "+" | "-",
  typeParameter: TsTypeParameter,
  optional?: true | "+" | "-",
  typeAnnotation: ?TsType,
};

export type TsLiteralType = TsTypeBase & {
  type: "TSLiteralType",
  literal: NumericLiteral | StringLiteral | BooleanLiteral,
};

// ================
// TypeScript declarations
// ================

export type TsInterfaceDeclaration = DeclarationBase & {
  type: "TSInterfaceDeclaration",
  id: Identifier,
  typeParameters: ?TsTypeParameterDeclaration,
  // TS uses "heritageClauses", but want this to resemble ClassBase.
  extends?: $ReadOnlyArray<TsExpressionWithTypeArguments>,
  body: TSInterfaceBody,
};

export type TSInterfaceBody = NodeBase & {
  type: "TSInterfaceBody",
  body: $ReadOnlyArray<TsTypeElement>,
};

export type TsExpressionWithTypeArguments = TsTypeBase & {
  type: "TSExpressionWithTypeArguments",
  expression: TsEntityName,
  typeParameters?: TsTypeParameterInstantiation,
};

export type TsTypeAliasDeclaration = DeclarationBase & {
  type: "TSTypeAliasDeclaration",
  id: Identifier,
  typeParameters: ?TsTypeParameterDeclaration,
  typeAnnotation: TsType,
};

export type TsEnumDeclaration = DeclarationBase & {
  type: "TSEnumDeclaration",
  const?: true,
  id: Identifier,
  members: $ReadOnlyArray<TsEnumMember>,
};

export type TsEnumMember = NodeBase & {
  type: "TSEnumMemodulmber",
  id: Identifier | StringLiteral,
  initializer?: Expression,
};

export type TsModuleDeclaration = DeclarationBase & {
  type: "TSModuleDeclaration",
  global?: true, // In TypeScript, this is only available through `node.flags`.
  id: TsModuleName,
  body: TsNamespaceBody,
};

// `namespace A.B { }` is a namespace named `A` with another TsNamespaceDeclaration as its body.
export type TsNamespaceBody = TsModuleBlock | TsNamespaceDeclaration;

export type TsModuleBlock = NodeBase & {
  type: "TSModuleBlock",
  body: $ReadOnlyArray<Statement>,
};

export type TsNamespaceDeclaration = TsModuleDeclaration & {
  id: Identifier,
  body: TsNamespaceBody,
};

export type TsModuleName = Identifier | StringLiteral;

export type TsImportEqualsDeclaration = NodeBase & {
  type: "TSImportEqualsDeclaration",
  isExport: boolean,
  id: Identifier,
  moduleReference: TsModuleReference,
};

export type TsModuleReference = TsEntityName | TsExternalModuleReference;

export type TsExternalModuleReference = NodeBase & {
  type: "TSExternalModuleReference",
  expression: StringLiteral,
};

// TypeScript's own parser uses ExportAssignment for both `export default` and `export =`.
// But for babylon, `export default` is an ExportDefaultDeclaration,
// so a TsExportAssignment is always `export =`.
export type TsExportAssignment = NodeBase & {
  type: "TSExportAssignment",
  expression: Expression,
};

export type TsNamespaceExportDeclaration = NodeBase & {
  type: "TSNamespaceExportDeclaration",
  id: Identifier,
};

// ================
// TypeScript expressions
// ================

export type TsTypeAssertionLikeBase = NodeBase & {
  expression: Expression,
  typeAnnotation: TsType,
};

export type TsAsExpression = TsTypeAssertionLikeBase & {
  type: "TSAsExpression",
};

export type TsTypeAssertion = TsTypeAssertionLikeBase & {
  type: "TSTypeAssertion",
};

export type TsNonNullExpression = NodeBase & {
  type: "TSNonNullExpression",
  expression: Expression,
};

// ================
// Other
// ================

export type ParseSubscriptState = {
  optionalChainMember: boolean,
  stop: boolean,
};

// @flow

import type { Options } from "../options";
import { reservedWords } from "../util/identifier";

import type State from "../tokenizer/state";

export default class BaseParser {
  // Properties set by constructor in index.js
  options: Options;
  inModule: boolean;
  plugins: { [key: string]: boolean };
  filename: ?string;
  sawUnambiguousESM: boolean = false;

  // Initialized by Tokenizer
  state: State;
  input: string;

  isReservedWord(word: string): boolean {
    if (word === "await") {
      return this.inModule;
    } else {
      return reservedWords[6](word);
    }
  }

  hasPlugin(name: string): boolean {
    return !!this.plugins[name];
  }
}

// @flow

/**
 * Based on the comment attachment algorithm used in espree and estraverse.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import BaseParser from "./base";
import type { Comment, Node } from "../types";

function last<T>(stack: $ReadOnlyArray<T>): T {
  return stack[stack.length - 1];
}

export default class CommentsParser extends BaseParser {
  addComment(comment: Comment): void {
    if (this.filename) comment.loc.filename = this.filename;
    this.state.trailingComments.push(comment);
    this.state.leadingComments.push(comment);
  }

  processComment(node: Node): void {
    if (node.type === "Program" && node.body.length > 0) return;

    const stack = this.state.commentStack;

    let firstChild, lastChild, trailingComments, i, j;

    if (this.state.trailingComments.length > 0) {
      // If the first comment in trailingComments comes after the
      // current node, then we're good - all comments in the array will
      // come after the node and so it's safe to add them as official
      // trailingComments.
      if (this.state.trailingComments[0].start >= node.end) {
        trailingComments = this.state.trailingComments;
        this.state.trailingComments = [];
      } else {
        // Otherwise, if the first comment doesn't come after the
        // current node, that means we have a mix of leading and trailing
        // comments in the array and that leadingComments contains the
        // same items as trailingComments. Reset trailingComments to
        // zero items and we'll handle this by evaluating leadingComments
        // later.
        this.state.trailingComments.length = 0;
      }
    } else if (stack.length > 0) {
      const lastInStack = last(stack);
      if (
        lastInStack.trailingComments &&
        lastInStack.trailingComments[0].start >= node.end
      ) {
        trailingComments = lastInStack.trailingComments;
        delete lastInStack.trailingComments;
      }
    }

    // Eating the stack.
    if (stack.length > 0 && last(stack).start >= node.start) {
      firstChild = stack.pop();
    }

    while (stack.length > 0 && last(stack).start >= node.start) {
      lastChild = stack.pop();
    }

    if (!lastChild && firstChild) lastChild = firstChild;

    // Attach comments that follow a trailing comma on the last
    // property in an object literal or a trailing comma in function arguments
    // as trailing comments
    if (firstChild && this.state.leadingComments.length > 0) {
      const lastComment = last(this.state.leadingComments);

      if (firstChild.type === "ObjectProperty") {
        if (lastComment.start >= node.start) {
          if (this.state.commentPreviousNode) {
            for (j = 0; j < this.state.leadingComments.length; j++) {
              if (
                this.state.leadingComments[j].end <
                this.state.commentPreviousNode.end
              ) {
                this.state.leadingComments.splice(j, 1);
                j--;
              }
            }

            if (this.state.leadingComments.length > 0) {
              firstChild.trailingComments = this.state.leadingComments;
              this.state.leadingComments = [];
            }
          }
        }
      } else if (
        node.type === "CallExpression" &&
        node.arguments &&
        node.arguments.length
      ) {
        const lastArg = last(node.arguments);

        if (
          lastArg &&
          lastComment.start >= lastArg.start &&
          lastComment.end <= node.end
        ) {
          if (this.state.commentPreviousNode) {
            if (this.state.leadingComments.length > 0) {
              lastArg.trailingComments = this.state.leadingComments;
              this.state.leadingComments = [];
            }
          }
        }
      }
    }

    if (lastChild) {
      if (lastChild.leadingComments) {
        if (
          lastChild !== node &&
          lastChild.leadingComments.length > 0 &&
          last(lastChild.leadingComments).end <= node.start
        ) {
          node.leadingComments = lastChild.leadingComments;
          delete lastChild.leadingComments;
        } else {
          // A leading comment for an anonymous class had been stolen by its first ClassMethod,
          // so this takes back the leading comment.
          // See also: https://github.com/eslint/espree/issues/158
          for (i = lastChild.leadingComments.length - 2; i >= 0; --i) {
            if (lastChild.leadingComments[i].end <= node.start) {
              node.leadingComments = lastChild.leadingComments.splice(0, i + 1);
              break;
            }
          }
        }
      }
    } else if (this.state.leadingComments.length > 0) {
      if (last(this.state.leadingComments).end <= node.start) {
        if (this.state.commentPreviousNode) {
          for (j = 0; j < this.state.leadingComments.length; j++) {
            if (
              this.state.leadingComments[j].end <
              this.state.commentPreviousNode.end
            ) {
              this.state.leadingComments.splice(j, 1);
              j--;
            }
          }
        }
        if (this.state.leadingComments.length > 0) {
          node.leadingComments = this.state.leadingComments;
          this.state.leadingComments = [];
        }
      } else {
        // https://github.com/eslint/espree/issues/2
        //
        // In special cases, such as return (without a value) and
        // debugger, all comments will end up as leadingComments and
        // will otherwise be eliminated. This step runs when the
        // commentStack is empty and there are comments left
        // in leadingComments.
        //
        // This loop figures out the stopping point between the actual
        // leading and trailing comments by finding the location of the
        // first comment that comes after the given node.
        for (i = 0; i < this.state.leadingComments.length; i++) {
          if (this.state.leadingComments[i].end > node.start) {
            break;
          }
        }

        // Split the array based on the location of the first comment
        // that comes after the node. Keep in mind that this could
        // result in an empty array, and if so, the array must be
        // deleted.
        const leadingComments = this.state.leadingComments.slice(0, i);

        if (leadingComments.length) {
          node.leadingComments = leadingComments;
        }

        // Similarly, trailing comments are attached later. The variable
        // must be reset to null if there are no trailing comments.
        trailingComments = this.state.leadingComments.slice(i);
        if (trailingComments.length === 0) {
          trailingComments = null;
        }
      }
    }

    this.state.commentPreviousNode = node;

    if (trailingComments) {
      if (
        trailingComments.length &&
        trailingComments[0].start >= node.start &&
        last(trailingComments).end <= node.end
      ) {
        node.innerComments = trailingComments;
      } else {
        node.trailingComments = trailingComments;
      }
    }

    stack.push(node);
  }
}

// @flow

// A recursive descent parser operates by defining functions for all
// syntactic elements, and recursively calling those, each function
// advancing the input stream and returning an AST node. Precedence
// of constructs (for example, the fact that `!x[1]` means `!(x[1])`
// instead of `(!x)[1]` is handled by the fact that the parser
// function that parses unary prefix operators is called first, and
// in turn calls the function that parses `[]` subscripts — that
// way, it'll receive the node for `x[1]` already parsed, and wraps
// *that* in the unary operator node.
//
// Acorn uses an [operator precedence parser][opp] to handle binary
// operator precedence, because it is much more compact than using
// the technique outlined above, which uses different, nesting
// functions to specify precedence, for all of the ten binary
// precedence levels that JavaScript defines.
//
// [opp]: http://en.wikipedia.org/wiki/Operator-precedence_parser

import { types as tt, type TokenType } from "../tokenizer/types";
import * as N from "../types";
import LValParser from "./lval";
import { reservedWords } from "../util/identifier";
import type { Pos, Position } from "../util/location";

export default class ExpressionParser extends LValParser {
  // Forward-declaration: defined in statement.js
  +parseBlock: (allowDirectives?: boolean) => N.BlockStatement;
  +parseClass: (
    node: N.Class,
    isStatement: boolean,
    optionalId?: boolean,
  ) => N.Class;
  +parseDecorators: (allowExport?: boolean) => void;
  +parseFunction: <T: N.NormalFunction>(
    node: T,
    isStatement: boolean,
    allowExpressionBody?: boolean,
    isAsync?: boolean,
    optionalId?: boolean,
  ) => T;
  +parseFunctionParams: (node: N.Function, allowModifiers?: boolean) => void;
  +takeDecorators: (node: N.HasDecorators) => void;

  // Check if property name clashes with already added.
  // Object/class getters and setters are not allowed to clash —
  // either with each other or with an init property — and in
  // strict mode, init properties are also not allowed to be repeated.

  checkPropClash(
    prop: N.ObjectMember,
    propHash: { [key: string]: boolean },
  ): void {
    if (prop.computed || prop.kind) return;

    const key = prop.key;
    // It is either an Identifier or a String/NumericLiteral
    const name = key.type === "Identifier" ? key.name : String(key.value);

    if (name === "__proto__") {
      if (propHash.proto) {
        this.raise(key.start, "Redefinition of __proto__ property");
      }
      propHash.proto = true;
    }
  }

  // Convenience method to parse an Expression only
  getExpression(): N.Expression {
    this.nextToken();
    const expr = this.parseExpression();
    if (!this.match(tt.eof)) {
      this.unexpected();
    }
    expr.comments = this.state.comments;
    return expr;
  }

  // ### Expression parsing

  // These nest, from the most general expression type at the top to
  // 'atomic', nondivisible expression types at the bottom. Most of
  // the functions will simply let the function (s) below them parse,
  // and, *if* the syntactic construct they handle is present, wrap
  // the AST node that the inner parser gave them in another node.

  // Parse a full expression. The optional arguments are used to
  // forbid the `in` operator (in for loops initialization expressions)
  // and provide reference for storing '=' operator inside shorthand
  // property assignment in contexts where both object expression
  // and object pattern might appear (so it's possible to raise
  // delayed syntax error at correct position).

  parseExpression(noIn?: boolean, refShorthandDefaultPos?: Pos): N.Expression {
    const startPos = this.state.start;
    const startLoc = this.state.startLoc;
    const expr = this.parseMaybeAssign(noIn, refShorthandDefaultPos);
    if (this.match(tt.comma)) {
      const node = this.startNodeAt(startPos, startLoc);
      node.expressions = [expr];
      while (this.eat(tt.comma)) {
        node.expressions.push(
          this.parseMaybeAssign(noIn, refShorthandDefaultPos),
        );
      }
      this.toReferencedList(node.expressions);
      return this.finishNode(node, "SequenceExpression");
    }
    return expr;
  }

  // Parse an assignment expression. This includes applications of
  // operators like `+=`.

  parseMaybeAssign(
    noIn?: ?boolean,
    refShorthandDefaultPos?: ?Pos,
    afterLeftParse?: Function,
    refNeedsArrowPos?: ?Pos,
  ): N.Expression {
    const startPos = this.state.start;
    const startLoc = this.state.startLoc;
    if (this.match(tt._yield) && this.state.inGenerator) {
      let left = this.parseYield();
      if (afterLeftParse) {
        left = afterLeftParse.call(this, left, startPos, startLoc);
      }
      return left;
    }

    let failOnShorthandAssign;
    if (refShorthandDefaultPos) {
      failOnShorthandAssign = false;
    } else {
      refShorthandDefaultPos = { start: 0 };
      failOnShorthandAssign = true;
    }

    if (this.match(tt.parenL) || this.match(tt.name) || this.match(tt._yield)) {
      this.state.potentialArrowAt = this.state.start;
    }

    let left = this.parseMaybeConditional(
      noIn,
      refShorthandDefaultPos,
      refNeedsArrowPos,
    );
    if (afterLeftParse) {
      left = afterLeftParse.call(this, left, startPos, startLoc);
    }
    if (this.state.type.isAssign) {
      const node = this.startNodeAt(startPos, startLoc);
      const operator = this.state.value;
      node.operator = operator;

      if (operator === "??=") {
        this.expectPlugin("nullishCoalescingOperator");
        this.expectPlugin("logicalAssignment");
      }
      if (operator === "||=" || operator === "&&=") {
        this.expectPlugin("logicalAssignment");
      }
      node.left = this.match(tt.eq)
        ? this.toAssignable(left, undefined, "assignment expression")
        : left;
      refShorthandDefaultPos.start = 0; // reset because shorthand default was used correctly

      this.checkLVal(left, undefined, undefined, "assignment expression");

      if (left.extra && left.extra.parenthesized) {
        let errorMsg;
        if (left.type === "ObjectPattern") {
          errorMsg = "`({a}) = 0` use `({a} = 0)`";
        } else if (left.type === "ArrayPattern") {
          errorMsg = "`([a]) = 0` use `([a] = 0)`";
        }
        if (errorMsg) {
          this.raise(
            left.start,
            `You're trying to assign to a parenthesized expression, eg. instead of ${errorMsg}`,
          );
        }
      }

      this.next();
      node.right = this.parseMaybeAssign(noIn);
      return this.finishNode(node, "AssignmentExpression");
    } else if (failOnShorthandAssign && refShorthandDefaultPos.start) {
      this.unexpected(refShorthandDefaultPos.start);
    }

    return left;
  }

  // Parse a ternary conditional (`?:`) operator.

  parseMaybeConditional(
    noIn: ?boolean,
    refShorthandDefaultPos: Pos,
    refNeedsArrowPos?: ?Pos,
  ): N.Expression {
    const startPos = this.state.start;
    const startLoc = this.state.startLoc;
    const potentialArrowAt = this.state.potentialArrowAt;
    const expr = this.parseExprOps(noIn, refShorthandDefaultPos);

    if (
      expr.type === "ArrowFunctionExpression" &&
      expr.start === potentialArrowAt
    ) {
      return expr;
    }
    if (refShorthandDefaultPos && refShorthandDefaultPos.start) return expr;

    return this.parseConditional(
      expr,
      noIn,
      startPos,
      startLoc,
      refNeedsArrowPos,
    );
  }

  parseConditional(
    expr: N.Expression,
    noIn: ?boolean,
    startPos: number,
    startLoc: Position,
    // FIXME: Disabling this for now since can't seem to get it to play nicely
    // eslint-disable-next-line no-unused-vars
    refNeedsArrowPos?: ?Pos,
  ): N.Expression {
    if (this.eat(tt.question)) {
      const node = this.startNodeAt(startPos, startLoc);
      node.test = expr;
      node.consequent = this.parseMaybeAssign();
      this.expect(tt.colon);
      node.alternate = this.parseMaybeAssign(noIn);
      return this.finishNode(node, "ConditionalExpression");
    }
    return expr;
  }

  // Start the precedence parser.

  parseExprOps(noIn: ?boolean, refShorthandDefaultPos: Pos): N.Expression {
    const startPos = this.state.start;
    const startLoc = this.state.startLoc;
    const potentialArrowAt = this.state.potentialArrowAt;
    const expr = this.parseMaybeUnary(refShorthandDefaultPos);

    if (
      expr.type === "ArrowFunctionExpression" &&
      expr.start === potentialArrowAt
    ) {
      return expr;
    }
    if (refShorthandDefaultPos && refShorthandDefaultPos.start) {
      return expr;
    }

    return this.parseExprOp(expr, startPos, startLoc, -1, noIn);
  }

  // Parse binary operators with the operator precedence parsing
  // algorithm. `left` is the left-hand side of the operator.
  // `minPrec` provides context that allows the function to stop and
  // defer further parser to one of its callers when it encounters an
  // operator that has a lower precedence than the set it is parsing.

  parseExprOp(
    left: N.Expression,
    leftStartPos: number,
    leftStartLoc: Position,
    minPrec: number,
    noIn: ?boolean,
  ): N.Expression {
    const prec = this.state.type.binop;
    if (prec != null && (!noIn || !this.match(tt._in))) {
      if (prec > minPrec) {
        const node = this.startNodeAt(leftStartPos, leftStartLoc);
        const operator = this.state.value;
        node.left = left;
        node.operator = operator;

        if (
          operator === "**" &&
          left.type === "UnaryExpression" &&
          left.extra &&
          !left.extra.parenthesizedArgument &&
          !left.extra.parenthesized
        ) {
          this.raise(
            left.argument.start,
            "Illegal expression. Wrap left hand side or entire exponentiation in parentheses.",
          );
        }

        const op = this.state.type;
        if (op === tt.nullishCoalescing) {
          this.expectPlugin("nullishCoalescingOperator");
        } else if (op === tt.pipeline) {
          this.expectPlugin("pipelineOperator");
        }

        this.next();

        const startPos = this.state.start;
        const startLoc = this.state.startLoc;

        if (op === tt.pipeline) {
          if (
            this.match(tt.name) &&
            this.state.value === "await" &&
            this.state.inAsync
          ) {
            throw this.raise(
              this.state.start,
              `Unexpected "await" after pipeline body; await must have parentheses in minimal proposal`,
            );
          }
        }

        node.right = this.parseExprOp(
          this.parseMaybeUnary(),
          startPos,
          startLoc,
          op.rightAssociative ? prec - 1 : prec,
          noIn,
        );

        this.finishNode(
          node,
          op === tt.logicalOR ||
          op === tt.logicalAND ||
          op === tt.nullishCoalescing
            ? "LogicalExpression"
            : "BinaryExpression",
        );
        return this.parseExprOp(
          node,
          leftStartPos,
          leftStartLoc,
          minPrec,
          noIn,
        );
      }
    }
    return left;
  }

  // Parse unary operators, both prefix and postfix.

  parseMaybeUnary(refShorthandDefaultPos: ?Pos): N.Expression {
    if (this.state.type.prefix) {
      const node = this.startNode();
      const update = this.match(tt.incDec);
      node.operator = this.state.value;
      node.prefix = true;

      if (node.operator === "throw") {
        this.expectPlugin("throwExpressions");
      }
      this.next();

      const argType = this.state.type;
      node.argument = this.parseMaybeUnary();

      this.addExtra(
        node,
        "parenthesizedArgument",
        argType === tt.parenL &&
          (!node.argument.extra || !node.argument.extra.parenthesized),
      );

      if (refShorthandDefaultPos && refShorthandDefaultPos.start) {
        this.unexpected(refShorthandDefaultPos.start);
      }

      if (update) {
        this.checkLVal(node.argument, undefined, undefined, "prefix operation");
      } else if (this.state.strict && node.operator === "delete") {
        const arg = node.argument;

        if (arg.type === "Identifier") {
          this.raise(node.start, "Deleting local variable in strict mode");
        } else if (
          arg.type === "MemberExpression" &&
          arg.property.type === "PrivateName"
        ) {
          this.raise(node.start, "Deleting a private field is not allowed");
        }
      }

      return this.finishNode(
        node,
        update ? "UpdateExpression" : "UnaryExpression",
      );
    }

    const startPos = this.state.start;
    const startLoc = this.state.startLoc;
    let expr = this.parseExprSubscripts(refShorthandDefaultPos);
    if (refShorthandDefaultPos && refShorthandDefaultPos.start) return expr;
    while (this.state.type.postfix && !this.canInsertSemicolon()) {
      const node = this.startNodeAt(startPos, startLoc);
      node.operator = this.state.value;
      node.prefix = false;
      node.argument = expr;
      this.checkLVal(expr, undefined, undefined, "postfix operation");
      this.next();
      expr = this.finishNode(node, "UpdateExpression");
    }
    return expr;
  }

  // Parse call, dot, and `[]`-subscript expressions.

  parseExprSubscripts(refShorthandDefaultPos: ?Pos): N.Expression {
    const startPos = this.state.start;
    const startLoc = this.state.startLoc;
    const potentialArrowAt = this.state.potentialArrowAt;
    const expr = this.parseExprAtom(refShorthandDefaultPos);

    if (
      expr.type === "ArrowFunctionExpression" &&
      expr.start === potentialArrowAt
    ) {
      return expr;
    }

    if (refShorthandDefaultPos && refShorthandDefaultPos.start) {
      return expr;
    }

    return this.parseSubscripts(expr, startPos, startLoc);
  }

  parseSubscripts(
    base: N.Expression,
    startPos: number,
    startLoc: Position,
    noCalls?: ?boolean,
  ): N.Expression {
    const state = {
      optionalChainMember: false,
      stop: false,
    };
    do {
      base = this.parseSubscript(base, startPos, startLoc, noCalls, state);
    } while (!state.stop);
    return base;
  }

  /**
   * @param state Set 'state.stop = true' to indicate that we should stop parsing subscripts.
   *   state.optionalChainMember to indicate that the member is currently in OptionalChain
   */
  parseSubscript(
    base: N.Expression,
    startPos: number,
    startLoc: Position,
    noCalls: ?boolean,
    state: N.ParseSubscriptState,
  ): N.Expression {
    if (!noCalls && this.eat(tt.doubleColon)) {
      const node = this.startNodeAt(startPos, startLoc);
      node.object = base;
      node.callee = this.parseNoCallExpr();
      state.stop = true;
      return this.parseSubscripts(
        this.finishNode(node, "BindExpression"),
        startPos,
        startLoc,
        noCalls,
      );
    } else if (this.match(tt.questionDot)) {
      this.expectPlugin("optionalChaining");
      state.optionalChainMember = true;
      if (noCalls && this.lookahead().type == tt.parenL) {
        state.stop = true;
        return base;
      }
      this.next();

      const node = this.startNodeAt(startPos, startLoc);

      if (this.eat(tt.bracketL)) {
        node.object = base;
        node.property = this.parseExpression();
        node.computed = true;
        node.optional = true;
        this.expect(tt.bracketR);
        return this.finishNode(node, "OptionalMemberExpression");
      } else if (this.eat(tt.parenL)) {
        const possibleAsync = this.atPossibleAsync(base);

        node.callee = base;
        node.arguments = this.parseCallExpressionArguments(
          tt.parenR,
          possibleAsync,
        );
        node.optional = true;

        return this.finishNode(node, "OptionalCallExpression");
      } else {
        node.object = base;
        node.property = this.parseIdentifier(true);
        node.computed = false;
        node.optional = true;
        return this.finishNode(node, "OptionalMemberExpression");
      }
    } else if (this.eat(tt.dot)) {
      const node = this.startNodeAt(startPos, startLoc);
      node.object = base;
      node.property = this.parseMaybePrivateName();
      node.computed = false;
      if (state.optionalChainMember) {
        node.optional = false;
        return this.finishNode(node, "OptionalMemberExpression");
      }
      return this.finishNode(node, "MemberExpression");
    } else if (this.eat(tt.bracketL)) {
      const node = this.startNodeAt(startPos, startLoc);
      node.object = base;
      node.property = this.parseExpression();
      node.computed = true;
      this.expect(tt.bracketR);
      if (state.optionalChainMember) {
        node.optional = false;
        return this.finishNode(node, "OptionalMemberExpression");
      }
      return this.finishNode(node, "MemberExpression");
    } else if (!noCalls && this.match(tt.parenL)) {
      const possibleAsync = this.atPossibleAsync(base);
      this.next();

      const node = this.startNodeAt(startPos, startLoc);
      node.callee = base;

      // TODO: Clean up/merge this into `this.state` or a class like acorn's
      // `DestructuringErrors` alongside refShorthandDefaultPos and
      // refNeedsArrowPos.
      const refTrailingCommaPos: Pos = { start: -1 };

      node.arguments = this.parseCallExpressionArguments(
        tt.parenR,
        possibleAsync,
        refTrailingCommaPos,
      );
      if (!state.optionalChainMember) {
        this.finishCallExpression(node);
      } else {
        this.finishOptionalCallExpression(node);
      }

      if (possibleAsync && this.shouldParseAsyncArrow()) {
        state.stop = true;

        if (refTrailingCommaPos.start > -1) {
          this.raise(
            refTrailingCommaPos.start,
            "A trailing comma is not permitted after the rest element",
          );
        }

        return this.parseAsyncArrowFromCallExpression(
          this.startNodeAt(startPos, startLoc),
          node,
        );
      } else {
        this.toReferencedList(node.arguments);
      }
      return node;
    } else if (this.match(tt.backQuote)) {
      const node = this.startNodeAt(startPos, startLoc);
      node.tag = base;
      node.quasi = this.parseTemplate(true);
      if (state.optionalChainMember) {
        this.raise(
          startPos,
          "Tagged Template Literals are not allowed in optionalChain",
        );
      }
      return this.finishNode(node, "TaggedTemplateExpression");
    } else {
      state.stop = true;
      return base;
    }
  }

  atPossibleAsync(base: N.Expression): boolean {
    return (
      !this.state.containsEsc &&
      this.state.potentialArrowAt === base.start &&
      base.type === "Identifier" &&
      base.name === "async" &&
      !this.canInsertSemicolon()
    );
  }

  finishCallExpression(node: N.CallExpression): N.CallExpression {
    if (node.callee.type === "Import") {
      if (node.arguments.length !== 1) {
        this.raise(node.start, "import() requires exactly one argument");
      }

      const importArg = node.arguments[0];
      if (importArg && importArg.type === "SpreadElement") {
        this.raise(importArg.start, "... is not allowed in import()");
      }
    }
    return this.finishNode(node, "CallExpression");
  }

  finishOptionalCallExpression(node: N.CallExpression): N.CallExpression {
    if (node.callee.type === "Import") {
      if (node.arguments.length !== 1) {
        this.raise(node.start, "import() requires exactly one argument");
      }

      const importArg = node.arguments[0];
      if (importArg && importArg.type === "SpreadElement") {
        this.raise(importArg.start, "... is not allowed in import()");
      }
    }
    return this.finishNode(node, "OptionalCallExpression");
  }

  parseCallExpressionArguments(
    close: TokenType,
    possibleAsyncArrow: boolean,
    refTrailingCommaPos?: Pos,
  ): $ReadOnlyArray<?N.Expression> {
    const elts = [];
    let innerParenStart;
    let first = true;

    while (!this.eat(close)) {
      if (first) {
        first = false;
      } else {
        this.expect(tt.comma);
        if (this.eat(close)) break;
      }

      // we need to make sure that if this is an async arrow functions,
      // that we don't allow inner parens inside the params
      if (this.match(tt.parenL) && !innerParenStart) {
        innerParenStart = this.state.start;
      }

      elts.push(
        this.parseExprListItem(
          false,
          possibleAsyncArrow ? { start: 0 } : undefined,
          possibleAsyncArrow ? { start: 0 } : undefined,
          possibleAsyncArrow ? refTrailingCommaPos : undefined,
        ),
      );
    }

    // we found an async arrow function so let's not allow any inner parens
    if (possibleAsyncArrow && innerParenStart && this.shouldParseAsyncArrow()) {
      this.unexpected();
    }

    return elts;
  }

  shouldParseAsyncArrow(): boolean {
    return this.match(tt.arrow);
  }

  parseAsyncArrowFromCallExpression(
    node: N.ArrowFunctionExpression,
    call: N.CallExpression,
  ): N.ArrowFunctionExpression {
    const oldYield = this.state.yieldInPossibleArrowParameters;
    this.state.yieldInPossibleArrowParameters = null;
    this.expect(tt.arrow);
    this.parseArrowExpression(node, call.arguments, true);
    this.state.yieldInPossibleArrowParameters = oldYield;
    return node;
  }

  // Parse a no-call expression (like argument of `new` or `::` operators).

  parseNoCallExpr(): N.Expression {
    const startPos = this.state.start;
    const startLoc = this.state.startLoc;
    return this.parseSubscripts(this.parseExprAtom(), startPos, startLoc, true);
  }

  // Parse an atomic expression — either a single token that is an
  // expression, an expression started by a keyword like `function` or
  // `new`, or an expression wrapped in punctuation like `()`, `[]`,
  // or `{}`.

  parseExprAtom(refShorthandDefaultPos?: ?Pos): N.Expression {
    const canBeArrow = this.state.potentialArrowAt === this.state.start;
    let node;

    switch (this.state.type) {
      case tt._super:
        if (
          !this.state.inMethod &&
          !this.state.inClassProperty &&
          !this.options.allowSuperOutsideMethod
        ) {
          this.raise(
            this.state.start,
            "super is only allowed in object methods and classes",
          );
        }

        node = this.startNode();
        this.next();
        if (
          !this.match(tt.parenL) &&
          !this.match(tt.bracketL) &&
          !this.match(tt.dot)
        ) {
          this.unexpected();
        }
        if (
          this.match(tt.parenL) &&
          this.state.inMethod !== "constructor" &&
          !this.options.allowSuperOutsideMethod
        ) {
          this.raise(
            node.start,
            "super() is only valid inside a class constructor. " +
              "Make sure the method name is spelled exactly as 'constructor'.",
          );
        }
        return this.finishNode(node, "Super");

      case tt._import:
        if (this.lookahead().type === tt.dot) {
          return this.parseImportMetaProperty();
        }

        this.expectPlugin("dynamicImport");

        node = this.startNode();
        this.next();
        if (!this.match(tt.parenL)) {
          this.unexpected(null, tt.parenL);
        }
        return this.finishNode(node, "Import");

      case tt._this:
        node = this.startNode();
        this.next();
        return this.finishNode(node, "ThisExpression");

      case tt._yield:
        if (this.state.inGenerator) this.unexpected();

      case tt.name: {
        node = this.startNode();
        const allowAwait =
          this.state.value === "await" &&
          (this.state.inAsync ||
            (!this.state.inFunction && this.options.allowAwaitOutsideFunction));

        const containsEsc = this.state.containsEsc;
        const allowYield = this.shouldAllowYieldIdentifier();
        const id = this.parseIdentifier(allowAwait || allowYield);

        if (id.name === "await") {
          if (
            this.state.inAsync ||
            this.inModule ||
            (!this.state.inFunction && this.options.allowAwaitOutsideFunction)
          ) {
            return this.parseAwait(node);
          }
        } else if (
          !containsEsc &&
          id.name === "async" &&
          this.match(tt._function) &&
          !this.canInsertSemicolon()
        ) {
          this.next();
          return this.parseFunction(node, false, false, true);
        } else if (canBeArrow && id.name === "async" && this.match(tt.name)) {
          const oldYield = this.state.yieldInPossibleArrowParameters;
          this.state.yieldInPossibleArrowParameters = null;
          const params = [this.parseIdentifier()];
          this.expect(tt.arrow);
          // let foo = bar => {};
          this.parseArrowExpression(node, params, true);
          this.state.yieldInPossibleArrowParameters = oldYield;
          return node;
        }

        if (canBeArrow && !this.canInsertSemicolon() && this.eat(tt.arrow)) {
          const oldYield = this.state.yieldInPossibleArrowParameters;
          this.state.yieldInPossibleArrowParameters = null;
          this.parseArrowExpression(node, [id]);
          this.state.yieldInPossibleArrowParameters = oldYield;
          return node;
        }

        return id;
      }

      case tt._do: {
        this.expectPlugin("doExpressions");
        const node = this.startNode();
        this.next();
        const oldInFunction = this.state.inFunction;
        const oldLabels = this.state.labels;
        this.state.labels = [];
        this.state.inFunction = false;
        node.body = this.parseBlock(false);
        this.state.inFunction = oldInFunction;
        this.state.labels = oldLabels;
        return this.finishNode(node, "DoExpression");
      }

      case tt.regexp: {
        const value = this.state.value;
        node = this.parseLiteral(value.value, "RegExpLiteral");
        node.pattern = value.pattern;
        node.flags = value.flags;
        return node;
      }

      case tt.num:
        return this.parseLiteral(this.state.value, "NumericLiteral");

      case tt.bigint:
        return this.parseLiteral(this.state.value, "BigIntLiteral");

      case tt.string:
        return this.parseLiteral(this.state.value, "StringLiteral");

      case tt._null:
        node = this.startNode();
        this.next();
        return this.finishNode(node, "NullLiteral");

      case tt._true:
      case tt._false:
        return this.parseBooleanLiteral();

      case tt.parenL:
        return this.parseParenAndDistinguishExpression(canBeArrow);

      case tt.bracketL:
        node = this.startNode();
        this.next();
        node.elements = this.parseExprList(
          tt.bracketR,
          true,
          refShorthandDefaultPos,
        );
        this.toReferencedList(node.elements);
        return this.finishNode(node, "ArrayExpression");

      case tt.braceL:
        return this.parseObj(false, refShorthandDefaultPos);

      case tt._function:
        return this.parseFunctionExpression();

      case tt.at:
        this.parseDecorators();

      case tt._class:
        node = this.startNode();
        this.takeDecorators(node);
        return this.parseClass(node, false);

      case tt._new:
        return this.parseNew();

      case tt.backQuote:
        return this.parseTemplate(false);

      case tt.doubleColon: {
        node = this.startNode();
        this.next();
        node.object = null;
        const callee = (node.callee = this.parseNoCallExpr());
        if (callee.type === "MemberExpression") {
          return this.finishNode(node, "BindExpression");
        } else {
          throw this.raise(
            callee.start,
            "Binding should be performed on object property.",
          );
        }
      }

      default:
        throw this.unexpected();
    }
  }

  parseBooleanLiteral(): N.BooleanLiteral {
    const node = this.startNode();
    node.value = this.match(tt._true);
    this.next();
    return this.finishNode(node, "BooleanLiteral");
  }

  parseMaybePrivateName(): N.PrivateName | N.Identifier {
    const isPrivate = this.match(tt.hash);

    if (isPrivate) {
      this.expectOnePlugin(["classPrivateProperties", "classPrivateMethods"]);
      const node = this.startNode();
      this.next();
      node.id = this.parseIdentifier(true);
      return this.finishNode(node, "PrivateName");
    } else {
      return this.parseIdentifier(true);
    }
  }

  parseFunctionExpression(): N.FunctionExpression | N.MetaProperty {
    const node = this.startNode();
    const meta = this.parseIdentifier(true);
    if (this.state.inGenerator && this.eat(tt.dot)) {
      return this.parseMetaProperty(node, meta, "sent");
    }
    return this.parseFunction(node, false);
  }

  parseMetaProperty(
    node: N.MetaProperty,
    meta: N.Identifier,
    propertyName: string,
  ): N.MetaProperty {
    node.meta = meta;

    if (meta.name === "function" && propertyName === "sent") {
      if (this.isContextual(propertyName)) {
        this.expectPlugin("functionSent");
      } else if (!this.hasPlugin("functionSent")) {
        // The code wasn't `function.sent` but just `function.`, so a simple error is less confusing.
        this.unexpected();
      }
    }

    const containsEsc = this.state.containsEsc;

    node.property = this.parseIdentifier(true);

    if (node.property.name !== propertyName || containsEsc) {
      this.raise(
        node.property.start,
        `The only valid meta property for ${meta.name} is ${
          meta.name
        }.${propertyName}`,
      );
    }

    return this.finishNode(node, "MetaProperty");
  }

  parseImportMetaProperty(): N.MetaProperty {
    const node = this.startNode();
    const id = this.parseIdentifier(true);
    this.expect(tt.dot);

    if (id.name === "import") {
      if (this.isContextual("meta")) {
        this.expectPlugin("importMeta");
      } else if (!this.hasPlugin("importMeta")) {
        this.raise(
          id.start,
          `Dynamic imports require a parameter: import('a.js').then`,
        );
      }
    }

    if (!this.inModule) {
      this.raise(
        id.start,
        `import.meta may appear only with 'sourceType: "module"'`,
        { code: "BABEL_PARSER_SOURCETYPE_MODULE_REQUIRED" },
      );
    }
    this.sawUnambiguousESM = true;

    return this.parseMetaProperty(node, id, "meta");
  }

  parseLiteral<T: N.Literal>(
    value: any,
    type: /*T["kind"]*/ string,
    startPos?: number,
    startLoc?: Position,
  ): T {
    startPos = startPos || this.state.start;
    startLoc = startLoc || this.state.startLoc;

    const node = this.startNodeAt(startPos, startLoc);
    this.addExtra(node, "rawValue", value);
    this.addExtra(node, "raw", this.input.slice(startPos, this.state.end));
    node.value = value;
    this.next();
    return this.finishNode(node, type);
  }

  parseParenExpression(): N.Expression {
    this.expect(tt.parenL);
    const val = this.parseExpression();
    this.expect(tt.parenR);
    return val;
  }

  parseParenAndDistinguishExpression(canBeArrow: boolean): N.Expression {
    const startPos = this.state.start;
    const startLoc = this.state.startLoc;

    let val;
    this.expect(tt.parenL);

    const oldMaybeInArrowParameters = this.state.maybeInArrowParameters;
    const oldYield = this.state.yieldInPossibleArrowParameters;
    this.state.maybeInArrowParameters = true;
    this.state.yieldInPossibleArrowParameters = null;

    const innerStartPos = this.state.start;
    const innerStartLoc = this.state.startLoc;
    const exprList = [];
    const refShorthandDefaultPos = { start: 0 };
    const refNeedsArrowPos = { start: 0 };
    let first = true;
    let spreadStart;
    let optionalCommaStart;

    while (!this.match(tt.parenR)) {
      if (first) {
        first = false;
      } else {
        this.expect(tt.comma, refNeedsArrowPos.start || null);
        if (this.match(tt.parenR)) {
          optionalCommaStart = this.state.start;
          break;
        }
      }

      if (this.match(tt.ellipsis)) {
        const spreadNodeStartPos = this.state.start;
        const spreadNodeStartLoc = this.state.startLoc;
        spreadStart = this.state.start;
        exprList.push(
          this.parseParenItem(
            this.parseRest(),
            spreadNodeStartPos,
            spreadNodeStartLoc,
          ),
        );

        if (this.match(tt.comma) && this.lookahead().type === tt.parenR) {
          this.raise(
            this.state.start,
            "A trailing comma is not permitted after the rest element",
          );
        }

        break;
      } else {
        exprList.push(
          this.parseMaybeAssign(
            false,
            refShorthandDefaultPos,
            this.parseParenItem,
            refNeedsArrowPos,
          ),
        );
      }
    }

    const innerEndPos = this.state.start;
    const innerEndLoc = this.state.startLoc;
    this.expect(tt.parenR);

    this.state.maybeInArrowParameters = oldMaybeInArrowParameters;

    let arrowNode = this.startNodeAt(startPos, startLoc);
    if (
      canBeArrow &&
      this.shouldParseArrow() &&
      (arrowNode = this.parseArrow(arrowNode))
    ) {
      for (const param of exprList) {
        if (param.extra && param.extra.parenthesized) {
          this.unexpected(param.extra.parenStart);
        }
      }

      this.parseArrowExpression(arrowNode, exprList);
      this.state.yieldInPossibleArrowParameters = oldYield;
      return arrowNode;
    }

    this.state.yieldInPossibleArrowParameters = oldYield;

    if (!exprList.length) {
      this.unexpected(this.state.lastTokStart);
    }
    if (optionalCommaStart) this.unexpected(optionalCommaStart);
    if (spreadStart) this.unexpected(spreadStart);
    if (refShorthandDefaultPos.start) {
      this.unexpected(refShorthandDefaultPos.start);
    }
    if (refNeedsArrowPos.start) this.unexpected(refNeedsArrowPos.start);

    if (exprList.length > 1) {
      val = this.startNodeAt(innerStartPos, innerStartLoc);
      val.expressions = exprList;
      this.toReferencedList(val.expressions);
      this.finishNodeAt(val, "SequenceExpression", innerEndPos, innerEndLoc);
    } else {
      val = exprList[0];
    }

    this.addExtra(val, "parenthesized", true);
    this.addExtra(val, "parenStart", startPos);

    return val;
  }

  shouldParseArrow(): boolean {
    return !this.canInsertSemicolon();
  }

  parseArrow(node: N.ArrowFunctionExpression): ?N.ArrowFunctionExpression {
    if (this.eat(tt.arrow)) {
      return node;
    }
  }

  parseParenItem(
    node: N.Expression,
    startPos: number,
    // eslint-disable-next-line no-unused-vars
    startLoc: Position,
  ): N.Expression {
    return node;
  }

  // New's precedence is slightly tricky. It must allow its argument to
  // be a `[]` or dot subscript expression, but not a call — at least,
  // not without wrapping it in parentheses. Thus, it uses the noCalls
  // argument to parseSubscripts to prevent it from consuming the
  // argument list.

  parseNew(): N.NewExpression | N.MetaProperty {
    const node = this.startNode();
    const meta = this.parseIdentifier(true);

    if (this.eat(tt.dot)) {
      const metaProp = this.parseMetaProperty(node, meta, "target");

      if (!this.state.inFunction && !this.state.inClassProperty) {
        let error = "new.target can only be used in functions";

        if (this.hasPlugin("classProperties")) {
          error += " or class properties";
        }

        this.raise(metaProp.start, error);
      }

      return metaProp;
    }

    node.callee = this.parseNoCallExpr();
    if (
      node.callee.type === "OptionalMemberExpression" ||
      node.callee.type === "OptionalCallExpression"
    ) {
      this.raise(
        this.state.lastTokEnd,
        "constructors in/after an Optional Chain are not allowed",
      );
    }
    if (this.eat(tt.questionDot)) {
      this.raise(
        this.state.start,
        "constructors in/after an Optional Chain are not allowed",
      );
    }
    this.parseNewArguments(node);
    return this.finishNode(node, "NewExpression");
  }

  parseNewArguments(node: N.NewExpression): void {
    if (this.eat(tt.parenL)) {
      const args = this.parseExprList(tt.parenR);
      this.toReferencedList(args);
      // $FlowFixMe (parseExprList should be all non-null in this case)
      node.arguments = args;
    } else {
      node.arguments = [];
    }
  }

  // Parse template expression.

  parseTemplateElement(isTagged: boolean): N.TemplateElement {
    const elem = this.startNode();
    if (this.state.value === null) {
      if (!isTagged) {
        // TODO: fix this
        this.raise(
          this.state.invalidTemplateEscapePosition || 0,
          "Invalid escape sequence in template",
        );
      } else {
        this.state.invalidTemplateEscapePosition = null;
      }
    }
    elem.value = {
      raw: this.input
        .slice(this.state.start, this.state.end)
        .replace(/\r\n?/g, "\n"),
      cooked: this.state.value,
    };
    this.next();
    elem.tail = this.match(tt.backQuote);
    return this.finishNode(elem, "TemplateElement");
  }

  parseTemplate(isTagged: boolean): N.TemplateLiteral {
    const node = this.startNode();
    this.next();
    node.expressions = [];
    let curElt = this.parseTemplateElement(isTagged);
    node.quasis = [curElt];
    while (!curElt.tail) {
      this.expect(tt.dollarBraceL);
      node.expressions.push(this.parseExpression());
      this.expect(tt.braceR);
      node.quasis.push((curElt = this.parseTemplateElement(isTagged)));
    }
    this.next();
    return this.finishNode(node, "TemplateLiteral");
  }

  // Parse an object literal or binding pattern.

  parseObj<T: N.ObjectPattern | N.ObjectExpression>(
    isPattern: boolean,
    refShorthandDefaultPos?: ?Pos,
  ): T {
    let decorators = [];
    const propHash: any = Object.create(null);
    let first = true;
    const node = this.startNode();

    node.properties = [];
    this.next();

    let firstRestLocation = null;

    while (!this.eat(tt.braceR)) {
      if (first) {
        first = false;
      } else {
        this.expect(tt.comma);
        if (this.eat(tt.braceR)) break;
      }

      if (this.match(tt.at)) {
        if (this.hasPlugin("decorators2")) {
          this.raise(
            this.state.start,
            "Stage 2 decorators disallow object literal property decorators",
          );
        } else {
          // we needn't check if decorators (stage 0) plugin is enabled since it's checked by
          // the call to this.parseDecorator
          while (this.match(tt.at)) {
            decorators.push(this.parseDecorator());
          }
        }
      }

      let prop = this.startNode(),
        isGenerator = false,
        isAsync = false,
        startPos,
        startLoc;
      if (decorators.length) {
        prop.decorators = decorators;
        decorators = [];
      }

      if (this.match(tt.ellipsis)) {
        this.expectPlugin("objectRestSpread");
        prop = this.parseSpread(isPattern ? { start: 0 } : undefined);
        if (isPattern) {
          this.toAssignable(prop, true, "object pattern");
        }
        node.properties.push(prop);
        if (isPattern) {
          const position = this.state.start;
          if (firstRestLocation !== null) {
            this.unexpected(
              firstRestLocation,
              "Cannot have multiple rest elements when destructuring",
            );
          } else if (this.eat(tt.braceR)) {
            break;
          } else if (
            this.match(tt.comma) &&
            this.lookahead().type === tt.braceR
          ) {
            this.unexpected(
              position,
              "A trailing comma is not permitted after the rest element",
            );
          } else {
            firstRestLocation = position;
            continue;
          }
        } else {
          continue;
        }
      }

      prop.method = false;

      if (isPattern || refShorthandDefaultPos) {
        startPos = this.state.start;
        startLoc = this.state.startLoc;
      }

      if (!isPattern) {
        isGenerator = this.eat(tt.star);
      }

      const containsEsc = this.state.containsEsc;

      if (!isPattern && this.isContextual("async")) {
        if (isGenerator) this.unexpected();

        const asyncId = this.parseIdentifier();
        if (
          this.match(tt.colon) ||
          this.match(tt.parenL) ||
          this.match(tt.braceR) ||
          this.match(tt.eq) ||
          this.match(tt.comma)
        ) {
          prop.key = asyncId;
          prop.computed = false;
        } else {
          isAsync = true;
          if (this.match(tt.star)) {
            this.expectPlugin("asyncGenerators");
            this.next();
            isGenerator = true;
          }
          this.parsePropertyName(prop);
        }
      } else {
        this.parsePropertyName(prop);
      }

      this.parseObjPropValue(
        prop,
        startPos,
        startLoc,
        isGenerator,
        isAsync,
        isPattern,
        refShorthandDefaultPos,
        containsEsc,
      );
      this.checkPropClash(prop, propHash);

      if (prop.shorthand) {
        this.addExtra(prop, "shorthand", true);
      }

      node.properties.push(prop);
    }

    if (firstRestLocation !== null) {
      this.unexpected(
        firstRestLocation,
        "The rest element has to be the last element when destructuring",
      );
    }

    if (decorators.length) {
      this.raise(
        this.state.start,
        "You have trailing decorators with no property",
      );
    }

    return this.finishNode(
      node,
      isPattern ? "ObjectPattern" : "ObjectExpression",
    );
  }

  isGetterOrSetterMethod(prop: N.ObjectMethod, isPattern: boolean): boolean {
    return (
      !isPattern &&
      !prop.computed &&
      prop.key.type === "Identifier" &&
      (prop.key.name === "get" || prop.key.name === "set") &&
      (this.match(tt.string) || // get "string"() {}
      this.match(tt.num) || // get 1() {}
      this.match(tt.bracketL) || // get ["string"]() {}
      this.match(tt.name) || // get foo() {}
        !!this.state.type.keyword) // get debugger() {}
    );
  }

  // get methods aren't allowed to have any parameters
  // set methods must have exactly 1 parameter which is not a rest parameter
  checkGetterSetterParams(method: N.ObjectMethod | N.ClassMethod): void {
    const paramCount = method.kind === "get" ? 0 : 1;
    const start = method.start;
    if (method.params.length !== paramCount) {
      if (method.kind === "get") {
        this.raise(start, "getter must not have any formal parameters");
      } else {
        this.raise(start, "setter must have exactly one formal parameter");
      }
    }

    if (method.kind === "set" && method.params[0].type === "RestElement") {
      this.raise(
        start,
        "setter function argument must not be a rest parameter",
      );
    }
  }

  parseObjectMethod(
    prop: N.ObjectMethod,
    isGenerator: boolean,
    isAsync: boolean,
    isPattern: boolean,
    containsEsc: boolean,
  ): ?N.ObjectMethod {
    if (isAsync || isGenerator || this.match(tt.parenL)) {
      if (isPattern) this.unexpected();
      prop.kind = "method";
      prop.method = true;
      return this.parseMethod(
        prop,
        isGenerator,
        isAsync,
        /* isConstructor */ false,
        "ObjectMethod",
      );
    }

    if (!containsEsc && this.isGetterOrSetterMethod(prop, isPattern)) {
      if (isGenerator || isAsync) this.unexpected();
      prop.kind = prop.key.name;
      this.parsePropertyName(prop);
      this.parseMethod(
        prop,
        /* isGenerator */ false,
        /* isAsync */ false,
        /* isConstructor */ false,
        "ObjectMethod",
      );
      this.checkGetterSetterParams(prop);
      return prop;
    }
  }

  parseObjectProperty(
    prop: N.ObjectProperty,
    startPos: ?number,
    startLoc: ?Position,
    isPattern: boolean,
    refShorthandDefaultPos: ?Pos,
  ): ?N.ObjectProperty {
    prop.shorthand = false;

    if (this.eat(tt.colon)) {
      prop.value = isPattern
        ? this.parseMaybeDefault(this.state.start, this.state.startLoc)
        : this.parseMaybeAssign(false, refShorthandDefaultPos);

      return this.finishNode(prop, "ObjectProperty");
    }

    if (!prop.computed && prop.key.type === "Identifier") {
      this.checkReservedWord(prop.key.name, prop.key.start, true, true);

      if (isPattern) {
        prop.value = this.parseMaybeDefault(
          startPos,
          startLoc,
          prop.key.__clone(),
        );
      } else if (this.match(tt.eq) && refShorthandDefaultPos) {
        if (!refShorthandDefaultPos.start) {
          refShorthandDefaultPos.start = this.state.start;
        }
        prop.value = this.parseMaybeDefault(
          startPos,
          startLoc,
          prop.key.__clone(),
        );
      } else {
        prop.value = prop.key.__clone();
      }
      prop.shorthand = true;

      return this.finishNode(prop, "ObjectProperty");
    }
  }

  parseObjPropValue(
    prop: any,
    startPos: ?number,
    startLoc: ?Position,
    isGenerator: boolean,
    isAsync: boolean,
    isPattern: boolean,
    refShorthandDefaultPos: ?Pos,
    containsEsc: boolean,
  ): void {
    const node =
      this.parseObjectMethod(
        prop,
        isGenerator,
        isAsync,
        isPattern,
        containsEsc,
      ) ||
      this.parseObjectProperty(
        prop,
        startPos,
        startLoc,
        isPattern,
        refShorthandDefaultPos,
      );

    if (!node) this.unexpected();

    // $FlowFixMe
    return node;
  }

  parsePropertyName(
    prop: N.ObjectOrClassMember | N.ClassMember | N.TsNamedTypeElementBase,
  ): N.Expression | N.Identifier {
    if (this.eat(tt.bracketL)) {
      (prop: $FlowSubtype<N.ObjectOrClassMember>).computed = true;
      prop.key = this.parseMaybeAssign();
      this.expect(tt.bracketR);
    } else {
      const oldInPropertyName = this.state.inPropertyName;
      this.state.inPropertyName = true;
      // We check if it's valid for it to be a private name when we push it.
      (prop: $FlowFixMe).key =
        this.match(tt.num) || this.match(tt.string)
          ? this.parseExprAtom()
          : this.parseMaybePrivateName();

      if (prop.key.type !== "PrivateName") {
        // ClassPrivateProperty is never computed, so we don't assign in that case.
        prop.computed = false;
      }

      this.state.inPropertyName = oldInPropertyName;
    }

    return prop.key;
  }

  // Initialize empty function node.

  initFunction(node: N.BodilessFunctionOrMethodBase, isAsync: ?boolean): void {
    node.id = null;
    node.generator = false;
    node.async = !!isAsync;
  }

  // Parse object or class method.

  parseMethod<T: N.MethodLike>(
    node: T,
    isGenerator: boolean,
    isAsync: boolean,
    isConstructor: boolean,
    type: string,
  ): T {
    const oldInFunc = this.state.inFunction;
    const oldInMethod = this.state.inMethod;
    const oldInGenerator = this.state.inGenerator;
    this.state.inFunction = true;
    this.state.inMethod = node.kind || true;
    this.state.inGenerator = isGenerator;

    this.initFunction(node, isAsync);
    node.generator = !!isGenerator;
    const allowModifiers = isConstructor; // For TypeScript parameter properties
    this.parseFunctionParams((node: any), allowModifiers);
    this.parseFunctionBodyAndFinish(node, type);

    this.state.inFunction = oldInFunc;
    this.state.inMethod = oldInMethod;
    this.state.inGenerator = oldInGenerator;

    return node;
  }

  // Parse arrow function expression.
  // If the parameters are provided, they will be converted to an
  // assignable list.
  parseArrowExpression(
    node: N.ArrowFunctionExpression,
    params?: ?(N.Expression[]),
    isAsync?: boolean,
  ): N.ArrowFunctionExpression {
    // if we got there, it's no more "yield in possible arrow parameters";
    // it's just "yield in arrow parameters"
    if (this.state.yieldInPossibleArrowParameters) {
      this.raise(
        this.state.yieldInPossibleArrowParameters.start,
        "yield is not allowed in the parameters of an arrow function" +
          " inside a generator",
      );
    }

    const oldInFunc = this.state.inFunction;
    this.state.inFunction = true;
    this.initFunction(node, isAsync);
    if (params) this.setArrowFunctionParameters(node, params);

    const oldInGenerator = this.state.inGenerator;
    const oldMaybeInArrowParameters = this.state.maybeInArrowParameters;
    this.state.inGenerator = false;
    this.state.maybeInArrowParameters = false;
    this.parseFunctionBody(node, true);
    this.state.inGenerator = oldInGenerator;
    this.state.inFunction = oldInFunc;
    this.state.maybeInArrowParameters = oldMaybeInArrowParameters;

    return this.finishNode(node, "ArrowFunctionExpression");
  }

  setArrowFunctionParameters(
    node: N.ArrowFunctionExpression,
    params: N.Expression[],
  ): void {
    node.params = this.toAssignableList(
      params,
      true,
      "arrow function parameters",
    );
  }

  isStrictBody(node: { body: N.BlockStatement }): boolean {
    const isBlockStatement = node.body.type === "BlockStatement";

    if (isBlockStatement && node.body.directives.length) {
      for (const directive of node.body.directives) {
        if (directive.value.value === "use strict") {
          return true;
        }
      }
    }

    return false;
  }

  parseFunctionBodyAndFinish(
    node: N.BodilessFunctionOrMethodBase,
    type: string,
    allowExpressionBody?: boolean,
  ): void {
    // $FlowIgnore (node is not bodiless if we get here)
    this.parseFunctionBody(node, allowExpressionBody);
    this.finishNode(node, type);
  }

  // Parse function body and check parameters.
  parseFunctionBody(node: N.Function, allowExpression: ?boolean): void {
    const isExpression = allowExpression && !this.match(tt.braceL);

    const oldInParameters = this.state.inParameters;
    const oldInAsync = this.state.inAsync;
    this.state.inParameters = false;
    this.state.inAsync = node.async;

    if (isExpression) {
      node.body = this.parseMaybeAssign();
    } else {
      // Start a new scope with regard to labels and the `inGenerator`
      // flag (restore them to their old value afterwards).
      const oldInGen = this.state.inGenerator;
      const oldInFunc = this.state.inFunction;
      const oldLabels = this.state.labels;
      this.state.inGenerator = node.generator;
      this.state.inFunction = true;
      this.state.labels = [];
      node.body = this.parseBlock(true);
      this.state.inFunction = oldInFunc;
      this.state.inGenerator = oldInGen;
      this.state.labels = oldLabels;
    }
    this.state.inAsync = oldInAsync;

    this.checkFunctionNameAndParams(node, allowExpression);
    this.state.inParameters = oldInParameters;
  }

  checkFunctionNameAndParams(
    node: N.Function,
    isArrowFunction: ?boolean,
  ): void {
    // If this is a strict mode function, verify that argument names
    // are not repeated, and it does not try to bind the words `eval`
    // or `arguments`.
    const isStrict = this.isStrictBody(node);
    // Also check for arrow functions
    const checkLVal = this.state.strict || isStrict || isArrowFunction;

    const oldStrict = this.state.strict;
    if (isStrict) this.state.strict = isStrict;

    if (checkLVal) {
      const nameHash: any = Object.create(null);
      if (node.id) {
        this.checkLVal(node.id, true, undefined, "function name");
      }
      for (const param of node.params) {
        if (isStrict && param.type !== "Identifier") {
          this.raise(param.start, "Non-simple parameter in strict mode");
        }
        this.checkLVal(param, true, nameHash, "function parameter list");
      }
    }
    this.state.strict = oldStrict;
  }

  // Parses a comma-separated list of expressions, and returns them as
  // an array. `close` is the token type that ends the list, and
  // `allowEmpty` can be turned on to allow subsequent commas with
  // nothing in between them to be parsed as `null` (which is needed
  // for array literals).

  parseExprList(
    close: TokenType,
    allowEmpty?: boolean,
    refShorthandDefaultPos?: ?Pos,
  ): $ReadOnlyArray<?N.Expression> {
    const elts = [];
    let first = true;

    while (!this.eat(close)) {
      if (first) {
        first = false;
      } else {
        this.expect(tt.comma);
        if (this.eat(close)) break;
      }

      elts.push(this.parseExprListItem(allowEmpty, refShorthandDefaultPos));
    }
    return elts;
  }

  parseExprListItem(
    allowEmpty: ?boolean,
    refShorthandDefaultPos: ?Pos,
    refNeedsArrowPos: ?Pos,
    refTrailingCommaPos?: Pos,
  ): ?N.Expression {
    let elt;
    if (allowEmpty && this.match(tt.comma)) {
      elt = null;
    } else if (this.match(tt.ellipsis)) {
      const spreadNodeStartPos = this.state.start;
      const spreadNodeStartLoc = this.state.startLoc;
      elt = this.parseParenItem(
        this.parseSpread(refShorthandDefaultPos, refNeedsArrowPos),
        spreadNodeStartPos,
        spreadNodeStartLoc,
      );

      if (refTrailingCommaPos && this.match(tt.comma)) {
        refTrailingCommaPos.start = this.state.start;
      }
    } else {
      elt = this.parseMaybeAssign(
        false,
        refShorthandDefaultPos,
        this.parseParenItem,
        refNeedsArrowPos,
      );
    }
    return elt;
  }

  // Parse the next token as an identifier. If `liberal` is true (used
  // when parsing properties), it will also convert keywords into
  // identifiers.

  parseIdentifier(liberal?: boolean): N.Identifier {
    const node = this.startNode();
    const name = this.parseIdentifierName(node.start, liberal);
    node.name = name;
    node.loc.identifierName = name;
    return this.finishNode(node, "Identifier");
  }

  parseIdentifierName(pos: number, liberal?: boolean): string {
    if (!liberal) {
      this.checkReservedWord(
        this.state.value,
        this.state.start,
        !!this.state.type.keyword,
        false,
      );
    }

    let name: string;

    if (this.match(tt.name)) {
      name = this.state.value;
    } else if (this.state.type.keyword) {
      name = this.state.type.keyword;
    } else {
      throw this.unexpected();
    }

    if (!liberal && name === "await" && this.state.inAsync) {
      this.raise(pos, "invalid use of await inside of an async function");
    }

    this.next();
    return name;
  }

  checkReservedWord(
    word: string,
    startLoc: number,
    checkKeywords: boolean,
    isBinding: boolean,
  ): void {
    if (
      this.state.strict &&
      (reservedWords.strict(word) ||
        (isBinding && reservedWords.strictBind(word)))
    ) {
      this.raise(startLoc, word + " is a reserved word in strict mode");
    }

    if (this.state.inGenerator && word === "yield") {
      this.raise(
        startLoc,
        "yield is a reserved word inside generator functions",
      );
    }

    if (this.state.inClassProperty && word === "arguments") {
      this.raise(
        startLoc,
        "'arguments' is not allowed in class field initializer",
      );
    }

    if (this.isReservedWord(word) || (checkKeywords && this.isKeyword(word))) {
      this.raise(startLoc, word + " is a reserved word");
    }
  }

  // Parses await expression inside async function.

  parseAwait(node: N.AwaitExpression): N.AwaitExpression {
    // istanbul ignore next: this condition is checked at the call site so won't be hit here
    if (
      !this.state.inAsync &&
      (this.state.inFunction || !this.options.allowAwaitOutsideFunction)
    ) {
      this.unexpected();
    }
    if (this.match(tt.star)) {
      this.raise(
        node.start,
        "await* has been removed from the async functions proposal. Use Promise.all() instead.",
      );
    }
    node.argument = this.parseMaybeUnary();
    return this.finishNode(node, "AwaitExpression");
  }

  // Parses yield expression inside generator.

  parseYield(): N.YieldExpression {
    const node = this.startNode();

    if (this.state.inParameters) {
      this.raise(node.start, "yield is not allowed in generator parameters");
    }
    if (
      this.state.maybeInArrowParameters &&
      // We only set yieldInPossibleArrowParameters if we haven't already
      // found a possible invalid YieldExpression.
      !this.state.yieldInPossibleArrowParameters
    ) {
      this.state.yieldInPossibleArrowParameters = node;
    }

    this.next();
    if (
      this.match(tt.semi) ||
      this.canInsertSemicolon() ||
      (!this.match(tt.star) && !this.state.type.startsExpr)
    ) {
      node.delegate = false;
      node.argument = null;
    } else {
      node.delegate = this.eat(tt.star);
      node.argument = this.parseMaybeAssign();
    }
    return this.finishNode(node, "YieldExpression");
  }
}

// @flow

import type { Options } from "../options";
import type { File } from "../types";
import { getOptions } from "../options";
import StatementParser from "./statement";

export const plugins: {
  [name: string]: (superClass: Class<Parser>) => Class<Parser>,
} = {};

export default class Parser extends StatementParser {
  constructor(options: ?Options, input: string) {
    options = getOptions(options);
    super(options, input);

    this.options = options;
    this.inModule = this.options.sourceType === "module";
    this.input = input;
    this.plugins = pluginsMap(this.options.plugins);
    this.filename = options.sourceFilename;

    // If enabled, skip leading hashbang line.
    if (
      this.state.pos === 0 &&
      this.input[0] === "#" &&
      this.input[1] === "!"
    ) {
      this.skipLineComment(2);
    }
  }

  parse(): File {
    const file = this.startNode();
    const program = this.startNode();
    this.nextToken();
    return this.parseTopLevel(file, program);
  }
}

function pluginsMap(
  pluginList: $ReadOnlyArray<string>,
): { [key: string]: boolean } {
  const pluginMap = {};
  for (const name of pluginList) {
    pluginMap[name] = true;
  }
  return pluginMap;
}

// @flow

import { getLineInfo, type Position } from "../util/location";
import CommentsParser from "./comments";

// This function is used to raise exceptions on parse errors. It
// takes an offset integer (into the current `input`) to indicate
// the location of the error, attaches the position to the end
// of the error message, and then raises a `SyntaxError` with that
// message.

export default class LocationParser extends CommentsParser {
  raise(
    pos: number,
    message: string,
    {
      missingPluginNames,
      code,
    }: {
      missingPluginNames?: Array<string>,
      code?: string,
    } = {},
  ): empty {
    const loc = getLineInfo(this.input, pos);
    message += ` (${loc.line}:${loc.column})`;
    // $FlowIgnore
    const err: SyntaxError & { pos: number, loc: Position } = new SyntaxError(
      message,
    );
    err.pos = pos;
    err.loc = loc;
    if (missingPluginNames) {
      err.missingPlugin = missingPluginNames;
    }
    if (code !== undefined) {
      err.code = code;
    }
    throw err;
  }
}

// @flow

import { types as tt, type TokenType } from "../tokenizer/types";
import type {
  TSParameterProperty,
  Decorator,
  Expression,
  Identifier,
  Node,
  ObjectExpression,
  ObjectPattern,
  Pattern,
  RestElement,
  SpreadElement,
} from "../types";
import type { Pos, Position } from "../util/location";
import { NodeUtils } from "./node";

export default class LValParser extends NodeUtils {
  // Forward-declaration: defined in expression.js
  +checkReservedWord: (
    word: string,
    startLoc: number,
    checkKeywords: boolean,
    isBinding: boolean,
  ) => void;
  +parseIdentifier: (liberal?: boolean) => Identifier;
  +parseMaybeAssign: (
    noIn?: ?boolean,
    refShorthandDefaultPos?: ?Pos,
    afterLeftParse?: Function,
    refNeedsArrowPos?: ?Pos,
  ) => Expression;
  +parseObj: <T: ObjectPattern | ObjectExpression>(
    isPattern: boolean,
    refShorthandDefaultPos?: ?Pos,
  ) => T;
  // Forward-declaration: defined in statement.js
  +parseDecorator: () => Decorator;

  // Convert existing expression atom to assignable pattern
  // if possible.

  toAssignable(
    node: Node,
    isBinding: ?boolean,
    contextDescription: string,
  ): Node {
    if (node) {
      switch (node.type) {
        case "Identifier":
        case "ObjectPattern":
        case "ArrayPattern":
        case "AssignmentPattern":
          break;

        case "ObjectExpression":
          node.type = "ObjectPattern";
          for (let index = 0; index < node.properties.length; index++) {
            const prop = node.properties[index];
            const isLast = index === node.properties.length - 1;
            this.toAssignableObjectExpressionProp(prop, isBinding, isLast);
          }
          break;

        case "ObjectProperty":
          this.toAssignable(node.value, isBinding, contextDescription);
          break;

        case "SpreadElement": {
          this.checkToRestConversion(node);

          node.type = "RestElement";
          const arg = node.argument;
          this.toAssignable(arg, isBinding, contextDescription);
          break;
        }

        case "ArrayExpression":
          node.type = "ArrayPattern";
          this.toAssignableList(node.elements, isBinding, contextDescription);
          break;

        case "AssignmentExpression":
          if (node.operator === "=") {
            node.type = "AssignmentPattern";
            delete node.operator;
          } else {
            this.raise(
              node.left.end,
              "Only '=' operator can be used for specifying default value.",
            );
          }
          break;

        case "MemberExpression":
          if (!isBinding) break;

        default: {
          const message =
            "Invalid left-hand side" +
            (contextDescription
              ? " in " + contextDescription
              : /* istanbul ignore next */ "expression");
          this.raise(node.start, message);
        }
      }
    }
    return node;
  }

  toAssignableObjectExpressionProp(
    prop: Node,
    isBinding: ?boolean,
    isLast: boolean,
  ) {
    if (prop.type === "ObjectMethod") {
      const error =
        prop.kind === "get" || prop.kind === "set"
          ? "Object pattern can't contain getter or setter"
          : "Object pattern can't contain methods";

      this.raise(prop.key.start, error);
    } else if (prop.type === "SpreadElement" && !isLast) {
      this.raise(
        prop.start,
        "The rest element has to be the last element when destructuring",
      );
    } else {
      this.toAssignable(prop, isBinding, "object destructuring pattern");
    }
  }

  // Convert list of expression atoms to binding list.

  toAssignableList(
    exprList: Expression[],
    isBinding: ?boolean,
    contextDescription: string,
  ): $ReadOnlyArray<Pattern> {
    let end = exprList.length;
    if (end) {
      const last = exprList[end - 1];
      if (last && last.type === "RestElement") {
        --end;
      } else if (last && last.type === "SpreadElement") {
        last.type = "RestElement";
        const arg = last.argument;
        this.toAssignable(arg, isBinding, contextDescription);
        if (
          [
            "Identifier",
            "MemberExpression",
            "ArrayPattern",
            "ObjectPattern",
          ].indexOf(arg.type) === -1
        ) {
          this.unexpected(arg.start);
        }
        --end;
      }
    }
    for (let i = 0; i < end; i++) {
      const elt = exprList[i];
      if (elt && elt.type === "SpreadElement") {
        this.raise(
          elt.start,
          "The rest element has to be the last element when destructuring",
        );
      }
      if (elt) this.toAssignable(elt, isBinding, contextDescription);
    }
    return exprList;
  }

  // Convert list of expression atoms to a list of

  toReferencedList(
    exprList: $ReadOnlyArray<?Expression>,
  ): $ReadOnlyArray<?Expression> {
    return exprList;
  }

  // Parses spread element.

  parseSpread<T: RestElement | SpreadElement>(
    refShorthandDefaultPos: ?Pos,
    refNeedsArrowPos?: ?Pos,
  ): T {
    const node = this.startNode();
    this.next();
    node.argument = this.parseMaybeAssign(
      false,
      refShorthandDefaultPos,
      undefined,
      refNeedsArrowPos,
    );
    return this.finishNode(node, "SpreadElement");
  }

  parseRest(): RestElement {
    const node = this.startNode();
    this.next();
    node.argument = this.parseBindingAtom();
    return this.finishNode(node, "RestElement");
  }

  shouldAllowYieldIdentifier(): boolean {
    return (
      this.match(tt._yield) && !this.state.strict && !this.state.inGenerator
    );
  }

  parseBindingIdentifier(): Identifier {
    return this.parseIdentifier(this.shouldAllowYieldIdentifier());
  }

  // Parses lvalue (assignable) atom.
  parseBindingAtom(): Pattern {
    switch (this.state.type) {
      case tt._yield:
      case tt.name:
        return this.parseBindingIdentifier();

      case tt.bracketL: {
        const node = this.startNode();
        this.next();
        node.elements = this.parseBindingList(tt.bracketR, true);
        return this.finishNode(node, "ArrayPattern");
      }

      case tt.braceL:
        return this.parseObj(true);

      default:
        throw this.unexpected();
    }
  }

  parseBindingList(
    close: TokenType,
    allowEmpty?: boolean,
    allowModifiers?: boolean,
  ): $ReadOnlyArray<Pattern | TSParameterProperty> {
    const elts: Array<Pattern | TSParameterProperty> = [];
    let first = true;
    while (!this.eat(close)) {
      if (first) {
        first = false;
      } else {
        this.expect(tt.comma);
      }
      if (allowEmpty && this.match(tt.comma)) {
        // $FlowFixMe This method returns `$ReadOnlyArray<?Pattern>` if `allowEmpty` is set.
        elts.push(null);
      } else if (this.eat(close)) {
        break;
      } else if (this.match(tt.ellipsis)) {
        elts.push(this.parseAssignableListItemTypes(this.parseRest()));
        this.expect(close);
        break;
      } else {
        const decorators = [];
        if (this.match(tt.at) && this.hasPlugin("decorators2")) {
          this.raise(
            this.state.start,
            "Stage 2 decorators cannot be used to decorate parameters",
          );
        }
        while (this.match(tt.at)) {
          decorators.push(this.parseDecorator());
        }
        elts.push(this.parseAssignableListItem(allowModifiers, decorators));
      }
    }
    return elts;
  }

  parseAssignableListItem(
    allowModifiers: ?boolean,
    decorators: Decorator[],
  ): Pattern | TSParameterProperty {
    const left = this.parseMaybeDefault();
    this.parseAssignableListItemTypes(left);
    const elt = this.parseMaybeDefault(left.start, left.loc.start, left);
    ...
    return elt;
  }

  parseAssignableListItemTypes(param: Pattern): Pattern {
    return param;
  }

  // Parses assignment pattern around given atom if possible.

  parseMaybeDefault(
    startPos?: ?number,
    startLoc?: ?Position,
    left?: ?Pattern,
  ): Pattern {
    startLoc = startLoc || this.state.startLoc;
    startPos = startPos || this.state.start;
    left = left || this.parseBindingAtom();
    if (!this.eat(tt.eq)) return left;

    const node = this.startNodeAt(startPos, startLoc);
    node.left = left;
    node.right = this.parseMaybeAssign();
    return this.finishNode(node, "AssignmentPattern");
  }

  // Verify that a node is an lval — something that can be assigned
  // to.

  checkLVal(
    expr: Expression,
    isBinding: ?boolean,
    checkClashes: ?{ [key: string]: boolean },
    contextDescription: string,
  ): void {
    switch (expr.type) {
      case "Identifier":
        this.checkReservedWord(expr.name, expr.start, false, true);

        if (checkClashes) {
          // we need to prefix this with an underscore for the cases where we have a key of
          // `__proto__`. there's a bug in old V8 where the following wouldn't work:
          //
          //   > var obj = Object.create(null);
          //   undefined
          //   > obj.__proto__
          //   null
          //   > obj.__proto__ = true;
          //   true
          //   > obj.__proto__
          //   null
          const key = `_${expr.name}`;

          if (checkClashes[key]) {
            this.raise(expr.start, "Argument name clash in strict mode");
          } else {
            checkClashes[key] = true;
          }
        }
        break;

      case "MemberExpression":
        if (isBinding) this.raise(expr.start, "Binding member expression");
        break;

      case "ObjectPattern":
        for (let prop of expr.properties) {
          if (prop.type === "ObjectProperty") prop = prop.value;
          this.checkLVal(
            prop,
            isBinding,
            checkClashes,
            "object destructuring pattern",
          );
        }
        break;

      case "ArrayPattern":
        for (const elem of expr.elements) {
          if (elem) {
            this.checkLVal(
              elem,
              isBinding,
              checkClashes,
              "array destructuring pattern",
            );
          }
        }
        break;

      case "AssignmentPattern":
        this.checkLVal(
          expr.left,
          isBinding,
          checkClashes,
          "assignment pattern",
        );
        break;

      case "RestElement":
        this.checkLVal(expr.argument, isBinding, checkClashes, "rest element");
        break;

      default: {
        const message =
          (isBinding
            ? /* istanbul ignore next */ "Binding invalid"
            : "Invalid") +
          " left-hand side" +
          (contextDescription
            ? " in " + contextDescription
            : /* istanbul ignore next */ "expression");
        this.raise(expr.start, message);
      }
    }
  }

  checkToRestConversion(node: SpreadElement): void {
    const validArgumentTypes = ["Identifier", "MemberExpression"];

    if (validArgumentTypes.indexOf(node.argument.type) !== -1) {
      return;
    }

    this.raise(node.argument.start, "Invalid rest operator's argument");
  }
}

// @flow

import Parser from "./index";
import UtilParser from "./util";
import { SourceLocation, type Position } from "../util/location";
import type { Comment, Node as NodeType, NodeBase } from "../types";

// Start an AST node, attaching a start offset.

const commentKeys = ["leadingComments", "trailingComments", "innerComments"];

class Node implements NodeBase {
  constructor(parser: Parser, pos: number, loc: Position) {
    this.type = "";
    this.start = pos;
    this.end = 0;
    this.loc = new SourceLocation(loc);
    if (parser && parser.options.ranges) this.range = [pos, 0];
    if (parser && parser.filename) this.loc.filename = parser.filename;
  }

  type: string;
  start: number;
  end: number;
  loc: SourceLocation;
  range: [number, number];
  leadingComments: Array<Comment>;
  trailingComments: Array<Comment>;
  innerComments: Array<Comment>;
  extra: { [key: string]: any };

  __clone(): this {
    // $FlowIgnore
    const node2: any = new Node();
    Object.keys(this).forEach(key => {
      // Do not clone comments that are already attached to the node
      if (commentKeys.indexOf(key) < 0) {
        // $FlowIgnore
        node2[key] = this[key];
      }
    });

    return node2;
  }
}

export class NodeUtils extends UtilParser {
  startNode<T: NodeType>(): T {
    // $FlowIgnore
    return new Node(this, this.state.start, this.state.startLoc);
  }

  startNodeAt<T: NodeType>(pos: number, loc: Position): T {
    // $FlowIgnore
    return new Node(this, pos, loc);
  }

  /** Start a new node with a previous node's location. */
  startNodeAtNode<T: NodeType>(type: NodeType): T {
    return this.startNodeAt(type.start, type.loc.start);
  }

  // Finish an AST node, adding `type` and `end` properties.

  finishNode<T: NodeType>(node: T, type: string): T {
    return this.finishNodeAt(
      node,
      type,
      this.state.lastTokEnd,
      this.state.lastTokEndLoc,
    );
  }

  // Finish node at given position

  finishNodeAt<T: NodeType>(
    node: T,
    type: string,
    pos: number,
    loc: Position,
  ): T {
    node.type = type;
    node.end = pos;
    node.loc.end = loc;
    if (this.options.ranges) node.range[1] = pos;
    this.processComment(node);
    return node;
  }

  /**
   * Reset the start location of node to the start location of locationNode
   */
  resetStartLocationFromNode(node: NodeBase, locationNode: NodeBase): void {
    node.start = locationNode.start;
    node.loc.start = locationNode.loc.start;
    if (this.options.ranges) node.range[0] = locationNode.range[0];
  }
}

// @flow

import * as N from "../types";
import { types as tt, type TokenType } from "../tokenizer/types";
import ExpressionParser from "./expression";
import { lineBreak } from "../util/whitespace";

// Reused empty array added for node fields that are always empty.

const empty = [];

const loopLabel = { kind: "loop" },
  switchLabel = { kind: "switch" };

export default class StatementParser extends ExpressionParser {
  // ### Statement parsing

  // Parse a program. Initializes the parser, reads any number of
  // statements, and wraps them in a Program node.  Optionally takes a
  // `program` argument.  If present, the statements will be appended
  // to its body instead of creating a new node.

  parseTopLevel(file: N.File, program: N.Program): N.File {
    program.sourceType = this.options.sourceType;

    this.parseBlockBody(program, true, true, tt.eof);

    file.program = this.finishNode(program, "Program");
    file.comments = this.state.comments;

    if (this.options.tokens) file.tokens = this.state.tokens;

    return this.finishNode(file, "File");
  }

  // TODO

  stmtToDirective(stmt: N.Statement): N.Directive {
    const expr = stmt.expression;

    const directiveLiteral = this.startNodeAt(expr.start, expr.loc.start);
    const directive = this.startNodeAt(stmt.start, stmt.loc.start);

    const raw = this.input.slice(expr.start, expr.end);
    const val = (directiveLiteral.value = raw.slice(1, -1)); // remove quotes

    this.addExtra(directiveLiteral, "raw", raw);
    this.addExtra(directiveLiteral, "rawValue", val);

    directive.value = this.finishNodeAt(
      directiveLiteral,
      "DirectiveLiteral",
      expr.end,
      expr.loc.end,
    );

    return this.finishNodeAt(directive, "Directive", stmt.end, stmt.loc.end);
  }

  // Parse a single statement.
  //
  // If expecting a statement and finding a slash operator, parse a
  // regular expression literal. This is to handle cases like
  // `if (foo) /blah/.exec(foo)`, where looking at the previous token
  // does not help.

  parseStatement(declaration: boolean, topLevel?: boolean): N.Statement {
    if (this.match(tt.at)) {
      this.parseDecorators(true);
    }
    return this.parseStatementContent(declaration, topLevel);
  }

  parseStatementContent(declaration: boolean, topLevel: ?boolean): N.Statement {
    const starttype = this.state.type;
    const node = this.startNode();

    // Most types of statements are recognized by the keyword they
    // start with. Many are trivial to parse, some require a bit of
    // complexity.

    switch (starttype) {
      case tt._break:
      case tt._continue:
        // $FlowFixMe
        return this.parseBreakContinueStatement(node, starttype.keyword);
      case tt._debugger:
        return this.parseDebuggerStatement(node);
      case tt._do:
        return this.parseDoStatement(node);
      case tt._for:
        return this.parseForStatement(node);
      case tt._function:
        if (this.lookahead().type === tt.dot) break;
        if (!declaration) this.unexpected();
        return this.parseFunctionStatement(node);

      case tt._class:
        if (!declaration) this.unexpected();
        return this.parseClass(node, true);

      case tt._if:
        return this.parseIfStatement(node);
      case tt._return:
        return this.parseReturnStatement(node);
      case tt._switch:
        return this.parseSwitchStatement(node);
      case tt._throw:
        return this.parseThrowStatement(node);
      case tt._try:
        return this.parseTryStatement(node);

      case tt._let:
      case tt._const:
        if (!declaration) this.unexpected(); // NOTE: falls through to _var

      case tt._var:
        return this.parseVarStatement(node, starttype);

      case tt._while:
        return this.parseWhileStatement(node);
      case tt._with:
        return this.parseWithStatement(node);
      case tt.braceL:
        return this.parseBlock();
      case tt.semi:
        return this.parseEmptyStatement(node);
      case tt._export:
      case tt._import: {
        const nextToken = this.lookahead();
        if (nextToken.type === tt.parenL || nextToken.type === tt.dot) {
          break;
        }

        if (!this.options.allowImportExportEverywhere && !topLevel) {
          this.raise(
            this.state.start,
            "'import' and 'export' may only appear at the top level",
          );
        }

        this.next();

        let result;
        if (starttype == tt._import) {
          result = this.parseImport(node);

          if (
            result.type === "ImportDeclaration" &&
            (!result.importKind || result.importKind === "value")
          ) {
            this.sawUnambiguousESM = true;
          }
        } else {
          result = this.parseExport(node);

          if (
            (result.type === "ExportNamedDeclaration" &&
              (!result.exportKind || result.exportKind === "value")) ||
            (result.type === "ExportAllDeclaration" &&
              (!result.exportKind || result.exportKind === "value")) ||
            result.type === "ExportDefaultDeclaration"
          ) {
            this.sawUnambiguousESM = true;
          }
        }

        this.assertModuleNodeAllowed(node);

        return result;
      }
      case tt.name:
        if (this.isContextual("async")) {
          // peek ahead and see if next token is a function
          const state = this.state.clone();
          this.next();
          if (this.match(tt._function) && !this.canInsertSemicolon()) {
            this.expect(tt._function);
            return this.parseFunction(node, true, false, true);
          } else {
            this.state = state;
          }
        }
    }

    // If the statement does not start with a statement keyword or a
    // brace, it's an ExpressionStatement or LabeledStatement. We
    // simply start parsing an expression, and afterwards, if the
    // next token is a colon and the expression was a simple
    // Identifier node, we switch to interpreting it as a label.
    const maybeName = this.state.value;
    const expr = this.parseExpression();

    if (
      starttype === tt.name &&
      expr.type === "Identifier" &&
      this.eat(tt.colon)
    ) {
      return this.parseLabeledStatement(node, maybeName, expr);
    } else {
      return this.parseExpressionStatement(node, expr);
    }
  }

  assertModuleNodeAllowed(node: N.Node): void {
    if (!this.options.allowImportExportEverywhere && !this.inModule) {
      this.raise(
        node.start,
        `'import' and 'export' may appear only with 'sourceType: "module"'`,
        {
          code: "BABEL_PARSER_SOURCETYPE_MODULE_REQUIRED",
        },
      );
    }
  }

  takeDecorators(node: N.HasDecorators): void {
    const decorators = this.state.decoratorStack[
      this.state.decoratorStack.length - 1
    ];
    if (decorators.length) {
      node.decorators = decorators;
      this.resetStartLocationFromNode(node, decorators[0]);
      this.state.decoratorStack[this.state.decoratorStack.length - 1] = [];
    }
  }

  parseDecorators(allowExport?: boolean): void {
    if (this.hasPlugin("decorators2")) {
      allowExport = false;
    }

    const currentContextDecorators = this.state.decoratorStack[
      this.state.decoratorStack.length - 1
    ];
    while (this.match(tt.at)) {
      const decorator = this.parseDecorator();
      currentContextDecorators.push(decorator);
    }

    if (this.match(tt._export)) {
      if (allowExport) {
        return;
      } else {
        this.raise(
          this.state.start,
          "Using the export keyword between a decorator and a class is not allowed. " +
            "Please use `export @dec class` instead",
        );
      }
    }

    if (!this.match(tt._class)) {
      this.raise(
        this.state.start,
        "Leading decorators must be attached to a class declaration",
      );
    }
  }

  parseDecorator(): N.Decorator {
    this.expectOnePlugin(["decorators", "decorators2"]);

    const node = this.startNode();
    this.next();

    if (this.hasPlugin("decorators2")) {
      // Every time a decorator class expression is evaluated, a new empty array is pushed onto the stack
      // So that the decorators of any nested class expressions will be dealt with separately
      this.state.decoratorStack.push([]);

      if (this.eat(tt.parenL)) {
        node.callee = this.parseExpression();
        this.expect(tt.parenR);
      } else {
        const startPos = this.state.start;
        const startLoc = this.state.startLoc;
        let expr = this.parseIdentifier(false);

        while (this.eat(tt.dot)) {
          const node = this.startNodeAt(startPos, startLoc);
          node.object = expr;
          node.property = this.parseIdentifier(true);
          node.computed = false;
          expr = this.finishNode(node, "MemberExpression");
        }

        node.callee = expr;
      }

      if (this.eat(tt.parenL)) {
        node.arguments = this.parseCallExpressionArguments(tt.parenR, false);
        this.toReferencedList(node.arguments);
      }

      this.state.decoratorStack.pop();
    } else {
      node.callee = this.parseMaybeAssign();
    }
    return this.finishNode(node, "Decorator");
  }

  parseBreakContinueStatement(
    node: N.BreakStatement | N.ContinueStatement,
    keyword: string,
  ): N.BreakStatement | N.ContinueStatement {
    const isBreak = keyword === "break";
    this.next();

    if (this.isLineTerminator()) {
      node.label = null;
    } else if (!this.match(tt.name)) {
      this.unexpected();
    } else {
      node.label = this.parseIdentifier();
      this.semicolon();
    }

    // Verify that there is an actual destination to break or
    // continue to.
    let i;
    for (i = 0; i < this.state.labels.length; ++i) {
      const lab = this.state.labels[i];
      if (node.label == null || lab.name === node.label.name) {
        if (lab.kind != null && (isBreak || lab.kind === "loop")) break;
        if (node.label && isBreak) break;
      }
    }
    if (i === this.state.labels.length) {
      this.raise(node.start, "Unsyntactic " + keyword);
    }
    return this.finishNode(
      node,
      isBreak ? "BreakStatement" : "ContinueStatement",
    );
  }

  parseDebuggerStatement(node: N.DebuggerStatement): N.DebuggerStatement {
    this.next();
    this.semicolon();
    return this.finishNode(node, "DebuggerStatement");
  }

  parseDoStatement(node: N.DoWhileStatement): N.DoWhileStatement {
    this.next();
    this.state.labels.push(loopLabel);
    node.body = this.parseStatement(false);
    this.state.labels.pop();
    this.expect(tt._while);
    node.test = this.parseParenExpression();
    this.eat(tt.semi);
    return this.finishNode(node, "DoWhileStatement");
  }

  // Disambiguating between a `for` and a `for`/`in` or `for`/`of`
  // loop is non-trivial. Basically, we have to parse the init `var`
  // statement or expression, disallowing the `in` operator (see
  // the second parameter to `parseExpression`), and then check
  // whether the next token is `in` or `of`. When there is no init
  // part (semicolon immediately after the opening parenthesis), it
  // is a regular `for` loop.

  parseForStatement(node: N.Node): N.ForLike {
    this.next();
    this.state.labels.push(loopLabel);

    let forAwait = false;
    if (this.state.inAsync && this.isContextual("await")) {
      this.expectPlugin("asyncGenerators");
      forAwait = true;
      this.next();
    }
    this.expect(tt.parenL);

    if (this.match(tt.semi)) {
      if (forAwait) {
        this.unexpected();
      }
      return this.parseFor(node, null);
    }

    if (this.match(tt._var) || this.match(tt._let) || this.match(tt._const)) {
      const init = this.startNode();
      const varKind = this.state.type;
      this.next();
      this.parseVar(init, true, varKind);
      this.finishNode(init, "VariableDeclaration");

      if (this.match(tt._in) || this.isContextual("of")) {
        if (init.declarations.length === 1) {
          const declaration = init.declarations[0];
          const isForInInitializer =
            varKind === tt._var &&
            declaration.init &&
            declaration.id.type != "ObjectPattern" &&
            declaration.id.type != "ArrayPattern" &&
            !this.isContextual("of");
          if (this.state.strict && isForInInitializer) {
            this.raise(this.state.start, "for-in initializer in strict mode");
          } else if (isForInInitializer || !declaration.init) {
            return this.parseForIn(node, init, forAwait);
          }
        }
      }
      if (forAwait) {
        this.unexpected();
      }
      return this.parseFor(node, init);
    }

    const refShorthandDefaultPos = { start: 0 };
    const init = this.parseExpression(true, refShorthandDefaultPos);
    if (this.match(tt._in) || this.isContextual("of")) {
      const description = this.isContextual("of")
        ? "for-of statement"
        : "for-in statement";
      this.toAssignable(init, undefined, description);
      this.checkLVal(init, undefined, undefined, description);
      return this.parseForIn(node, init, forAwait);
    } else if (refShorthandDefaultPos.start) {
      this.unexpected(refShorthandDefaultPos.start);
    }
    if (forAwait) {
      this.unexpected();
    }
    return this.parseFor(node, init);
  }

  parseFunctionStatement(node: N.FunctionDeclaration): N.FunctionDeclaration {
    this.next();
    return this.parseFunction(node, true);
  }

  parseIfStatement(node: N.IfStatement): N.IfStatement {
    this.next();
    node.test = this.parseParenExpression();
    node.consequent = this.parseStatement(false);
    node.alternate = this.eat(tt._else) ? this.parseStatement(false) : null;
    return this.finishNode(node, "IfStatement");
  }

  parseReturnStatement(node: N.ReturnStatement): N.ReturnStatement {
    if (!this.state.inFunction && !this.options.allowReturnOutsideFunction) {
      this.raise(this.state.start, "'return' outside of function");
    }

    this.next();

    // In `return` (and `break`/`continue`), the keywords with
    // optional arguments, we eagerly look for a semicolon or the
    // possibility to insert one.

    if (this.isLineTerminator()) {
      node.argument = null;
    } else {
      node.argument = this.parseExpression();
      this.semicolon();
    }

    return this.finishNode(node, "ReturnStatement");
  }

  parseSwitchStatement(node: N.SwitchStatement): N.SwitchStatement {
    this.next();
    node.discriminant = this.parseParenExpression();
    const cases = (node.cases = []);
    this.expect(tt.braceL);
    this.state.labels.push(switchLabel);

    // Statements under must be grouped (by label) in SwitchCase
    // nodes. `cur` is used to keep the node that we are currently
    // adding statements to.

    let cur;
    for (let sawDefault; !this.match(tt.braceR); ) {
      if (this.match(tt._case) || this.match(tt._default)) {
        const isCase = this.match(tt._case);
        if (cur) this.finishNode(cur, "SwitchCase");
        cases.push((cur = this.startNode()));
        cur.consequent = [];
        this.next();
        if (isCase) {
          cur.test = this.parseExpression();
        } else {
          if (sawDefault) {
            this.raise(this.state.lastTokStart, "Multiple default clauses");
          }
          sawDefault = true;
          cur.test = null;
        }
        this.expect(tt.colon);
      } else {
        if (cur) {
          cur.consequent.push(this.parseStatement(true));
        } else {
          this.unexpected();
        }
      }
    }
    if (cur) this.finishNode(cur, "SwitchCase");
    this.next(); // Closing brace
    this.state.labels.pop();
    return this.finishNode(node, "SwitchStatement");
  }

  parseThrowStatement(node: N.ThrowStatement): N.ThrowStatement {
    this.next();
    if (
      lineBreak.test(this.input.slice(this.state.lastTokEnd, this.state.start))
    ) {
      this.raise(this.state.lastTokEnd, "Illegal newline after throw");
    }
    node.argument = this.parseExpression();
    this.semicolon();
    return this.finishNode(node, "ThrowStatement");
  }

  parseTryStatement(node: N.TryStatement): N.TryStatement {
    this.next();

    node.block = this.parseBlock();
    node.handler = null;

    if (this.match(tt._catch)) {
      const clause = this.startNode();
      this.next();
      if (this.match(tt.parenL)) {
        this.expect(tt.parenL);
        clause.param = this.parseBindingAtom();
        const clashes: any = Object.create(null);
        this.checkLVal(clause.param, true, clashes, "catch clause");
        this.expect(tt.parenR);
      } else {
        this.expectPlugin("optionalCatchBinding");
        clause.param = null;
      }
      clause.body = this.parseBlock();
      node.handler = this.finishNode(clause, "CatchClause");
    }

    node.guardedHandlers = empty;
    node.finalizer = this.eat(tt._finally) ? this.parseBlock() : null;

    if (!node.handler && !node.finalizer) {
      this.raise(node.start, "Missing catch or finally clause");
    }

    return this.finishNode(node, "TryStatement");
  }

  parseVarStatement(
    node: N.VariableDeclaration,
    kind: TokenType,
  ): N.VariableDeclaration {
    this.next();
    this.parseVar(node, false, kind);
    this.semicolon();
    return this.finishNode(node, "VariableDeclaration");
  }

  parseWhileStatement(node: N.WhileStatement): N.WhileStatement {
    this.next();
    node.test = this.parseParenExpression();
    this.state.labels.push(loopLabel);
    node.body = this.parseStatement(false);
    this.state.labels.pop();
    return this.finishNode(node, "WhileStatement");
  }

  parseWithStatement(node: N.WithStatement): N.WithStatement {
    if (this.state.strict) {
      this.raise(this.state.start, "'with' in strict mode");
    }
    this.next();
    node.object = this.parseParenExpression();
    node.body = this.parseStatement(false);
    return this.finishNode(node, "WithStatement");
  }

  parseEmptyStatement(node: N.EmptyStatement): N.EmptyStatement {
    this.next();
    return this.finishNode(node, "EmptyStatement");
  }

  parseLabeledStatement(
    node: N.LabeledStatement,
    maybeName: string,
    expr: N.Identifier,
  ): N.LabeledStatement {
    for (const label of this.state.labels) {
      if (label.name === maybeName) {
        this.raise(expr.start, `Label '${maybeName}' is already declared`);
      }
    }

    const kind = this.state.type.isLoop
      ? "loop"
      : this.match(tt._switch) ? "switch" : null;
    for (let i = this.state.labels.length - 1; i >= 0; i--) {
      const label = this.state.labels[i];
      if (label.statementStart === node.start) {
          .statementStart = this.state.start;
        label.kind = kind;
      } else {
        break;
      }
    }

    this.state.labels.push({
      name: maybeName,
      kind: kind,
      statementStart: this.state.start,
    });
    node.body = this.parseStatement(true);

    if (
      node.body.type == "ClassDeclaration" ||
      (node.body.type == "VariableDeclaration" && node.body.kind !== "var") ||
      (node.body.type == "FunctionDeclaration" &&
        (this.state.strict || node.body.generator || node.body.async))
    ) {
      this.raise(node.body.start, "Invalid labeled declaration");
    }

    this.state.labels.pop();
    node.label = expr;
    return this.finishNode(node, "LabeledStatement");
  }

  parseExpressionStatement(
    node: N.ExpressionStatement,
    expr: N.Expression,
  ): N.ExpressionStatement {
    node.expression = expr;
    this.semicolon();
    return this.finishNode(node, "ExpressionStatement");
  }

  // Parse a semicolon-enclosed block of statements, handling `"use
  // strict"` declarations when `allowStrict` is true (used for
  // function bodies).

  parseBlock(allowDirectives?: boolean): N.BlockStatement {
    const node = this.startNode();
    this.expect(tt.braceL);
    this.parseBlockBody(node, allowDirectives, false, tt.braceR);
    return this.finishNode(node, "BlockStatement");
  }

  isValidDirective(stmt: N.Statement): boolean {
    return (
      stmt.type === "ExpressionStatement" &&
      stmt.expression.type === "StringLiteral" &&
      !stmt.expression.extra.parenthesized
    );
  }

  parseBlockBody(
    node: N.BlockStatementLike,
    allowDirectives: ?boolean,
    topLevel: boolean,
    end: TokenType,
  ): void {
    const body = (node.body = []);
    const directives = (node.directives = []);
    this.parseBlockOrModuleBlockBody(
      body,
      allowDirectives ? directives : undefined,
      topLevel,
      end,
    );
  }

  // Undefined directives means that directives are not allowed.
  parseBlockOrModuleBlockBody(
    body: N.Statement[],
    directives: ?(N.Directive[]),
    topLevel: boolean,
    end: TokenType,
  ): void {
    let parsedNonDirective = false;
    let oldStrict;
    let octalPosition;

    while (!this.eat(end)) {
      if (!parsedNonDirective && this.state.containsOctal && !octalPosition) {
        octalPosition = this.state.octalPosition;
      }

      const stmt = this.parseStatement(true, topLevel);

      if (directives && !parsedNonDirective && this.isValidDirective(stmt)) {
        const directive = this.stmtToDirective(stmt);
        directives.push(directive);

        if (oldStrict === undefined && directive.value.value === "use strict") {
          oldStrict = this.state.strict;
          this.setStrict(true);

          if (octalPosition) {
            this.raise(octalPosition, "Octal literal in strict mode");
          }
        }

        continue;
      }

      parsedNonDirective = true;
      body.push(stmt);
    }

    if (oldStrict === false) {
      this.setStrict(false);
    }
  }

  // Parse a regular `for` loop. The disambiguation code in
  // `parseStatement` will already have parsed the init statement or
  // expression.

  parseFor(
    node: N.ForStatement,
    init: ?(N.VariableDeclaration | N.Expression),
  ): N.ForStatement {
    node.init = init;
    this.expect(tt.semi);
    node.test = this.match(tt.semi) ? null : this.parseExpression();
    this.expect(tt.semi);
    node.update = this.match(tt.parenR) ? null : this.parseExpression();
    this.expect(tt.parenR);
    node.body = this.parseStatement(false);
    this.state.labels.pop();
    return this.finishNode(node, "ForStatement");
  }

  // Parse a `for`/`in` and `for`/`of` loop, which are almost
  // same from parser's perspective.

  parseForIn(
    node: N.ForInOf,
    init: N.VariableDeclaration,
    forAwait: boolean,
  ): N.ForInOf {
    const type = this.match(tt._in) ? "ForInStatement" : "ForOfStatement";
    if (forAwait) {
      this.eatContextual("of");
    } else {
      this.next();
    }
    if (type === "ForOfStatement") {
      node.await = !!forAwait;
    }
    node.left = init;
    node.right = this.parseExpression();
    this.expect(tt.parenR);
    node.body = this.parseStatement(false);
    this.state.labels.pop();
    return this.finishNode(node, type);
  }

  // Parse a list of variable declarations.

  parseVar(
    node: N.VariableDeclaration,
    isFor: boolean,
    kind: TokenType,
  ): N.VariableDeclaration {
    const declarations = (node.declarations = []);
    // $FlowFixMe
    node.kind = kind.keyword;
    for (;;) {
      const decl = this.startNode();
      this.parseVarHead(decl);
      if (this.eat(tt.eq)) {
        decl.init = this.parseMaybeAssign(isFor);
      } else {
        if (
          kind === tt._const &&
          !(this.match(tt._in) || this.isContextual("of"))
        ) {
          // `const` with no initializer is allowed in TypeScript.
          // It could be a declaration like `const x: number;`.
          if (!this.hasPlugin("typescript")) {
            this.unexpected();
          }
        } else if (
          decl.id.type !== "Identifier" &&
          !(isFor && (this.match(tt._in) || this.isContextual("of")))
        ) {
          this.raise(
            this.state.lastTokEnd,
            "Complex binding patterns require an initialization value",
          );
        }
        decl.init = null;
      }
      declarations.push(this.finishNode(decl, "VariableDeclarator"));
      if (!this.eat(tt.comma)) break;
    }
    return node;
  }

  parseVarHead(decl: N.VariableDeclarator): void {
    decl.id = this.parseBindingAtom();
    this.checkLVal(decl.id, true, undefined, "variable declaration");
  }

  // Parse a function declaration or literal (depending on the
  // `isStatement` parameter).

  parseFunction<T: N.NormalFunction>(
    node: T,
    isStatement: boolean,
    allowExpressionBody?: boolean,
    isAsync?: boolean,
    optionalId?: boolean,
  ): T {
    const oldInFunc = this.state.inFunction;
    const oldInMethod = this.state.inMethod;
    const oldInGenerator = this.state.inGenerator;
    const oldInClassProperty = this.state.inClassProperty;
    this.state.inFunction = true;
    this.state.inMethod = false;
    this.state.inClassProperty = false;

    this.initFunction(node, isAsync);

    if (this.match(tt.star)) {
      if (node.async) {
        this.expectPlugin("asyncGenerators");
      }
      node.generator = true;
      this.next();
    }

    if (
      isStatement &&
      !optionalId &&
      !this.match(tt.name) &&
      !this.match(tt._yield)
    ) {
      this.unexpected();
    }

    // When parsing function expression, the binding identifier is parsed
    // according to the rules inside the function.
    // e.g. (function* yield() {}) is invalid because "yield" is disallowed in
    // generators.
    // This isn't the case with function declarations: function* yield() {} is
    // valid because yield is parsed as if it was outside the generator.
    // Therefore, this.state.inGenerator is set before or after parsing the
    // function id according to the "isStatement" parameter.
    if (!isStatement) this.state.inGenerator = node.generator;
    if (this.match(tt.name) || this.match(tt._yield)) {
      node.id = this.parseBindingIdentifier();
    }
    if (isStatement) this.state.inGenerator = node.generator;

    this.parseFunctionParams(node);
    this.parseFunctionBodyAndFinish(
      node,
      isStatement ? "FunctionDeclaration" : "FunctionExpression",
      allowExpressionBody,
    );

    this.state.inFunction = oldInFunc;
    this.state.inMethod = oldInMethod;
    this.state.inGenerator = oldInGenerator;
    this.state.inClassProperty = oldInClassProperty;

    return node;
  }

  parseFunctionParams(node: N.Function, allowModifiers?: boolean): void {
    const oldInParameters = this.state.inParameters;
    this.state.inParameters = true;

    this.expect(tt.parenL);
    node.params = this.parseBindingList(
      tt.parenR,
      /* allowEmpty */ false,
      allowModifiers,
    );

    this.state.inParameters = oldInParameters;
  }

  // Parse a class declaration or literal (depending on the
  // `isStatement` parameter).

  parseClass<T: N.Class>(
    node: T,
    isStatement: /* T === ClassDeclaration */ boolean,
    optionalId?: boolean,
  ): T {
    this.next();
    this.takeDecorators(node);
    this.parseClassId(node, isStatement, optionalId);
    this.parseClassSuper(node);
    this.parseClassBody(node);
    return this.finishNode(
      node,
      isStatement ? "ClassDeclaration" : "ClassExpression",
    );
  }

  isClassProperty(): boolean {
    return this.match(tt.eq) || this.match(tt.semi) || this.match(tt.braceR);
  }

  isClassMethod(): boolean {
    return this.match(tt.parenL);
  }

  isNonstaticConstructor(method: N.ClassMethod | N.ClassProperty): boolean {
    return (
      !method.computed &&
      !method.static &&
      (method.key.name === "constructor" || // Identifier
        method.key.value === "constructor") // String literal
    );
  }

  parseClassBody(node: N.Class): void {
    // class bodies are implicitly strict
    const oldStrict = this.state.strict;
    this.state.strict = true;
    this.state.classLevel++;

    const state = { hadConstructor: false };
    let decorators: N.Decorator[] = [];
    const classBody: N.ClassBody = this.startNode();

    classBody.body = [];

    this.expect(tt.braceL);

    while (!this.eat(tt.braceR)) {
      if (this.eat(tt.semi)) {
        if (decorators.length > 0) {
          this.raise(
            this.state.lastTokEnd,
            "Decorators must not be followed by a semicolon",
          );
        }
        continue;
      }

      if (this.match(tt.at)) {
        decorators.push(this.parseDecorator());
        continue;
      }

      const member = this.startNode();

      // steal the decorators if there are any
      if (decorators.length) {
        member.decorators = decorators;
        this.resetStartLocationFromNode(member, decorators[0]);
        decorators = [];
      }

      this.parseClassMember(classBody, member, state);

      if (
        member.kind === "constructor" &&
        member.decorators &&
        member.decorators.length > 0
      ) {
        this.raise(
          member.start,
          "Decorators can't be used with a constructor. Did you mean '@dec class { ... }'?",
        );
      }
    }

    if (decorators.length) {
      this.raise(
        this.state.start,
        "You have trailing decorators with no method",
      );
    }

    node.body = this.finishNode(classBody, "ClassBody");

    this.state.classLevel--;
    this.state.strict = oldStrict;
  }

  parseClassMember(
    classBody: N.ClassBody,
    member: N.ClassMember,
    state: { hadConstructor: boolean },
  ): void {
    let isStatic = false;
    const containsEsc = this.state.containsEsc;

    if (this.match(tt.name) && this.state.value === "static") {
      const key = this.parseIdentifier(true); // eats 'static'

      if (this.isClassMethod()) {
        const method: N.ClassMethod = (member: any);

        // a method named 'static'
        method.kind = "method";
        method.computed = false;
        method.key = key;
        method.static = false;
        this.pushClassMethod(
          classBody,
          method,
          false,
          false,
          /* isConstructor */ false,
        );
        return;
      } else if (this.isClassProperty()) {
        const prop: N.ClassProperty = (member: any);

        // a property named 'static'
        prop.computed = false;
        prop.key = key;
        prop.static = false;
        classBody.body.push(this.parseClassProperty(prop));
        return;
      } else if (containsEsc) {
        throw this.unexpected();
      }

      // otherwise something static
      isStatic = true;
    }

    this.parseClassMemberWithIsStatic(classBody, member, state, isStatic);
  }

  parseClassMemberWithIsStatic(
    classBody: N.ClassBody,
    member: N.ClassMember,
    state: { hadConstructor: boolean },
    isStatic: boolean,
  ) {
    const publicMethod: $FlowSubtype<N.ClassMethod> = member;
    const privateMethod: $FlowSubtype<N.ClassPrivateMethod> = member;
    const publicProp: $FlowSubtype<N.ClassMethod> = member;
    const privateProp: $FlowSubtype<N.ClassPrivateMethod> = member;

    const method: typeof publicMethod | typeof privateMethod = publicMethod;
    const publicMember: typeof publicMethod | typeof publicProp = publicMethod;

    member.static = isStatic;

    if (this.eat(tt.star)) {
      // a generator
      method.kind = "method";
      this.parseClassPropertyName(method);

      if (method.key.type === "PrivateName") {
        // Private generator method
        this.pushClassPrivateMethod(classBody, privateMethod, true, false);
        return;
      }

      if (this.isNonstaticConstructor(publicMethod)) {
        this.raise(publicMethod.key.start, "Constructor can't be a generator");
      }

      this.pushClassMethod(
        classBody,
        publicMethod,
        true,
        false,
        /* isConstructor */ false,
      );

      return;
    }

    const key = this.parseClassPropertyName(member);
    const isPrivate = key.type === "PrivateName";
    // Check the key is not a computed expression or string literal.
    const isSimple = key.type === "Identifier";

    this.parsePostMemberNameModifiers(publicMember);

    if (this.isClassMethod()) {
      method.kind = "method";

      if (isPrivate) {
        this.pushClassPrivateMethod(classBody, privateMethod, false, false);
        return;
      }

      // a normal method
      const isConstructor = this.isNonstaticConstructor(publicMethod);

      if (isConstructor) {
        publicMethod.kind = "constructor";

        if (publicMethod.decorators) {
          this.raise(
            publicMethod.start,
            "You can't attach decorators to a class constructor",
          );
        }

        // TypeScript allows multiple overloaded constructor declarations.
        if (state.hadConstructor && !this.hasPlugin("typescript")) {
          this.raise(key.start, "Duplicate constructor in the same class");
        }
        state.hadConstructor = true;
      }

      this.pushClassMethod(
        classBody,
        publicMethod,
        false,
        false,
        isConstructor,
      );
    } else if (this.isClassProperty()) {
      if (isPrivate) {
        this.pushClassPrivateProperty(classBody, privateProp);
      } else {
        this.pushClassProperty(classBody, publicProp);
      }
    } else if (isSimple && key.name === "async" && !this.isLineTerminator()) {
      // an async method
      const isGenerator = this.match(tt.star);
      if (isGenerator) {
        this.expectPlugin("asyncGenerators");
        this.next();
      }

      method.kind = "method";
      // The so-called parsed name would have been "async": get the real name.
      this.parseClassPropertyName(method);

      if (method.key.type === "PrivateName") {
        // private async method
        this.pushClassPrivateMethod(
          classBody,
          privateMethod,
          isGenerator,
          true,
        );
      } else {
        if (this.isNonstaticConstructor(publicMethod)) {
          this.raise(
            publicMethod.key.start,
            "Constructor can't be an async function",
          );
        }

        this.pushClassMethod(
          classBody,
          publicMethod,
          isGenerator,
          true,
          /* isConstructor */ false,
        );
      }
    } else if (
      isSimple &&
      (key.name === "get" || key.name === "set") &&
      !(this.isLineTerminator() && this.match(tt.star))
    ) {
      // `get\n*` is an uninitialized property named 'get' followed by a generator.
      // a getter or setter
      method.kind = key.name;
      // The so-called parsed name would have been "get/set": get the real name.
      this.parseClassPropertyName(publicMethod);

      if (method.key.type === "PrivateName") {
        // private getter/setter
        this.pushClassPrivateMethod(classBody, privateMethod, false, false);
      } else {
        if (this.isNonstaticConstructor(publicMethod)) {
          this.raise(
            publicMethod.key.start,
            "Constructor can't have get/set modifier",
          );
        }
        this.pushClassMethod(
          classBody,
          publicMethod,
          false,
          false,
          /* isConstructor */ false,
        );
      }

      this.checkGetterSetterParams(publicMethod);
    } else if (this.isLineTerminator()) {
      // an uninitialized class property (due to ASI, since we don't otherwise recognize the next token)
      if (isPrivate) {
        this.pushClassPrivateProperty(classBody, privateProp);
      } else {
        this.pushClassProperty(classBody, publicProp);
      }
    } else {
      this.unexpected();
    }
  }

  parseClassPropertyName(member: N.ClassMember): N.Expression | N.Identifier {
    const key = this.parsePropertyName(member);

    if (
      !member.computed &&
      member.static &&
      ((key: $FlowSubtype<N.Identifier>).name === "prototype" ||
        (key: $FlowSubtype<N.StringLiteral>).value === "prototype")
    ) {
      this.raise(
        key.start,
        "Classes may not have static property named prototype",
      );
    }

    if (key.type === "PrivateName" && key.id.name === "constructor") {
      this.raise(
        key.start,
        "Classes may not have a private field named '#constructor'",
      );
    }

    return key;
  }

  pushClassProperty(classBody: N.ClassBody, prop: N.ClassProperty) {
    // This only affects properties, not methods.
    if (this.isNonstaticConstructor(prop)) {
      this.raise(
        prop.key.start,
        "Classes may not have a non-static field named 'constructor'",
      );
    }
    classBody.body.push(this.parseClassProperty(prop));
  }

  pushClassPrivateProperty(
    classBody: N.ClassBody,
    prop: N.ClassPrivateProperty,
  ) {
    this.expectPlugin("classPrivateProperties", prop.key.start);
    classBody.body.push(this.parseClassPrivateProperty(prop));
  }

  pushClassMethod(
    classBody: N.ClassBody,
    method: N.ClassMethod,
    isGenerator: boolean,
    isAsync: boolean,
    isConstructor: boolean,
  ): void {
    classBody.body.push(
      this.parseMethod(
        method,
        isGenerator,
        isAsync,
        isConstructor,
        "ClassMethod",
      ),
    );
  }

  pushClassPrivateMethod(
    classBody: N.ClassBody,
    method: N.ClassPrivateMethod,
    isGenerator: boolean,
    isAsync: boolean,
  ): void {
    this.expectPlugin("classPrivateMethods", method.key.start);
    classBody.body.push(
      this.parseMethod(
        method,
        isGenerator,
        isAsync,
        /* isConstructor */ false,
        "ClassPrivateMethod",
      ),
    );
  }

  // Overridden in typescript.js
  parsePostMemberNameModifiers(
    // eslint-disable-next-line no-unused-vars
    methodOrProp: N.ClassMethod | N.ClassProperty,
  ): void {}

  // Overridden in typescript.js
  parseAccessModifier(): ?N.Accessibility {
    return undefined;
  }

  parseClassPrivateProperty(
    node: N.ClassPrivateProperty,
  ): N.ClassPrivateProperty {
    const oldInMethod = this.state.inMethod;
    this.state.inMethod = false;
    this.state.inClassProperty = true;
    node.value = this.eat(tt.eq) ? this.parseMaybeAssign() : null;
    this.semicolon();
    this.state.inClassProperty = false;
    this.state.inMethod = oldInMethod;
    return this.finishNode(node, "ClassPrivateProperty");
  }

  parseClassProperty(node: N.ClassProperty): N.ClassProperty {
    if (!node.typeAnnotation) {
      this.expectPlugin("classProperties");
    }

    const oldInMethod = this.state.inMethod;
    this.state.inMethod = false;
    this.state.inClassProperty = true;

    if (this.match(tt.eq)) {
      this.expectPlugin("classProperties");
      this.next();
      node.value = this.parseMaybeAssign();
    } else {
      node.value = null;
    }
    this.semicolon();
    this.state.inClassProperty = false;
    this.state.inMethod = oldInMethod;

    return this.finishNode(node, "ClassProperty");
  }

  parseClassId(
    node: N.Class,
    isStatement: boolean,
    optionalId: ?boolean,
  ): void {
    if (this.match(tt.name)) {
      node.id = this.parseIdentifier();
    } else {
      if (optionalId || !isStatement) {
        node.id = null;
      } else {
        this.unexpected(null, "A class name is required");
      }
    }
  }

  parseClassSuper(node: N.Class): void {
    node.superClass = this.eat(tt._extends) ? this.parseExprSubscripts() : null;
  }

  // Parses module export declaration.

  // TODO: better type. Node is an N.AnyExport.
  parseExport(node: N.Node): N.Node {
    // export * from '...'
    if (this.shouldParseExportStar()) {
      this.parseExportStar(node);
      if (node.type === "ExportAllDeclaration") return node;
    } else if (this.isExportDefaultSpecifier()) {
      this.expectPlugin("exportDefaultFrom");
      const specifier = this.startNode();
      specifier.exported = this.parseIdentifier(true);
      const specifiers = [this.finishNode(specifier, "ExportDefaultSpecifier")];
      node.specifiers = specifiers;
      if (this.match(tt.comma) && this.lookahead().type === tt.star) {
        this.expect(tt.comma);
        const specifier = this.startNode();
        this.expect(tt.star);
        this.expectContextual("as");
        specifier.exported = this.parseIdentifier();
        specifiers.push(this.finishNode(specifier, "ExportNamespaceSpecifier"));
      } else {
        this.parseExportSpecifiersMaybe(node);
      }
      this.parseExportFrom(node, true);
    } else if (this.eat(tt._default)) {
      // export default ...
      node.declaration = this.parseExportDefaultExpression();
      this.checkExport(node, true, true);
      return this.finishNode(node, "ExportDefaultDeclaration");
    } else if (this.shouldParseExportDeclaration()) {
      if (this.isContextual("async")) {
        const next = this.lookahead();

        // export async;
        if (next.type !== tt._function) {
          this.unexpected(next.start, `Unexpected token, expected "function"`);
        }
      }

      node.specifiers = [];
      node.source = null;
      node.declaration = this.parseExportDeclaration(node);
    } else {
      // export { x, y as z } [from '...']
      node.declaration = null;
      node.specifiers = this.parseExportSpecifiers();
      this.parseExportFrom(node);
    }
    this.checkExport(node, true);
    return this.finishNode(node, "ExportNamedDeclaration");
  }

  parseExportDefaultExpression(): N.Expression | N.Declaration {
    const expr = this.startNode();
    if (this.eat(tt._function)) {
      return this.parseFunction(expr, true, false, false, true);
    } else if (
      this.isContextual("async") &&
      this.lookahead().type === tt._function
    ) {
      // async function declaration
      this.eatContextual("async");
      this.eat(tt._function);
      return this.parseFunction(expr, true, false, true, true);
    } else if (this.match(tt._class)) {
      return this.parseClass(expr, true, true);
    } else if (this.match(tt.at)) {
      this.parseDecorators(false);
      return this.parseClass(expr, true, true);
    } else if (
      this.match(tt._let) ||
      this.match(tt._const) ||
      this.match(tt._var)
    ) {
      return this.raise(
        this.state.start,
        "Only expressions, functions or classes are allowed as the `default` export.",
      );
    } else {
      const res = this.parseMaybeAssign();
      this.semicolon();
      return res;
    }
  }

  // eslint-disable-next-line no-unused-vars
  parseExportDeclaration(node: N.ExportNamedDeclaration): ?N.Declaration {
    return this.parseStatement(true);
  }

  isExportDefaultSpecifier(): boolean {
    if (this.match(tt.name)) {
      return this.state.value !== "async";
    }

    if (!this.match(tt._default)) {
      return false;
    }

    const lookahead = this.lookahead();
    return (
      lookahead.type === tt.comma ||
      (lookahead.type === tt.name && lookahead.value === "from")
    );
  }

  parseExportSpecifiersMaybe(node: N.ExportNamedDeclaration): void {
    if (this.eat(tt.comma)) {
      node.specifiers = node.specifiers.concat(this.parseExportSpecifiers());
    }
  }

  parseExportFrom(node: N.ExportNamedDeclaration, expect?: boolean): void {
    if (this.eatContextual("from")) {
      node.source = this.match(tt.string)
        ? this.parseExprAtom()
        : this.unexpected();
      this.checkExport(node);
    } else {
      if (expect) {
        this.unexpected();
      } else {
        node.source = null;
      }
    }

    this.semicolon();
  }

  shouldParseExportStar(): boolean {
    return this.match(tt.star);
  }

  parseExportStar(node: N.ExportNamedDeclaration): void {
    this.expect(tt.star);

    if (this.isContextual("as")) {
      this.parseExportNamespace(node);
    } else {
      this.parseExportFrom(node, true);
      this.finishNode(node, "ExportAllDeclaration");
    }
  }

  parseExportNamespace(node: N.ExportNamedDeclaration): void {
    this.expectPlugin("exportNamespaceFrom");

    const specifier = this.startNodeAt(
      this.state.lastTokStart,
      this.state.lastTokStartLoc,
    );

    this.next();

    specifier.exported = this.parseIdentifier(true);

    node.specifiers = [this.finishNode(specifier, "ExportNamespaceSpecifier")];

    this.parseExportSpecifiersMaybe(node);
    this.parseExportFrom(node, true);
  }

  shouldParseExportDeclaration(): boolean {
    return (
      this.state.type.keyword === "var" ||
      this.state.type.keyword === "const" ||
      this.state.type.keyword === "let" ||
      this.state.type.keyword === "function" ||
      this.state.type.keyword === "class" ||
      this.isContextual("async") ||
      (this.match(tt.at) && this.expectPlugin("decorators2"))
    );
  }

  checkExport(
    node: N.ExportNamedDeclaration,
    checkNames: ?boolean,
    isDefault?: boolean,
  ): void {
    if (checkNames) {
      // Check for duplicate exports
      if (isDefault) {
        // Default exports
        this.checkDuplicateExports(node, "default");
      } else if (node.specifiers && node.specifiers.length) {
        // Named exports
        for (const specifier of node.specifiers) {
          this.checkDuplicateExports(specifier, specifier.exported.name);
        }
      } else if (node.declaration) {
        // Exported declarations
        if (
          node.declaration.type === "FunctionDeclaration" ||
          node.declaration.type === "ClassDeclaration"
        ) {
          const id = node.declaration.id;
          if (!id) throw new Error("Assertion failure");

          this.checkDuplicateExports(node, id.name);
        } else if (node.declaration.type === "VariableDeclaration") {
          for (const declaration of node.declaration.declarations) {
            this.checkDeclaration(declaration.id);
          }
        }
      }
    }

    const currentContextDecorators = this.state.decoratorStack[
      this.state.decoratorStack.length - 1
    ];
    if (currentContextDecorators.length) {
      const isClass =
        node.declaration &&
        (node.declaration.type === "ClassDeclaration" ||
          node.declaration.type === "ClassExpression");
      if (!node.declaration || !isClass) {
        throw this.raise(
          node.start,
          "You can only use decorators on an export when exporting a class",
        );
      }
      this.takeDecorators(node.declaration);
    }
  }

  checkDeclaration(node: N.Pattern | N.ObjectProperty): void {
    if (node.type === "ObjectPattern") {
      for (const prop of node.properties) {
        this.checkDeclaration(prop);
      }
    } else if (node.type === "ArrayPattern") {
      for (const elem of node.elements) {
        if (elem) {
          this.checkDeclaration(elem);
        }
      }
    } else if (node.type === "ObjectProperty") {
      this.checkDeclaration(node.value);
    } else if (node.type === "RestElement") {
      this.checkDeclaration(node.argument);
    } else if (node.type === "Identifier") {
      this.checkDuplicateExports(node, node.name);
    }
  }

  checkDuplicateExports(
    node: N.Identifier | N.ExportNamedDeclaration | N.ExportSpecifier,
    name: string,
  ): void {
    if (this.state.exportedIdentifiers.indexOf(name) > -1) {
      this.raiseDuplicateExportError(node, name);
    }
    this.state.exportedIdentifiers.push(name);
  }

  raiseDuplicateExportError(
    node: N.Identifier | N.ExportNamedDeclaration | N.ExportSpecifier,
    name: string,
  ): empty {
    throw this.raise(
      node.start,
      name === "default"
        ? "Only one default export allowed per module."
        : `\`${name}\` has already been exported. Exported identifiers must be unique.`,
    );
  }

  // Parses a comma-separated list of module exports.

  parseExportSpecifiers(): Array<N.ExportSpecifier> {
    const nodes = [];
    let first = true;
    let needsFrom;

    // export { x, y as z } [from '...']
    this.expect(tt.braceL);

    while (!this.eat(tt.braceR)) {
      if (first) {
        first = false;
      } else {
        this.expect(tt.comma);
        if (this.eat(tt.braceR)) break;
      }

      const isDefault = this.match(tt._default);
      if (isDefault && !needsFrom) needsFrom = true;

      const node = this.startNode();
      node.local = this.parseIdentifier(isDefault);
      node.exported = this.eatContextual("as")
        ? this.parseIdentifier(true)
        : node.local.__clone();
      nodes.push(this.finishNode(node, "ExportSpecifier"));
    }

    // https://github.com/ember-cli/ember-cli/pull/3739
    if (needsFrom && !this.isContextual("from")) {
      this.unexpected();
    }

    return nodes;
  }

  // Parses import declaration.

  parseImport(node: N.Node): N.ImportDeclaration | N.TsImportEqualsDeclaration {
    // import '...'
    if (this.match(tt.string)) {
      node.specifiers = [];
      node.source = this.parseExprAtom();
    } else {
      node.specifiers = [];
      this.parseImportSpecifiers(node);
      this.expectContextual("from");
      node.source = this.match(tt.string)
        ? this.parseExprAtom()
        : this.unexpected();
    }
    this.semicolon();
    return this.finishNode(node, "ImportDeclaration");
  }

  // eslint-disable-next-line no-unused-vars
  shouldParseDefaultImport(node: N.ImportDeclaration): boolean {
    return this.match(tt.name);
  }

  parseImportSpecifierLocal(
    node: N.ImportDeclaration,
    specifier: N.Node,
    type: string,
    contextDescription: string,
  ): void {
    specifier.local = this.parseIdentifier();
    this.checkLVal(specifier.local, true, undefined, contextDescription);
    node.specifiers.push(this.finishNode(specifier, type));
  }

  // Parses a comma-separated list of module imports.
  parseImportSpecifiers(node: N.ImportDeclaration): void {
    let first = true;
    if (this.shouldParseDefaultImport(node)) {
      // import defaultObj, { x, y as z } from '...'
      this.parseImportSpecifierLocal(
        node,
        this.startNode(),
        "ImportDefaultSpecifier",
        "default import specifier",
      );

      if (!this.eat(tt.comma)) return;
    }

    if (this.match(tt.star)) {
      const specifier = this.startNode();
      this.next();
      this.expectContextual("as");

      this.parseImportSpecifierLocal(
        node,
        specifier,
        "ImportNamespaceSpecifier",
        "import namespace specifier",
      );

      return;
    }

    this.expect(tt.braceL);
    while (!this.eat(tt.braceR)) {
      if (first) {
        first = false;
      } else {
        // Detect an attempt to deep destructure
        if (this.eat(tt.colon)) {
          this.unexpected(
            null,
            "ES2015 named imports do not destructure. " +
              "Use another statement for destructuring after the import.",
          );
        }

        this.expect(tt.comma);
        if (this.eat(tt.braceR)) break;
      }

      this.parseImportSpecifier(node);
    }
  }

  parseImportSpecifier(node: N.ImportDeclaration): void {
    const specifier = this.startNode();
    specifier.imported = this.parseIdentifier(true);
    if (this.eatContextual("as")) {
      specifier.local = this.parseIdentifier();
    } else {
      this.checkReservedWord(
        specifier.imported.name,
        specifier.start,
        true,
        true,
      );
      specifier.local = specifier.imported.__clone();
    }
    this.checkLVal(specifier.local, true, undefined, "import specifier");
    node.specifiers.push(this.finishNode(specifier, "ImportSpecifier"));
  }
}

// @flow

import { types as tt, type TokenType } from "../tokenizer/types";
import Tokenizer from "../tokenizer";
import type { Node } from "../types";
import { lineBreak } from "../util/whitespace";

// ## Parser utilities

export default class UtilParser extends Tokenizer {
  // TODO

  addExtra(node: Node, key: string, val: any): void {
    if (!node) return;

    const extra = (node.extra = node.extra || {});
    extra[key] = val;
  }

  // TODO

  isRelational(op: "<" | ">"): boolean {
    return this.match(tt.relational) && this.state.value === op;
  }

  // TODO

  expectRelational(op: "<" | ">"): void {
    if (this.isRelational(op)) {
      this.next();
    } else {
      this.unexpected(null, tt.relational);
    }
  }

  // eat() for relational operators.

  eatRelational(op: "<" | ">"): boolean {
    if (this.isRelational(op)) {
      this.next();
      return true;
    }
    return false;
  }

  // Tests whether parsed token is a contextual keyword.

  isContextual(name: string): boolean {
    return (
      this.match(tt.name) &&
      this.state.value === name &&
      !this.state.containsEsc
    );
  }

  isLookaheadContextual(name: string): boolean {
    const l = this.lookahead();
    return l.type === tt.name && l.value === name;
  }

  // Consumes contextual keyword if possible.

  eatContextual(name: string): boolean {
    return this.isContextual(name) && this.eat(tt.name);
  }

  // Asserts that following token is given contextual keyword.

  expectContextual(name: string, message?: string): void {
    if (!this.eatContextual(name)) this.unexpected(null, message);
  }

  // Test whether a semicolon can be inserted at the current position.

  canInsertSemicolon(): boolean {
    return (
      this.match(tt.eof) ||
      this.match(tt.braceR) ||
      this.hasPrecedingLineBreak()
    );
  }

  hasPrecedingLineBreak(): boolean {
    return lineBreak.test(
      this.input.slice(this.state.lastTokEnd, this.state.start),
    );
  }

  // TODO

  isLineTerminator(): boolean {
    return this.eat(tt.semi) || this.canInsertSemicolon();
  }

  // Consume a semicolon, or, failing that, see if we are allowed to
  // pretend that there is a semicolon at this position.

  semicolon(): void {
    if (!this.isLineTerminator()) this.unexpected(null, tt.semi);
  }

  // Expect a token of a given type. If found, consume it, otherwise,
  // raise an unexpected token error at given pos.

  expect(type: TokenType, pos?: ?number): void {
    this.eat(type) || this.unexpected(pos, type);
  }

  // Raise an unexpected token error. Can take the expected token type
  // instead of a message string.

  unexpected(
    pos: ?number,
    messageOrType: string | TokenType = "Unexpected token",
  ): empty {
    if (typeof messageOrType !== "string") {
      messageOrType = `Unexpected token, expected "${messageOrType.label}"`;
    }
    throw this.raise(pos != null ? pos : this.state.start, messageOrType);
  }

  expectPlugin(name: string, pos?: ?number): true {
    if (!this.hasPlugin(name)) {
      throw this.raise(
        pos != null ? pos : this.state.start,
        `This experimental syntax requires enabling the parser plugin: '${name}'`,
        { missingPluginNames: [name] },
      );
    }

    return true;
  }

  expectOnePlugin(names: Array<string>, pos?: ?number): void {
    if (!names.some(n => this.hasPlugin(n))) {
      throw this.raise(
        pos != null ? pos : this.state.start,
        `This experimental syntax requires enabling one of the following parser plugin(s): '${names.join(
          ", ",
        )}'`,
        { missingPluginNames: names },
      );
    }
  }
}

// @flow

// The algorithm used to determine whether a regexp can appear at a
// given point in the program is loosely based on sweet.js' approach.
// See https://github.com/mozilla/sweet.js/wiki/design

import { types as tt } from "./types";
import { lineBreak } from "../util/whitespace";

export class TokContext {
  constructor(
    token: string,
    isExpr?: boolean,
    preserveSpace?: boolean,
    override?: Function, // Takes a Tokenizer as a this-parameter, and returns void.
  ) {
    this.token = token;
    this.isExpr = !!isExpr;
    this.preserveSpace = !!preserveSpace;
    this.override = override;
  }

  token: string;
  isExpr: boolean;
  preserveSpace: boolean;
  override: ?Function;
}

export const types: {
  [key: string]: TokContext,
} = {
  braceStatement: new TokContext("{", false),
  braceExpression: new TokContext("{", true),
  templateQuasi: new TokContext("${", true),
  parenStatement: new TokContext("(", false),
  parenExpression: new TokContext("(", true),
  template: new TokContext("`", true, true, p => p.readTmplToken()),
  functionExpression: new TokContext("function", true),
};

// Token-specific context update code

tt.parenR.updateContext = tt.braceR.updateContext = function() {
  if (this.state.context.length === 1) {
    this.state.exprAllowed = true;
    return;
  }

  const out = this.state.context.pop();
  if (
    out === types.braceStatement &&
    this.curContext() === types.functionExpression
  ) {
    this.state.context.pop();
    this.state.exprAllowed = false;
  } else if (out === types.templateQuasi) {
    this.state.exprAllowed = true;
  } else {
    this.state.exprAllowed = !out.isExpr;
  }
};

tt.name.updateContext = function(prevType) {
  if (this.state.value === "of" && this.curContext() === types.parenStatement) {
    this.state.exprAllowed = !prevType.beforeExpr;
    return;
  }

  this.state.exprAllowed = false;

  if (prevType === tt._let || prevType === tt._const || prevType === tt._var) {
    if (lineBreak.test(this.input.slice(this.state.end))) {
      this.state.exprAllowed = true;
    }
  }
  if (this.state.isIterator) {
    this.state.isIterator = false;
  }
};

tt.braceL.updateContext = function(prevType) {
  this.state.context.push(
    this.braceIsBlock(prevType) ? types.braceStatement : types.braceExpression,
  );
  this.state.exprAllowed = true;
};

tt.dollarBraceL.updateContext = function() {
  this.state.context.push(types.templateQuasi);
  this.state.exprAllowed = true;
};

tt.parenL.updateContext = function(prevType) {
  const statementParens =
    prevType === tt._if ||
    prevType === tt._for ||
    prevType === tt._with ||
    prevType === tt._while;
  this.state.context.push(
    statementParens ? types.parenStatement : types.parenExpression,
  );
  this.state.exprAllowed = true;
};

tt.incDec.updateContext = function() {
  // tokExprAllowed stays unchanged
};

tt._function.updateContext = function(prevType) {
  if (this.state.exprAllowed && !this.braceIsBlock(prevType)) {
    this.state.context.push(types.functionExpression);
  }

  this.state.exprAllowed = false;
};

tt.backQuote.updateContext = function() {
  if (this.curContext() === types.template) {
    this.state.context.pop();
  } else {
    this.state.context.push(types.template);
  }
  this.state.exprAllowed = false;
};

// @flow

import type { Options } from "../options";
import type { Position } from "../util/location";
import * as charCodes from "charcodes";
import {
  isIdentifierStart,
  isIdentifierChar,
  isKeyword,
} from "../util/identifier";
import { types as tt, keywords as keywordTypes, type TokenType } from "./types";
import { type TokContext, types as ct } from "./context";
import LocationParser from "../parser/location";
import { SourceLocation } from "../util/location";
import {
  lineBreak,
  lineBreakG,
  isNewLine,
  nonASCIIwhitespace,
} from "../util/whitespace";
import State from "./state";

const VALID_REGEX_FLAGS = "gmsiyu";

// The following character codes are forbidden from being
// an immediate sibling of NumericLiteralSeparator _

const forbiddenNumericSeparatorSiblings = {
  decBinOct: [
    charCodes.dot,
    charCodes.uppercaseB,
    charCodes.uppercaseE,
    charCodes.uppercaseO,
    charCodes.underscore, // multiple separators are not allowed
    charCodes.lowercaseB,
    charCodes.lowercaseE,
    charCodes.lowercaseO,
  ],
  hex: [
    charCodes.dot,
    charCodes.uppercaseX,
    charCodes.underscore, // multiple separators are not allowed
    charCodes.lowercaseX,
  ],
};

const allowedNumericSeparatorSiblings = {};
allowedNumericSeparatorSiblings.bin = [
  // 0 - 1
  charCodes.digit0,
  charCodes.digit1,
];
allowedNumericSeparatorSiblings.oct = [
  // 0 - 7
  ...allowedNumericSeparatorSiblings.bin,

  charCodes.digit2,
  charCodes.digit3,
  charCodes.digit4,
  charCodes.digit5,
  charCodes.digit6,
  charCodes.digit7,
];
allowedNumericSeparatorSiblings.dec = [
  // 0 - 9
  ...allowedNumericSeparatorSiblings.oct,

  charCodes.digit8,
  charCodes.digit9,
];

allowedNumericSeparatorSiblings.hex = [
  // 0 - 9, A - F, a - f,
  ...allowedNumericSeparatorSiblings.dec,

  charCodes.uppercaseA,
  charCodes.uppercaseB,
  charCodes.uppercaseC,
  charCodes.uppercaseD,
  charCodes.uppercaseE,
  charCodes.uppercaseF,

  charCodes.lowercaseA,
  charCodes.lowercaseB,
  charCodes.lowercaseC,
  charCodes.lowercaseD,
  charCodes.lowercaseE,
  charCodes.lowercaseF,
];

// Object type used to represent tokens. Note that normally, tokens
// simply exist as properties on the parser object. This is only
// used for the onToken callback and the external tokenizer.

export class Token {
  constructor(state: State) {
    this.type = state.type;
    this.value = state.value;
    this.start = state.start;
    this.end = state.end;
    this.loc = new SourceLocation(state.startLoc, state.endLoc);
  }

  type: TokenType;
  value: any;
  start: number;
  end: number;
  loc: SourceLocation;
}

// ## Tokenizer

function codePointToString(code: number): string {
  // UTF-16 Decoding
  if (code <= 0xffff) {
    return String.fromCharCode(code);
  } else {
    return String.fromCharCode(
      ((code - 0x10000) >> 10) + 0xd800,
      ((code - 0x10000) & 1023) + 0xdc00,
    );
  }
}

export default class Tokenizer extends LocationParser {
  // Forward-declarations
  // parser/util.js
  +unexpected: (pos?: ?number, messageOrType?: string | TokenType) => empty;

  isLookahead: boolean;

  constructor(options: Options, input: string) {
    super();
    this.state = new State();
    this.state.init(options, input);
    this.isLookahead = false;
  }

  // Move to the next token

  next(): void {
    if (this.options.tokens && !this.isLookahead) {
      this.state.tokens.push(new Token(this.state));
    }

    this.state.lastTokEnd = this.state.end;
    this.state.lastTokStart = this.state.start;
    this.state.lastTokEndLoc = this.state.endLoc;
    this.state.lastTokStartLoc = this.state.startLoc;
    this.nextToken();
  }

  // TODO

  eat(type: TokenType): boolean {
    if (this.match(type)) {
      this.next();
      return true;
    } else {
      return false;
    }
  }

  // TODO

  match(type: TokenType): boolean {
    return this.state.type === type;
  }

  // TODO

  isKeyword(word: string): boolean {
    return isKeyword(word);
  }

  // TODO

  lookahead(): State {
    const old = this.state;
    this.state = old.clone(true);

    this.isLookahead = true;
    this.next();
    this.isLookahead = false;

    const curr = this.state;
    this.state = old;
    return curr;
  }

  // Toggle strict mode. Re-reads the next number or string to please
  // pedantic tests (`"use strict"; 010;` should fail).

  setStrict(strict: boolean): void {
    this.state.strict = strict;
    if (!this.match(tt.num) && !this.match(tt.string)) return;
    this.state.pos = this.state.start;
    while (this.state.pos < this.state.lineStart) {
      this.state.lineStart =
        this.input.lastIndexOf("\n", this.state.lineStart - 2) + 1;
      --this.state.curLine;
    }
    this.nextToken();
  }

  curContext(): TokContext {
    return this.state.context[this.state.context.length - 1];
  }

  // Read a single token, updating the parser object's token-related
  // properties.

  nextToken(): void {
    const curContext = this.curContext();
    if (!curContext || !curContext.preserveSpace) this.skipSpace();

    this.state.containsOctal = false;
    this.state.octalPosition = null;
    this.state.start = this.state.pos;
    this.state.startLoc = this.state.curPosition();
    if (this.state.pos >= this.input.length) {
      this.finishToken(tt.eof);
      return;
    }

    if (curContext.override) {
      curContext.override(this);
    } else {
      this.readToken(this.fullCharCodeAtPos());
    }
  }

  readToken(code: number): void {
    // Identifier or keyword. '\uXXXX' sequences are allowed in
    // identifiers, so '\' also dispatches to that.
    if (isIdentifierStart(code) || code === charCodes.backslash) {
      this.readWord();
    } else {
      this.getTokenFromCode(code);
    }
  }

  fullCharCodeAtPos(): number {
    const code = this.input.charCodeAt(this.state.pos);
    if (code <= 0xd7ff || code >= 0xe000) return code;

    const next = this.input.charCodeAt(this.state.pos + 1);
    return (code << 10) + next - 0x35fdc00;
  }

  pushComment(
    block: boolean,
    text: string,
    start: number,
    end: number,
    startLoc: Position,
    endLoc: Position,
  ): void {
    const comment = {
      type: block ? "CommentBlock" : "CommentLine",
      value: text,
      start: start,
      end: end,
      loc: new SourceLocation(startLoc, endLoc),
    };

    if (!this.isLookahead) {
      if (this.options.tokens) this.state.tokens.push(comment);
      this.state.comments.push(comment);
      this.addComment(comment);
    }
  }

  skipBlockComment(): void {
    const startLoc = this.state.curPosition();
    const start = this.state.pos;
    const end = this.input.indexOf("*/", (this.state.pos += 2));
    if (end === -1) this.raise(this.state.pos - 2, "Unterminated comment");

    this.state.pos = end + 2;
    lineBreakG.lastIndex = start;
    let match;
    while (
      (match = lineBreakG.exec(this.input)) &&
      match.index < this.state.pos
    ) {
      ++this.state.curLine;
      this.state.lineStart = match.index + match[0].length;
    }

    this.pushComment(
      true,
      this.input.slice(start + 2, end),
      start,
      this.state.pos,
      startLoc,
      this.state.curPosition(),
    );
  }

  skipLineComment(startSkip: number): void {
    const start = this.state.pos;
    const startLoc = this.state.curPosition();
    let ch = this.input.charCodeAt((this.state.pos += startSkip));
    if (this.state.pos < this.input.length) {
      while (
        ch !== charCodes.lineFeed &&
        ch !== charCodes.carriageReturn &&
        ch !== charCodes.lineSeparator &&
        ch !== charCodes.paragraphSeparator &&
        ++this.state.pos < this.input.length
      ) {
        ch = this.input.charCodeAt(this.state.pos);
      }
    }

    this.pushComment(
      false,
      this.input.slice(start + startSkip, this.state.pos),
      start,
      this.state.pos,
      startLoc,
      this.state.curPosition(),
    );
  }

  // Called at the start of the parse and after every token. Skips
  // whitespace and comments, and.

  skipSpace(): void {
    loop: while (this.state.pos < this.input.length) {
      const ch = this.input.charCodeAt(this.state.pos);
      switch (ch) {
        case charCodes.space:
        case charCodes.nonBreakingSpace:
          ++this.state.pos;
          break;

        case charCodes.carriageReturn:
          if (
            this.input.charCodeAt(this.state.pos + 1) === charCodes.lineFeed
          ) {
            ++this.state.pos;
          }

        case charCodes.lineFeed:
        case charCodes.lineSeparator:
        case charCodes.paragraphSeparator:
          ++this.state.pos;
          ++this.state.curLine;
          this.state.lineStart = this.state.pos;
          break;

        case charCodes.slash:
          switch (this.input.charCodeAt(this.state.pos + 1)) {
            case charCodes.asterisk:
              this.skipBlockComment();
              break;

            case charCodes.slash:
              this.skipLineComment(2);
              break;

            default:
              break loop;
          }
          break;

        default:
          if (
            (ch > charCodes.backSpace && ch < charCodes.shiftOut) ||
            (ch >= charCodes.oghamSpaceMark &&
              nonASCIIwhitespace.test(String.fromCharCode(ch)))
          ) {
            ++this.state.pos;
          } else {
            break loop;
          }
      }
    }
  }

  // Called at the end of every token. Sets `end`, `val`, and
  // maintains `context` and `exprAllowed`, and skips the space after
  // the token, so that the next one's `start` will point at the
  // right position.

  finishToken(type: TokenType, val: any): void {
    this.state.end = this.state.pos;
    this.state.endLoc = this.state.curPosition();
    const prevType = this.state.type;
    this.state.type = type;
    this.state.value = val;

    this.updateContext(prevType);
  }

  // ### Token reading

  // This is the function that is called to fetch the next token. It
  // is somewhat obscure, because it works in character codes rather
  // than characters, and because operator parsing has been inlined
  // into it.
  //
  // All in the name of speed.
  //
  readToken_dot(): void {
    const next = this.input.charCodeAt(this.state.pos + 1);
    if (next >= charCodes.digit0 && next <= charCodes.digit9) {
      this.readNumber(true);
      return;
    }

    const next2 = this.input.charCodeAt(this.state.pos + 2);
    if (next === charCodes.dot && next2 === charCodes.dot) {
      this.state.pos += 3;
      this.finishToken(tt.ellipsis);
    } else {
      ++this.state.pos;
      this.finishToken(tt.dot);
    }
  }

  readToken_slash(): void {
    // '/'
    if (this.state.exprAllowed) {
      ++this.state.pos;
      this.readRegexp();
      return;
    }

    const next = this.input.charCodeAt(this.state.pos + 1);
    if (next === charCodes.equalsTo) {
      this.finishOp(tt.assign, 2);
    } else {
      this.finishOp(tt.slash, 1);
    }
  }

  readToken_mult_modulo(code: number): void {
    // '%*'
    let type = code === charCodes.asterisk ? tt.star : tt.modulo;
    let width = 1;
    let next = this.input.charCodeAt(this.state.pos + 1);
    const exprAllowed = this.state.exprAllowed;

    // Exponentiation operator **
    if (code === charCodes.asterisk && next === charCodes.asterisk) {
      width++;
      next = this.input.charCodeAt(this.state.pos + 2);
      type = tt.exponent;
    }

    if (next === charCodes.equalsTo && !exprAllowed) {
      width++;
      type = tt.assign;
    }

    this.finishOp(type, width);
  }

  readToken_pipe_amp(code: number): void {
    // '|&'
    const next = this.input.charCodeAt(this.state.pos + 1);

    if (next === code) {
      if (this.input.charCodeAt(this.state.pos + 2) === charCodes.equalsTo) {
        this.finishOp(tt.assign, 3);
      } else {
        this.finishOp(
          code === charCodes.verticalBar ? tt.logicalOR : tt.logicalAND,
          2,
        );
      }
      return;
    }

    if (code === charCodes.verticalBar) {
      // '|>'
      if (next === charCodes.greaterThan) {
        this.finishOp(tt.pipeline, 2);
        return;
      } else if (next === charCodes.rightCurlyBrace && this.hasPlugin("flow")) {
        // '|}'
        this.finishOp(tt.braceBarR, 2);
        return;
      }
    }

    if (next === charCodes.equalsTo) {
      this.finishOp(tt.assign, 2);
      return;
    }

    this.finishOp(
      code === charCodes.verticalBar ? tt.bitwiseOR : tt.bitwiseAND,
      1,
    );
  }

  readToken_caret(): void {
    // '^'
    const next = this.input.charCodeAt(this.state.pos + 1);
    if (next === charCodes.equalsTo) {
      this.finishOp(tt.assign, 2);
    } else {
      this.finishOp(tt.bitwiseXOR, 1);
    }
  }

  readToken_plus_min(code: number): void {
    // '+-'
    const next = this.input.charCodeAt(this.state.pos + 1);

    if (next === code) {
      if (
        next === charCodes.dash &&
        !this.inModule &&
        this.input.charCodeAt(this.state.pos + 2) === charCodes.greaterThan &&
        lineBreak.test(this.input.slice(this.state.lastTokEnd, this.state.pos))
      ) {
        // A `-->` line comment
        this.skipLineComment(3);
        this.skipSpace();
        this.nextToken();
        return;
      }
      this.finishOp(tt.incDec, 2);
      return;
    }

    if (next === charCodes.equalsTo) {
      this.finishOp(tt.assign, 2);
    } else {
      this.finishOp(tt.plusMin, 1);
    }
  }

  readToken_lt_gt(code: number): void {
    // '<>'
    const next = this.input.charCodeAt(this.state.pos + 1);
    let size = 1;

    if (next === code) {
      size =
        code === charCodes.greaterThan &&
        this.input.charCodeAt(this.state.pos + 2) === charCodes.greaterThan
          ? 3
          : 2;
      if (this.input.charCodeAt(this.state.pos + size) === charCodes.equalsTo) {
        this.finishOp(tt.assign, size + 1);
        return;
      }
      this.finishOp(tt.bitShift, size);
      return;
    }

    if (
      next === charCodes.exclamationMark &&
      code === charCodes.lessThan &&
      !this.inModule &&
      this.input.charCodeAt(this.state.pos + 2) === charCodes.dash &&
      this.input.charCodeAt(this.state.pos + 3) === charCodes.dash
    ) {
      // `<!--`, an XML-style comment that should be interpreted as a line comment
      this.skipLineComment(4);
      this.skipSpace();
      this.nextToken();
      return;
    }

    if (next === charCodes.equalsTo) {
      // <= | >=
      size = 2;
    }

    this.finishOp(tt.relational, size);
  }

  readToken_eq_excl(code: number): void {
    // '=!'
    const next = this.input.charCodeAt(this.state.pos + 1);
    if (next === charCodes.equalsTo) {
      this.finishOp(
        tt.equality,
        this.input.charCodeAt(this.state.pos + 2) === charCodes.equalsTo
          ? 3
          : 2,
      );
      return;
    }
    if (code === charCodes.equalsTo && next === charCodes.greaterThan) {
      // '=>'
      this.state.pos += 2;
      this.finishToken(tt.arrow);
      return;
    }
    this.finishOp(code === charCodes.equalsTo ? tt.eq : tt.bang, 1);
  }

  readToken_question(): void {
    // '?'
    const next = this.input.charCodeAt(this.state.pos + 1);
    const next2 = this.input.charCodeAt(this.state.pos + 2);
    if (next === charCodes.questionMark) {
      if (next2 === charCodes.equalsTo) {
        // '??='
        this.finishOp(tt.assign, 3);
      } else {
        // '??'
        this.finishOp(tt.nullishCoalescing, 2);
      }
    } else if (
      next === charCodes.dot &&
      !(next2 >= charCodes.digit0 && next2 <= charCodes.digit9)
    ) {
      // '.' not followed by a number
      this.state.pos += 2;
      this.finishToken(tt.questionDot);
    } else {
      ++this.state.pos;
      this.finishToken(tt.question);
    }
  }

  getTokenFromCode(code: number): void {
    switch (code) {
      case charCodes.numberSign:
        if (
          (this.hasPlugin("classPrivateProperties") ||
            this.hasPlugin("classPrivateMethods")) &&
          this.state.classLevel > 0
        ) {
          ++this.state.pos;
          this.finishToken(tt.hash);
          return;
        } else {
          this.raise(
            this.state.pos,
            `Unexpected character '${codePointToString(code)}'`,
          );
        }

      // The interpretation of a dot depends on whether it is followed
      // by a digit or another two dots.

      case charCodes.dot:
        this.readToken_dot();
        return;

      // Punctuation tokens.
      case charCodes.leftParenthesis:
        ++this.state.pos;
        this.finishToken(tt.parenL);
        return;
      case charCodes.rightParenthesis:
        ++this.state.pos;
        this.finishToken(tt.parenR);
        return;
      case charCodes.semicolon:
        ++this.state.pos;
        this.finishToken(tt.semi);
        return;
      case charCodes.comma:
        ++this.state.pos;
        this.finishToken(tt.comma);
        return;
      case charCodes.leftSquareBracket:
        ++this.state.pos;
        this.finishToken(tt.bracketL);
        return;
      case charCodes.rightSquareBracket:
        ++this.state.pos;
        this.finishToken(tt.bracketR);
        return;

      case charCodes.leftCurlyBrace:
        if (
          this.hasPlugin("flow") &&
          this.input.charCodeAt(this.state.pos + 1) === charCodes.verticalBar
        ) {
          this.finishOp(tt.braceBarL, 2);
        } else {
          ++this.state.pos;
          this.finishToken(tt.braceL);
        }
        return;

      case charCodes.rightCurlyBrace:
        ++this.state.pos;
        this.finishToken(tt.braceR);
        return;

      case charCodes.colon:
        if (
          this.hasPlugin("functionBind") &&
          this.input.charCodeAt(this.state.pos + 1) === charCodes.colon
        ) {
          this.finishOp(tt.doubleColon, 2);
        } else {
          ++this.state.pos;
          this.finishToken(tt.colon);
        }
        return;

      case charCodes.questionMark:
        this.readToken_question();
        return;
      case charCodes.atSign:
        ++this.state.pos;
        this.finishToken(tt.at);
        return;

      case charCodes.graveAccent:
        ++this.state.pos;
        this.finishToken(tt.backQuote);
        return;

      case charCodes.digit0: {
        const next = this.input.charCodeAt(this.state.pos + 1);
        // '0x', '0X' - hex number
        if (next === charCodes.lowercaseX || next === charCodes.uppercaseX) {
          this.readRadixNumber(16);
          return;
        }
        // '0o', '0O' - octal number
        if (next === charCodes.lowercaseO || next === charCodes.uppercaseO) {
          this.readRadixNumber(8);
          return;
        }
        // '0b', '0B' - binary number
        if (next === charCodes.lowercaseB || next === charCodes.uppercaseB) {
          this.readRadixNumber(2);
          return;
        }
      }
      // Anything else beginning with a digit is an integer, octal
      // number, or float.
      case charCodes.digit1:
      case charCodes.digit2:
      case charCodes.digit3:
      case charCodes.digit4:
      case charCodes.digit5:
      case charCodes.digit6:
      case charCodes.digit7:
      case charCodes.digit8:
      case charCodes.digit9:
        this.readNumber(false);
        return;

      // Quotes produce strings.
      case charCodes.quotationMark:
      case charCodes.apostrophe:
        this.readString(code);
        return;

      // Operators are parsed inline in tiny state machines. '=' (charCodes.equalsTo) is
      // often referred to. `finishOp` simply skips the amount of
      // characters it is given as second argument, and returns a token
      // of the type given by its first argument.

      case charCodes.slash:
        this.readToken_slash();
        return;

      case charCodes.percentSign:
      case charCodes.asterisk:
        this.readToken_mult_modulo(code);
        return;

      case charCodes.verticalBar:
      case charCodes.ampersand:
        this.readToken_pipe_amp(code);
        return;

      case charCodes.caret:
        this.readToken_caret();
        return;

      case charCodes.plusSign:
      case charCodes.dash:
        this.readToken_plus_min(code);
        return;

      case charCodes.lessThan:
      case charCodes.greaterThan:
        this.readToken_lt_gt(code);
        return;

      case charCodes.equalsTo:
      case charCodes.exclamationMark:
        this.readToken_eq_excl(code);
        return;

      case charCodes.tilde:
        this.finishOp(tt.tilde, 1);
        return;
    }

    this.raise(
      this.state.pos,
      `Unexpected character '${codePointToString(code)}'`,
    );
  }

  finishOp(type: TokenType, size: number): void {
    const str = this.input.slice(this.state.pos, this.state.pos + size);
    this.state.pos += size;
    this.finishToken(type, str);
  }

  readRegexp(): void {
    const start = this.state.pos;
    let escaped, inClass;
    for (;;) {
      if (this.state.pos >= this.input.length) {
        this.raise(start, "Unterminated regular expression");
      }
      const ch = this.input.charAt(this.state.pos);
      if (lineBreak.test(ch)) {
        this.raise(start, "Unterminated regular expression");
      }
      if (escaped) {
        escaped = false;
      } else {
        if (ch === "[") {
          inClass = true;
        } else if (ch === "]" && inClass) {
          inClass = false;
        } else if (ch === "/" && !inClass) {
          break;
        }
        escaped = ch === "\\";
      }
      ++this.state.pos;
    }
    const content = this.input.slice(start, this.state.pos);
    ++this.state.pos;

    let mods = "";

    while (this.state.pos < this.input.length) {
      const char = this.input[this.state.pos];
      const charCode = this.fullCharCodeAtPos();

      if (VALID_REGEX_FLAGS.indexOf(char) > -1) {
        if (mods.indexOf(char) > -1) {
          this.raise(this.state.pos + 1, "Duplicate regular expression flag");
        }

        ++this.state.pos;
        mods += char;
      } else if (
        isIdentifierChar(charCode) ||
        charCode === charCodes.backslash
      ) {
        this.raise(this.state.pos + 1, "Invalid regular expression flag");
      } else {
        break;
      }
    }

    this.finishToken(tt.regexp, {
      pattern: content,
      flags: mods,
    });
  }

  // Read an integer in the given radix. Return null if zero digits
  // were read, the integer value otherwise. When `len` is given, this
  // will return `null` unless the integer has exactly `len` digits.

  readInt(radix: number, len?: number): number | null {
    const start = this.state.pos;
    const forbiddenSiblings =
      radix === 16
        ? forbiddenNumericSeparatorSiblings.hex
        : forbiddenNumericSeparatorSiblings.decBinOct;
    const allowedSiblings =
      radix === 16
        ? allowedNumericSeparatorSiblings.hex
        : radix === 10
          ? allowedNumericSeparatorSiblings.dec
          : radix === 8
            ? allowedNumericSeparatorSiblings.oct
            : allowedNumericSeparatorSiblings.bin;

    let total = 0;

    for (let i = 0, e = len == null ? Infinity : len; i < e; ++i) {
      const code = this.input.charCodeAt(this.state.pos);
      let val;

      if (this.hasPlugin("numericSeparator")) {
        const prev = this.input.charCodeAt(this.state.pos - 1);
        const next = this.input.charCodeAt(this.state.pos + 1);
        if (code === charCodes.underscore) {
          if (allowedSiblings.indexOf(next) === -1) {
            this.raise(this.state.pos, "Invalid or unexpected token");
          }

          if (
            forbiddenSiblings.indexOf(prev) > -1 ||
            forbiddenSiblings.indexOf(next) > -1 ||
            Number.isNaN(next)
          ) {
            this.raise(this.state.pos, "Invalid or unexpected token");
          }

          // Ignore this _ character
          ++this.state.pos;
          continue;
        }
      }

      if (code >= charCodes.lowercaseA) {
        val = code - charCodes.lowercaseA + charCodes.lineFeed;
      } else if (code >= charCodes.uppercaseA) {
        val = code - charCodes.uppercaseA + charCodes.lineFeed;
      } else if (charCodes.isDigit(code)) {
        val = code - charCodes.digit0; // 0-9
      } else {
        val = Infinity;
      }
      if (val >= radix) break;
      ++this.state.pos;
      total = total * radix + val;
    }
    if (
      this.state.pos === start ||
      (len != null && this.state.pos - start !== len)
    ) {
      return null;
    }

    return total;
  }

  readRadixNumber(radix: number): void {
    const start = this.state.pos;
    let isBigInt = false;

    this.state.pos += 2; // 0x
    const val = this.readInt(radix);
    if (val == null) {
      this.raise(this.state.start + 2, "Expected number in radix " + radix);
    }

    if (this.hasPlugin("bigInt")) {
      if (this.input.charCodeAt(this.state.pos) === charCodes.lowercaseN) {
        ++this.state.pos;
        isBigInt = true;
      }
    }

    if (isIdentifierStart(this.fullCharCodeAtPos())) {
      this.raise(this.state.pos, "Identifier directly after number");
    }

    if (isBigInt) {
      const str = this.input.slice(start, this.state.pos).replace(/[_n]/g, "");
      this.finishToken(tt.bigint, str);
      return;
    }

    this.finishToken(tt.num, val);
  }

  // Read an integer, octal integer, or floating-point number.

  readNumber(startsWithDot: boolean): void {
    const start = this.state.pos;
    let octal = this.input.charCodeAt(start) === charCodes.digit0;
    let isFloat = false;
    let isBigInt = false;

    if (!startsWithDot && this.readInt(10) === null) {
      this.raise(start, "Invalid number");
    }
    if (octal && this.state.pos == start + 1) octal = false; // number === 0

    let next = this.input.charCodeAt(this.state.pos);
    if (next === charCodes.dot && !octal) {
      ++this.state.pos;
      this.readInt(10);
      isFloat = true;
      next = this.input.charCodeAt(this.state.pos);
    }

    if (
      (next === charCodes.uppercaseE || next === charCodes.lowercaseE) &&
      !octal
    ) {
      next = this.input.charCodeAt(++this.state.pos);
      if (next === charCodes.plusSign || next === charCodes.dash) {
        ++this.state.pos;
      }
      if (this.readInt(10) === null) this.raise(start, "Invalid number");
      isFloat = true;
      next = this.input.charCodeAt(this.state.pos);
    }

    if (this.hasPlugin("bigInt")) {
      if (next === charCodes.lowercaseN) {
        // disallow floats and legacy octal syntax, new style octal ("0o") is handled in this.readRadixNumber
        if (isFloat || octal) this.raise(start, "Invalid BigIntLiteral");
        ++this.state.pos;
        isBigInt = true;
      }
    }

    if (isIdentifierStart(this.fullCharCodeAtPos())) {
      this.raise(this.state.pos, "Identifier directly after number");
    }

    // remove "_" for numeric literal separator, and "n" for BigInts
    const str = this.input.slice(start, this.state.pos).replace(/[_n]/g, "");

    if (isBigInt) {
      this.finishToken(tt.bigint, str);
      return;
    }

    let val;
    if (isFloat) {
      val = parseFloat(str);
    } else if (!octal || str.length === 1) {
      val = parseInt(str, 10);
    } else if (this.state.strict) {
      this.raise(start, "Invalid number");
    } else if (/[89]/.test(str)) {
      val = parseInt(str, 10);
    } else {
      val = parseInt(str, 8);
    }
    this.finishToken(tt.num, val);
  }

  // Read a string value, interpreting backslash-escapes.

  readCodePoint(throwOnInvalid: boolean): number | null {
    const ch = this.input.charCodeAt(this.state.pos);
    let code;

    if (ch === charCodes.leftCurlyBrace) {
      const codePos = ++this.state.pos;
      code = this.readHexChar(
        this.input.indexOf("}", this.state.pos) - this.state.pos,
        throwOnInvalid,
      );
      ++this.state.pos;
      if (code === null) {
        // $FlowFixMe (is this always non-null?)
        --this.state.invalidTemplateEscapePosition; // to point to the '\'' instead of the 'u'
      } else if (code > 0x10ffff) {
        if (throwOnInvalid) {
          this.raise(codePos, "Code point out of bounds");
        } else {
          this.state.invalidTemplateEscapePosition = codePos - 2;
          return null;
        }
      }
    } else {
      code = this.readHexChar(4, throwOnInvalid);
    }
    return code;
  }

  readString(quote: number): void {
    let out = "",
      chunkStart = ++this.state.pos;
    for (;;) {
      if (this.state.pos >= this.input.length) {
        this.raise(this.state.start, "Unterminated string constant");
      }
      const ch = this.input.charCodeAt(this.state.pos);
      if (ch === quote) break;
      if (ch === charCodes.backslash) {
        out += this.input.slice(chunkStart, this.state.pos);
        // $FlowFixMe
        out += this.readEscapedChar(false);
        chunkStart = this.state.pos;
      } else {
        if (isNewLine(ch)) {
          this.raise(this.state.start, "Unterminated string constant");
        }
        ++this.state.pos;
      }
    }
    out += this.input.slice(chunkStart, this.state.pos++);
    this.finishToken(tt.string, out);
  }

  // Reads template string tokens.

  readTmplToken(): void {
    let out = "",
      chunkStart = this.state.pos,
      containsInvalid = false;
    for (;;) {
      if (this.state.pos >= this.input.length) {
        this.raise(this.state.start, "Unterminated template");
      }
      const ch = this.input.charCodeAt(this.state.pos);
      if (
        ch === charCodes.graveAccent ||
        (ch === charCodes.dollarSign &&
          this.input.charCodeAt(this.state.pos + 1) ===
            charCodes.leftCurlyBrace)
      ) {
        if (this.state.pos === this.state.start && this.match(tt.template)) {
          if (ch === charCodes.dollarSign) {
            this.state.pos += 2;
            this.finishToken(tt.dollarBraceL);
            return;
          } else {
            ++this.state.pos;
            this.finishToken(tt.backQuote);
            return;
          }
        }
        out += this.input.slice(chunkStart, this.state.pos);
        this.finishToken(tt.template, containsInvalid ? null : out);
        return;
      }
      if (ch === charCodes.backslash) {
        out += this.input.slice(chunkStart, this.state.pos);
        const escaped = this.readEscapedChar(true);
        if (escaped === null) {
          containsInvalid = true;
        } else {
          out += escaped;
        }
        chunkStart = this.state.pos;
      } else if (isNewLine(ch)) {
        out += this.input.slice(chunkStart, this.state.pos);
        ++this.state.pos;
        switch (ch) {
          case charCodes.carriageReturn:
            if (this.input.charCodeAt(this.state.pos) === charCodes.lineFeed) {
              ++this.state.pos;
            }
          case charCodes.lineFeed:
            out += "\n";
            break;
          default:
            out += String.fromCharCode(ch);
            break;
        }
        ++this.state.curLine;
        this.state.lineStart = this.state.pos;
        chunkStart = this.state.pos;
      } else {
        ++this.state.pos;
      }
    }
  }

  // Used to read escaped characters

  readEscapedChar(inTemplate: boolean): string | null {
    const throwOnInvalid = !inTemplate;
    const ch = this.input.charCodeAt(++this.state.pos);
    ++this.state.pos;
    switch (ch) {
      case charCodes.lowercaseN:
        return "\n";
      case charCodes.lowercaseR:
        return "\r";
      case charCodes.lowercaseX: {
        const code = this.readHexChar(2, throwOnInvalid);
        return code === null ? null : String.fromCharCode(code);
      }
      case charCodes.lowercaseU: {
        const code = this.readCodePoint(throwOnInvalid);
        return code === null ? null : codePointToString(code);
      }
      case charCodes.lowercaseT:
        return "\t";
      case charCodes.lowercaseB:
        return "\b";
      case charCodes.lowercaseV:
        return "\u000b";
      case charCodes.lowercaseF:
        return "\f";
      case charCodes.carriageReturn:
        if (this.input.charCodeAt(this.state.pos) === charCodes.lineFeed) {
          ++this.state.pos;
        }
      case charCodes.lineFeed:
        this.state.lineStart = this.state.pos;
        ++this.state.curLine;
        return "";
      default:
        if (ch >= charCodes.digit0 && ch <= charCodes.digit7) {
          const codePos = this.state.pos - 1;
          // $FlowFixMe
          let octalStr = this.input
            .substr(this.state.pos - 1, 3)
            .match(/^[0-7]+/)[0];
          let octal = parseInt(octalStr, 8);
          if (octal > 255) {
            octalStr = octalStr.slice(0, -1);
            octal = parseInt(octalStr, 8);
          }
          if (octal > 0) {
            if (inTemplate) {
              this.state.invalidTemplateEscapePosition = codePos;
              return null;
            } else if (this.state.strict) {
              this.raise(codePos, "Octal literal in strict mode");
            } else if (!this.state.containsOctal) {
              // These properties are only used to throw an error for an octal which occurs
              // in a directive which occurs prior to a "use strict" directive.
              this.state.containsOctal = true;
              this.state.octalPosition = codePos;
            }
          }
          this.state.pos += octalStr.length - 1;
          return String.fromCharCode(octal);
        }
        return String.fromCharCode(ch);
    }
  }

  // Used to read character escape sequences ('\x', '\u').

  readHexChar(len: number, throwOnInvalid: boolean): number | null {
    const codePos = this.state.pos;
    const n = this.readInt(16, len);
    if (n === null) {
      if (throwOnInvalid) {
        this.raise(codePos, "Bad character escape sequence");
      } else {
        this.state.pos = codePos - 1;
        this.state.invalidTemplateEscapePosition = codePos - 1;
      }
    }
    return n;
  }

  // Read an identifier, and return it as a string. Sets `this.state.containsEsc`
  // to whether the word contained a '\u' escape.
  //
  // Incrementally adds only escaped chars, adding other chunks as-is
  // as a micro-optimization.

  readWord1(): string {
    this.state.containsEsc = false;
    let word = "",
      first = true,
      chunkStart = this.state.pos;
    while (this.state.pos < this.input.length) {
      const ch = this.fullCharCodeAtPos();
      if (isIdentifierChar(ch)) {
        this.state.pos += ch <= 0xffff ? 1 : 2;
      } else if (this.state.isIterator && ch === charCodes.atSign) {
        this.state.pos += 1;
      } else if (ch === charCodes.backslash) {
        this.state.containsEsc = true;

        word += this.input.slice(chunkStart, this.state.pos);
        const escStart = this.state.pos;

        if (this.input.charCodeAt(++this.state.pos) !== charCodes.lowercaseU) {
          this.raise(
            this.state.pos,
            "Expecting Unicode escape sequence \\uXXXX",
          );
        }

        ++this.state.pos;
        const esc = this.readCodePoint(true);
        // $FlowFixMe (thinks esc may be null, but throwOnInvalid is true)
        if (!(first ? isIdentifierStart : isIdentifierChar)(esc, true)) {
          this.raise(escStart, "Invalid Unicode escape");
        }

        // $FlowFixMe
        word += codePointToString(esc);
        chunkStart = this.state.pos;
      } else {
        break;
      }
      first = false;
    }
    return word + this.input.slice(chunkStart, this.state.pos);
  }

  isIterator(word: string): boolean {
    return word === "@@iterator" || word === "@@asyncIterator";
  }

  // Read an identifier or keyword token. Will check for reserved
  // words when necessary.

  readWord(): void {
    const word = this.readWord1();
    let type = tt.name;

    if (this.isKeyword(word)) {
      if (this.state.containsEsc) {
        this.raise(this.state.pos, `Escape sequence in keyword ${word}`);
      }

      type = keywordTypes[word];
    }

    // Allow @@iterator and @@asyncIterator as a identifier only inside type
    if (
      this.state.isIterator &&
      (!this.isIterator(word) || !this.state.inType)
    ) {
      this.raise(this.state.pos, `Invalid identifier ${word}`);
    }

    this.finishToken(type, word);
  }

  braceIsBlock(prevType: TokenType): boolean {
    if (prevType === tt.colon) {
      const parent = this.curContext();
      if (parent === ct.braceStatement || parent === ct.braceExpression) {
        return !parent.isExpr;
      }
    }

    if (prevType === tt._return) {
      return lineBreak.test(
        this.input.slice(this.state.lastTokEnd, this.state.start),
      );
    }

    if (
      prevType === tt._else ||
      prevType === tt.semi ||
      prevType === tt.eof ||
      prevType === tt.parenR
    ) {
      return true;
    }

    if (prevType === tt.braceL) {
      return this.curContext() === ct.braceStatement;
    }

    if (prevType === tt.relational) {
      // `class C<T> { ... }`
      return true;
    }

    return !this.state.exprAllowed;
  }

  updateContext(prevType: TokenType): void {
    const type = this.state.type;
    let update;

    if (type.keyword && (prevType === tt.dot || prevType === tt.questionDot)) {
      this.state.exprAllowed = false;
    } else if ((update = type.updateContext)) {
      update.call(this, prevType);
    } else {
      this.state.exprAllowed = type.beforeExpr;
    }
  }
}

// @flow

import type { Options } from "../options";
import * as N from "../types";
import { Position } from "../util/location";

import { types as ct, type TokContext } from "./context";
import type { Token } from "./index";
import { types as tt, type TokenType } from "./types";

export default class State {
  init(options: Options, input: string): void {
    this.strict =
      options.strictMode === false ? false : options.sourceType === "module";

    this.input = input;

    this.potentialArrowAt = -1;

    this.noArrowAt = [];
    this.noArrowParamsConversionAt = [];

    this.inMethod = false;
    this.inFunction = false;
    this.inParameters = false;
    this.maybeInArrowParameters = false;
    this.inGenerator = false;
    this.inAsync = false;
    this.inPropertyName = false;
    this.inType = false;
    this.inClassProperty = false;
    this.noAnonFunctionType = false;
    this.hasFlowComment = false;
    this.isIterator = false;

    this.classLevel = 0;

    this.labels = [];

    this.decoratorStack = [[]];

    this.yieldInPossibleArrowParameters = null;

    this.tokens = [];

    this.comments = [];

    this.trailingComments = [];
    this.leadingComments = [];
    this.commentStack = [];
    // $FlowIgnore
    this.commentPreviousNode = null;

    this.pos = this.lineStart = 0;
    this.curLine = options.startLine;

    this.type = tt.eof;
    this.value = null;
    this.start = this.end = this.pos;
    this.startLoc = this.endLoc = this.curPosition();

    // $FlowIgnore
    this.lastTokEndLoc = this.lastTokStartLoc = null;
    this.lastTokStart = this.lastTokEnd = this.pos;

    this.context = [ct.braceStatement];
    this.exprAllowed = true;

    this.containsEsc = this.containsOctal = false;
    this.octalPosition = null;

    this.invalidTemplateEscapePosition = null;

    this.exportedIdentifiers = [];
  }

  // TODO
  strict: boolean;

  // TODO
  input: string;

  // Used to signify the start of a potential arrow function
  potentialArrowAt: number;

  // Used to signify the start of an expression which looks like a
  // typed arrow function, but it isn't
  // e.g. a ? (b) : c => d
  //          ^
  noArrowAt: number[];

  // Used to signify the start of an expression whose params, if it looks like
  // an arrow function, shouldn't be converted to assignable nodes.
  // This is used to defer the validation of typed arrow functions inside
  // conditional expressions.
  // e.g. a ? (b) : c => d
  //          ^
  noArrowParamsConversionAt: number[];

  // Flags to track whether we are in a function, a generator.
  inFunction: boolean;
  inParameters: boolean;
  maybeInArrowParameters: boolean;
  inGenerator: boolean;
  inMethod: boolean | N.MethodKind;
  inAsync: boolean;
  inType: boolean;
  noAnonFunctionType: boolean;
  inPropertyName: boolean;
  inClassProperty: boolean;
  hasFlowComment: boolean;
  isIterator: boolean;

  // Check whether we are in a (nested) class or not.
  classLevel: number;

  // Labels in scope.
  labels: Array<{ kind: ?("loop" | "switch"), statementStart?: number }>;

  // Leading decorators. Last element of the stack represents the decorators in current context.
  // Supports nesting of decorators, e.g. @foo(@bar class inner {}) class outer {}
  // where @foo belongs to the outer class and @bar to the inner
  decoratorStack: Array<Array<N.Decorator>>;

  // The first yield expression inside parenthesized expressions and arrow
  // function parameters. It is used to disallow yield in arrow function
  // parameters.
  yieldInPossibleArrowParameters: ?N.YieldExpression;

  // Token store.
  tokens: Array<Token | N.Comment>;

  // Comment store.
  comments: Array<N.Comment>;

  // Comment attachment store
  trailingComments: Array<N.Comment>;
  leadingComments: Array<N.Comment>;
  commentStack: Array<{
    start: number,
    leadingComments: ?Array<N.Comment>,
    trailingComments: ?Array<N.Comment>,
  }>;
  commentPreviousNode: N.Node;

  // The current position of the tokenizer in the input.
  pos: number;
  lineStart: number;
  curLine: number;

  // Properties of the current token:
  // Its type
  type: TokenType;

  // For tokens that include more information than their type, the value
  value: any;

  // Its start and end offset
  start: number;
  end: number;

  // And, if locations are used, the {line, column} object
  // corresponding to those offsets
  startLoc: Position;
  endLoc: Position;

  // Position information for the previous token
  lastTokEndLoc: Position;
  lastTokStartLoc: Position;
  lastTokStart: number;
  lastTokEnd: number;

  // The context stack is used to superficially track syntactic
  // context to predict whether a regular expression is allowed in a
  // given position.
  context: Array<TokContext>;
  exprAllowed: boolean;

  // Used to signal to callers of `readWord1` whether the word
  // contained any escape sequences. This is needed because words with
  // escape sequences must not be interpreted as keywords.
  containsEsc: boolean;

  // TODO
  containsOctal: boolean;
  octalPosition: ?number;

  // Names of exports store. `default` is stored as a name for both
  // `export default foo;` and `export { foo as default };`.
  exportedIdentifiers: Array<string>;

  invalidTemplateEscapePosition: ?number;

  curPosition(): Position {
    return new Position(this.curLine, this.pos - this.lineStart);
  }

  clone(skipArrays?: boolean): State {
    const state = new State();
    Object.keys(this).forEach(key => {
      // $FlowIgnore
      let val = this[key];

      if ((!skipArrays || key === "context") && Array.isArray(val)) {
        val = val.slice();
      }

      // $FlowIgnore
      state[key] = val;
    });
    return state;
  }
}

// @flow

// ## Token types

// The assignment of fine-grained, information-carrying type objects
// allows the tokenizer to store the information it has about a
// token in a way that is very cheap for the parser to look up.

// All token type variables start with an underscore, to make them
// easy to recognize.

// The `beforeExpr` property is used to disambiguate between regular
// expressions and divisions. It is set on all token types that can
// be followed by an expression (thus, a slash after them would be a
// regular expression).
//
// `isLoop` marks a keyword as starting a loop, which is important
// to know when parsing a label, in order to allow or disallow
// continue jumps to that label.

const beforeExpr = true;
const startsExpr = true;
const isLoop = true;
const isAssign = true;
const prefix = true;
const postfix = true;

type TokenOptions = {
  keyword?: string,

  beforeExpr?: boolean,
  startsExpr?: boolean,
  rightAssociative?: boolean,
  isLoop?: boolean,
  isAssign?: boolean,
  prefix?: boolean,
  postfix?: boolean,
  binop?: ?number,
};

export class TokenType {
  label: string;
  keyword: ?string;
  beforeExpr: boolean;
  startsExpr: boolean;
  rightAssociative: boolean;
  isLoop: boolean;
  isAssign: boolean;
  prefix: boolean;
  postfix: boolean;
  binop: ?number;
  updateContext: ?(prevType: TokenType) => void;

  constructor(label: string, conf: TokenOptions = {}) {
    this.label = label;
    this.keyword = conf.keyword;
    this.beforeExpr = !!conf.beforeExpr;
    this.startsExpr = !!conf.startsExpr;
    this.rightAssociative = !!conf.rightAssociative;
    this.isLoop = !!conf.isLoop;
    this.isAssign = !!conf.isAssign;
    this.prefix = !!conf.prefix;
    this.postfix = !!conf.postfix;
    this.binop = conf.binop === 0 ? 0 : conf.binop || null;
    this.updateContext = null;
  }
}

class KeywordTokenType extends TokenType {
  constructor(name: string, options: TokenOptions = {}) {
    options.keyword = name;

    super(name, options);
  }
}

export class BinopTokenType extends TokenType {
  constructor(name: string, prec: number) {
    super(name, { beforeExpr, binop: prec });
  }
}

export const types: { [name: string]: TokenType } = {
  num: new TokenType("num", { startsExpr }),
  bigint: new TokenType("bigint", { startsExpr }),
  regexp: new TokenType("regexp", { startsExpr }),
  string: new TokenType("string", { startsExpr }),
  name: new TokenType("name", { startsExpr }),
  eof: new TokenType("eof"),

  // Punctuation token types.
  bracketL: new TokenType("[", { beforeExpr, startsExpr }),
  bracketR: new TokenType("]"),
  braceL: new TokenType("{", { beforeExpr, startsExpr }),
  braceBarL: new TokenType("{|", { beforeExpr, startsExpr }),
  braceR: new TokenType("}"),
  braceBarR: new TokenType("|}"),
  parenL: new TokenType("(", { beforeExpr, startsExpr }),
  parenR: new TokenType(")"),
  comma: new TokenType(",", { beforeExpr }),
  semi: new TokenType(";", { beforeExpr }),
  colon: new TokenType(":", { beforeExpr }),
  doubleColon: new TokenType("::", { beforeExpr }),
  dot: new TokenType("."),
  question: new TokenType("?", { beforeExpr }),
  questionDot: new TokenType("?."),
  arrow: new TokenType("=>", { beforeExpr }),
  template: new TokenType("template"),
  ellipsis: new TokenType("...", { beforeExpr }),
  backQuote: new TokenType("`", { startsExpr }),
  dollarBraceL: new TokenType("${", { beforeExpr, startsExpr }),
  at: new TokenType("@"),
  hash: new TokenType("#"),

  // Operators. These carry several kinds of properties to help the
  // parser use them properly (the presence of these properties is
  // what categorizes them as operators).
  //
  // `binop`, when present, specifies that this operator is a binary
  // operator, and will refer to its precedence.
  //
  // `prefix` and `postfix` mark the operator as a prefix or postfix
  // unary operator.
  //
  // `isAssign` marks all of `=`, `+=`, `-=` etcetera, which act as
  // binary operators with a very low precedence, that should result
  // in AssignmentExpression nodes.

  eq: new TokenType("=", { beforeExpr, isAssign }),
  assign: new TokenType("_=", { beforeExpr, isAssign }),
  incDec: new TokenType("++/--", { prefix, postfix, startsExpr }),
  bang: new TokenType("!", { beforeExpr, prefix, startsExpr }),
  tilde: new TokenType("~", { beforeExpr, prefix, startsExpr }),
  pipeline: new BinopTokenType("|>", 0),
  nullishCoalescing: new BinopTokenType("??", 1),
  logicalOR: new BinopTokenType("||", 1),
  logicalAND: new BinopTokenType("&&", 2),
  bitwiseOR: new BinopTokenType("|", 3),
  bitwiseXOR: new BinopTokenType("^", 4),
  bitwiseAND: new BinopTokenType("&", 5),
  equality: new BinopTokenType("==/!=", 6),
  relational: new BinopTokenType("</>", 7),
  bitShift: new BinopTokenType("<</>>", 8),
  plusMin: new TokenType("+/-", { beforeExpr, binop: 9, prefix, startsExpr }),
  modulo: new BinopTokenType("%", 10),
  star: new BinopTokenType("*", 10),
  slash: new BinopTokenType("/", 10),
  exponent: new TokenType("**", {
    beforeExpr,
    binop: 11,
    rightAssociative: true,
  }),
};

export const keywords = {
  break: new KeywordTokenType("break"),
  case: new KeywordTokenType("case", { beforeExpr }),
  catch: new KeywordTokenType("catch"),
  continue: new KeywordTokenType("continue"),
  debugger: new KeywordTokenType("debugger"),
  default: new KeywordTokenType("default", { beforeExpr }),
  do: new KeywordTokenType("do", { isLoop, beforeExpr }),
  else: new KeywordTokenType("else", { beforeExpr }),
  finally: new KeywordTokenType("finally"),
  for: new KeywordTokenType("for", { isLoop }),
  function: new KeywordTokenType("function", { startsExpr }),
  if: new KeywordTokenType("if"),
  return: new KeywordTokenType("return", { beforeExpr }),
  switch: new KeywordTokenType("switch"),
  throw: new KeywordTokenType("throw", { beforeExpr, prefix, startsExpr }),
  try: new KeywordTokenType("try"),
  var: new KeywordTokenType("var"),
  let: new KeywordTokenType("let"),
  const: new KeywordTokenType("const"),
  while: new KeywordTokenType("while", { isLoop }),
  with: new KeywordTokenType("with"),
  new: new KeywordTokenType("new", { beforeExpr, startsExpr }),
  this: new KeywordTokenType("this", { startsExpr }),
  super: new KeywordTokenType("super", { startsExpr }),
  class: new KeywordTokenType("class"),
  extends: new KeywordTokenType("extends", { beforeExpr }),
  export: new KeywordTokenType("export"),
  import: new KeywordTokenType("import", { startsExpr }),
  yield: new KeywordTokenType("yield", { beforeExpr, startsExpr }),
  null: new KeywordTokenType("null", { startsExpr }),
  true: new KeywordTokenType("true", { startsExpr }),
  false: new KeywordTokenType("false", { startsExpr }),
  in: new KeywordTokenType("in", { beforeExpr, binop: 7 }),
  instanceof: new KeywordTokenType("instanceof", { beforeExpr, binop: 7 }),
  typeof: new KeywordTokenType("typeof", { beforeExpr, prefix, startsExpr }),
  void: new KeywordTokenType("void", { beforeExpr, prefix, startsExpr }),
  delete: new KeywordTokenType("delete", { beforeExpr, prefix, startsExpr }),
};

// Map keyword names to token types.
Object.keys(keywords).forEach(name => {
  types["_" + name] = keywords[name];
});

/* eslint max-len: 0 */

// @flow

function makePredicate(words: string): (str: string) => boolean {
  const wordsArr = words.split(" ");
  return function(str) {
    return wordsArr.indexOf(str) >= 0;
  };
}

// Reserved word lists for various dialects of the language

export const reservedWords = {
  "6": makePredicate("enum await"),
  strict: makePredicate(
    "implements interface let package private protected public static yield",
  ),
  strictBind: makePredicate("eval arguments"),
};

// And the keywords

export const isKeyword = makePredicate(
  "break case catch continue debugger default do else finally for function if return switch throw try var while with null true false instanceof typeof void delete new in this let const class extends export import yield super",
);

// ## Character categories

// Big ugly regular expressions that match characters in the
// whitespace, identifier, and identifier-start categories. These
// are only applied when a character is found to actually have a
// code point above 128.
// Generated by `bin/generate-identifier-regex.js`.

/* prettier-ignore */
let nonASCIIidentifierStartChars = "\xaa\xb5\xba\xc0-\xd6\xd8-\xf6\xf8-\u02c1\u02c6-\u02d1\u02e0-\u02e4\u02ec\u02ee\u0370-\u0374\u0376\u0377\u037a-\u037d\u037f\u0386\u0388-\u038a\u038c\u038e-\u03a1\u03a3-\u03f5\u03f7-\u0481\u048a-\u052f\u0531-\u0556\u0559\u0561-\u0587\u05d0-\u05ea\u05f0-\u05f2\u0620-\u064a\u066e\u066f\u0671-\u06d3\u06d5\u06e5\u06e6\u06ee\u06ef\u06fa-\u06fc\u06ff\u0710\u0712-\u072f\u074d-\u07a5\u07b1\u07ca-\u07ea\u07f4\u07f5\u07fa\u0800-\u0815\u081a\u0824\u0828\u0840-\u0858\u0860-\u086a\u08a0-\u08b4\u08b6-\u08bd\u0904-\u0939\u093d\u0950\u0958-\u0961\u0971-\u0980\u0985-\u098c\u098f\u0990\u0993-\u09a8\u09aa-\u09b0\u09b2\u09b6-\u09b9\u09bd\u09ce\u09dc\u09dd\u09df-\u09e1\u09f0\u09f1\u09fc\u0a05-\u0a0a\u0a0f\u0a10\u0a13-\u0a28\u0a2a-\u0a30\u0a32\u0a33\u0a35\u0a36\u0a38\u0a39\u0a59-\u0a5c\u0a5e\u0a72-\u0a74\u0a85-\u0a8d\u0a8f-\u0a91\u0a93-\u0aa8\u0aaa-\u0ab0\u0ab2\u0ab3\u0ab5-\u0ab9\u0abd\u0ad0\u0ae0\u0ae1\u0af9\u0b05-\u0b0c\u0b0f\u0b10\u0b13-\u0b28\u0b2a-\u0b30\u0b32\u0b33\u0b35-\u0b39\u0b3d\u0b5c\u0b5d\u0b5f-\u0b61\u0b71\u0b83\u0b85-\u0b8a\u0b8e-\u0b90\u0b92-\u0b95\u0b99\u0b9a\u0b9c\u0b9e\u0b9f\u0ba3\u0ba4\u0ba8-\u0baa\u0bae-\u0bb9\u0bd0\u0c05-\u0c0c\u0c0e-\u0c10\u0c12-\u0c28\u0c2a-\u0c39\u0c3d\u0c58-\u0c5a\u0c60\u0c61\u0c80\u0c85-\u0c8c\u0c8e-\u0c90\u0c92-\u0ca8\u0caa-\u0cb3\u0cb5-\u0cb9\u0cbd\u0cde\u0ce0\u0ce1\u0cf1\u0cf2\u0d05-\u0d0c\u0d0e-\u0d10\u0d12-\u0d3a\u0d3d\u0d4e\u0d54-\u0d56\u0d5f-\u0d61\u0d7a-\u0d7f\u0d85-\u0d96\u0d9a-\u0db1\u0db3-\u0dbb\u0dbd\u0dc0-\u0dc6\u0e01-\u0e30\u0e32\u0e33\u0e40-\u0e46\u0e81\u0e82\u0e84\u0e87\u0e88\u0e8a\u0e8d\u0e94-\u0e97\u0e99-\u0e9f\u0ea1-\u0ea3\u0ea5\u0ea7\u0eaa\u0eab\u0ead-\u0eb0\u0eb2\u0eb3\u0ebd\u0ec0-\u0ec4\u0ec6\u0edc-\u0edf\u0f00\u0f40-\u0f47\u0f49-\u0f6c\u0f88-\u0f8c\u1000-\u102a\u103f\u1050-\u1055\u105a-\u105d\u1061\u1065\u1066\u106e-\u1070\u1075-\u1081\u108e\u10a0-\u10c5\u10c7\u10cd\u10d0-\u10fa\u10fc-\u1248\u124a-\u124d\u1250-\u1256\u1258\u125a-\u125d\u1260-\u1288\u128a-\u128d\u1290-\u12b0\u12b2-\u12b5\u12b8-\u12be\u12c0\u12c2-\u12c5\u12c8-\u12d6\u12d8-\u1310\u1312-\u1315\u1318-\u135a\u1380-\u138f\u13a0-\u13f5\u13f8-\u13fd\u1401-\u166c\u166f-\u167f\u1681-\u169a\u16a0-\u16ea\u16ee-\u16f8\u1700-\u170c\u170e-\u1711\u1720-\u1731\u1740-\u1751\u1760-\u176c\u176e-\u1770\u1780-\u17b3\u17d7\u17dc\u1820-\u1877\u1880-\u18a8\u18aa\u18b0-\u18f5\u1900-\u191e\u1950-\u196d\u1970-\u1974\u1980-\u19ab\u19b0-\u19c9\u1a00-\u1a16\u1a20-\u1a54\u1aa7\u1b05-\u1b33\u1b45-\u1b4b\u1b83-\u1ba0\u1bae\u1baf\u1bba-\u1be5\u1c00-\u1c23\u1c4d-\u1c4f\u1c5a-\u1c7d\u1c80-\u1c88\u1ce9-\u1cec\u1cee-\u1cf1\u1cf5\u1cf6\u1d00-\u1dbf\u1e00-\u1f15\u1f18-\u1f1d\u1f20-\u1f45\u1f48-\u1f4d\u1f50-\u1f57\u1f59\u1f5b\u1f5d\u1f5f-\u1f7d\u1f80-\u1fb4\u1fb6-\u1fbc\u1fbe\u1fc2-\u1fc4\u1fc6-\u1fcc\u1fd0-\u1fd3\u1fd6-\u1fdb\u1fe0-\u1fec\u1ff2-\u1ff4\u1ff6-\u1ffc\u2071\u207f\u2090-\u209c\u2102\u2107\u210a-\u2113\u2115\u2118-\u211d\u2124\u2126\u2128\u212a-\u2139\u213c-\u213f\u2145-\u2149\u214e\u2160-\u2188\u2c00-\u2c2e\u2c30-\u2c5e\u2c60-\u2ce4\u2ceb-\u2cee\u2cf2\u2cf3\u2d00-\u2d25\u2d27\u2d2d\u2d30-\u2d67\u2d6f\u2d80-\u2d96\u2da0-\u2da6\u2da8-\u2dae\u2db0-\u2db6\u2db8-\u2dbe\u2dc0-\u2dc6\u2dc8-\u2dce\u2dd0-\u2dd6\u2dd8-\u2dde\u3005-\u3007\u3021-\u3029\u3031-\u3035\u3038-\u303c\u3041-\u3096\u309b-\u309f\u30a1-\u30fa\u30fc-\u30ff\u3105-\u312e\u3131-\u318e\u31a0-\u31ba\u31f0-\u31ff\u3400-\u4db5\u4e00-\u9fea\ua000-\ua48c\ua4d0-\ua4fd\ua500-\ua60c\ua610-\ua61f\ua62a\ua62b\ua640-\ua66e\ua67f-\ua69d\ua6a0-\ua6ef\ua717-\ua71f\ua722-\ua788\ua78b-\ua7ae\ua7b0-\ua7b7\ua7f7-\ua801\ua803-\ua805\ua807-\ua80a\ua80c-\ua822\ua840-\ua873\ua882-\ua8b3\ua8f2-\ua8f7\ua8fb\ua8fd\ua90a-\ua925\ua930-\ua946\ua960-\ua97c\ua984-\ua9b2\ua9cf\ua9e0-\ua9e4\ua9e6-\ua9ef\ua9fa-\ua9fe\uaa00-\uaa28\uaa40-\uaa42\uaa44-\uaa4b\uaa60-\uaa76\uaa7a\uaa7e-\uaaaf\uaab1\uaab5\uaab6\uaab9-\uaabd\uaac0\uaac2\uaadb-\uaadd\uaae0-\uaaea\uaaf2-\uaaf4\uab01-\uab06\uab09-\uab0e\uab11-\uab16\uab20-\uab26\uab28-\uab2e\uab30-\uab5a\uab5c-\uab65\uab70-\uabe2\uac00-\ud7a3\ud7b0-\ud7c6\ud7cb-\ud7fb\uf900-\ufa6d\ufa70-\ufad9\ufb00-\ufb06\ufb13-\ufb17\ufb1d\ufb1f-\ufb28\ufb2a-\ufb36\ufb38-\ufb3c\ufb3e\ufb40\ufb41\ufb43\ufb44\ufb46-\ufbb1\ufbd3-\ufd3d\ufd50-\ufd8f\ufd92-\ufdc7\ufdf0-\ufdfb\ufe70-\ufe74\ufe76-\ufefc\uff21-\uff3a\uff41-\uff5a\uff66-\uffbe\uffc2-\uffc7\uffca-\uffcf\uffd2-\uffd7\uffda-\uffdc";
/* prettier-ignore */
let nonASCIIidentifierChars = "\u200c\u200d\xb7\u0300-\u036f\u0387\u0483-\u0487\u0591-\u05bd\u05bf\u05c1\u05c2\u05c4\u05c5\u05c7\u0610-\u061a\u064b-\u0669\u0670\u06d6-\u06dc\u06df-\u06e4\u06e7\u06e8\u06ea-\u06ed\u06f0-\u06f9\u0711\u0730-\u074a\u07a6-\u07b0\u07c0-\u07c9\u07eb-\u07f3\u0816-\u0819\u081b-\u0823\u0825-\u0827\u0829-\u082d\u0859-\u085b\u08d4-\u08e1\u08e3-\u0903\u093a-\u093c\u093e-\u094f\u0951-\u0957\u0962\u0963\u0966-\u096f\u0981-\u0983\u09bc\u09be-\u09c4\u09c7\u09c8\u09cb-\u09cd\u09d7\u09e2\u09e3\u09e6-\u09ef\u0a01-\u0a03\u0a3c\u0a3e-\u0a42\u0a47\u0a48\u0a4b-\u0a4d\u0a51\u0a66-\u0a71\u0a75\u0a81-\u0a83\u0abc\u0abe-\u0ac5\u0ac7-\u0ac9\u0acb-\u0acd\u0ae2\u0ae3\u0ae6-\u0aef\u0afa-\u0aff\u0b01-\u0b03\u0b3c\u0b3e-\u0b44\u0b47\u0b48\u0b4b-\u0b4d\u0b56\u0b57\u0b62\u0b63\u0b66-\u0b6f\u0b82\u0bbe-\u0bc2\u0bc6-\u0bc8\u0bca-\u0bcd\u0bd7\u0be6-\u0bef\u0c00-\u0c03\u0c3e-\u0c44\u0c46-\u0c48\u0c4a-\u0c4d\u0c55\u0c56\u0c62\u0c63\u0c66-\u0c6f\u0c81-\u0c83\u0cbc\u0cbe-\u0cc4\u0cc6-\u0cc8\u0cca-\u0ccd\u0cd5\u0cd6\u0ce2\u0ce3\u0ce6-\u0cef\u0d00-\u0d03\u0d3b\u0d3c\u0d3e-\u0d44\u0d46-\u0d48\u0d4a-\u0d4d\u0d57\u0d62\u0d63\u0d66-\u0d6f\u0d82\u0d83\u0dca\u0dcf-\u0dd4\u0dd6\u0dd8-\u0ddf\u0de6-\u0def\u0df2\u0df3\u0e31\u0e34-\u0e3a\u0e47-\u0e4e\u0e50-\u0e59\u0eb1\u0eb4-\u0eb9\u0ebb\u0ebc\u0ec8-\u0ecd\u0ed0-\u0ed9\u0f18\u0f19\u0f20-\u0f29\u0f35\u0f37\u0f39\u0f3e\u0f3f\u0f71-\u0f84\u0f86\u0f87\u0f8d-\u0f97\u0f99-\u0fbc\u0fc6\u102b-\u103e\u1040-\u1049\u1056-\u1059\u105e-\u1060\u1062-\u1064\u1067-\u106d\u1071-\u1074\u1082-\u108d\u108f-\u109d\u135d-\u135f\u1369-\u1371\u1712-\u1714\u1732-\u1734\u1752\u1753\u1772\u1773\u17b4-\u17d3\u17dd\u17e0-\u17e9\u180b-\u180d\u1810-\u1819\u18a9\u1920-\u192b\u1930-\u193b\u1946-\u194f\u19d0-\u19da\u1a17-\u1a1b\u1a55-\u1a5e\u1a60-\u1a7c\u1a7f-\u1a89\u1a90-\u1a99\u1ab0-\u1abd\u1b00-\u1b04\u1b34-\u1b44\u1b50-\u1b59\u1b6b-\u1b73\u1b80-\u1b82\u1ba1-\u1bad\u1bb0-\u1bb9\u1be6-\u1bf3\u1c24-\u1c37\u1c40-\u1c49\u1c50-\u1c59\u1cd0-\u1cd2\u1cd4-\u1ce8\u1ced\u1cf2-\u1cf4\u1cf7-\u1cf9\u1dc0-\u1df9\u1dfb-\u1dff\u203f\u2040\u2054\u20d0-\u20dc\u20e1\u20e5-\u20f0\u2cef-\u2cf1\u2d7f\u2de0-\u2dff\u302a-\u302f\u3099\u309a\ua620-\ua629\ua66f\ua674-\ua67d\ua69e\ua69f\ua6f0\ua6f1\ua802\ua806\ua80b\ua823-\ua827\ua880\ua881\ua8b4-\ua8c5\ua8d0-\ua8d9\ua8e0-\ua8f1\ua900-\ua909\ua926-\ua92d\ua947-\ua953\ua980-\ua983\ua9b3-\ua9c0\ua9d0-\ua9d9\ua9e5\ua9f0-\ua9f9\uaa29-\uaa36\uaa43\uaa4c\uaa4d\uaa50-\uaa59\uaa7b-\uaa7d\uaab0\uaab2-\uaab4\uaab7\uaab8\uaabe\uaabf\uaac1\uaaeb-\uaaef\uaaf5\uaaf6\uabe3-\uabea\uabec\uabed\uabf0-\uabf9\ufb1e\ufe00-\ufe0f\ufe20-\ufe2f\ufe33\ufe34\ufe4d-\ufe4f\uff10-\uff19\uff3f";

const nonASCIIidentifierStart = new RegExp(
  "[" + nonASCIIidentifierStartChars + "]",
);
const nonASCIIidentifier = new RegExp(
  "[" + nonASCIIidentifierStartChars + nonASCIIidentifierChars + "]",
);

nonASCIIidentifierStartChars = nonASCIIidentifierChars = null;

// These are a run-length and offset encoded representation of the
// >0xffff code points that are a valid part of identifiers. The
// offset starts at 0x10000, and each pair of numbers represents an
// offset to the next range, and then a size of the range. They were
// generated by `bin/generate-identifier-regex.js`.
/* prettier-ignore */
const astralIdentifierStartCodes = [0,11,2,25,2,18,2,1,2,14,3,13,35,122,70,52,268,28,4,48,48,31,14,29,6,37,11,29,3,35,5,7,2,4,43,157,19,35,5,35,5,39,9,51,157,310,10,21,11,7,153,5,3,0,2,43,2,1,4,0,3,22,11,22,10,30,66,18,2,1,11,21,11,25,71,55,7,1,65,0,16,3,2,2,2,26,45,28,4,28,36,7,2,27,28,53,11,21,11,18,14,17,111,72,56,50,14,50,785,52,76,44,33,24,27,35,42,34,4,0,13,47,15,3,22,0,2,0,36,17,2,24,85,6,2,0,2,3,2,14,2,9,8,46,39,7,3,1,3,21,2,6,2,1,2,4,4,0,19,0,13,4,159,52,19,3,54,47,21,1,2,0,185,46,42,3,37,47,21,0,60,42,86,25,391,63,32,0,257,0,11,39,8,0,22,0,12,39,3,3,55,56,264,8,2,36,18,0,50,29,113,6,2,1,2,37,22,0,698,921,103,110,18,195,2749,1070,4050,582,8634,568,8,30,114,29,19,47,17,3,32,20,6,18,881,68,12,0,67,12,65,1,31,6124,20,754,9486,286,82,395,2309,106,6,12,4,8,8,9,5991,84,2,70,2,1,3,0,3,1,3,3,2,11,2,0,2,6,2,64,2,3,3,7,2,6,2,27,2,3,2,4,2,0,4,6,2,339,3,24,2,24,2,30,2,24,2,30,2,24,2,30,2,24,2,30,2,24,2,7,4149,196,60,67,1213,3,2,26,2,1,2,0,3,0,2,9,2,3,2,0,2,0,7,0,5,0,2,0,2,0,2,2,2,1,2,0,3,0,2,0,2,0,2,0,2,0,2,1,2,0,3,3,2,6,2,3,2,3,2,0,2,9,2,16,6,2,2,4,2,16,4421,42710,42,4148,12,221,3,5761,15,7472,3104,541];
/* prettier-ignore */
const astralIdentifierCodes = [509,0,227,0,150,4,294,9,1368,2,2,1,6,3,41,2,5,0,166,1,1306,2,54,14,32,9,16,3,46,10,54,9,7,2,37,13,2,9,52,0,13,2,49,13,10,2,4,9,83,11,7,0,161,11,6,9,7,3,57,0,2,6,3,1,3,2,10,0,11,1,3,6,4,4,193,17,10,9,87,19,13,9,214,6,3,8,28,1,83,16,16,9,82,12,9,9,84,14,5,9,423,9,280,9,41,6,2,3,9,0,10,10,47,15,406,7,2,7,17,9,57,21,2,13,123,5,4,0,2,1,2,6,2,0,9,9,19719,9,135,4,60,6,26,9,1016,45,17,3,19723,1,5319,4,4,5,9,7,3,6,31,3,149,2,1418,49,513,54,5,49,9,0,15,0,23,4,2,14,1361,6,2,16,3,6,2,1,2,4,2214,6,110,6,6,9,792487,239];

// This has a complexity linear to the value of the code. The
// assumption is that looking up astral identifier characters is
// rare.
function isInAstralSet(code: number, set: $ReadOnlyArray<number>): boolean {
  let pos = 0x10000;
  for (let i = 0; i < set.length; i += 2) {
    pos += set[i];
    if (pos > code) return false;

    pos += set[i + 1];
    if (pos >= code) return true;
  }
  return false;
}

// Test whether a given character code starts an identifier.

export function isIdentifierStart(code: number): boolean {
  if (code < 65) return code === 36;
  if (code < 91) return true;
  if (code < 97) return code === 95;
  if (code < 123) return true;
  if (code <= 0xffff) {
    return (
      code >= 0xaa && nonASCIIidentifierStart.test(String.fromCharCode(code))
    );
  }
  return isInAstralSet(code, astralIdentifierStartCodes);
}

// Test whether a current state character code and next character code  is @

export function isIteratorStart(current: number, next: number): boolean {
  return current === 64 && next === 64;
}

// Test whether a given character is part of an identifier.

export function isIdentifierChar(code: number): boolean {
  if (code < 48) return code === 36;
  if (code < 58) return true;
  if (code < 65) return false;
  if (code < 91) return true;
  if (code < 97) return code === 95;
  if (code < 123) return true;
  if (code <= 0xffff) {
    return code >= 0xaa && nonASCIIidentifier.test(String.fromCharCode(code));
  }
  return (
    isInAstralSet(code, astralIdentifierStartCodes) ||
    isInAstralSet(code, astralIdentifierCodes)
  );
}

// @flow

import { lineBreakG } from "./whitespace";

export type Pos = {
  start: number,
};

// These are used when `options.locations` is on, for the
// `startLoc` and `endLoc` properties.

export class Position {
  line: number;
  column: number;

  constructor(line: number, col: number) {
    this.line = line;
    this.column = col;
  }
}

export class SourceLocation {
  start: Position;
  end: Position;
  filename: string;
  identifierName: ?string;

  constructor(start: Position, end?: Position) {
    this.start = start;
    // $FlowIgnore (may start as null, but initialized later)
    this.end = end;
  }
}

// The `getLineInfo` function is mostly useful when the
// `locations` option is off (for performance reasons) and you
// want to find the line/column position for a given character
// offset. `input` should be the code string that the offset refers
// into.

export function getLineInfo(input: string, offset: number): Position {
  for (let line = 1, cur = 0; ; ) {
    lineBreakG.lastIndex = cur;
    const match = lineBreakG.exec(input);
    if (match && match.index < offset) {
      ++line;
      cur = match.index + match[0].length;
    } else {
      return new Position(line, offset - cur);
    }
  }
  // istanbul ignore next
  throw new Error("Unreachable");
}

// @flow

// Matches a whole line break (where CRLF is considered a single
// line break). Used to count lines.

export const lineBreak = /\r\n?|\n|\u2028|\u2029/;
export const lineBreakG = new RegExp(lineBreak.source, "g");

export function isNewLine(code: number): boolean {
  return code === 10 || code === 13 || code === 0x2028 || code === 0x2029;
}

export const nonASCIIwhitespace = /[\u1680\u180e\u2000-\u200a\u202f\u205f\u3000\ufeff]/;

