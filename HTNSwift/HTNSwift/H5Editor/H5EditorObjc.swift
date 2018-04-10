//
//  H5EditorObjc.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/23.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

struct H5EditorObjc: HTNMultilingualismSpecification {
    var pageId = "" { didSet { pageId = validIdStr(id: pageId) } }
    var id = "" { didSet { id = validIdStr(id: id) } }
    var selfId: String { return "self.\(self.id)" }
    var selfStr = "self"
    var selfPtStr = "self."
    
    func viewPtToStrStruct(vpt:HTNMt.ViewPt) -> HTNMt.ViewStrStruct {
        var getter = ""
        var initContent = ""
        var property = ""
        let vClassStr = viewTypeClassStr(vt: vpt.viewType)
        property = "@property (nonatomic, strong) \(vClassStr) *\(vpt.id);\n"
        switch vpt.viewType {
        case .label:
            getter += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
                return self.ptEqualToStr(pe: pe)
            }).once({ (p) in
                //_myView = [[UILabel alloc] init];
                p.leftId(vpt.id).leftIdPrefix("_").left(.none).rightType(.new).rightString(vClassStr).add()
                
                //_myView.attributedText = [[NSAttributedString alloc] initWithData:[@"<p><span>流式1</span></p>" dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
                p.left(.text).rightType(.text).rightText(vpt.text).add()
                
                //_myView.lineBreakMode = NSLineBreakByWordWrapping;
                p.left(.lineBreakMode).rightType(.string).rightString("NSLineBreakByWordWrapping").add()
                
                //_myView.numberOfLines = (HTNSCREENWIDTH * 0.0)/375;
                p.left(.numberOfLines).rightType(.int).rightInt(0).add()
                
                //_myView.font = [UIFont systemFontOfSize:16.0];
                p.left(.font).rightType(.font).rightFloat(vpt.fontSize).add()
                
                //textColor
                p.filter({ () -> Bool in
                    return vpt.textColor.count > 0
                }).left(.textColor).rightType(.color).rightColor(vpt.textColor).add()
                
            }).filter({ () -> Bool in
                return vpt.isNormal
            }).once({ (p) in
                let cId = vpt.id + "Container"
                //UIView *myViewContainer = [[UIView alloc] init];
                p.add(newEqualStr(vType: .view, id: cId))
                
                //myViewContainer.width = _hllfxu51uie.width;
                p.leftId(cId)
                    .left(.width)
                    .rightId(vpt.id)
                    .rightIdPrefix("_")
                    .rightType(.pt)
                    .right(.width)
                    .add()
                
                //myViewContainer.height = _hllfxu51uie.height;
                p.left(.height).right(.height).add()
                
                //myViewContainer.top = (HTNSCREENWIDTH * 65.0)/375;
                p.left(.top).rightType(.float).rightFloat(vpt.top).add()
                
                //myViewContainer.left = (HTNSCREENWIDTH * 95.0)/375;
                p.left(.left).rightFloat(vpt.left).add()
                
                //_myView.width -= (HTNSCREENWIDTH * 32.0)/375;
                p.leftIdPrefix("_")
                    .leftId(vpt.id)
                    .left(.width)
                    .equalType(.decrease)
                    .rightType(.float)
                    .rightFloat(vpt.padding.left * 2)
                    .add()
                
                //_myView.height -= (HTNSCREENWIDTH * 16.0)/375;
                p.left(.height).rightFloat(vpt.padding.top * 2).add()
                
                //_myView.top = (HTNSCREENWIDTH * 8.0)/375;
                p.left(.top).equalType(.normal).rightFloat(vpt.padding.top).add()
                
                //_myView.left = (HTNSCREENWIDTH * 16.0)/375;
                p.left(.left).rightFloat(vpt.padding.left).add()
                
                p.add(addSubViewStr(host: cId, sub: "_" + vpt.id))
                p.add(addSubViewStr(host: "self", sub: cId))
                
            }).mutiEqualStr
        case .button:
            getter += ""
        case .image:
            getter += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
                return self.ptEqualToStr(pe: pe)
            }).once({ (p) in
                //_myView = [[UIImageView alloc] init];
                p.leftId(vpt.id).leftIdPrefix("_").left(.none).rightType(.new).rightString(vClassStr).add()
                
                //[_myView sd_setImageWithURL:[NSURL URLWithString:@"https://static.starming.com/resource/121203c9-favorite.png"]];
                p.add(sdSetImageUrl(view: "_" + vpt.id, url: vpt.imageUrl))
                
                //[self addSubview:_myView];
                p.add(addSubViewStr(host: "self", sub: "_" + vpt.id))
            }).filter({ () -> Bool in
                return vpt.isNormal
            }).once({ (p) in
                //_myView.top = (HTNSCREENWIDTH * 240.0)/375;
                p.leftId(vpt.id).leftIdPrefix("_").left(.top).rightType(.float).rightFloat(vpt.top).add()
                
                //_myView.left = (HTNSCREENWIDTH * 35.0)/375;
                p.left(.left).rightFloat(vpt.left).add()
            }).mutiEqualStr
        case .view:
            getter += ""
        }
        
        //各个类型通用的属性设置
        getter += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
            return self.ptEqualToStr(pe: pe)
        }).once({ (p) in
            p.leftId(vpt.id).leftIdPrefix("_").end()
            //_myView.width = (HTNSCREENWIDTH * 375.0)/375;
            p.left(.width).rightType(.float).rightFloat(vpt.width).add()
            
            //_myView.height = (HTNSCREENWIDTH * 48.0)/375;
            p.left(.height).rightType(.float).rightFloat(vpt.height).add()
        }).mutiEqualStr
        
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
            initContent += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
                return self.ptEqualToStr(pe: pe)
            }).once({ (p) in
                //self.myView.tag = 1;
                p.leftIdPrefix("self.").left(.tag).leftId(vpt.id).rightType(.int).rightInt(1).add()
            }).mutiEqualStr
        }
        
        return HTNMt.ViewStrStruct(propertyStr: property, initStr: initContent, getterStr: getter, viewPt: vpt)
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
    func newEqualStr(vType: HTNMt.ViewType, id: String) -> String {
        let vClass = viewTypeClassStr(vt: vType)
        return "\(vClass) *\(id) = [[\(vClass) alloc] init];"
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
        case .center:
            ptStr = "centerX"
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
        case .tag:
            ptStr = "tag"
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
            rightStr = "\(pe.rightInt)"
        case .string:
            rightStr = "\(pe.rightString)"
        case .color:
            if pe.rightColor.hasPrefix("#") {
                let hexStr = pe.rightColor[1..<pe.rightColor.count]
                rightStr = """
                [UIColor one_colorWithHexString:@"\(hexStr)"]
                """
            }
            //rgba(255,255,255,0)
            if pe.rightColor.hasPrefix("rgba") {
                let rgbaArr = pe.rightColor[5..<pe.rightColor.count - 1].components(separatedBy: ",")
                rightStr = """
                [UIColor colorWithRed:\(rgbaArr[0])/255.0 green:\(rgbaArr[1])/255.0 blue:\(rgbaArr[2])/255.0 alpha:\(rgbaArr[3])]
                """
            }
        case .new:
            rightStr = "[[\(pe.rightString) alloc] init]"
        case .text:
            rightStr = """
            [[NSAttributedString alloc] initWithData:[@"\(pe.rightText.escape())" dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil]
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
        #import <SDWebImage/UIImageView+WebCache.h>
        
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
    
    //协议外的一些方法
    func sizeToFit(elm:String) -> String {
        return "[\(elm) sizeToFit];"
    }
    fileprivate func sdSetImageUrl(view:String, url:String) -> String {
        let encodeUrl = """
        [@"\(url)" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
        """
        return """
        [\(view) sd_setImageWithURL:[NSURL URLWithString:\(encodeUrl)]];
        """
    }
    
}
