//
//  LedgerKeyXDR.swift
//  stellarsdk
//
//  Created by Rogobete Christian on 13.02.18.
//  Copyright © 2018 Soneso. All rights reserved.
//

import Foundation

public enum ConfigSettingID: Int32 {
    case contractMaxSizeBytes = 0
    case contractComputeV0 = 1
    case contractLedgerCostV0 = 2
    case contractHistoricalDataV0 = 3
    case contractMetaDataV0 = 4
    case contractBandwidthV0 = 5
    case contractCostParamsCpuInstructions = 6
    case contractCostParamsMemoryBytes = 7
    case contractDataKeySizeBytes = 8
    case contractDataEntrySizeBytes = 9
    case stateExpiration = 10
    case contractExecutionLanes = 11
    case bucketListSizeWindow = 12
}

public enum LedgerKeyXDR: XDRCodable {
    case account (LedgerKeyAccountXDR)
    case trustline (LedgerKeyTrustLineXDR)
    case offer (LedgerKeyOfferXDR)
    case data (LedgerKeyDataXDR)
    case claimableBalance (ClaimableBalanceIDXDR)
    case liquidityPool(LiquidityPoolIDXDR)
    case contractData(LedgerKeyContractDataXDR)
    case contractCode(LedgerKeyContractCodeXDR)
    case configSetting(Int32)
    
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        let type = try container.decode(Int32.self)
        
        switch type {
        case LedgerEntryType.account.rawValue:
            let acc = try container.decode(LedgerKeyAccountXDR.self)
            self = .account(acc)
        case LedgerEntryType.trustline.rawValue:
            let trus = try container.decode(LedgerKeyTrustLineXDR.self)
            self = .trustline(trus)
        case LedgerEntryType.offer.rawValue:
            let offeru = try container.decode(LedgerKeyOfferXDR.self)
            self = .offer(offeru)
        case LedgerEntryType.data.rawValue:
            let datamu = try container.decode(LedgerKeyDataXDR.self)
            self = .data (datamu)
        case LedgerEntryType.claimableBalance.rawValue:
            let value = try container.decode(ClaimableBalanceIDXDR.self)
            self = .claimableBalance (value)
        case LedgerEntryType.liquidityPool.rawValue:
            let value = try container.decode(LiquidityPoolIDXDR.self)
            self = .liquidityPool (value)
        case LedgerEntryType.contractData.rawValue:
            let contractData = try container.decode(LedgerKeyContractDataXDR.self)
            self = .contractData (contractData)
        case LedgerEntryType.contractCode.rawValue:
            let contractCode = try container.decode(LedgerKeyContractCodeXDR.self)
            self = .contractCode (contractCode)
        case LedgerEntryType.configSetting.rawValue:
            let configSettingId = try container.decode(Int32.self)
            self = .configSetting (configSettingId)
        default:
            let acc = try container.decode(LedgerKeyAccountXDR.self)
            self = .account(acc)
        }
    }
  
    public func type() -> Int32 {
        switch self {
        case .account: return LedgerEntryType.account.rawValue
        case .trustline: return LedgerEntryType.trustline.rawValue
        case .offer: return LedgerEntryType.offer.rawValue
        case .data: return LedgerEntryType.data.rawValue
        case .claimableBalance: return LedgerEntryType.claimableBalance.rawValue
        case .liquidityPool: return LedgerEntryType.liquidityPool.rawValue
        case .contractData: return LedgerEntryType.contractData.rawValue
        case .contractCode: return LedgerEntryType.contractCode.rawValue
        case .configSetting: return LedgerEntryType.configSetting.rawValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(type())
        
        switch self {
        case .account (let acc):
            try container.encode(acc)
        case .trustline (let trust):
            try container.encode(trust)
        case .offer (let offeru):
            try container.encode(offeru)
        case .data (let datamu):
            try container.encode(datamu)
        case .claimableBalance (let value):
            try container.encode(value)
        case .liquidityPool (let value):
            try container.encode(value)
        case .contractData (let value):
            try container.encode(value)
        case .contractCode (let value):
            try container.encode(value)
        case .configSetting (let configSettingId):
            try container.encode(configSettingId)
        }
    }
}

public struct LiquidityPoolIDXDR: XDRCodable {
    public let liquidityPoolID:WrappedData32
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        liquidityPoolID = try container.decode(WrappedData32.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(liquidityPoolID)
    }
    
    public var poolIDString: String {
        return liquidityPoolID.wrapped.hexEncodedString()
    }
}

public enum ContractEntryBodyType: Int32 {
    case dataEntry = 0
    case expirationExtension = 1
}

public enum ContractDataFlags: Int32 {
    case noAutobump = 0x1
}

public enum ContractDataDurability: Int32 {
    case temporary = 0
    case persistent = 1
}


public struct LedgerKeyContractDataXDR: XDRCodable {
    public var contract:SCAddressXDR
    public var key:SCValXDR
    public var durability:ContractDataDurability
    public var bodyType:ContractEntryBodyType
    
    public init(contract: SCAddressXDR, key: SCValXDR, durability: ContractDataDurability, bodyType: ContractEntryBodyType) {
        self.contract = contract
        self.key = key
        self.durability = durability
        self.bodyType = bodyType
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        contract = try container.decode(SCAddressXDR.self)
        key = try container.decode(SCValXDR.self)
        let durabilityVal = try container.decode(Int32.self)
        switch durabilityVal {
            case ContractDataDurability.temporary.rawValue:
                durability = ContractDataDurability.temporary
            default:
                durability = ContractDataDurability.persistent
        }
        let bodyTypeVal = try container.decode(Int32.self)
        switch bodyTypeVal {
            case ContractEntryBodyType.dataEntry.rawValue:
                bodyType = ContractEntryBodyType.dataEntry
            default:
                bodyType = ContractEntryBodyType.expirationExtension
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contract)
        try container.encode(key)
        try container.encode(durability.rawValue)
        try container.encode(bodyType.rawValue)
    }
}

public struct LedgerKeyContractCodeXDR: XDRCodable {
    public var hash:WrappedData32
    public var bodyType:ContractEntryBodyType
    
    public init(hash: WrappedData32, bodyType: ContractEntryBodyType) {
        self.hash = hash
        self.bodyType = bodyType
    }
    
    public init(wasmId: String, bodyType: ContractEntryBodyType) {
        self.hash = wasmId.wrappedData32FromHex()
        self.bodyType = bodyType
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        hash = try container.decode(WrappedData32.self)
        let bodyTypeVal = try container.decode(Int32.self)
        switch bodyTypeVal {
            case ContractEntryBodyType.dataEntry.rawValue:
                bodyType = ContractEntryBodyType.dataEntry
            default:
                bodyType = ContractEntryBodyType.expirationExtension
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(hash)
        try container.encode(bodyType.rawValue)
    }
}

