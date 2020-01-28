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

extension HubConnection: RealTimeAzureConnection {}

protocol RealTimeAzureConnection {
    func start()
    func stop()
    var started: (() -> Void)? { set get }
    var error: ((Error) -> Void)? { set get }
    var connectionSlow: (() -> Void)? { set get }
    var closed: (() -> Void)? { set get }
}

final class SignalRClient: RealTimeConnection  {
    var connection: RealTimeAzureConnection
    
    enum Error: Swift.Error {
        case clientError
    }
    
    init(connection: RealTimeAzureConnection) {
        self.connection = connection
    }
    
 
    func start(status: @escaping (RealTimeConnectionStatus) -> Void) {
        connection.started = {
            status(.connected)
        }
        
        connection.error = { (error) in
            status(.failed(Error.clientError))
        }
        
        connection.connectionSlow = {
            status(.slow)
        }
        
        connection.closed = {
            status(.disconnected)
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
        _ = SignalRClient(connection: spy)
        
        XCTAssertEqual(spy.connectionRequests, 0)
    }
    
    func test_onConnect_startsConnections() {
        let spy = RealTimeSpy()
        let sut = SignalRClient(connection: spy)
        
        sut.start() { _ in }
        
        XCTAssertEqual(spy.connectionRequests, 1)
    }
    
    func test_onConnect_ReturnsErrorOnClientError() {
        let spy = RealTimeSpy()
        let realTimeClient = SignalRClient(connection: spy)
                
        expect(sut: realTimeClient, toCompleteWith: [.failed(SignalRClient.Error.clientError)]) {
            let error = NSError(domain: "any-Error", code: 0)
            spy.connectWith(error: error)
        }
    }
    
    func test_onConnect_ReturnsConnectedResultWhenConnectionSuccessful() {
        let spy = RealTimeSpy()
        let realTimeClient = SignalRClient(connection: spy)
        
        expect(sut: realTimeClient, toCompleteWith: [.connected]) {
            spy.successfullyConnect()
        }
    }
    
    func test_onStop_stopsTheConnection() {
        let spy = RealTimeSpy()
        let realTimeClient = SignalRClient(connection: spy)
        
        realTimeClient.stop()
        
        XCTAssertTrue(spy.calledStopConnection)
    }
    
    func test_onDisconnected_returnsConnectionDisconnected() {
        let spy = RealTimeSpy()
        let realTimeClient = SignalRClient(connection: spy)
        
        expect(sut: realTimeClient, toCompleteWith: [.connected, .disconnected]) {
            spy.successfullyConnect()
            spy.simulateDisconnected()
        }
    }

    
    func test_onSlowConnection_returnsSlowConnectionResult() {
        let spy = RealTimeSpy()
        let realTimeClient = SignalRClient(connection: spy)
                
        expect(sut: realTimeClient, toCompleteWith: [.connected, .slow]) {
            spy.successfullyConnect()
            spy.simulateSlowConnection()
        }
    }
    
    private func makeSUT() -> (azureConnection: RealTimeAzureConnection, sut: SignalRClient) {
//        let connection = HubConnection(withUrl: "http://172.17.147.90")
//        connection.addValue(value: "Bearer Xm2mk0_R_0b5DYr95Mgo0AtH0-6yed8NgXHPFRtMYfy4wEKtdq8cjy69j6-pQjVKtU5tMGTIcbd0AMQqr4xEvcHuRUNs6HrFS6HW9FJLb6DsjrKV7ycjhTysRRua5sUYVAfO5y-sDAF_cr83HSNZ-Rt2VvStydXQkwIwYpuNanMfKAmmvEDSgirErPaz9fmwUAZiOzMRXHuoF57XgQ_it3PUFvArvM9gNzVfPg5FYEJ0XzY2x1MnbT_uIskhppjNN5kEkf--1ntCWjvlhBwL3jbl57dBz2Y0ZmLgrWFWLr2B9S2XCbIMV7CZZCLo2B5CuQmJyUBUm3pA9Q3vfbiRXeCjCAbq3AUcfQCmF4r_FsKHhEGQluZRe4UxGOdOCKpLmADLoGrNN-wlFOP44-Jp3gf8l5meFa-wLrYgNA1VB0X-RAl0oz4PdrBKvMjjonq9bjgJXJoZE4FmoSWNvdHv5jIVWiSMN6Aws6h6fP8h5hCKob1mhN3vYEhJ3J4zqR9nMqRasID0yTEZ4ajCT1tFog", forHttpHeaderField: "Authorization")
//        let proxy = connection.createHubProxy(hubName: "chathub")!
//        let realTimeClient = SignalRClient(proxy: proxy, connection: connection)
//
//        return (connection, proxy, realTimeClient)
        
        let spy = RealTimeSpy()
        let realTimeClient = SignalRClient(connection: spy)

        return (spy, realTimeClient)
    }
    
    private func expect(sut: SignalRClient, toCompleteWith expectedResults: [RealTimeConnectionStatus], file: StaticString = #file, line: UInt = #line, when action: () -> ()) {
        let exp = expectation(description: "Waiting to connect")
        exp.expectedFulfillmentCount = expectedResults.count
        
        var capturedResults = [RealTimeConnectionStatus]()

        sut.start() { (result) in
            exp.fulfill()
            capturedResults.append(result)
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(capturedResults, expectedResults, file: file, line: line)
    }
}

class RealTimeSpy: RealTimeAzureConnection {
    private(set) var connectionRequests = 0
    private(set) var calledStopConnection = false
    
    // MARK: - RealTimeConnection
    
    var started: (() -> Void)?
    var error: ((Error) -> Void)?
    var connectionSlow: (() -> Void)?
    var closed: (() -> Void)?

    func start() {
        connectionRequests += 1
    }
    
    func stop() {
        calledStopConnection = true
    }
    
    
    func successfullyConnect() {
        started?()
    }
    
    func simulateDisconnected() {
        closed?()
    }
    
    func connectWith(error: Error) {
        self.error?(error)
    }
    
    func simulateSlowConnection() {
        connectionSlow?()
    }
}


extension RealTimeConnectionStatus: Equatable {
    public static func == (lhs: RealTimeConnectionStatus, rhs: RealTimeConnectionStatus) -> Bool {
        switch (lhs, rhs) {
        case (.connected, .connected):
            return true
        case (.slow, .slow):
            return true
        case (.disconnected, .disconnected):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
