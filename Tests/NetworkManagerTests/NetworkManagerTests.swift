import XCTest
@testable import NetworkManager

final class NetworkManagerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
    
    }
    
    
}

class FakeSession: URLSessionProtocol {
    func dataTask(with urlRequest: URLRequest, then handler: @escaping (Result<(Data, URLResponse), Error>) -> Void) -> URLSessionDataTask {
        // JSON DATA
        return URLSessionDataTaskMock {
            let error = NSError(domain: "Fake Error", code: 0, userInfo: ["sik" : "sok"])
            handler(.failure(error))
        }
    }
}

class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    // We override the 'resume' method and simply call our closure
    // instead of actually resuming any task.
    override func resume() {
        closure()
    }
    
    override func cancel() {
        closure()
    }
}

class UsersEndpoint: NetworkConfiguration {
    static var shared: NetworkConfiguration = UsersEndpoint()
    
    required init() {}
    
    var urlComponent: URLComponents {
        var component = URLComponents()
        component.host = "mthost"
        component.scheme = "https"
        return component
    }
    
    var headers: HTTPHeaders?
}


class UserInteractor {
    var networkManager: NetworkManager
    
    var cancelableRequests: [CancelableRequestProtocol]?
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    func getUsers() {
        let networkManager = NetworkManager(session: FakeSession())
        
        let request = APIRequest<UsersEndpoint>(method: .get, path: "")
        
        let task = networkManager.loadData(fromRequest: request, responseModel: FakeModel.self) { result in
            
        }
        
        cancelableRequests?.append(task)
    }
    
    deinit {
        cancelableRequests?.forEach {$0.cancel()}
    }
}


struct FakeModel: Decodable {
    
}
