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
//            await asyncWork()
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

func doAsyncWork() async {
    print("Doing async work")
}

func doRegularWork() {
    Task {
        await doAsyncWork()
    }
}

func asyncWork() async {}

func fetchData1() -> Int { 1 }

func fetchData2() -> Int { 2 }

func fetchData() -> String { "" }

//结构化并发（Structured Concurrency）
//
//使用 async let 创建子任务，必须在 await 之后获取结果。
//这些任务和父任务绑定，父任务结束时子任务也会自动取消。
func e1() async {
    async let data1 = fetchData1()
    async let data2 = fetchData2()
    let result = await (data1, data2)
    print("获取的数据: \(result)")
}

//非结构化并发（Unstructured Concurrency）
//
//使用 Task {} 创建独立的任务，生命周期独立于调用它的代码。
//适用于 需要在独立线程运行但不依赖于调用者生命周期的任务。
func e2() {
    Task {
        let result = await fetchData()
        print("异步获取数据: \(result)")
    }
}

//Task 的取消
//Swift 的 Task 支持取消 (Task.cancel())，可以在任务中手动检查 Task.isCancelled 来提前退出：
//如果外部调用 task.cancel()，任务会被终止。
func e3() {
    Task {
        for i in 1...5 {
            if Task.isCancelled {
                print("任务被取消")
                return
            }
            print("执行任务 \(i)")
            try await Task.sleep(nanoseconds: 1_000_000_000) // 模拟耗时操作
        }
    }
}

//Task.detached
//Task.detached 创建完全独立的任务，不受调用环境影响：
func e4() {
    Task.detached {
        let data = await fetchData()
        print("独立任务数据: \(data)")
    }
}

//Task 的返回值
//Task 也是 泛型类型，你可以通过 value 获取返回值：
func e5() async {
    let task = Task { () -> String in
        return await fetchData()
    }

    let result = await task.value
    print("获取的结果: \(result)")
}
