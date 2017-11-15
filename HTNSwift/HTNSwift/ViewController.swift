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
        let htmlStr = """
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
         <img class="icon" src="http://www.flexboxpatterns.com/images/dog_1.jpg"></img>
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
         <img class="icon" src="http://www.flexboxpatterns.com/images/dog_1.jpg"></img>
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
         <img class="icon" src="http://www.flexboxpatterns.com/images/dog_1.jpg"></img>
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
         <img class="icon" src="http://www.flexboxpatterns.com/images/dog_1.jpg"></img>
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
//        document.des() //打印包含样式信息的 DOM 树
//        print("\(tks)\(cssStyle)\(document)")
        
        //转 Textrue
//        let layoutElement = LayoutElement().createRenderer(doc: document)
//        _ = HTMLToTexture(nodeName:"Flexbox").converter(layoutElement);
        
        //TODO: 支持 JS Parser 成 AST
        let jsStr = """
switch (expr) {
  case 'Oranges':
    console.log('Oranges are $0.59 a pound.');
    break;
  case 'Apples':
    console.log('Apples are $0.32 a pound.');
    break;
  case 'Bananas':
    console.log('Bananas are $0.48 a pound.');
    break;
  case 'Cherries':
    console.log('Cherries are $3.00 a pound.');
    break;
  case 'Mangoes':
  case 'Papayas':
    console.log('Mangoes and papayas are $2.79 a pound.');
    break;
  default:
    console.log('Sorry, we are out of ' + expr + '.');
}
salva.name;
salva.greeting();
a = b;
"""
//        let jsTokenizer = JSTokenizer(jsStr)
//        let tks = jsTokenizer.parse()
//        for str in tks {
//             print("[\(str.type)]\(str.data)")
//        }
        let jsTreeBuilder = JSTreeBuilder(jsStr)
        jsTreeBuilder.parser()
        jsTreeBuilder.rootNode.des()
        
    }

}

