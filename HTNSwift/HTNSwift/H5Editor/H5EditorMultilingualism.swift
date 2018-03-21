//
//  H5EditorMultilingualism.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/21.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation
//属性类型定义
enum WgPt {
    case none,top,bottom,left,right
}
enum PtEqualRightType {
    case pt,float,color
}
//表达式所需结构
struct PtEqual {
    var leftId = ""
    var left = WgPt.none
    var rightType = PtEqualRightType.pt
    var rightId = ""
    var right = WgPt.none
    var rightFloat = 0
    var rightColor = ""
}
//实现文件所需结构
struct ImpFile {
    var properties = ""
    var initContent = ""
    var getters = ""
}
//接口文件所需结构
struct InterfaceFile {
    
}
//多语言协议规范
protocol H5EditorMultilingualismSpecification {
    var pageId: String {get set}                        //页面 id
    var id: String {get set}                            //动态 id
    func IdProperty(pt: WgPt, idPar: String) -> String  //属性
    func ptEqualToStr(pe:PtEqual) -> String             //属性表达式
    func selfAddSubViewStr(vId: String) -> String       //self添加视图
    func impFile(impf:ImpFile) -> String                //实现文件的内容
    func interfaceFile(intf:InterfaceFile) -> String    //接口文件的内容
}
extension H5EditorMultilingualismSpecification {
    
}

//Objective-C
struct H5EditorObjc: H5EditorMultilingualismSpecification {
    var id = ""
    var pageId = ""
    func selfAddSubViewStr(vId: String) -> String {
        return "[self addSubview:self.\(vId)];"
    }
    
    func IdProperty(pt: WgPt, idPar: String) -> String {
        var idStr = "self.\(self.id)."
        if idPar.count > 0 {
            idStr = "self.\(idPar)."
        }
        var ptStr = ""
        switch pt {
        case .bottom:
            ptStr = "bottom"
        case .left:
            ptStr = "left"
        case .right:
            ptStr = "right"
        case .top:
            ptStr = "top"
        case .none:
            ptStr = ""
        }
        return idStr + ptStr
    }
    
    func ptEqualToStr(pe:PtEqual) -> String {
        let leftStr = IdProperty(pt: pe.left, idPar: pe.leftId)
        var rightStr = ""
        switch pe.rightType {
        case .pt:
            rightStr = IdProperty(pt: pe.right, idPar: pe.rightId)
        case .float:
            rightStr = "\(pe.rightFloat)"
        case .color:
            rightStr = pe.rightColor
        }
        return leftStr + " = " + rightStr + ";"
    }
    
    func impFile(impf: ImpFile) -> String {
        return """
#import <UIKit/UIKit.h>
#import "\(pageId).h"
#import "HTNUI.h"

@interface \(pageId)()
\(impf.properties)
@end

@implementation \(pageId)

- (instancetype)init {
if (self = [super init]) {
\(impf.initContent)
}
return self;
}

\(impf.getters)

@end
"""
    }
    func interfaceFile(intf:InterfaceFile) -> String {
        return """
#import <UIKit/UIKit.h>

@interface \(pageId) : UIView

@end
"""
    }

}

////Swift
//struct H5EditorSwift: H5EditorMultilingualismSpecification {
//    var id = ""
//    var left = "left"
//    var right = "right"
//    var top = "top"
//    var bottom = "bottom"
//    func flowTopSetNormal(lastWidgetId: String) -> String {
//        return "\(id).top = \(lastWidgetId).bottom;"
//    }
//}

