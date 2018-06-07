//
//  APITarget.swift
//  Dalagram
//
//  Created by Toremurat on 07.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import Moya

public enum Dalagram {
    
    // MARK: - Auth
    case signIn(phone: String)
    case confirmAccount(phone:String, code: String)
    
    // MARK: - Profile
    case getProfile(user_id: Int?)
    case updateProfile([String: String])
    case editProfile([String: String])
}

extension Dalagram: TargetType {

    public var baseURL: URL { return URL(string: "http://dalagram.bugingroup.com/api")! }
    
    public var path: String {
        
        switch self {
        
        // MARK: - Auth Path
        case .signIn:
            return "/auth/login"
        case .confirmAccount:
            return "/auth/confirm"
            
        // MARK: - Profile Path
        case .getProfile:
            return "/profile"
        case .updateProfile:
            return "/profile"
        case .editProfile:
            return "/profile"
        }
        
    }
    
    public var method: Moya.Method {
        switch self {
        case .getProfile:
            return .get
        default:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        
        // MARK: - Auth Task
            
        case .signIn(let phone):
            return .requestParameters(parameters: ["phone" : phone], encoding: URLEncoding.default)
        case .confirmAccount(let phone, let code):
            return .requestParameters(parameters: ["phone" : phone, "sms_code": code], encoding: URLEncoding.default)
        
        // MARK: - Profile Task
            
        case .updateProfile(let params):
            return .requestCompositeParameters(bodyParameters: params, bodyEncoding: URLEncoding.httpBody, urlParameters: ["token" : User.getToken()])
        case .getProfile(let user_id):
            var params = ["token" : User.getToken()]
            if let id = user_id {
                params["user_id"] = "\(id)"
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .editProfile(let params):
            return .requestCompositeParameters(bodyParameters: params, bodyEncoding: URLEncoding.httpBody, urlParameters: ["token" : User.getToken()])
            
        default:
            return .requestPlain
        }
    }
        
    public var sampleData: Data {
        return "Default sample data".data(using: String.Encoding.utf8)!
    }
    
    public var headers: [String : String]? {
        return nil
    }
}
//            let imgData = MultipartFormData(provider: .data(data), name: "image", fileName: "photo.jpg", mimeType: "image/jpeg")
//            let multipartData = [imgData]
//            return .upload(.multipart(multipartData))
