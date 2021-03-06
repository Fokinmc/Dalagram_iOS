//
//  APIProvider.swift
//  Dalagram
//
//  Created by Toremurat on 07.06.18.
//  Copyright © 2018 BuginGroup. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import SwiftyJSON
import SVProgressHUD

typealias Success = (_ data: JSON) -> Void
typealias Failure = (_ responseError: JSON) -> Void

class NetworkManager {
    
    //static let provider = MoyaProvider<Dalagram>(plugins: [NetworkLoggerPlugin.init(verbose: true)])
    static let provider = MoyaProvider<Dalagram>()
    
    static func makeRequest(_ target: Dalagram, success: @escaping Success = { _ in }, failure: @escaping Failure = { _ in }) -> Void {
        provider.request(target) { (result) in
            switch result {
            case .success(let response):
                print(response.statusCode)
                if response.statusCode >= 200 && response.statusCode <= 300 {
                    do {
                        var json = try JSON(data: response.data)
                        print(json)
                        if json["status"].boolValue {
                            success(json)
                            SVProgressHUD.dismiss()
                        } else {
                            failure(json)
                            SVProgressHUD.dismiss()
                            WhisperHelper.showErrorMurmur(title: json["error"].stringValue)
                        }
                    }
                    catch {
                        SVProgressHUD.dismiss()
                        WhisperHelper.showErrorMurmur(title: "JSON mapping error (Ошибка обработки данных")
                    }
                } else {
                    SVProgressHUD.dismiss()
                    WhisperHelper.showErrorMurmur(title: "External Server Error (Ошибка загрузки данных)")
                }
            case .failure(let error):
                SVProgressHUD.dismiss()
                WhisperHelper.showErrorMurmur(title: error.localizedDescription)
            }
        }
        
    }
    
    private func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data // fallback to original data if it can't be serialized.
        }
    }
    
}
extension Moya.Response {
    func mapNSArray() throws -> NSArray {
        let any = try self.mapJSON()
        guard let array = any as? NSArray else {
            throw MoyaError.jsonMapping(self)
        }
        return array
    }
}
