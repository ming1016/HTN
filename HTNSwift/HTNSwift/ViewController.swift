//
//  ViewController.swift
//  HTNSwift
//
//  Created by DaiMing on 2017/10/11.
//  Copyright © 2017年 Starming. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        let htmlStr = "<html><head><title>First parse</title></head><body><p>Parsed HTML into a doc.</p></body></html>"
        let htmlStr = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\"><!--comment --><html><head><script type=\"text/javascript\">try{document.execCommand(\"BackgroundImageCache\", false, true);}catch(e){}</script><style type=\"text/css\">.dice-example td, .dice-example th { border: solid thin; width: 1.35em; height: 1.05em; text-align: center; padding: 0; }</style></head><body background=\"#!kd\" style=\"dskf*&^$#\">as<aaa/><input text=\"\"/>dfs</body></html>"
        let treeBuilder = HTMLTreeBuilder(htmlStr)
        let doc = treeBuilder.parse()
        let cssStyle = CSSParser(treeBuilder.doc.allStyle()).parseSheet()
        print("\(doc)\(cssStyle)")
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

