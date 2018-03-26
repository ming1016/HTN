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
        var padding = Padding()
        var isFirst = false
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
        var viewType = ViewType.label
        var layoutType = LayoutType.normal
        var isNormal = false
        var text = ""
        var fontSize:Float = 32
        var textColor = ""
        var width:Float = 0
        var height:Float = 0
    }
    
    struct ViewStrStruct {
        let propertyStr: String
        let initStr: String
        let getterStr: String
    }
    
    //属性类型定义
    enum WgPt {
        case none
        case new
        case top,bottom,left,right                           //位置相关属性
        case text,font,textColor,lineBreakMode,numberOfLines //label 相关属性
        case width,height                                    //通用属性
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
        
        var mutiEqualStr = ""         //累加的字符串
        var mutiEqualLineMark = "\n"  //换行标识
    }
    class PtEqualC {
        typealias MutiClosure = ((_ pe: PtEqual) -> String)
        var pe:PtEqual = PtEqual()
        var accumulatorLine:MutiClosure = {_ in return ""}
        
        func config(_ closure:(_ pc: PtEqualC) -> Void) -> PtEqualC{
            closure(self)
            return self
        }
        func configMuti(_ closure:@escaping MutiClosure) -> PtEqualC {
            self.accumulatorLine = closure
            return self
        }
        func add() {
            self.pe.mutiEqualStr += accumulatorLine(self.pe) + self.pe.mutiEqualLineMark
        }
        func end() {} //结束时无返回，表示全部结束设置
        func left(_ wp:WgPt) -> PtEqualC {
            self.pe.left = wp
            return self
        }
        func leftId(_ str:String) -> PtEqualC {
            self.pe.leftId = str
            return self
        }
        func leftIdPrefix(_ str:String) -> PtEqualC {
            self.pe.leftIdPrefix = str
            return self
        }
        func rightType(_ t:PtEqualRightType) -> PtEqualC {
            self.pe.rightType = t
            return self
        }
        func rightId(_ str:String) -> PtEqualC {
            self.pe.rightId = str
            return self
        }
        func rightIdPrefix(_ str:String) -> PtEqualC {
            self.pe.rightIdPrefix = str
            return self
        }
        func right(_ wp:WgPt) -> PtEqualC {
            self.pe.right = wp
            return self
        }
        func rightFloat(_ f:Float) -> PtEqualC {
            self.pe.rightFloat = f
            return self
        }
        func rightInt(_ i:Int) -> PtEqualC {
            self.pe.rightInt = i
            return self
        }
        func rightColor(_ str:String) -> PtEqualC {
            self.pe.rightColor = str
            return self
        }
        func rightText(_ str:String) -> PtEqualC {
            self.pe.rightText = str
            return self
        }
        func rightString(_ str:String) -> PtEqualC {
            self.pe.rightString = str
            return self
        }
        func rightSuffix(_ str:String) -> PtEqualC {
            self.pe.rightSuffix = str
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

