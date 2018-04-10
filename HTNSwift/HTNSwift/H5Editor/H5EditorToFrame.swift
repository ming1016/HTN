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
        m.pageId = h5editor.data?.pages![0].id ?? ""
        //全部 widget
        let page = h5editor.data?.pages![0];
        let allWidgets = page?.widgets ?? [];
        //流式布局 widget,逆序添加H5Editor的widgets
        let flowWidgets = allWidgets.filter{ $0.layout == "flow" }.reversed()
        //普通布局 widget,逆序添加H5Editor的widgets
        let normalWidgets = allWidgets.filter{ $0.layout == "normal" }.reversed()
        
        var wgPropertyStr = ""
        var wgInitStr = ""
        var wgGetterStr = ""
        //处理scrollView
        let pageStruct = pageStructConvertToScrollView(page: page!)
        wgPropertyStr += pageStruct.propertyStr
        wgInitStr += pageStruct.initStr
        wgGetterStr += pageStruct.getterStr
        //先处理和添加流式布局，再处理普通布局
        //流式布局
        var lastWidget : H5Editor.Data.Page.Widget
        for (index, widget) in flowWidgets.enumerated() {
            //更新标识
            lastWidget = widget
            //对 flow 的所有 widget 的处理
            let wd = widgetStructConvertToStr(widget: widget)
            m.id = widget.id ?? ""
            wgPropertyStr += wd.propertyStr
            wgInitStr += wd.initStr
            wgGetterStr += wd.getterStr
            
            var fl = HTNMt.Flowly()
            fl.id = m.id
            fl.lastId = m.validIdStr(id: lastWidget.id ?? "")
            fl.isFirst = index == 0
            fl.viewPt = wd.viewPt
            
            wgInitStr += m.flowViewLayout(fl: fl)
        }

        //对于 normal 的处理
        for widget in normalWidgets {
            let wd = widgetStructConvertToStr(widget: widget)
            m.id = widget.id ?? ""
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
        
        //生成文件测试
//        let hFilePath = "/Users/didi/Documents/Demo/HomePageTest/HomePageTest/\(m.pageId).h"
//        let mFilePath = "/Users/didi/Documents/Demo/HomePageTest/HomePageTest/\(m.pageId).m"
//        try! nativeHStr.write(toFile: hFilePath, atomically: true, encoding: String.Encoding.utf8)
//        try! nativeMStr.write(toFile: mFilePath, atomically: true, encoding: String.Encoding.utf8)
        
        return nativeMStr
    }
    
    struct WidgetStr {
        let propertyStr: String
        let initStr: String
        let getterStr: String
    }
    
    fileprivate func pageStructConvertToScrollView(page: H5Editor.Data.Page) -> HTNMt.ViewStrStruct {
        //h5editor 结构体和 htn 多语言结构体的转换
        var vp = HTNMt.ViewPt()
        vp.id = m.pageId
        vp.viewType = .scrollView
        vp.width = page.width ?? 0
        vp.height = page.height ?? 0
        vp.bgColor = page.bgColor ?? ""
        
        let pageStruct = m.viewPtToStrStruct(vpt: vp)
        return pageStruct
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
        vp.id = m.validIdStr(id: widget.id ?? "")
        vp.viewType = uiType
        vp.layoutType = layoutType
        vp.width = widget.width ?? 0
        vp.height = widget.height ?? 0
        vp.top = widget.top ?? 0
        vp.left = widget.left ?? 0
        vp.bgColor = widget.bgColor ?? ""
        vp.radius = widget.borderRadius ?? 0
        vp.borderColor = widget.borderColor ?? ""
        vp.borderWidth = widget.borderWidth ?? 0
        vp.hasBorder = widget.hasBorder ?? false
        
        if uiType == .button {
            vp.text = widget.data?.text ?? ""
        }else{
            vp.text = widget.data?.content ?? ""
        }
        vp.fontSize = widget.data?.fontSize ?? 32
        vp.textColor = widget.data?.color ?? ""
        vp.imageUrl = widget.data?.url ?? ""
        vp.isNormal = widget.layout == "normal"
        
        //padding 的处理
        if (widget.padding?.count)! > 0 {
            let paddingArr = widget.padding?.split(separator: " ")
            if paddingArr?.count == 4 {
                vp.padding = HTNMt.Padding(top: Float(paddingArr![0])!, left: Float(paddingArr![1])!, bottom: Float(paddingArr![2])!, right: Float(paddingArr![3])!)
            }
        }
        
        //横向和纵向
        var vAlign = HTNMt.VerticalAlign.padding
        switch widget.data?.verticalAlign {
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
        switch widget.data?.horizontalAlign {
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
        
        //处理 trigger
        if let triggers = widget.triggers {
            if triggers.count > 0 {
                for trigger in triggers {
                    //跳转属性
                    if trigger.type == "Redirect", let url = trigger.data?.url {
                        vp.redirectUrl = url
                    }
                }
            }
        }
        
        let reStruct = m.viewPtToStrStruct(vpt: vp)
        
        return reStruct
    }
    
//    fileprivate func validIdStr(w:H5Editor.Data.Page.Widget) -> String {
//        return "h\(w.id)"
//    }
}
