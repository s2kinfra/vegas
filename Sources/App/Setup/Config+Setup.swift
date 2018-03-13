import FluentProvider
import MySQLProvider
import AuthProvider
import Cookies
import Foundation
import Cache
import RedisProvider
import Sessions

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
        
        // Sessions
        let redisCache = try RedisCache.init(config: self)
        
        let redisSessions = SessionsMiddleware(CacheSessions(redisCache)) { req -> Cookie in
            return Cookie(
                name: "vapor-session",
                value: "",
                expires: Date().addingTimeInterval(60 * 60 * 24 * 7), // 7 days
                secure: false,
                httpOnly: true
            )
        }
        let persistMiddleware = PersistMiddleware(User.self)
        
        addConfigurable(middleware: persistMiddleware, name: "persist")
        addConfigurable(middleware: redisSessions, name: "redis")
        
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
        try addProvider(RedisProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(User.self)
        preparations.append(File.self)
        preparations.append(Follow.self)
        preparations.append(Feed.self)
        preparations.append(FeedKeys.self)
        preparations.append(Notification.self)
        preparations.append(NotificationParameterData.self)
        preparations.append(Trip.self)
        preparations.append(Destination.self)
        preparations.append(Comment.self)
        preparations.append(Attachment.self)
    }
}
