//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by Özgür Ersöz on 5.12.2020.
//

import Foundation

protocol NetworkManagerProtocol {
    func loadData<ResponseModel: Decodable>(
        fromRequest urlRequest: APIRequestProtocol,
        responseModel: ResponseModel.Type,
        then handler: @escaping (Result<ResponseModel, NetworkError>) -> Void
    ) -> CancelableRequestProtocol
}

public class NetworkManager: NetworkManagerProtocol, CancelableRequestProtocol {
    private var session: URLSessionProtocol
    private var dataTask: URLSessionDataTask?
    
    public init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    @discardableResult
    public func loadData<ResponseModel: Decodable>(
        fromRequest urlRequest: APIRequestProtocol,
        responseModel: ResponseModel.Type,
        then handler: @escaping (Result<ResponseModel, NetworkError>) -> Void
    ) -> CancelableRequestProtocol {
        do {
            let request = try urlRequest.request()
            
            let task = session.dataTask(with: request) { (result) in
                switch result {
                case .failure(let error):
                    handler(.failure(.genericError(error.localizedDescription)))
                case .success((let data, let response)):
                    do {
                        let decodedData = try self.decode(data, to: responseModel.self)
                        handler(.success(decodedData))
                    } catch {
                        handler(.failure(.genericError(error.localizedDescription)))
                    }
                    
                }
            }
            self.dataTask = task
            task.resume()
        } catch {
            handler(.failure(.invalidURL))
        }
        
        return self
    }
    
    private func decode<T: Decodable>(_ data: Data, to type: T.Type) throws -> T {
        do {
            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode(type.self, from: data)
            return decodedObject
        } catch {
            throw NetworkError.invalidJsonData
        }
    }
    
    public func cancel() {
        if let dataTask = dataTask {
            dataTask.cancel()
        }
    }
}

public enum NetworkError: Error {
    case invalidJsonData
    case genericError(_ message: String)
    case invalidURL
}


public protocol CancelableRequestProtocol {
    func cancel()
}
