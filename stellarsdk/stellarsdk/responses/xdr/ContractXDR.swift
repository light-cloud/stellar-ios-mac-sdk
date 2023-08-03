//
//  ContractXDR.swift
//  stellarsdk
//
//  Created by Christian Rogobete.
//  Copyright © 2023 Soneso. All rights reserved.
//

import Foundation

public enum SCValType: Int32 {
    case bool = 0
    case void = 1
    case error = 2
    case u32 = 3
    case i32 = 4
    case u64 = 5
    case i64 = 6
    case timepoint = 7
    case duration = 8
    case u128 = 9
    case i128 = 10
    case u256 = 11
    case i256 = 12
    case bytes = 13
    case string = 14
    case symbol = 15
    case vec = 16
    case map = 17
    case address = 18
    case contractInstance = 19
    case ledgerKeyContractInstance = 20
    case ledgerKeyNonce = 21
}

public enum SCErrorType: Int32 {
    case contract = 0
    case wasmVm = 1
    case context = 2
    case storage = 3
    case object = 4
    case crypto = 5
    case events = 6
    case budget = 7
    case value = 8
    case auth = 9
}

public enum SCErrorCode: Int32 {
    case arithDomain = 0
    case indexBounds = 1
    case invalidInput = 2
    case missingValue = 3
    case existingValue = 4
    case exceededLimit = 5
    case invalidAction = 6
    case internalError = 7
    case unexpectedType = 8
    case unexpectedSize = 9
}

public enum ContractCostType: Int32 {
    case wasmInsnExec = 0
    case wasmMemAlloc = 1
    case hostMemAlloc = 2
    case hostMemCpy = 3
    case hostMemCmp = 4
    case invokeHostFunction = 5
    case visitObject = 6
    case valXdrConv = 7
    case valSer = 8
    case valDeser = 9
    case computeSha256Hash = 10
    case computeEd25519PubKey = 11
    case mapEntry = 12
    case vecEntry = 13
    case guardFrame = 14
    case verifyEd25519Sig = 15
    case vmMemRead = 16
    case vmMemWrite = 17
    case vmInstantiation = 18
    case vmCachedInstantiation = 19
    case invokeVmFunction = 20
    case chargeBudget = 21
    case computeKeccak256Hash = 22
    case computeEcdsaSecp256k1Key = 23
    case computeEcdsaSecp256k1Sig = 24
    case recoverEcdsaSecp256k1Key = 25
    case int256AddSub = 26
    case int256Mul = 27
    case int256Div = 28
    case int256Pow = 29
    case int256Shift = 30
}

public enum SCErrorXDR: XDRCodable {

    case contract(Int32)
    case wasmVm(Int32)
    case context(Int32)
    case storage(Int32)
    case object(Int32)
    case crypto(Int32)
    case events(Int32)
    case budget(Int32)
    case value(Int32)
    case auth(Int32)
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let discriminant = try container.decode(Int32.self)
        let type = SCErrorType(rawValue: discriminant)!
        
        switch type {
        case .contract:
            let errCode = try container.decode(Int32.self)
            self = .contract(errCode)
        case .wasmVm:
            let errCode = try container.decode(Int32.self)
            self = .wasmVm(errCode)
        case .context:
            let errCode = try container.decode(Int32.self)
            self = .context(errCode)
        case .storage:
            let errCode = try container.decode(Int32.self)
            self = .storage(errCode)
        case .object:
            let errCode = try container.decode(Int32.self)
            self = .object(errCode)
        case .crypto:
            let errCode = try container.decode(Int32.self)
            self = .crypto(errCode)
        case .events:
            let errCode = try container.decode(Int32.self)
            self = .events(errCode)
        case .budget:
            let errCode = try container.decode(Int32.self)
            self = .budget(errCode)
        case .value:
            let errCode = try container.decode(Int32.self)
            self = .value(errCode)
        case .auth:
            let errCode = try container.decode(Int32.self)
            self = .auth(errCode)
        }
    }
    
    public func type() -> Int32 {
        switch self {
        case .contract: return SCErrorType.contract.rawValue
        case .wasmVm: return SCErrorType.wasmVm.rawValue
        case .context: return SCErrorType.context.rawValue
        case .storage: return SCErrorType.storage.rawValue
        case .object: return SCErrorType.object.rawValue
        case .crypto: return SCErrorType.crypto.rawValue
        case .events: return SCErrorType.events.rawValue
        case .budget: return SCErrorType.budget.rawValue
        case .value: return SCErrorType.value.rawValue
        case .auth: return SCErrorType.auth.rawValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(type())
        switch self {
        case .contract (let errCode):
            try container.encode(errCode)
            break
        case .wasmVm (let errCode):
            try container.encode(errCode)
            break
        case .context (let errCode):
            try container.encode(errCode)
            break
        case .storage (let errCode):
            try container.encode(errCode)
            break
        case .object (let errCode):
            try container.encode(errCode)
            break
        case .crypto (let errCode):
            try container.encode(errCode)
            break
        case .events (let errCode):
            try container.encode(errCode)
            break
        case .budget (let errCode):
            try container.encode(errCode)
            break
        case .value (let errCode):
            try container.encode(errCode)
            break
        case .auth (let errCode):
            try container.encode(errCode)
            break
            
        }
    }
}

public enum SCAddressType: Int32 {
    case account = 0
    case contract = 1
}

public enum SCAddressXDR: XDRCodable {
    case account(PublicKey)
    case contract(WrappedData32)
    
    public init(accountId: String) throws {
        self = .account(try PublicKey(accountId: accountId))
    }
    
    public init(contractId: String) throws {
        if let contractIdData = contractId.data(using: .hexadecimal) {
            self = .contract(WrappedData32(contractIdData))
        } else {
            throw StellarSDKError.encodingError(message: "error xdr encoding invoke host function operation, invalid contract id")
        }
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let discriminant = try container.decode(Int32.self)
        let type = SCAddressType(rawValue: discriminant)!
        
        switch type {
        case .account:
            let account = try container.decode(PublicKey.self)
            self = .account(account)
        case .contract:
            let contract = try container.decode(WrappedData32.self)
            self = .contract(contract)
        }
    }
    
    public func type() -> Int32 {
        switch self {
        case .account: return SCAddressType.account.rawValue
        case .contract: return SCAddressType.contract.rawValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(type())
        switch self {
        case .account (let account):
            try container.encode(account)
            break
        case .contract (let contract):
            try container.encode(contract)
            break
        }
    }
    
    public var accountId:String? {
        switch self {
        case .account(let pk):
            return pk.accountId
        default:
            return nil
        }
    }
    
    public var contractId:String? {
        switch self {
        case .contract(let data):
            return data.wrapped.hexEncodedString()
        default:
            return nil
        }
    }
}

public struct SCNonceKeyXDR: XDRCodable {
    public let nonce: Int64
    
    public init(nonce:Int64) {
        self.nonce = nonce
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        nonce = try container.decode(Int64.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(nonce)
    }
}

public enum SCValXDR: XDRCodable {

    case bool(Bool)
    case void
    case error(SCErrorXDR)
    case u32(UInt32)
    case i32(Int32)
    case u64(UInt64)
    case i64(Int64)
    case timepoint(UInt64)
    case duration(UInt64)
    case u128(UInt128PartsXDR)
    case i128(Int128PartsXDR)
    case u256(UInt256PartsXDR)
    case i256(Int256PartsXDR)
    case bytes(Data)
    case string(String)
    case symbol(String)
    case vec([SCValXDR]?)
    case map([SCMapEntryXDR]?)
    case address(SCAddressXDR)
    case ledgerKeyContractInstance
    case contractInstance(SCContractInstanceXDR)
    case ledgerKeyNonce(SCNonceKeyXDR)

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let discriminant = try container.decode(Int32.self)
        let type = SCValType(rawValue: discriminant)!
        
        switch type {
        case .bool:
            let b = try container.decode(Bool.self)
            self = .bool(b)
        case .void:
            self = .void
        case .error:
            let error = try container.decode(SCErrorXDR.self)
            self = .error(error)
        case .u32:
            let u32 = try container.decode(UInt32.self)
            self = .u32(u32)
        case .i32:
            let i32 = try container.decode(Int32.self)
            self = .i32(i32)
        case .u64:
            let u64 = try container.decode(UInt64.self)
            self = .u64(u64)
        case .i64:
            let i64 = try container.decode(Int64.self)
            self = .i64(i64)
        case .timepoint:
            let timepoint = try container.decode(UInt64.self)
            self = .timepoint(timepoint)
        case .duration:
            let duration = try container.decode(UInt64.self)
            self = .duration(duration)
        case .u128:
            let u128 = try container.decode(UInt128PartsXDR.self)
            self = .u128(u128)
        case .i128:
            let i128 = try container.decode(Int128PartsXDR.self)
            self = .i128(i128)
        case .u256:
            let u256 = try container.decode(UInt256PartsXDR.self)
            self = .u256(u256)
        case .i256:
            let i256 = try container.decode(Int256PartsXDR.self)
            self = .i256(i256)
        case .bytes:
            let bytes = try container.decode(Data.self)
            self = .bytes(bytes)
        case .string:
            let string = try container.decode(String.self)
            self = .string(string)
        case .symbol:
            let symbol = try container.decode(String.self)
            self = .symbol(symbol)
        case .vec:
            let vecPresent = try container.decode(UInt32.self)
            if vecPresent != 0 {
                let vec = try decodeArray(type: SCValXDR.self, dec: decoder)
                self = .vec(vec)
            } else {
                self = .vec(nil)
            }
        case .map:
            let mapPresent = try container.decode(UInt32.self)
            if mapPresent != 0 {
                let map = try decodeArray(type: SCMapEntryXDR.self, dec: decoder)
                self = .map(map)
            } else {
                self = .map(nil)
            }
        case .address:
            let address = try container.decode(SCAddressXDR.self)
            self = .address(address)
            
        case .ledgerKeyContractInstance:
            self = .ledgerKeyContractInstance
            break
        case .contractInstance:
            let contractInstance = try container.decode(SCContractInstanceXDR.self)
            self = .contractInstance(contractInstance)
        case .ledgerKeyNonce:
            let ledgerKeyNonce = try container.decode(SCNonceKeyXDR.self)
            self = .ledgerKeyNonce(ledgerKeyNonce)
        }
    }
    
    public init(accountEd25519Signature: AccountEd25519Signature) {
        let pkBytes = Data(accountEd25519Signature.publicKey.bytes)
        let sigBytes = Data(accountEd25519Signature.signature)
        let pkMapEntry = SCMapEntryXDR(key: SCValXDR.symbol("public_key"), val: SCValXDR.bytes(pkBytes))
        let sigMapEntry = SCMapEntryXDR(key: SCValXDR.symbol("signature"), val: SCValXDR.bytes(sigBytes))
        self = .map([pkMapEntry,sigMapEntry])
    }
    
    public func type() -> Int32 {
        switch self {
        case .bool: return SCValType.bool.rawValue
        case .void: return SCValType.bool.rawValue
        case .error: return SCValType.error.rawValue
        case .u32: return SCValType.u32.rawValue
        case .i32: return SCValType.i32.rawValue
        case .u64: return SCValType.u64.rawValue
        case .i64: return SCValType.i64.rawValue
        case .timepoint: return SCValType.timepoint.rawValue
        case .duration: return SCValType.duration.rawValue
        case .u128: return SCValType.u128.rawValue
        case .i128: return SCValType.i128.rawValue
        case .u256: return SCValType.u256.rawValue
        case .i256: return SCValType.i256.rawValue
        case .bytes: return SCValType.bytes.rawValue
        case .string: return SCValType.string.rawValue
        case .symbol: return SCValType.symbol.rawValue
        case .vec: return SCValType.vec.rawValue
        case .map: return SCValType.map.rawValue
        case .address: return SCValType.address.rawValue
        case .ledgerKeyContractInstance: return SCValType.ledgerKeyContractInstance.rawValue
        case .contractInstance: return SCValType.contractInstance.rawValue
        case .ledgerKeyNonce: return SCValType.ledgerKeyNonce.rawValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(type())
        switch self {
        case .bool (let bool):
            try container.encode(bool)
        case .void:
            break
        case .error (let error):
            try container.encode(error)
        case .u32 (let u32):
            try container.encode(u32)
        case .i32 (let i32):
            try container.encode(i32)
        case .u64 (let u64):
            try container.encode(u64)
        case .i64 (let i64):
            try container.encode(i64)
        case .timepoint (let timepoint):
            try container.encode(timepoint)
        case .duration (let duration):
            try container.encode(duration)
        case .u128 (let u128):
            try container.encode(u128)
        case .i128 (let i128):
            try container.encode(i128)
        case .u256 (let u256):
            try container.encode(u256)
        case .i256 (let i256):
            try container.encode(i256)
        case .bytes (let bytes):
            try container.encode(bytes)
        case .string (let string):
            try container.encode(string)
        case .symbol (let symbol):
            try container.encode(symbol)
        case .vec (let vec):
            if let vec = vec {
                let flag: Int32 = 1
                try container.encode(flag)
                try container.encode(vec)
            } else {
                let flag: Int32 = 0
                try container.encode(flag)
            }
            break
        case .map (let map):
            if let map = map {
                let flag: Int32 = 1
                try container.encode(flag)
                try container.encode(map)
            } else {
                let flag: Int32 = 0
                try container.encode(flag)
            }
            break
        case .address(let address):
            try container.encode(address)
            break
        case .ledgerKeyContractInstance:
            break
        case .contractInstance(let val):
            try container.encode(val)
            break
        case .ledgerKeyNonce (let nonceKey):
            try container.encode(nonceKey)
            break
        }
    }
    
    public static func fromXdr(base64:String) throws -> SCValXDR {
        let xdrDecoder = XDRDecoder.init(data: [UInt8].init(base64: base64))
        return try SCValXDR(from: xdrDecoder)
    }
    

    public var isBool:Bool {
        return type() == SCValType.bool.rawValue
    }
    
    public var bool:Bool? {
        switch self {
        case .bool(let bool):
            return bool
        default:
            return nil
        }
    }
    
    public var isVoid:Bool {
        return type() == SCValType.void.rawValue
    }
    
    public var isU32:Bool {
        return type() == SCValType.u32.rawValue
    }
    
    public var u32:UInt32? {
        switch self {
        case .u32(let val):
            return val
        default:
            return nil
        }
    }
    
    public var isI32: Bool {
        return type() == SCValType.i32.rawValue
    }
    
    public var i32:Int32? {
        switch self {
        case .i32(let val):
            return val
        default:
            return nil
        }
    }
    
    public var isError:Bool {
        return type() == SCValType.error.rawValue
    }
    
    public var error:SCErrorXDR? {
        switch self {
        case .error(let val):
            return val
        default:
            return nil
        }
    }
    
    public var isU64: Bool {
        return type() == SCValType.u64.rawValue
    }
    
    public var u64:UInt64? {
        switch self {
        case .u64(let u64):
            return u64
        default:
            return nil
        }
    }
    
    public var isI64: Bool {
        return type() == SCValType.i64.rawValue
    }
    
    public var i64:Int64? {
        switch self {
        case .i64(let i64):
            return i64
        default:
            return nil
        }
    }
    
    public var isTimepoint: Bool {
        return type() == SCValType.timepoint.rawValue
    }
    
    public var timepoint:UInt64? {
        switch self {
        case .timepoint(let timepoint):
            return timepoint
        default:
            return nil
        }
    }
    
    public var isDuration: Bool {
        return type() == SCValType.duration.rawValue
    }
    
    public var duration:UInt64? {
        switch self {
        case .duration(let duration):
            return duration
        default:
            return nil
        }
    }
    
    public var isU128: Bool {
        return type() == SCValType.u128.rawValue
    }
    
    public var u128:UInt128PartsXDR? {
        switch self {
        case .u128(let u128):
            return u128
        default:
            return nil
        }
    }
    
    public var isI128: Bool {
        return type() == SCValType.i128.rawValue
    }
    
    public var i128:Int128PartsXDR? {
        switch self {
        case .i128(let i128):
            return i128
        default:
            return nil
        }
    }
    
    public var isU256: Bool {
        return type() == SCValType.u256.rawValue
    }
    
    public var u256:UInt256PartsXDR? {
        switch self {
        case .u256(let u256):
            return u256
        default:
            return nil
        }
    }
    
    public var isI256: Bool {
        return type() == SCValType.i256.rawValue
    }
    
    public var i256:Int256PartsXDR? {
        switch self {
        case .i256(let i256):
            return i256
        default:
            return nil
        }
    }
    
    public var isBytes:Bool {
        return type() == SCValType.bytes.rawValue
    }
    
    public var bytes:Data? {
        switch self {
        case .bytes(let bytes):
            return bytes
        default:
            return nil
        }
    }
    
    public var isString:Bool {
        return type() == SCValType.string.rawValue
    }
    
    public var string:String? {
        switch self {
        case .string(let val):
            return val
        default:
            return nil
        }
    }
    
    public var isSymbol:Bool {
        return type() == SCValType.symbol.rawValue
    }
    
    public var symbol:String? {
        switch self {
        case .symbol(let val):
            return val
        default:
            return nil
        }
    }
    
    public var isVec: Bool {
        return type() == SCValType.vec.rawValue
    }
    
    public var vec:[SCValXDR]? {
        switch self {
        case .vec(let vec):
            return vec
        default:
            return nil
        }
    }
    
    public var isMap: Bool {
        return type() == SCValType.map.rawValue
    }
    
    public var map:[SCMapEntryXDR]? {
        switch self {
        case .map(let map):
            return map
        default:
            return nil
        }
    }
    
    public var isAddress: Bool {
        return type() == SCValType.address.rawValue
    }
    
    public var address:SCAddressXDR? {
        switch self {
        case .address(let val):
            return val
        default:
            return nil
        }
    }
    
    public var isContractInstance: Bool {
        return type() == SCValType.contractInstance.rawValue
    }
    
    public var contractInstance:SCContractInstanceXDR? {
        switch self {
        case .contractInstance(let val):
            return val
        default:
            return nil
        }
    }
    
    public var isLedgerKeyContractInstance: Bool {
        return type() == SCValType.ledgerKeyContractInstance.rawValue
    }
    
    public var isLedgerKeyNonce: Bool {
        return type() == SCValType.ledgerKeyNonce.rawValue
    }
    
    public var ledgerKeyNonce:SCNonceKeyXDR? {
        switch self {
        case .ledgerKeyNonce(let val):
            return val
        default:
            return nil
        }
    }
}


public struct SCMapEntryXDR: XDRCodable {
    public let key: SCValXDR
    public let val: SCValXDR
    
    public init(key:SCValXDR, val:SCValXDR) {
        self.key = key
        self.val = val
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        key = try container.decode(SCValXDR.self)
        val = try container.decode(SCValXDR.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(key)
        try container.encode(val)
    }
}

public enum ContractExecutableType: Int32 {
    case wasm = 0
    case token = 1
}

public enum ContractExecutableXDR: XDRCodable {
    case wasm(WrappedData32)
    case token
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let discriminant = try container.decode(Int32.self)
        let type = ContractExecutableType(rawValue: discriminant)!
        
        switch type {
        case .wasm:
            let wasmHash = try container.decode(WrappedData32.self)
            self = .wasm(wasmHash)
        case .token:
            self = .token
        }
    }
    
    public func type() -> Int32 {
        switch self {
        case .wasm: return ContractExecutableType.wasm.rawValue
        case .token: return ContractExecutableType.token.rawValue
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(type())
        switch self {
        case .wasm (let wasmHash):
            try container.encode(wasmHash)
            break
        case .token:
            break
        }
    }
    
    public var isWasm:Bool? {
        return type() == ContractExecutableType.wasm.rawValue
    }
    
    public var wasm:WrappedData32? {
        switch self {
        case .wasm(let val):
            return val
        default:
            return nil
        }
    }
    
    public var isToken:Bool? {
        return type() == ContractExecutableType.token.rawValue
    }
}

public struct Int128PartsXDR: XDRCodable {
    public let hi: Int64
    public let lo: UInt64
    
    public init(hi:Int64, lo:UInt64) {
        self.hi = hi
        self.lo = lo
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        hi = try container.decode(Int64.self)
        lo = try container.decode(UInt64.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(hi)
        try container.encode(lo)
    }
}

public struct UInt128PartsXDR: XDRCodable {
    public let hi: UInt64
    public let lo: UInt64
    
    public init(hi:UInt64, lo:UInt64) {
        self.hi = hi
        self.lo = lo
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        hi = try container.decode(UInt64.self)
        lo = try container.decode(UInt64.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(hi)
        try container.encode(lo)
    }
}

public struct Int256PartsXDR: XDRCodable {

    public let hiHi: Int64
    public let hiLo: UInt64
    public let loHi: UInt64
    public let loLo: UInt64
    
    public init(hiHi: Int64, hiLo: UInt64, loHi: UInt64, loLo: UInt64) {
        self.hiHi = hiHi
        self.hiLo = hiLo
        self.loHi = loHi
        self.loLo = loLo
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        hiHi = try container.decode(Int64.self)
        hiLo = try container.decode(UInt64.self)
        loHi = try container.decode(UInt64.self)
        loLo = try container.decode(UInt64.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(hiHi)
        try container.encode(hiLo)
        try container.encode(loHi)
        try container.encode(loLo)
    }
}

public struct UInt256PartsXDR: XDRCodable {

    public let hiHi: UInt64
    public let hiLo: UInt64
    public let loHi: UInt64
    public let loLo: UInt64
    
    public init(hiHi: UInt64, hiLo: UInt64, loHi: UInt64, loLo: UInt64) {
        self.hiHi = hiHi
        self.hiLo = hiLo
        self.loHi = loHi
        self.loLo = loLo
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        hiHi = try container.decode(UInt64.self)
        hiLo = try container.decode(UInt64.self)
        loHi = try container.decode(UInt64.self)
        loLo = try container.decode(UInt64.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(hiHi)
        try container.encode(hiLo)
        try container.encode(loHi)
        try container.encode(loLo)
    }
}

public struct SCContractInstanceXDR: XDRCodable {
    public let executable: ContractExecutableXDR
    public let storage: [SCMapEntryXDR]?
    
    public init(executable: ContractExecutableXDR, storage: [SCMapEntryXDR]?) {
        self.executable = executable
        self.storage = storage
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        executable = try container.decode(ContractExecutableXDR.self)
        let present = try container.decode(Int32.self) == 1
        if (present) {
            storage = try decodeArray(type: SCMapEntryXDR.self, dec: decoder)
        } else {
            storage = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(executable)
        if let sm = storage {
            try container.encode(Int32(1))
            try container.encode(sm)
        }
        else {
            try container.encode(Int32(0))
        }
    }
}
