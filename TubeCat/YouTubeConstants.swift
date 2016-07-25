//
//  YouTubeConstants.swift
//  TubeCat
//
//  Created by Leqi Long on 7/9/16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation

extension YouTubeClient{
    
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "www.googleapis.com"
        static let ApiPath = "/youtube/v3"
    }
    
    struct Methods{
        static let Search = "/search"
        static let Activities = "/activities"
    }
    
    struct ParameterKeys{
        static let APIKey = "key"
        static let Part = "part"
        static let MaxResults = "maxResults"
        static let Language = "relevanceLanguage"
        static let SearchTerm = "q"
        static let ResultsType = "type"
        static let Category = "videoCategoryId"
        static let PageToken = "pageToken"
        static let ChannelId = "channelId"
    }
    
    struct ParameterValues{
        static let APIKey = "AIzaSyC5oisbw05I-UZIU9eH2XdfN9rUUf1n7nY"
        static let Snippet = "snippet"
        static let NumberOfResults = 20  //Allows 0 - 50, default is 5
        static let VideosType = "video"
        static let ChannelsType = "channel"
    }
    
    struct ResponseKeys{
        static let RegionCode = "regionCode"
        static let PageInfo = "pageInfo"
        static let TotalResults = "totalResults"
        static let Items = "items"
        static let ID = "id"
        static let VideoID = "videoId"
        static let ChannelID = "channelId"
        static let Snippet = "snippet"
        static let Title = "title"
        static let Description = "description"
        static let Thumbnail = "thumbnails"
        static let DefaultThumbnail = "default"
        static let HighResThumbnail = "high"
        static let MedResThumbnail = "medium"
        static let ThumbnailURL = "url"
        static let ChannelTitle = "channelTitle"
        static let NextPageToken = "nextPageToken"
        static let PrePageToken = "prevPageToken"
    }
    struct CategoryParameterValues{
        static let Films = "1"
        static let Music = "10"
        static let Animals = "15"
        static let Sports = "17"
        static let ShortFilms = "18"
        static let Travel = "19"
        static let Gaming = "20"
        static let PeopleAndBlogs = "22"
        static let Comedy = "23"
        static let Entertainment = "24"
        static let Politics = "25"
        static let Style = "26"
        static let Education = "27"
        static let Science = "28"
        static let Trailers = "44"
        static let Nonprofit = "29"
        static let Anime = "31"
        static let Documentary = "35"
        static let Classics = "33"
        static let Auto = "2"
        static let Movies = "30"
        static let SciFi = "40"
        static let Shows = "43"
        
    }
    struct LanguagesParameterValues{
        static let Arabic = "ar"
        static let Chinese = "zh"
        static let German = "de"
        static let English = "en"
        static let French = "fr"
        static let Hindi = "hi"
        static let Japanese = "ja"
        static let Korean = "ko"
    }

}