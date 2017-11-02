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
        var htmlStr = ""
//        htmlStr = """
//<!doctype html>
//<html>
//
//<head>
//  <meta charset="UTF-8" />
//  <title>FlexboxViewController</title>
//  <script src="vue.js"></script>
//  <script src="axios.min.js"></script>
//  <script src="lodash.min.js"></script>
//  <script src="currency-validator.js"></script>
//  <style>
//    #six {
//      flex-grow: 0;
//      flex-basis: 120px;
//      align-self: flex-end;
//    }
//    .big {
//      width: 120px; height: 200px; background-color: #00FF00; margin: 10px; color: #000000;
//    }
//    .small {
//      width: 100pt;
//      height: 40pt;
//      background-color: orange;
//      margin: 10pt;
//      color: #FF0000;
//      display: flex;
//      flex-direction: row;
//    }
//    .tinyBox {
//      width: 10pt; height: 10pt; background-color: red; margin: 5pt;
//    }
//    #main {
//      display: flex;
//      flex-direction: row;
//      flex-wrap: wrap;
//      flex-flow: row wrap;
//      justify-content: flex-start;
//      align-items: center;
//      align-content: flex-start;
//    }
//    ul {
//      display: flex;
//      flex-direction: column;
//      justify-content: center;
//      list-style-type: none;
//      align-items: center;
//      flex-wrap: wrap;
//      -webkit-padding-start: 0pt;
//    }
//  </style>
//</head>
//<body>
//  <div id="main">
//    <div class="big" id="smallbox">
//      <p class="small"></p>
//    </div>
//    <ul class="big">
//      <li class="tinyBox"></li>
//      <li class="tinyBox"></li>
//      <li class="tinyBox"></li>
//    </ul>
//    <ul class="big" id="more">
//      <li class="small">
//        <div class="tinyBox"></div>
//        <div class="tinyBox"></div>
//        <div class="tinyBox"></div>
//        <div class="tinyBox"></div>
//        <div class="tinyBox"></div>
//      </li>
//      <li class="small"></li>
//      <li class="small"></li>
//    </ul>
//    <div class="big" id="six"></div>
//    <div class="big"></div>
//    <div class="big"></div>
//  </div>
//</body>
//</html>
//"""
        htmlStr = """
        <!DOCTYPE html>
        <html>
        <head>
        <title></title>
        <style type="text/css">
        .stream {
        display: flex;
        -ms-flex-direction: column-reverse;
        flex-direction: column-reverse
        }
        .post {
        margin-bottom: 5px
        }
        .post {
        display: -ms-flexbox;
        display: flex
        }
        .postUser {
        -ms-flex: 0 1 auto;
        flex: 0 1 auto;
        padding-bottom: 10px
        }
        .postUser__portrait {
        display: -ms-flexbox;
        display: flex;
        -ms-flex-pack: center;
        justify-content: center;
        -ms-flex-align: center;
        align-items: center;
        width: 100px;
        height: 90px;
        font-size: 70px;
        line-height: 0
        }
        .icon {
        color: #BCD2DA;
        width: 70px;
        height: 70px
        }
        .postBody__content,
        .postUser__name {
        color: #57727C;
        font-size: 12px
        }
        
        .postUser__name {
        font-weight: 700;
        line-height: 1;
        text-align: center
        }
        .postBody {
        -ms-flex: 1 1 0%;
        flex: 1 1 0%;
        position: relative;
        padding: 15px;
        border: 1px solid #CAD0D2;
        border-radius: 4px
        }
        .postBody:after,
        .postBody:before {
        right: 100%;
        top: 35px;
        border: solid transparent;
        content: " ";
        height: 0;
        width: 0;
        position: absolute;
        pointer-events: none
        }
        .postBody:after {
        border-color: transparent #fff transparent transparent;
        border-width: 8px;
        margin-top: -8px
        }
        .postBody:before {
        border-color: transparent #CAD0D2 transparent transparent;
        border-width: 9px;
        margin-top: -9px
        }
        .postBody__date {
        margin-top: 5px;
        color: #86969C;
        font-size: 10px
        }
        .fpDemoPanel__codeType,
        .fpSectionTitle,
        .postBody__date {
        text-transform: uppercase;
        letter-spacing: 1px
        }
        
        
        </style>
        </head>
        <body>
        <div class="stream">
        <div class="post">
        <div class="postUser">
        <div class="postUser__portrait">
        <span class="icon"></span>
        </div>
        <div class="postUser__name">CJ C.</div>
        </div>
        <div class="postBody">
        <div class="postBody__content">
        Going hiking with @karla in Yosemite!
        </div>
        <div class="postBody__date">
        May 27
        </div>
        </div>
        </div>
        
        <div class="post">
        <div class="postUser">
        <div class="postUser__portrait">
        <span class="icon"></span>
        </div>
        <div class="postUser__name">Jatesh V.</div>
        </div>
        <div class="postBody">
        <div class="postBody__content">
        Flexboxpatterns.com is the most amazing flexbox resource I've ever used! It's changed my
        life forever and now everybody tells me that *I'M* amazing, too! Use flexboxpatterns.com!
        Love flexboxpatterns.com!
        </div>
        <div class="postBody__date">
        May 28
        </div>
        </div>
        </div>
        
        <div class="post">
        <div class="postUser">
        <div class="postUser__portrait">
        <span class="icon"></span>
        </div>
        <div class="postUser__name">Damien S.</div>
        </div>
        <div class="postBody">
        <div class="postBody__content">
        Anybody else wondering when the Blade Runner and Westworld tie-in will be released? #crossover
        #replicant
        </div>
        <div class="postBody__date">
        June 1
        </div>
        </div>
        </div>
        
        <div class="post">
        <div class="postUser">
        <div class="postUser__portrait">
        <span class="icon"></span>
        </div>
        <div class="postUser__name">Ziggie G.</div>
        </div>
        <div class="postBody">
        <div class="postBody__content">
        I love eating pizza!!!!!!!
        </div>
        <div class="postBody__date">
        June 5
        </div>
        </div>
        </div>
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
        
        //转 Textrue

        let layoutElement = LayoutElement().createRenderer(doc: document)
        _ = HTMLToTexture(nodeName:"Flexbox").converter(layoutElement);
        
        //TODO: 支持 JS Parser 成 AST
        let jsStr = """
var scale = 1.2;
function foo(o) {
    return scale * Math.sqrt(o.x * o.x + o.y * o.y);
}
for (var i = 0; i < 100; ++i)
    print(foo({x:1.5, y:2.5}));
"""
        let jsTokenizer = JSTokenizer(jsStr)
        let tks = jsTokenizer.parse()
        
        let jsTreeBuilder = JSTreeBuilder(jsStr)
        jsTreeBuilder.parser()
        
        print("\(tks)")
        for str in tks {
            print("\(str.data)")
        }
    }

}

