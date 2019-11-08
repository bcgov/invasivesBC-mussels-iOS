//
//  ApplicationErrorConst.swift
//  FoodAnytime
//
//  Created by Pushan Mitra on 21/09/18.
//  Copyright © 2018 Pushan Mitra. All rights reserved.
//

import Foundation


func AppError(code: Int = ApplicationErrorGeneric,description: String, userInfo: [String: Any]? = nil) -> Error {
    var newInfo: [String : Any] = userInfo ?? [String:Any]()
    newInfo[NSLocalizedDescriptionKey] = description
    newInfo[ApplicationErrorInfoMessageKey] = description
    let error = NSError(domain: ApplicationDomain, code: code, userInfo: newInfo)
    return (error as Error)
}

let ApplicationErrorGeneric: Int = 1000
let AppErrorNetworkDataError: Int = 1001
let ApplicationJSONParsingError: Int = 1002
let ApplicationNoLocationError: Int = 2001
let ApplicationNoLocationInfoError: Int = 2002
let ApplicationEmptyResponseError = 1003
let ApplicationCloudError = 1004
let ApplicationInvalidURLError: Int = 1010

let AppUserAlereadyConfirmed: String = "User is already confirmed."
let AppInfoNotAvailable: String = "N.A."
let ApplicationItemCloudPublicPathError = "Unable to create item cloud public path"
let RemoteAPIInvalidURLMessage: String = StrProcessing("Not able to connect invalid #url, please check with system admin")
let ApplicationJSONParsingErrorMessage: String = StrProcessing("Unable to parse server response")
let RemoteAPIDataErrorMessage: String = "API data error"
