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
    case uploadAvatar(Data)
    
    // MARK: - Contacts
    case addContacts([[String: String]])
    case getContacts()
    case removeContact(user_id: Int)
    
    // MARK: - Chat
    case sendMessage([String: Any])
    case getDialogs([String: Any])
    case getDialogDetails([String: Any])
    
    // MARK: - Group
    case createGroup(name: String, users: [[String: Int]], image: Data?)
    case uploadGroupPhoto(group_id: Int, image: Data)
    case editGroup(group_id: Int, group_name: String)
    case getGroups([String: String])
    case getGroupDetails(group_id: Int)
    case getGroupMembers([String: String])
    case addGroupMember(group_id: Int, user_id: Int)
    case removeGroupMember(group_id: Int, user_id: Int)
    case setGroupAdmin(group_id: Int, user_id: Int)
    case declineGroupAdmin(group_id: Int, user_id: Int)
    
    // MARK: - Channel
    case createChannel(name: String, login: String, users: [[String: Int]], image: Data?)
    case uploadChannelPhoto(channel_id: Int, image: Data)
    case editChannel(channel_id: Int, name: String, login: String)
    case getChannels([String: String])
    case getChannelDetails(channel_id: Int)
    case getChannelMembers(channel_id: Int, page: Int, count: Int)
    case addChannelMember(channel_id: Int, user_id: Int)
    case removeChannelMember(channel_id: Int, user_id: Int)
    case setChannelAdmin(channel_id: Int, user_id: Int)
    case declineChannelAdmin(channel_id: Int, user_id: Int)
    
    // MARK: - News
    case getNews([String: String])
    case addNews([String: String])
    case editNews(news_id: Int, [String: String])
    case uploadPhoto(image: Data)
    case removePhoto(imageUrl: String)
    
    // MARK: Push
    case addPushToken([String: String])
    case removePushToken([String: String])
    case sendPushNotification([String: String])
    
    
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
        case .uploadAvatar:
            return "/profile/avatar"
            
        // MARK: - Contacts Path
        case .getContacts, .addContacts, .removeContact:
            return "/contact"
            
        // MARK: - Chat
        case .sendMessage, .getDialogs:
            return "/chat"
        case .getDialogDetails:
            return "/chat/detail"
            
        // MARK: - Group
        case .createGroup, .getGroups:
            return "/group"
        case .uploadGroupPhoto:
            return  "/group/avatar"
        case .editGroup(let group_id, _):
            return "/group/\(group_id)"
        case .getGroupDetails(let group_id):
            return "/group/\(group_id)"
        case .getGroupMembers(let group_id):
            return "/group/user/\(group_id)"
        case .addGroupMember(let group_id, _):
            return "/group/user/\(group_id)"
        case .removeGroupMember(let group_id, _):
            return "/group/user/\(group_id)"
        case .setGroupAdmin(let group_id, _):
            return "/group/admin/\(group_id)"
        case .declineGroupAdmin(let group_id, _):
            return "/group/admin/\(group_id)"
            
        // MARK: - Channel
        case .createChannel, .getChannels:
            return "/channel"
        case .uploadChannelPhoto:
            return "/channel/avatar"
        case .editChannel(let channel_id, _, _):
            return "/channel/\(channel_id)"
        case .getChannelDetails(let channel_id):
            return "/channel/\(channel_id)"
        case .getChannelMembers(let channel_id, _, _):
            return "/channel/user/\(channel_id)"
        case .addChannelMember(let channel_id, _):
            return "/channel/user/\(channel_id)"
        case .removeChannelMember(let channel_id, _):
            return "/channel/user/\(channel_id)"
        case .setChannelAdmin(let channel_id, _):
            return "/channel/admin/\(channel_id)"
        case .declineChannelAdmin(let channel_id, _):
            return "/channel/admin/\(channel_id)"
            
        // MARK: - News
        case .getNews, .addNews:
            return "/news"
        case .editNews(let news_id, _):
            return "/news/\(news_id)"
        case .uploadPhoto, .removePhoto:
            return "/image"
            
        // MARK: Push
        case .addPushToken, .removePushToken:
            return "/push"
        case .sendPushNotification:
            return "/push/send"
            
        }
        
    }
    
    public var method: Moya.Method {
        switch self {
        case .getProfile, .getContacts, .getDialogs, .getDialogDetails, .getGroups, .getGroupDetails,
             .getGroupMembers, .getChannels, .getChannelDetails, .getChannelMembers, .getNews:
            return .get
        case .removePushToken, .removeGroupMember, .declineGroupAdmin, .removeChannelMember,
             .declineChannelAdmin, .removePhoto:
            return .delete
        default:
            return .post
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    public var task: Task {
        switch self {
        
        // MARK: - Auth Params
            
        case .signIn(let phone):
            return .requestParameters(parameters: ["phone" : phone], encoding: URLEncoding.default)
            
        case .confirmAccount(let phone, let code):
            return .requestParameters(parameters: ["phone" : phone, "sms_code": code], encoding: URLEncoding.default)
        
        // MARK: - Profile Params
            
        case .updateProfile(let params):
            return .requestCompositeParameters(bodyParameters: params, bodyEncoding: URLEncoding.httpBody,
                                               urlParameters: ["token" : User.getToken()])
            
        case .getProfile(let user_id):
            var params = ["token" : User.getToken()]
            if let id = user_id {
                params["user_id"] = "\(id)"
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .editProfile(let params):
            return .requestCompositeParameters(bodyParameters: params, bodyEncoding: URLEncoding.httpBody,
                                               urlParameters: ["token" : User.getToken()])
            
        case .uploadAvatar(let data):
            let imgData = MultipartFormData(provider: .data(data), name: "image", fileName: "photo.jpg", mimeType: "image/jpeg")
            return .uploadCompositeMultipart([imgData], urlParameters: ["token" : User.getToken()])
            
        // MARK: - Contacts Params
            
        case .addContacts(let jsonParams):
            return .requestCompositeParameters(bodyParameters:  ["contact_users" : jsonParams], bodyEncoding: JSONEncoding.default, urlParameters: ["token" : User.getToken()])
            
        case .getContacts():
            return .requestParameters(parameters: ["token": User.getToken()], encoding: URLEncoding.default)
            
        // MARK: Messages
        case .sendMessage(let params):
            return .requestCompositeParameters(bodyParameters: params, bodyEncoding: URLEncoding.httpBody,
                                               urlParameters: ["token" : User.getToken()])
            
        case .getDialogs(let params), .getDialogDetails(let params):
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        
        // MARK: Group
        case .createGroup(let groupName, let usersParams, let imageData):
            if let image = imageData {
                let imgData = MultipartFormData(provider: .data(image), name: "image", fileName: "photo.jpg", mimeType: "image/jpeg")
                return .uploadCompositeMultipart([imgData], urlParameters: ["token" : User.getToken(),"group_name": groupName, "group_users": usersParams])
            } else {
                return .requestCompositeParameters(bodyParameters: ["group_name": groupName, "group_users": usersParams], bodyEncoding: JSONEncoding.default, urlParameters: ["token" : User.getToken()])
            }
            
        case .uploadGroupPhoto(let group_id, let imageData):
            let imgData = MultipartFormData(provider: .data(imageData), name: "image", fileName: "group_photo.jpg", mimeType: "image/jpeg")
            return .uploadCompositeMultipart([imgData], urlParameters: ["token" : User.getToken(), "group_id": group_id])
            
        case .editGroup(_, let group_name):
            return .requestCompositeParameters(bodyParameters: ["group_name": group_name], bodyEncoding: URLEncoding.httpBody, urlParameters: ["token" : User.getToken()])
            
        case .getGroupDetails(_):
            return .requestParameters(parameters: ["token": User.getToken()], encoding: URLEncoding.default)
            
        case .setGroupAdmin(_, let user_id), .addGroupMember(_, let user_id):
            return .requestCompositeParameters(bodyParameters: ["user_id": user_id], bodyEncoding: URLEncoding.httpBody, urlParameters: ["token" : User.getToken()])
            
        case .removeGroupMember(let group_id, let user_id), .declineGroupAdmin(let group_id, let user_id):
            return .requestCompositeParameters(bodyParameters: ["group_id": group_id, "user_id": user_id], bodyEncoding: URLEncoding.httpBody, urlParameters: ["token" : User.getToken()])
            
        // MARK: Channel
            
        case .createChannel(let name, let login, let usersParams, let imageData):
            if let image = imageData {
                let imgData = MultipartFormData(provider: .data(image), name: "image", fileName: "photo.jpg", mimeType: "image/jpeg")
                return .uploadCompositeMultipart([imgData], urlParameters: ["token" : User.getToken(),"channel_name": name, "channel_login": login, "channel_users": usersParams])
            } else {
                return .requestCompositeParameters(bodyParameters: ["channel_name": name, "channel_login": login, "channel_users": usersParams], bodyEncoding: JSONEncoding.default, urlParameters: ["token" : User.getToken()])
            }
            
        case .uploadChannelPhoto(let channel_id, let imageData):
            let imgData = MultipartFormData(provider: .data(imageData), name: "image", fileName: "group_photo.jpg", mimeType: "image/jpeg")
            return .uploadCompositeMultipart([imgData], urlParameters: ["token" : User.getToken(), "channel_id": channel_id])
        
        case .editChannel(_, let name, let login):
            return .requestCompositeParameters(bodyParameters: ["is_public": "0", "channel_name": name, "channel_login": login], bodyEncoding: URLEncoding.httpBody, urlParameters: ["token" : User.getToken()])
        
        case .getChannelDetails(_):
            return .requestParameters(parameters: ["token": User.getToken()], encoding: URLEncoding.default)
            
        case .getChannelMembers(_, let page, let count):
            return .requestParameters(parameters: ["token": User.getToken(), "page": page, "per_page": count], encoding: URLEncoding.default)
            
        case .addChannelMember(_, let user_id), .setChannelAdmin(_, let user_id):
            return .requestCompositeParameters(bodyParameters: ["user_id": user_id], bodyEncoding: URLEncoding.httpBody, urlParameters: ["token" : User.getToken()])
            
        case .removeChannelMember(_, let user_id), .declineChannelAdmin(_, let user_id):
            return .requestCompositeParameters(bodyParameters: ["user_id": user_id], bodyEncoding: URLEncoding.httpBody, urlParameters: ["token" : User.getToken()])
            
        default:
            return .requestPlain
        }
    }
        
    public var sampleData: Data {
        return "Default sample data".data(using: String.Encoding.utf8)!
    }
    
}

