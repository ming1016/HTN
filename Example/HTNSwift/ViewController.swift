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
        
//        let a = JTokenizer("(add 2 (subtract 4.4 2))").tokenizer()
//        print("\(a)")
        CodeGeneratorFromJSToOC("(add 2 (subtract 4.4 2))")
        
        
        //justTest()
        
        
    }
//    class CM {
//
//        func shell(_ args: String..., path: String = "/usr/bin/") -> (Int32, String) {
//            let process = Process()
//            process.launchPath = path
//            process.arguments = args
//
//            let pipe = Pipe()
//            process.standardOutput = pipe
//
//            process.launch()
//            process.waitUntilExit()
//
//
//            let data = pipe.fileHandleForReading.readDataToEndOfFile()
//            let output: String = String(data: data, encoding: .utf8)!
//
//            return (process.terminationStatus, output)
//        }
//    }

}

