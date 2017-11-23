//
//  WebServiceClass.swift
//  ProviDesk
//
//  Created by Omkar Awate on 19/09/17.
//  Copyright © 2017 Omkar Awate. All rights reserved.
//

import UIKit
import SwiftyJSON

let Base_Url = "https://api.simplysmart.tech" as String


class WebServiceClass: NSObject{
    
    let configuration = URLSessionConfiguration.default
    
    let type = ""
    
    //    MARK: - Login API
    func WebAPI_For_Login(_ ApiName: String, Body: String, RequestType: String, callback: @escaping (NSDictionary) -> ()){
        
        let session = URLSession(configuration: configuration)
        let data = Body.data(using: String.Encoding.utf8)
        let urlString = NSString(format: "%@/%@",Base_Url,ApiName);
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.url = URL(string: NSString(format: "%@", urlString)as String)
        request.httpMethod = RequestType
        request.timeoutInterval = 20
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/vnd.botsworth.v2+json", forHTTPHeaderField: "Accept")
        request.httpBody  = data
        var dataTask = URLSessionDataTask()
        dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            do {
                if((data) != nil)
                {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        //  print(jsonResult)
                        DispatchQueue.main.async(execute: {
                            callback(jsonResult)
                        })
                    }
                }else
                {
                    let Dict: NSMutableDictionary? = NSMutableDictionary()
                    Dict?.setValue("Something went wrong", forKey: "Error")
                    callback(Dict!)
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
                let Dict: NSMutableDictionary? = NSMutableDictionary()
                Dict?.setValue("Something went wrong", forKey: "Error")
                callback(Dict!)
            }
        })
        dataTask.resume()
    }
    
    //    MARK: - GET API
    func WebAPI_WithOut_Body(_ ApiName: String, RequestType: String, callback: @escaping (JSON) -> ())
    {
        var apiNameFormatted = ApiName
        let api_key = UserDefaults.standard.string(forKey: "X-Api-Key")! as String
        let auth_token=UserDefaults.standard.string(forKey: "Authorization_token")! as String
        
        let subdomain = UserDefaults.standard.string(forKey: "SubDomain")
        if subdomain != nil {
            if ApiName.contains("?") {
                apiNameFormatted = ApiName + "&subdomain=" + subdomain!
            } else {
                apiNameFormatted = ApiName + "?subdomain=" + subdomain!
            }
        }
        
        let session = URLSession(configuration: configuration)
        let urlString = NSString(format: "%@/%@",Base_Url,apiNameFormatted);
        var request : URLRequest = URLRequest(url: URL(string: NSString(format: "%@", urlString)as String)!)
        //        request.cachePolicy = NSURLRequest.CachePolicy.returnCacheDataDontLoad
        request.httpMethod = RequestType
        request.timeoutInterval = 20
        request.addValue(api_key, forHTTPHeaderField: "X-Api-Key")
        request.addValue(auth_token, forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.botsworth.v1+json", forHTTPHeaderField: "Accept")
        //request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        print("Request is :\(request)")
        
        var dataTask = URLSessionDataTask()
        dataTask = session.dataTask(with: request  as URLRequest, completionHandler: { (data, response, error) in
            do {
                //                print(String(describing: (response as! HTTPURLResponse).allHeaderFields))
                if((data) != nil)
                {
                    let jsonResult :JSON?
                    do{
                        jsonResult = try JSON(data:data!)
                        
                        if (jsonResult != nil) {
                            print(String(describing: jsonResult?.dictionaryValue))
                            DispatchQueue.main.async(execute: {
                                callback(jsonResult!)
                            })
                        }
                    }
                    catch{
                        print("Json Exception :")
                    }
                }
                else
                {
                    let Dict: NSMutableDictionary? = NSMutableDictionary()
                    Dict?.setValue("Something went wrong", forKey: "Error")
                    callback(JSON(Dict ?? NSMutableDictionary()))
                }
                
            }
            //            catch let error as NSError {
            //                print(error.localizedDescription)
            //                let Dict: NSMutableDictionary? = NSMutableDictionary()
            //                Dict?.setValue("Something went wrong", forKey: "Error")
            //                callback(JSON(Dict!))
            //            }
        })
        dataTask.resume()
    }
    
    func WebAPI_WithOut_Body_V2(_ ApiName: String, RequestType: String, callback: @escaping (JSON) -> ())
    {
        var apiNameFormatted = ApiName
        let api_key = UserDefaults.standard.string(forKey: "X-Api-Key")! as String
        let auth_token=UserDefaults.standard.string(forKey: "Authorization_token")! as String
        print("api_key\(api_key)")
        print("auth_token\(auth_token)")
        
        let subdomain = UserDefaults.standard.string(forKey: "SubDomain")
        if subdomain != nil {
            if ApiName.contains("?") {
                apiNameFormatted = ApiName + "&subdomain=" + subdomain!
            } else {
                apiNameFormatted = ApiName + "?subdomain=" + subdomain!
            }
        }
        
        let session = URLSession(configuration: configuration)
        let urlString = NSString(format: "%@/%@",Base_Url,apiNameFormatted);
        var request : URLRequest = URLRequest(url: URL(string: NSString(format: "%@", urlString)as String)!)
        //        request.cachePolicy = NSURLRequest.CachePolicy.returnCacheDataDontLoad
        request.httpMethod = RequestType
        request.timeoutInterval = 20
        request.addValue(api_key, forHTTPHeaderField: "X-Api-Key")
        request.addValue(auth_token, forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.botsworth.v2+json", forHTTPHeaderField: "Accept")
        //request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        print("Request is :\(request)")
        
        var dataTask = URLSessionDataTask()
        dataTask = session.dataTask(with: request  as URLRequest, completionHandler: { (data, response, error) in
            do {
                //                print(String(describing: (response as! HTTPURLResponse).allHeaderFields))
                print("response : \(String(describing: response))")
                if((data) != nil)
                {
                    let jsonResult :JSON?
                    print("data is :\(String(describing: data))")
                    do{
                        jsonResult = try JSON(data:data!)
                        if (jsonResult != nil) {
                            print("Response:\(String(describing: jsonResult?.stringValue))")
                            DispatchQueue.main.async(execute: {
                                callback(jsonResult!)
                            })
                        }
                    }
                    catch{
                        print("Json Exception :")
                    }
                    
                }
                else
                {
                    let Dict: NSMutableDictionary? = NSMutableDictionary()
                    Dict?.setValue("Something went wrong", forKey: "Error")
                    callback(JSON(Dict ?? NSMutableDictionary()))
                }
                
            }
            //            catch let error as NSError {
            //                print(error.localizedDescription)
            //                let Dict: NSMutableDictionary? = NSMutableDictionary()
            //                Dict?.setValue("Something went wrong", forKey: "Error")
            //                callback(JSON(Dict!))
            //            }
        })
        dataTask.resume()
    }
    
    
    
    
    
    
    
    
    //    MARK: - PUT/POST API
    func WebAPI_With_Body(_ ApiName: String, Body: String, RequestType: String, callback: @escaping (JSON) -> ()){
        
        var apiNameFormatted = ApiName
        let subdomain = UserDefaults.standard.string(forKey: "SubDomain")
        if subdomain != nil {
            if ApiName.contains("?") {
                apiNameFormatted = ApiName + "&subdomain=" + subdomain!
            } else {
                apiNameFormatted = ApiName + "?subdomain=" + subdomain!
            }
        }
        
        let session = URLSession(configuration: configuration)
        let urlString = NSString(format: "%@/%@",Base_Url,apiNameFormatted);
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.url = URL(string: NSString(format: "%@", urlString)as String)
        request.httpMethod = RequestType
        request.timeoutInterval = 30
        let body = Body.data(using: String.Encoding.utf8)
        request.httpBody = body
        
        
        
        let api_key = UserDefaults.standard.string(forKey: "X-Api-Key")! as String
        print("api_key : \(api_key)")
        let auth_token=UserDefaults.standard.string(forKey: "Authorization_token")! as String
        print("auth_token : \(auth_token)")
        
        request.addValue(api_key, forHTTPHeaderField: "X-Api-Key")
        request.addValue(auth_token, forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.botsworth.v1+json", forHTTPHeaderField: "Accept")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var dataTask = URLSessionDataTask()
        print("REquest is : \(request)")
        print("Request Body is : \(String(describing: request.httpBody?.description))")
        dataTask = session.dataTask(with: request  as URLRequest, completionHandler: { (data, response, error) in
            do {
                if((data) != nil)
                {
                    let jsonResult :JSON?
                    do{
                        jsonResult = try JSON(data:data!)
                        
                        if (jsonResult != nil) {
                            //  print(jsonResult)
                            DispatchQueue.main.async(execute: {
                                callback(jsonResult!)
                            })
                        }
                    }
                    catch{
                        print("Json Exception :")
                    }
                }else
                {
                    let Dict: NSMutableDictionary? = NSMutableDictionary()
                    Dict?.setValue("Something went wrong", forKey: "Error")
                    callback(JSON(Dict!))
                }
            }
            //            catch let error as NSError {
            //                print(error.localizedDescription)
            //                let Dict: NSMutableDictionary? = NSMutableDictionary()
            //                Dict?.setValue("Something went wrong", forKey: "Error")
            //                callback(JSON(Dict!))
            //            }
        })
        dataTask.resume()
    }
    
    // MARK: - Request Generator
    func clearCachedResponseforURLRequestString(urlString ApiName: String) {
        var apiNameFormatted = ApiName
        let api_key = UserDefaults.standard.string(forKey: "X-Api-Key")! as String
        let auth_token = UserDefaults.standard.string(forKey: "Authorization_token")! as String
        
        let subdomain = UserDefaults.standard.string(forKey: "SubDomain")
        if subdomain != nil {
            if ApiName.contains("?") {
                apiNameFormatted = ApiName + "&subdomain=" + subdomain!
            } else {
                apiNameFormatted = ApiName + "?subdomain=" + subdomain!
            }
        }
        
        let urlString = NSString(format: "%@/%@",Base_Url,apiNameFormatted);
        let url = URL(string: String(format: "%@", urlString))
        var request : URLRequest = URLRequest(url: url!)
        //        request.cachePolicy = NSURLRequest.CachePolicy.returnCacheDataDontLoad
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.addValue(api_key, forHTTPHeaderField: "X-Api-Key")
        request.addValue(auth_token, forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.botsworth.v1+json", forHTTPHeaderField: "Accept")
        let newResponse = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: "1.1", headerFields: ["Cache-Control":"max-age=0"])
        let cachedResponse = CachedURLResponse(response: newResponse!, data: Data())
        URLCache.shared.storeCachedResponse(cachedResponse, for: request)
        //        let response = URLCache.shared.cachedResponse(for: request)?.response as! HTTPURLResponse
        //        print(String(describing : response.allHeaderFields), "SHared cache print is")
    }
}










