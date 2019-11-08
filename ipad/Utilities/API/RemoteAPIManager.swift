//
//  RemoteAPIManager.swift
//  FoodAnytime
//
//  Created by Pushan Mitra on 21/09/18.
//  Copyright © 2018 Pushan Mitra. All rights reserved.
//

import Foundation
import Alamofire

typealias RequestHeader = HTTPHeaders
typealias BodyParameters = Parameters


typealias NetworkDecodeStatus = (status: Bool, data: Data?, error: Error?)

class RemoteAPIManager {
    let queue: DispatchQueue = DispatchQueue(label: (AppFullName + "-Network"))
    static let `default` : RemoteAPIManager = {
        return RemoteAPIManager()
    }()
    
    typealias Callback = (_ error: Error?,_ info: Data) -> Void
    
    
    private func _handleResp(_ response: DataResponse<Data>,_ url: String = "",_ callback: Callback) {
        switch response.result {
        case .success:
            InfoLog("[COMPLETE - \(url)]")
            if let data: Data =  response.result.value {
                InfoLog("[SUCCESS]")
                InfoLog("[VALUE] : \n \(data.string)")
                callback(nil, data)
            } else {
                InfoLog("[FAIL] - NO DATA RECEIVED")
                let error: Error = AppError(code: AppErrorNetworkDataError, description: RemoteAPIDataErrorMessage)
                callback(error, "".data)
            }
            
        case .failure(let error):
            ErrorLog("[ERROR = \(url)]")
            ErrorLog("Error: \(error)")
            callback(error, "".data)
            
        }
    }
    
    func get(_ url: String,_ headers: RequestHeader = [:]) -> Promise<Data> {
        return Promise({ (resolve, reject) in
            Alamofire.request(url, method: .get, headers: headers)
                .log()
                .responseData(completionHandler: { (response) in
                self._handleResp(response, url, { (error, info) in
                    if let e: Error = error {
                        reject(e, nil)
                    } else {
                        resolve(info, nil)
                    }
                })
            })
        })
    }
    
    func post(_ url: String,parameters: BodyParameters,_ headers: RequestHeader = [:]) -> Promise<Data> {
        return Promise<Data>({ (resolve, reject) in
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .log()
                .responseData(completionHandler: { (response) in
                self._handleResp(response, url, { (error, info) in
                    if let e: Error = error {
                        reject(e, nil)
                    } else {
                        resolve(info, nil)
                    }
                })
            })
        })
    }
    
    func post(_ url: String,body: Data,_ headers: RequestHeader = [:]) -> Promise<Data> {
        return Promise<Data>({ (resolve, reject) in
            Alamofire.request(url, method: .post, parameters: [:], encoding: body, headers: headers)
                .log()
                .responseData(completionHandler: { (response) in
                self._handleResp(response, url, { (error, info) in
                    if let e: Error = error {
                        reject(e, nil)
                    } else {
                        resolve(info, nil)
                    }
                })
            })
        })
    }
    
    
    func api(_ url: String,body: Data,method: APIMethod,_ headers: RequestHeader = [:]) -> Promise<Data> {
        return Promise<Data>({ (resolve, reject) in
            Alamofire.request(url, method: method, parameters: [:], encoding: body, headers: headers)
                .log()
                .responseData(completionHandler: { (response) in
                    self._handleResp(response, url, { (error, info) in
                        if let e: Error = error {
                            reject(e, nil)
                        } else {
                            resolve(info, nil)
                        }
                    })
                })
        })
    }
    
    func api(_ url: String,method: APIMethod,parameters: BodyParameters,_ headers: RequestHeader = [:]) -> Promise<Data> {
        return Promise<Data>({ (resolve, reject) in
            Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .log()
                .responseData(completionHandler: { (response) in
                    self._handleResp(response, url, { (error, info) in
                        if let e: Error = error {
                            reject(e, nil)
                        } else {
                            resolve(info, nil)
                        }
                    })
                })
        })
    }
    
    func put(_ url: String,body: Data,_ headers: RequestHeader = [:]) -> Promise<Data> {
        return Promise<Data>({ (resolve, reject) in
            Alamofire.request(url, method: .put, parameters: [:], encoding: body, headers: headers)
                .log()
                .responseData(completionHandler: { (response) in
                    self._handleResp(response, url, { (error, info) in
                        if let e: Error = error {
                            reject(e, nil)
                        } else {
                            resolve(info, nil)
                        }
                    })
                })
        })
    }
    
    func put(_ url: String,parameters: BodyParameters,_ headers: RequestHeader = [:]) -> Promise<Data> {
        return Promise<Data>({ (resolve, reject) in
            Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .log()
                .responseData(completionHandler: { (response) in
                    self._handleResp(response, url, { (error, info) in
                        if let e: Error = error {
                            reject(e, nil)
                        } else {
                            resolve(info, nil)
                        }
                    })
                })
        })
    }
    
    
}


extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

extension Data: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = self
        return request
    }
}

extension Request {
    public func log() -> Self {
        #if DEBUG
        InfoLog("=============== Request =====================")
        debugPrint(self)
        InfoLog("=============== Request =====================")
        #endif
        return self
    }
}
