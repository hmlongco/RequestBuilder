//
//  User.swift
//

import Foundation

// MARK: - User
public struct User: Hashable, Identifiable, Codable, Equatable {

    public let id: UUID

    let originalID: UserID
    let name: UserName
    let gender: String?
    let location: UserLocation?
    let email: String?
    let login: UserLogin?
    let dob: UserDOB?
    let phone: String?
    let cell: String?
    let picture: UserPicture?
    let nat: String?

    init(id: UUID, originalID: UserID, name: UserName, gender: String?, location: UserLocation?, email: String?, login: UserLogin?, dob: UserDOB?,
         phone: String?, cell: String?, picture: UserPicture?, nat: String?) {
        self.id = id
        self.originalID = originalID
        self.name = name
        self.gender = gender
        self.location = location
        self.email = email
        self.login = login
        self.dob = dob
        self.phone = phone
        self.cell = cell
        self.picture = picture
        self.nat = nat
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        originalID = try values.decode(UserID.self, forKey: .originalID)
        name = try values.decode(UserName.self, forKey: .name)
        gender = try? values.decode(String.self, forKey: .gender)
        location = try? values.decode(UserLocation.self, forKey: .location)
        email = try? values.decode(String.self, forKey: .email)
        login = try? values.decode(UserLogin.self, forKey: .login)
        dob = try? values.decode(UserDOB.self, forKey: .dob)
        phone = try? values.decode(String.self, forKey: .phone)
        cell = try? values.decode(String.self, forKey: .cell)
        picture = try? values.decode(UserPicture.self, forKey: .picture)
        nat = try? values.decode(String.self, forKey: .nat)

        id = UUID()
    }

    enum CodingKeys: String, CodingKey {
        case originalID = "id"
        case name
        case gender
        case location
        case email
        case login
        case dob
        case phone
        case cell
        case picture
        case nat
    }
}


// MARK: - Dob
public struct UserDOB: Hashable, Codable, Equatable {
    let date: String?
    let age: Int?
}

// MARK: - ID
public struct UserID: Hashable, Codable, Equatable {
    let name: String?
    let value: String?
}

// MARK: - Location
public struct UserLocation: Hashable, Codable, Equatable {
    let street: UserStreet?
    let city: String?
    let state: String?
    let postcode: String?

    enum CodingKeys: String, CodingKey {
        case street
        case city
        case state
        case postcode
    }

    public init(street: UserStreet?, city: String?, state: String?, postcode: String?) {
        self.street = street
        self.city = city
        self.state = state
        self.postcode = postcode
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        street = try values.decode(UserStreet.self, forKey: .street)
        city = try values.decode(String.self, forKey: .city)
        state = try values.decode(String.self, forKey: .state)
        if let value = try? values.decode(Int.self, forKey: .postcode) {
            postcode = "\(value)"
        } else {
            postcode =  try? values.decode(String.self, forKey: .postcode)
        }
    }
}

public struct UserStreet: Hashable, Codable, Equatable {
    let number: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case number
        case name
    }

    public init(number: String?, name: String?) {
        self.number = number
        self.name = name
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(Int.self, forKey: .number) {
            number = "\(value)"
        } else {
            number =  try? values.decode(String.self, forKey: .number)
        }
        name = try values.decode(String.self, forKey: .name)
    }
}

// MARK: - Login
public struct UserLogin: Hashable, Codable, Equatable {
    let uuid: String?
    let username: String?
    let password: String?
    let salt: String?
    let md5: String?
    let sha1: String?
    let sha256: String?
}

// MARK: - Name
public struct UserName: Hashable, Codable, Equatable {
    let title: String?
    let first: String
    let last: String
}

// MARK: - Picture
public struct UserPicture: Hashable, Codable, Equatable {
    let large: String?
    let medium: String?
    let thumbnail: String?
}

// MARK: - API Result Type
public struct UserResultType: Decodable {
    let results: [User]
}

// MARK: - Helpers
extension User {
    public var fullname: String {
        return name.first + " " + name.last
    }
}

// MARK: - MOCKS
extension User {
    
    static var users = [mockTS, mockJQ] // deliberately provided out of sort order

    static var mockJQ: User {
        return User(
            id: UUID(),
            originalID: UserID(name: "21", value: "21"),
            name: UserName(title: "Mr.", first: "Jonny", last: "Quest"),
            gender: "M",
            location: UserLocation(street: UserStreet(number: "123", name: "East West"), city: "Quest Headquarters", state: "FL", postcode: "32808"),
            email: "jquest@quest.com",
            login: nil,
            dob: nil,
            phone: "303-555-8888",
            cell: nil,
            picture: UserPicture(large: "User-JQ", medium: "User-JQ", thumbnail: "User-JQ"),
            nat: "US"
        )
    }

    static var mockTS: User {
        return User(
            id: UUID(),
            originalID: UserID(name: "22", value: "22"),
            name: UserName(title: "Mr.", first: "Tom", last: "Swift"),
            gender: "M",
            location: nil,
            email: "tomswift@swiftenterprises.com",
            login: nil,
            dob: UserDOB(date: nil, age: 17),
            phone: "402-555-9999",
            cell: nil,
            picture: nil,
            nat: "US"
        )
    }

}
