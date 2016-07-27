//
//  YouTubeClient.swift
//  TubeCat
//
//  Created by Leqi Long on 7/9/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

class YouTubeClient{
    
    let request: Request
    
    init(){
        let url = URLComponents(scheme: Constants.ApiScheme, host: Constants.ApiHost, path: Constants.ApiPath)
        request = Request(url: url)
    }
    
    func getVideosByCategory(categoryId: String?, token: String? = nil, language: String? = nil, completionHandler: (videosInfo: [[String:AnyObject]]?, nextPageToken: String?, prevPageToken: String?, error: NSError?) -> Void){
        var parameters = [String:AnyObject]()
        if let categoryId = categoryId{
            parameters = [
                ParameterKeys.Part: ParameterValues.Snippet,
                ParameterKeys.ResultsType: ParameterValues.VideosType,
                ParameterKeys.Category: categoryId,
                ParameterKeys.Language: LanguagesParameterValues.English,
                ParameterKeys.MaxResults: ParameterValues.NumberOfResults,
                ParameterKeys.APIKey: ParameterValues.APIKey
            ]
        }
        
        if let token = token{
            parameters[ParameterKeys.PageToken] = token
        }
        request.taskForAnyMethod(Methods.Search, paramaters: parameters, requestMethod: .GET) { (result, error) in
            if let result = result{
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(result, options: .AllowFragments) as! [String:AnyObject]
                var desiredVideosInfo = [[String:AnyObject]]()
                
                /* GUARD: Is "items" key in our result? */
                guard let videosArray = parsedResult[ResponseKeys.Items] as? [[String:AnyObject]] else {
                    self.displayError("Cannot find keys '\(ResponseKeys.Items)' in \(parsedResult)")
                    return
                }
                
                guard let nextPageToken = parsedResult[ResponseKeys.NextPageToken] as? String else{
                    self.displayError("All of the results has been shown.")
                    return
                }
                
                for video in videosArray{
                    
                    var videoInfoDict = [String:AnyObject]()
                    
                    guard let ids = video[ResponseKeys.ID] as? [String:AnyObject] else {
                        print("Cannot find keys '\(ResponseKeys.ID)' in \(video)")
                        return
                    }
                    
                    guard let videoId = ids[ResponseKeys.VideoID] as? String else {
                        print("Cannot find keys '\(ResponseKeys.VideoID)' in \(ids)")
                        return
                    }
                    
                    videoInfoDict[ResponseKeys.VideoID] = videoId
                    
                    guard let snippet = video[ResponseKeys.Snippet] as? [String:AnyObject] else {
                        print("Cannot find keys '\(ResponseKeys.Snippet)' in \(video)")
                        return
                    }
                    
                    guard let title = snippet[ResponseKeys.Title] as? String else {
                        print("Cannot find keys '\(ResponseKeys.Title)' in \(snippet)")
                        return
                    }
                    
                    videoInfoDict[ResponseKeys.Title] = title
                    
                    guard let description = snippet[ResponseKeys.Description] as? String else {
                        print("Cannot find keys '\(ResponseKeys.Description)' in \(snippet)")
                        return
                    }
                    
                    videoInfoDict[ResponseKeys.Description] = description
                    
                    guard let thumbnailsDict = snippet[ResponseKeys.Thumbnail] as? [String:AnyObject] else {
                        print("Cannot find keys '\(ResponseKeys.Thumbnail)' in \(snippet)")
                        return
                    }
                    
                    guard let medResThumbnailDict = thumbnailsDict[ResponseKeys.MedResThumbnail] as? [String:AnyObject] else {
                        print("Cannot find keys '\(ResponseKeys.MedResThumbnail)' in \(thumbnailsDict)")
                        return
                    }
                    
                    guard let url = medResThumbnailDict[ResponseKeys.ThumbnailURL] as? String else {
                        print("Cannot find keys '\(ResponseKeys.ThumbnailURL)' in \(medResThumbnailDict)")
                        return
                    }
                    
                    videoInfoDict[ResponseKeys.ThumbnailURL] = url
                    
                    desiredVideosInfo.append(videoInfoDict)
                    
                }
                
                if let prevPageToken = parsedResult[ResponseKeys.PrePageToken] as? String{
                    completionHandler(videosInfo: desiredVideosInfo, nextPageToken: nextPageToken, prevPageToken:prevPageToken, error: nil)
                }else{
                    self.displayError("This is the first page!")
                    completionHandler(videosInfo: desiredVideosInfo, nextPageToken: nextPageToken, prevPageToken:nil, error: nil)
                }
            }else{
                self.displayError("There's an error with your request: \(error)")
                completionHandler(videosInfo: nil, nextPageToken: nil, prevPageToken: nil, error: error)
            }
        }
    }
    
    
    func searchByKeywords(keywords: String?, resultType: String?, channelId: String? = nil, token: String?, completionHandler: (resultsInfo: [[String:AnyObject]]?, nextPageToken: String?, prevPageToken: String?, error: NSError?) -> Void){
        var parameters = [String:AnyObject]()
        if let keywords = keywords,
            let resultType = resultType{
            parameters = [
                ParameterKeys.Part: ParameterValues.Snippet,
                ParameterKeys.ResultsType: resultType,
                ParameterKeys.SearchTerm: keywords,
                ParameterKeys.MaxResults: 50,
                ParameterKeys.APIKey: ParameterValues.APIKey
            ]
        }
        
        if let channelId = channelId,
            let resultType = resultType{
            parameters = [
                ParameterKeys.Part: ParameterValues.Snippet,
                ParameterKeys.ResultsType: resultType,
                ParameterKeys.MaxResults: 50,
                ParameterKeys.ChannelId: channelId,
                ParameterKeys.APIKey: ParameterValues.APIKey
            ]
        }
        
        if let token = token{
            parameters[ParameterKeys.PageToken] = token
        }
        
        request.taskForAnyMethod(Methods.Search, paramaters: parameters, requestMethod: .GET) { (result, error) in
            if let result = result{
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(result, options: .AllowFragments) as! [String:AnyObject]
                var desiredResultsInfo = [[String:AnyObject]]()

                /* GUARD: Is "items" key in our result? */
                guard let resultsArray = parsedResult[ResponseKeys.Items] as? [[String:AnyObject]] else {
                    self.displayError("Cannot find keys '\(ResponseKeys.Items)' in \(parsedResult)")
                    return
                }
                
                for result in resultsArray{
                    
                    var resultInfoDict = [String:AnyObject]()
                    
                    guard let ids = result[ResponseKeys.ID] as? [String:AnyObject] else {
                        print("Cannot find keys '\(ResponseKeys.ID)' in \(result)")
                        return
                    }

                    if resultType == ParameterValues.VideosType{
                        guard let videoId = ids[ResponseKeys.VideoID] as? String else {
                            print("Cannot find keys '\(ResponseKeys.VideoID)' in \(ids)")
                            return
                        }
                        
                        resultInfoDict[ResponseKeys.VideoID] = videoId
                    }else{
                        guard let channelId = ids[ResponseKeys.ChannelID] as? String else {
                            print("Cannot find keys '\(ResponseKeys.ChannelID)' in \(ids)")
                            return
                        }
                        
                        resultInfoDict[ResponseKeys.ChannelID] = channelId
                    }
                    
                    guard let snippet = result[ResponseKeys.Snippet] as? [String:AnyObject] else {
                        print("Cannot find keys '\(ResponseKeys.Snippet)' in \(result)")
                        return
                    }
                    
                    guard let title = snippet[ResponseKeys.Title] as? String else {
                        print("Cannot find keys '\(ResponseKeys.Title)' in \(snippet)")
                        return
                    }
                    
                    resultInfoDict[ResponseKeys.Title] = title
                    
                    guard let description = snippet[ResponseKeys.Description] as? String else {
                        print("Cannot find keys '\(ResponseKeys.Description)' in \(snippet)")
                        return
                    }
                    
                    resultInfoDict[ResponseKeys.Description] = description
                    
                    guard let thumbnailsDict = snippet[ResponseKeys.Thumbnail] as? [String:AnyObject] else {
                        print("Cannot find keys '\(ResponseKeys.Thumbnail)' in \(snippet)")
                        return
                    }
                    
                    guard let medResThumbnailDict = thumbnailsDict[ResponseKeys.MedResThumbnail] as? [String:AnyObject] else {
                        print("Cannot find keys '\(ResponseKeys.MedResThumbnail)' in \(thumbnailsDict)")
                        return
                    }
                    
                    guard let url = medResThumbnailDict[ResponseKeys.ThumbnailURL] as? String else {
                        print("Cannot find keys '\(ResponseKeys.ThumbnailURL)' in \(medResThumbnailDict)")
                        return
                    }
                    
                    resultInfoDict[ResponseKeys.ThumbnailURL] = url
                    
                    desiredResultsInfo.append(resultInfoDict)
                }
                
                if let nextPageToken = parsedResult[ResponseKeys.NextPageToken] as? String,
                    let prevPageToken = parsedResult[ResponseKeys.PrePageToken] as? String{
                    completionHandler(resultsInfo: desiredResultsInfo, nextPageToken: nextPageToken, prevPageToken: prevPageToken, error: nil)
                }else if let nextPageToken = parsedResult[ResponseKeys.NextPageToken] as? String{
                    completionHandler(resultsInfo: desiredResultsInfo, nextPageToken: nextPageToken, prevPageToken: nil, error: nil)
                }else if let prevPageToken = parsedResult[ResponseKeys.PrePageToken] as? String{
                    completionHandler(resultsInfo: desiredResultsInfo, nextPageToken: nil, prevPageToken:prevPageToken, error: nil)
                }else{
                    completionHandler(resultsInfo: desiredResultsInfo, nextPageToken: nil, prevPageToken: nil, error: nil)
                }
            }else{
                print(error?.localizedDescription)
                completionHandler(resultsInfo: nil, nextPageToken: nil, prevPageToken: nil, error: error)
            }
        }
        
        

    }
    
    //MARK: Singleton
    private static var sharedInstance = YouTubeClient()
    
    class func sharedClient() -> YouTubeClient {
        return sharedInstance
    }

    
    // MARK: error status
    func displayError(error: String){
        print(error)
    }
    
}