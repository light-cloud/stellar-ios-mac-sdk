//
//  GetTransactionStatusResponse.swift
//  stellarsdk
//
//  Created by Christian Rogobete.
//  Copyright © 2023 Soneso. All rights reserved.
//

import Foundation

/// Response when polling the rpc server to find out if a transaction has been
/// completed.
/// See: https://soroban.stellar.org/api/methods/getTransaction
public class GetTransactionResponse: NSObject, Decodable {
    
    public static let STATUS_SUCCESS = "SUCCESS"
    public static let STATUS_NOT_FOUND = "NOT_FOUND"
    public static let STATUS_FAILED = "FAILED"
    
    /// The current status of the transaction by hash, one of: SUCCESS, NOT_FOUND, FAILED
    public var status:String
    
    /// The latest ledger known to Soroban-RPC at the time it handled the getTransaction() request.
    public var latestLedger:String
    
    /// The unix timestamp of the close time of the latest ledger known to Soroban-RPC at the time it handled the getTransaction() request.
    public var latestLedgerCloseTime:String
    
    /// The oldest ledger ingested by Soroban-RPC at the time it handled the getTransaction() request.
    public var oldestLedger:String
    
    /// (optional) The sequence of the ledger which included the transaction. This field is only present if status is SUCCESS or FAILED.
    public var ledger:String?
    
    /// (optional) The unix timestamp of when the transaction was included in the ledger. This field is only present if status is SUCCESS or FAILED.
    public var createdAt:String?
    
    /// (optional) The index of the transaction among all transactions included in the ledger. This field is only present if status is SUCCESS or FAILED.
    public var applicationOrder:Int?
    
    /// (optional) Indicates whether the transaction was fee bumped. This field is only present if status is SUCCESS or FAILED.
    public var feeBump:Bool?
    
    /// (optional) A base64 encoded string of the raw TransactionEnvelope XDR struct for this transaction.
    public var envelopeXdr:String? // TransactionEnvelope
    
    /// (optional) A base64 encoded string of the raw TransactionResult XDR struct for this transaction. This field is only present if status is SUCCESS or FAILED.
    public var resultXdr:String? // TransactionResult
    
    /// (optional) A base64 encoded string of the raw TransactionResultMeta XDR struct for this transaction.
    public var resultMetaXdr:String? // TransactionResultMeta
    
    /// (optional) Will be present on failed transactions.
    public var error:TransactionStatusError?
    
    private enum CodingKeys: String, CodingKey {
        case status
        case latestLedger
        case latestLedgerCloseTime
        case oldestLedger
        case ledger
        case createdAt
        case applicationOrder
        case feeBump
        case envelopeXdr
        case resultXdr
        case resultMetaXdr
        case error
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        status = try values.decode(String.self, forKey: .status)
        latestLedger = try values.decode(String.self, forKey: .latestLedger)
        latestLedgerCloseTime = try values.decode(String.self, forKey: .latestLedgerCloseTime)
        oldestLedger = try values.decode(String.self, forKey: .oldestLedger)
        ledger = try values.decodeIfPresent(String.self, forKey: .ledger)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        applicationOrder = try values.decodeIfPresent(Int.self, forKey: .applicationOrder)
        feeBump = try values.decodeIfPresent(Bool.self, forKey: .feeBump)
        envelopeXdr = try values.decodeIfPresent(String.self, forKey: .envelopeXdr)
        resultXdr = try values.decodeIfPresent(String.self, forKey: .resultXdr)
        resultMetaXdr = try values.decodeIfPresent(String.self, forKey: .resultMetaXdr)
        error = try values.decodeIfPresent(TransactionStatusError.self, forKey: .error)
    }
    
    /// Extracts the value from the first transaction status result
    public var resultValue:SCValXDR? {
        if (error != nil || status != GetTransactionResponse.STATUS_SUCCESS || resultMetaXdr == nil) {
            return nil
        }
        let meta = try? TransactionMetaXDR(fromBase64: resultMetaXdr!)
        return meta?.transactionMetaV3?.sorobanMeta?.returnValue
    }
    
    /// Extracts the wasm id from the response if the transaction installed a contract
    public var wasmId:String? {
        return binHex
    }
    
    /// Extracts the wasm id from the response if the transaction created a contract
    public var createdContractId:String? {
        return resultValue?.address?.contractId
    }
    
    private var binHex:String? {
        if let data = bin {
            return data.hexEncodedString()
        }
        return nil
    }
    
    private var bin:Data? {
        return resultValue?.bytes
    }
}
