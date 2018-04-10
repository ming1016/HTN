//
//  File.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/21.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

struct H5Editor : Codable {
    var errno: Int?
    var msg: String?
    var data: Data?
    
    struct Data: Codable {
        var _id: String?
        //var clazz: String?
        //var userId: String?
        var name: String?
        var title: String?
        var pages: [Page]?
        
        struct Page: Codable {
            var id: String?
            //var clazz: String?
            var name: String?
            var bgColor: String?
            var bgImage: String?
            var bgImagePosition: String?
            var bgImageRepeat: String?
            var widgets: [Widget]?
            var isSelected: Bool?
            var width: Float?
            var height: Float?
            var type: String?
            var triggers: [Trigger]?
            var variableMap: VariableMap?
            var isStandard: Bool?
            var panelType: String?
            var createAt: String?
            var themeType: String?
            
            struct Widget: Codable {
                var id: String?
                var name: String?
                var type: String?               //类型
                var location: String?           //相对定位的位置 page
                var align: String?              //排列方式 free
                var alignLeftMargin: Float?     //边距
                var alignRightMargin: Float?
                var alignTopMargin: Float?
                var alignBottomMargin: Float?
                var width: Float?               //宽
                var height: Float?              //高
                var top: Float?                 //顶部
                var left: Float?                //居左多少
                var rotate: Float?              //旋转
                var bgColor: String?            //背景颜色 rgba(255,255,255,0)
                var bgImage: String?            //背景图片
                var bgImagePosition: String?    //背景图片位置 center-center
                var bgImageRepeat: String?      //背景图片是否平铺 none
                var borderRadius: Float?        //圆角 0
                var visible: Bool?              //是否可视 true
                var data: WidgetData?           //数据
                var animations: [Animation]?    //动画
                var triggers: [Trigger]?        //触发器
                var isSelected: Bool?           //是否选择 false
                var layout: String?             //布局 flow
                var pageWidth: Float?           //所属页面宽度
                var pageHeight: Float?          //所属页面高度
                var opacity: Float?             //不透明度 100
                var hasBorder: Bool?            //是否有边框 false
                var borderStyle: String?        //边框样式 solid
                var borderWidth: Float?         //边框宽度 1
                var borderColor: String?        //边框颜色
                var borderDirections: [String]? //边框包含那些边['top','right','bottom','left']
                var condition: Condition?       //组件条件
                var variableMap: VariableMap?   //组件属性的映射变量表
                var needAttach: Bool?           //是否吸附其它组件 false
                var attach: String?             //吸附组件 ''
                var locked: Bool?               //锁定位置
                var readonly: Bool?             //是否只读
                var layers: [Layer]?            //
                var hasLayers: Bool?
                var defaultLayerCount: Float?
                var maxLayerCount: Float?
                var padding: String?            //内边距
                var children: [Widget]?
                struct WidgetData: Codable {
                    //label
                    var content: String?
                    var text: String?
                    var color: String?
                    var fontSize: Float?
                    var fontFamily: String?
                    var fontWeight: String?
                    var verticalAlign: String?
                    var horizontalAlign: String?
                    var lineHeight: Float?
                    var letterSpacing: Float?
                    //image
                    var url: String?
                    var usePicSet: Bool?
                    var size: Size?
                    
                    struct Size: Codable {
                        var height: Float
                        var width: Float
                    }
                }
                struct Animation: Codable {
                    
                }
                struct Condition: Codable {
                    
                }
                struct Layer: Codable {
                    
                }
            }
            
        }
        var createTime: String?
        var lastModifyTime: String?
        var publishTime: String?
        var layout: String?
        var carouselDirection: String?
        var dataUrl: String?
        var descUrl: String?
        var descriptions: [Description]?
        var useData: Bool?
        var triggers: [Trigger]?
        var variableMap: VariableMap?
        var type: String?
        var lastModifiedDate: String?
        var config: Config?
        var editable: Bool?
        var logId: String?
        
        struct Description: Codable {
            
        }
        //处理比如点击等事件
        struct Trigger: Codable {
            var id: String?
            var clazz: String?
            var type: String?
            var event: String?
            var data: TriggerData?
            var variableMap: VariableMap?
            
            struct TriggerData: Codable {
                var url: String?
                var parameter: Bool?
            }
            struct VariableMap: Codable {
                
            }
        }
        struct VariableMap: Codable {
            
        }
        struct Config: Codable {
            
        }
        
    }
}
