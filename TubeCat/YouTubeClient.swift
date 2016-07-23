//
//  YouTubeClient.swift
//  TubeCat
//
//  Created by Leqi Long on 7/9/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

class YouTubeClient: NSObject{
    
    let request: Request
    
    override init(){
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
                
                print("nextPageToken is \(nextPageToken)")
                
                for video in videosArray{
                    
                    var videoInfoDict = [String:AnyObject]()
                    
                    guard let ids = video[YouTubeClient.ResponseKeys.ID] as? [String:AnyObject] else {
                        print("Cannot find keys '\(YouTubeClient.ResponseKeys.ID)' in \(video)")
                        return
                    }
                    
                    guard let videoId = ids[YouTubeClient.ResponseKeys.VideoID] as? String else {
                        print("Cannot find keys '\(YouTubeClient.ResponseKeys.VideoID)' in \(ids)")
                        return
                    }
                    
                    videoInfoDict[ResponseKeys.VideoID] = videoId
                    
                    guard let snippet = video[YouTubeClient.ResponseKeys.Snippet] as? [String:AnyObject] else {
                        print("Cannot find keys '\(YouTubeClient.ResponseKeys.Snippet)' in \(video)")
                        return
                    }
                    
                    guard let title = snippet[YouTubeClient.ResponseKeys.Title] as? String else {
                        print("Cannot find keys '\(YouTubeClient.ResponseKeys.Title)' in \(snippet)")
                        return
                    }
                    
                    videoInfoDict[ResponseKeys.Title] = title
                    
                    guard let description = snippet[YouTubeClient.ResponseKeys.Description] as? String else {
                        print("Cannot find keys '\(YouTubeClient.ResponseKeys.Description)' in \(snippet)")
                        return
                    }
                    
                    videoInfoDict[ResponseKeys.Description] = description
                    
                    guard let thumbnailsDict = snippet[YouTubeClient.ResponseKeys.Thumbnail] as? [String:AnyObject] else {
                        print("Cannot find keys '\(YouTubeClient.ResponseKeys.Thumbnail)' in \(snippet)")
                        return
                    }
                    
                    guard let medResThumbnailDict = thumbnailsDict[YouTubeClient.ResponseKeys.MedResThumbnail] as? [String:AnyObject] else {
                        print("Cannot find keys '\(YouTubeClient.ResponseKeys.MedResThumbnail)' in \(thumbnailsDict)")
                        return
                    }
                    
                    guard let url = medResThumbnailDict[YouTubeClient.ResponseKeys.ThumbnailURL] as? String else {
                        print("Cannot find keys '\(YouTubeClient.ResponseKeys.ThumbnailURL)' in \(medResThumbnailDict)")
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