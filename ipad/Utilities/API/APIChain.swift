//
//  APITestHelper.swift
//  ipadTests
//
//  Created by Pushan  on 2019-11-12.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

/**
 * Typealias of closure: Process API call
 *  Param
 *          api: API object to call
 *          data: JSON Codable request data for api
 *          additionalData: Data gathered by previous api call
 *   Returns:
 *          Promise<Any>
 */
typealias APIDataProcess =  ((_ api: API, _ data: JSONCodable, _ additionalData: Any?) -> Promise<Any>?)

/***
  * Tuple to store api invoke info
 */
typealias APITuple = (api: API, data: JSONCodable, process: APIDataProcess)

/*!
 * Chain result
 */
typealias APIChainResult = ((_ results: [Any]) -> Void)

/**
  * APIChain: Chain of API call invoker
 */
class APIChain: NSObject {
    // Shared Object
    static let shared: APIChain = {
        return APIChain()
    }()
    
    // Promise object to store current api invoke
    var promise: Promise<Any>?
    
    // Store collective results
    var results: [Any] = [Any]()
    
    /*!
     * 
     */
    func callAPI(_ api: API,_ data: JSONCodable,_ prev: Any?,_ process: APIDataProcess, _ done: @escaping InfoAction) {
        // Calling process data with result of prev
        self.promise = process(api, data, prev)
        if let _ = self.promise {
            self.promise?.then({ (resp, _) in
                InfoLog("\(api.tag) | [COMPELETE]")
                done(resp)
            })
            self.promise?.error({ (err, _) in
                ErrorLog("\(api.tag) | ERROR | \(err)")
                done(nil)
            })
        } else {
            InfoLog("\(api.tag) | Unable to proecess api call")
            done(nil)
        }
        
    }
    
    func call(apis: [APITuple], incomingData: Any? = nil, completion: @escaping APIChainResult) {
        if apis.count == 0 {
            completion(self.results)
            return
        } else {
            if let tuple = apis.first {
                self.callAPI(tuple.api, tuple.data, incomingData, tuple.process) { (info: Any?) in
                    // Remove first
                    var temp = [APITuple](apis)
                    temp.removeFirst()
                    if let `info`: Any = info {
                        self.results.append(`info`)
                    }
                    self.call(apis: temp, incomingData: info, completion: completion)
                }
            } else {
                completion(self.results)
                return
            }
        }
    }
}
