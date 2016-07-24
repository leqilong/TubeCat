//
//  VideosTableViewController.swift
//  TubeCat
//
//  Created by Leqi Long on 7/9/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import CoreData

class VideosTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
 
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
        
        configure()
        
        if (category.loadedVideos == false){
            getVideos(category!, token: nil)
        }
        executeSearch()
        tableView.reloadData()

    }
    
    func configure(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
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
                        video.thumbnail = NSData(contentsOfURL: NSURL(string: url)!)
                        video.text = description
                        video.category = self.category
                }
                
                if let nextPageToken = nextPageToken{
                    self.category.nextPageToken = nextPageToken
                }
                
                if let prevPageToken = prevPageToken{
                    self.category.prePageToken = prevPageToken
                }
                
                do{
                    try self.context.save()
                }catch{}
                
            }else{
                print(error?.localizedDescription)
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
        prepareForNewPage()
        getVideos(category!, token: category.prePageToken)
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
        
        let vid = fetchedResultsController.objectAtIndexPath(indexPath) as! Video

        cell.videoTitleLabel.text = vid.title
        cell.thumbnailImageView.image = UIImage(data: vid.thumbnail!)
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
    //MARK: NSFetchedResultsControllerDelegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        let set = NSIndexSet(index: sectionIndex)
        
        switch(type){
        case .Insert:
            self.tableView.insertSections(set, withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(set, withRowAnimation: .Fade)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch (type) {
        case .Update:
            //print("Update object: \(newIndexPath)")
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Insert:
            //print("Insert object : \(newIndexPath)")
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            //print("Delete object: \(newIndexPath)")
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
        tableView.endUpdates()
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
