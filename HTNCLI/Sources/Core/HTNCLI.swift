//
//  HTNCLI.swift
//  HTNCLI
//
//  Created by 陈爱彬 on 2018/4/17. Maintain by 陈爱彬
//  Description 
//

import Foundation
import HTN
import PathKit

public class HTNCLI {
    public static let version = "0.1.0"
    
    let sema = DispatchSemaphore(value: 0)
    
    public init() {}
    
    //build h5editor urls and export to outputPath
    public func buildH5Editor(urls: [String], outputPath: String) {
        let path = Path(outputPath)
        for url in urls {
            print("Request url:\(url)")
            SMNetWorking<H5Editor>().requestJSON(url) { (jsonModel) in
                let converter = H5EditorToFrame<H5EditorObjc>(H5EditorObjc())
                let reStr = converter.convert(jsonModel)
//                print(reStr)
//                print(converter.m.pageId)
                let hPath = path + Path(converter.m.pageId + ".h")
                let mPath = path + Path(converter.m.pageId + ".m")
                self.writeFileToPath(hPath, content: reStr.0)
                self.writeFileToPath(mPath, content: reStr.1)
                self.sema.signal()
            }
            sema.wait()
        }
    }
    //write response to path
    func writeFileToPath(_ path: Path, content: String) {
        try? path.write(content)
    }
}
