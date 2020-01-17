//
//  RealTimeControllerTests.swift
//  RealTimeControllerTests
//
//  Created by Jose Alvarez on 12/26/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest

import RealTimeController
import SignalRSwift
import DEUCE_Framework

protocol RealTimeProxy {
}

protocol RealTimeConnection {
    func start()
    func stop()
    var started: (() -> Void)? { set get }
    var error: ((Error) -> Void)? { set get }
    var connectionSlow: (() -> Void)? { set get }
}

final class SignalRClient: RealTimeClient  {
    let proxy: RealTimeProxy
    var connection: RealTimeConnection
    
    enum Error: Swift.Error {
        case clientError
    }
    
    init(proxy: RealTimeProxy, connection: RealTimeConnection) {
        self.proxy = proxy
        self.connection = connection
    }
    
    func connectTo(url: URL, result: @escaping (RealTimeClientResult) -> Void) {
        connection.started = {
            result(.connected)
        }
        
        connection.error = { (error) in
            result(.failed(Error.clientError))
        }
        
        connection.connectionSlow = {
            result(.slow)
        }

        connection.start()
    }
    
    func stop() {
        connection.stop()
    }
}

class RealTimeControllerTests: XCTestCase {
    func test_onInit_doesNotConnect() {
        let spy = RealTimeSpy()
        _ = SignalRClient(proxy: spy, connection: spy)
        
        XCTAssertEqual(spy.connectionRequests, 0)
    }
    
    func test_onConnect_startsConnections() {
        let spy = RealTimeSpy()
        let sut = SignalRClient(proxy: spy, connection: spy)
        
        sut.connectTo(url: URL(string: "www.google.com")!) { _ in }
        
        XCTAssertEqual(spy.connectionRequests, 1)
    }
    
    func test_onConnect_ReturnsErrorOnClientError() {
        let spy = RealTimeSpy()
        let realTimeClient = SignalRClient(proxy: spy, connection: spy)
                
        var capturedResult: RealTimeClientResult?
        
        let exp = expectation(description: "Waiting to connect")
        
        realTimeClient.connectTo(url: URL(string: "www.google.com")!) { (result) in
            capturedResult = result
            
            exp.fulfill()
        }
        
        let error = NSError(domain: "any-Error", code: 0)
        spy.connectWith(error: error)
        
        wait(for: [exp], timeout: 10.0)
        
        if let capturedResult = capturedResult, case RealTimeClientResult.failed(let error) = capturedResult {
            XCTAssertEqual(error as! SignalRClient.Error, SignalRClient.Error.clientError)
        } else {
            XCTFail("Expected \(SignalRClient.Error.clientError), got \(String(describing: capturedResult)) instead")
        }
    }
    
    func test_onConnect_ReturnsConnectedResultWhenConnectionSuccessful() {
        let spy = RealTimeSpy()
        let realTimeClient = SignalRClient(proxy: spy, connection: spy)
                
        var capturedResult: RealTimeClientResult?
        
        let exp = expectation(description: "Waiting to connect")
        
        realTimeClient.connectTo(url: URL(string: "www.google.com")!) { (result) in
            capturedResult = result
            
            exp.fulfill()
        }
        
        spy.successfullyConnect()
        
        wait(for: [exp], timeout: 10.0)
        
        XCTAssertEqual(capturedResult, RealTimeClientResult.connected)
    }
    
    func test_onStop_stopsTheConnection() {
        let spy = RealTimeSpy()
        let realTimeClient = SignalRClient(proxy: spy, connection: spy)
        
        realTimeClient.stop()
        
        XCTAssertTrue(spy.calledStopConnection)
    }
    
    func test_onSlowConnection_returnsSlowConnectionResult() {
        let spy = RealTimeSpy()
        let realTimeClient = SignalRClient(proxy: spy, connection: spy)
                
        var capturedResults = [RealTimeClientResult]()
        
        let exp = expectation(description: "Waiting to connect")
        exp.expectedFulfillmentCount = 2
        
        realTimeClient.connectTo(url: URL(string: "www.google.com")!) { (result) in
            capturedResults.append(result)
            
            exp.fulfill()
        }
        
        spy.successfullyConnect()
        spy.simulateSlowConnection()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedResults, [RealTimeClientResult.connected, RealTimeClientResult.slow])
    }
    
    private func makeSUT() -> (connection: RealTimeConnection, proxy: RealTimeProxy, sut: SignalRClient) {
//        let connection = HubConnection(withUrl: "http://172.17.147.90")
//        connection.addValue(value: "Bearer Xm2mk0_R_0b5DYr95Mgo0AtH0-6yed8NgXHPFRtMYfy4wEKtdq8cjy69j6-pQjVKtU5tMGTIcbd0AMQqr4xEvcHuRUNs6HrFS6HW9FJLb6DsjrKV7ycjhTysRRua5sUYVAfO5y-sDAF_cr83HSNZ-Rt2VvStydXQkwIwYpuNanMfKAmmvEDSgirErPaz9fmwUAZiOzMRXHuoF57XgQ_it3PUFvArvM9gNzVfPg5FYEJ0XzY2x1MnbT_uIskhppjNN5kEkf--1ntCWjvlhBwL3jbl57dBz2Y0ZmLgrWFWLr2B9S2XCbIMV7CZZCLo2B5CuQmJyUBUm3pA9Q3vfbiRXeCjCAbq3AUcfQCmF4r_FsKHhEGQluZRe4UxGOdOCKpLmADLoGrNN-wlFOP44-Jp3gf8l5meFa-wLrYgNA1VB0X-RAl0oz4PdrBKvMjjonq9bjgJXJoZE4FmoSWNvdHv5jIVWiSMN6Aws6h6fP8h5hCKob1mhN3vYEhJ3J4zqR9nMqRasID0yTEZ4ajCT1tFog", forHttpHeaderField: "Authorization")
//        let proxy = connection.createHubProxy(hubName: "chathub")!
//        let realTimeClient = SignalRClient(proxy: proxy, connection: connection)
//
//        return (connection, proxy, realTimeClient)
        
        let spy = RealTimeSpy()
        let realTimeClient = SignalRClient(proxy: spy, connection: spy)

        return (spy, spy, realTimeClient)
    }
}

class RealTimeSpy: RealTimeProxy, RealTimeConnection {
    private(set) var connectionRequests = 0
    private(set) var calledStopConnection = false
    
    // MARK: - RealTimeConnection
    
    var started: (() -> Void)?
    var error: ((Error) -> Void)?
    var connectionSlow: (() -> Void)?

    func start() {
        connectionRequests += 1
    }
    
    func stop() {
        calledStopConnection = true
    }
    
    
    func successfullyConnect() {
        started?()
    }
    
    func connectWith(error: Error) {
        self.error?(error)
    }
    
    func simulateSlowConnection() {
        connectionSlow?()
    }
}


extension RealTimeClientResult: Equatable {
    public static func == (lhs: RealTimeClientResult, rhs: RealTimeClientResult) -> Bool {
        switch (lhs, rhs) {
        case (.connected, .connected):
            return true
        case (.slow, .slow):
            return true
        default:
            return false
        }
    }
}

extension HubProxy: RealTimeProxy {}

extension HubConnection: RealTimeConnection {}
