//
//  PathPaymentResultXDR.swift
//  stellarsdk
//
//  Created by Razvan Chelemen on 14/02/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public enum PathPaymentResultCode: Int {
    case success = 0
    case malformed = -1
    case underfounded = -2
    case srcNoTrust = -3
    case srcNotAuthorized = -4
    case noDestination = -5
    case noTrust = -6
    case notAuthorized = -7
    case lineFull = -8
    case noIssuer = -9
    case tooFewOffers = -10
    case offerCrossSelf = -11
    case overSendMax = -12
}

enum PathPaymentResultXDR: XDRCodable {
    case success(Int, [ClaimOfferAtomXDR], SimplePaymentResultXDR)
    case noIssuer(Int, AssetXDR)
    case empty (Int)
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let code = PathPaymentResultCode(rawValue: try container.decode(Int.self))!
        
        switch code {
            case .success:
                let offers = try container.decode([ClaimOfferAtomXDR].self)
                let last = try container.decode(SimplePaymentResultXDR.self)
                self = .success(code.rawValue, offers, last)
            case .noIssuer:
                self = .noIssuer(code.rawValue, try container.decode(AssetXDR.self))
            default:
                self = .empty (code.rawValue)
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        switch self {
            case .success(let code, let offers, let last):
                try container.encode(code)
                try container.encode(offers)
                try container.encode(last)
            case .noIssuer(let code, let asset):
                try container.encode(code)
                try container.encode(asset)
            case .empty:
                break
        }
    }
}