//
//  STPPaymentMethodCashAppParams.swift
//  StripePayments
//
//  Created by Nick Porter on 12/12/22.
//  Copyright © 2022 Stripe, Inc. All rights reserved.
//

import Foundation

/// An object representing parameters used to create a CashApp Payment Method
/// - Note: Cash App Pay is currently in beta therefore the interface of this class is subject to change.
public class STPPaymentMethodCashAppParams: NSObject, STPFormEncodable {
    @objc public var additionalAPIParameters: [AnyHashable: Any] = [:]

    @objc
    public static func rootObjectName() -> String? {
        return "cashapp"
    }

    @objc
    public static func propertyNamesToFormFieldNamesMapping() -> [String: String] {
        return [:]
    }
}
