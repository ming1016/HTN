//
//  HTMLToTexture.swift
//  HTNSwift
//
//  Created by sunshinelww on 2017/10/26.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Foundation

struct ClassProperty {
    var propertyName: String
    var declareStr: String
    var instantiationStr: String
    
    init(_ propertyName: String, declareStr: String, instantiationStr: String) {
        self.propertyName = propertyName
        self.declareStr = declareStr
        self.instantiationStr = instantiationStr;
    }
}

class HTMLToTexture {
    static var index=0;
    var classPropertyArray = [String: ClassProperty]()
    let nodeClassName:String
    
    init(nodeName:String) {
        nodeClassName = nodeName
    }
    
    func cutNumberMark(str:String) -> String {
        var re = str.replacingOccurrences(of: "pt", with: "")
        re = re.replacingOccurrences(of: "px", with: "")
        return re
    }
    
    enum VarType { //暂时支持这三种变量
        case TEXT_NODE_TYPE //文本
        case IMG_NODE_TYPE  //图片
        case LAYOUT_TYPE    //布局
        case DISPALY_NODE_TYPE //节点类型
    }
    
    /**
     变量名生成器
     **/
    func generateVarName(_ elem: Element, varType:VarType) -> String {
        var id :String?
        if let attrDict = elem.startTagToken?.attributeDic {
            id = attrDict["id"]
        }
        var varName = "";
        if id == nil || id!.isEmpty{
            switch varType{
            case .IMG_NODE_TYPE:
                varName = "imageNode_\(HTMLToTexture.index)"
            case .LAYOUT_TYPE:
                varName = "stackLayout_\(HTMLToTexture.index)"
            case .TEXT_NODE_TYPE:
                varName =  "textNode_\(HTMLToTexture.index)"
            case .DISPALY_NODE_TYPE:
                varName = "displayNode_\(HTMLToTexture.index)"
            }
            HTMLToTexture.index += 1;
        }
        else{
            varName = id!
        }
        return varName
    }
    
    //布局方向
    static let flexDirectionMap = [
        "row" : "ASStackLayoutDirectionHorizontal",
        "column" : "ASStackLayoutDirectionVertical"
    ]
    
    //主轴对齐方式
    static let justifyContentMap = [
        "flex-start" : "ASStackLayoutJustifyContentStart",
        "flex-end" : "ASStackLayoutJustifyContentEnd",
        "center" : "ASStackLayoutJustifyContentCenter",
        "space-between" : "ASStackLayoutJustifyContentSpaceBetween",
        "space-around" : "ASStackLayoutJustifyContentSpaceAround"
    ]
    
    //侧轴对齐
    static let alignItemMap = [
        "flex-start" : "ASStackLayoutAlignItemsStart",
        "flex-end" : "ASStackLayoutAlignItemsEnd",
        "center" : "ASStackLayoutAlignItemsCenter",
        "baseline" : "ASStackLayoutAlignItemsBaselineFirst",
        "stretch" : "ASStackLayoutAlignItemsStretch"
    ]
    
    func shouldHandleMargin(elem: Element) -> Bool {
        guard let renderObj = elem.renderer else {
            return false
        }
        if renderObj.margin_top == 0 && renderObj.margin_left == 0 && renderObj.margin_bottom == 0 && renderObj.margin_right == 0{
            return false
        }
        return true
    }
    
    func handleMargin(elem: Element, varName: String, codeStr: inout String) -> String {
        var layoutVarName = varName;
        if let renderObj = elem.renderer{
            layoutVarName += "_addMargin"
            codeStr += """
            ASInsetLayoutSpec *\(layoutVarName)=
            [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(\(renderObj.margin_top), \(renderObj.margin_left), \(renderObj.margin_bottom), \(renderObj.margin_right))
            child:\(classPropertyArray.keys.contains(varName) ? "self."+varName : varName)];\n
            """
        }
        return layoutVarName
    }
    /**
     padding操作需要生成Node
     **/
    func handlePadding(elem: Element, varName: String, codeStr: inout String) -> String {
        var nodeVarName = generateVarName(elem, varType: VarType.DISPALY_NODE_TYPE)
        nodeVarName += "_node"
        let declareStr = "@property (strong, nonatomic) ASDisplayNode *\(nodeVarName);"
        
        var instanStr = """
        _\(nodeVarName)=[[ASDisplayNode alloc] init];
        _\(nodeVarName).automaticallyManagesSubnodes = YES;
        """;
        for attr in elem.propertyMap{
            switch attr.key {
            case "width":
                instanStr.append("_\(nodeVarName).style.width = ASDimensionMakeWithPoints(\(cutNumberMark(str: attr.value)));\n")
            case "height":
                instanStr.append("_\(nodeVarName).style.height = ASDimensionMakeWithPoints(\(cutNumberMark(str: attr.value)));\n")
            case "background-color":
                instanStr.append("_\(nodeVarName).backgroundColor = [UIColor colorWithHexString:@\"\(attr.value)\"];\n")
            default:
                print("Unknown text CSS atrribute: ---- \(attr.key)---- function :\(#function)")
            }
        }
        
        var newCodeStr = "";
        let renderObj = elem.renderer
        if (renderObj != nil) && !(renderObj!.padding_top == 0 && renderObj!.padding_left == 0 && renderObj!.padding_bottom == 0 && renderObj!.padding_right == 0){
            newCodeStr += """
            self.\(nodeVarName).layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            @strongify(self);
            \(codeStr)
            
            return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(\(renderObj!.margin_top), \(renderObj!.margin_left), \(renderObj!.margin_bottom), \(renderObj!.margin_right))
            child:\(varName)];
            };\n
            """
        }
        else{
            newCodeStr += """
            self.\(nodeVarName).layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            @strongify(self);
            \(codeStr)
            return [ASWrapperLayoutSpec wrapperWithLayoutElement:\(varName)];
            };\n
            """
        }
        codeStr = newCodeStr;
        classPropertyArray [nodeVarName] = ClassProperty(nodeVarName,declareStr: declareStr,instantiationStr: instanStr)
        return nodeVarName
    }
    
    /**
     返回一个stackLayout布局
     **/
    func stackLayoutSpec(elem: Element)-> (varName : String, codeStr : String)?{
        
        var layoutVarName = generateVarName(elem, varType: .LAYOUT_TYPE)
        var flex_direction = "row"
        var justify_content = "flex-start"
        var align_items = "flex-start"
        
        for attr in elem.propertyMap{
            if( attr.key == "flex-direction"){
                flex_direction = attr.value
            }
            
            if( attr.key == "justify-content"){
                justify_content = attr.value
            }
            
            if(attr.key == "align-items"){
                align_items = attr.value
            }
        }
        var str="";
        var childArray="@[";
        for child in elem.children{
            guard let transformedStr = commonConverter(elem :child as! Element) else{
                continue
            }
            str += transformedStr.codeStr
            childArray.append(classPropertyArray.keys.contains(transformedStr.varName) ? "self."+transformedStr.varName : transformedStr.varName)
            if(child !== elem.children.last!){
                childArray.append(",")
            }
        }
        childArray.append("]")
        if childArray == "@[]"{ //没有子元素，则不用返回布局
            return nil
        }
        str += """
        ASStackLayoutSpec * \(layoutVarName) = [ASStackLayoutSpec stackLayoutSpecWithDirection:\(HTMLToTexture.flexDirectionMap[flex_direction]!) spacing:0 justifyContent: \(HTMLToTexture.justifyContentMap[justify_content]!) alignItems: \(HTMLToTexture.alignItemMap[align_items]!) children:\(childArray)];
        
        """
        if shouldHandleMargin(elem: elem){
            layoutVarName = handleMargin(elem: elem, varName: layoutVarName, codeStr: &str)
        }
        return (layoutVarName, str)
    }
    
    public func commonConverter(elem: Element) ->(varName: String, codeStr: String)?{
        if isFlex(elem: elem){
            return stackLayoutSpec(elem: elem)
        }
        //非Flex布局
        if let tagName = elem.startTagToken?.data { //Tag节点
            var codeStr = ""
            if elem.children.count > 0{ //容器节点，默认采用纵向布局,两两组合
                var i = 0
                var result :(varName: String, codeStr: String)?
                repeat{
                    result = commonConverter(elem: elem.children[i] as! Element)
                    i += 1
                } while i < elem.children.count && result != nil
                
                guard result != nil else{
                    return nil //没有一个合法的child,则不用布局了
                }
                codeStr += result!.codeStr;
                var varName = result!.varName;
                
                for _ in i..<elem.children.count{
                    let currElem = elem.children[i] as! Element
                    
                    guard let result = commonConverter(elem: currElem) else{
                        continue
                    }
                    let childArray = "\(varName), \(classPropertyArray.keys.contains(result.varName) ? "self."+result.varName : result.varName)"
                    let layoutVarName = "\(varName)_\(result.varName)"
                    codeStr += """
                    ASStackLayoutSpec * \(layoutVarName) = [ASStackLayoutSpec stackLayoutSpecWithDirection:\(HTMLToTexture.flexDirectionMap["column"]!) spacing:0.f  justifyContent: \(HTMLToTexture.justifyContentMap["flex-start"]!) alignItems: \(HTMLToTexture.alignItemMap["flerx"]!) children:\(childArray)];
                    """
                    varName = layoutVarName
                }
                
                //先处理自己padding,再处理margin
                varName = handlePadding(elem: elem, varName: varName, codeStr: &codeStr)
                if shouldHandleMargin(elem: elem){
                    varName = handleMargin(elem: elem, varName: varName, codeStr: &codeStr)
                }
                return (varName, codeStr)
            }
            else { //非容器节点，暂时考虑两种，DIV和IMG
                switch tagName{
                case "DIV","div"://没有子节点的DIV
                    let varName = generateVarName(elem, varType: .DISPALY_NODE_TYPE)
                    var codeAtrr = ""
                    for attr in elem.propertyMap{
                        switch attr.key {
                        case "width":
                            codeAtrr.append("_\(varName).style.width = ASDimensionMakeWithPoints(\(cutNumberMark(str: attr.value)));\n")
                        case "height":
                            codeAtrr.append("_\(varName).style.height = ASDimensionMakeWithPoints(\(cutNumberMark(str: attr.value)));\n")
                        case "background-color":
                            codeAtrr.append("_\(varName).backgroundColor = [UIColor colorWithHexString:@\"\(attr.value)\"];\n")
                        default:
                            print("Unknown text css atrribute:div---- \(attr.key)---- function :\(#function)")
                        }
                    }
                    let declareStr = "@property (strong, nonatomic) ASDisplayNode *\(varName);"
                    let instanStr = """
                    _\(varName) = [[ASDisplayNode alloc] init];
                    \(codeAtrr)
                    """
                    let clsProperty = ClassProperty(varName,declareStr: declareStr, instantiationStr:instanStr)
                    classPropertyArray [varName] = clsProperty //保存Node节点作为类属性
                    var layoutCodeStr = ""
                    if shouldHandleMargin(elem: elem){
                        let layoutVarName = handleMargin(elem: elem, varName: varName, codeStr: &layoutCodeStr)
                        return (layoutVarName, layoutCodeStr)
                    }
                    return (varName,layoutCodeStr)
                case "IMG,img":
                    var src: String?
                    for attr in (elem.startTagToken?.attributeList)! {
                        if(attr.name == "attr"){
                            src = attr.value
                        }
                    }
                    let varName = generateVarName(elem, varType: .IMG_NODE_TYPE)
                    var codeAtrr = ""
                    for attr in elem.propertyMap{
                        switch attr.key {
                        case "width":
                            codeAtrr.append("_\(varName).style.width = ASDimensionMakeWithPoints(\(cutNumberMark(str: attr.value)));\n")
                        case "height":
                            codeAtrr.append("_\(varName).style.height = ASDimensionMakeWithPoints(\(cutNumberMark(str: attr.value)));\n")
                        case "border-radius":
                            codeAtrr.append("_\(varName).cornerRadius = \(cutNumberMark(str: attr.value));\n")
                        case "background-color":
                            codeAtrr.append("_\(varName).style.backgroundColor = [UIColor colorWithHexString:@\"\(attr.value)\"];\n")
                        default:
                            print("Unknown text css atrribute: IMG ---- \(attr.key)!---- function: \(#function)")
                        }
                    }
                    var declareStr = ""
                    var instanStr = ""
                    if let imgLink = src {
                        if(imgLink.hasPrefix("http://") || imgLink.hasPrefix("https://")){ //网络图片
                            declareStr = "@property (nonatomic, strong) ASImageNode *\(varName);\n"
                            codeAtrr.append("_\(varName).URL = [NSURL URLWithString:@\"\(imgLink)\"];\n")
                            instanStr.append("_\(varName)=[[ASNetworkImageNode alloc] init];\n")
                        }
                        else{
                            declareStr = "@property (nonatomic, strong) ASNetworkImageNode *\(varName);\n"
                            codeAtrr.append("_\(varName).image = [UIImage imageNamed:@\"\(imgLink)\"];\n")
                            instanStr.append("_\(varName) = [[ASImageNode alloc] init];\n")
                        }
                    }
                    instanStr.append(codeAtrr)
                    classPropertyArray[varName] = ClassProperty(varName,declareStr:declareStr,instantiationStr:instanStr);
                    var layoutCodeStr = ""
                    if shouldHandleMargin(elem: elem){
                        let layoutVarName = handleMargin(elem: elem, varName: varName, codeStr: &layoutCodeStr)
                        return (layoutVarName, layoutCodeStr)
                    }
                    return (varName,layoutCodeStr)
                default:
                    print("Not Support HTML Tag \(tagName)")
                    return nil
                }
            }
        }
        else { //单元节点，可以直接进行替换,暂时为CHAR类型，以后再扩充
            //CHAR节点需要从父节点去寻找属性
            let parentNode = elem.parent as! Element
            let nodeVarName = generateVarName(elem, varType: .TEXT_NODE_TYPE)
            var textAttr = ""
            for attr in parentNode.propertyMap{
                switch attr.key {
                case "font-size":
                    textAttr.append(",NSFontAttributeName : [UIFont systemFontOfSize:\(cutNumberMark(str:attr.value))]")
                case "color" :
                    textAttr.append(",NSForegroundColorAttributeName : [UIColor colorWithHexString:@\"\(attr.value)\"]")
                default:
                    print("unknown text css atrribute: CHAR ---- \(attr.key) ---- Function: \(#function)")
                }
            }
            if(!textAttr.isEmpty) {textAttr.removeFirst()}
            let declareStr = "@property (strong, nonatomic) ASTextNode *\(nodeVarName);"
            let instanStr = """
            _\(nodeVarName) = [[ASTextNode alloc] init];
            _\(nodeVarName).attributedText = [[NSAttributedString alloc] initWithString:@"\(elem.charToken?.data ?? "")"  attributes:@{ \(textAttr)}];
            """
            
            let clsProperty = ClassProperty(nodeVarName,declareStr: declareStr, instantiationStr:instanStr)
            classPropertyArray [nodeVarName] = clsProperty //保存Node节点作为类属性
            return (nodeVarName,"")
        }
    }
    
    //是否采用Flex布局
    private func isFlex(elem: Element) -> Bool{
        if let i = elem.propertyMap.keys.index(of:"display") {
            return elem.propertyMap.values[i] == "flex"
        }
        return false
    }
    
    private func assembleSourceCode(_ varName: String, codeStr: String){
        let objcSourceCodeH = """
        #import <AsyncDisplayKit/AsyncDisplayKit.h>
        
        @interface \(nodeClassName) : ASDisplayNode
        
        @end
        
        """;
        var tempCode = ""
        for clsProperty in classPropertyArray{
            tempCode += clsProperty.value.declareStr;
            tempCode += "\n"
        }
        var objcSourceCodeM = """
        #import "\(nodeClassName).h"
        
        
        @interface \(nodeClassName) ()
        \(tempCode)
        @end
        
        """;
        tempCode = ""
        for clsProperty in classPropertyArray{
            tempCode += clsProperty.value.instantiationStr;
            tempCode += "\n"
        }
        objcSourceCodeM += """
        
        @implementation \(nodeClassName)
        - (instancetype)init
        {
        self = [super init];
        if (self) {
        self.automaticallyManagesSubnodes = YES;
        
        \(tempCode)
        }
        return self;
        }
        
        - (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize
        {
        @weakify(self);
        \(codeStr)
        return \(varName);
        }
        
        @end
        """
        let HFilePath:String = NSHomeDirectory() + "/Documents/\(nodeClassName).h"
        let MFilePath:String = NSHomeDirectory() + "/Documents/\(nodeClassName).m"
        try! objcSourceCodeH.write(toFile: HFilePath, atomically: true, encoding: String.Encoding.utf8)
        try! objcSourceCodeM.write(toFile: MFilePath, atomically: true, encoding: String.Encoding.utf8)
    }
    
    public func converter(_ doc: Document)->Document{
        for e in doc.children{
            if (e as! Element).startTagToken?.data=="body"{
                
                if let result = commonConverter(elem: e as! Element){
                    print(result.codeStr)
                    assembleSourceCode(result.varName, codeStr:  result.codeStr);
                }
            }
        }
        return doc
    }
}
