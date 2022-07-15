//
//  Session.swift
//
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation
import Combine

public class Session {
    public static let shared: Session = Session()
    private init() {}
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func request<T>(
        _ parameter: T,
        decoder: JSONDecoder = JSONDecoder()
    ) -> AnyPublisher<T.Response, Error> where T: SessionParameterProtocol {
        do {
            return session
                .dataTaskPublisher(for: try parameter.asURLRequest())
                .tryMap({ element -> Data in
                    guard let httpResponse = element.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        let code = (element.response as? HTTPURLResponse)?.statusCode
                        throw SesssionError.responseError(.badServerResponse(code))
                    }
                    return element.data
                })
                .decode(type: T.Response.self, decoder: decoder)
                .eraseToAnyPublisher()
        } catch {
            return Fail(outputType: T.Response.self, failure: error)
                .eraseToAnyPublisher()
        }
    }
}

fileprivate extension SessionParameterProtocol {
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: path) else {
            throw SesssionError.requestError(.invalidURL(path))
        }
        
        var request = URLRequest(url: url)
        try request.adapted(with: self)
        return request
    }
}
