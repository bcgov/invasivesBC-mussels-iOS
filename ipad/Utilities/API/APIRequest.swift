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

enum APIRequestType {
    case Get
    case Post
}

class APIRequest {
    static func headers() -> HTTPHeaders {
        if let token = AuthenticationService.getAccessToken() {
            return ["Authorization": "Bearer \(token)"]
        } else {
            return ["Content-Type": "application/json"]
        }
    }
    
    /*************************************************************************************************************/
    
    static func request(type: APIRequestType, endpoint: URL, params: [String: Any]? = nil, completion: @escaping (_ response: JSON?) -> Void) {
        
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
        
        if AuthenticationService.isAuthTokenExpired() && !AuthenticationService.isRefreshExpired() {
            AuthenticationService.refreshCredentials { (success) in
                if !success {
                    return completion(nil)
                }
                switch type {
                case .Get:
                    get(endpoint: endpoint, completion: completion)
                case .Post:
                    post(endpoint: endpoint, params: params ?? [String: Any](), completion: completion)
                }
            }
        } else if !AuthenticationService.isAuthTokenExpired() {
            switch type {
            case .Get:
                get(endpoint: endpoint, completion: completion)
            case .Post:
                post(endpoint: endpoint, params: params ?? [String: Any](), completion: completion)
            }
        } else {
            print("Tokens Expired")
            return completion(nil)
        }
        
    }
    
    
    // MARK: GET request
    private static func get(endpoint: URL, completion: @escaping (_ response: JSON?) -> Void) {
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
        _ = Alamofire.request(endpoint, method: .get, headers: headers()).responseData { (response) in
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
        //        debugPrint(req)
    }
    
    static func post(endpoint: URL, params: [String: Any], completion: @escaping (_ response: JSON?) -> Void) {
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
        
        // Request
        _ = Alamofire.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers()).responseJSON { response in
            completed = true
            if timedOut {return}
            guard response.result.description == "SUCCESS", let value = response.result.value else {
                return completion(nil)
            }
            let json = JSON(value)
            if let error = json["error"].string {
                print("POST call rejected:")
                print("Endpoint: \(endpoint)")
                print("Error: \(error)")
                return completion(nil)
            } else {
                // Success
                return completion(json)
            }
        }
        //        debugPrint(req);
    }
    
    public static func fetchCodeTables(then: @escaping([String:Any]?)->Void) {
        guard let url = URL(string: APIURL.codes) else {return then(nil)}
        self.request(type: .Get, endpoint: url) { (_response) in
            guard let response = _response else {return then(nil)}
            var result: [String:Any] = [String:Any]()
            let data = response["data"]
            DispatchQueue.global(qos: .background).async {
                for (key, value) in data {
                    result[key] = value.arrayValue
                }
                return then(result)
            }
        }
    }
    
    public static func fetchWaterBodies(then: @escaping([[String:Any]]?)->Void) {
        guard let url = URL(string: APIURL.waterBody) else {return then(nil)}
        self.request(type: .Get, endpoint: url) { (_response) in
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
    
    private static func fetchUser(then: @escaping([String: JSON]?)->Void) {
        guard let url = URL(string: APIURL.user) else {return then(nil)}
        self.request(type: .Get, endpoint: url) { (_response) in
            guard let response = _response else {return then(nil)}
            let data = response["data"].dictionaryValue
            return then(data)
        }
    }
    
    private static func fetchUserRoles(then: @escaping([UserRoleModel])-> Void) {
        fetchUser { (result) in
            guard let userDictionary = result else {return then([])}
            guard let roles = userDictionary["roles"]?.arrayValue else {
                return then([])
            }
            var roleModels: [UserRoleModel] = []
            for role in roles {
                let roleName = role["role"].stringValue
                let roleCodeName = role["code"].stringValue
                let roleCode = role["role_code_id"].intValue
                roleModels.append(UserRoleModel(role: roleName, code: roleCodeName, roleCode: roleCode))
            }
            return then(roleModels)
        }
    }
    
    public static func checkAccess(then: @escaping(Bool)-> Void) {
        fetchUserRoles { (roles) in
            for role in roles where role.roleCode == AccessService.AccessRoleID || role.roleCode == AccessService.AccessRoleID_ADM || role.roleCode == AccessService.AccessRoleID_Inspect_ADM {
                return then(true)
            }
            return then(false)
        }
    }
    
    public static func checkAccessRequest(then: @escaping(Bool)-> Void) {
        guard let url = URL(string: APIURL.assessRequest) else {return then(false)}
        self.request(type: .Get, endpoint: url) { (_response) in
            // TODO: THIS ENDPOINT IS CURRENTLY NOT FUNCTIONION PROPERLY.
           //  print(_response)
            return then(false)
        }
    }
    
    public static func sendAccessRequest(then: @escaping(Bool?)->Void) {
        guard let url = URL(string: APIURL.assessRequest) else {return then(nil)}
        checkAccessRequest { (exists) in
            if exists {return then(true)}
            let body: [String : Any] = [
                "requestedAccessCode": AccessService.AccessRoleID,
                "requestNote": "Mobile Access"
            ]
            self.request(type: .Post, endpoint: url, params: body){ (_response) in
                guard let response = _response else {return then(nil)}
                print(response)
                let errors = response["errors"].arrayValue
                if errors.count > 0 {
                    return then(false)
                } else {
                    let data = response["data"].dictionaryValue
                    if (data["requestedAccessCode"]?.dictionaryValue) != nil {
                        return then(true)
                    }
                }
                return then(false)
            }
        }
    }
    
    /*!
     * File Upload API
     * @param File URL
     * @param Other File info
     * @param Completion Handler
     */
    public static func uploadFile(fileURL: URL, info: [String : String], timeout: TimeInterval = 60, then: @escaping BooleanAction) {
        if !fileURL.isFileURL || FileManager.default.fileExists(atPath: fileURL.absoluteString) {
            ErrorLog("File does not exists in path: \(fileURL.absoluteString)")
            then(false)
            return
        }
        
        // Timer
        var completed = false
        setTimeout(time: timeout) {
            if !completed {
                ErrorLog("File upload [TIMEOUT] \n file: (\(fileURL)) ")
                Banner.show(message: "File Upload Timeout")
                then(false)
            }
        }
        
        
        // Send Request
        upload(multipartFormData: { (form: MultipartFormData) in
            // Adding attributes
            for (k,v) in info {
                form.append(v.data, withName: k)
            }
            // Adding file data
            form.append( fileURL, withName: "file")
        }, usingThreshold: UInt64.init(), to: APIURL.uploads,  method: .post, headers: headers()) { result in
            switch result {
            case .success(let request, _, _):
                request.responseJSON { response in
                    // Mark completed
                    completed = true
                    // Check error
                    if let err = response.error {
                        ErrorLog("Request failure for file: \(fileURL) \nError: \(err)")
                        then(false)
                        return
                    }
                    // Check response body
                    guard let value = response.result.value else {
                        ErrorLog("No Value return by server \n file: \(fileURL)")
                        then(false)
                        return
                    }
                    let json = JSON(value)
                    if let err = json["error"].string {
                        ErrorLog("Server returns error: \(err)\n file: \(fileURL)")
                        then(false)
                        return
                    }
                    InfoLog("File Upload [SUCCESS] \n file: \(fileURL)")
                    then(true)
                }
            case .failure(let err):
                ErrorLog("File Encoding error: \(err) \n file: \(fileURL)")
                completed = true
                then(false)
            }
        }
    }
    public static func uploadFile(filePath: String, info: [String: String], timeout: TimeInterval = 60, then: @escaping (Bool) -> Void) {
        self.uploadFile(fileURL: URL(fileURLWithPath: filePath), info: info, timeout: timeout, then: then)
    }
}
