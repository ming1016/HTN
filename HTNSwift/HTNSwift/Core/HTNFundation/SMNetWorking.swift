//
//  HTNNetworking.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/29.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

open class SMNetWorking<T:Codable> {
    var op:Optionals = Optionals()
    
    open let session:URLSession
    
    //处理数据的 block
    typealias CompletionJSONClosure = (_ data:T) -> Void
    var completionJSONClosure:CompletionJSONClosure =  {_ in }
    
    //配置 request
    typealias ConfigRequestClosure = (_ request:URLRequest) -> Void
    var configRequestClosure:ConfigRequestClosure = {_ in }
    
    public init() {
        self.session = URLSession.shared
    }
    
    //JSON的请求
    func requestJSON(_ url: SMURLNetWorking,
                     doneClosure:@escaping CompletionJSONClosure
                    ) {
        self.completionJSONClosure = doneClosure
        var request:URLRequest = NSURLRequest.init(url: url.asURL()) as URLRequest
        request.httpMethod = op.httpMethod.rawValue
        self.configRequestClosure(request) //block 方式自定义 request 的属性
        let task = self.session.dataTask(with: request) { (data, res, error) in
            if (error == nil) {
                let decoder = JSONDecoder()
                do {
                    print("解析 JSON 成功")
                    let jsonModel = try decoder.decode(T.self, from: data!)
                    self.completionJSONClosure(jsonModel)
                } catch {
                    print("解析 JSON 失败")
                }
            }
        }
        task.resume()
    }
    
    //链式方法
    //HTTPMethod 的设置
    func method(_ md:HTTPMethod) -> SMNetWorking {
        self.op.httpMethod = md
        return self
    }
    func configRequest(_ c:@escaping ConfigRequestClosure) -> SMNetWorking {
        self.configRequestClosure = c
        return self
    }
    
    //struct
    struct Optionals {
        var httpMethod:HTTPMethod = .GET
        //后期继续添加更多
        //...
    }
    
    //enum
    enum HTTPMethod: String {
        case GET,OPTIONS,HEAD,POST,PUT,PATCH,DELETE,TRACE,CONNECT
    }
    
}

/*----------Protocol----------*/
protocol SMURLNetWorking {
    func asURL() -> URL
}

/*----------Extension---------*/
extension String: SMURLNetWorking {
    public func asURL() -> URL {
        guard let url = URL(string:self) else {
            return URL(string:"http:www.starming.com")!
        }
        return url
    }
}



