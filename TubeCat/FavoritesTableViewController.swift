//
//  FavoritesTableViewController.swift
//  TubeCat
//
//  Created by Leqi Long on 7/20/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: CoreDataTableViewController{

    @IBOutlet weak var nextPageButton: UIBarButtonItem!
    @IBOutlet weak var prevPageButton: UIBarButtonItem!
    private let authClient = AuthorizedClient.sharedClient()
    var context: NSManagedObjectContext{
        return CoreDataStack.sharedInstance.context
    }
    
    let dataSource = DataSource.sharedClient()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fr = NSFetchRequest(entityName: "Video")
        fr.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fr.predicate = NSPredicate(format: "user == %@", self.dataSource.user!)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    var nextPageToken: String?
    var prevPageToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        if dataSource.user?.loadedVideos == false {
            print("A new user. loadedVideos is false")
            prepareForNewPage()
            getFavoritesVideos(nil)
        }
        if dataSource.user?.prevPageToken == nil{
            prevPageButton.enabled = false
        }
        
        if dataSource.user?.nextPageToken == nil{
            nextPageButton.enabled = false
        }
        
        executeSearch()
        tableView.reloadData()
        
    }
    
    func getFavoritesVideos(token: String?){
        authClient.getPlaylists(AuthorizedClient.SubsequentRequests.GetFavoriteVideos, token: token){(videosInfo, nextPageToken, prevPageToken, videoInfo, success, error) in
            self.context.performBlock(){
                if let error = error{
                    self.displayError("We're unable to perform your request at the moment. Please try again later")
                }else{
                    if let videosInfo = videosInfo{
                        print("We've got \(videosInfo.count) videos back")
                        for videoInfo in videosInfo{
                            let videoId = videoInfo[AuthorizedClient.ResponseKeys.VideoId]! as String
                            let title = videoInfo[AuthorizedClient.ResponseKeys.Title]! as String
                            let url = videoInfo[AuthorizedClient.ResponseKeys.ThumbnailURL]! as String
                            let description = videoInfo[AuthorizedClient.ResponseKeys.Description]! as String
                            let video = Video(id: videoId, title: title, context: self.context)
                            video.thumbnailURL = url
                            video.isFavorite = true
                            video.user = self.dataSource.user
                            self.dataSource.user?.loadedVideos = true
                        }
                    
                        if let nextPageToken = nextPageToken{
                            self.dataSource.user?.nextPageToken = nextPageToken
                            self.nextPageButton.enabled = true
                        }else{
                            self.dataSource.user?.nextPageToken = nil
                            self.nextPageButton.enabled = false
                        }
                    
                        if let prevPageToken = prevPageToken{
                            self.dataSource.user?.prevPageToken = prevPageToken
                            self.prevPageButton.enabled = true
                        }else{
                            self.dataSource.user?.prevPageToken = nil
                            self.prevPageButton.enabled = false
                        }
                        do{
                            try self.context.save()
                        }catch{}
                    }
                }
            }
        }

    }
    
    func configure(){
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.88, green:0.38, blue:0.21, alpha:1.0)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    
    @IBAction func goToNextPage(sender: AnyObject) {
        prevPageButton.enabled = true
        prepareForNewPage()
        getFavoritesVideos(dataSource.user?.nextPageToken)
        if dataSource.user?.nextPageToken == nil{
            nextPageButton.enabled = false
        }else{
            nextPageButton.enabled = true
        }

    }
    
    @IBAction func goToPrevPage(sender: AnyObject) {
        nextPageButton.enabled = true
        prepareForNewPage()
        getFavoritesVideos(dataSource.user?.prevPageToken)
        if dataSource.user?.prevPageToken == nil{
            prevPageButton.enabled = false
        }else{
            prevPageButton.enabled = true
        }
    }
    
    @IBAction func refresh(sender: AnyObject) {
        prepareForNewPage()
        getFavoritesVideos(nil)
    }
    
    private func prepareForNewPage(){
        if let fetchedResults = fetchedResultsController.fetchedObjects{
            for result in fetchedResults{
                let video = result as! Video
                context.deleteObject(video)
            }
            
            do{
                try self.context.save()
            }catch{}
        }
    }
    
    //MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections{
            print("We have \(sections.count) sections")
            return sections.count
        }else{
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = fetchedResultsController.sections{
            let section = sections[section]
            print("We have \(section.numberOfObjects) objects in 1 section")
            return section.numberOfObjects
            
        }else{
            return 0
        }
    }
    
    //MARK: -UITableViewDelegate methods
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("favoriteCell", forIndexPath: indexPath) as! FavoritesTableViewCell
        cell.backgroundColor = UIColor(red:0.95, green:0.91, blue:0.86, alpha:1.0)
        let vid = fetchedResultsController.objectAtIndexPath(indexPath) as! Video
        cell.thumbnailImageView.image = nil
        cell.thumbnailImageView.backgroundColor = UIColor.clearColor()
        cell.activityIndicator.hidden = false
        cell.activityIndicator.startAnimating()
        
        if let imageData = vid.thumbnail{
            cell.thumbnailImageView.image = UIImage(data: vid.thumbnail!)
            cell.activityIndicator.hidden = true
        }else{
            dispatch_async(dispatch_get_main_queue()) {
                if let imageURL = NSURL(string: vid.thumbnailURL!){
                    if let imageData = NSData(contentsOfURL: imageURL),
                        let image = UIImage(data: imageData){
                        cell.thumbnailImageView.image = image
                        vid.thumbnail = imageData
                        cell.activityIndicator.hidden = true
                        do{
                            try self.context.save()
                        }catch{}
                        
                    }
                }
            }
            
        }
        
        cell.videoTitleLabel.text = vid.title
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vid = fetchedResultsController.objectAtIndexPath(indexPath) as! Video
        
        print("Video ID is \(vid.id)")
        let videoPlayerVC = storyboard!.instantiateViewControllerWithIdentifier("videoPlayer") as! VideoPlayerViewController
        videoPlayerVC.videoId = vid.id!
        videoPlayerVC.video = vid
        self.navigationController?.pushViewController(videoPlayerVC, animated: true)
    }
    


}

extension FavoritesTableViewController{
    func executeSearch(){
        do{
            try fetchedResultsController.performFetch()
        }catch let e as NSError{
            print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
        }
        
    }
}