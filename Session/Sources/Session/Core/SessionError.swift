//
//  SessionError.swift
//
//
//  Created by 賴柏宏 on 2022/7/15.
//

import Foundation

public enum SesssionError: Error {
    case requestError(RequestErrorReason)
    case responseError(ResponseErrorReason)
    
    public enum RequestErrorReason {
        case invalidURL(String)
    }
    
    public enum ResponseErrorReason {
        case badServerResponse(Int?)
    }
}
