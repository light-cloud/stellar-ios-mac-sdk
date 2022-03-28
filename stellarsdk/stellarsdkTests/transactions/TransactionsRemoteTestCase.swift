//
//  TransactionsRemoteTestCase.swift
//  stellarsdkTests
//
//  Created by Razvan Chelemen on 08/02/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import XCTest
import stellarsdk

class TransactionsRemoteTestCase: XCTestCase {
    //let sdk = StellarSDK(withHorizonUrl: "https://horizon.stellar.org")
    let sdk = StellarSDK()
    let seed = "SBFLTUTTPH36XNVCUAHYNUSVFLWDQFJ2ZH5YP3VNJJYQAJ2JZ2RZRGF7"
    var streamItem:TransactionsStreamItem? = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetTransactions() {
        let expectation = XCTestExpectation(description: "Get transactions")
        
        sdk.transactions.getTransactions(limit: 15) { (response) -> (Void) in
            switch response {
            case .success(let transactionsResponse):
                // load next page
                transactionsResponse.getNextPage(){ (response) -> (Void) in
                    switch response {
                    case .success(let nextTransactionsResponse):
                        // load previous page, should contain the same transactions as the first page
                        nextTransactionsResponse.getPreviousPage(){ (response) -> (Void) in
                            switch response {
                            case .success(let prevTransactionsResponse):
                                let transaction1 = transactionsResponse.records.first
                                let transaction2 = prevTransactionsResponse.records.last // because ordering is asc now.
                                XCTAssertTrue(transaction1?.id == transaction2?.id)
                                XCTAssertTrue(transaction1?.transactionHash == transaction2?.transactionHash)
                                XCTAssertTrue(transaction1?.ledger == transaction2?.ledger)
                                XCTAssertTrue(transaction1?.createdAt == transaction2?.createdAt)
                                XCTAssertTrue(transaction1?.sourceAccount == transaction2?.sourceAccount)
                                XCTAssertTrue(transaction1?.sourceAccountSequence == transaction2?.sourceAccountSequence)
                                XCTAssertTrue(transaction1?.maxFee == transaction2?.maxFee)
                                XCTAssertTrue(transaction1?.feeAccount == transaction2?.feeAccount)
                                XCTAssertTrue(transaction1?.feeCharged == transaction2?.feeCharged)
                                XCTAssertTrue(transaction1?.operationCount == transaction2?.operationCount)
                                XCTAssertTrue(transaction1?.memoType == transaction2?.memoType)
                                XCTAssertTrue(transaction1?.memo == transaction2?.memo)
                                XCTAssert(true)
                                expectation.fulfill()
                            case .failure(let error):
                                StellarSDKLog.printHorizonRequestErrorMessage(tag:"GT Test", horizonRequestError: error)
                                XCTAssert(false)
                            }
                        }
                    case .failure(let error):
                        StellarSDKLog.printHorizonRequestErrorMessage(tag:"GT Test", horizonRequestError: error)
                        XCTAssert(false)
                    }
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"GT Test", horizonRequestError: error)
                XCTAssert(false)
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testGetTransactionsForAccount() {
        let expectation = XCTestExpectation(description: "Get transactions for account")
        let pk = try! KeyPair(secretSeed: seed).publicKey
        sdk.transactions.getTransactions(forAccount: pk.accountId) { (response) -> (Void) in
            switch response {
            case .success(_):
                XCTAssert(true)
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"GTFA Test", horizonRequestError: error)
                XCTAssert(false)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testGetTransactionsForClaimableBalance() {
        let expectation = XCTestExpectation(description: "Get transactions for account")
        let claimableBalanceId = "00000000cca8fa61d9c3e2274943f24fbda525cdf836aee7267f0db2905571ad0eb8760c"
        sdk.transactions.getTransactions(forClaimableBalance: claimableBalanceId) { (response) -> (Void) in
            switch response {
            case .success(let transactions):
                if let _ = transactions.records.first {
                    XCTAssert(true)
                } else {
                    XCTAssert(false)
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"GTFA Test", horizonRequestError: error)
                XCTAssert(false)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testGetTransactionsForLedger() {
        let expectation = XCTestExpectation(description: "Get transactions for ledger")
        
        sdk.transactions.getTransactions(forLedger: "19") { (response) -> (Void) in
            switch response {
            case .success(_):
                XCTAssert(true)
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"GTFL Test", horizonRequestError: error)
                XCTAssert(false)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testGetTransactionDetails() {
        let expectation = XCTestExpectation(description: "Get transaction details")
        
        sdk.transactions.getTransactionDetails(transactionHash: "542fbd10071ea9f39217fa262336ac725f443bb6e35c0cab1c01ac16c21f226e") { (response) -> (Void) in
            switch response {
            case .success(_):
                XCTAssert(true)
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"GTD Test", horizonRequestError: error)
                XCTAssert(false)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testGetTransactionDetailsClaimAtomTypeLiquidityPool() {
        let expectation = XCTestExpectation(description: "Get transaction details")
        
        sdk.transactions.getTransactionDetails(transactionHash: "c08aa6ddc85a45e61616e04169255b65ef8f18a1770cfd1f9d6ef06e1d9181b5") { (response) -> (Void) in
            switch response {
            case .success(let transaction):
                XCTAssert(transaction.transactionResult.feeCharged == 100);
                switch(transaction.transactionResult.resultBody) {
                    case .success(let operations):
                        XCTAssert(operations.count == 1)
                        switch(operations.first) {
                            case .pathPaymentStrictSend(_, let result):
                                switch(result) {
                                    case .success(_, let claimAtoms, _):
                                        XCTAssert(claimAtoms.count == 3)
                                        switch (claimAtoms.first) {
                                            case .liquidityPool(let claimAtomLiquidityPool):
                                                XCTAssert(claimAtomLiquidityPool.amountSold == 55011524)
                                                XCTAssert(claimAtomLiquidityPool.assetSold.assetCode == "USD")
                                                XCTAssert(claimAtomLiquidityPool.amountBought == 12000000)
                                                XCTAssert(claimAtomLiquidityPool.assetBought.assetCode == "USDC")
                                            default:
                                                XCTAssert(false)
                                        }
                                    default:
                                        XCTAssert(false)
                                }
                            default:
                                XCTAssert(false)
                        }
                    default:
                        XCTAssert(false)
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"GTD Test", horizonRequestError: error)
                XCTAssert(false)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }

    func testTransactionSigning() {
        let keyPair = try! KeyPair(secretSeed: seed)
        
        let expectation = XCTestExpectation(description: "Transaction successfully signed.")
        sdk.accounts.getAccountDetails(accountId: keyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let data):
                let operationBody = OperationBodyXDR.inflation
                let operation = OperationXDR(sourceAccount: keyPair.publicKey, body: operationBody)
                var transaction = TransactionXDR(sourceAccount: keyPair.publicKey, seqNum: data.sequenceNumber + 1, timeBounds: nil, memo: .none, operations: [operation])
                try! transaction.sign(keyPair: keyPair, network: .testnet)
                let encodedT = try! transaction.encodedV1Transaction()
                print("\nTransaction V1:")
                print(encodedT)
                print("\nEnvelope V1:")
                let xdrEnvelopeV0 = try! transaction.encodedV1Envelope()
                print(xdrEnvelopeV0)
                print("\nEnvelope P13:")
                let xdrEnvelope = try! transaction.encodedEnvelope()
                print(xdrEnvelope)
                expectation.fulfill()
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"TS Test", horizonRequestError:error)
                XCTAssert(false)
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testTransactionV0Signing() {
        let keyPair = try! KeyPair(secretSeed: seed)
        
        let expectation = XCTestExpectation(description: "Transaction successfully signed.")
        sdk.accounts.getAccountDetails(accountId: keyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let data):
                let operationBody = OperationBodyXDR.inflation
                let operation = OperationXDR(sourceAccount: keyPair.publicKey, body: operationBody)
                var transaction = TransactionV0XDR(sourceAccount: keyPair.publicKey, seqNum: data.sequenceNumber + 1, timeBounds: nil, memo: .none, operations: [operation])
                try! transaction.sign(keyPair: keyPair, network: .testnet)
                let encodedT = try! transaction.encodedV0Transaction()
                print("\nTransaction VO:")
                print(encodedT)
                print("\nEnvelope VO:")
                let xdrEnvelopeV0 = try! transaction.encodedV0Envelope()
                print(xdrEnvelopeV0)
                print("\nEnvelope P13:")
                let xdrEnvelope = try! transaction.encodedEnvelope()
                print(xdrEnvelope)
                expectation.fulfill()
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"TS Test", horizonRequestError:error)
                XCTAssert(false)
            }
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testTransactionMultiSigning() {
        let expectation = XCTestExpectation(description: "Transaction Multisignature")
        
        do {
            let source = try KeyPair(secretSeed:seed)
            let destination = try KeyPair(secretSeed: "SBK3OW43UIX4HDWDJNO4FTOKL3ESZ4CBDPA57UAUE7SL3JMPNHWZEYGF")
            
            streamItem = sdk.transactions.stream(for: .transactionsForAccount(account: source.accountId, cursor: "now"))
            streamItem?.onReceive { response in
                switch response {
                case .open:
                    break
                case .response(_, let response):
                    for sign in response.signatures {
                        print("Signature: \(sign)")
                    }
                    if response.signatures.count == 2 {
                        XCTAssert(true)
                        expectation.fulfill()
                        self.streamItem?.closeStream()
                        self.streamItem = nil
                    }
                case .error(let error):
                    if let horizonRequestError = error as? HorizonRequestError {
                        StellarSDKLog.printHorizonRequestErrorMessage(tag:"SRP Test - destination", horizonRequestError:horizonRequestError)
                    } else {
                        print("Error \(error?.localizedDescription ?? "")")
                    }
                }
            }
            
            sdk.accounts.getAccountDetails(accountId: source.accountId) { (response) -> (Void) in
                switch response {
                case .success(let accountResponse):
                    do {
                        let paymentOperation = PaymentOperation(destination: destination,
                                                                asset: Asset(type: AssetType.ASSET_TYPE_NATIVE)!,
                                                                amount: 1.5)
                        
                        let paymentOperation2 = PaymentOperation(sourceAccount: destination,
                                                                destination: source,
                                                                asset: Asset(type: AssetType.ASSET_TYPE_NATIVE)!,
                                                                amount: 3.5)
                        
                        let transaction = try Transaction(sourceAccount: accountResponse,
                                                          operations: [paymentOperation, paymentOperation2],
                                                          memo: Memo.none,
                                                          timeBounds:nil)
                        
                        try transaction.sign(keyPair: source, network: .testnet)
                        try transaction.sign(keyPair: destination, network: .testnet)
                        
                        try self.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                            switch response {
                            case .success(let rep):
                                print("SRP Test: Transaction successfully sent. Hash: \(rep.transactionHash)")
                            case .destinationRequiresMemo(let destinationAccountId):
                                print("SRP Test: Destination requires memo \(destinationAccountId)")
                                XCTAssert(false)
                                expectation.fulfill()
                            case .failure(let error):
                                StellarSDKLog.printHorizonRequestErrorMessage(tag:"SRP Test", horizonRequestError:error)
                                XCTAssert(false)
                                expectation.fulfill()
                            }
                        }
                    } catch {
                        XCTAssert(false)
                        expectation.fulfill()
                    }
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"SRP Test", horizonRequestError:error)
                    XCTAssert(false)
                    expectation.fulfill()
                }
            }
        } catch {
            XCTAssert(false)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testTransactionEnvelopePost() {
        let keyPair = try! KeyPair(secretSeed: seed)
        
        let expectation = XCTestExpectation(description: "Transaction successfully signed.")
        sdk.accounts.getAccountDetails(accountId: keyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let data):
                let operationBody0 = OperationBodyXDR.manageData(ManageDataOperationXDR(dataName: "kop", dataValue: "api.stellar.org".data(using: .utf8)))
                let operation0 = OperationXDR(sourceAccount: keyPair.publicKey, body: operationBody0)
                let operationBody = OperationBodyXDR.bumpSequence(BumpSequenceOperationXDR(bumpTo: data.sequenceNumber + 10))
                let operation = OperationXDR(sourceAccount: keyPair.publicKey, body: operationBody)
                var transaction = TransactionXDR(sourceAccount: keyPair.publicKey, seqNum: data.sequenceNumber + 1, timeBounds: nil, memo: .none, operations: [operation0, operation], maxOperationFee: 190)
                
                try! transaction.sign(keyPair: keyPair, network: .testnet)
                let xdrEnvelope = try! transaction.encodedEnvelope()
                print(xdrEnvelope)
                self.sdk.transactions.postTransaction(transactionEnvelope: xdrEnvelope, response: { (response) -> (Void) in
                    switch response {
                    case .success(let transaction):
                        print(transaction.transactionHash)
                        expectation.fulfill()
                    case .destinationRequiresMemo(let destinationAccountId):
                        print("TEP Test: Destination requires memo \(destinationAccountId)")
                        XCTAssert(false)
                        expectation.fulfill()
                    case .failure(let error):
                        StellarSDKLog.printHorizonRequestErrorMessage(tag:"TEP Test", horizonRequestError:error)
                        XCTAssert(false)
                    }
                })
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"TEP Test", horizonRequestError:error)
                XCTAssert(false)
            }
        }
        
        wait(for: [expectation], timeout: 25.0)
    }
    
    func testTransactionV1Sign() throws {
        let keyPair = try! KeyPair(secretSeed: "SB2VUAO2O2GLVUQOY46ZDAF3SGWXOKTY27FYWGZCSV26S24VZ6TUKHGE")
        // transaction envelope v1
        let xdr = "AAAAAgAAAADUtWEQOb8u8wqHpML1OV4SV3E5EjliNElgRW2AmJDkaQAAJxAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAEAAAAA1LVhEDm/LvMKh6TC9TleEldxORI5YjRJYEVtgJiQ5GkAAAABAAAAANS1YRA5vy7zCoekwvU5XhJXcTkSOWI0SWBFbYCYkORpAAAAAAAAAAAAAAABAAAAAAAAAAA="

        let envelopeXDR = try! TransactionEnvelopeXDR(xdr: xdr)
        let txHash = try! [UInt8](envelopeXDR.txHash(network: .public))
        envelopeXDR.appendSignature(signature: keyPair.signDecorated(txHash))

        let userSignature = envelopeXDR.txSignatures.first!.signature.base64EncodedString()
        let validUserSignature = "1iw8QognbB+8DmvUTAk0SQSxjpsYqa2pnP9/A7qJwyJ5IPVG+wl4w6M5mHel5CjzsnWKwurE/LCY26Jmz5KiBw=="
          
        print("XDR Envelope: \(envelopeXDR.xdrEncoded!)")
        XCTAssertEqual(validUserSignature, userSignature)
    }

    func testTransactionV1Sign2() throws {
        let keyPair = try! KeyPair(secretSeed: "SB2VUAO2O2GLVUQOY46ZDAF3SGWXOKTY27FYWGZCSV26S24VZ6TUKHGE")
        // transaction envelope v1
        let xdr = "AAAAAgAAAADUtWEQOb8u8wqHpML1OV4SV3E5EjliNElgRW2AmJDkaQAAJxAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAEAAAAA1LVhEDm/LvMKh6TC9TleEldxORI5YjRJYEVtgJiQ5GkAAAABAAAAANS1YRA5vy7zCoekwvU5XhJXcTkSOWI0SWBFbYCYkORpAAAAAAAAAAAAAAABAAAAAAAAAAA="

        let transaction = try! Transaction(envelopeXdr: xdr)
        try! transaction.sign(keyPair: keyPair, network: .public)
        let envelopeXDR = try! TransactionEnvelopeXDR(xdr: transaction.encodedEnvelope())

        let userSignature = envelopeXDR.txSignatures.first!.signature.base64EncodedString()
        let validUserSignature = "1iw8QognbB+8DmvUTAk0SQSxjpsYqa2pnP9/A7qJwyJ5IPVG+wl4w6M5mHel5CjzsnWKwurE/LCY26Jmz5KiBw=="
          
        print("XDR Envelope: \(envelopeXDR.xdrEncoded!)")
        XCTAssertEqual(validUserSignature, userSignature)
    }
    
    func testTransactionSponsoringXDR() throws {
        
        let xdr = "AAAAAgAAAAA0jCzxfXQz6m2qbnLP+65jGoAlFe4iq6PDscyjMQFpaQAtxsAB6r3KAAAB3AAAAAEAAAAAAAAAAAAAAABgJQcCAAAAAAAAAAMAAAABAAAAAB4iR3Mb6J8v89M2SdB9HqBrRdxzyIS66zoSEI3YmXjBAAAAEAAAAACHq6ZMhPkTrMxCxpHMRzP0+x9RiQrWytu63h+8FZ9paAAAAAEAAAAAh6umTIT5E6zMQsaRzEcz9PsfUYkK1srbut4fvBWfaWgAAAAGAAAAAVVTREMAAAAAO5kROA7+mIugqJAOsc/kTzZvfb6Ua+0HckD39iTfFcV//////////wAAAAEAAAAAh6umTIT5E6zMQsaRzEcz9PsfUYkK1srbut4fvBWfaWgAAAARAAAAAAAAAAHYmXjBAAAAQFiyng7KylEQ2YEAL+mmEmPx4V0WipbQy6kuc/RDVjGVsjW45L1FQbGU7eja7gAIsaU0m83xW1eGQn/m1A5RTww="

        let transaction = try Transaction(envelopeXdr: xdr)
        let envelopeXDR = try transaction.encodedEnvelope()
        
        XCTAssertEqual(xdr, envelopeXDR)
    }
    
    func testTransactionSponsoringXDR2() throws {
        
        let xdr = "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"

        let transaction = try Transaction(envelopeXdr: xdr)
        let operations = transaction.operations
        for op in operations {
            if let rsop = op as? RevokeSponsorshipOperation {
                if let ledgerkey = rsop.ledgerKey {
                    switch ledgerkey {
                    case .account(let acc):
                        print(acc.accountID.accountId)
                    default:
                        break
                    }
                }
            }
        }
        let envelopeXDR = try transaction.encodedEnvelope()
        
        XCTAssertEqual(xdr, envelopeXDR)
    }
    
    func testTransactionSponsoringXDR3() throws {
        
        let xdr = "AAAAAgAAAACihyLOUMbcixRy/6eWFjofjp/WvOulrLUSTdifhvbfBwAAASwACEtuAAAAFwAAAAAAAAAAAAAAAwAAAAEAAAAAoocizlDG3IsUcv+nlhY6H46f1rzrpay1Ek3Yn4b23wcAAAAQAAAAAPMed6fp3yGhZYD8Eof0kFShAqGI7iL4T3+Hn/FDiIvQAAAAAAAAAAYAAAABU0tZAAAAAAB+byWqW6fUDTqmlHOBjzkyAptP3jcizGYO/CWH/S5RKQAAABdIdugAAAAAAAAAABEAAAAAAAAAAob23wcAAABAO34o58GqRbKPAUI4fGanjzp10b+H76SNOdWQhBsU9F/LdnapUQmfhJGgd9Y7IqEOrNL9Ht+8T75Q1xfjaJXCAUOIi9AAAABA7pSUP0CRTs+uJStx2W/LvsXBM0AK8pKbeqHLVHLn+cNVWjfxO2whYvqOUewvLcFrZhcqQqfkw6QVP91DfmRFBQ=="

        let transaction = try Transaction(envelopeXdr: xdr)
        let envelopeXDR = try transaction.encodedEnvelope()
        
        XCTAssertEqual(xdr, envelopeXDR)
    }
    
    func testTransactionV0SignWithTwoOperations() throws {
        let keyPair = try! KeyPair(secretSeed: "SB2VUAO2O2GLVUQOY46ZDAF3SGWXOKTY27FYWGZCSV26S24VZ6TUKHGE")
        // transaction envelope v0 with two payment operations
        let xdr = "AAAAANS1YRA5vy7zCoekwvU5XhJXcTkSOWI0SWBFbYCYkORpAAAAyAAAAAAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAABAAAAAE8LpHirFqhklgFS3bqZmOEvg53t/uQ8CFrefQom/uZVAAAAAAAAAAAF9eEAAAAAAAAAAAEAAAAATwukeKsWqGSWAVLdupmY4S+Dne3+5DwIWt59Cib+5lUAAAAAAAAAAAL68IAAAAAAAAAAAA=="
        
        var envelopeXDR = try! TransactionEnvelopeXDR(xdr: xdr)
        switch envelopeXDR {
        case .v0(let txEnvV0):
            // if its a v0 transaction envelope, convert it to a v1 transaction envelope
            let tV0Xdr = txEnvV0.tx
            let pk = try PublicKey(tV0Xdr.sourceAccountEd25519)
            let transactionXdr = TransactionXDR(sourceAccount: pk, seqNum: tV0Xdr.seqNum, timeBounds: tV0Xdr.timeBounds, memo: tV0Xdr.memo, operations: tV0Xdr.operations, maxOperationFee: tV0Xdr.fee / UInt32(tV0Xdr.operations.count) )
            let txV1E = TransactionV1EnvelopeXDR(tx: transactionXdr, signatures: envelopeXDR.txSignatures)
            envelopeXDR = TransactionEnvelopeXDR.v1(txV1E)
        default:
            break
        }
        let txHash = try! [UInt8](envelopeXDR.txHash(network: .public))
        envelopeXDR.appendSignature(signature: keyPair.signDecorated(txHash))

        let userSignature = envelopeXDR.txSignatures.first!.signature.base64EncodedString()
        let validUserSignature = "/x+ipnunmfDID9kX09bmnZOLSG/3Cwld0zgHzpgN6vNAQ4ebrcnALv8hwvVlS5IFY6wKRacWBM0gA9eSd68/CQ=="
          
        print("XDR Envelope: \(envelopeXDR.xdrEncoded!)")
        XCTAssertEqual(validUserSignature, userSignature)
    }
    
    func testCoSignTransactionEnvelope2() {
        
        let seed = "SB2VUAO2O2GLVUQOY46ZDAF3SGWXOKTY27FYWGZCSV26S24VZ6TUKHGE"
        let keyPair = try! KeyPair(secretSeed: seed)
        
        let transaction = "AAAAAgAAAADUtWEQOb8u8wqHpML1OV4SV3E5EjliNElgRW2AmJDkaQAAJxAAAAAAAAAAAQAAAAAAAAAAAAAAAQAAAAEAAAAA1LVhEDm/LvMKh6TC9TleEldxORI5YjRJYEVtgJiQ5GkAAAABAAAAANS1YRA5vy7zCoekwvU5XhJXcTkSOWI0SWBFbYCYkORpAAAAAAAAAAAAAAABAAAAAAAAAAA="
        
        let transactionEnvelope = try! TransactionEnvelopeXDR(xdr: transaction)
        let txHash = try! [UInt8](transactionEnvelope.txHash(network: .public))
        transactionEnvelope.appendSignature(signature: keyPair.signDecorated(txHash))

        var encodedEnvelope = try! XDREncoder.encode(transactionEnvelope)
        
        let result = Data(bytes: &encodedEnvelope, count: encodedEnvelope.count).base64EncodedString()
        
        print(result)
        
        XCTAssert(true)
    }

    func testCoSignTransactionEnvelope3() {
        let keyPair = try! KeyPair(secretSeed: "SA6QS22REFMONMF3O7MMUCUVCXQIS6EHC63VY4FIEIF4KGET4BR6UQAI")
        
        let xdr = "AAAAAAZHmUf2xSOqrDLf0wK1KnpKn9gLAyk3Djc7KHL5e2YuAAAAAf//////////AAAAAQAAAABe1CIaAAAAAF7UI0YAAAAAAAAAAQAAAAEAAAAA305u1W+C8ChCMyOCQa/OjrYFXs3VQvneddHTq+p6CqcAAAAKAAAAClZhdWx0IGF1dGgAAAAAAAEAAABANGQ5ZjQ5OWNmMWE5ZTJiM2RkZWUyMWNjZGNmZjQ3MTIzZjgwM2UzNjdmZDYxZmY5Mjc1NGZmMTJhMWNmOWE0ZAAAAAAAAAAB+XtmLgAAAEAidHX75sVl7ZdXrkOL+EX7qskl/9xVMKkXC4lr1zjQQbNZyeO9Sa49BC1ln54k9FFvabWG0RAf7IChg4E7QN8C"
        
        let transaction = try! Transaction(envelopeXdr: xdr)
        try! transaction.sign(keyPair: keyPair, network: .public)
        let xdrEnvelope = try! transaction.encodedEnvelope()
        print(xdrEnvelope)
        
        XCTAssert(true)
        
    }
    
    func testCoSignTransactionEnvelope() {
        let keyPair = try! KeyPair(secretSeed: "SA33GXHR62NBMBH5OZK5JHXR3X7KAANKMVXPIP6VQQO6N5HGKFB66HWR")
        
        let xdr = "AAAAALR6uVN4RmrfW6K8wdmNznPg6i3Q0dFJTu+fC/RccUZQAAABkAAN4SkAAAABAAAAAAAAAAAAAAAEAAAAAAAAAAYAAAABRFNRAAAAAABHB84JGCc/5+R3BOlxDMXPzkRrWjzfWQvocgCZlHVYu3//////////AAAAAAAAAAYAAAABVVNEAAAAAAABxhW5NR6QVXaxvG7fKS5GdaoNNuHlB1wIB+Sdra3GIn//////////AAAAAAAAAAUAAAAAAAAAAAAAAAAAAAABAAAAAQAAAAEAAAACAAAAAQAAAAIAAAABAAAAAgAAAAAAAAABAAAAADcAko3Ije9aGOP0RkukFkQVJtdyFphVAsp/A/iOD8+7AAAAAQAAAAEAAAAAb0vB44BU2bPolZjPxTq49MypRuzHJ9s9aYwS1QoGvoAAAAABAAAAALR6uVN4RmrfW6K8wdmNznPg6i3Q0dFJTu+fC/RccUZQAAAAAURTUQAAAAAARwfOCRgnP+fkdwTpcQzFz85Ea1o831kL6HIAmZR1WLsAAAAAO5rKAAAAAAAAAAABCga+gAAAAEAceq3kjgzL9Hd0ad60WltzntByI1fdBUXp8nmR8V1d5QlEoDcrOHMo73SvpqvW4yfmksM4P4ixS5Pi4VUeboQL"
        
        let transaction = try! Transaction(envelopeXdr: xdr)
        
        try! transaction.sign(keyPair: keyPair, network: .testnet)
        
        let xdrEnvelope = try! transaction.encodedEnvelope()
        print(xdrEnvelope)
        
        XCTAssertTrue(transaction.fee == 400)
        
    }
    
    func testFeeBumpTransactionEnvelopePost() {
        let sourceAccountKeyPair = try! KeyPair(secretSeed: seed)
        
        let expectation = XCTestExpectation(description: "FeeBumpTransaction successfully sent.")
        let destination = "GAQC6DUD2OVIYV3DTBPOSLSSOJGE4YJZHEGQXOU4GV6T7RABWZXELCUT"
        let payerSeed = "SD7F3RYMDHQ6SBMVKONRRQCG4OFCW7HSWPS7CBGH762ZHVA6LC6RR5LD"
        
        
        do {
            let payerKeyPair = try KeyPair(secretSeed: payerSeed)
            
            streamItem = sdk.transactions.stream(for: .transactionsForAccount(account: payerKeyPair.accountId, cursor: "now"))
            streamItem?.onReceive { response in
                switch response {
                case .open:
                    break
                case .response(_, let response):
                    
                    if let fbr = response.feeBumpTransactionResponse, let itr = response.innerTransactionResponse {
                        print("\nfee_bump-transaction: \(fbr.transactionHash)")
                        for signature in fbr.signatures {
                            print("signature: \(signature)")
                        }
                        print("\ninner_transaction: \(itr.transactionHash)")
                        for signature in itr.signatures {
                            print("signature: \(signature)")
                        }
                        print("max_fee: \(itr.maxFee)\n")
                        XCTAssert(true)
                    } else {
                        XCTAssert(false)
                    }
                    expectation.fulfill()
                    self.streamItem?.closeStream()
                    self.streamItem = nil
                case .error(let error):
                    if let horizonRequestError = error as? HorizonRequestError {
                        StellarSDKLog.printHorizonRequestErrorMessage(tag:"SRP Test - destination", horizonRequestError:horizonRequestError)
                    } else {
                        print("Error \(error?.localizedDescription ?? "")")
                    }
                    XCTAssert(false)
                    expectation.fulfill()
                }
            }
            
            sdk.accounts.getAccountDetails(accountId: sourceAccountKeyPair.accountId) { (response) -> (Void) in
                switch response {
                case .success(let accountResponse):
                    do {
                        let paymentOperation = try PaymentOperation(sourceAccountId: sourceAccountKeyPair.accountId,
                                                                destinationAccountId: destination,
                                                                asset: Asset(type: AssetType.ASSET_TYPE_NATIVE)!,
                                                                amount: 1.5)
                        let innerTx = try Transaction(sourceAccount: accountResponse,
                                                          operations: [paymentOperation],
                                                          memo: Memo.none,
                                                          timeBounds:nil)
                        try innerTx.sign(keyPair: sourceAccountKeyPair, network: Network.testnet)
                        
                        self.sdk.accounts.getAccountDetails(accountId: payerKeyPair.accountId) { (response) -> (Void) in
                            switch response {
                            case .success(let accountResponse):
                                do {
                                    let mux = try MuxedAccount(accountId: accountResponse.accountId, sequenceNumber: accountResponse.sequenceNumber, id: 929299292)
                                    let fb = try FeeBumpTransaction(sourceAccount: mux, fee: 200, innerTransaction: innerTx)
                                    
                                    try fb.sign(keyPair: payerKeyPair, network: Network.testnet)
                                    
                                    try self.sdk.transactions.submitFeeBumpTransaction(transaction: fb) { (response) -> (Void) in
                                        switch response {
                                        case .success(let response):
                                            print("SFB Test: FeeBumpTransaction successfully sent. Hash \(response.transactionHash)")
                                            XCTAssert(true)
                                        case .destinationRequiresMemo(let destinationAccountId):
                                            print("SFB Test: Destination requires memo \(destinationAccountId)")
                                            XCTAssert(false)
                                            expectation.fulfill()
                                        case .failure(let error):
                                            StellarSDKLog.printHorizonRequestErrorMessage(tag:"FBT Test", horizonRequestError:error)
                                            XCTAssert(false)
                                            expectation.fulfill()
                                        }
                                    }
                                } catch {
                                    XCTAssert(false)
                                    expectation.fulfill()
                                }
                            case .failure(let error):
                                StellarSDKLog.printHorizonRequestErrorMessage(tag:"FBT Test", horizonRequestError:error)
                                XCTAssert(false)
                                expectation.fulfill()
                            }
                        }
                    } catch {
                        XCTAssert(false)
                        expectation.fulfill()
                    }
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"FBT Test", horizonRequestError:error)
                    XCTAssert(false)
                    expectation.fulfill()
                }
            }
        } catch {
            XCTAssert(false)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 25.0)
    }
    
    
    func testGetFeeBumpTransactionDetails() {
        let expectation = XCTestExpectation(description: "Get transaction details")
        
        sdk.transactions.getTransactionDetails(transactionHash: "5a270b978380f9ac264787bea669eeca523a32ef7b8e1f0f570a207776d33c7b") { (response) -> (Void) in
            switch response {
            case .success(let response):
                if let fbr = response.feeBumpTransactionResponse, let itr = response.innerTransactionResponse {
                    print("\nfee_bump-transaction: \(fbr.transactionHash)")
                    for signature in fbr.signatures {
                        print("signature: \(signature)")
                    }
                    print("\ninner_transaction: \(itr.transactionHash)")
                    for signature in itr.signatures {
                        print("signature: \(signature)")
                    }
                    print("max_fee: \(itr.maxFee)\n")
                    XCTAssert(true)
                } else {
                    XCTAssert(false)
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"GTD Test", horizonRequestError: error)
                XCTAssert(false)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testFeeBumpTransactionV0EnvelopePost() {
        let expectation = XCTestExpectation(description: "FeeBumpTransaction successfully sent.")
        let payerSeed = "SBJUS3LKMADSRXARW2SPALMMVNUKMQRSNJLLJPS7B37L55EUOEAGE42B"
        
        
        do {
            let payerKeyPair = try KeyPair(secretSeed: payerSeed)
            
            streamItem = sdk.transactions.stream(for: .transactionsForAccount(account: payerKeyPair.accountId, cursor: "now"))
            streamItem?.onReceive { response in
                switch response {
                case .open:
                    break
                case .response(_, let response):
                    
                    if let fbr = response.feeBumpTransactionResponse, let itr = response.innerTransactionResponse {
                        print("\nfee_bump-transaction: \(fbr.transactionHash)")
                        for signature in fbr.signatures {
                            print("signature: \(signature)")
                        }
                        print("\ninner_transaction: \(itr.transactionHash)")
                        for signature in itr.signatures {
                            print("signature: \(signature)")
                        }
                        print("max_fee: \(itr.maxFee)\n")
                        XCTAssert(true)
                    } else {
                        XCTAssert(false)
                    }
                    expectation.fulfill()
                    self.streamItem?.closeStream()
                    self.streamItem = nil
                case .error(let error):
                    if let horizonRequestError = error as? HorizonRequestError {
                        StellarSDKLog.printHorizonRequestErrorMessage(tag:"SRP Test - destination", horizonRequestError:horizonRequestError)
                    } else {
                        print("Error \(error?.localizedDescription ?? "")")
                    }
                    XCTAssert(false)
                    expectation.fulfill()
                }
            }
            
           let v0TxEnvelopeXdr = "AAAAAA9dYWYYZPa5mcu1VSiWu4RiF5zXVTOzwT9RiAKFEdsGAAAAZAALar8AAAALAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAEAAAAAD11hZhhk9rmZy7VVKJa7hGIXnNdVM7PBP1GIAoUR2wYAAAABAAAAACAvDoPTqoxXY5he6S5SckxOYTk5DQu6nDV9P8QBtm5FAAAAAAAAAAAA5OHAAAAAAAAAAAGFEdsGAAAAQMuZ7GbtMd/FOU1MYY32W8nXnwLI761iUSDaXA5yVb5tTBIk0pPyiM97XZbl3fDmmKY5gBdItZyls0cxfocHNwE="
            
            let innerTx = try Transaction(envelopeXdr: v0TxEnvelopeXdr)
            
            self.sdk.accounts.getAccountDetails(accountId: payerKeyPair.accountId) { (response) -> (Void) in
                switch response {
                case .success(let accountResponse):
                    do {
                        let mux = try MuxedAccount(accountId: accountResponse.accountId, sequenceNumber: accountResponse.sequenceNumber, id: 929299292)
                        let fb = try FeeBumpTransaction(sourceAccount: mux, fee: 200, innerTransaction: innerTx)
                        
                        try fb.sign(keyPair: payerKeyPair, network: Network.testnet)
                        
                        try self.sdk.transactions.submitFeeBumpTransaction(transaction: fb) { (response) -> (Void) in
                            switch response {
                            case .success(let response):
                                print("SFB Test: FeeBumpTransaction successfully sent. Hash \(response.transactionHash)")
                                XCTAssert(true)
                            case .destinationRequiresMemo(let destinationAccountId):
                                print("SFB Test: Destination requires memo \(destinationAccountId)")
                                XCTAssert(false)
                                expectation.fulfill()
                            case .failure(let error):
                                StellarSDKLog.printHorizonRequestErrorMessage(tag:"FBT Test", horizonRequestError:error)
                                XCTAssert(false)
                                expectation.fulfill()
                            }
                        }
                    } catch {
                        XCTAssert(false)
                        expectation.fulfill()
                    }
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"FBT Test", horizonRequestError:error)
                    XCTAssert(false)
                    expectation.fulfill()
                }
            }
        } catch {
            XCTAssert(false)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 25.0)
    }
    
    func testGetFeeBumpTransactionV0Details() {
        let expectation = XCTestExpectation(description: "Get transaction details")
        
        sdk.transactions.getTransactionDetails(transactionHash: "3ca56013371e58e0259a582f43fc814f00f61a0de24981d7ac9246ee387712ed") { (response) -> (Void) in
            switch response {
            case .success(let response):
                if let fbr = response.feeBumpTransactionResponse, let itr = response.innerTransactionResponse {
                    print("\nfee_bump-transaction: \(fbr.transactionHash)")
                    for signature in fbr.signatures {
                        print("signature: \(signature)")
                    }
                    print("\ninner_transaction: \(itr.transactionHash)")
                    for signature in itr.signatures {
                        print("signature: \(signature)")
                    }
                    print("max_fee: \(itr.maxFee)\n")
                    XCTAssert(true)
                } else {
                    XCTAssert(false)
                }
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"GTD Test", horizonRequestError: error)
                XCTAssert(false)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }

    func testCompareTransactionMemoHash() {
        let expectation = XCTestExpectation(description: "Get right memo")
        sdk.transactions.getTransactionDetails(transactionHash: "d50158208f1b0436d7bf99f8ecc2c15f1933e1bcd1c2a91479e29108c9cba61a") { (response) -> (Void) in
            switch response {
            case .success(let transactionsResponse):
                let memo1 = transactionsResponse.memo!.toXDR().xdrEncoded!
                let memo = try! Memo(hash: "000000000000000000000000000000002fbf727695e5431783cf6cbcef3864e1".data(using: .hexadecimal)!)
                let memo2 = memo!.toXDR().xdrEncoded!
                if memo1 == memo2 {
                    XCTAssert(true)
                } else {
                    XCTAssert(false)
                }
                expectation.fulfill()
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"HMO Test", horizonRequestError: error)
                XCTAssert(false)
            }
        }
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testCompareTransactionMemoHash2() {
        let expectation = XCTestExpectation(description: "Get right memo")
        sdk.transactions.getTransactionDetails(transactionHash: "d50158208f1b0436d7bf99f8ecc2c15f1933e1bcd1c2a91479e29108c9cba61a") { (response) -> (Void) in
            switch response {
            case .success(let transactionsResponse):
                let myHexMemo = "000000000000000000000000000000002fbf727695e5431783cf6cbcef3864e1";
                if let txMemo = try? transactionsResponse.memo?.hexValue(), txMemo == myHexMemo {
                    print ("BINGO!")
                    XCTAssert(true)
                } else {
                   XCTAssert(false)
                }
                expectation.fulfill()
            case .failure(let error):
                StellarSDKLog.printHorizonRequestErrorMessage(tag:"HMO2 Test", horizonRequestError: error)
            }
        }
        wait(for: [expectation], timeout: 15.0)
    }
    
    /*func testTransactionXdrSubmitIssue140() {
        let expectation = XCTestExpectation(description: "submit and parse result")
        let xdrString = "AAAAAgAAAAAzLZ8nl00dWGwmhZ41swmc14jvBRVZNf4HKJZC7Cn7rwADDUAB6XUMAAAIeQAAAAAAAAAAAAAAAgAAAAEAAAAAMy2fJ5dNHVhsJoWeNbMJnNeI7wUVWTX+ByiWQuwp+68AAAANAAAAAVVTRAAAAAAA6KYahh5gr2D4B3PgY0blxyy+Wdyt2jdgjVjvQlEdn9wAAAAAAAZhQgAAAAAzLZ8nl00dWGwmhZ41swmc14jvBRVZNf4HKJZC7Cn7rwAAAAAAAAAAABngLwAAAAEAAAABVVNEQwAAAAA7mRE4Dv6Yi6CokA6xz+RPNm99vpRr7QdyQPf2JN8VxQAAAAEAAAAAMy2fJ5dNHVhsJoWeNbMJnNeI7wUVWTX+ByiWQuwp+68AAAAFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAJbG9ic3RyLmNvAAAAAAAAAAAAAAAAAAAC7Cn7rwAAAEBtbQWhFE9e1z+uCEm/D54NYqSkQXL3kP+pgYYFmTiDNFCm0Bj4mljcPaANvqBGc1Kj/LoRWJh582FR5MAwGcIIAY1PewAAAEA0aWjOGDvgZ3vOreMwoHuuiapX9n4i79Lr3eZPXGmbZON97F46zEkjjqXavkp3TmvjAsEiOr++7hrdrnNXzhoG"
        do {
            let transaction = try Transaction(envelopeXdr:xdrString)
            
            try self.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                switch response {
                case .success(let rep):
                    print("SRP Test: Transaction successfully sent. Hash: \(rep.transactionHash)")
                    expectation.fulfill()
                case .destinationRequiresMemo(let destinationAccountId):
                    print("SRP Test: Destination requires memo \(destinationAccountId)")
                    XCTAssert(false)
                    expectation.fulfill()
                case .failure(let error):
                    StellarSDKLog.printHorizonRequestErrorMessage(tag:"SRP Test", horizonRequestError:error)
                    XCTAssert(false)
                    expectation.fulfill()
                }
            }
            
            let envelopeString = try transaction.encodedEnvelope()
            XCTAssertTrue(xdrString == envelopeString)
        } catch {
            XCTAssertTrue(false)
        }
        
        wait(for: [expectation], timeout: 15.0)
    }*/
}
