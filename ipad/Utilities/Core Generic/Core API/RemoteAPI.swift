//
//  RemoteAPI.swift
//  FoodAnytime
//
//  Created by Pushan Mitra on 21/09/18.
//  Copyright © 2018 Pushan Mitra. All rights reserved.
//

import Foundation
import Alamofire

protocol JSONCodable {
    func json() -> Data
}

typealias JSONMap = [String: Any]
typealias JSONArray = [Any]

extension String: JSONCodable {
    func json() -> Data {
        return self.data(using: .utf8) ?? Data()
    }
    
}


extension Dictionary: JSONCodable {
    func json() -> Data {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return data
        } catch let exp {
            InfoLog("Exception while parsing dict: \(exp)")
            InfoLog("DICT: \(self)")
            return "".data
        }
    }
}

extension RemoteAPI {
    class func api() -> Self {
        return self.init(url: self.apiURL())
    }
}

struct VoidResponse: Codable {
    var status: String = "Success"
    var data: Data?
}

typealias PromiseVoidResp = Promise<VoidResponse>
typealias APIMethod = HTTPMethod

class RemoteAPI<R>: ExpressibleByStringLiteral {
    typealias Response = R
    typealias StringLiteralType = String
    
    /*class func api() -> self {
        return self.init(url: self.apiURL())
    }*/
    
    class func apiURL() -> String {
        return ""
    }
    
    
    var argMap: [String : String] = [:] {
        didSet {
            self._createURL()
        }
    }
    
    func body(method: APIMethod) -> JSONCodable {
        return ""
    }
    
    func postBody() -> JSONCodable? {
        return self.reqBody
    }
    
    func putBody() -> JSONCodable? {
        return self.reqBody
    }
    
    var isValid: Bool {
        return !self._url.isEmpty && URL(string: self._url) != nil
    }
    
    
    var token: String {
        return "";
    }
    
    
    var headers: RequestHeader  {
        return ["Content-Type" : "application/json","Authorization": "Bearer \(token)"]
    }
    internal var _url: String = ""
    internal var _unformattedURL: String = ""
    internal var _promise: Promise<Data>? = nil
    internal var reqBody: JSONCodable? = nil
    required init(url: String) {
        _url = url
        _unformattedURL = url
    }
    
    var urlOptions: [String] {
        return [String]();
    }
    
    var url: String {
        return self._url
    }
    
    var tag: String {
        return self._url.lastPathComponent;
    }
    
    convenience required init(stringLiteral value: RemoteAPI.StringLiteralType) {
        self.init(url: value)
    }
    
    // Subclass must override this
    func processData(data: Data, more: Any?) -> (Response?, Any?) {
        // Try JSON parsing here
        do {
            let parse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? Response
            return (parse, more)
        } catch let excp {
            InfoLog("Parsing Exception: \(excp)")
            return (nil, more)
            
        }
    }
    
    func processError(_ errorData: Data) -> Any? {
        // Parse error data
        do {
            let parse = try JSONSerialization.jsonObject(with: errorData, options: .mutableContainers)
            return parse
        } catch let excp {
            InfoLog("Parsing Exception: \(excp)")
            return nil
            
        }
    }
    
    
    func _invokeAPI(_ method: APIMethod,_ id: String? = nil) -> Promise<R>? {
        return Promise<Response>({ (resolve, reject) in
            if !isValid {
                InfoLog("Invalid URL : \(self._url)")
                DispatchQueue.main.async {
                    let message = "Invalid url: \(self._url)"
                    let error = AppError(code: ApplicationInvalidURLError, description: message, userInfo: nil)
                    reject(error, nil)
                }
                return
            }
            switch method {
            case .get:
                if let i: String = id {
                    let tempURL = self._url + "/\(i)"
                    self._promise = RemoteAPIManager.default.get(tempURL, self.headers)
                } else {
                    self._promise = RemoteAPIManager.default.get(self._url, self.headers)
                }
            case .post:
                let body = self.postBody() ?? self.body(method: method)
                self._promise = RemoteAPIManager.default.post(self._url, body: body.json(), headers)
            case .put:
                let body = self.putBody() ?? self.body(method: method)
                if let i: String = id {
                    let tempURL = self._url + "/\(i)"
                    self._promise = RemoteAPIManager.default.put(tempURL, body: body.json(), headers)
                } else {
                    self._promise = RemoteAPIManager.default.put(self._url, body: body.json(), headers)
                }
            default:
                self._promise = RemoteAPIManager.default.api(self._url, body: self.body(method: method).json(), method: method, headers)
            }
            

            // Success case
            self._promise?.then({ (info, _) in
                do {
                    // Process req.
                    let p = self.processData(data: info, more: nil)
                    // InfoLog("Data: \(p)")
                    if let resp: Response = p.0 {
                        resolve(resp, p.1)
                    } else {
                        throw AppError(description: "Unable to process json data")
                    }
                } catch (let excp) {
                    
                    if R.self == VoidResponse.self {
                        InfoLog("Void Response pattern: ignoring exception")
                        var voidResp = VoidResponse()
                        voidResp.data = info
                        let obj: R = voidResp as! R
                        resolve(obj, nil)
                    } else {
                        InfoLog("JSON Parsing Fail")
                        InfoLog("Reason: \(excp)")
                        InfoLog("Des: \(excp.localizedDescription): \((excp as NSError).code)")
                        let error: Error = AppError(code: ApplicationJSONParsingError, description:ApplicationJSONParsingErrorMessage , userInfo: nil)
                        reject(error, info)
                    }
                    
                }
            })
            
            
            // Fail Case
            self._promise?.error({ (error, data) in
                if let errData: Data = data as? Data {
                    reject(error, self.processError(errData))
                } else {
                    reject(error, nil)
                }
            })
        })
    }
    
    func get(arg: [String: String]? = nil, id: String? = nil) -> Promise<Response>? {
        if let a = arg {
            self.argMap = self.argMap.merge(a)
        }
        return self._invokeAPI(.get, id)
    }
    
    func post(_ data: JSONCodable? = nil) -> Promise<Response>? {
        self.reqBody = data
        return self._invokeAPI(.post)
    }
    
    func delete() -> Promise<Response>? {
        return self._invokeAPI(.delete)
    }
    
    func put(id: String? = nil, _ data: JSONCodable? = nil) -> Promise<Response>? {
        self.reqBody = data
        return self._invokeAPI(.put, id)
    }
    
    func _createURL() {
        var url: String = self._unformattedURL
        let finalArgMap = self.willCreateURL(from: self.argMap)
        
        // Now Replacing Url with dynamic key present on url
        for (key,val) in finalArgMap {
            url = url.replacingOccurrences(of: key, with: val)
        }
        var options: String = ""
        for option in urlOptions {
            guard let value: String = finalArgMap[option] else {
                continue
            }
            let subOption: String = (option.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? option) + "=" + (value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? value)
            options = options + subOption + "&"
        }
        options = String(options.dropLast())
        // Now check url already have options or not
        if let _ = url.firstIndex(of: "?") {
            url = url + "&\(options)"
        } else {
            url = url + "?\(options)"
        }
        
        self._url = url
    }
    
    func willCreateURL(from argument: [String : String]) -> [String : String] {
        return argument
    }
    
    
}


extension RemoteAPI where R == Data {
    func processData(data: Data, more: Any?) -> (Data?, Any?) {
        return (data, more)
    }
}

class RemoteCodableAPI<R: Codable>: RemoteAPI<R> {
    override func processData(data: Data, more: Any?) -> (R?, Any?) {
        do {
            let decoder = JSONDecoder()
            let decodedStore: R = try decoder.decode(R.self, from: data)
            return (decodedStore, more)
        } catch let excp {
            InfoLog("JSON Parsing Fail")
            InfoLog("Reason: \(excp)")
            InfoLog("Des: \(excp.localizedDescription): \((excp as NSError).code)")
            return (nil, more)
        }
    }
}





extension RemoteAPI: CustomStringConvertible {
    var description: String {
        return _url
    }
    
}

extension RemoteAPI: URLConvertible {
    public func asURL() throws -> URL {
        guard let url = URL(string: self._url) else { throw AFError.invalidURL(url: self.description) }
        return url
    }
}



