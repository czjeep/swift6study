//
//  Study1.swift
//  swift6study
//
//  Created by weitu on 2025/3/4.
//

import UIKit

class Study1: NSObject {
    
    @available(*, deprecated, message:"Use the main actor version.")
    func myMethod() {
        // 避免重复，将原实现移到 myMethodOnMain 中
        // 不过因为我们从原先的非 Main Actor 环境里调用了 Main Actor 里的方法，会编译报错
//        MainActor.assertIsolated("This method is expected to be called in main thread!")
//        MainActor.assumeIsolated {
//            self.myMethodOnMain()
//        }
//
    }
    
    @MainActor func myMethodOnMain() {
        // ..其他被隔离在 MainActor 中的 UI 操作
    }
    
    func foo() {}
}

extension MainActor {
    
    static func runSafely<T>(_ block: @MainActor () -> T) throws -> T where T : Sendable {
        if Thread.isMainThread {
            return MainActor.assumeIsolated { block() }
        } else {
            MainActor.assertIsolated("This method is expected to be called in main thread!")
            return DispatchQueue.main.sync {
                MainActor.assumeIsolated { block() }
            }
        }
    }
}
