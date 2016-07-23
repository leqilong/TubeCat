//
//  AuthorizedConstants.swift
//  TubeCat
//
//  Created by Leqi Long on 7/19/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation


extension AuthorizedClient{
    struct Constants{
        static let ApiScheme = "https"
        static let ApiHost = "www.googleapis.com"
        static let ApiPath = "/youtube/v3"
    }
    
    struct Methods{
        static let PlayLists = "/channels"
        static let PlayListItems = "/playlistItems"
        
    }
    
    struct ParameterKeys{
        static let APIKey = "key"
        static let Part = "part"
        static let Mine = "mine"
        static let PlayListId = "playlistId"
        static let MaxResults = "maxResults"
        static let PageToken = "pageToken"
        static let PlaylistItemId = "id"
        static let AccessToken = "access_token"
    }
    
    struct ParameterValues{
        static let APIKey = "AIzaSyC5oisbw05I-UZIU9eH2XdfN9rUUf1n7nY"
        static let Snippet = "snippet"
        static let ContentDetails = "contentDetails"
        static let Status = "status"
        static let Mine = "true"
        static let MaxResults = 20
    }
    
    struct ResponseKeys{
        static let Items = "items"
        static let PlaylistItemId = "id"
        static let Snippet = "snippet"
        static let ContentDetails = "contentDetails"
        static let RelatedPlaylist = "relatedPlaylists"
        static let Favorites = "favorites"
        static let NextPageToken = "nextPageToken"
        static let PrePageToken = "prevPageToken"
        static let VideoId = "videoId"
        static let Title = "title"
        static let Description = "description"
        static let Thumbnail = "thumbnails"
        static let MedResThumbnail = "medium"
        static let ThumbnailURL =  "url"
        
    }
    
    struct JSONBodyKeys{
        static let Snippet = "snippet"
        static let PlayListId = "playlistId"
        static let Kind = "kind"
        static let VideoId = "videoId"
        static let ResourceId = "resourceId"
    }
    
    struct JSONBodyValues{
        static let Kind = "youtube#video"
    }
    
    struct SubsequentRequests{
        static let GetFavoriteVideos = "GetFavoriteVideos"
        static let AddFavoriteVideo = "AddFavoriteVideo"
        static let DeleteFavoriteVideo = "DeleteFavoriteVideo"
    }
}
