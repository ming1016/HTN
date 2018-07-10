//
//  ViewController.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/11.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Cocoa
import HTN


struct Data {
    let a: String
}


@available(OSX 10.13, *)
@available(OSX 10.13, *)
class ViewController: NSViewController {
    
    @IBOutlet weak var inputLb: NSTextField!
    
    @IBOutlet var nativeCodeLb: NSTextView!
    @IBOutlet weak var inputTypeSelect: NSPopUpButton!
    @IBOutlet weak var toNativeBt: NSButton!
    
    @IBAction func toNativeAction(_ sender: Any) {
        guard let item = inputTypeSelect.selectedItem else {
            return
        }
        switch item.title {
        case "HTML 转 Texture":
            htmlToTexture()
        case "JSON 转 Frame":
            jsonToFrame()
        case "Javascript 测试":
            javascriptTest()
        default:
            htmlToTexture()
        }
        
    }
    
    func jsonToFrame() {
        guard inputLb.stringValue.count > 0 else {
            return;
        }
        //请求地址在输入框输入
        SMNetWorking<H5Editor>().requestJSON(inputLb.stringValue) { (jsonModel) in
            guard let model = jsonModel else {
                return
            }
            let reStr = H5EditorToFrame<H5EditorObjc>(H5EditorObjc()).convert(model)
//            print(reStr)
            DispatchQueue.main.async {
                self.nativeCodeLb.string = reStr.0 + "\n\n" + reStr.1
            }
        }
    }
    public func javascriptTest() {
        
    }
    
    
    
    //递归所有子节点
    public func htmlToTexture() {
        let treeBuilder = HTMLTreeBuilder(inputLb.stringValue)
        _ = treeBuilder.parse()
        let cssStyle = CSSParser(treeBuilder.doc.allStyle()).parseSheet()
        let document = StyleResolver().resolver(treeBuilder.doc, styleSheet: cssStyle)
        document.des() //打印包含样式信息的 DOM 树
        
        //转 Textrue
        let layoutElement = LayoutElement().createRenderer(doc: document)
        _ = HTMLToTexture(nodeName:"Flexbox").converter(layoutElement);
        nativeCodeLb.string = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nativeCodeLb.font = NSFont.userFont(ofSize: 16)
        
        var caseStr = "31 + 8 / 2 * 3"
        
        caseStr = "31 + (4 + 5 - (3 + 3)) * 4 - (1 + (51 - 4))"
        caseStr = "4 + 3 * 2"
        //caseStr = "4 + 3 - 2"
        caseStr = "4 + - 3 * 2"
        caseStr = """
        @interface OurClass
        // 定义属性
        @property (nonatomic, assign) NSUInteger pa;
        @property (nonatomic, assign) NSUInteger pb;
        
        @end
        
        @implementation OurClass
        
        /* 开始运算 */
        - (void)run {
            a = 13.3;
            ab = (3 + 2) + a * 2;
        }
        
        @end
        """
        
        let interperter = OCInterpreter(caseStr)
        
        print(interperter)
        
//        VueTest().LetTestBegin()
        
//        let jsonStringClear = justTest().replacingOccurrences(of: "\n", with: "")
//        let jsonData = jsonStringClear.data(using: .utf8)!
//
//        do {
//            let a = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! [Dictionary<String, Any>]
//            for c in a {
//                print(c["type"] ?? "")
//            }
//        } catch let error as NSError { print(error) }
        
    }

}





