//
//  File.swift
//  
//
//  Created by Özgür Ersöz on 10.12.2020.
//

import Foundation

public protocol URLSessionProtocol {
    func dataTask(
        with urlRequest: URLRequest,
        then handler: @escaping (Result<(Data, URLResponse), Error>) -> Void
    ) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {

    public func dataTask(
        with urlRequest: URLRequest,
        then handler: @escaping (Result<(Data, URLResponse), Error>) -> Void
    ) -> URLSessionDataTask {
        
        let task = dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                handler(.failure(error))
            }
            
            guard
                let data = data,
                let response = response
            else {
                let error = NSError(domain: "DATA EMPTY", code: 0, userInfo: nil)
                handler(.failure(error))
                return
            }
            
            handler(.success((data, response)))
            
        }
        
        return task
    }
}
