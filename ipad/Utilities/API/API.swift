//
//  API.swift
//  ipad
//
//  Created by Pushan  on 2019-11-08.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
typealias RemoteResponse = [String : Any]
let APIErrorKey: String = "errors"
let APIDataKey: String = "data"
class API: RemoteAPI<RemoteResponse>  {
    // TODO: Remove test token
    override var token: String {
        return TestToken
    }
    
    // Processing sever response
    override func processData(data: Data, more: Any?) -> (RemoteResponse?, Any?) {
        // Try JSON parsing here
        do {
            let parse: RemoteResponse = try (JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? RemoteResponse ?? [:])
            // Now check for error
            if let data = parse[APIDataKey] as? RemoteResponse {
                return (data, parse)
            } else {
                return (parse, more)
            }
        } catch let excp {
            InfoLog("Parsing Exception: \(excp)")
            return (nil, more)
            
        }
    }
    
    override func processError(_ errorData: Data) -> Any? {
        let e = super.processError(errorData)
        if let errorResp: [String: Any] = e as? [String: Any] {
            // Get errors
            if let errors: [Any] = errorResp[APIErrorKey] as? [Any] {
                return errors;
            }
        }
        return e
    }
}
