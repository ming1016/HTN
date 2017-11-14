//
//  JSNode.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/25.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

//参考 EcmaScript 的 BNF http://tomcopeland.blogs.com/EcmaScript.html
public class JSNode : Node {
    public var type = NodeType.Unknown
    public var data = ""
    
    public var stackNode: [JSNode]?
    
    
    public enum NodeType:String {
        case Unknown
        case Root
        case VariableStatement   // var
        case VariableDeclarator  //
        case Expression          //等号右侧的表达式
        case Identifier          //对象或变量
        case Operator            //+ - * /
        case Dot
        case Literal             //字符串
        
        case RoundBracket        //()
        case Brace               //{}
        case Bracket             //[]
        
        case CommaSplit          //逗号分隔
        
        case CallExpression      //callee arguments
        case MemberExpression    //computed object property
        case ArrayExpression     //
        case LeftHandSideExpression
        case FunctionExpression
    }
    
    init(type:NodeType) {
        self.type = type
    }
    
    public func des() {
        for aNode in self.children {
            desNode(node: aNode as! JSNode, level: 0)
        }
    }
    
    private func desNode(node:JSNode, level: Int) {
        let  typeStr = node.type.rawValue
        
        var frontStr = ""
        for _ in 0...level {
            if level > 0 {
                frontStr += "   "
            }
        }
        var dataStr = ""
        if node.data.count > 0 {
            dataStr = "data:\(node.data)"
        }
        print("\(frontStr)[\(typeStr)]\(dataStr)")
        
        if node.children.count > 0 {
            for aNode in node.children {
                desNode(node: aNode as! JSNode, level: level + 1)
            }
        }
    }
    
    
    /*-------------------暂时不用下面的-------------------*/
//    class ExpressionNode: JSNode {
//        var assignmentExpressionList = [AssignmentExpressionNode]()
//    }
//    class AssignmentExpressionNode: JSNode {
//        var leftHandSideExpression = LeftHandSideExpressionNode()
//        var assignmentOperator = AssignmentOperatorNode()
//        var assignmentExpression: AssignmentExpressionNode?
//        var conditionalExpression: ConditionalExpressionNode?
//    }
//    //左表达式
//    class LeftHandSideExpressionNode: JSNode {
//        //callExpression 和 memberExpression 有其一
//        var callExpression: CallExpressionNode?
//        var  memberExpression: MemberExpressionNode?
//    }
//    class LeftHandSideExpressionForInNode: JSNode {
////        var callExpressionForIn =
//    }
//    class callExpressionForInNode: JSNode {
//        var memberExpressionForIn = MemberExpressionForInNode()
//        var argumentList = [AssignmentExpressionNode]()
//        var callExpressionPart = [CallExpressionPartNode]()
//    }
//    class MemberExpressionForInNode: JSNode {
//        var functionExpression: FunctionExpressionNode?
//        var PrimaryExpression: PrimaryExpressionNode?
//        var memberExpressionPartList = [MemberExpressionPartNode]()
//    }
//    class CallExpressionNode: JSNode {
//        var memberExpression = MemberExpressionNode()
//        var argumentList = [AssignmentExpressionNode]() // 通过 "(" 和 ")" 把以 "," 分割的 AssignmentExpressionNode 集到一起
//        var callExpressionPartList = [CallExpressionPartNode]()
//    }
//
//    class CallExpressionPartNode: JSNode {
//        //argumentList 和 bracketExpressionList 有其一
//        var argumentList: [AssignmentExpressionNode]?
//        var bracketExpression: ExpressionNode? // "[" 和 "]" 包含的 expression
//        var dotIdentifier: String? // "." identifier
//    }
//
//    class MemberExpressionNode: JSNode {
//        // BNF 的表达式 MemberExpression ::= (( FunctionExpression | PrimaryExpression ) ( MemberExpressionPart )*) | AllocationExpression
//        // 根据 BNF 可以按照如果有 allocationExpression 后面就不处理，如果没有后面在 functionExpression 和 primaryExpression 里看有哪个就用那个
//        var allocationExpression: AllocationExpressionNode?
//
//        var functionExpression: FunctionExpressionNode?
//        var primaryExpression: PrimaryExpressionNode?
//        var memberExpressionPartList: [MemberExpressionPartNode]?
//
//    }
//    class MemberExpressionPartNode: JSNode {
//        var bracketExpressionList: [ExpressionNode]? //"[" 和 "]" 包含的 expression
//        var dotIdentifier: String? // "." identifier
//    }
//    class FunctionExpressionNode: JSNode {
//        var identifier: String? // "function" 后跟的函数名
//        var formalParameterList: [String]? //"(" 和 ")" 里的参数列表
//        var functionBody = FunctionBodyNode()
//    }
//
//    class FunctionBodyNode: JSNode {
//        var sourceElementList: [SourceElementNode]?
//    }
//    class SourceElementNode: JSNode {
//        var functionDeclaration: FunctionDeclarationNode?
//        var statement: StatementNode?
//    }
//    class FunctionDeclarationNode: JSNode {
//        var identifier = "" // "function" 后跟的函数名
//        var formalParameterList: [String]? //"(" 和 ")" 里的参数列表。根据 "," 区分为不同的参数
//        var functionBody = FunctionBodyNode()
//    }
//    class StatementNode: JSNode {
//        var statementType = StatementType.Unknown
//        var block: BlockNode?
//        var jscriptVarStatement: JScriptVarStatementNode?
//        var variableStatement: VariableStatementNode?
//        var emptyStatement: EmptyStatementNode?
//        var labelledStatement: LabelledStatementNode?
//        var expressionStatement: ExpressionStatementNode?
//        var ifStatement: IfStatementNode?
//        var iterationStatement: IterationStatementNode?
//        var continueStatement: ContinueStatementNode?
//        var breakStatement: BreakStatementNode?
//        var importStatement: ImportStatementNode?
//        var returnStatement: ReturnStatementNode?
//        var withStatement: WithStatementNode?
//        var switchStatement: SwitchStatementNode?
//        var throwStatement: ThrowStatementNode?
//        var tryStatement: TryStatementNode?
//    }
//    class PrimaryExpressionNode: JSNode {
//        var primaryExpressionType = PrimaryExpressionType.Unknow
//        var objectLiteral: ObjectLiteralNode?
//        var expressionList: [ExpressionNode]?
//        var identifier: String?
//        var arrayLiteral: [AssignmentExpressionNode]?
//        var Literal: String?
//    }
//    class ObjectLiteralNode: JSNode {
//        // "{" 和 "}" 之间
//        var propertyNameAndValueList: [PropertyNameAndValue]? // "," 号分割
//    }
//    class PropertyNameAndValue: JSNode {
//        //根据 ":" 号分为左右两个部分
//        var propertyName = ""
//        var assignmentExpression = AssignmentExpressionNode()
//    }
//
//    class AllocationExpressionNode: JSNode {
//        //AllocationExpression ::= ( "new" MemberExpression (( Arguments ( MemberExpressionPart )*)*))
//        var memberExpression = MemberExpressionNode()
//        var argumentList = [AssignmentExpressionNode]() // 通过 "(" 和 ")" 把以 "," 分割的 AssignmentExpressionNode 集到一起
//        var callExpressionPartList = [CallExpressionPartNode]()
//    }
//
//    class AssignmentOperatorNode: JSNode {
//        var assignmentOperatorType = AssignmentOperatorType.Unknown
//    }
//    class ConditionalExpressionNode: JSNode {
//        //ConditionalExpression ::= LogicalORExpression ( "?" AssignmentExpression ":" AssignmentExpression )?
//        var logicalORExpression = LogicalORExpressionNode()
//        var assignmentExpression = AssignmentExpressionNode()
//        var elseAssignmentExpression = AssignmentExpressionNode()
//    }
//    class LogicalORExpressionNode: JSNode {
//        //LogicalORExpression ::= LogicalANDExpression ( LogicalOROperator LogicalANDExpression )*
//        //LogicalOROperator = "||"
//        var logicalANDExpressionLeft = LogicalANDExpressionNode()
//        var logicalANDExpressionRight = LogicalANDExpressionNode()
//    }
//    class LogicalANDExpressionNode: JSNode {
//        //LogicalANDExpression ::= BitwiseORExpression ( LogicalANDOperator BitwiseORExpression )*
//        //LogicalANDOperator = "&&"
//        var bitwiseORExpressionLeft = BitwiseORExpressionNode()
//        var bitwiseORExpressionRight = BitwiseORExpressionNode()
//    }
//    class BitwiseORExpressionNode: JSNode {
//        //BitwiseORExpression ::= BitwiseXORExpression ( BitwiseOROperator BitwiseXORExpression )*
//        //BitwiseOROperator = "|"
//        var bitwiseXORExpressionLeft = BitwiseXORExpressionNode()
//        var bitwiseXORExpressionRight = BitwiseXORExpressionNode()
//    }
//    class BitwiseXORExpressionNode: JSNode {
//        //BitwiseXORExpression ::= BitwiseANDExpression ( BitwiseXOROperator BitwiseANDExpression )*
//        //BitwiseXOROperator = "^"
//        var bitwiseANDExpressionLeft = BitwiseANDExpressionNode()
//        var bitwiseANDExpressionRight = BitwiseANDExpressionNode()
//    }
//    class BitwiseANDExpressionNode: JSNode {
//        //BitwiseANDExpression ::= EqualityExpression ( BitwiseANDOperator EqualityExpression )*
//        //BitwiseXOROperator = "&"
//        var equalityExpressionLeft = EqualityExpressionNode()
//        var equalityExpressionRight = EqualityExpressionNode()
//    }
//    class EqualityExpressionNode: JSNode {
//        //EqualityExpression ::= RelationalExpression ( EqualityOperator RelationalExpression )*
//        //EqualityOperator ::= ( "==" | "!=" | "===" | "!==" )
//        var relationalExpressionLeft = RelationalExpressionNode()
//        var relationalExpressionRight = RelationalExpressionNode()
//        var equalityOperatorType = EqualityOperatorType.Unknown
//    }
//    class RelationalExpressionNode: JSNode {
//        //RelationalExpression ::= ShiftExpression ( RelationalOperator ShiftExpression )*
//        //RelationalOperator ::= ( "<" | ">" | "<=" | ">=" | "instanceof" | "in" )
//        var shiftExpressionLeft = ShiftExpressionNode()
//        var shiftExpressionRight = ShiftExpressionNode()
//        var relationalOperatorType = RelationalOperatorType.Unknown
//    }
//    class ShiftExpressionNode: JSNode {
//        //ShiftExpression ::= AdditiveExpression ( ShiftOperator AdditiveExpression )*
//        //ShiftOperator ::= ( "<<" | ">>" | ">>>" )
//        var additiveExpressionLeft = AdditiveExpressionNode()
//        var additiveExpressionRight = AdditiveExpressionNode()
//        var shiftOperatorType = ShiftOperatorType.Unknown
//    }
//    class AdditiveExpressionNode: JSNode {
//        //AdditiveExpression ::= MultiplicativeExpression ( AdditiveOperator MultiplicativeExpression )*
//        //AdditiveOperator ::= ( "+" | "-" )
//        var multiplicativeExpressionLeft = MultiplicativeExpressionNode()
//        var multiplicativeExpressionRight = MultiplicativeExpressionNode()
//        var additiveExpressionType = AdditiveOperatorType.Unknown
//    }
//    class MultiplicativeExpressionNode: JSNode {
//        //MultiplicativeExpression ::= UnaryExpression ( MultiplicativeOperator UnaryExpression )*
//        //MultiplicativeOperator ::= ( "*" | <SLASH> | "%" )
//        var unaryExpressionLeft = UnaryExpressionNode()
//        var unaryExpressionRight = UnaryExpressionNode()
//        var multiplicativeOperatorType = MultiplicativeOperatorType.Unknown
//    }
//    //一元表达式
//    class UnaryExpressionNode: JSNode {
//        //UnaryExpression ::= ( PostfixExpression | ( UnaryOperator UnaryExpression )+ )
//        //UnaryOperator ::= ( "delete" | "void" | "typeof" | "++" | "--" | "+" | "-" | "~" | "!" )
//        var postfixExpression = PostfixExpressionNode()
//        var unaryExpression = UnaryExpressionNode()
//        var unaryOperatorType = UnaryOperatorType.Unknown
//    }
//    class PostfixExpressionNode: JSNode {
//        //PostfixExpression    ::=    LeftHandSideExpression ( PostfixOperator )?
//        var leftHandSideExpression = LeftHandSideExpressionNode()
//        var postfixOperatorType = PostfixOperatorType.Unknown
//    }
//
//    //PostfixOperator Type
//    enum PostfixOperatorType {
//        case Unknown
//        case DoubleAdd   // ++
//        case DoubleMinus // --
//    }
//
//    //UnaryOperator Type
//    enum UnaryOperatorType {
//        case Unknown
//        case Delete                  // delete
//        case Void                    // void
//        case Typeof                  // typeof
//        case DoubleAdd               // ++
//        case DoubleMinus             // --
//        case Add                     // +
//        case Minus                   // -
//        case Tilde                   // ~
//        case ExclamationMark         // !
//    }
//
//    //MultiplicativeOperator Type
//    enum MultiplicativeOperatorType {
//        case Unknown
//        case Asterisk  // *
//        case Slash     // /
//        case Percent   // %
//    }
//
//    //AdditiveExpression Type
//    enum AdditiveOperatorType {
//        case Unknown
//        case Add     // +
//        case Minus   // -
//    }
//
//    //ShiftOperator Type
//    enum ShiftOperatorType {
//        case Unknown
//        case DoubleAngleBracketLeft  // <<
//        case DoubleAngleBracketRIght // >>
//        case TripleAngleBracketRight // >>>
//    }
//
//    //RelationalOperator Type
//    enum RelationalOperatorType {
//        case Unknown
//        case AngleBracketLeft       // <
//        case AngleBracketRight      // >
//        case AngleBracketLeftEqual  // <=
//        case AngleBracketRightEqual // >=
//        case instanceof             // instance
//        case inkeyword              // in
//    }
//
//    //EqualityOperator Type
//    enum EqualityOperatorType {
//        case Unknown
//        case DoubleEqual          // ==
//        case ExclamationMarkEqual // !=
//        case TripleEqual          // ===
//        case ExclamationMarkDoubleEqual // !==
//    }
//
//    //AssignmentOperator Type
//    enum AssignmentOperatorType {
//        case Unknown
//        case Equal          //=
//        case AsteriskEqual  //*=
//        case SlashAssign    // /
//        case PercentEqual   //%=
//        case AddEqual       //+=
//        case MinusEqual     //-=
//        case DoubleAngleBracketLeft  //<<=
//        case DoubleAngleBracketRight //>>=
//        case TripleAngleBracketRight //>>>=
//        case AmpersandEqual   //&=
//        case CaretEqual       //^=
//        case VerticalLineEqual //|=
//    }
//
//    //PrimaryExpression Type
//    enum PrimaryExpressionType {
//        case Unknow
//        case This
//        case ObjectLiteral
//        case ExpressionList
//        case Identifier
//        case ArrayLiteral
//        case Literal
//    }
//
//    //Statement Type
//    enum StatementType {
//        case Unknown
//        case Block
//        case JScriptVarStatement
//        case VariableStatement
//        case EmptyStatement
//        case LabelledStatement
//        case ExpressionStatement
//        case IfStatement
//        case IterationStatement
//        case ContinueStatement
//        case BreakStatement
//        case ImportStatement
//        case ReturnStatement
//        case WithStatement
//        case SwitchStatement
//        case ThrowStatement
//        case TryStatement
//    }
//    class BlockNode: JSNode {
//        //在 "{" 和 "}" 里
//        var statementList: [StatementNode]?
//    }
//    class JScriptVarStatementNode: JSNode {
//        //"var" 开头 "," 分割，";" 结束或者换行结束
//        var jscriptVarDeclarationList = [JScriptVarDeclarationNode]()
//    }
//    //已用
//    class JScriptVarDeclarationNode: JSNode {
//        //JScriptVarDeclaration ::= Identifier ":" <IDENTIFIER_NAME> ( Initialiser )?
//        var identifier = ""
//        var identifierName = ""
////        var initialiser: InitialiserNode?
//        var assignmentExpression: AssignmentExpressionNode? //新添，"=" 后的表达式
//    }
//    class InitialiserNode: JSNode {
//        //"=" 后面的表达式
//        var assignmentExpression = AssignmentExpressionNode()
//    }
//    class VariableStatementNode: JSNode {
//        //"var" 开头 "," 分割，";" 结束或者换行结束
//        var variableDeclarationList = [VariableDeclarationNode]()
//    }
//    class VariableDeclarationNode: JSNode {
//        //VariableDeclaration ::= Identifier ( Initialiser )?
//        var identifier = ""
////        var initialiser: InitialiserNode?
//    }
//    class EmptyStatementNode: JSNode {
//        //EmptyStatement ::= ";"
//    }
//    class LabelledStatementNode: JSNode {
//        //LabelledStatement ::= Identifier ":" Statement
//        var identifier = ""
//        var statement = StatementNode()
//    }
//    class ExpressionStatementNode: JSNode {
//        var expression = ExpressionNode()
//    }
//    class IfStatementNode: JSNode {
//        var expression = ExpressionNode()
//        var ifStatement = StatementNode()
//        var elseStatement = StatementNode()
//    }
//    class IterationStatementNode: JSNode {
//        var iterationStatementType = IterationStatementType.Unknown
//        var statement: StatementNode?
//        var expressionFirst = ExpressionNode()
//        var expressionSecond: ExpressionNode?
//        var variableDeclarationList: [VariableDeclarationNode]?
//        var leftHandSideExpressionForIn: LeftHandSideExpressionForInNode?
//    }
//
//    //IterationStatement Type
//    enum IterationStatementType {
//        case Unknown
//        case DoWhile      //( "do" Statement "while" "(" Expression ")" ( ";" )? )
//        case WhileOnly    //( "while" "(" Expression ")" Statement )
//        //TODO: ExpressionNoIn 的处理，BNF 是 ( "for" "(" ( ExpressionNoIn )? ";" ( Expression )? ";" ( Expression )? ")" Statement )
//        case ForVar       //( "for" "(" "var" VariableDeclarationList ";" ( Expression )? ";" ( Expression )? ")" Statement )
//        //TODO: VariableDeclarationNoIn 的处理 ，BNF 是 ( "for" "(" "var" VariableDeclarationNoIn "in" Expression ")" Statement )
//        case ForIn        //( "for" "(" LeftHandSideExpressionForIn "in" Expression ")" Statement )
//    }
//
//    class ContinueStatementNode: JSNode {
//        //ContinueStatement ::= "continue" ( Identifier )? ( ";" )?
//        var identifier: String?
//    }
//    class BreakStatementNode: JSNode {
//        //BreakStatement ::= "break" ( Identifier )? ( ";" )?
//        var identifier: String?
//    }
//    class ImportStatementNode: JSNode {
//        //ImportStatement ::= "import" Name ( "." "*" )? ";"
////        var name = [String]() //Name ::= <IDENTIFIER_NAME> ( "." <IDENTIFIER_NAME> )*
//    }
//    class ReturnStatementNode: JSNode {
//        //ReturnStatement ::= "return" ( Expression )? ( ";" )?
//        var expression: ExpressionNode?
//    }
//    class WithStatementNode: JSNode {
//        //WithStatement ::= "with" "(" Expression ")" Statement
//        var expression = ExpressionNode()
//        var statement = StatementNode()
//    }
//    class SwitchStatementNode: JSNode {
//        //SwitchStatement ::= "switch" "(" Expression ")" CaseBlock
//        var expression = ExpressionNode()
//        var caseBlock = CaseBlockNode()
//    }
//    class CaseBlockNode: JSNode {
//        //CaseBlock ::= "{" ( CaseClauses )? ( "}" | DefaultClause ( CaseClauses )? "}" )
//        var caseClauseList: [CaseClauseNode]?
//        var defaultClauseList: [DefaultClauseNode]?
//    }
//    class CaseClauseNode: JSNode {
//        //CaseClause ::= ( ( "case" Expression ":" ) ) ( StatementList )?
//        var expression = ExpressionNode()
//        var statementList: [StatementNode]?
//    }
//    class DefaultClauseNode: JSNode {
//        //DefaultClause ::= ( ( "default" ":" ) ) ( StatementList )?
//        var statementList: [StatementNode]?
//    }
//    class ThrowStatementNode: JSNode {
//        //ThrowStatement ::= "throw" Expression ( ";" )?
//        var expression = ExpressionNode()
//    }
//    class TryStatementNode: JSNode {
//        //TryStatement ::= "try" Block ( ( Finally | Catch ( Finally )? ) )
//        var tryBlock = BlockNode()
//        var finallyBlock: BlockNode?
//        var catchNode: CatchNode?
//    }
//    class CatchNode: JSNode {
//        var identifier = ""
//        var block = BlockNode()
//    }
}








