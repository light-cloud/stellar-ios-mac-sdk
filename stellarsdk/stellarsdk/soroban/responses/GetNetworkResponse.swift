//
//  GetNetworkResponse.swift
//  stellarsdk
//
//  Created by Christian Rogobete on 27.02.23.
//  Copyright © 2023 Soneso. All rights reserved.
//

import Foundation

public class GetNetworkResponse: NSObject, Decodable {
    
    public var friendbotUrl:String
    public var passphrase:String
    public var protocolVersion:String
    
    private enum CodingKeys: String, CodingKey {
        case friendbotUrl
        case passphrase
        case protocolVersion
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        friendbotUrl = try values.decode(String.self, forKey: .friendbotUrl)
        passphrase = try values.decode(String.self, forKey: .passphrase)
        protocolVersion = try values.decode(String.self, forKey: .protocolVersion)
    }
}
