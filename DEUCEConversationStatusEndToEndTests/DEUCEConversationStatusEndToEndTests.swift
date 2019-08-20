//
//  DEUCEConversationStatusEndToEndTests.swift
//  DEUCEConversationStatusEndToEndTests
//
//  Created by Jose Alvarez on 8/19/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import XCTest
import DEUCE_Framework

class DEUCEConversationStatusEndToEndTests: XCTestCase {

    /*func test_endToEndTestServerGetFeedResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(items)?:
            XCTAssertEqual(items.count, 8, "Expected 8 items in the test account")

            items.forEach { (item) in
//                XCTAssertEqual(items, expectedItem(at: index), "Unexpected item values at index \(index)")
            }
        default:
            XCTFail("Expected successful result, got no result instead")
        }
    }*/

    // MARK: - Helpers

    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> LoadConversationResult? {
        //TODO: I need to switch to my url since i used my own model for DEUCE.
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteConversationsLoader(url: testServerURL, client: client)
        trackForMemoryLeaks(object: client, file: file, line:  line)
        trackForMemoryLeaks(object: loader, file: file, line:  line)
        let exp = expectation(description: "Wait for load completion")

        var receivedResult: LoadConversationResult?
        loader.load { (result) in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)

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
}
