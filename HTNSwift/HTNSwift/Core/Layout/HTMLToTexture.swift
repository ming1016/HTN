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
    
    enum VarType { 
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
                varName = "\(elem.startTagToken?.data ?? "displayNode")_\(HTMLToTexture.index)"
            }
            HTMLToTexture.index += 1;
        }
        else{
            varName = id!
        }
        return varName
    }
    
    private func convertStringToVar(_ text: String) -> (varName:String, codeStr: String){
        let varName = "str_\(HTMLToTexture.index)"
        HTMLToTexture.index += 1
        if text.trimmingCharacters(in: .whitespaces).isEmpty{
            return (varName, "NSString *\(varName) = @\"\";");
        }
        var codeStr = """
        NSMutableString *\(varName)= [[NSMutableString alloc] init];\n
        """
        let textArr = text.split(separator: "\n")
        for subText  in textArr {
            codeStr += "[\(varName) appendString:@\"\(subText)\"];\n"
        }
        return (varName, codeStr)
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
    
    //文本相关
    static let textAlignment = [
        "left":"NSTextAlignmentLeft", //default
        "center":"NSTextAlignmentCenter",
        "right":"NSTextAlignmentRight"
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
        if let renderObj = elem.renderer{
            if renderObj.borderWidth > 0{ //只有大于0时候，才进行设置
                instanStr.append("_\(nodeVarName).borderWidth = \(renderObj.borderWidth);\n")
                instanStr.append("_\(nodeVarName).borderColor =[UIColor colorWithHexString:@\"\(renderObj.borderColor ?? "#000000")\"].CGColor;\n")
            }
            if renderObj.borderRadius > 0{
                instanStr.append("_\(nodeVarName).cornerRadius = \(renderObj.borderRadius);\n")
            }
        }
        var newCodeStr = "";
        let renderObj = elem.renderer
        if (renderObj != nil) && !(renderObj!.padding_top == 0 && renderObj!.padding_left == 0 && renderObj!.padding_bottom == 0 && renderObj!.padding_right == 0){
            newCodeStr += """
            self.\(nodeVarName).layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            @strongify(self);
            \(codeStr)
            
            return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(\(renderObj!.padding_top), \(renderObj!.padding_left), \(renderObj!.padding_bottom), \(renderObj!.padding_right))
            child:\(classPropertyArray.keys.contains(varName) ? "self."+varName : varName)];
            };\n
            """
        }
        else{
            newCodeStr += """
            self.\(nodeVarName).layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            @strongify(self);
            \(codeStr)
            return [ASWrapperLayoutSpec wrapperWithLayoutElement:\(classPropertyArray.keys.contains(varName) ? "self."+varName : varName)];
            };\n
            """
        }
        codeStr = newCodeStr;
        classPropertyArray [nodeVarName] = ClassProperty(nodeVarName,declareStr: declareStr,instantiationStr: instanStr)
        return nodeVarName
    }
    
    func shouldHandleFlex(elem: Element) -> Bool {
        if let value = elem.propertyMap["flex"]{
            if value == "none"{
                return false
            }
            return true
        }
        return false
    }
    
    func handleFlexAttr(flexAttrStr: String, varName: String, codeStr: inout String) {
        let flexAttrArray = flexAttrStr.split(separator: " ").map(String.init)
        let varName0 = classPropertyArray.keys.contains(varName) ? "self."+varName : varName
        if flexAttrArray.count == 1{
            if flexAttrArray[0] == "auto" {
                codeStr += """
                \(varName0).style.flexGrow = 1;
                \(varName0).style.flexShrink = 1;
                \(varName0).style.flexBasis = \(varName0).style.width;\n
                """
            }
            else if  flexAttrArray[0] == "1"{
                codeStr += """
                \(varName0).style.flexGrow = 1;
                \(varName0).style.flexShrink = 1;
                \(varName0).style.flexBasis = \(varName0).style.width;\n
                """
            }
        }
        else {
            codeStr += """
            \(varName0).style.flexGrow = \(flexAttrArray[0]);
            \(varName0).style.flexShrink = \(flexAttrArray[1]);\n
            """
            if flexAttrArray[2] == "auto"{
                codeStr += "\(varName0).style.flexBasis = \(varName0).style.width;\n";
            }
            else if flexAttrArray[2] == "0%"{ //暂时发现这种写法 当flex-basis设置为0%的时候，其设置的宽度将不起任何作用，如item1中的wdith
                codeStr += "\(varName0).style.flexBasis = ASDimensionAuto;\n";
            }
            else {
                codeStr += "\(varName0).style.flexBasis =\(flexAttrArray[2]);\n";
            }
        }
    }
    
    /**
     返回一个stackLayout布局
     **/
    func stackLayoutSpec(elem: Element)-> (varName : String, codeStr : String)?{
        
        var layoutVarName = generateVarName(elem, varType: .LAYOUT_TYPE)
        var flex_direction = "row"
        var justify_content = "flex-start" //主轴默认值是flex-start
        var align_items = "stretch" //交叉轴默认值是stretch
        
        if let value = elem.propertyMap["flex-direction"]{
            flex_direction = value
        }
        
        if let value = elem.propertyMap["justify-content"]{
            justify_content = value
        }
        
        if let value = elem.propertyMap["align-items"]{
            align_items = value
        }
        var str="";
        var childArray="@[";
        let updateOrderChild = (flex_direction == "row-reverse" || flex_direction == "column-reverse") ? elem.children.reversed() : elem.children ;
        for child in updateOrderChild{
            guard let transformedStr = commonConverter(elem :child as! Element) else{
                continue
            }
            str += transformedStr.codeStr
            childArray.append(classPropertyArray.keys.contains(transformedStr.varName) ? "self."+transformedStr.varName : transformedStr.varName)
            if(child !== updateOrderChild.last!){
                childArray.append(",")
            }
        }
        childArray.append("]")
        if childArray == "@[]"{ //没有子元素，则不用返回布局
            return nil
        }
        
        if flex_direction == "row-reverse"{
            flex_direction = "row"
            if justify_content == "flex-start"{
                justify_content = "flex-end"
            }
            else if justify_content == "flex-end"{
                justify_content = "flex-start"
            }
        }
        
        if flex_direction == "column-reverse"{
            flex_direction = "column"
            if justify_content == "flex-start"{
                justify_content = "flex-end"
            }
            else if justify_content == "flex-end"{
                justify_content = "flex-start"
            }
        }
        
        str += """
        ASStackLayoutSpec * \(layoutVarName) = [ASStackLayoutSpec stackLayoutSpecWithDirection:\(HTMLToTexture.flexDirectionMap[flex_direction]!) spacing:0 justifyContent: \(HTMLToTexture.justifyContentMap[justify_content]!) alignItems: \(HTMLToTexture.alignItemMap[align_items]!) children:\(childArray)];
        
        """
        layoutVarName = handlePadding(elem: elem, varName: layoutVarName, codeStr: &str)
        if shouldHandleMargin(elem: elem){
            layoutVarName = handleMargin(elem: elem, varName: layoutVarName, codeStr: &str)
        }
        
        if shouldHandleFlex(elem: elem){
            handleFlexAttr(flexAttrStr: elem.propertyMap["flex"]!, varName: layoutVarName, codeStr: &str)
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
                } while i < elem.children.count && result == nil
                
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
                    let childArray = "\(classPropertyArray.keys.contains(varName) ? "self."+varName : varName), \(classPropertyArray.keys.contains(result.varName) ? "self."+result.varName : result.varName)"
                    let layoutVarName = "\(varName)_\(result.varName)"
                    codeStr += """
                    \(result.codeStr)
                    ASStackLayoutSpec * \(layoutVarName) = [ASStackLayoutSpec stackLayoutSpecWithDirection:\(HTMLToTexture.flexDirectionMap["column"]!) spacing:0.f  justifyContent: \(HTMLToTexture.justifyContentMap["flex-start"]!) alignItems: \(HTMLToTexture.alignItemMap["stretch"]!) children:@[\(childArray)]];
                    """
                    varName = layoutVarName
                }
                
                //先处理自己padding,再处理margin
                varName = handlePadding(elem: elem, varName: varName, codeStr: &codeStr)
                if shouldHandleMargin(elem: elem){
                    varName = handleMargin(elem: elem, varName: varName, codeStr: &codeStr)
                }
                if shouldHandleFlex(elem: elem){
                    handleFlexAttr(flexAttrStr: elem.propertyMap["flex"]!, varName: varName, codeStr: &codeStr)
                }
                return (varName, codeStr)
            }
            else { //非容器节点
                switch tagName{
                case "span","SPAN":
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
                    var layoutVarName = varName
                    if shouldHandleMargin(elem: elem){
                        layoutVarName = handleMargin(elem: elem, varName: varName, codeStr: &layoutCodeStr)
                    }
                    if shouldHandleFlex(elem: elem){
                        handleFlexAttr(flexAttrStr: elem.propertyMap["flex"]!, varName: varName, codeStr: &codeStr)
                    }
                    return (layoutVarName,layoutCodeStr)
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
                    var layoutVarName = varName
                    if shouldHandleMargin(elem: elem){
                        layoutVarName = handleMargin(elem: elem, varName: varName, codeStr: &layoutCodeStr)
                    }
                    if shouldHandleFlex(elem: elem){
                        handleFlexAttr(flexAttrStr: elem.propertyMap["flex"]!, varName: varName, codeStr: &codeStr)
                    }
                    return (layoutVarName,layoutCodeStr)
                case "IMG","img":
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
                    if let imgLink = elem.startTagToken?.attributeDic["src"] {
                        if imgLink.hasPrefix("http://") || imgLink.hasPrefix("https://"){ //网络图片
                            declareStr = "@property (nonatomic, strong) ASNetworkImageNode *\(varName);\n"
                            codeAtrr.append("_\(varName).URL = [NSURL URLWithString:@\"\(imgLink)\"];\n")
                            instanStr.append("_\(varName)=[[ASNetworkImageNode alloc] init];\n")
                        }
                        else{
                            declareStr = "@property (nonatomic, strong) ASImageNode *\(varName);\n"
                            codeAtrr.append("_\(varName).image = [UIImage imageNamed:@\"\(imgLink)\"];\n")
                            instanStr.append("_\(varName) = [[ASImageNode alloc] init];\n")
                        }
                    }
                    else{ //设置一个空的占位图片
                        declareStr = "@property (nonatomic, strong) ASNetworkImageNode *\(varName);\n"
                        instanStr.append("_\(varName) = [[ASImageNode alloc] init];\n")
                    }
                    instanStr.append(codeAtrr)
                    classPropertyArray[varName] = ClassProperty(varName,declareStr:declareStr,instantiationStr:instanStr);
                    var layoutCodeStr = ""
                    var layoutVarName = varName
                    if shouldHandleMargin(elem: elem){
                        layoutVarName = handleMargin(elem: elem, varName: varName, codeStr: &layoutCodeStr)
                    }
                    return (layoutVarName,layoutCodeStr)
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
            var textStyleStr = ""
            for attr in parentNode.propertyMap{
                switch attr.key {
                case "font-size":
                    textAttr.append(",NSFontAttributeName : [UIFont systemFontOfSize:\(cutNumberMark(str:attr.value))]")
                case "color" :
                    textAttr.append(",NSForegroundColorAttributeName : [UIColor colorWithHexString:@\"\(attr.value)\"]")
                case "text-align":
                    textStyleStr = """
                      NSMutableParagraphStyle * paragraphStyle_\(HTMLToTexture.index) = [[NSMutableParagraphStyle alloc] init];
                      paragraphStyle_\(HTMLToTexture.index).alignment = \(HTMLToTexture.textAlignment[attr.value] ?? HTMLToTexture.textAlignment["left"]!);\n
                    """
                   textAttr.append(",NSParagraphStyleAttributeName: paragraphStyle_\(HTMLToTexture.index)")
                  HTMLToTexture.index += 1
                default:
                    print("unknown text css atrribute: CHAR ---- \(attr.key) ---- Function: \(#function)")
                }
            }
            if(!textAttr.isEmpty) {textAttr.removeFirst()}
            let textData = elem.charToken?.data ?? ""
            let result = convertStringToVar(textData)
            let declareStr = "@property (strong, nonatomic) ASTextNode *\(nodeVarName);"
            let instanStr = """
            \(result.codeStr)
            _\(nodeVarName) = [[ASTextNode alloc] init];
            \(textStyleStr)
            _\(nodeVarName).attributedText = [[NSAttributedString alloc] initWithString:\(result.varName)  attributes:@{ \(textAttr)}];
            """
            
            let clsProperty = ClassProperty(nodeVarName,declareStr: declareStr, instantiationStr:instanStr)
            classPropertyArray [nodeVarName] = clsProperty //保存Node节点作为类属性
            return (nodeVarName,"")
        }
    }
    
    //是否采用Flex布局
    private func isFlex(elem: Element) -> Bool{
        if let value = elem.propertyMap["display"] {
            return value == "flex"
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
        print("\(MFilePath)")
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
