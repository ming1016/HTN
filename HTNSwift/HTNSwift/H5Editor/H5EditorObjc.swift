//
//  H5EditorObjc.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/23.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

struct H5EditorObjc: HTNMultilingualismSpecification {
    var id = "" { didSet { id = validIdStr(id: id) } }
    var pageId = "" { didSet { pageId = validIdStr(id: pageId) } }
    
    func flowViewLayout(fl:HTNMt.Flowly) -> String {
        //UIView *hxgrtr3x785view = [UIView new];
        let cId = id + "view"
        var lyStr = ""
        lyStr += newEqualStr(vType: .view, id: cId) + "\n"
        
        //h4fw4rfejxvview.top = hxgrtr3x785view.bottom;
        var p = HTNMt.PtEqual()
        p.left = .top
        p.leftId = cId
        p.rightId = fl.lastId + "view"
        p.rightType = .pt
        p.right = .bottom
        lyStr += ptEqualToStr(pe: p) + "\n"
        
        //处理第一个的情况
        //hxgrtr3x785view.top = 0.0;
        if fl.isFirst {
            p = HTNMt.PtEqual()
            p.leftId = cId
            p.left = .top
            p.rightType = .float
            p.rightFloat = 0
            lyStr += ptEqualToStr(pe: p) + "\n"
        }
        
        //hxgrtr3x785view.left = 0.0;
        p = HTNMt.PtEqual()
        p.leftId = cId
        p.left = .left
        p.rightType = .float
        p.rightFloat = 0
        lyStr += ptEqualToStr(pe: p) + "\n"
        
        //hxgrtr3x785view.width = self.hxgrtr3x785.width;
        p = HTNMt.PtEqual()
        p.leftId = cId
        p.left = .width
        p.rightType = .pt
        p.rightIdPrefix = "self."
        p.rightId = id
        p.right = .width
        lyStr += ptEqualToStr(pe: p) + "\n"
        
        //hxgrtr3x785view.height = self.hxgrtr3x785.height;
        p.left = .height
        p.right = .height
        lyStr += ptEqualToStr(pe: p) + "\n"
        
        //self.hxgrtr3x785.width -= 16 * 2;
        p = HTNMt.PtEqual()
        p.left = .width
        p.leftId = id
        p.leftIdPrefix = "self."
        p.rightType = .float
        p.rightFloat = fl.padding.left * 2
        p.equalType = .decrease
        lyStr += ptEqualToStr(pe: p) + "\n"
        
        //self.hxgrtr3x785.height -= 8 * 2;
        p.left = .height
        p.rightFloat = fl.padding.top * 2
        lyStr += ptEqualToStr(pe: p) + "\n"
        
        //self.hxgrtr3x785.top = hxgrtr3x785view.top + 8;
        p.equalType = .normal
        p.left = .top
        p.rightType = .float
        p.rightFloat = fl.padding.top
        lyStr += ptEqualToStr(pe: p) + "\n"
        
        //self.hxgrtr3x785.left = hxgrtr3x785view.left + 16;
        p.left = .left
        p.rightFloat = fl.padding.left
        lyStr += ptEqualToStr(pe: p) + "\n"
        
        //[hxgrtr3x785view addSubview:self.hxgrtr3x785];
        lyStr += addSubViewStr(host: cId, sub: "self.\(id)") + "\n"
        //[self addSubview:hxgrtr3x785view];
        lyStr += addSubViewStr(host: "self", sub: cId) + "\n"
        
        return lyStr
    }
    
    func newEqualStr(vType: HTNMt.ViewType, id: String) -> String {
        let vClass = viewTypeClassStr(vt: vType)
        return "\(vClass) *\(id) = [[\(vClass) alloc] init];"
    }
    
    func viewPtToStrStruct(vpt:HTNMt.ViewPt) -> HTNMt.ViewStrStruct {
        var getter = ""
        var initContent = ""
        var property = ""
        let vClassStr = viewTypeClassStr(vt: .label)
        property = "@property (nonatomic, strong) \(vClassStr) *\(vpt.id);\n"
        switch vpt.viewType {
        case .label:
            var pe = HTNMt.PtEqual()
            pe.leftId = vpt.id
            pe.leftIdPrefix = "_"
            pe.left = .none
            pe.rightType = .new
            pe.rightString = vClassStr
            getter += ptEqualToStr(pe: pe) + "\n"
            
            pe.left = .text
            pe.rightType = .text
            pe.rightText = vpt.text
            getter += ptEqualToStr(pe: pe) + "\n"
            
            pe.left = .lineBreakMode
            pe.rightType = .string
            pe.rightString = "NSLineBreakByWordWrapping"
            getter += ptEqualToStr(pe: pe) + "\n"
            
            pe.left = .numberOfLines
            pe.rightType = .int
            pe.rightFloat = 0;
            getter += ptEqualToStr(pe: pe) + "\n"
            
            pe.left = .font
            pe.rightType = .font
            pe.rightFloat = vpt.fontSize
            getter += ptEqualToStr(pe: pe) + "\n"
            
            //处理没有这个数据就不设置这个属性
            if vpt.textColor.count > 0 {
                pe.left = .textColor
                pe.rightType = .color
                pe.rightString = vpt.textColor
                getter += ptEqualToStr(pe: pe) + "\n"
            }
            
            pe.left = .width
            pe.rightType = .float
            pe.rightFloat = vpt.width
            getter += ptEqualToStr(pe: pe) + "\n"
            
            pe.left = .height
            pe.rightType = .float
            pe.rightFloat = vpt.height
            getter += ptEqualToStr(pe: pe) + "\n"
            
            getter = ""
            getter = HTNMt.PtEqualC().configMuti({ (pe) -> String in
                return self.ptEqualToStr(pe: pe)
            }).config({ (pc) in
                pc.leftId(vpt.id).leftIdPrefix("_").left(.none).rightType(.new).rightString(vClassStr).add()
            }).config({ (pc) in
                pc.left(.text).rightType(.text).rightText(vpt.text).add()
            }).config({ (pc) in
                pc.left(.lineBreakMode).rightType(.string).rightString("NSLineBreakByWordWrapping").add()
            }).config({ (pc) in
//                pc.left(.numberOfLines)
            }).pe.mutiEqualStr
            print(getter)
        case .button:
            getter = ""
        case .image:
            getter = ""
        case .view:
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
        
        return HTNMt.ViewStrStruct(propertyStr: property, initStr: initContent, getterStr: getter)
    }
    func addSubViewStr(host: String,sub: String) -> String {
        return "[\(host) addSubview:\(sub)];"
    }
    func viewTypeClassStr(vt: HTNMt.ViewType) -> String {
        switch vt {
        case .view:
            return "UIView"
        case .label:
            return "UILabel"
        case .button:
            return "UIButton"
        case .image:
            return "UIImageView"
        }
    }
    func idProperty(pt: HTNMt.WgPt, idPar: String, prefix: String) -> String {
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
            ptStr = "attributedText"
        case .textColor:
            ptStr = "textColor"
        case .width:
            ptStr = "width"
        case .height:
            ptStr = "height"
        case .lineBreakMode:
            ptStr = "lineBreakMode"
        case .numberOfLines:
            ptStr = "numberOfLines"
        case .none:
            ptStr = ""
        case .new:
            ptStr = ""
        }
        
        if pt != .none {
            idStr += "."
        }
        return prefix + idStr + ptStr
    }
    
    func ptEqualToStr(pe:HTNMt.PtEqual) -> String {
        let leftStr = idProperty(pt: pe.left, idPar: pe.leftId, prefix: pe.leftIdPrefix)
        var rightStr = ""
        switch pe.rightType {
        case .pt:
            rightStr = idProperty(pt: pe.right, idPar: pe.rightId, prefix: pe.rightIdPrefix)
        case .float:
            rightStr = "\(scale(pe.rightFloat))"
        case .int:
            rightStr = "\(scale(Float(pe.rightInt)))"
        case .string:
            rightStr = "\(pe.rightString)"
        case .color:
            var hexStr = ""
            if pe.rightColor.hasPrefix("#") {
                hexStr = pe.rightColor[1..<pe.rightColor.count - 1]
            }
            rightStr = """
            [UIColor one_colorWithHexString:@"\(hexStr)"]
            """
        case .new:
            rightStr = "[[\(pe.rightString) alloc] init]"
        case .text:
            rightStr = """
            [[NSAttributedString alloc] initWithData:[@"\(pe.rightText)" dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil]
            """
        case .font:
            rightStr = "[UIFont systemFontOfSize:\(pe.rightFloat/2)]"
        }
        
        var equalStr = " = "
        switch pe.equalType {
        case .normal:
            equalStr = " = "
        case .accumulation:
            equalStr = " += "
        case .decrease:
            equalStr = " -= "
        }
        return leftStr + equalStr + rightStr + pe.rightSuffix + ";"
    }
    
    func impFile(impf: HTNMt.ImpFile) -> String {
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
    func interfaceFile(intf:HTNMt.InterfaceFile) -> String {
        return """
        #import <UIKit/UIKit.h>
        
        @interface \(pageId) : UIView
        
        @end
        """
    }
    func validIdStr(id: String) -> String {
        return "h" + id;
    }
    
    func scale(_ v: Float) -> String {
        return "(HTNSCREENWIDTH * \(v))/375"
    }
}
