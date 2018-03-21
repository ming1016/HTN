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
                    "content": "流式1"
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
                "padding": "8 16 8 16"
            }
,
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
                    "content": "流式2"
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
                "top": 85,
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
                    "content": "普通2"
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
                "top": 100,
                "left": 0,
                "rotate": 0,
                "bgColor": "rgba(163,120,95,0)",
                "bgImage": "",
                "bgImagePosition": "center-center",
                "bgImageRepeat": "none",
                "borderRadius": 0,
                "visible": true,
                "data":
                {
                    "content": "普通1"
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
            }
],
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
        "publishTime": "2018-03-20T06:57:58.059Z",
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
        "lastModifiedDate": "2018-03-20T06:57:57.948Z",
        "config":
        {},
        "editable": true,
        "logId": "5ab0b0f5261a8d160ac3222d"
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
