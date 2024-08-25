//
//  ExpirationPolicy.swift
//  
//
//  Created by Илья Аникин on 25.08.2024.
//

import Foundation

/// Expiration policy for notification.
public enum ExpirationPolicy {
    /// Notification is considered as non-expiring and requires user's action for dismissing.
    case never
    /// Notification is considered as expired after it's have been stayed on top
    /// of the stack for defined time interval.
    ///
    /// Expired notification will be auto-dissmissed.
    case timeout(RunLoop.SchedulerTimeType.Stride)
}
