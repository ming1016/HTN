//
//  OCStaticAnalyzer.swift
//  HTN
//
//  Created by DaiMing on 2018/7/4.
//

import Foundation

public class OCStaticAnalyzer: OCVisitor {
    private var symbolTable = OCSymbolTable(name: "global")
    
    public init() {
        
    }
    
    public func analyze(node: OCAST) -> OCSymbolTable {
        visit(node: node)
        return symbolTable
    }
    
    func visit(propertyDeclaration: OCPropertyDeclaration) {
        guard symbolTable.lookup(propertyDeclaration.name) == nil else {
            fatalError("Error: duplicate identifier \(propertyDeclaration.name) found")
        }
        
        guard let symbolType = symbolTable.lookup(propertyDeclaration.type) else {
            fatalError("Error: \(propertyDeclaration.type) type not found")
        }
        
        symbolTable.define(OCVariableSymbol(name: propertyDeclaration.name, type: symbolType))
    }
    
    func visit(variable: OCVar) {
        guard symbolTable.lookup(variable.name) != nil else {
            fatalError("Error: \(variable.name) variable not found")
        }
    }
    
    func visit(assign: OCAssign) {
        guard symbolTable.lookup(assign.left.name) != nil else {
            fatalError("Error: \(assign.left.name) not found")
        }
    }
    
}
