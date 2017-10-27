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
        
        
        case EqualEvent          // =
        case AsteriskEqualEvent  //*=
        case SlashAssignEvent    // /
        case PercentEqualEvent   //%=
        case AddEqualEvent       //+=
        case MinusEqualEvent     //-=
        case DoubleAngleBracketLeftEvent  //<<=
        case DoubleAngleBracketRightEvent //>>=
        case TripleAngleBracketRightEvent //>>>=
        case AmpersandEqualEvent     //&=
        case CaretEqualEvent         //^=
        case VerticalLineEqualEvent  //|=
        
        case NewEvent      // new
        case FunctionEvent // function
    }
}
