//
//  LayoutElement.swift
//  HTNSwift
//
//  Created by sunshinelww on 2017/10/25.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation
/**
 布局类
 **/
class LayoutElement {

    public func createRenderer(doc:Document)->Document {
        layoutBlockChildren(doc)
        return doc
    }
    
    /**
     给每个需要显示的节点创建RenderObject
     **/
    private func layoutBlockChildren(_ elem:Element){
        if(shouldCreateRenderer(elem)){
            elem.createRenderObject(); //创建RenderObject
            parseMargin(elem)  //解析margin
            parsePadding(elem) //解析padding
            parseBorder(elem)
            if elem.children.count > 0{
                for child in elem.children{
                    let e = child as! Element;
                    layoutBlockChildren(e); //递归渲染子元素
                }
            }
        }
    }
    
    /**
     判断是否需要给节点创建Render
    **/
    private func shouldCreateRenderer(_ elem:Element) -> Bool{
        //Css display:none的元素不需要
        if let property = elem.propertyMap["display"] {
            if property == "none"{
                return false
            }
        }
        return true
    }
    
    private func parseMargin(_ elem :Element){
        if let propertyValue = elem.propertyMap["margin"] {
            let results = propertyValue.split(separator: " ")
            if results.count == 1 {//只有一个值
                if let value=Double(cutNumberMark(str: String(results[0]))){
                    elem.renderer?.margin_top = Double(value);
                    elem.renderer?.margin_left = Double(value);
                    elem.renderer?.margin_bottom = Double(value);
                    elem.renderer?.margin_right = Double(value);
                }
            }
            else if results.count == 2{
                if let value=Double(cutNumberMark(str: String(results[0]))){
                    elem.renderer?.margin_top = Double(value);
                    elem.renderer?.margin_bottom = Double(value);
                }
                if let value=Double(cutNumberMark(str: String(results[1]))){
                    elem.renderer?.margin_left = Double(value);
                    elem.renderer?.margin_right = Double(value);
                }
            }
            else if results.count == 3{
                if let value=Double(cutNumberMark(str: String(results[0]))){
                    elem.renderer?.margin_top = Double(value);
                }
                if let value=Double(cutNumberMark(str: String(results[1]))){
                    elem.renderer?.margin_left = Double(value);
                    elem.renderer?.margin_right = Double(value);
                }
                if let value=Double(cutNumberMark(str: String(results[2]))){
                    elem.renderer?.margin_bottom = Double(value);
                }
            }
            else if results.count == 4{
                if let value=Double(cutNumberMark(str: String(results[0]))){
                    elem.renderer?.margin_top = Double(value);
                }
                if let value=Double(cutNumberMark(str: String(results[1]))){
                    elem.renderer?.margin_right = Double(value);
                }
                if let value=Double(cutNumberMark(str: String(results[2]))){
                    elem.renderer?.margin_bottom = Double(value);
                }
                if let value=Double(cutNumberMark(str: String(results[3]))){
                    elem.renderer?.margin_left = Double(value);
                }
            }
        }
        else if let propertyValue = elem.propertyMap["margin-top"]{
            if let value = Double(cutNumberMark(str: String(propertyValue))){
                elem.renderer?.margin_top = value;
            }
        }
        else if let propertyValue = elem.propertyMap["margin-left"]{
            if let value = Double(cutNumberMark(str: String(propertyValue))){
                elem.renderer?.margin_left = value;
            }
        }
        else if let propertyValue = elem.propertyMap["margin-bottom"]{
            if let value = Double(cutNumberMark(str: String(propertyValue))){
                elem.renderer?.margin_bottom = value;
            }
        }
        else if let propertyValue = elem.propertyMap["margin-right"]{
            if let value = Double(cutNumberMark(str: String(propertyValue))){
                elem.renderer?.margin_right = value;
            }
        }
        
    }
    
    private func parsePadding(_ elem :Element){
        if let propertyValue = elem.propertyMap["padding"]{
            let results = propertyValue.split(separator: " ")
            if results.count == 1 {//只有一个值
                if let value=Double(cutNumberMark(str: String(results[0]))){
                    elem.renderer?.padding_top = Double(value);
                    elem.renderer?.padding_right = Double(value);
                    elem.renderer?.padding_bottom = Double(value);
                    elem.renderer?.padding_left = Double(value);
                }
            }
            else if results.count == 4{
                if let value=Double(cutNumberMark(str: String(results[0]))){
                    elem.renderer?.padding_top = Double(value);
                }
                if let value=Double(cutNumberMark(str: String(results[1]))){
                    elem.renderer?.padding_right = Double(value);
                }
                if let value=Double(cutNumberMark(str: String(results[2]))){
                    elem.renderer?.padding_bottom = Double(value);
                }
                if let value=Double(cutNumberMark(str: String(results[3]))){
                    elem.renderer?.padding_left = Double(value);
                }
            }
        }
        else if let propertyValue = elem.propertyMap["padding-top"]{
            if let value = Double(cutNumberMark(str: String(propertyValue))){
                elem.renderer?.padding_top = value;
            }
        }
        else if let propertyValue = elem.propertyMap["padding-left"]{
            if let value = Double(cutNumberMark(str: String(propertyValue))){
                elem.renderer?.padding_left = value;
            }
        }
        else if let propertyValue = elem.propertyMap["padding-bottom"]{
            if let value = Double(cutNumberMark(str: String(propertyValue))){
                elem.renderer?.padding_bottom = value;
            }
        }
        else if let propertyValue = elem.propertyMap["padding-right"]{
            if let value = Double(cutNumberMark(str: String(propertyValue))){
                elem.renderer?.padding_right = value;
            }
        }
    }
    
    private func parseBorder(_ elem: Element) {
        if let propertyValue = elem.propertyMap["border"]{
            let valueArr = propertyValue.split(separator: " ").map(String.init)
            elem.renderer?.borderWidth = Double(cutNumberMark(str: valueArr[0])) ?? 0.0
            elem.renderer?.borderColor = valueArr[2]
        }
    }
    
    func cutNumberMark(str:String) -> String {
        var re = str.replacingOccurrences(of: "pt", with: "")
        re = re.replacingOccurrences(of: "px", with: "")
        return re
    }
}
