//
//  Promise.swift
//  FoodAnytime
//
//  Created by Pushan Mitra on 21/09/18.
//  Copyright © 2018 Pushan Mitra. All rights reserved.
//

import Foundation

public typealias ErrorAction = (_ error: Error,_ info: Any?) -> Void



public class Promise <T> {
    public typealias PromiseAction = (_ info: T,_ moreInfo: Any?) -> Void
    public typealias PromiseCallback = (_ resolve: @escaping PromiseAction, _ reject:@escaping ErrorAction) -> Void
    private var _actions: [PromiseAction] = [PromiseAction]()
    private var _errorHandlers: [ErrorAction] = [ErrorAction]()
    public var queue: DispatchQueue = DispatchQueue.main
    
    public func clear() {
        _actions = [PromiseAction]()
        _errorHandlers = [ErrorAction]()
    }
    
    deinit {
        clear()
    }
    
    var _resolve: PromiseAction = {(_,_) in }
    var _reject: ErrorAction = {(_,_) in }
    
    func __resolve(_ info: T,_ moreInfo: Any?) {
        queue.async {
            for action in self._actions {
                action(info, moreInfo)
            }
            
            self.queue.async {
                self.clear()
            }
        }
    }
    func __reject(_ error: Error, info: Any?) {
        queue.async {
            for action in self._errorHandlers {
                action(error, info)
            }
            
            self.queue.async {
                self.clear()
            }
        }
    }
    
    public func then(_ action: @escaping PromiseAction) {
        self._actions.append(action)
    }
    
    public func error(_ action: @escaping ErrorAction) {
        self._errorHandlers.append(action)
    }
    
    func set() {
        _reject = {[weak self](_ error: Error,_ info: Any?) in
            self?.__reject(error, info: info)
        }
        _resolve = {[weak self] (_ info: T,_ moreInfo: Any?) in
            self?.__resolve(info, moreInfo)
        }
    }
    
    init(_ callback: PromiseCallback) {
        
        self.set()
        callback(self._resolve, self._reject)
    }
    
    
}

public class DeferredPromise<T, Data> : Promise<T> {
    public typealias DeferredThunk = (_ info:Data?, _ resolve: @escaping PromiseAction, _ reject:@escaping ErrorAction) -> Void
    internal var action: DeferredThunk?
    
    public init(_ thunk:@escaping DeferredThunk) {
        super.init { (_, _) in
            
        }
        self.set()
        action = thunk
    }
    
    public func call(_ info: Data?) {
        action?(info,self._resolve, self._reject)
    }
    
    public override func clear() {
        super.clear()
        action = nil
    }
}

public class DeferredPromises: ExpressibleByArrayLiteral {
    
    public typealias PromiseType = DeferredPromise<Any?,Any?>
    internal var promises: [PromiseType] = [PromiseType]()
    var _resolve: Promise<Any?>.PromiseAction?
    var _reject: ErrorAction?
    var queue: DispatchQueue = DispatchQueue.main
    
    public required init(arrayLiteral: PromiseType...) {
        for element in arrayLiteral {
            self.promises.append(element)
        }
    }
    
    public func start(_ data: Any?) -> Promise<Any?> {
        let promise: Promise<Any?> = Promise { (resolve, _) in
            self._resolve = resolve
            self.queue.async {
                self.exec(data)
            }
        }
        return promise
    }
    
    func callNext(_ data: Any?) {
        self.promises.remove(at: 0)
        self.exec(data)
    }
    
    func exec(_ data: Any?) {
        if promises.count > 0 {
            let promise: PromiseType = self.promises[0]
            promise.then {[weak self] (data, _) in
                self?.callNext(data)
            }
            promise.error {[weak self] (data, _) in
                self?.callNext(data)
            }
            queue.async {
                promise.call(data)
            }
            
        } else {
            self._resolve?(nil, nil)
        }
    }
    
}


