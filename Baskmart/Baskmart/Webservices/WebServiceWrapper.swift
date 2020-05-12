//
//  WebServiceWrapper.swift
//  ZUPER PRO
//
//  Created by Sabari on 1/9/19.
//  Copyright © 2019 APPLE. All rights reserved.
//

import Foundation
/// Webservice Wrapper
public struct WebServiceWrapper {
    
    //1 creating the session
    let session: URLSession
    
    
    /// Session configuration
    /// - Parameter configuration: URLSessionConfiguration
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    
    /// init with default configuration
    init() {
        self.init(configuration: .default)
    }
    
    typealias JSON = [String: AnyObject]
    typealias JSONTaskCompletionHandler = (Result<JSON>) -> ()
    
    
    /// Get Api
    /// - Parameters:
    ///   - url: pass URL
    ///   - accesToken: access token
    ///   - completion: Get api resonse from server
    func jsonGetTask(url:URL ,accesToken: String?, completionHandler completion: @escaping JSONTaskCompletionHandler) {
        
        var request = URLRequest(url: url)
        if let token = accesToken
        {
            request.setValue("\(token)", forHTTPHeaderField: "X-Auth-Token")
        }
        self.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session.configuration.urlCache = nil
        var task = URLSessionDataTask()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            task = self.session.dataTask(with: request) { (data, response, error) in
                
                DispatchQueue.main.async(execute: {
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(.Error(.requestFailed))
                        return
                    }
                    
                    if httpResponse.statusCode == 200 {
                        
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.Success(json))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                    }
                    else if httpResponse.statusCode == 400 || httpResponse.statusCode == 401
                    {
                        
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.ApiError(json as! [String : String]))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                    }
                    else {
                        completion(.Error(.responseUnsuccessful))
                        print("\(String(describing: error))")
                    }
                })
            }
            task.resume()
        }
    }
    
    /// Post Api
    /// - Parameters:
    ///   - url: pass url
    ///   - accesToken: access token
    ///   - postData: post dict
    ///   - method: methods - POST/PUT/DELETE
    ///   - completion: Get api resonse from server
    func jsonPostTask(url:URL ,accesToken: String?,postData:[String:Any],method:String, completionHandler completion: @escaping JSONTaskCompletionHandler)  {
        
        var request = URLRequest(url: url)
        if let token = accesToken
        {
            request.setValue("\(token)", forHTTPHeaderField: "X-Auth-Token")
        }
        
        request.httpMethod = method
        self.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session.configuration.urlCache = nil
        if postData.count > 0
        {
            let jsonData = try? JSONSerialization.data(withJSONObject: postData)
            request.httpBody = jsonData
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var task = URLSessionDataTask()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            task = self.session.dataTask(with: request) { (data, response, error) in
                
                DispatchQueue.main.async(execute: {
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(.Error(.requestFailed))
                        return
                    }
                    
                    if httpResponse.statusCode == 200 {
                        
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.Success(json))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                    }
                    else if httpResponse.statusCode == 400 ||  httpResponse.statusCode == 401
                    {
                        
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.ApiError(json as! [String : String]))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                    }
                    else if (httpResponse.statusCode == NSURLErrorCancelled || httpResponse.statusCode == NSURLErrorTimedOut || httpResponse.statusCode == NSURLErrorCannotConnectToHost || httpResponse.statusCode == NSURLErrorNetworkConnectionLost || httpResponse.statusCode == NSURLErrorNotConnectedToInternet || httpResponse.statusCode == NSURLErrorInternationalRoamingOff || httpResponse.statusCode == NSURLErrorCallIsActive || httpResponse.statusCode == NSURLErrorDataNotAllowed)
                    {
                        completion(.Error(.offline))
                    }
                    else {
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.ApiError(json as [String : Any]))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                    }
                })
            }
            task.resume()
        }
        
        
    }
    
    
    /// Image Uplaod api
    /// - Parameters:
    ///   - url: Url string
    ///   - imageData: image data as type Data
    ///   - accesToken: access token
    ///   - postData: post dict
    ///   - method: methods - POST/PUT/DELETE
    ///   - fileName: image name
    ///   - type: type
    ///   - completion: get api resonse from server
    func uploadImage(url:URL,imageData:Data,accesToken: String?,postData:[String:Any]?,method:String,fileName:String,type:String, completionHandler completion: @escaping JSONTaskCompletionHandler)  {
        
        var request = URLRequest(url: url)
        if let token = accesToken
        {
            request.setValue("\(token)", forHTTPHeaderField: "X-Auth-Token")
        }
        
        request.httpMethod = method
        
        
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = NSMutableData()
        let fname = fileName
        let mimetype = type
        //define the data post parameter
        
        if postData != nil
        {
            for (key, value) in postData! {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"attachment\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("attachment\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"attachment\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = body as Data
        
        
        var task = URLSessionDataTask()
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            task = self.session.dataTask(with: request) { (data, response, error) in
                
                DispatchQueue.main.async(execute: {
                    guard let httpResponse = response as? HTTPURLResponse else {
                        completion(.Error(.requestFailed))
                        return
                    }
                    
                    if httpResponse.statusCode == 200 {
                        
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.Success(json))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                    }
                    else if httpResponse.statusCode == 400 || httpResponse.statusCode == 401 || httpResponse.statusCode == 404
                    {
                        
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.ApiError(json as! [String : String]))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                    }
                    else if (httpResponse.statusCode == NSURLErrorCancelled || httpResponse.statusCode == NSURLErrorTimedOut || httpResponse.statusCode == NSURLErrorCannotConnectToHost || httpResponse.statusCode == NSURLErrorNetworkConnectionLost || httpResponse.statusCode == NSURLErrorNotConnectedToInternet || httpResponse.statusCode == NSURLErrorInternationalRoamingOff || httpResponse.statusCode == NSURLErrorCallIsActive || httpResponse.statusCode == NSURLErrorDataNotAllowed)
                    {
                        completion(.Error(.offline))
                    }
                        
                    else {
                        
                        
                        if let data = data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                                    DispatchQueue.main.async {
                                        completion(.ApiError(json))
                                    }
                                }
                            } catch {
                                completion(.Error(.jsonConversionFailure))
                            }
                        } else {
                            completion(.Error(.invalidData))
                        }
                      //  completion(.Error(.responseUnsuccessful))
                        print("\(String(describing: error))")
                    }
                })
            }
            task.resume()
        }
    }
    
    
    /// Get Resonse as Data from api
    /// - Parameters:
    ///   - postData: Post DIct
    ///   - method: type
    ///   - accesToken: access token
    ///   - url: url
    ///   - completion: Get resonse from api
    func downloadData(postData:[String:Any]?,method:String,accesToken: String?,url: URL, completion: @escaping (_ data: Data?) -> Void)
    {
        var request = URLRequest(url: url)
        if let token = accesToken
        {
            request.setValue("\(token)", forHTTPHeaderField: "X-Auth-Token")
        }
        
        request.httpMethod = method
        self.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session.configuration.urlCache = nil
        if let postJson = postData
        {
            let jsonData = try? JSONSerialization.data(withJSONObject: postJson)
            request.httpBody = jsonData
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var task = URLSessionDataTask()
        task = self.session.dataTask(with: request) {(data, response, error) in
            DispatchQueue.main.async(execute: {
                if data != nil
                {
                    if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode
                    {
                        completion(data)
                    }
                    else
                    {
                        completion(nil)
                    }
                }
                else
                {
                    completion(nil)
                }
            })
        }
        task.resume()
    }
}


/// Webservice Completion result type
public enum Result <T>{
    case Success(T)
    case Error(ApiResponseError)
    case ApiError([String:Any])
}

//Api error from Response
public enum ApiResponseError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case invalidURL
    case jsonParsingFailure
    case offline
    
}





