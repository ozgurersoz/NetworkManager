//
//  APIRequest.swift
//  NetworkManager
//
//  Created by Özgür Ersöz on 5.12.2020.
//

import Foundation

protocol APIRequestProtocol {
    func request() throws -> URLRequest
    func asURL() -> URL?
}

public typealias HTTPHeaders = [String: String]

class APIRequest<Configuration: NetworkConfiguration>: APIRequestProtocol {
    
    private let method: HTTPMethod
    private let path: String
    private let parameters: [URLQueryItem]?
    private let config = Configuration()
    private let body: Data?
    
    init(
        method: HTTPMethod,
        path: String,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil
    ) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.body = body
    }
    
    func request() throws -> URLRequest {
        guard let url = asURL() else { throw NetworkError.invalidURL }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = 60
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        config.headers?.forEach({ (key, value) in
            urlRequest.addValue(key, forHTTPHeaderField: value)
        })
        
        return urlRequest
    }
    
    func asURL() -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = config.host
        component.path = path
        component.queryItems = parameters
        
        return component.url
    }
}

protocol NetworkConfiguration {
    static var shared: NetworkConfiguration { get }
    var headers: HTTPHeaders? { get }
    var host: String { get }
    init()
}
