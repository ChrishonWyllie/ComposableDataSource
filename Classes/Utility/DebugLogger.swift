//
//  DebugLogger.swift
//  Celestial
//
//  Created by Chrishon Wyllie on 7/17/20.
//

import Foundation

internal class DebugLogger {
    
    public static let shared = DebugLogger()
    private var debugMessages: [String] = []
    private var withNsLog = true
    
    private let serialQueue = DispatchQueue(label: "com.chrishonwyllie.ComposableDataSource.DebugLogger")

    
    
    private init(withNsLog: Bool = true) {
        self.withNsLog = withNsLog
        clear()
    }
    
    let eyebrowRaisers: [String] = ["fail", "failed", "error"]
    
    public func addDebugMessage(_ message: String) {
        guard ComposableCollectionDataSource.debugModeIsActive == true else {
            return
        }
        
        for keyword in eyebrowRaisers {
            if message.lowercased().contains(keyword.lowercased()) {
                fatalError("\n\(String(describing: type(of: self))) ----- \(message)\n")
            }
        }
        
        if withNsLog {
            #if DEBUG
            NSLog("\n\(message)\n")
            #endif
        }
        serialQueue.sync {
            self.debugMessages.append(message)
        }
        
    }
    
    public func getAllMessages() -> [String] {
        return debugMessages
    }
    
    public func clear() {
        debugMessages.removeAll()
    }
}
