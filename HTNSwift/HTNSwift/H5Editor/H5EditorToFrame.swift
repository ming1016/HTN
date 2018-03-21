//
//  H5EditorToFrame.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/21.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

class H5EditorToFrame<M:H5EditorMultilingualismSpecification> {
    var m:M //多语言的支持
    init(m:M) {
        self.m = m
    }
    
    func convert(h5editor:H5Editor) -> String {
        m.pageId = "h" + h5editor.data.pages[0].id
        //全部 widget
        let allWidgets = h5editor.data.pages[0].widgets;
        //流式布局 widget
        var flowWidgets = [H5Editor.Data.Page.Widget]()
        //普通布局 widget
        var normalWidgets = [H5Editor.Data.Page.Widget]()
        //讲两类布局放到两个不同集合中，先处理和添加流式布局，再处理普通布局
        for widget in allWidgets {
            if widget.layout == "flow" {
                flowWidgets.append(widget)
            } else if widget.layout == "normal" {
                normalWidgets.append(widget)
            }
        }
        
        var wgPropertyStr = ""
        var wgInitStr = ""
        var wgGetterStr = ""
        //流式布局
        var lastWidget = flowWidgets[0]
        var i = 0
        for widget in flowWidgets {
            let wd = widgetStructConvertToStr(widget: widget)
            let id = validIdStr(w: widget)
            m.id = id
            wgPropertyStr += wd.propertyStr
            wgInitStr += wd.initStr
            wgGetterStr += wd.getterStr
            var pe = PtEqual()
            pe.left = .top
            pe.rightId = validIdStr(w: lastWidget)
            pe.rightType = .pt
            pe.right = .bottom
            var topStr = m.ptEqualToStr(pe: pe)
            if i == 0 {
                var topPe = PtEqual()
                topPe.left = .top
                topPe.rightType = .float
                topPe.rightFloat = 0;
                topStr = m.ptEqualToStr(pe: topPe)
            }
            var leftPe = PtEqual()
            leftPe.left = .left
            leftPe.rightType = .float
            leftPe.rightFloat = 0
            let leftStr = m.ptEqualToStr(pe: leftPe)
            wgInitStr += """
            \(topStr)
            \(leftStr)
            \(m.selfAddSubViewStr(vId: m.id))\n
            """
            lastWidget = widget
            i += 1
        }
        //最终对文件的拼装
        var imp = ImpFile()
        imp.properties = wgPropertyStr
        imp.initContent = wgInitStr
        imp.getters = wgGetterStr
        
        let nativeMStr = m.impFile(impf: imp)
        let nativeHStr = m.interfaceFile(intf: InterfaceFile())
        print(nativeHStr)
        return nativeMStr
    }
    
    struct WidgetStr {
        let propertyStr: String
        let initStr: String
        let getterStr: String
    }
    
    fileprivate func widgetStructConvertToStr(widget:H5Editor.Data.Page.Widget) -> WidgetStr {
        var uiType = ""
        var getterBody = ""
        let id = validIdStr(w: widget)
        switch widget.type {
        case "RichText","NormalText":
            uiType = "UILabel"
            getterBody = """
            _\(id) = [[UILabel alloc] init];
            _\(id).text = @"\(widget.data.content ?? "")";
            _\(id).font = [UIFont systemFontOfSize:\(widget.data.fontSize ?? 12)];
            _\(id).textColor = [UIColor one_colorWithHexString:@"333333"];
            _\(id).width = \(scaleValueStr(v: widget.width));
            _\(id).height = \(scaleValueStr(v: widget.height));
            """
        case "Image":
            uiType = "UIImageView"
        case "Button":
            uiType = "UIButton"
        default:
            uiType = "UIView"
        }
        let propertyStr = "@property (nonatomic, strong) \(uiType) *\(id);\n"
        
        let getterStr = """
        - (\(uiType) *)\(validIdStr(w: widget)) {
        if(!_\(validIdStr(w: widget))){
        \(getterBody)
        }
        return _\(validIdStr(w: widget));
        }\n
        """
        let initStr = ""
        if widget.type == "normal" {
            
        }
        
        let reStr = WidgetStr(propertyStr: propertyStr, initStr: initStr, getterStr: getterStr)
        return reStr
    }
    fileprivate func scaleValueStr(v:Float) -> String {
        return "(HTNSCREENWIDTH * \(v))/375"
    }
    fileprivate func validIdStr(w:H5Editor.Data.Page.Widget) -> String {
        return "h\(w.id)"
    }
}
