//
//  AppDelegate.swift
//  DEUCEApp
//
//  Created by Jose Alvarez on 12/13/19.
//  Copyright © 2019 DEUCE. All rights reserved.
//

import UIKit
import DEUCE_Framework
import DEUCEiOS

class MockRealtimeClient: RealTimeConnection {
    private var status: ((RealTimeConnectionStatus) -> Void)!
    
    func start(status: @escaping (RealTimeConnectionStatus) -> Void) {
        self.status = status
        
        self.status(.connected)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            self.sendNewMessage()
//        }
    }
    
    func stop() {
    }
    
    private func sendNewMessage() {
//        let message: [String: Any] = [
//            "Id": "f9d90452-202e-11ea-a5e8-2e728ce88125",
//            "ConversationId": "0004a106-202f-11ea-978f-2e728ce88125",
//            "ConversationType": 0,
//            "ContentType": 0,
//            "CreatedByUserName": "Liliana",
//            "LastMessage": "updated message?",
//            "OtherUserName": "Otro user",
//            "GroupName": "Power Ranger",
//            "LastMessageTimeStamp": "2019-12-17T02:13:54.0000000"
//        ]
//
//        self.status(.newMessage(message))
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        client.addAdditionalHeaders(headers: ["Content-Type": "application/json", "Authorization": "bearer cUQDqfHosx3t74qCf5xCYCqIVSEh4IeQFuliE9a_uBVOCLZlpk2f3lFLL2ym2dnt7-PFvbYtSO_IwvoF8HmSZRaTZBtTmGz04FGacLekyiGX5TN9Gf02MrujkCeb1iT4vsuQozPesE5Zcg7vZpudT5GoEEwRXnbNals7EH4LMYxT03ORIE8dh1YfREDCbQw9dq2KYm_6hqiegDZGNy7WmYWgwzIx5DhsnW5pfDEtI68pG1zC7ue_qIcmcdjx8RisYSjNaHhX5nZnEjSUPzfdpPPu7CUprwACjB76yAFvg0QEgLRGl0WOGqrEl4Q6Tj5WXhZgMX-ezNp5C0bkiFCYM08G_OVXM1IN0s8Rl1yrUVfE6on8d3-8TsPVQYzJ859_-9u7jPBMTaMDf_O_VyUBu6sv1DdJ-15eJ9a3H1Z3-3t_wHECbMZ-mHBGu-uaJSd0e_s8OXEDMq5fsQoLyZe4x6X8PWJOUPzoZ_cp5cwR67tqPIhQbjTejQ290zfkm7KZD_x4V7mAt2HWRXEeGP9_cQ"])
        //        let url = URL(string: "https://private-cc34f7-deuce2.apiary-mock.com/conversations")!
        let url = URL(string: "http://172.17.147.90/api/ConversationStatus/Latest")!
        
        let conversationsLoader = RemoteConversationsLoader(url: url, client: client)
        let realTimeClient = MockRealtimeClient()
        let listener = RealTimeConnectionListener(connection: realTimeClient, url: url)
        let loaderAndListener = ConversationsLoaderAndRealtimeListener(remoteLoader: conversationsLoader, realtimeLoader: listener)
        let imageLoader = RemoteImageDataLoader(client: client)
        
        let viewController = ConversationsComposer.conversationsComposedWith(conversationsLoader: loaderAndListener, imageDataLoader: imageLoader)
        
        window?.rootViewController = viewController
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

