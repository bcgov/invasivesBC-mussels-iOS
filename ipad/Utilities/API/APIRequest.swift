//
//  APIRequest.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-02-12.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Reachability
import SingleSignOn
import Realm
import RealmSwift

class APIRequest {
    static func headers() -> HTTPHeaders {
        if let token = Auth.getAccessToken() {
            return ["Authorization": "Bearer \(token)"]
        } else {
            return ["Content-Type": "application/json"]
        }
    }
    
    /*************************************************************************************************************/
    
    // MARK: GET request
    private static func get(endpoint: URL, completion: @escaping (_ response: JSON?) -> Void) {
        // Reachability
        do {
            let reacahbility = try Reachability()
            if (reacahbility.connection == .unavailable) {
                Banner.show(message: "No Connection")
                return completion(nil)
            }
        } catch  let error as NSError {
            print("** Reachability ERROR")
            print(error)
            return completion(nil)
        }
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
        _ = Alamofire.SessionManager(configuration: configuration)
        
        // Make the call
        let req = Alamofire.request(endpoint, method: .get, headers: headers()).responseData { (response) in
            completed = true
            if timedOut {return}
            
            guard response.result.description == "SUCCESS", let value = response.result.value else {
                return completion(nil)
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
            
        }
        debugPrint(req)
    }
    
    public static func fetchCodeTables(then: @escaping([String:Any]?)->Void) {
        guard let url = URL(string: APIURL.codes) else {return then(nil)}
        self.get(endpoint: url) { (_response) in
            guard let response = _response else {return then(nil)}
            var result: [String:Any] = [String:Any]()
            let data = response["data"]
            DispatchQueue.global(qos: .background).async {
                for (key, value) in data {
                    result[key] = value.arrayValue.map { $0.stringValue}
                }
                return then(result)
            }
        }
    }
    
    public static func fetchWaterBodies(then: @escaping([[String:Any]]?)->Void) {
        guard let url = URL(string: APIURL.waterBody) else {return then(nil)}
        self.get(endpoint: url) { (_response) in
            guard let response = _response else {return then(nil)}
            var result: [[String:Any]] = [[String:Any]()]
            let data = response["data"]
            DispatchQueue.global(qos: .background).async {
                for (_, value) in data {
                    result.append(value.dictionaryValue)
                }
                return then(result)
            }
        }
    }
}
