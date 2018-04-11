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
                
                //myViewContainer.width = (HTNSCREENWIDTH * 48.0)/375;
                p.leftId(cId).left(.width).rightType(.float).rightFloat(vpt.width).add()
                
                //myViewContainer.height = (HTNSCREENWIDTH * 48.0)/375;
                p.left(.height).rightType(.float).rightFloat(vpt.height).add()
                
                //myViewContainer.top = (HTNSCREENWIDTH * 65.0)/375;
                p.left(.top).rightType(.float).rightFloat(vpt.top).add()
                
                //myViewContainer.left = (HTNSCREENWIDTH * 95.0)/375;
                p.left(.left).rightFloat(vpt.left).add()
                
                //_myView.width = myViewContainer.width;
                p.leftIdPrefix("_")
                    .leftId(vpt.id)
                    .left(.width)
                    .rightId(cId)
                    .rightType(.pt)
                    .right(.width)
                    .add()
                
                //_myView.height = myViewContainer.height;
                p.left(.height).right(.height).add()

                //_myView.width -= (HTNSCREENWIDTH * 32.0)/375;
                p.left(.width)
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
                
                //disable userInteraction
//                p.leftId(cId).leftIdPrefix("").left(.enableClick).rightType(.int).rightInt(0).add()

                p.add(addSubViewStr(host: cId, sub: "_" + vpt.id))
                p.add(addSubViewStr(host: "\(selfStr).\(self.pageId)", sub: cId))
                
            }).mutiEqualStr
        case .button:
            getter += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
                return self.ptEqualToStr(pe: pe)
            }).once({ (p) in
                p.leftId(vpt.id).leftIdPrefix("_").left(.none).rightType(.new).rightString(vClassStr).add()
                p.left(.titleFont).rightType(.font).rightFloat(vpt.fontSize).add()
                //title
                p.equalType(.set).left(.title).rightType(.string).rightString("@\"\(vpt.text)\"").rightSuffix(" forState:UIControlStateNormal").add()
                //textColor
                p.filter({ () -> Bool in
                    return vpt.textColor.count > 0
                }).equalType(.set).left(.titleColor).rightType(.color).rightColor(vpt.textColor).rightSuffix(" forState:UIControlStateNormal").add()
                //disable userInteraction
//                p.equalType(.normal).left(.enableClick).rightType(.int).rightInt(0).rightSuffix("").add()
                
                p.add(addSubViewStr(host: "self.\(self.pageId)", sub: "_" + vpt.id))
            }).filter({ () -> Bool in
                return vpt.isNormal
            }).once({ (p) in
                //_myView.top = (HTNSCREENWIDTH * 240.0)/375;
                p.leftId(vpt.id).leftIdPrefix("_").left(.top).rightType(.float).rightFloat(vpt.top).add()
                //_myView.left = (HTNSCREENWIDTH * 35.0)/375;
                p.left(.left).rightFloat(vpt.left).add()
            }).mutiEqualStr
        case .image:
            getter += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
                return self.ptEqualToStr(pe: pe)
            }).once({ (p) in
                //_myView = [[UIImageView alloc] init];
                p.leftId(vpt.id).leftIdPrefix("_").left(.none).rightType(.new).rightString(vClassStr).add()
                
                //[_myView sd_setImageWithURL:[NSURL URLWithString:@"https://static.starming.com/resource/121203c9-favorite.png"]];
                p.add(sdSetImageUrl(view: "_" + vpt.id, url: vpt.imageUrl))
                
                //[self addSubview:_myView];
                p.add(addSubViewStr(host: "\(selfStr).\(self.pageId)", sub: "_" + vpt.id))
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
        case .scrollView:
            getter += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
                return self.ptEqualToStr(pe: pe)
            }).once({ (p) in
                p.leftId(vpt.id).leftIdPrefix("_").left(.none).rightType(.new).rightString(vClassStr).add()
                p.left(.clips).rightType(.int).rightInt(1).add()
                p.left(.contentSize).rightType(.size).rightSize(w: vpt.width, h: vpt.height).add()
                p.add(addSubViewStr(host: "self", sub: "_" + vpt.id))
            }).filter({ () -> Bool in
                return vpt.isNormal
            }).once({ (p) in
                p.left(.top).rightType(.float).rightFloat(vpt.top).add()
                p.left(.left).rightType(.float).rightFloat(vpt.left).add()
            }).mutiEqualStr
        }
        
        //各个类型通用的属性设置
        getter += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
            return self.ptEqualToStr(pe: pe)
        }).once({ (p) in
            p.leftId(vpt.id).leftIdPrefix("_").end()
            if vpt.viewType != .label {
                //label的宽高由container决定
                //_myView.width = (HTNSCREENWIDTH * 375.0)/375;
                p.left(.width).rightType(.float).rightFloat(vpt.width).add()
                
                //_myView.height = (HTNSCREENWIDTH * 48.0)/375;
                p.left(.height).rightType(.float).rightFloat(vpt.height).add()
            }
            //backgroundColor
            p.left(.bgColor).rightType(.color).rightColor(vpt.bgColor).add()
            
            //cornerRadius
            p.filter({ () -> Bool in
                return vpt.radius > 0
            }).left(.radius).rightType(.float).rightFloat(vpt.radius).add()
            p.filter({ () -> Bool in
                return vpt.radius > 0
            }).left(.masksToBounds).rightType(.int).rightInt(1).add()

            //border
            p.filter({ () -> Bool in
                return vpt.hasBorder && vpt.borderWidth > 0
            }).left(.borderWidth).rightType(.float).rightFloat(vpt.borderWidth).add()
            p.filter({ () -> Bool in
                return vpt.hasBorder && vpt.borderColor.count > 0
            }).left(.borderColor).rightType(.color).rightColor(vpt.borderColor).rightSuffix(".CGColor") .add()
        }).filter({ () -> Bool in
            //处理有跳转的的情况
            return vpt.viewType != .button && vpt.viewType != .scrollView && vpt.redirectUrl.count > 0
        }).once({ (p) in
            //如果有跳转添加一个 button
            //enable userInteraction
            p.leftId(vpt.id).leftIdPrefix("_").left(.enableClick).rightType(.int).rightInt(1).add()
            let btnId = vpt.id + "Btn"
            p.add(newEqualStr(vType: .button, id: btnId))
            //myViewBtn.width = _hllfxu51uie.width;
            p.leftId(btnId)
                .leftIdPrefix("")
                .left(.width)
                .rightId(vpt.id)
                .rightIdPrefix("_")
                .rightType(.pt)
                .right(.width)
                .add()
            //myViewContainer.height = _hllfxu51uie.height;
            p.left(.height).right(.height).add()
            //myViewContainer.top = 0;
            p.left(.top).rightType(.float).rightFloat(0).add()
            p.left(.left).rightFloat(0).add()
            p.add(addSubViewStr(host: "_" + vpt.id, sub: btnId))
            p.left(.racCommand).rightType(.racCommand).rightString(vpt.redirectUrl).add()
        }).mutiEqualStr
        
        //处理有跳转的的情况
        
        
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
                p.leftIdPrefix(selfPtStr).left(.tag).leftId(vpt.id).rightType(.int).rightInt(1).add()
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
        case .scrollView:
            return "UIScrollView"
        }
    }
    func newEqualStr(vType: HTNMt.ViewType, id: String) -> String {
        let vClass = viewTypeClassStr(vt: vType)
        return "\(vClass) *\(id) = [[\(vClass) alloc] init];"
    }
    func idProperty(pt: HTNMt.WgPt, idPar: String, prefix: String, equalT: HTNMt.EqualType) -> String {
        var idStr = "\(self.id)"
        if idPar.count > 0 {
            idStr = "\(idPar)"
        }
        let ptStr = pt.ocProperty
        if equalT == .set {
            return "[" + prefix + idStr + " set\(ptStr):"
        }
        if pt != .none {
            idStr += "."
        }
        return prefix + idStr + ptStr
    }
    
    func ptEqualToStr(pe:HTNMt.PtEqual) -> String {
        let leftStr = idProperty(pt: pe.left, idPar: pe.leftId, prefix: pe.leftIdPrefix,equalT: pe.equalType)
        var rightStr = ""
        switch pe.rightType {
        case .pt:
            rightStr = idProperty(pt: pe.right, idPar: pe.rightId, prefix: pe.rightIdPrefix,equalT: pe.equalType)
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
        case .size:
            rightStr = "CGSizeMake(\(scale(pe.rightSize.0)), \(scale(pe.rightSize.1)))"
        case .racCommand:
            rightStr = """
            [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            NSString *redirectUrl = @"\(pe.rightString)";
            [HTNUI redirectPageWithURLString:redirectUrl];
            return [RACSignal empty];
            }]
            """
        }
        var equalStr = " = "
        var endStr = ";"
        switch pe.equalType {
        case .normal:
            equalStr = " = "
        case .accumulation:
            equalStr = " += "
        case .decrease:
            equalStr = " -= "
        case .set:
            equalStr = ""
            endStr = "];"
        }
        return leftStr + equalStr + rightStr + pe.rightSuffix + endStr
    }
    
    func impFile(impf: HTNMt.ImpFile) -> String {
        return """
        #import <UIKit/UIKit.h>
        #import "\(pageId).h"
        #import "HTNUI.h"
        #import <SDWebImage/UIImageView+WebCache.h>
        #import <ReactiveCocoa/ReactiveCocoa.h>
        
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
        
        - (void)layoutSubviews {
        [super layoutSubviews];
        CGRect scrollRect = self.\(self.pageId).frame;
        scrollRect.size.width = self.frame.size.width;
        scrollRect.size.height = self.frame.size.height;
        self.\(self.pageId).frame = scrollRect;
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
    
    func sizeToFit(elm:String) -> String {
        return "[\(elm) sizeToFit];"
    }
    //协议外的一些方法
    fileprivate func sdSetImageUrl(view:String, url:String) -> String {
        let encodeUrl = """
        [@"\(url)" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
        """
        return """
        [\(view) sd_setImageWithURL:[NSURL URLWithString:\(encodeUrl)]];
        """
    }
    
}

//ObjC属性定义
extension HTNMt.WgPt {
    var ocProperty : String {
        switch self {
        case .top:
            return "top"
        case .bottom:
            return "bottom"
        case .left:
            return "left"
        case .right:
            return "right"
        case .center:
            return "centerX"
        case .width:
            return "width"
        case .height:
            return "height"
        case .tag:
            return "tag"
        case .bgColor:
            return "backgroundColor"
        case .radius:
            return "layer.cornerRadius"
        case .borderColor:
            return "layer.borderColor"
        case .borderWidth:
            return "layer.borderWidth"
        case .masksToBounds:
            return "layer.masksToBounds"
        case .clips:
            return "clipsToBounds"
        case .enableClick:
            return "userInteractionEnabled"
        case .text:
            return "attributedText"
        case .font:
            return "font"
        case .textColor:
            return "textColor"
        case .lineBreakMode:
            return "lineBreakMode"
        case .numberOfLines:
            return "numberOfLines"
        case .title:
            return "Title"
        case .titleFont:
            return "titleLabel.font"
        case .titleColor:
            return "TitleColor"
        case .racCommand:
            return "rac_command"
        case .contentSize:
            return "contentSize"
        case .bounces:
            return "bounces"
        case .pagingEnabled:
            return "pagingEnabled"
        case .showHIndicator:
            return "showsHorizontalScrollIndicator"
        case .showVIndicator:
            return "showsVerticalScrollIndicator"
        case .none:
            return ""
        case .new:
            return ""
        }
    }
}


