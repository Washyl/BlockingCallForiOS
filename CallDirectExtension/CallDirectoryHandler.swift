//
//  CallDirectoryHandler.swift
//  CallDirectExtension
//
//  Created by Washyl on 7/14/24.
//
import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {
    
    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        if context.isIncremental {
            addOrRemoveIncrementalBlockingPhoneNumbers(to: context)
        } else {
            addAllBlockingPhoneNumbers(to: context)
        }
        
        context.completeRequest()
    }
    
    private func addAllBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        let defaults = UserDefaults(suiteName: "Washyl.CallBlock")
        let blockedNumbers = defaults?.array(forKey: "blockedNumbers") as? [Int64] ?? []
        
        for phoneNumber in blockedNumbers {
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
        }
    }
    
    private func addOrRemoveIncrementalBlockingPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Implement incremental updates if needed
    }
    
    private func addOrRemoveIncrementalIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Placeholder for phone number identification
    }
    
    private func addAllIdentificationPhoneNumbers(to context: CXCallDirectoryExtensionContext) {
        // Placeholder for phone number identification
    }
}
