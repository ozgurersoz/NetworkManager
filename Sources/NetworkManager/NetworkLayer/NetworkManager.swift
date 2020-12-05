//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by Özgür Ersöz on 5.12.2020.
//

import Foundation

class NetworkManager {
    var session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func loadData<ResponseModel: Decodable>(
        fromRequest urlRequest: APIRequestProtocol,
        responseModel: ResponseModel.Type,
        then handler: @escaping (Result<ResponseModel, NetworkError>) -> Void
    ) {
        do {
            let request = try urlRequest.request()
            
            let task = session.dataTask(with: request) { (data, response, error) in
                if let data = data {
                    do {
                        let user = try self.decode(data, to: ResponseModel.self)
                        handler(.success(user))
                    } catch  {
                        handler(.failure(.genericError(error.localizedDescription)))
                    }
                }
            }
            
            task.resume()
        } catch {
            handler(.failure(.invalidURL))
        }
    }
    
    func decode<T: Decodable>(_ data: Data, to type: T.Type) throws -> T {
        do {
            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode(type.self, from: data)
            return decodedObject
        } catch {
            throw NetworkError.invalidJsonData
        }
    }
    
}

enum NetworkError: Error {
    case invalidJsonData
    case genericError(_ message: String)
    case invalidURL
}

