//
//  GetLedgerEntryResponse.swift
//  stellarsdk
//
//  Created by Christian Rogobete.
//  Copyright © 2023 Soneso. All rights reserved.
//

import Foundation

/// Response when reading the current values of ledger entries.
public class GetLedgerEntryResponse: NSObject, Decodable {
    
    /// The current value of the given ledger entry  (serialized in a base64 string)
    public var ledgerEntryData:String
    /// The ledger number of the last time this entry was updated (optional)
    public var lastModifiedLedgerSeq:String?
    /// The current latest ledger observed by the node when this response was generated.
    public var latestLedger:String
    
    private enum CodingKeys: String, CodingKey {
        case ledgerEntryData = "xdr"
        case lastModifiedLedgerSeq
        case latestLedger
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ledgerEntryData = try values.decode(String.self, forKey: .ledgerEntryData)
        lastModifiedLedgerSeq = try values.decodeIfPresent(String.self, forKey: .lastModifiedLedgerSeq)
        latestLedger = try values.decode(String.self, forKey: .latestLedger)
    }
}
