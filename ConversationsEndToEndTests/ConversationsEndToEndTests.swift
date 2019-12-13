//
//  ConversationsEndToEndTests.swift
//  ConversationsEndToEndTests
//
//  Created by Jose Alvarez on 8/19/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework

class ConversationsEndToEndTests: XCTestCase {

    func test_endToEndTestServerGetFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 2, "Expected 2 items in the test account")

            items.forEach { (item) in
//                XCTAssertEqual(items, expectedItem(at: index), "Unexpected item values at index \(index)")
            }
        default:
            XCTFail("Expected successful result, got no result instead")
        }
    }

    // MARK: - Helpers

    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> LoadConversationsResult? {
        let testServerURL = URL(string: "http://desktop-l87s12t:54368/api/ConversationStatus/Latest")!
        let client = URLSessionHTTPClient()
        client.addAdditionalHeaders(headers: authorizationHeader())
        let loader = RemoteConversationsLoader(url: testServerURL, client: client)

        trackForMemoryLeaks(object: client, file: file, line:  line)
        trackForMemoryLeaks(object: loader, file: file, line:  line)
        let exp = expectation(description: "Wait for load completion")

        var receivedResult: LoadConversationsResult?
        loader.load { (result) in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 15.0)

        return receivedResult
    }
//    private func expectedItem(at index: Int) -> Conversation {
//        return Conversation(id: id(at: index), image: imageUrl(at: index), message: <#T##String?#>, lastMessageUser: <#T##String?#>, lastMessageTime: <#T##Date?#>, conversationType: <#T##Int#>, groupName: <#T##String?#>, contentType: <#T##Int#>)
//    }

    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "",
            "",
            ""][index])!
    }

    private func authorizationHeader() -> [String: String] {
        return ["Authorization": "Bearer c_RpqNMTBIgJQQJxcWheGE3xGrb89CwCjpf0XZg0tAPnZnJOV0M37pH8xmu7fBp4Q6q0_Z4ta2Dzc2Vs74O3uR_AmQ8t62cMfCM7zSuZKP-YFqXuDkKWkLnzUTBo749m1JY2o7I2LbCKjm_E6AYNMougBrhyhTbBR5Q14Abj9lohRcy4zKlww-qHjADoV2nuIMATpJO0BCX_vEFSVbj4LxXXY7EkPsrH4rcQqZqS7nztVesSdx87YRDpxgv7-bnzwnkNBmfi2lVXUAEy0HC7cSRxdtx-bOwJw7i0fdHs4Dam7R4S20D5jrkDxllWomgQIIPF3tpRJAY6M6VsuHxwE41-snhuuxZXRZqbQfjkkiBX7-0BvVIJvNl5G21c42K9A42gc--HNmUTDF_FmdqX_6jSj0YKBFLcMTQiuqyzuIu7zj4e_mV9aOkfKC6XdJOTOTHDozzc0Z8iqNHkpl2Ga6G5n2hb26fJzsW1rnOmlkb-Hh1knON8k29PpT2CdaUbXyLKL0AAIGwvoCUN5j7i8ghOrsFpOF8A_dBus45YvMw", "Content-Type": "application/json"]
    }
}
