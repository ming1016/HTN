//
//  JSTokenizer.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/30.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

public class JSTokenizer {
    private var _input: String
    private var _index: String.Index
    private var _bufferStr: String
    private var _bufferToken: JSToken
    private var _tks: [JSToken]
    
    public init(_ input: String) {
        _input = input
        _index = input.startIndex
        _bufferStr = ""
        _bufferToken = JSToken()
        _tks = [JSToken]()
    }
    //TODO: 解决最后一个 char 如果不是关键字会被忽略掉
    public func parse() -> [JSToken] {
        let newStr = dislodgeAnnotaion(content: _input)
        _input = newStr
        _index = newStr.startIndex
        
        
        let stateMachine = HTNStateMachine<S, E>(S.Data)
        
        stateMachine.listen(E.SignleKeywordEvent, transit: S.Data, to: S.Data) { (t) in
            self._bufferToken.type = .Char
            self._bufferToken.data = self._bufferStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if self._bufferToken.data != "" {
                self.addToken()
            }
            self.advanceIndexAndResetCurrentBuffer()
        }
        stateMachine.listen(E.MultiKeywordEvent, transit: S.Data, to: S.Data) { (t) in
            self._bufferToken.type = .KeyWords
            self._bufferToken.data = self._bufferStr.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.addToken()
            self.advanceIndexAndResetCurrentBuffer()
        }
        let singleCharKeywordArray = [",",".",":",";","?","(",")","[","]","{","}","|","^","&","<",">","+","-","*","/","%","~","=","\"","'","!","\n"]
        let multiCharKeywordArray = ["instance","in","delete","void","typeof","var","new","function","do","while","for","in","continue","break","import","return","with","switch","case","default","throw","try","finally","catch","if","else","const"];
        
        while let aChar = currentChar {
            let aStr = aChar.description
            if singleCharKeywordArray.contains(aStr) {
                //添加 bufferStr
                if multiCharKeywordArray.contains(_bufferStr.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) {
                    _ = stateMachine.trigger(E.MultiKeywordEvent)
                } else {
                    _ = stateMachine.trigger(E.SignleKeywordEvent)
                }
                //添加 keyword
                _bufferToken.data = aStr
                _bufferToken.type = .KeyWords
                _tks.append(_bufferToken)
                _bufferToken = JSToken()
                continue
            } else {
                addBufferStr(aStr)
            }
            
            if aStr == " " {
                //处理 for in 里的 in 关键字的情况
                if _bufferStr.hasSuffix(" in ") {
                    self._bufferToken.data = _bufferStr.dropLast(4).description
                    self._bufferToken.type = .Char
                    _tks.append(_bufferToken)
                    _bufferToken = JSToken()
                    
                    self._bufferToken.data = "in"
                    self._bufferToken.type = .KeyWords
                    _tks.append(_bufferToken)
                    _bufferToken = JSToken()
                    
                    self.advanceIndexAndResetCurrentBuffer()
                    continue
                }
                //处理多字符关键字情况
                if multiCharKeywordArray.contains(_bufferStr.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) {
                    _ = stateMachine.trigger(E.MultiKeywordEvent)
                    continue
                }
            }
            
            self.advanceIndex()
        }
        return _tks
    }
    
    //tinyTool
    // 清理注释
    func dislodgeAnnotaion(content:String) -> String {
        
        let annotationBlockPattern = "/\\*[\\s\\S]*?\\*/" //匹配/*...*/这样的注释
        let annotationLinePattern = "//.*?\\n" //匹配//这样的注释
        
        let regexBlock = try! NSRegularExpression(pattern: annotationBlockPattern, options: NSRegularExpression.Options(rawValue:0))
        let regexLine = try! NSRegularExpression(pattern: annotationLinePattern, options: NSRegularExpression.Options(rawValue:0))
        var newStr = ""
        newStr = regexLine.stringByReplacingMatches(in: content, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, content.characters.count), withTemplate: "")
        newStr = regexBlock.stringByReplacingMatches(in: newStr, options: NSRegularExpression.MatchingOptions(rawValue:0), range: NSMakeRange(0, newStr.characters.count), withTemplate: "")
        return newStr
    }
    var currentChar: Character? {
        return _index < _input.endIndex ? _input[_index] : nil
    }
    func addBufferStr(_ bufferStr: String) {
        _bufferStr += bufferStr
    }
    func isQuotation(s: String) -> Bool {
        if s == "\"" || s == "'" {
            return true
        }
        return false
    }
    
    //添加 token
    func addToken() {
        let tk = _bufferToken
        _tks.append(tk)
        _bufferToken = JSToken()
    }
    func advanceIndex() {
        _input.characters.formIndex(after: &_index)
    }
    func advanceIndexAndResetCurrentBuffer() {
        _bufferStr = ""
        advanceIndex()
    }
    
    //
    enum S: HTNStateType {
        case Data
        case StartQuotation
        
    }
    enum E: HTNEventType {
        case SignleKeywordEvent
        case MultiKeywordEvent
//        case CommaEvent             // , expression 里区分不同的 expression
//        case DotEvent               // .
//        case ColonEvent             // :
//        case SemicolonEvent         // ;
//        case QuestionMarkEvent      // ?
//        case RoundBracketLeftEvent  // (
//        case RoundBracketRightEvent // )
//        case BracketLeftEvent       // [
//        case BracketRightEvent      // ]
//        case BraceLeftEvent         // {
//        case BraceRightEvent        // }
        
//        case DoubleVerticalLineEvent   // ||
//        case DoubleAmpersandEvent      // &&
//        case VerticalLineEvent         // |
//        case CaretEvent                // ^
//        case AmpersandEvent            // &
//        case DoubleEqualEvent          // ==
//        case ExclamationMarkEqualEvent // !=
//        case TripleEqualEvent          // ===
//        case ExclamationMarkDoubleEqualEvent // !==
//        case AngleBracketLeftEvent       // <
//        case AngleBracketRightEvent      // >
//        case AngleBracketLeftEqualEvent  // <=
//        case AngleBracketRightEqualEvent // >=
//        case instanceofEvent             // instance
//        case inEvent                     // in
//        case DoubleAngleBracketLeftEvent  // <<
//        case DoubleAngleBracketRIghtEvent // >>
//        case TripleAngleBracketRightEvent // >>>
//        case AddEvent                     // +
//        case MinusEvent                   // -
//        case AsteriskEvent                // *
//        case SlashEvent                   // /
//        case PercentEvent                 // %
//        case DeleteEvent                  // delete
//        case VoidEvent                    // void
//        case TypeofEvent                  // typeof
//        case DoubleAddEvent               // ++
//        case DoubleMinusEvent             // --
//        case TildeEvent                   // ~
//        case VarEvent                     // var
        
//        case EqualEvent          // =
//        case AsteriskEqualEvent  // *=
//        case SlashAssignEvent    // /=
//        case PercentEqualEvent   // %=
//        case AddEqualEvent       // +=
//        case MinusEqualEvent     // -=
//        case DoubleAngleBracketLeftEqualEvent  // <<=
//        case DoubleAngleBracketRightEqualEvent // >>=
//        case TripleAngleBracketRightEqualEvent // >>>=
//        case AmpersandEqualEvent     // &=
//        case CaretEqualEvent         // ^=
//        case VerticalLineEqualEvent  // |=
        
//        case NewEvent      // new
//        case FunctionEvent // function
//        case DoEvent       // do
//        case WhileEvent    // while
//        case ForEvent      // for
//        case InEvent       // in
//        case ContinueEvent // continue
//        case BreakEvent    // break
//        case ImportEvent   // import
//        case ReturnEvent   // return
//        case WithEvent     // with
//        case SwitchEvent   // switch
//        case CaseEvent     // case
//        case DefaultEvent  // default
//        case ThrowEvent    // throw
//        case TryEvent      // try
//        case FinallyEvent  // finally
//        case catchEvent    // catch
    }
}



