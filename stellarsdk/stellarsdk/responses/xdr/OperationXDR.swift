//
//  OperationXDR.swift
//  stellarsdk
//
//  Created by Razvan Chelemen on 12/02/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public struct OperationXDR: XDRCodable {
    public var sourceAccount: MuxedAccountXDR?
    public var body: OperationBodyXDR
    
    @available(*, deprecated, message: "use init(sourceAccount: MuxedAccountXDR?, body: OperationBodyXDR) instead")
    public init(sourceAccount: PublicKey?, body: OperationBodyXDR) {
        var mux:MuxedAccountXDR? = nil
        if let sa = sourceAccount {
            mux = MuxedAccountXDR.ed25519(sa.bytes)
        }
        self.init(sourceAccount: mux, body: body)
    }
    
    public init(sourceAccount: MuxedAccountXDR?, body: OperationBodyXDR) {
        self.sourceAccount = sourceAccount
        self.body = body
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        sourceAccount = try decodeArray(type: MuxedAccountXDR.self, dec: decoder).first
        body = try container.decode(OperationBodyXDR.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        if sourceAccount != nil {
            try container.encode([sourceAccount])
        }
        else {
            try container.encode([MuxedAccountXDR]())
        }
        
        try container.encode(body)
    }
    
    public mutating func setFootprint(footprint:Footprint) {
        var invokeHostFuncOp:InvokeHostFunctionOpXDR? = nil
        switch body {
            case .invokeHostFunction(let value):
                invokeHostFuncOp = value
            default:
                break
        }
        if invokeHostFuncOp != nil {
            invokeHostFuncOp!.ledgerFootprint = footprint.xdrFootprint
            self.body = OperationBodyXDR.invokeHostFunction(invokeHostFuncOp!)
        }
    }
    
    public mutating func setContractAuth(auth:[ContractAuthXDR]) {
        var invokeHostFuncOp:InvokeHostFunctionOpXDR? = nil
        switch body {
            case .invokeHostFunction(let value):
                invokeHostFuncOp = value
            default:
                break
        }
        if invokeHostFuncOp != nil {
            invokeHostFuncOp!.auth = auth
            self.body = OperationBodyXDR.invokeHostFunction(invokeHostFuncOp!)
        }
    }
}
