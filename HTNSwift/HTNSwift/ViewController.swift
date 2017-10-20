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
//        let htmlStr = "<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"><!--comment --><html><head><script type="text/javascript">try{document.execCommand("BackgroundImageCache", false, true);}catch(e){}</script><style type="text/css">.dice-example td, .dice-example th { border: solid thin; width: 1.35em; height: 1.05em; text-align: center; padding: 0; } .aa {border:solid;} aaa {border:lll;} #cccs {border:cccsss;kkk:999;lll:0px;}</style></head><body background="#!kd" style="dskf*&^$#">as<aaa/><input class="aa" text=""/>dfs<li id="cccs"></li></body></html>"
//        let htmlStr = "<!doctype html><html><head> <meta charset="UTF-8" /> <title>FlexboxViewController</title> <script src="vue.js"></script> <script src="axios.min.js"></script> <script src="lodash.min.js"></script> <script src="currency-validator.js"></script> <style> #six { flex-grow: 0;  flex-basis: 120pt;  align-self: flex-end;  } .big { width: 120pt; height: 200pt; background-color: black; margin: 10pt; color: white; } .small { width: 100pt; height: 40pt; background-color: orange; margin: 10pt; color: white; display: flex; flex-direction: row; } .tinyBox { width: 10pt; height: 10pt; background-color: red; margin: 5pt; } #main { display: flex; flex-direction: row;  flex-wrap: wrap; flex-flow: row wrap; justify-content: flex-start; align-items: center; align-content: flex-start; } ul { display: flex; flex-direction: column; justify-content: center; list-style-type: none; align-items: center; flex-wrap: wrap; -webkit-padding-start: 0pt; } </style></head><body> <div id="main"> <div class="big" id="smallbox"> <p class="small"></p> </div> <ul class="big"> <li class="tinyBox"></li> <li class="tinyBox"></li> <li class="tinyBox"></li> </ul> <ul class="big" id="more"> <li class="small"> <div class="tinyBox"></div> <div class="tinyBox"></div> <div class="tinyBox"></div> <div class="tinyBox"></div> <div class="tinyBox"></div> </li> <li class="small"></li> <li class="small"></li> </ul> <div class="big" id="six"></div> <div class="big"></div> <div class="big"></div> </div></body></html>"
        let htmlStr = """
<!doctype html>
<html>

<head>
  <meta charset="UTF-8" />
  <title>FlexboxViewController</title>
  <script src="vue.js"></script>
  <script src="axios.min.js"></script>
  <script src="lodash.min.js"></script>
  <script src="currency-validator.js"></script>
  <style>
    #six {
      flex-grow: 0;
      flex-basis: 120pt;
      align-self: flex-end;
    }
    .big {
      width: 120pt; height: 200pt; background-color: black; margin: 10pt; color: white;
    }
    .small {
      width: 100pt;
      height: 40pt;
      background-color: orange;
      margin: 10pt;
      color: white;
      display: flex;
      flex-direction: row;
    }
    .tinyBox {
      width: 10pt; height: 10pt; background-color: red; margin: 5pt;
    }
    #main {
      display: flex;
      flex-direction: row;
      flex-wrap: wrap;
      flex-flow: row wrap;
      justify-content: flex-start;
      align-items: center;
      align-content: flex-start;
    }
    ul {
      display: flex;
      flex-direction: column;
      justify-content: center;
      list-style-type: none;
      align-items: center;
      flex-wrap: wrap;
      -webkit-padding-start: 0pt;
    }
  </style>
</head>
<body>
  <div id="main">
    <div class="big" id="smallbox">
      <p class="small"></p>
    </div>
    <ul class="big">
      <li class="tinyBox"></li>
      <li class="tinyBox"></li>
      <li class="tinyBox"></li>
    </ul>
    <ul class="big" id="more">
      <li class="small">
        <div class="tinyBox"></div>
        <div class="tinyBox"></div>
        <div class="tinyBox"></div>
        <div class="tinyBox"></div>
        <div class="tinyBox"></div>
      </li>
      <li class="small"></li>
      <li class="small"></li>
    </ul>
    <div class="big" id="six"></div>
    <div class="big"></div>
    <div class="big"></div>
  </div>
</body>
</html>
"""
        let treeBuilder = HTMLTreeBuilder(htmlStr)
        _ = treeBuilder.parse()
        let cssStyle = CSSParser(treeBuilder.doc.allStyle()).parseSheet()
        let document = StyleResolver().resolver(treeBuilder.doc, styleSheet: cssStyle)
        document.des() //打印包含样式信息的 DOM 树
//        print("\(tks)\(cssStyle)\(document)")
        
        //TODO: 转原生，待完成，先前实现了转 Yoga 原生代码，在项目在 https://github.com/ming1016/smck 里，具体转原生的代码实现在：https://github.com/ming1016/smck/blob/master/smck/Plugin/H5ToSwiftByFlexBoxPlugin.swift 。
        //接下来打算将其转换成 Texture 让效率更高
        
        //TODO: 支持 JS Parser 成 AST
        let jsStr = """
var scale = 1.2;
function foo(o) {
    return scale * Math.sqrt(o.x * o.x + o.y * o.y);
}
for (var i = 0; i < 100; ++i)
    print(foo({x:1.5, y:2.5}));
"""
    }

}

