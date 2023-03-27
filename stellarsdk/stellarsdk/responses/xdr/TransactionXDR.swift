//
//  TransactionXDR.swift
//  stellarsdk
//
//  Created by SONESO
//  Copyright © 2020 Soneso. All rights reserved.
//

import Foundation

public struct TransactionXDR: XDRCodable {
    public let sourceAccount: MuxedAccountXDR
    public let fee: UInt32
    public let seqNum: Int64
    public let cond: PreconditionsXDR
    public let memo: MemoXDR
    public var operations: [OperationXDR]
    public let reserved: Int32
    
    private var signatures = [DecoratedSignatureXDR]()
    
    public init(sourceAccount: MuxedAccountXDR, seqNum: Int64, cond: PreconditionsXDR, memo: MemoXDR, operations: [OperationXDR], maxOperationFee:UInt32 = 100) {
        self.sourceAccount = sourceAccount
        self.seqNum = seqNum
        self.cond = cond
        self.memo = memo
        self.operations = operations
        
        self.fee = maxOperationFee * UInt32(operations.count)
        
        reserved = 0
    }
    
    public init(sourceAccount: PublicKey, seqNum: Int64, cond: PreconditionsXDR, memo: MemoXDR, operations: [OperationXDR], maxOperationFee:UInt32 = 100) {
        let mux = MuxedAccountXDR.ed25519(sourceAccount.bytes)
        self.init(sourceAccount: mux, seqNum: seqNum, cond: cond, memo: memo, operations: operations, maxOperationFee: maxOperationFee)
    }
    
    @available(*, deprecated, message: "use preconditions instead")
    public init(sourceAccount: PublicKey, seqNum: Int64, timeBounds: TimeBoundsXDR?, memo: MemoXDR, operations: [OperationXDR], maxOperationFee:UInt32 = 100) {
        let mux = MuxedAccountXDR.ed25519(sourceAccount.bytes)
        var cond = PreconditionsXDR.none
        if let tb = timeBounds {
            cond = PreconditionsXDR.time(tb)
        }
        self.init(sourceAccount: mux, seqNum: seqNum, cond: cond, memo: memo, operations: operations, maxOperationFee: maxOperationFee)
    }

    @available(*, deprecated, message: "use preconditions instead")
    public init(sourceAccount: MuxedAccountXDR, seqNum: Int64, timeBounds: TimeBoundsXDR?, memo: MemoXDR, operations: [OperationXDR], maxOperationFee:UInt32 = 100) {
        var cond = PreconditionsXDR.none
        if let tb = timeBounds {
            cond = PreconditionsXDR.time(tb)
        }
        self.init(sourceAccount: sourceAccount, seqNum: seqNum, cond: cond, memo: memo, operations: operations, maxOperationFee:maxOperationFee)
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        sourceAccount = try container.decode(MuxedAccountXDR.self)
        fee = try container.decode(UInt32.self)
        seqNum = try container.decode(Int64.self)
        cond = try container.decode(PreconditionsXDR.self)
        memo = try container.decode(MemoXDR.self)
        operations = try decodeArray(type: OperationXDR.self, dec: decoder)
        reserved = try container.decode(Int32.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        
        try container.encode(sourceAccount)
        try container.encode(fee)
        try container.encode(seqNum)
        try container.encode(cond)
        try container.encode(memo)
        try container.encode(operations)
        try container.encode(reserved)
    }
    
    public mutating func sign(keyPair:KeyPair, network:Network) throws {
        let transactionHash = try [UInt8](hash(network: network))
        let signature = keyPair.signDecorated(transactionHash)
        signatures.append(signature)
    }
    
    public mutating func addSignature(signature: DecoratedSignatureXDR) {
        signatures.append(signature)
    }
    
    private func signatureBase(network:Network) throws -> Data {
        let payload = TransactionSignaturePayload(networkId: WrappedData32(network.networkId), taggedTransaction: .typeTX(self))
        return try Data(XDREncoder.encode(payload))
    }
    
    public func hash(network:Network) throws -> Data {
        return try signatureBase(network: network).sha256()
    }
    
    public func toEnvelopeXDR() throws -> TransactionEnvelopeXDR {
        let envelopeV1 = TransactionV1EnvelopeXDR(tx: self, signatures: signatures)
        return TransactionEnvelopeXDR.v1(envelopeV1)
    }
    
    public func encodedEnvelope() throws -> String {
        let envelope = try toEnvelopeXDR()
        var encodedEnvelope = try XDREncoder.encode(envelope)
        
        return Data(bytes: &encodedEnvelope, count: encodedEnvelope.count).base64EncodedString()
    }
    
    public func toEnvelopeV1XDR() throws -> TransactionV1EnvelopeXDR {        
        return TransactionV1EnvelopeXDR(tx: self, signatures: signatures)
    }
    
    public func encodedV1Envelope() throws -> String {
        let envelope = try toEnvelopeV1XDR()
        var encodedEnvelope = try XDREncoder.encode(envelope)
        
        return Data(bytes: &encodedEnvelope, count: encodedEnvelope.count).base64EncodedString()
    }
    
    public func encodedV1Transaction() throws -> String {
        var encodedT = try XDREncoder.encode(self)
        
        return Data(bytes: &encodedT, count: encodedT.count).base64EncodedString()
    }
}
