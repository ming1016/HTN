//
//  H5EditorMultilingualism.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/21.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

//多语言协议规范
public protocol HTNMultilingualismSpecification {
    var pageId: String {get set}             //页面 id
    var id: String {get set}                 //动态 id
    var selfId: String {get}                 //self.id
    var selfStr: String {get}                //self
    var selfPtStr: String {get}              //self.
    func validIdStr(id: String) -> String    //对 id 字符串的合法化
    
    func newEqualStr(vType:HTNMt.ViewType,id:String) -> String //初始化一个类型对象
    
    func viewPtToStrStruct(vpt:HTNMt.ViewPt) -> HTNMt.ViewStrStruct //视图属性转视图结构
    
    func viewTypeClassStr(vt:HTNMt.ViewType) -> String         //视图类型类名的映射
    func ptEqualToStr(pe:HTNMt.PtEqual) -> String              //属性表达式
    func addSubViewStr(host: String,sub: String) -> String     //添加 subView
    func impFile(impf:HTNMt.ImpFile) -> String                 //实现文件的内容
    func interfaceFile(intf:HTNMt.InterfaceFile) -> String                    //接口文件的内容
    func idProperty(pt: HTNMt.WgPt, idPar: String, prefix: String, equalT: HTNMt.EqualType) -> String  //属性
    
    func flowViewLayout(fl:HTNMt.Flowly) -> String             //flow 布局
    func scale(_ v:Float) -> String                            //适应屏幕尺寸 scale 转换
    
    func sizeToFit(elm:String) -> String  //处理label sizeToFit
}
extension HTNMultilingualismSpecification {
    public func flowViewLayout(fl:HTNMt.Flowly) -> String {
        let cId = id + "Container"
        var lyStr = ""
        //UIView *myViewContainer = [UIView new];
        lyStr += newEqualStr(vType: .view, id: cId) + "\n"
        
        //属性拼装
        lyStr += HTNMt.PtEqualC().accumulatorLine({ (pe) -> String in
            return self.ptEqualToStr(pe: pe)
        }).once({ (p) in
            p.left(.top).leftId(cId).end()
            if fl.isFirst {
                //myViewContainer.top = 0.0;
                p.rightType(.float).rightFloat(0).add()
            } else {
                //myViewContainer.top = lastView.bottom;
                p.rightId(fl.lastId + "Container").rightType(.pt).right(.bottom).add()
            }
        }).once({ (p) in
            //myViewContainer.left = 0.0;
            p.leftId(cId).left(.left).rightType(.float).rightFloat(0).add()
        }).once({ (p) in
            //myViewContainer.width = self.myView.width;
            p.leftId(cId).left(.width).rightType(.pt).rightIdPrefix(selfPtStr).rightId(id).right(.width).add()
            
            //myViewContainer.height = self.myView.height;
            p.left(.height).right(.height).add()
        }).once({ (p) in
            //self.myView.width -= 16 * 2;
            p.left(.width).leftId(id).leftIdPrefix(selfPtStr).rightType(.float).rightFloat(fl.viewPt.padding.left * 2).equalType(.decrease).add()
            
            //self.myView.height -= 8 * 2;
            p.left(.height).rightFloat(fl.viewPt.padding.top * 2).add()
            
            //self.myView.top = 8;
            p.equalType(.normal).left(.top).rightType(.float).rightFloat(fl.viewPt.padding.top).add()
            
            //属性 verticalAlign 或 horizontalAlign 是 padding 和其它排列时的区别处理
            if fl.viewPt.horizontalAlign == .padding {
                //self.myView.left = 16;
                p.left(.left).rightFloat(fl.viewPt.padding.left).add()
            } else {
                //[self.myView sizeToFit];
                p.add(sizeToFit(elm: "\(selfId)"))
                p.left(.height).rightType(.pt).rightId(cId).right(.height).add()
                switch fl.viewPt.horizontalAlign {
                case .center:
                    p.left(HTNMt.WgPt.center).right(.center).add()
                case .left:
                    p.left(.left).right(.left).add()
                case .right:
                    p.left(.right).right(.right).add()
                default:
                    ()
                }
            }
            
            
        }).mutiEqualStr
        
        //[myViewContainer addSubview:self.myView];
        lyStr += addSubViewStr(host: cId, sub: "\(selfId)") + "\n"
        //[self addSubview:myViewContainer];
        lyStr += addSubViewStr(host: selfStr, sub: cId) + "\n"
        
        return lyStr
    }
}
/*-----------协议所需结构和枚举------------*/
public struct HTNMt {
    //flow布局
    public struct Flowly {
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
    public enum ViewType {
        case view,label,image,button,scrollView
    }
    enum LayoutType {
        case normal,flow
    }
    //视图属性数据结构
    public struct ViewPt {
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
        var bgColor = "" //背景色
        var radius:Float = 0  //圆角
        var borderColor = ""  //边框颜色
        var borderWidth:Float = 0  //边框宽度
        var hasBorder = false   //是否有边框
        var redirectUrl = ""  //点击跳转地址
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
    
    public struct ViewStrStruct {
        let propertyStr: String
        let initStr: String
        let getterStr: String
        var viewPt: ViewPt
    }
    
    //属性类型定义
    public enum WgPt {
        case none
        case new
        case top,bottom,left,right,center //位置相关属性
        case width,height,tag,bgColor,radius,borderColor,borderWidth,masksToBounds,clips,enableClick //通用属性
        case text,font,textColor,lineBreakMode,numberOfLines //label 相关属性
        case title,titleFont,titleColor,racCommand //button 相关属性
        case contentSize,bounces,pagingEnabled,showHIndicator,showVIndicator //scrollView 相关属性
    }
    enum PtEqualRightType {
        case pt,float,int,string,color,text,new,font,size,racCommand
    }
    //表达式所需结构
    public struct PtEqual {
        var leftId = ""
        var left = WgPt.none
        var leftIdPrefix = "" //左前缀
        var rightType = PtEqualRightType.pt
        var rightId = ""
        var rightIdPrefix = ""
        var right = WgPt.none
        var rightFloat:Float = 0
        var rightInt:Int = 0
        var rightSize:(Float,Float) = (0,0)
        var rightColor = ""
        var rightText = ""
        var rightString = ""
        var rightSuffix = ""
        
        var equalType = EqualType.normal
    }
    class PtEqualC {
        typealias MutiClosure = (_ pe: PtEqual) -> String
        typealias FilterClosure = () -> Bool
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
        func rightSize(w:Float, h:Float) -> PtEqualC {
            filterBl ? self.pe.rightSize = (w,h) : ()
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
    public enum EqualType {
        case normal,accumulation,decrease,set
    }
    //实现文件所需结构
    public struct ImpFile {
        var properties = ""
        var initContent = ""
        var getters = ""
    }
    //接口文件所需结构
    public struct InterfaceFile {
        
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

