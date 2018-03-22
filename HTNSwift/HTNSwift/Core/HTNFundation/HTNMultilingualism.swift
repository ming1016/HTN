//
//  H5EditorMultilingualism.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/21.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

//多语言协议规范
protocol HTNMultilingualismSpecification {
    var pageId: String {get set}                        //页面 id
    var id: String {get set}                            //动态 id
    func validIdStr(id: String) -> String               //对 id 字符串的合法化
    func viewPtToStrStruct(vpt:ViewPt) -> ViewStrStruct //视图属性转视图结构
    func viewTypeClassStr(vt:ViewType) -> String        //视图类型类名的映射
    func ptEqualToStr(pe:PtEqual) -> String             //属性表达式
    func selfAddSubViewStr(vId: String) -> String       //self添加视图
    func impFile(impf:ImpFile) -> String                //实现文件的内容
    func interfaceFile(intf:InterfaceFile) -> String    //接口文件的内容
    func idProperty(pt: WgPt, idPar: String, prefix: String) -> String  //属性
}
extension HTNMultilingualismSpecification {
    
}
/*-----------协议所需结构和枚举------------*/
//视图类型
enum ViewType {
    case label,image,button
}
enum LayoutType {
    case normal,flow
}
//视图属性数据结构
struct ViewPt {
    var id = ""
    var viewType = ViewType.label
    var layoutType = LayoutType.normal
    var isNormal = false
    var text = ""
    var fontSize:Float = 12
    var textColor = ""
    var width:Float = 0
    var height:Float = 0
}
struct ViewStrStruct {
    let propertyStr: String
    let initStr: String
    let getterStr: String
}

//属性类型定义
enum WgPt {
    case none
    case top,bottom,left,right //位置相关属性
    case text,font,textColor        //label 相关属性
    case width,height               //通用属性
}
enum PtEqualRightType {
    case pt,float,color,text,new,font
}
//表达式所需结构
struct PtEqual {
    var idPrefix = "" //id的前缀
    var leftId = ""
    var left = WgPt.none
    var rightType = PtEqualRightType.pt
    var rightId = ""
    var right = WgPt.none
    var rightFloat:Float = 0
    var rightColor = ""
    var rightString = ""
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


/*--------------------------------*/
/*---------具体语言实现------------*/
/*--------------------------------*/
//Objective-C
struct H5EditorObjc: HTNMultilingualismSpecification {
    var id = "" { didSet { id = validIdStr(id: id) } }
    var pageId = "" { didSet { pageId = validIdStr(id: pageId) } }
    
    func viewPtToStrStruct(vpt:ViewPt) -> ViewStrStruct {
        var getter = ""
        var initContent = ""
        var property = ""
        let vClassStr = viewTypeClassStr(vt: .label)
        switch vpt.viewType {
        case .label:
            property = "@property (nonatomic, strong) \(vClassStr) *\(vpt.id);\n"
            
            var pe = PtEqual()
            pe.leftId = vpt.id
            pe.idPrefix = "_"
            pe.left = .none
            pe.rightType = .new
            pe.rightString = vClassStr
            getter += ptEqualToStr(pe: pe) + "\n"
            
            pe.left = .text
            pe.rightType = .text
            pe.rightString = vpt.text
            getter += ptEqualToStr(pe: pe) + "\n"
            
            pe.left = .font
            pe.rightType = .font
            pe.rightFloat = vpt.fontSize
            getter += ptEqualToStr(pe: pe) + "\n"
            
            pe.left = .textColor
            pe.rightType = .color
            pe.rightString = vpt.textColor
            getter += ptEqualToStr(pe: pe) + "\n"
            
            pe.left = .width
            pe.rightType = .float
            pe.rightFloat = vpt.width
            getter += ptEqualToStr(pe: pe) + "\n"
            
            pe.left = .height
            pe.rightType = .float
            pe.rightFloat = vpt.height
            getter += ptEqualToStr(pe: pe) + "\n"
            
        case .button:
            getter = ""
        case .image:
            getter = ""
        }
        
        getter = """
        - (\(vClassStr) *)\(vpt.id) {
        if(!_\(vpt.id)){
        \(getter)
        }
        return _\(vpt.id);
        }\n
        """
        
        //处理 init content
        if vpt.layoutType == .normal  {
            //处理绝对定位
            initContent = "some thing need to do ..."
        }
        
        return ViewStrStruct(propertyStr: property, initStr: initContent, getterStr: getter)
    }
    
    func selfAddSubViewStr(vId: String) -> String {
        return "[self addSubview:self.\(vId)];"
    }
    func viewTypeClassStr(vt: ViewType) -> String {
        switch vt {
        case .label:
            return "UILabel"
        case .button:
            return "UIButton"
        case .image:
            return "UIImageView"
        }
    }
    func idProperty(pt: WgPt, idPar: String, prefix: String) -> String {
        var idStr = "\(self.id)"
        if idPar.count > 0 {
            idStr = "\(idPar)"
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
        case .font:
            ptStr = "font"
        case .text:
            ptStr = "text"
        case .textColor:
            ptStr = "textColor"
        case .width:
            ptStr = "width"
        case .height:
            ptStr = "height"
        case .none:
            ptStr = ""
        }
        if pt != .none {
            ptStr = "." + ptStr
        }
        var prefixStr = prefix
        if prefix.count == 0 {
            prefixStr = "self."
        }
        return prefixStr + idStr + ptStr
    }
    
    func ptEqualToStr(pe:PtEqual) -> String {
        let leftStr = idProperty(pt: pe.left, idPar: pe.leftId, prefix: pe.idPrefix)
        var rightStr = ""
        switch pe.rightType {
        case .pt:
            rightStr = idProperty(pt: pe.right, idPar: pe.rightId, prefix: pe.idPrefix)
        case .float:
            rightStr = "\(pe.rightFloat)"
        case .color:
            rightStr = """
            [UIColor one_colorWithHexString:@"333333"]
            """
        case .new:
            rightStr = "[[\(pe.rightString) alloc] init]"
        case .text:
            rightStr = """
            @"\(pe.rightString)"
            """
        case .font:
            rightStr = "[UIFont systemFontOfSize:\(pe.rightFloat)]"
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
    func validIdStr(id: String) -> String {
        return "h" + id;
    }
}

////Swift
//struct H5EditorSwift: HTNMultilingualismSpecification {
//    var id = ""
//    var left = "left"
//    var right = "right"
//    var top = "top"
//    var bottom = "bottom"
//    func flowTopSetNormal(lastWidgetId: String) -> String {
//        return "\(id).top = \(lastWidgetId).bottom;"
//    }
//}

