//
//  H5EditorToFrame.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/21.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

class H5EditorToFrame<M:HTNMultilingualismSpecification> {
    var m:M //多语言的支持
    init(m:M) {
        self.m = m
    }
    
    func convert(h5editor:H5Editor) -> String {
        m.pageId = h5editor.data.pages[0].id
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
            m.id = widget.id
            wgPropertyStr += wd.propertyStr
            wgInitStr += wd.initStr
            wgGetterStr += wd.getterStr
            var pe = PtEqual()
            pe.left = .top
            pe.rightId = m.validIdStr(id: lastWidget.id)
            pe.rightType = .pt
            pe.right = .bottom
            var topStr = m.ptEqualToStr(pe: pe)
            //第一个顶在最上面
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
    
    fileprivate func widgetStructConvertToStr(widget:H5Editor.Data.Page.Widget) -> ViewStrStruct {
        var uiType = ViewType.label
        switch widget.type {
        case "RichText","NormalText":
            uiType = .label
        case "Image":
            uiType = .image
        case "Button":
            uiType = .button
        default:
            uiType = .label
        }
        var layoutType = LayoutType.normal
        if widget.layout == "flow" {
            layoutType = .flow
        }
        var vp = ViewPt()
        vp.id = m.validIdStr(id: widget.id)
        vp.viewType = uiType
        vp.layoutType = layoutType
        vp.text = widget.data.content ?? ""
        vp.fontSize = widget.data.fontSize ?? 12
        vp.textColor = widget.data.color ?? "333333"
        vp.width = widget.width
        vp.height = widget.height
        let reStruct = m.viewPtToStrStruct(vpt: vp)
        
        return reStruct
    }
    fileprivate func scaleValueStr(v:Float) -> String {
        return "(HTNSCREENWIDTH * \(v))/375"
    }
//    fileprivate func validIdStr(w:H5Editor.Data.Page.Widget) -> String {
//        return "h\(w.id)"
//    }
}
