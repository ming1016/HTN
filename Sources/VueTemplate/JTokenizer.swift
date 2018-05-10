//
//  JTokenizer.swift
//  HTN
//
//  Created by DaiMing on 2018/4/27.
//

import Foundation

public struct JToken {
    public var type = JTokenType.none
    public var value = ""
    public var options = [JTokenOption]()
    public var priority:Int = 0
}

public class JTokenizer {
    private var _input: String
    private var _index: String.Index
    
    public init(_ input: String) {
        _input = input.filterAnnotationBlock()
        _index = _input.startIndex
    }
    
    public func tokenizer() -> [JToken] {
        var tokens = [JToken]()
        
        let symbols = ["[", "]", "{", "{|", "}", "|}", "|", "(", ")", ",", ":", "::", ".", "?", "?.", "=>", "...", "=", "_=", "++", "--", ">", "`", "${", "$", "@", "#", "_", "=", "+", "!", "~", "|>", "??", "||", "&&", "&", "==", "!=", "^", "<", "<<", ">>", "-", "%", "*", "/", "**"]
        let eofs = [" ", "\n", ";"]
        
        while let aChar = currentChar {
            
            let s = aChar.description
            
            // 处理 " 和 ' 符号，需要处理转义和另一个 " 和 ' 符号作为结束
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
            
            // 处理 / 符号，这个是正则的处理，比如 if (/[0-9\.]/.test(currentChar)) {
            if s == "/" {
                var cSb = ""
                var escaped = false
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
                        var tk = JToken()
                        tk.type = .slash
                        tk.value = s
                        tokens.append(tk)
                        
                        break
                    }
                }
                var tk = JToken()
                tk.type = .regular
                tk.value = cSb
                tokens.append(tk)
                continue
            }
            
            
            // 处理 " ", "\n", ";"
            if eofs.contains(s) {
                // 空格
                advanceIndex()
                continue
            }
            
            if symbols.contains(s) {
                // 处理符号
                var cSb = ""
                while let cChar = currentChar {
                    let sb = cChar.description
                    if eofs.contains(sb) {
                        break
                    }
                    let checkForwardStr = cSb + sb
                    if symbols.contains(checkForwardStr) {
                        cSb = checkForwardStr
                    } else {
                        break
                    }
                    advanceIndex()
                    continue
                }
                tokens.append(tokenFrom(cSb))
                continue
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
                continue
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
                    tokens.append(tokenFrom(word))
                }
                continue
            } // end if else
        } // end while
        
        return tokens
    }
    
    func tokenFrom(_ input:String) -> JToken {
        var tk = JToken()
        switch input {
        case "[":
            tk.type = .braceL
        case "]":
            tk.type = .braceR
        case "{":
            tk.type = .braceL
        case "{|":
            tk.type = .braceBarL
        case "}":
            tk.type = .braceR
        case "|}":
            tk.type = .braceBarR
        case "(":
            tk.type = .parenL
        case ")":
            tk.type = .parenR
        case ",":
            tk.type = .comma
        case ";":
            tk.type = .semi
        case ":":
            tk.type = .colon
        case "::":
            tk.type = .doubleColon
        case ".":
            tk.type = .dot
        case "?":
            tk.type = .question
        case "?.":
            tk.type = .questiondot
        case "=>":
            tk.type = .arrow
        case "...":
            tk.type = .ellipsis
        case "`":
            tk.type = .backQuote
        case "${":
            tk.type = .dollarBraceL
        case "@":
            tk.type = .at
        case "#":
            tk.type = .hash
        
        // 操作符
        case "=":
            tk.type = .eq
        case "_=":
            tk.type = .assign
        case "++", "--":
            tk.type = .incDec
        case "!":
            tk.type = .bang
        case "~":
            tk.type = .tilde
        
        // 有优先级的操作符
        case "|>":
            tk.type = .pipleline
        case "??":
            tk.type = .nullishCoalescing
        case "||":
            tk.type = .logicalOR
        case "&&":
            tk.type = .logicalAND
        case "|":
            tk.type = .bitwiseOR
        case "^":
            tk.type = .bitwiseXOR
        case "&":
            tk.type = .bitwiseAND
        case "==", "!=", "===":
            tk.type = .equality
        case "<", ">":
            tk.type = .relational
        case "<<", ">>":
            tk.type = .bitShift
        case "+", "-":
            tk.type = .plusMin
        case "%":
            tk.type = .modulo
        case "*":
            tk.type = .star
        case "/":
            tk.type = .slash
        case "**":
            tk.type = .exponent
        
        // 关键字
        case "template":
            tk.type = .template
        case "break":
            tk.type = .break
        case "case":
            tk.type = .case
        case "catch":
            tk.type = .catch
        case "continue":
            tk.type = .continue
        case "debugger":
            tk.type = .debugger
        case "default":
            tk.type = .default
        case "do":
            tk.type = .do
        case "else":
            tk.type = .else
        case "finally":
            tk.type = .finally
        case "for":
            tk.type = .for
        case "function":
            tk.type = .function
        case "if":
            tk.type = .if
        case "return":
            tk.type = .return
        case "switch":
            tk.type = .switch
        case "throw":
            tk.type = .throw
        case "try":
            tk.type = .try
        case "var":
            tk.type = .var
        case "let":
            tk.type = .let
        case "const":
            tk.type = .const
        case "while":
            tk.type = .while
        case "with":
            tk.type = .with
        case "new":
            tk.type = .new
        case "this":
            tk.type = .this
        case "super":
            tk.type = .super
        case "class":
            tk.type = .class
        case "extends":
            tk.type = .extends
        case "export":
            tk.type = .export
        case "import":
            tk.type = .import
        case "yield":
            tk.type = .yield
        case "null":
            tk.type = .null
        case "true":
            tk.type = .true
        case "false":
            tk.type = .false
        case "in":
            tk.type = .in
        case "instance":
            tk.type = .instanceof
        case "typeof":
            tk.type = .typeof
        case "void":
            tk.type = .void
        case "delete":
            tk.type = .delete
            
        default:
            tk.type = .none
        }
        tk.value = input
        return tk
    }
    
    //parser tool
    var currentChar: Character? {
        return _index < _input.endIndex ? _input[_index] : nil
    }
    func advanceIndex() {
        if _index < _input.endIndex {
            _input.formIndex(after: &_index)
        }
        
    }
}
