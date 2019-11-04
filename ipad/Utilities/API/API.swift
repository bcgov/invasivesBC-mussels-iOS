//
//  API.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Foundation
import Alamofire
import SwiftyJSON
import Reachability
import SingleSignOn

class API {
    
    private static func headers() -> HTTPHeaders {
        if let token = Auth.getAccessToken() {
            return ["Authorization": "Bearer \(token)"]
        } else {
            return ["Content-Type": "application/json"]
        }
    }
    
    // MARK: Put Post and Get requests
    public static func put(endpoint: URL, params: [String: Any], completion: @escaping (_ response: Bool) -> Void) {
        var request = URLRequest(url: endpoint)
        request.httpMethod = HTTPMethod.put.rawValue
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        if let token = Auth.getAccessToken() {
             request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let data = try! JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        request.httpBody = data
        
        // API INPUT DATA LOGGING
        print("API PUT REQUEST: " + endpoint.absoluteString + " " + AnyDictToJSONString(inputdata: params));
        
        // Manual 20 second timeout for each call
        var completed = false
        var timedOut = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if !completed {
                timedOut = true
                Banner.show(message: "Request Time Out")
                return completion(false)
            }
        }
        
        let req = Alamofire.request(request).responseJSON { response in
            completed = true
            if timedOut {return}
            
             //API RESPONSE LOGGING:
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("API PUT RESPONSE:  " + endpoint.absoluteString + "  " + utf8Text);
            }
            
            if let rsp = response.result.value, let responseJSON: JSON = JSON(rsp), let error = responseJSON["error"].string {
                print("PUT ERROR:")
                print(error)
                return completion(false)
            }
            
            if let rsp = response.response {
                print("PUT Request received status code \(rsp.statusCode).")
            }
            
            return completion(!response.result.isFailure)
        }
        // prints a curl request mirroring this alamo one
        debugPrint(req);
    }
    
    public static func post(endpoint: URL, params: [String: Any], completion: @escaping (_ success: Bool) -> Void) {
        // Manual 20 second timeout for each call
        var completed = false
        var timedOut = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if !completed {
                timedOut = true
                Banner.show(message: "Request Time Out")
                return completion(false)
            }
        }
        
        // API INPUT DATA LOGGING
        print("API POST REQUEST:  " + endpoint.absoluteString + "  " +  AnyDictToJSONString(inputdata: params));
        
        // Request
        let req = Alamofire.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers()).responseJSON { response in
            completed = true
            if timedOut {return}
            
            if response.result.description == "SUCCESS", let value = response.result.value {
                
                // API RESPONSE LOGGING
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("API GET RESPONSE:  " + endpoint.absoluteString + "  " + utf8Text);
                }
                
                let json = JSON(value)
                if let error = json["error"].string {
                    print("GET call rejected:")
                    print("Endpoint: \(endpoint)")
                    print("Error: \(error)")
                    return completion(false)
                } else {
                    // Success
                    return completion(true)
                }
            } else {
                print("GET call failed:")
                print("Endpoint: \(endpoint)")
                return completion(false)
            }
            
        }
        // prints a curl request mirroring this alamo one
        debugPrint(req);
    }
    
    public static func get(endpoint: URL, completion: @escaping (_ response: JSON?) -> Void) {
        // Manual 20 second timeout for each call
        var completed = false
        var timedOut = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if !completed {
                timedOut = true
                Banner.show(message: "Request Time Out")
                return completion(nil)
            }
        }
        
        let configuration = URLSessionConfiguration.default
        // disable default credential store
        configuration.urlCredentialStorage = nil
        
        // API INPUT DATA LOGGING
        print("API GET REQUEST:  " + endpoint.absoluteString );
        
        let req = Alamofire.request(endpoint, method: .get, headers: headers()).responseData { (response) in
            completed = true
            if timedOut {return}
            
            if response.result.description == "SUCCESS", let value = response.result.value {
                
                // API RESPONSE LOGGING
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("API GET RESPONSE:  " + endpoint.absoluteString + "  " + utf8Text);
                }
                
                let json = JSON(value)
                if let error = json["error"].string {
                    print("GET call rejected:")
                    print("Endpoint: \(endpoint)")
                    print("Error: \(error)")
                    return completion(nil)
                } else {
                    // Success
                    return completion(json)
                }
            } else {
                print("GET call failed:")
                print("Endpoint: \(endpoint)")
                return completion(nil)
            }
        }
        
        // prints a curl request mirroring this alamo one
        debugPrint(req);
    }
    
    private static func JSONtoString(inputJSON: JSON) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: inputJSON, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return " *  unable to serialize JSON * ";
        }
        
        if let result = String(data: data, encoding: String.Encoding.utf8) {
            return result;
        }
        else {
            return " * JSON data deserialized as nil * ";
        }
    }
    
    private static func AnyDictToJSONString(inputdata: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: inputdata, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return " *  unable to serialize [string:any] * ";
        }
        
        if let result = String(data: data, encoding: String.Encoding.utf8) {
            return result;
        }
        else {
            return " * [string:any] data deserialized as nil * ";
        }
    }
}
