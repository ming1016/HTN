//
//  File.swift
//  HTN
//
//  Created by DaiMing on 2018/5/9.
//

import Foundation

public enum JTokenOption {
    case beforeExpr
    case startsExpr
    case rightAssociative
    case isLoop
    case isAssign
    case prefix
    case postfix
}
// ES 标准
public enum JTokenType:String {
    case none
    
    case float
    case int
    case bingint
    
    case string    // 字符
    case name      // 命名
    case eof       // 间隔，换行
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

