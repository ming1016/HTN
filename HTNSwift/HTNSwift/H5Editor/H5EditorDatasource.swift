//
//  H5EditorData.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/21.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

struct H5EditorDatasource {
    func dataFromJson(id:String) -> H5Editor {
        let jsonString = """
{
    "errno": 0,
    "msg": "ok",
    "data":
    {
        "_id": "5aa72bf823e2380c378563ea",
        "clazz": "project",
        "userId": "daiming",
        "name": "start",
        "title": "start",
        "pages": [
        {
            "id": "cdjy4sqej0",
            "clazz": "page",
            "name": "页面-1",
            "bgColor": "rgba(255,255,255,1)",
            "bgImage": "",
            "bgImagePosition": "center-center",
            "bgImageRepeat": "none",
            "widgets": [
            {
                "id": "1tfjoi6ktr",
                "name": "图片-1",
                "type": "Image",
                "location": "page",
                "align": "free",
                "alignLeftMargin": 0,
                "alignRightMargin": 0,
                "alignTopMargin": 0,
                "alignBottomMargin": 0,
                "width": 278,
                "height": 273,
                "top": 240,
                "left": 35,
                "rotate": 0,
                "bgColor": "rgba(255,255,255,0)",
                "bgImage": "",
                "bgImagePosition": "center-center",
                "bgImageRepeat": "none",
                "borderRadius": 0,
                "visible": true,
                "data":
                {
                    "url": "https://static.didialift.com/pinche/gift/resource/bd02101d8e198f34a1999f0c12e451cc-favorite.png",
                    "usePicSet": false,
                    "size":
                    {
                        "height": 496,
                        "width": 505
                    }
                },
                "animations": [],
                "triggers": [],
                "isSelected": true,
                "layout": "flow",
                "pageWidth": 375,
                "pageHeight": 603,
                "opacity": 100,
                "hasBorder": false,
                "borderStyle": "solid",
                "borderWidth": 1,
                "borderColor": "rgba(0, 0, 0, 1)",
                "borderDirections": [
                    "top",
                    "right",
                    "bottom",
                    "left"
                ],
                "condition":
                {},
                "variableMap":
                {},
                "needAttach": false,
                "attach": "",
                "locked": false,
                "readonly": false,
                "layers": [],
                "hasLayers": false,
                "defaultLayerCount": 0,
                "maxLayerCount": 0,
                "padding": "0 0 0 0"
            },
            {
                "id": "emlku5dlde",
                "name": "单行文本-1",
                "type": "NormalText",
                "location": "page",
                "align": "free",
                "alignLeftMargin": 0,
                "alignRightMargin": 0,
                "alignTopMargin": 0,
                "alignBottomMargin": 0,
                "width": 375,
                "height": 38,
                "top": 205,
                "left": 0,
                "rotate": 0,
                "bgColor": "rgba(255,255,255,0)",
                "bgImage": "",
                "bgImagePosition": "center-center",
                "bgImageRepeat": "none",
                "borderRadius": 0,
                "visible": true,
                "data":
                {
                    "content": "就是单行的",
                    "color": "rgba(22.95,142.8,234.6,1)",
                    "fontSize": 32,
                    "fontFamily": "PingFangSC",
                    "fontWeight": "Medium",
                    "verticalAlign": "middle",
                    "horizontalAlign": "center",
                    "lineHeight": 60,
                    "letterSpacing": 0
                },
                "animations": [],
                "triggers": [],
                "isSelected": true,
                "layout": "flow",
                "pageWidth": 375,
                "pageHeight": 603,
                "opacity": 100,
                "hasBorder": false,
                "borderStyle": "solid",
                "borderWidth": 1,
                "borderColor": "rgba(0, 0, 0, 1)",
                "borderDirections": [
                    "top",
                    "right",
                    "bottom",
                    "left"
                ],
                "condition":
                {},
                "variableMap":
                {},
                "needAttach": false,
                "attach": "",
                "locked": false,
                "readonly": false,
                "layers": [],
                "hasLayers": false,
                "defaultLayerCount": 0,
                "maxLayerCount": 0,
                "padding": "0 0 0 0"
            },
            {
                "id": "xgrtr3x785",
                "name": "文本-3",
                "type": "RichText",
                "location": "page",
                "align": "free",
                "alignLeftMargin": 0,
                "alignRightMargin": 0,
                "alignTopMargin": 0,
                "alignBottomMargin": 0,
                "width": 375,
                "height": 48,
                "top": 0,
                "left": 0,
                "rotate": 0,
                "bgColor": "rgba(255,255,255,0)",
                "bgImage": "",
                "bgImagePosition": "center-center",
                "bgImageRepeat": "none",
                "borderRadius": 0,
                "visible": true,
                "data":
                {
                    "content": "<p><span>流式1</span></p>"
                },
                "animations": [],
                "triggers": [],
                "isSelected": false,
                "layout": "flow",
                "pageWidth": 375,
                "pageHeight": 603,
                "opacity": 100,
                "hasBorder": false,
                "borderStyle": "solid",
                "borderWidth": 1,
                "borderColor": "rgba(0, 0, 0, 1)",
                "borderDirections": [
                    "top",
                    "right",
                    "bottom",
                    "left"
                ],
                "condition":
                {},
                "variableMap":
                {},
                "needAttach": false,
                "attach": "",
                "locked": false,
                "readonly": false,
                "layers": [],
                "hasLayers": false,
                "defaultLayerCount": 0,
                "maxLayerCount": 0,
                "padding": "8 16 8 16"
            },
            {
                "id": "4fw4rfejxv",
                "name": "文本-4",
                "type": "RichText",
                "location": "page",
                "align": "free",
                "alignLeftMargin": 0,
                "alignRightMargin": 0,
                "alignTopMargin": 0,
                "alignBottomMargin": 0,
                "width": 375,
                "height": 48,
                "top": 0,
                "left": 0,
                "rotate": 0,
                "bgColor": "rgba(255,255,255,0)",
                "bgImage": "",
                "bgImagePosition": "center-center",
                "bgImageRepeat": "none",
                "borderRadius": 0,
                "visible": true,
                "data":
                {
                    "content": "<p>流式2</p>"
                },
                "animations": [],
                "triggers": [],
                "isSelected": false,
                "layout": "flow",
                "pageWidth": 375,
                "pageHeight": 603,
                "opacity": 100,
                "hasBorder": false,
                "borderStyle": "solid",
                "borderWidth": 1,
                "borderColor": "rgba(0, 0, 0, 1)",
                "borderDirections": [
                    "top",
                    "right",
                    "bottom",
                    "left"
                ],
                "condition":
                {},
                "variableMap":
                {},
                "needAttach": false,
                "attach": "",
                "locked": false,
                "readonly": false,
                "layers": [],
                "hasLayers": false,
                "defaultLayerCount": 0,
                "maxLayerCount": 0,
                "padding": "8 16 8 16"
            },
            {
                "id": "167r8ukvkj",
                "name": "文本-2",
                "type": "RichText",
                "location": "page",
                "align": "free",
                "alignLeftMargin": 0,
                "alignRightMargin": 0,
                "alignTopMargin": 0,
                "alignBottomMargin": 0,
                "width": 375,
                "height": 48,
                "top": 140,
                "left": 40,
                "rotate": 0,
                "bgColor": "rgba(255,255,255,0)",
                "bgImage": "",
                "bgImagePosition": "center-center",
                "bgImageRepeat": "none",
                "borderRadius": 0,
                "visible": true,
                "data":
                {
                    "content": "<p>普通2</p>"
                },
                "animations": [],
                "triggers": [],
                "isSelected": false,
                "layout": "flow",
                "pageWidth": 375,
                "pageHeight": 603,
                "opacity": 100,
                "hasBorder": false,
                "borderStyle": "solid",
                "borderWidth": 1,
                "borderColor": "rgba(0, 0, 0, 1)",
                "borderDirections": [
                    "top",
                    "right",
                    "bottom",
                    "left"
                ],
                "condition":
                {},
                "variableMap":
                {},
                "needAttach": false,
                "attach": "",
                "locked": false,
                "readonly": false,
                "layers": [],
                "hasLayers": false,
                "defaultLayerCount": 0,
                "maxLayerCount": 0,
                "padding": "8 16 8 16"
            },
            {
                "id": "llfxu51uie",
                "name": "文本-1",
                "type": "RichText",
                "location": "page",
                "align": "free",
                "alignLeftMargin": 0,
                "alignRightMargin": 0,
                "alignTopMargin": 0,
                "alignBottomMargin": 0,
                "width": 375,
                "height": 48,
                "top": 65,
                "left": 95,
                "rotate": 0,
                "bgColor": "rgba(163,120,95,0)",
                "bgImage": "",
                "bgImagePosition": "center-center",
                "bgImageRepeat": "none",
                "borderRadius": 0,
                "visible": true,
                "data":
                {
                    "content": "<p>普通1</p>"
                },
                "animations": [],
                "triggers": [],
                "isSelected": false,
                "layout": "normal",
                "pageWidth": 375,
                "pageHeight": 603,
                "opacity": 100,
                "hasBorder": false,
                "borderStyle": "solid",
                "borderWidth": 1,
                "borderColor": "rgba(0, 0, 0, 1)",
                "borderDirections": [
                    "top",
                    "right",
                    "bottom",
                    "left"
                ],
                "condition":
                {},
                "variableMap":
                {},
                "needAttach": false,
                "attach": "",
                "locked": false,
                "readonly": false,
                "layers": [],
                "hasLayers": false,
                "defaultLayerCount": 0,
                "maxLayerCount": 0,
                "padding": "8 16 8 16"
            }],
            "isSelected": true,
            "width": 375,
            "height": 603,
            "type": "scrollscreen",
            "triggers": [],
            "variableMap":
            {},
            "isStandard": false
        }],
        "createTime": "2018-03-13T01:40:08.916Z",
        "lastModifyTime": "2018-03-13T01:40:10.972Z",
        "publishTime": "2018-03-26T07:49:09.141Z",
        "layout": "normal",
        "carouselDirection": "vertical",
        "dataUrl": "",
        "descUrl": "",
        "descriptions": [],
        "useData": false,
        "triggers": [],
        "variableMap":
        {},
        "type": "combine",
        "lastModifiedDate": "2018-03-26T07:49:08.576Z",
        "config":
        {},
        "editable": true,
        "logId": "5ab8a5f41843679c813b768a"
    }
}
"""
        let jsonStringClear = jsonString.replacingOccurrences(of: "\n", with: "")
        let jsonData = jsonStringClear.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let jsonModel = try! decoder.decode(H5Editor.self, from: jsonData)
        return jsonModel
    }

}
