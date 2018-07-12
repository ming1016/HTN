//
//  OCSymbolTable.swift
//  HTN
//
//  Created by DaiMing on 2018/7/10.
//

import Foundation

public class OCSymbolTable {
    var symbols: [String: OCSymbol] = [:]
    
    let name: String
    
    init(name: String) {
        self.name = name
        defineBuiltInTypes()
    }
    
    private func defineBuiltInTypes() {
        define(OCBuiltInTypeSymbol.integer)
        define(OCBuiltInTypeSymbol.float)
        define(OCBuiltInTypeSymbol.boolean)
        define(OCBuiltInTypeSymbol.string)
    }
    
    func define(_ symbol: OCSymbol) {
        symbols[symbol.name] = symbol
    }
    
    func lookup(_ name: String) -> OCSymbol? {
        if let symbol = symbols[name] {
            return symbol
        }
        return nil
    }
}
