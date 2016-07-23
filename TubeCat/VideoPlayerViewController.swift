//
//  VideoPlayerViewController.swift
//  TubeCat
//
//  Created by Leqi Long on 7/17/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import CoreData

class VideoPlayerViewController: UIViewController {

    @IBOutlet weak var videoPlayerView: YTPlayerView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    var videoId: String?
    var playlistItemId: String?
    var isFavorite = false
    var video: Video?
    var context: NSManagedObjectContext{
        return CoreDataStack.sharedInstance.context
    }
    private let authClient = AuthorizedClient.sharedClient()
    let dataSource = DataSource.sharedClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoPlayerView.loadWithVideoId(videoId!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("View Will Appear!!!!")
        if let video = video{
            authClient.getPlaylists(AuthorizedClient.SubsequentRequests.GetFavoriteVideos){ (videosInfo, nextPageToken, prevPageToken, videoInfo, success, error) in
                self.isFavorite = false
                if let videosInfo = videosInfo{
                    for video in videosInfo{
                        if video[AuthorizedClient.ResponseKeys.VideoId] == self.videoId{
                            self.isFavorite = true
                            self.video?.isFavorite = true
                            self.video?.playlistItemId = video[AuthorizedClient.ResponseKeys.PlaylistItemId]
                            do{
                                try self.context.save()
                            }catch{}
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.favoriteButton.tintColor = (self.isFavorite) ? UIColor.greenColor() : nil
                    }

                }
            }
        }

    }
    
    @IBAction func toggleFavorite(sender: AnyObject) {
        if isFavorite{
            print("isFavorite is \(isFavorite), so we're going to DELETE the video.")
            authClient.getPlaylists(AuthorizedClient.SubsequentRequests.DeleteFavoriteVideo, playlistItemId: video?.playlistItemId) { (videosInfo, nextPageToken, prevPageToken, videoInfo, success, error) in
                if (success != nil){
                    self.video?.isFavorite = false
                    self.video?.user = nil
                    do{
                        try self.context.save()
                    }catch{}
                    self.isFavorite = false
                }else{
                    print(error?.localizedDescription)
                }
            }
        }else{
            print("isFavorite is \(isFavorite), so we're going to ADD the video.")
            authClient.getPlaylists(AuthorizedClient.SubsequentRequests.AddFavoriteVideo, videoId: videoId) { (videosInfo, nextPageToken, prevPageToken, videoInfo, success, error) in
                if let videoInfo = videoInfo{
                    self.isFavorite = true
                    self.video?.isFavorite = true
                    self.video?.playlistItemId = videoInfo[AuthorizedClient.ResponseKeys.PlaylistItemId] as? String
                    self.video?.user = self.dataSource.user
                    
                    print("Added favorite video. Now set self.video?.playlistItemId as \(self.video?.playlistItemId)!!!!!!!!")
                    
                    do{
                        try self.context.save()
                    }catch{}
                }else{
                    print(error?.localizedDescription)
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.favoriteButton.tintColor = (self.isFavorite) ? UIColor.greenColor() : nil
        }

        
    }
    
    
}
