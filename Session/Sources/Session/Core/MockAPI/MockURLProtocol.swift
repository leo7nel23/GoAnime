//
//  MockURLProtocol.swift
//
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation

class MockURLProtocol: URLProtocol {
    enum Error: Swift.Error, LocalizedError, CustomDebugStringConvertible {
        case missingMockedData(url: String)
        
        var errorDescription: String? {
            return debugDescription
        }
        
        var debugDescription: String {
            switch self {
            case .missingMockedData(let url):
                return "Missing mock for URL: \(url)"
            }
        }
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        Mocker.shared.shouldHandle(for: request)
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let mockAPI = Mocker.shared.mockAPI(for: request),
              let response = HTTPURLResponse(
                url: mockAPI.urlRequest.url!,
                statusCode: mockAPI.response.statusCode,
                httpVersion: nil,
                headerFields: nil
              ) else {
            client?.urlProtocol(self, didFailWithError: Error.missingMockedData(url: request.url!.absoluteString))
            return
        }
        
        let data = mockAPI.response.data.asData()
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
        
        mockAPI.unregisterIfNeed()
        mockAPI.didComplete?()
    }
    
    override func stopLoading() { }
}

