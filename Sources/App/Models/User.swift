//
//  User.swift
//  App
//
//  Created by Daniel Skevarp on 2018-01-19.
//

import Vapor
import FluentProvider
import AuthProvider
/**
 Errors that can be thrown by User model
 ````
 case invalidCredentials
 case missingCredentials
 ````
 */
enum UserErrors : Error {
    ///Invalid credentials sent when trying to login
    case invalidCredentials,
    ///No credentials or insuffient credentials sent for login
    missingCredentials
}

struct baseUserData {
    var profileImage : File
    var id : Int
    var username : String
    var email : String
    var firstname : String
    var lastname : String
    var isPrivate : Bool
}

extension User {
    
    private var profilePicture : Int? {
        set {
            self.dataStorage["profilePicture"] = newValue
        }
        get {
            return getDataFor(key: "profilePicture")
        }
    }
    var firstname : String? {
        set(newValue) {
            self.dataStorage["firstname"] = newValue
        }
        get {
            return getDataFor(key: "firstname")
        }
    }
    
    var sessionTimeout : Double? {
        set(newValue) {
            self.dataStorage["sessionTimeout"] = newValue
        }
        get {
            return getDataFor(key: "sessionTimeout")
        }
    }
    
    var username  : String? {
        set(newValue) {
            self.dataStorage["username"] = newValue
        }
        get {
            return getDataFor(key: "username")
        }
    }
    var lastname  : String?{
        set(newValue) {
            self.dataStorage["lastname"] = newValue
        }
        get {
            return getDataFor(key: "lastname")
        }
    }
    var email : String?{
        set(newValue) {
            self.dataStorage["email"] = newValue
        }
        get {
            return getDataFor(key: "email")
        }
    }
    var isPrivate : Int? {
        set(newValue) {
            self.dataStorage["isPrivate"] = newValue
        }
        get {
            return getDataFor(key: "isPrivate")!
        }
    }
    var password : String? {
        set(newValue) {
            self.dataStorage["password"] = newValue
        }
        get {
            return getDataFor(key: "password")
        }
    }
    
    var profileImage : File {
        get {
            guard let fileId = self.profilePicture else {
                let workDir = Config.workingDirectory()
                let file = File.init(name: "defaultProfilePicture", path: "/img/profile/default-avatar.png", absolutePath: "\(workDir)public/img/profile/profile.png", user_id: self.id!, type: .image)
                file.id = 0
                return file
            }
            guard let file = try? File.find(fileId)! else {
                let workDir = Config.workingDirectory()
                let file = File.init(name: "defaultProfilePicture", path: "/img/profile/default-avatar.png", absolutePath: "\(workDir)public/img/profile/default-avatar.png", user_id: self.id!, type: .image)
                file.id = 0
                return file
            }
            
            return file
        }
        set (newValue){
            self.profilePicture = newValue.id?.int
        }
    }
}

final class User : Model, DataStorage {
    var dataStorage = [String : Any]()
    var dataStorageACL = [String : [DataACL]]()
    
    var _password  : Bytes?
    
    func initDatalevels() {
        self.setDataLevel(key: "email", levels: [.row , .json])
        self.setDataLevel(key: "_password", levels: [.priv])
        self.setDataLevel(key: "password", levels: [.priv])
        self.setDataLevel(key: "isPrivate", levels: [.row , .json])
        self.setDataLevel(key: "firstname", levels: [.row , .json])
        self.setDataLevel(key: "username", levels: [.row , .json])
        self.setDataLevel(key: "lastname", levels: [.row , .json])
        self.setDataLevel(key: "profilePicture", level: .row)
        self.setDataLevel(key: "profileImage", level: .json)
        self.setDataLevel(key: "sessionTimeout", levels: [.row, .json])
    }
    
    func getBaseUserData() -> baseUserData {
        let userData = baseUserData.init(profileImage: self.profileImage,
                                         id: self.id!.int!,
                                         username: self.username!,
                                         email: self.email!,
                                         firstname: self.firstname!,
                                         lastname: self.lastname!,
                                         isPrivate: self.isPrivate!.boolValue)
        
        return userData
    }
    
    func setDataLevel(key : String, level : DataACL){
        guard dataStorageACL[key] != nil else {
            dataStorageACL[key] = [level]
            return
        }
        dataStorageACL[key]?.append(level)
    }
    
    func setDataLevel(key : String, levels : [DataACL]){
        for level in levels {
            if let dl = dataStorageACL[key] {
                if !dl.contains(level){
                    dataStorageACL[key]?.append(level)
                }
            }else{
                dataStorageACL[key] = [level]
            }
        }
    }
    
    var storage: Storage = Storage()
   
    /// Set profileImage for user
    func setProfileImage(file _file : File) throws {
        self.profilePicture = _file.id?.int
        try save()
    }
    
    func setProfileImage(id _id : Int) throws {
        self.profilePicture = _id
        try save()
    }
    
    /** Computed property to get firstname + lastname as a single string,
     if first and lastname hasn´t been set, return username */
    var fullname : String {
        get {
            guard let firstname = self.firstname,
                let lastname = self.lastname else {
                    return self.username!
            }
            return "\(firstname) \(lastname)"
        }
    }
    
    /// Create a database row from the object
    func makeRow() throws -> Row {
        var row = Row()
        for data in try getData(level: .row).enumerated() {
            try row.set(data.element.key,data.element.value)
        }
        try row.set("id", self.id)
        try row.set("password", self._password?.makeString())
        return row
    }
    
    init() {
        initDatalevels()
    }
    /// initialize object from database row
    init(row: Row) throws {
        let passwordAsString: String = try row.get("password")
        self._password = passwordAsString.makeBytes()
        id = try row.get("id")
        
        
        for (k,v) in row.object! {
            self.dataStorage[k] = v
         }
        initDatalevels()
    }
    
    init(username: String, email: String, password: String, firstname : String?, lastname : String?) {
        do {
            let hashedPassword = try User.passwordHasher.make(password)
            self.username = username
            self.email = email
            self._password = hashedPassword
            self.password = password
            self.firstname = firstname
            self.lastname = lastname
//            self.isPrivate = 1
//            self.profilePicture = nil
            initDatalevels()
        }catch {
        }
    }
    
    /// Returns if a user is connected to this user
    func isUserRelatedTo(user: User) throws -> Bool {
        for follower in self.followers {
            if try follower.getFollowerUser().id! == user.id! {
                return true
            }
        }
        return false
    }
    
    /// Register new user with all data specified
    static func registerNewUser(username: String, email: String, password: String, firstname: String, lastname: String) throws -> User {
        let newUser = User.init(username: username.lowercased(), email: email.lowercased(), password: password, firstname : firstname, lastname : lastname)
        try newUser.save()
        let user = try User.authenticate(Password.init(username: email.lowercased(), password: password))
        return user
    }
    
    /// Register new user from userPayload - Register
    static func registerNewUser(userData: UserPayloadRegister) throws -> User {
        let newuser = User.init(username: userData.username, email: userData.email, password: userData.password, firstname: userData.firstname, lastname: userData.lastname)
        try newuser.save()
        let user = try User.authenticate(Password.init(username: userData.email.lowercased(), password: userData.password))
        return user
        
    }
    /**
     Login User with Username and Password
     */
    static func loginUser(username : String, password: String) throws -> User {
        
        let passwordCredentials = Password(username: username.lowercased(), password: password)
        
        let user = try User.authenticate(passwordCredentials)
        return user
    }
    
    /**
     Login User with userPayload - Login
     */
    
    static func loginUser(userData : UserPayloadLogin) throws -> User {
        
        let passwordCredentials = Password(username: userData.username.lowercased(), password: userData.password)
        
        let user = try User.authenticate(passwordCredentials)
        
        return user
    }
    
    /**
     Login User with Email and Password
     */
    static func loginUser(email : String, password : String) throws -> User {
        let passwordCredentials = Password(username: email.lowercased(), password: password)
        
        let user = try User.authenticate(passwordCredentials)

        return user
    }
    
    /**
     Get users timeline
 
    */
    func getTimeline() throws -> [timelineResponsePayload]{
        var tl = [timelineResponsePayload]()
        
        let feeds = try self.getTimelineItems(startIndex: 0, numberOfFeeds: 25)
        
        for feed in feeds{
            switch feed.feedType! {
            case .commentAdded:
                break
                
            default :
                break
            }
        }
        
        return tl
    }
    
    
    /**
     Login User with request containing email and password
     
     **Username can be used in the request as long as it is saved in the email data**
     
     */
    static func loginUser(request : Request) throws -> User {
        guard let username = request.data["email"]?.string,
            let password = request.data["password"]?.string else {
                throw UserErrors.missingCredentials
                //return try self.viewFactory.renderView(path: "index", request: request)
        }
        
        let passwordCredentials = Password(username: username.lowercased(), password: password)
        do {
            let user = try User.authenticate(passwordCredentials)
            try request.auth.authenticate(user, persist: true)
            return user
        } catch {
            throw UserErrors.invalidCredentials
        }
    }
    
    
}
