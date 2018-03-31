//
//  HTNNetworking.swift
//  HTNSwift
//
//  Created by DaiMing on 2018/3/29.
//  Copyright © 2018年 Starming. All rights reserved.
//

import Foundation

open class SMNetWorking<T:Codable> {
    open let session:URLSession
    
    typealias CompletionJSONClosure = (_ data:T) -> Void
    var completionJSONClosure:CompletionJSONClosure =  {_ in }
    
    public init() {
        self.session = URLSession.shared
    }
    
    //JSON的请求
    func requestJSON(_ url: SMURLNetWorking,
                     doneClosure:@escaping CompletionJSONClosure
                    ) {
        self.completionJSONClosure = doneClosure
        let request:URLRequest = NSURLRequest.init(url: url.asURL()) as URLRequest
        let task = self.session.dataTask(with: request) { (data, res, error) in
            if (error == nil) {
                let decoder = JSONDecoder()
                let jsonModel = try! decoder.decode(T.self, from: data!)
                self.completionJSONClosure(jsonModel)
            }
        }
        task.resume()
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



