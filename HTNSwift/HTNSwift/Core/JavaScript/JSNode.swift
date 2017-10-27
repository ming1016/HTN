//
//  JSNode.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/25.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

//参考 EcmaScript 的 BNF http://tomcopeland.blogs.com/EcmaScript.html
class JSNode : Node {
    
    
    class ExpressionNode: JSNode {
        var assignmentExpressionList = [AssignmentExpressionNode]()
    }
    class AssignmentExpressionNode: JSNode {
        var leftHandSideExpression = LeftHandSideExpressionNode()
        var assignmentOperator = AssignmentOperatorNode()
        var assignmentExpression: AssignmentExpressionNode?
        var conditionalExpression: ConditionalExpressionNode?
    }
    //左表达式
    class LeftHandSideExpressionNode: JSNode {
        //callExpression 和 memberExpression 有其一
        var callExpression: CallExpressionNode?
        var  memberExpression: MemberExpressionNode?
    }
    class CallExpressionNode: JSNode {
        var memberExpression = MemberExpressionNode()
        var argumentList = [AssignmentExpressionNode]() // 通过 "(" 和 ")" 把以 "," 分割的 AssignmentExpressionNode 集到一起
        var callExpressionPartList = [CallExpressionPartNode]()
    }
    
    class CallExpressionPartNode: JSNode {
        //argumentList 和 bracketExpressionList 有其一
        var argumentList: [AssignmentExpressionNode]?
        var bracketExpression: ExpressionNode? // "[" 和 "]" 包含的 expression
        var dotIdentifier: String? // "." identifier
    }
    
    class MemberExpressionNode: JSNode {
        // BNF 的表达式 MemberExpression ::= (( FunctionExpression | PrimaryExpression ) ( MemberExpressionPart )*) | AllocationExpression
        // 根据 BNF 可以按照如果有 allocationExpression 后面就不处理，如果没有后面在 functionExpression 和 primaryExpression 里看有哪个就用那个
        var allocationExpression: AllocationExpressionNode?
        
        var functionExpression: FunctionExpressionNode?
        var primaryExpression: PrimaryExpressionNode?
        var memberExpressionPartList: [MemberExpressionPartNode]?
        
    }
    class MemberExpressionPartNode: JSNode {
        var bracketExpressionList: [ExpressionNode]? //"[" 和 "]" 包含的 expression
        var dotIdentifier: String? // "." identifier
    }
    class FunctionExpressionNode: JSNode {
        var identifier: String? // "function" 后跟的函数名
        var formalParameterList: FormalParameterListNode? //"(" 和 ")" 里的参数列表
        var functionBody = FunctionBodyNode()
    }
    class FormalParameterListNode: JSNode {
        var identifierList = [String]() //根据 "," 区分为不同的参数
    }
    class FunctionBodyNode: JSNode {
        var sourceElementList: [SourceElementNode]?
    }
    class SourceElementNode: JSNode {
        var functionDeclaration: FunctionDeclarationNode?
        var statement: StatementNode?
    }
    class FunctionDeclarationNode: JSNode {
        var identifier = "" // "function" 后跟的函数名
        var formalParameterList: FormalParameterListNode? //"(" 和 ")" 里的参数列表
        var functionBody = FunctionBodyNode()
    }
    class StatementNode: JSNode {
        var statementType = StatementType.Unknown
        var block: BlockNode?
        var jscriptVarStatement: JScriptVarStatementNode?
        var variableStatement: VariableStatementNode?
        var emptyStatement: EmptyStatementNode?
        var labelledStatement: LabelledStatementNode?
        var expressionStatement: ExpressionStatementNode?
        var ifStatement: IfStatementNode?
        var iterationStatement: IterationStatementNode?
        var continueStatement: ContinueStatementNode?
        var breakStatement: BreakStatementNode?
        var importStatement: ImportStatementNode?
        var returnStatement: ReturnStatementNode?
        var withStatement: WithStatementNode?
        var switchStatement: SwitchStatementNode?
        var throwStatement: ThrowStatementNode?
        var tryStatement: TryStatementNode?
    }
    class PrimaryExpressionNode: JSNode {
        var primaryExpressionType = PrimaryExpressionType.Unknow
        var objectLiteral: ObjectLiteralNode?
        var expressionList: [ExpressionNode]?
        var identifier: String?
        var arrayLiteral: [AssignmentExpressionNode]?
        var Literal: String?
    }
    class ObjectLiteralNode: JSNode {
        // "{" 和 "}" 之间
        var propertyNameAndValueList: [PropertyNameAndValue]? // "," 号分割
    }
    class PropertyNameAndValue: JSNode {
        //根据 ":" 号分为左右两个部分
        var propertyName = ""
        var assignmentExpression = AssignmentExpressionNode()
    }
    
    class AllocationExpressionNode: JSNode {
        //AllocationExpression ::= ( "new" MemberExpression (( Arguments ( MemberExpressionPart )*)*))
        var memberExpression = MemberExpressionNode()
        var argumentList = [AssignmentExpressionNode]() // 通过 "(" 和 ")" 把以 "," 分割的 AssignmentExpressionNode 集到一起
        var callExpressionPartList = [CallExpressionPartNode]()
    }
    
    class AssignmentOperatorNode: JSNode {
        var assignmentOperatorType = AssignmentOperatorType.Unknown
    }
    class ConditionalExpressionNode: JSNode {
        //ConditionalExpression ::= LogicalORExpression ( "?" AssignmentExpression ":" AssignmentExpression )?
        var logicalORExpression = LogicalORExpressionNode()
        var assignmentExpression = AssignmentExpressionNode()
        var elseAssignmentExpression = AssignmentExpressionNode()
    }
    class LogicalORExpressionNode: JSNode {
        //LogicalORExpression ::= LogicalANDExpression ( LogicalOROperator LogicalANDExpression )*
        //LogicalOROperator = "||"
        var logicalANDExpressionLeft = LogicalANDExpressionNode()
        var logicalANDExpressionRight = LogicalANDExpressionNode()
    }
    class LogicalANDExpressionNode: JSNode {
        //LogicalANDExpression ::= BitwiseORExpression ( LogicalANDOperator BitwiseORExpression )*
        //LogicalANDOperator = "&&"
        var bitwiseORExpressionLeft = BitwiseORExpressionNode()
        var bitwiseORExpressionRight = BitwiseORExpressionNode()
    }
    class BitwiseORExpressionNode: JSNode {
        //BitwiseORExpression ::= BitwiseXORExpression ( BitwiseOROperator BitwiseXORExpression )*
        //BitwiseOROperator = "|"
        var bitwiseXORExpressionLeft = BitwiseXORExpressionNode()
        var bitwiseXORExpressionRight = BitwiseXORExpressionNode()
    }
    class BitwiseXORExpressionNode: JSNode {
        //BitwiseXORExpression ::= BitwiseANDExpression ( BitwiseXOROperator BitwiseANDExpression )*
        //BitwiseXOROperator = "^"
        var bitwiseANDExpressionLeft = BitwiseANDExpressionNode()
        var bitwiseANDExpressionRight = BitwiseANDExpressionNode()
    }
    class BitwiseANDExpressionNode: JSNode {
        //BitwiseANDExpression ::= EqualityExpression ( BitwiseANDOperator EqualityExpression )*
        //BitwiseXOROperator = "&"
        var equalityExpressionLeft = EqualityExpressionNode()
        var equalityExpressionRight = EqualityExpressionNode()
    }
    class EqualityExpressionNode: JSNode {
        //EqualityExpression ::= RelationalExpression ( EqualityOperator RelationalExpression )*
        //EqualityOperator ::= ( "==" | "!=" | "===" | "!==" )
        var relationalExpressionLeft = RelationalExpressionNode()
        var relationalExpressionRight = RelationalExpressionNode()
        var equalityOperatorType = EqualityOperatorType.Unknown
    }
    class RelationalExpressionNode: JSNode {
        //RelationalExpression ::= ShiftExpression ( RelationalOperator ShiftExpression )*
        //RelationalOperator ::= ( "<" | ">" | "<=" | ">=" | "instanceof" | "in" )
        var shiftExpressionLeft = ShiftExpressionNode()
        var shiftExpressionRight = ShiftExpressionNode()
        var relationalOperatorType = RelationalOperator.Unknown
    }
    class ShiftExpressionNode: JSNode {
        //ShiftExpression ::= AdditiveExpression ( ShiftOperator AdditiveExpression )*
        //ShiftOperator ::= ( "<<" | ">>" | ">>>" )
        var additiveExpressionLeft = AdditiveExpressionNode()
        var additiveExpressionRight = AdditiveExpressionNode()
        
    }
    class AdditiveExpressionNode: JSNode {
        
    }
    
    //S
    
    //RelationalOperator Type
    enum RelationalOperator {
        case Unknown
        case AngleBracketLeft       // <
        case AngleBracketRight      // >
        case AngleBracketLeftEqual  // <=
        case AngleBracketRightEqual // >=
        case instanceof             // instance
        case inkeyword              // in
    }
    
    //EqualityOperator Type
    enum EqualityOperatorType {
        case Unknown
        case DoubleEqual          // ==
        case ExclamationMarkEqual // !=
        case TripleEqual          // ===
        case ExclamationMarkDoubleEqual // !==
    }
    
    //AssignmentOperator Type
    enum AssignmentOperatorType {
        case Unknown
        case Equal          //=
        case AsteriskEqual  //*=
        case SlashAssign    // /
        case PercentEqual   //%=
        case AddEqual       //+=
        case MinusEqual     //-=
        case DoubleAngleBracketLeft  //<<=
        case DoubleAngleBracketRight //>>=
        case TripleAngleBracketRight //>>>=
        case AmpersandEqual   //&=
        case CaretEqual       //^=
        case VerticalLineEqual //|=
    }
    
    //PrimaryExpression Type
    enum PrimaryExpressionType {
        case Unknow
        case This
        case ObjectLiteral
        case ExpressionList
        case Identifier
        case ArrayLiteral
        case Literal
    }
    
    //Statement Type
    enum StatementType {
        case Unknown
        case Block
        case JScriptVarStatement
        case VariableStatement
        case EmptyStatement
        case LabelledStatement
        case ExpressionStatement
        case IfStatement
        case IterationStatement
        case ContinueStatement
        case BreakStatement
        case ImportStatement
        case ReturnStatement
        case WithStatement
        case SwitchStatement
        case ThrowStatement
        case TryStatement
    }
    class BlockNode: JSNode {
        
    }
    class JScriptVarStatementNode: JSNode {
        
    }
    class VariableStatementNode: JSNode {
        
    }
    class EmptyStatementNode: JSNode {
        
    }
    class LabelledStatementNode: JSNode {
        
    }
    class ExpressionStatementNode: JSNode {
        
    }
    class IfStatementNode: JSNode {
        
    }
    class IterationStatementNode: JSNode {
        
    }
    class ContinueStatementNode: JSNode {
        
    }
    class BreakStatementNode: JSNode {
        
    }
    class ImportStatementNode: JSNode {
        
    }
    class ReturnStatementNode: JSNode {
        
    }
    class WithStatementNode: JSNode {
        
    }
    class SwitchStatementNode: JSNode {
        
    }
    class ThrowStatementNode: JSNode {
        
    }
    class TryStatementNode: JSNode {
        
    }
}








