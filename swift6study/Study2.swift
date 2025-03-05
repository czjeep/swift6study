//
//  Study2.swift
//  swift6study
//
//  Created by weitu on 2025/3/5.
//

import UIKit

class Study2: NSObject {
    
    struct Message: Decodable, Identifiable {
        let id: Int
        let from: String
        let message: String
    }

    func fetchMessages(completion: @Sendable @escaping ([Message]) -> Void) {
        let url = URL(string: "https://hws.dev/user-messages.json")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data {
                if let messages = try? JSONDecoder().decode([Message].self, from: data) {
                    completion(messages)
                    return
                }
            }

            completion([])
        }.resume()
    }

    //must and only once。add the runtime cost of checking you’ve used the continuation correctly.
    func fetchMessages() async -> [Message] {
        await withCheckedContinuation { continuation in
            fetchMessages { messages in
                continuation.resume(returning: messages)
            }
        }
    }
    
    //must and only once。
    func fetchMessages2() async -> [Message] {
        await withUnsafeContinuation { continuation in
            fetchMessages { messages in
                continuation.resume(returning: messages)
            }
        }
    }
    
    func doAsyncWork() async {
        print("Doing async work")
    }

    func doRegularWork() {
        Task {
            await self.doAsyncWork()
        }
    }
    
    func doRegularWork2() async {
        await doAsyncWork()
    }

    func test() {
        
    }
}

extension Study2 {
    
    static func test() async {
        var obj: Study2?
        let messages = await obj?.fetchMessages()
    }
}
