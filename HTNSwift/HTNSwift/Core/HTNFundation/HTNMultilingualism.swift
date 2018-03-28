//
//  H5EditorMultilingualism.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/21.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

//多语言协议规范
protocol HTNMultilingualismSpecification {
    var pageId: String {get set}                               //页面 id
    var id: String {get set}                                   //动态 id
    func newEqualStr(vType:HTNMt.ViewType,id:String) -> String //初始化一个类型对象
    func validIdStr(id: String) -> String                      //对 id 字符串的合法化
    func viewPtToStrStruct(vpt:HTNMt.ViewPt) -> HTNMt.ViewStrStruct //视图属性转视图结构
    func viewTypeClassStr(vt:HTNMt.ViewType) -> String         //视图类型类名的映射
    func ptEqualToStr(pe:HTNMt.PtEqual) -> String              //属性表达式
    func addSubViewStr(host: String,sub: String) -> String     //添加 subView
    func impFile(impf:HTNMt.ImpFile) -> String                 //实现文件的内容
    func interfaceFile(intf:HTNMt.InterfaceFile) -> String                    //接口文件的内容
    func idProperty(pt: HTNMt.WgPt, idPar: String, prefix: String) -> String  //属性
    
    func flowViewLayout(fl:HTNMt.Flowly) -> String             //flow 布局
    
    func scale(_ v:Float) -> String                            //适应屏幕尺寸 scale 转换
}
extension HTNMultilingualismSpecification {
    
}
/*-----------协议所需结构和枚举------------*/
struct HTNMt {
    //flow布局
    struct Flowly {
        var id = ""
        var lastId = ""
        var isFirst = false
        var viewPt = ViewPt()
    }
    struct Padding {
        var top:Float = 0
        var left:Float = 0
        var bottom:Float = 0
        var right:Float = 0
    }
    //视图类型
    enum ViewType {
        case view,label,image,button
    }
    enum LayoutType {
        case normal,flow
    }
    //视图属性数据结构
    struct ViewPt {
        var id = ""
        var viewType:ViewType = .label
        var layoutType:LayoutType = .normal
        var isNormal = false
        var text = ""
        var fontSize:Float = 32
        var textColor = ""
        var top:Float = 0
        var left:Float = 0
        var width:Float = 0
        var height:Float = 0
        var padding = Padding()
        var verticalAlign:VerticalAlign = .padding
        var horizontalAlign:HorizontalAlign = .padding
        var imageUrl  = ""  //图片链接
    }
    enum VerticalAlign {
        case padding
        case middle
        case top
        case bottom
    }
    enum HorizontalAlign {
        case padding
        case center
        case left
        case right
    }
    
    struct ViewStrStruct {
        let propertyStr: String
        let initStr: String
        let getterStr: String
        var viewPt: ViewPt
    }
    
    //属性类型定义
    enum WgPt {
        case none
        case new
        case top,bottom,left,right,center                    //位置相关属性
        case text,font,textColor,lineBreakMode,numberOfLines //label 相关属性
        case width,height,tag                                //通用属性
    }
    enum PtEqualRightType {
        case pt,float,int,string,color,text,new,font
    }
    //表达式所需结构
    struct PtEqual {
        var leftId = ""
        var left = WgPt.none
        var leftIdPrefix = "" //左前缀
        var rightType = PtEqualRightType.pt
        var rightId = ""
        var rightIdPrefix = ""
        var right = WgPt.none
        var rightFloat:Float = 0
        var rightInt:Int = 0
        var rightColor = ""
        var rightText = ""
        var rightString = ""
        var rightSuffix = ""
        
        var equalType = EqualType.normal
    }
    class PtEqualC {
        typealias MutiClosure = ((_ pe: PtEqual) -> String)
        typealias FilterClosure = (() -> Bool)
        var pe:PtEqual = PtEqual()
        var accumulatorLineClosure:MutiClosure = {_ in return ""}
        var filterBl = true
        var mutiEqualStr = ""         //累加的字符串
        var mutiEqualLineMark = "\n"  //换行标识
        //设置 PtEqual 结构体
        func once(_ closure:(_ pc: PtEqualC) -> Void) -> PtEqualC{
            if filterBl {
                closure(self)
            }
            _ = resetPe()
            _ = resetFilter()
            return self
        }
        //累计设置的 PtEqual 字符串
        func accumulatorLine(_ closure:@escaping MutiClosure) -> PtEqualC {
            self.accumulatorLineClosure = closure
            return self
        }
        //执行累加动作
        func add() {
            if filterBl {
                self.mutiEqualStr += accumulatorLineClosure(self.pe) + self.mutiEqualLineMark
            }
            _ = resetFilter()
        }
        //累加自定义的字符串
        func add(_ str:String) {
            if filterBl {
                self.mutiEqualStr += str + self.mutiEqualLineMark
            }
            _ = resetFilter()
        }
        //过滤条件
        func filter(_ closure: FilterClosure) -> PtEqualC {
            filterBl = closure()
            return self
        }
        //重置 PtEqual
        func resetPe() -> PtEqualC {
            self.pe = PtEqual()
            return self
        }
        //重置 filter
        func resetFilter() -> PtEqualC {
            filterBl = true
            return self
        }
        //结束时无返回，表示全部结束设置
        func end() {
            _ = resetFilter()
        }
        func left(_ wp:WgPt) -> PtEqualC {
            filterBl ? self.pe.left = wp : ()
            return self
        }
        func leftId(_ str:String) -> PtEqualC {
            filterBl ? self.pe.leftId = str : ()
            return self
        }
        func leftIdPrefix(_ str:String) -> PtEqualC {
            filterBl ? self.pe.leftIdPrefix = str : ()
            return self
        }
        func rightType(_ t:PtEqualRightType) -> PtEqualC {
            filterBl ? self.pe.rightType = t : ()
            return self
        }
        func rightId(_ str:String) -> PtEqualC {
            filterBl ? self.pe.rightId = str : ()
            return self
        }
        func rightIdPrefix(_ str:String) -> PtEqualC {
            filterBl ? self.pe.rightIdPrefix = str : ()
            return self
        }
        func right(_ wp:WgPt) -> PtEqualC {
            filterBl ? self.pe.right = wp : ()
            return self
        }
        func rightFloat(_ f:Float) -> PtEqualC {
            filterBl ? self.pe.rightFloat = f : ()
            return self
        }
        func rightInt(_ i:Int) -> PtEqualC {
            filterBl ? self.pe.rightInt = i : ()
            return self
        }
        func rightColor(_ str:String) -> PtEqualC {
            filterBl ? self.pe.rightColor = str : ()
            return self
        }
        func rightText(_ str:String) -> PtEqualC {
            filterBl ? self.pe.rightText = str : ()
            return self
        }
        func rightString(_ str:String) -> PtEqualC {
            filterBl ? self.pe.rightString = str : ()
            return self
        }
        func rightSuffix(_ str:String) -> PtEqualC {
            filterBl ? self.pe.rightSuffix = str : ()
            return self
        }
        func equalType(_ et:EqualType) -> PtEqualC {
            filterBl ? self.pe.equalType = et : ()
            return self
        }
        
    }
    //等号类型
    enum EqualType {
        case normal,accumulation,decrease
    }
    //实现文件所需结构
    struct ImpFile {
        var properties = ""
        var initContent = ""
        var getters = ""
    }
    //接口文件所需结构
    struct InterfaceFile {
        
    }
}

/*--------------------------------*/
/*---------具体语言实现------------*/
/*--------------------------------*/
//Objective-C
//见H5EditorObjc.swift

////Swift
//struct H5EditorSwift: HTNMultilingualismSpecification {
//    var id = ""
//    var left = "left"
//    var right = "right"
//    var top = "top"
//    var bottom = "bottom"
//    func flowTopSetNormal(lastWidgetId: String) -> String {
//        return "\(id).top = \(lastWidgetId).bottom;"
//    }
//}

