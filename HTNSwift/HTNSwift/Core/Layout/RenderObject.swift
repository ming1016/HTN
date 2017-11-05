//
//  RenderObject.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/15.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation
public class RenderObject {
    
    public var x : Double? //代表元素的一个布局位置，暂时只考虑这四个属性，以后再添加
    public var y : Double?
    public var width  : Double
    public var height : Double
    
    //主要设置盒子模型的padding属性
    public var padding_top : Double = 0
    public var padding_left :Double = 0
    public var padding_bottom : Double = 0
    public var padding_right : Double = 0
    
    //盒子模型的border属性
    public var border_top : Double = 0
    public var border_left : Double = 0
    public var border_bottom : Double = 0
    public var border_right : Double = 0
    
    //盒子模型的marginInfo,注意父节点的marginInfo需要根据所有子节点信息的marginInfo来共同决定
    public var margin_top : Double = 0
    public var margin_left : Double = 0
    public var margin_bottom : Double = 0
    public var margin_right : Double = 0
    
    public var backgroundColor : String? //背景颜色
    public var borderColor :String? //边框颜色
    public var borderWidth :Double = 0 //边框宽度
    public var borderRadius :Double = 0 //边框圆角
    
    init() {
        width=0
        height=0
    }
    
    public func setPadding(_ top :Double, _ left : Double, _ bottom: Double, _ right: Double){
        padding_top = top
        padding_left = left
        padding_bottom = bottom
        padding_right = right
    }
}
