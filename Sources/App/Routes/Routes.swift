import Vapor
import AuthProvider
import BCrypt

extension Droplet {
    func setupRoutes() throws {
        let routesV1 = RoutesV1.init(drop: self)
        try collection(routesV1)
    }
    
}
