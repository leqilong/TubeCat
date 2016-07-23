//
//  Request.swift
//  TubeCat
//
//  Created by Leqi Long on 7/9/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

enum HTTPMethod: String{
    case GET, POST, PUT, DELETE
}

struct URLComponents{
    let scheme: String
    let host: String
    let path: String
}

class Request{
    
    //MARK: Properties
    let session: NSURLSession!
    let url: URLComponents
    
    init(url: URLComponents){
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: config)
        self.url = url
    }
    
    //MARK: Make a generic HTTP request function for any task
    func taskForAnyMethod(method: String, paramaters: [String:AnyObject], requestMethod: HTTPMethod, headers: [String:String]? = nil, jsonBody: [String:AnyObject]? = nil, completionHandler: (result: NSData?, error: NSError?) -> Void){
        /* Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: urlForRequests(method, parameters: paramaters))
        let url = urlForRequests(method, parameters: paramaters)
        request.HTTPMethod = requestMethod.rawValue
        print("requestMethod is \(request.HTTPMethod)!!!!!!")
        
        //print("Request url is: \(url)")
        
        /*add headers, if any*/
//        if let headers = headers {
//            for (key, value) in headers {
//                request.addValue(value, forHTTPHeaderField: key)
//            }
//        }
        /*add body, if any*/
        if let jsonBody = jsonBody{
            print("jsonBody in request.swift is \(jsonBody)!!!!!!")
            
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions())
        }
        
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request){(data, response, error) in
            func displayError(error: String) {
                print(error)
                completionHandler(result: nil, error: self.errorStatus(1, description: error))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else{
                displayError("There was an error with your request: \(error)")
                return
            }
            /* GUARD: did we get a successful response?*/
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode < 299 else{
                displayError("Unsuccessful response: \(response)")
                return
            }
            
            completionHandler(result: data, error: nil)
            
        }
        /* Start the request */
        task.resume()
    }
    
    // MARK: create a URL for making the request URL
    func urlForRequests(method: String, parameters: [String:AnyObject]? = nil) -> NSURL{
        
        let components = NSURLComponents()
        components.scheme = url.scheme
        components.host = url.host
        components.path = url.path + (method ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        if let parameters = parameters{
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
            
        }
    
        return components.URL!
    }
    

    
    // MARK: error status
    func errorStatus(status: Int, description: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: description]
        return NSError(domain: "Response", code: status, userInfo: userInfo)
    }

}