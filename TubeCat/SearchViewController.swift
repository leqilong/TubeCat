//
//  SearchViewController.swift
//  TubeCat
//
//  Created by Leqi Long on 7/24/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchSegmentContent: UISegmentedControl!
    @IBOutlet weak var waitView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var channelsArray = [[String:AnyObject]]()
    var videosArray = [[String:AnyObject]]()
    private let youtubeClient = YouTubeClient.sharedClient()
    var prevPageToken: String?
    var nextPageToken: String?
    
    var context: NSManagedObjectContext{
        return CoreDataStack.sharedInstance.context
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure(){
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        searchTextField.delegate = self
        waitView.hidden = true 
    }
    
    
    
    @IBAction func changeSegmentContent(sender: AnyObject) {
        
        waitView.hidden = false
        
        performSearch(searchTextField.text, channelId: nil, pageToken: nil)
        
        searchResultsTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)

    }
    
    //MARK: -UITableViewDataSource methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchSegmentContent.selectedSegmentIndex == 0{
            return channelsArray.count
        }else{
            return videosArray.count
        }
    }
    
    
    //MARK: -UITableViewDelegate methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if searchSegmentContent.selectedSegmentIndex == 0{
            cell = tableView.dequeueReusableCellWithIdentifier("channelCell", forIndexPath: indexPath)
            
            let channelThumbnailImageView = cell.viewWithTag(1) as! UIImageView
            let channelTitleLabel = cell.viewWithTag(2) as! UILabel
            let channelDescriptionLabel = cell.viewWithTag(3) as! UILabel
            
            let channelInfo = self.channelsArray[indexPath.row]
            
            dispatch_async(dispatch_get_main_queue()) {
                
            let image = UIImage(data: NSData(contentsOfURL: NSURL(string: channelInfo[YouTubeClient.ResponseKeys.ThumbnailURL] as! String)!)!)
            channelThumbnailImageView.image = image?.rounded
                
            channelTitleLabel.text = channelInfo[YouTubeClient.ResponseKeys.Title] as? String
            
            channelDescriptionLabel.text = channelInfo[YouTubeClient.ResponseKeys.Description] as? String
            }
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("videoResultCell", forIndexPath: indexPath)
            
            let videoThumbnailImageView = cell.viewWithTag(1) as! UIImageView
            let videoTitleLabel = cell.viewWithTag(2) as! UILabel
            let videoDescriptionLabel = cell.viewWithTag(3) as! UILabel
            
            dispatch_async(dispatch_get_main_queue()) {
                let videoInfo = self.videosArray[indexPath.row]
                videoThumbnailImageView.image = UIImage(data: NSData(contentsOfURL: NSURL(string: videoInfo[YouTubeClient.ResponseKeys.ThumbnailURL] as! String)!)!)
                videoTitleLabel.text = videoInfo[YouTubeClient.ResponseKeys.Title] as? String
                videoDescriptionLabel.text = videoInfo[YouTubeClient.ResponseKeys.Description] as? String
            }
            
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchSegmentContent.selectedSegmentIndex == 0{
            searchSegmentContent.selectedSegmentIndex = 1
            waitView.hidden = false
            videosArray.removeAll(keepCapacity: false)
            let channelId = channelsArray[indexPath.row][YouTubeClient.ResponseKeys.ChannelID] as? String
            performSearch(nil, channelId: channelId, pageToken: nil)

        }else{
            let videoId = videosArray[indexPath.row][YouTubeClient.ResponseKeys.VideoID] as? String
            let videoTitle = videosArray[indexPath.row][YouTubeClient.ResponseKeys.Title] as? String
            let video = Video(id: videoId!, title: videoTitle!, context: self.context)
            video.thumbnail = NSData(contentsOfURL: NSURL(string: (videosArray[indexPath.row][YouTubeClient.ResponseKeys.ThumbnailURL] as? String)!)!)
            do{
                try self.context.save()
            }catch{}
            let videoPlayerVC = storyboard!.instantiateViewControllerWithIdentifier("videoPlayer") as! VideoPlayerViewController
            videoPlayerVC.videoId = videoId
            videoPlayerVC.video = video
            self.navigationController?.pushViewController(videoPlayerVC, animated: true)
        }
    }
    
    //MARK: -UITextFieldDelegate methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        waitView.hidden = false
        
        if searchTextField.text != ""{
            performSearch(searchTextField.text, channelId: nil, pageToken: nil)
        }else{
            waitView.hidden = true
        }
        
        return true
        
    }
    
    
    func performSearch(keywords: String?, channelId: String?, pageToken: String?)->Void{
        
        var resultType = YouTubeClient.ParameterValues.ChannelsType
        channelsArray.removeAll(keepCapacity: false)
        
        if searchSegmentContent.selectedSegmentIndex == 1{
            resultType = YouTubeClient.ParameterValues.VideosType
            videosArray.removeAll(keepCapacity: false)
        }
        
        youtubeClient.searchByKeywords(keywords, resultType: resultType, channelId: channelId, token: pageToken){ (resultsInfo, nextPageToken, prevPageToken, error) in
                var resultDetailDict = [String:AnyObject]()
                //var videoDetailDict: [String:AnyObject]?
                dispatch_async(dispatch_get_main_queue()) {
                    if let resultsInfo = resultsInfo{
                        for result in resultsInfo{
                            
                            resultDetailDict[YouTubeClient.ResponseKeys.Title] = result[YouTubeClient.ResponseKeys.Title]
                            
                            resultDetailDict[YouTubeClient.ResponseKeys.Description] = result[YouTubeClient.ResponseKeys.Description]
                            
                            resultDetailDict[YouTubeClient.ResponseKeys.ThumbnailURL] = result[YouTubeClient.ResponseKeys.ThumbnailURL]
                            
                            if self.searchSegmentContent.selectedSegmentIndex == 0{
                                resultDetailDict[YouTubeClient.ResponseKeys.ChannelID] = result[YouTubeClient.ResponseKeys.ChannelID]
                                
                                self.channelsArray.append(resultDetailDict)
                            }else{
                                resultDetailDict[YouTubeClient.ResponseKeys.VideoID] = result[YouTubeClient.ResponseKeys.VideoID]
                                
                                self.videosArray.append(resultDetailDict)
                            }
                            
                        }
                        
                        self.searchResultsTableView.reloadData()
                    }else{
                        print(error?.localizedDescription)
                    }
                    
                    self.waitView.hidden = true
                }
            }
        
    }
    
}

