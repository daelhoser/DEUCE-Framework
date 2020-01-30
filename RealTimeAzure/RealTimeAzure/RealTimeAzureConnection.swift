//
//  RealTimeAzureConnection.swift
//  RealTimeController
//
//  Created by Jose Alvarez on 1/28/20.
//  Copyright © 2020 DEUCE. All rights reserved.
//

import Foundation
import SignalRSwift
import DEUCE_Framework

var hubConnection = HubConnection(withUrl: "http://172.17.147.90")

public class HubConnectionDecorator: RealTimeAzureConnection {
    public var started: (() -> Void)?
    
    public var error: ((Error) -> Void)?
    
    public var connectionSlow: (() -> Void)?
    
    public var closed: (() -> Void)?
    
    public init() {
        hubConnection.started = {
            print("SIELS")
            self.started?()
        }
        self.error = hubConnection.error
        self.connectionSlow = hubConnection.connectionSlow
        self.closed = hubConnection.closed
        
        hubConnection.addValue(value: "Bearer Xm2mk0_R_0b5DYr95Mgo0AtH0-6yed8NgXHPFRtMYfy4wEKtdq8cjy69j6-pQjVKtU5tMGTIcbd0AMQqr4xEvcHuRUNs6HrFS6HW9FJLb6DsjrKV7ycjhTysRRua5sUYVAfO5y-sDAF_cr83HSNZ-Rt2VvStydXQkwIwYpuNanMfKAmmvEDSgirErPaz9fmwUAZiOzMRXHuoF57XgQ_it3PUFvArvM9gNzVfPg5FYEJ0XzY2x1MnbT_uIskhppjNN5kEkf--1ntCWjvlhBwL3jbl57dBz2Y0ZmLgrWFWLr2B9S2XCbIMV7CZZCLo2B5CuQmJyUBUm3pA9Q3vfbiRXeCjCAbq3AUcfQCmF4r_FsKHhEGQluZRe4UxGOdOCKpLmADLoGrNN-wlFOP44-Jp3gf8l5meFa-wLrYgNA1VB0X-RAl0oz4PdrBKvMjjonq9bjgJXJoZE4FmoSWNvdHv5jIVWiSMN6Aws6h6fP8h5hCKob1mhN3vYEhJ3J4zqR9nMqRasID0yTEZ4ajCT1tFog", forHttpHeaderField: "Authorization")
        
        let proxy = hubConnection.createHubProxy(hubName: "chathub")
    }

    public func start() {
        hubConnection.start()
    }
    
    public func stop() {
        hubConnection.stop()
    }
}

public class HubProxyDecorator: ConversationsHub {
    private var hubProxy: HubProxy?
    
    public init() {
//        hubConnection.addValue(value: "Bearer Xm2mk0_R_0b5DYr95Mgo0AtH0-6yed8NgXHPFRtMYfy4wEKtdq8cjy69j6-pQjVKtU5tMGTIcbd0AMQqr4xEvcHuRUNs6HrFS6HW9FJLb6DsjrKV7ycjhTysRRua5sUYVAfO5y-sDAF_cr83HSNZ-Rt2VvStydXQkwIwYpuNanMfKAmmvEDSgirErPaz9fmwUAZiOzMRXHuoF57XgQ_it3PUFvArvM9gNzVfPg5FYEJ0XzY2x1MnbT_uIskhppjNN5kEkf--1ntCWjvlhBwL3jbl57dBz2Y0ZmLgrWFWLr2B9S2XCbIMV7CZZCLo2B5CuQmJyUBUm3pA9Q3vfbiRXeCjCAbq3AUcfQCmF4r_FsKHhEGQluZRe4UxGOdOCKpLmADLoGrNN-wlFOP44-Jp3gf8l5meFa-wLrYgNA1VB0X-RAl0oz4PdrBKvMjjonq9bjgJXJoZE4FmoSWNvdHv5jIVWiSMN6Aws6h6fP8h5hCKob1mhN3vYEhJ3J4zqR9nMqRasID0yTEZ4ajCT1tFog", forHttpHeaderField: "Authorization")

//        hubProxy = hubConnection.createHubProxy(hubName: "chathub")
    }
    
    public func onn(eventName: String, handler: @escaping ([Any]) -> Void) {
        _ = hubProxy?.on(eventName: eventName, handler: handler)
    }
}

public protocol RealTimeAzureConnection {
    func start()
    func stop()
    var started: (() -> Void)? { set get }
    var error: ((Error) -> Void)? { set get }
    var connectionSlow: (() -> Void)? { set get }
    var closed: (() -> Void)? { set get }
}
