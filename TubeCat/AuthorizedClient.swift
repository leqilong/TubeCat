//
//  AuthorizedClient.swift
//  TubeCat
//
//  Created by Leqi Long on 7/19/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation


class AuthorizedClient: NSObject{
    
    let request: Request
    
    override init(){
        let url = URLComponents(scheme: Constants.ApiScheme, host: Constants.ApiHost, path: Constants.ApiPath)
        request = Request(url: url)
    }
    
    func getPlaylists(subsequentRequest: String?, token: String?, videoId: String? = nil, playlistItemId: String? = nil, completionHandler: (videosInfo: [[String:String]]?, nextPageToken: String?, prevPageToken: String? , videoInfo: [String:AnyObject]? , success: Bool? , error: NSError?)->Void){
        let parameters: [String:AnyObject] = [
            ParameterKeys.Part:ParameterValues.ContentDetails,
            ParameterKeys.Mine: ParameterValues.Mine,
            ParameterKeys.APIKey:ParameterValues.APIKey,
            ParameterKeys.AccessToken: "\(GIDSignIn.sharedInstance().currentUser.authentication.accessToken)"

        ]

        //var playListId: String?
        request.taskForAnyMethod(Methods.PlayLists, paramaters: parameters, requestMethod: .GET) { (result, error) in
            if let result = result{
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(result, options: .AllowFragments) as! [String:AnyObject]
                
                /* GUARD: Is "items" key in our result? */
                guard let items = parsedResult[ResponseKeys.Items] as? [[String:AnyObject]] else {
                    self.displayError("Cannot find keys '\(ResponseKeys.Items)' in \(parsedResult)")
                    return
                }
                
                guard let contentDetails = items[0][ResponseKeys.ContentDetails] as? [String:AnyObject] else {
                    self.displayError("Cannot find keys '\(ResponseKeys.ContentDetails)' in \(items[0])")
                    return
                }
                
                
                guard let relatedPlaylists = contentDetails[ResponseKeys.RelatedPlaylist] as? [String:AnyObject] else {
                    self.displayError("Cannot find keys '\(ResponseKeys.RelatedPlaylist)' in \(contentDetails)")
                    return
                }
                
                guard let favoritesId = relatedPlaylists[ResponseKeys.Favorites] as? String else {
                    self.displayError("Cannot find keys '\(ResponseKeys.Favorites)' in \(relatedPlaylists)")
                    return
                }
                
                if let subsequentRequest = subsequentRequest{
                    switch(subsequentRequest){
                    case SubsequentRequests.GetFavoriteVideos:
                        self.getFavoritesVideos(favoritesId, token: token){ (videosInfo, nextPageToken, prevPageToken, error) in
                            if let videosInfo = videosInfo,
                                let nextPageToken = nextPageToken,
                                let prevPageToken = prevPageToken{
                                completionHandler(videosInfo: videosInfo, nextPageToken: nextPageToken, prevPageToken: prevPageToken, videoInfo: nil, success: nil, error: nil)
                            }else if let videosInfo = videosInfo,
                                let nextPageToken = nextPageToken{
                                completionHandler(videosInfo: videosInfo, nextPageToken: nextPageToken, prevPageToken: nil, videoInfo: nil, success: nil, error: nil)
                            }else if let videosInfo = videosInfo,
                                        let prevPageToken = prevPageToken{
                                completionHandler(videosInfo: videosInfo, nextPageToken: nil, prevPageToken:prevPageToken, videoInfo: nil, success: nil, error: nil)
                            }else if let videosInfo = videosInfo{
                                completionHandler(videosInfo: videosInfo, nextPageToken: nil, prevPageToken:nil, videoInfo: nil, success: nil, error: nil)
                            }else{
                                completionHandler(videosInfo: nil, nextPageToken: nil, prevPageToken: nil, videoInfo: nil, success: nil, error: error)
                            }
                        }
                    case SubsequentRequests.AddFavoriteVideo:
                        if let videoId = videoId{
                            self.addFavoriteVideo(favoritesId, videoId: videoId) { (videoInfo, error) in
                                if let videoInfo = videoInfo{
                                    completionHandler(videosInfo: nil, nextPageToken: nil, prevPageToken: nil, videoInfo: videoInfo, success: nil, error: nil)
                                }else{
                                    completionHandler(videosInfo: nil, nextPageToken: nil, prevPageToken: nil, videoInfo: nil, success: nil, error: error)
                                }
                            }
                        }
                    case SubsequentRequests.DeleteFavoriteVideo:
                        if let playlistItemId = playlistItemId{
                            self.deleteAVideoFromFavorites(playlistItemId) { (success, error) in
                                if let success = success{
                                    completionHandler(videosInfo: nil, nextPageToken: nil, prevPageToken: nil, videoInfo: nil, success: success, error: nil)
                                }else{
                                    completionHandler(videosInfo: nil, nextPageToken: nil, prevPageToken: nil, videoInfo: nil, success: nil, error: error)
                                }
                            }
                        }
                    default: break
                    }
                }
                
            }else{
                self.displayError((error?.localizedDescription)!)
            }
        }
    }
    
    
    func getFavoritesVideos(playlistId: String?, token: String?, completionHandler: (videosInfo: [[String:String]]?, nextPageToken: String?, prevPageToken: String?, error: NSError?)->Void){
        
        var parameters = [String:AnyObject]()
        
        if let playlistId = playlistId{
            parameters = [
                ParameterKeys.Part: ParameterValues.Snippet + "," + ParameterValues.ContentDetails + "," + ParameterValues.Status,
                ParameterKeys.PlayListId: playlistId,
                ParameterKeys.MaxResults: ParameterValues.MaxResults,
                ParameterKeys.APIKey:ParameterValues.APIKey,
                ParameterKeys.AccessToken: "\(GIDSignIn.sharedInstance().currentUser.authentication.accessToken)"
            ]
        }
        
        if let token = token {
            parameters[ParameterKeys.PageToken] = token
        }
        
        request.taskForAnyMethod(Methods.PlayListItems, paramaters: parameters, requestMethod: .GET){(result, error) in
            if let result = result{
                let parsedResult = try! NSJSONSerialization.JSONObjectWithData(result, options: .AllowFragments) as! [String:AnyObject]
                
                var desiredVideosInfo = [[String:String]]()
                
                
                /* GUARD: Is "items" key in our result? */
                guard let videosArray = parsedResult[ResponseKeys.Items] as? [[String:AnyObject]] else {
                    self.displayError("Cannot find keys '\(ResponseKeys.Items)' in \(parsedResult)")
                    return
                }
                
                for video in videosArray{
                    var videoInfoDict = [String:String]()
                    
                    guard let playlistItemId = video[ResponseKeys.PlaylistItemId] as? String else{
                        print("Cannot find keys '\(ResponseKeys.PlaylistItemId)' in \(video)")
                        return
                    }
                    
                    videoInfoDict[ResponseKeys.PlaylistItemId] = playlistItemId
                    
                    guard let idDict = video[ResponseKeys.ContentDetails] as? [String:AnyObject] else {
                        print("Cannot find keys '\(ResponseKeys.ContentDetails)' in \(video)")
                        return
                    }
                    
                    guard let videoId = idDict[ResponseKeys.VideoId] as? String else{
                        print("Cannot find keys '\(ResponseKeys.VideoId)' in \(idDict)")
                        return

                    }
                    
                    videoInfoDict[ResponseKeys.VideoId] = videoId
                    
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
                        break
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
                
                if let nextPageToken = parsedResult[ResponseKeys.NextPageToken] as? String,
                    let prevPageToken = parsedResult[ResponseKeys.PrePageToken] as? String{
                    completionHandler(videosInfo: desiredVideosInfo, nextPageToken: nextPageToken, prevPageToken:prevPageToken, error: nil)
                }else if let nextPageToken = parsedResult[ResponseKeys.NextPageToken] as? String{
                    print("This is the first page!")
                    completionHandler(videosInfo: desiredVideosInfo, nextPageToken: nextPageToken, prevPageToken:nil, error: nil)
                }else if let prevPageToken = parsedResult[ResponseKeys.PrePageToken] as? String{
                    print("This is the last page!")
                    completionHandler(videosInfo: desiredVideosInfo, nextPageToken: nil, prevPageToken:prevPageToken, error: nil)
                }else{
                    print("This is the only page!")
                    completionHandler(videosInfo: desiredVideosInfo, nextPageToken: nil, prevPageToken:nil, error: nil)
                }
                
            }else{
                self.displayError("There's an error with your request: \(error)")
                completionHandler(videosInfo: nil, nextPageToken: nil, prevPageToken: nil, error: error)
            }
        }
    }
    
    
    func addFavoriteVideo(playlistId: String, videoId: String, completionHandler: (videoInfo: [String:AnyObject]?, error: NSError?)->Void){
        
            let parameter: [String:AnyObject] = [
                ParameterKeys.Part:ParameterValues.Snippet,
                ParameterKeys.APIKey:ParameterValues.APIKey,
                ParameterKeys.AccessToken: "\(GIDSignIn.sharedInstance().currentUser.authentication.accessToken)"
            ]
        
        print("videoId is: \(videoId). And playlistId is \(playlistId)!!!!")
        let jsonBody: [String:AnyObject] = [
            JSONBodyKeys.Snippet: [
                JSONBodyKeys.PlayListId: playlistId,
                JSONBodyKeys.ResourceId: [
                    JSONBodyKeys.Kind: JSONBodyValues.Kind,
                    JSONBodyKeys.VideoId: videoId
                ]
            ]
        ]
//        let jsonString = "json=[{\"str\":\"Hello\",\"num\":1},{\"str\":\"Goodbye\",\"num\":99}]"
            print("And jsonBody is \(jsonBody)")
        
            request.taskForAnyMethod(Methods.PlayListItems, paramaters: parameter, requestMethod: .POST, jsonBody: jsonBody){ (result, error) in
                if let result = result{
                    let parsedResult = try! NSJSONSerialization.JSONObjectWithData(result, options: .AllowFragments) as! [String:AnyObject]
                    
                    var desiredVideoInfo = [String:AnyObject]()
                    
                    guard let playlistItemId = parsedResult[ResponseKeys.PlaylistItemId] as? String else{
                        self.displayError("Cannot find keys '\(ResponseKeys.PlaylistItemId)' in \(parsedResult)")
                        return
                    }
                    
                    desiredVideoInfo[ResponseKeys.PlaylistItemId] = playlistItemId
                    
                    guard let videoDict = parsedResult[ResponseKeys.Snippet] as? [String:AnyObject] else{
                        self.displayError("Cannot find keys '\(ResponseKeys.Snippet)' in \(parsedResult)")
                        return
                    }
                    
                    guard let title = videoDict[ResponseKeys.Title] as? String else{
                        self.displayError("Cannot find keys '\(ResponseKeys.Title)' in \(videoDict)")
                        return
                    }
                    
                    desiredVideoInfo[ResponseKeys.Title] = title
                    
                    guard let thumbnailsDict = videoDict[ResponseKeys.Thumbnail] as? [String:AnyObject] else{
                        self.displayError("Cannot find keys '\(ResponseKeys.Thumbnail)' in \(videoDict)")
                        return
                    }
                    
                    guard let medResThumbnailDict = thumbnailsDict[ResponseKeys.MedResThumbnail] as? [String:AnyObject] else{
                        self.displayError("Cannot find keys '\(ResponseKeys.MedResThumbnail)' in \(thumbnailsDict)")
                        return
                    }
                    
                    guard let url = medResThumbnailDict[ResponseKeys.ThumbnailURL] as? String else {
                        print("Cannot find keys '\(ResponseKeys.ThumbnailURL)' in \(medResThumbnailDict)")
                        return
                    }
                    
                    desiredVideoInfo[ResponseKeys.ThumbnailURL] = url
                    
                    completionHandler(videoInfo: desiredVideoInfo, error: nil)
                    
                }else{
                    print(error?.localizedDescription)
                    completionHandler(videoInfo: nil, error: error)
                }
            }
        
    }
    
    func deleteAVideoFromFavorites(playlistItemId: String, completionHandler: (success: Bool?, error: NSError?) ->Void){
            let parameters: [String:AnyObject] = [
                ParameterKeys.PlaylistItemId:playlistItemId,
                ParameterKeys.APIKey:ParameterValues.APIKey,
                ParameterKeys.AccessToken: "\(GIDSignIn.sharedInstance().currentUser.authentication.accessToken)"
            ]
    
            request.taskForAnyMethod(Methods.PlayListItems, paramaters: parameters, requestMethod: .DELETE){(result, error) in
                if let result = result{
                    completionHandler(success: true, error: nil)
                }else{
                    completionHandler(success: false, error: error)
                }
            }
    }
    
    //MARK: Singleton
    private static var sharedInstance = AuthorizedClient()
    
    class func sharedClient() -> AuthorizedClient {
        return sharedInstance
    }
    
    
    // MARK: error status
    func displayError(error: String){
        print(error)
    }
    
}