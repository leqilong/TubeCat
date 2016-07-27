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
    @IBOutlet weak var titleLabel: UILabel!
    
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
        
        titleLabel.text = video?.title
        videoPlayerView.loadWithVideoId(videoId!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = video{
            authClient.getPlaylists(AuthorizedClient.SubsequentRequests.GetFavoriteVideos, token: nil){ (videosInfo, nextPageToken, prevPageToken, videoInfo, success, error) in
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
                    self.favoriteButton.imageView!.image = self.favoriteButton.imageView!.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    if self.isFavorite{
                        self.favoriteButton.tintColor = UIColor.redColor()
                    }else{
                        self.favoriteButton.tintColor = UIColor.blackColor()
                    }
                  }
            
                }
            }
        }

    }
    
    @IBAction func toggleFavorite(sender: AnyObject) {
        if isFavorite{
            self.isFavorite = false
            authClient.getPlaylists(AuthorizedClient.SubsequentRequests.DeleteFavoriteVideo, token: nil, playlistItemId: video?.playlistItemId) { (videosInfo, nextPageToken, prevPageToken, videoInfo, success, error) in
                if (success != nil){
                    self.video?.isFavorite = false
                    self.video?.user = nil
                }else{
                    self.displayError("We're unable to perform your request at the moment. Please try again later")
                }
            }
        }else{
            self.isFavorite = true
            authClient.getPlaylists(AuthorizedClient.SubsequentRequests.AddFavoriteVideo, token: nil, videoId: videoId) { (videosInfo, nextPageToken, prevPageToken, videoInfo, success, error) in
                if let videoInfo = videoInfo{
                    self.video?.isFavorite = true
                    self.video?.playlistItemId = videoInfo[AuthorizedClient.ResponseKeys.PlaylistItemId] as? String
                    self.video?.user = self.dataSource.user
                }else{
                    print(error?.localizedDescription)
                    self.displayError("We're unable to perform your request at the moment. Please try again later")
                }
            }
        }
        
        do{
            try self.context.save()
        }catch{}

        dispatch_async(dispatch_get_main_queue()) {
            self.favoriteButton.imageView!.image = self.favoriteButton.imageView!.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            if self.isFavorite{
                self.favoriteButton.tintColor = UIColor.redColor()
            }else{
                self.favoriteButton.tintColor = UIColor.blackColor()
            }
        }

        
    }
    
    
}
