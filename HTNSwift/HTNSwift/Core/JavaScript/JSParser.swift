//
//  JSParser.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/25.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

class JSParser {
    //
    enum S: HTNStateType {
        case UnknownState
    }
    enum E: HTNEventType {
        case CommaEvent             // , expression 里区分不同的 expression
        case DotEvent               // .
        case ColonEvent             // :
        case SemicolonEvent         // ;
        case QuestionMarkEvent      // ?
        case RoundBracketLeftEvent  // (
        case RoundBracketRightEvent // )
        case BracketLeftEvent       // [
        case BracketRightEvent      // ]
        case BraceLeftEvent         // {
        case BraceRightEvent        // }
        
        case DoubleVerticalLineEvent   // ||
        case DoubleAmpersandEvent      // &&
        case VerticalLineEvent         // |
        case CaretEvent                // ^
        case AmpersandEvent            // &
        case DoubleEqualEvent          // ==
        case ExclamationMarkEqualEvent // !=
        case TripleEqualEvent          // ===
        case ExclamationMarkDoubleEqualEvent // !==
        case AngleBracketLeftEvent       // <
        case AngleBracketRightEvent      // >
        case AngleBracketLeftEqualEvent  // <=
        case AngleBracketRightEqualEvent // >=
        case instanceofEvent             // instance
        case inEvent                     // in
        case DoubleAngleBracketLeftEvent  // <<
        case DoubleAngleBracketRIghtEvent // >>
        case TripleAngleBracketRightEvent // >>>
        case AddEvent                     // +
        case MinusEvent                   // -
        case AsteriskEvent                // *
        case SlashEvent                   // /
        case PercentEvent                 // %
        case DeleteEvent                  // delete
        case VoidEvent                    // void
        case TypeofEvent                  // typeof
        case DoubleAddEvent               // ++
        case DoubleMinusEvent             // --
        case TildeEvent                   // ~
        case VarEvent                     // var
        
        case EqualEvent          // =
        case AsteriskEqualEvent  //*=
        case SlashAssignEvent    // /=
        case PercentEqualEvent   //%=
        case AddEqualEvent       //+=
        case MinusEqualEvent     //-=
        case DoubleAngleBracketLeftEqualEvent  //<<=
        case DoubleAngleBracketRightEqualEvent //>>=
        case TripleAngleBracketRightEqualEvent //>>>=
        case AmpersandEqualEvent     //&=
        case CaretEqualEvent         //^=
        case VerticalLineEqualEvent  //|=
        
        case NewEvent      // new
        case FunctionEvent // function
        case DoEvent       // do
        case WhileEvent    // while
        case ForEvent      // for
        case InEvent       // in
        case ContinueEvent // continue
        case BreakEvent    // break
        case ImportEvent   // import
        case ReturnEvent   // return
        case WithEvent     // with
        case SwitchEvent   // switch
        case CaseEvent     // case
        case DefaultEvent  // default
        case ThrowEvent    // throw
        case TryEvent      // try
        case FinallyEvent  // finally
        case catchEvent    // catch
    }
}
