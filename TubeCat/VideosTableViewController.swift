//
//  VideosTableViewController.swift
//  TubeCat
//
//  Created by Leqi Long on 7/9/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import CoreData

class VideosTableViewController: CoreDataTableViewController{
    
 
    @IBOutlet weak var nextPageButton: UIBarButtonItem!
   
    @IBOutlet weak var previousPageButton: UIBarButtonItem!
    
    //MARK: properties
    private let youtubeClient = YouTubeClient.sharedClient()
    var context: NSManagedObjectContext{
        return CoreDataStack.sharedInstance.context
    }
    var category: Category!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fr = NSFetchRequest(entityName: "Video")
        fr.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fr.predicate = NSPredicate(format: "category == %@", self.category)
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
        
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure()
        
        if (category.loadedVideos == false){
            getVideos(category!, token: nil)
        }
        
        if category.prePageToken == nil{
            previousPageButton.enabled = false
        }
        
        if category.nextPageToken == nil{
            nextPageButton.enabled = false
        }
        
        executeSearch()
        tableView.reloadData()

    }
    
//    func configure(){
//        tableView.delegate = self
//        tableView.dataSource = self
//    }
    
    
    func getVideos(category: Category, token: String?){
        
        category.loadedVideos = true
        if let token = token{
            category.currentPageToken = token
        }
        
        youtubeClient.getVideosByCategory(category.id, token: token) { (videosInfo, nextPageToken, prevPageToken, error) in
            self.context.performBlock(){
            if let videosInfo = videosInfo{
                print("We've got \(videosInfo.count) videos back")
                for videoInfo in videosInfo{
                        let videoId = videoInfo[YouTubeClient.ResponseKeys.VideoID] as! String
                        let title = videoInfo[YouTubeClient.ResponseKeys.Title] as! String
                        let url = videoInfo[YouTubeClient.ResponseKeys.ThumbnailURL] as! String
                        let description = videoInfo[YouTubeClient.ResponseKeys.Description] as! String
                        let video = Video(id: videoId, title: title, context: self.context)
                        video.thumbnailURL = url
                        video.text = description
                        video.category = self.category
                }
                
                if let nextPageToken = nextPageToken{
                    self.category.nextPageToken = nextPageToken
                    self.nextPageButton.enabled = true
                }else{
                    self.category.nextPageToken = nil
                    self.nextPageButton.enabled = false
                }
                
                if let prevPageToken = prevPageToken{
                    self.category.prePageToken = prevPageToken
                    self.previousPageButton.enabled = true
                }else{
                     self.category.prePageToken = nil
                     self.previousPageButton.enabled = false
                }
                
                do{
                    try self.context.save()
                }catch{}
                
            }else{
                print(error?.localizedDescription)
                self.displayError("We're unable to perform your request at this moment. Please try again later")
            }
         }
       }
    }

    @IBAction func nextPagePressed(sender: AnyObject) {
        previousPageButton.enabled = true 
        prepareForNewPage()
        getVideos(category!, token: category.nextPageToken)
    }
    
    
    @IBAction func previousPagePressed(sender: AnyObject) {
        nextPageButton.enabled = true
        prepareForNewPage()
        getVideos(category!, token: category.prePageToken)
    }

    
    @IBAction func refresh(sender: AnyObject) {
        prepareForNewPage()
        getVideos(category!, token: nil)
    }
    
    private func prepareForNewPage(){
        if let fetchedResults = fetchedResultsController.fetchedObjects{
            print("We've got \(fetchedResults.count) fetchedResults")
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("videoCell", forIndexPath: indexPath) as! VideoTableViewCell
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
        cell.videoDescriptionLabel.text  = vid.text

        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vid = fetchedResultsController.objectAtIndexPath(indexPath) as! Video
        
        //print("Video ID is \(vid.id)")
        let videoPlayerVC = storyboard!.instantiateViewControllerWithIdentifier("videoPlayer") as! VideoPlayerViewController
        videoPlayerVC.videoId = vid.id!
        videoPlayerVC.video = vid
        self.navigationController?.pushViewController(videoPlayerVC, animated: true)
    }
}

extension VideosTableViewController{
    func executeSearch(){
            do{
                try fetchedResultsController.performFetch()
                //tableView.reloadData()
            }catch let e as NSError{
            print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        
    }
}
