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


typealias Success = (_ data: JSON) -> Void
typealias Failure = (_ responseError: Any?) -> Void

class NetworkManager {
    
    static let provider = MoyaProvider<Dalagram>(plugins: [NetworkLoggerPlugin.init(verbose: true)])
    //static let provider = MoyaProvider<Dalagram>()
    
    static func makeRequest(_ target: Dalagram, success:@escaping Success = { _ in }, failure:@escaping Failure = { _ in }) -> Void {
       
        provider.request(target) { (result) in
            switch result {
            case .success(let response):
                if response.statusCode >= 200 && response.statusCode <= 300 {
                    do {
                        let json = try JSON(data: response.data)
                        print(json)
                        if json["status"].boolValue {
                            success(json)
                        } else {
                            WhisperHelper.showErrorMurmur(title: json["error"].stringValue)
                        }
                    }
                    catch {
                        WhisperHelper.showErrorMurmur(title: "JSON mapping error (Ошибка обработки данных")
                    }
                } else {
                    WhisperHelper.showErrorMurmur(title: "External Server Error (Ошибка загрузки данных)")
                }
            case .failure(let error):
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
