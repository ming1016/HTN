//
//  File.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/21.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

struct H5Editor : Codable {
    let errno: Int
    let msg: String
    let data: Data
    
    struct Data: Codable {
        let _id: String
        let clazz: String
        let userId: String
        let name: String
        let title: String
        let pages: [Page]
        
        struct Page: Codable {
            let id: String
            let clazz: String
            let name: String
            let bgColor: String
            let bgImage: String
            let bgImagePosition: String
            let bgImageRepeat: String
            let widgets: [Widget]
            let isSelected: Bool
            let width: Float
            let height: Float
            let type: String
            let triggers: [Trigger]
            let variableMap: VariableMap
            let isStandard: Bool
            let panelType: String?
            let createAt: String?
            let themeType: String?
            
            
            struct Widget: Codable {
                let id: String
                let name: String
                let type: String               //类型
                let location: String           //相对定位的位置 page
                let align: String              //排列方式 free
                let alignLeftMargin: Float     //边距
                let alignRightMargin: Float
                let alignTopMargin: Float
                let alignBottomMargin: Float
                let width: Float               //宽
                let height: Float              //高
                let top: Float                 //顶部
                let left: Float                //居左多少
                let rotate: Float              //旋转
                let bgColor: String            //背景颜色 rgba(255,255,255,0)
                let bgImage: String            //背景图片
                let bgImagePosition: String    //背景图片位置 center-center
                let bgImageRepeat: String      //背景图片是否平铺 none
                let borderRadius: Float        //圆角 0
                let visible: Bool              //是否可视 true
                let data: WidgetData           //数据
                let animations: [Animation]    //动画
                let triggers: [Trigger]        //触发器
                let isSelected: Bool           //是否选择 false
                let layout: String             //布局 flow
                let pageWidth: Float           //所属页面宽度
                let pageHeight: Float          //所属页面高度
                let opacity: Float             //不透明度 100
                let hasBorder: Bool            //是否有边框 false
                let borderStyle: String        //边框样式 solid
                let borderWidth: Float         //边框宽度 1
                let borderColor: String        //边框颜色
                let borderDirections: [String] //边框包含那些边['top','right','bottom','left']
                let condition: Condition       //组件条件
                let variableMap: VariableMap   //组件属性的映射变量表
                let needAttach: Bool           //是否吸附其它组件 false
                let attach: String             //吸附组件 ''
                let locked: Bool               //锁定位置
                let readonly: Bool             //是否只读
                let layers: [Layer]            //
                let hasLayers: Bool
                let defaultLayerCount: Float
                let maxLayerCount: Float
                let padding: String            //内边距
                let children: [Widget]?
                struct WidgetData: Codable {
                    //label
                    let content: String?
                    let color: String?
                    let fontSize: Float?
                    let fontFamily: String?
                    let fontWeight: String?
                    let verticalAlign: String?
                    let horizontalAlign: String?
                    let lineHeight: Float?
                    let letterSpacing: Float?
                    //image
                    let url: String?
                    let usePicSet: Bool?
                    let size: Size?
                    
                    struct Size: Codable {
                        let height: Float
                        let width: Float
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
        let createTime: String
        let lastModifyTime: String
        let publishTime: String
        let layout: String
        let carouselDirection: String
        let dataUrl: String
        let descUrl: String
        let descriptions: [Description]
        let useData: Bool
        let triggers: [Trigger]
        let variableMap: VariableMap
        let type: String
        let lastModifiedDate: String
        let config: Config
        let editable: Bool
        let logId: String
        
        struct Description: Codable {
            
        }
        struct Trigger: Codable {
            
        }
        struct VariableMap: Codable {
            
        }
        struct Config: Codable {
            
        }
        
    }
}
