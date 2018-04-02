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
    init(_ m:M) {
        self.m = m
    }
    
    func convert(_ h5editor:H5Editor) -> String {
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
        //对 flow 的所有 widget 的处理
        for widget in flowWidgets {
            let wd = widgetStructConvertToStr(widget: widget)
            m.id = widget.id
            wgPropertyStr += wd.propertyStr
            wgInitStr += wd.initStr
            wgGetterStr += wd.getterStr
            
            var fl = HTNMt.Flowly()
            fl.id = m.id
            fl.lastId = m.validIdStr(id: lastWidget.id)
            fl.isFirst = i == 0
            fl.viewPt = wd.viewPt
            
            wgInitStr += m.flowViewLayout(fl: fl)
            lastWidget = widget
            
            i += 1
        }
        
        //对于 normal 的处理
        for widget in normalWidgets {
            let wd = widgetStructConvertToStr(widget: widget)
            m.id = widget.id
            wgPropertyStr += wd.propertyStr
            wgInitStr += wd.initStr
            wgGetterStr += wd.getterStr
        }
        
        //最终对文件的拼装
        var imp = HTNMt.ImpFile()
        imp.properties = wgPropertyStr
        imp.initContent = wgInitStr
        imp.getters = wgGetterStr
        
        let nativeMStr = m.impFile(impf: imp)
        let nativeHStr = m.interfaceFile(intf: HTNMt.InterfaceFile())
        print(nativeHStr)
        return nativeMStr
    }
    
    struct WidgetStr {
        let propertyStr: String
        let initStr: String
        let getterStr: String
    }
    
    fileprivate func widgetStructConvertToStr(widget:H5Editor.Data.Page.Widget) -> HTNMt.ViewStrStruct {
        var uiType = HTNMt.ViewType.label
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
        var layoutType = HTNMt.LayoutType.normal
        if widget.layout == "flow" {
            layoutType = .flow
        }
        //h5editor 结构体和 htn 多语言结构体的转换
        var vp = HTNMt.ViewPt()
        vp.id = m.validIdStr(id: widget.id)
        vp.viewType = uiType
        vp.layoutType = layoutType
        vp.width = widget.width
        vp.height = widget.height
        vp.top = widget.top
        vp.left = widget.left
        
        vp.text = widget.data.content ?? ""
        vp.fontSize = widget.data.fontSize ?? 32
        vp.textColor = widget.data.color ?? ""
        
        vp.imageUrl = widget.data.url ?? ""
        
        vp.isNormal = widget.layout == "normal"
        
        //padding 的处理
        if widget.padding.count > 0 {
            let paddingArr = widget.padding.split(separator: " ")
            if paddingArr.count == 4 {
                vp.padding = HTNMt.Padding(top: Float(paddingArr[0])!, left: Float(paddingArr[1])!, bottom: Float(paddingArr[2])!, right: Float(paddingArr[3])!)
            }
        }
        
        //横向和纵向
        var vAlign = HTNMt.VerticalAlign.padding
        switch widget.data.verticalAlign {
        case "middle"?:
            vAlign = .middle
        case "top"?:
            vAlign = .top
        case "bottom"?:
            vAlign = .bottom
        default:
            vAlign = .padding
        }
        vp.verticalAlign = vAlign
        
        var hAlign = HTNMt.HorizontalAlign.padding
        switch widget.data.horizontalAlign {
        case "center"?:
            hAlign = .center
        case "left"?:
            hAlign = .left
        case "right"?:
            hAlign = .right
        default:
            hAlign = .padding
        }
        vp.horizontalAlign = hAlign
        
        let reStruct = m.viewPtToStrStruct(vpt: vp)
        
        return reStruct
    }
    
//    fileprivate func validIdStr(w:H5Editor.Data.Page.Widget) -> String {
//        return "h\(w.id)"
//    }
}
