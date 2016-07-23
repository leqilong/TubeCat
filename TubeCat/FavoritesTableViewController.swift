//
//  FavoritesTableViewController.swift
//  TubeCat
//
//  Created by Leqi Long on 7/20/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate{
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()

        authClient.getPlaylists(AuthorizedClient.SubsequentRequests.GetFavoriteVideos){(videosInfo, nextPageToken, prevPageToken, videoInfo, success, error) in
            self.context.performBlock(){
                if let videosInfo = videosInfo{
                    print("We've got \(videosInfo.count) videos back")
                    for videoInfo in videosInfo{
                        let videoId = videoInfo[AuthorizedClient.ResponseKeys.VideoId]! as String
                        let title = videoInfo[AuthorizedClient.ResponseKeys.Title]! as String
                        let url = videoInfo[AuthorizedClient.ResponseKeys.ThumbnailURL]! as String
                        let description = videoInfo[AuthorizedClient.ResponseKeys.Description]! as String
                        let video = Video(id: videoId, title: title, context: self.context)
                        video.thumbnail = NSData(contentsOfURL: NSURL(string: url)!)
                        video.isFavorite = true
                        video.user = self.dataSource.user
                    }
                    do{
                        try self.context.save()
                    }catch{}
                }else{
                    print(error?.localizedDescription)
                }
            }
        }

        executeSearch()
        tableView.reloadData()
        
    }
    
    func configure(){
        tableView.delegate = self
        tableView.dataSource = self
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("favoriteCell", forIndexPath: indexPath) as! FavoritesTableViewCell
        
        let vid = fetchedResultsController.objectAtIndexPath(indexPath) as! Video
        
        cell.videoTitleLabel.text = vid.title
        cell.thumbnailImageView.image = UIImage(data: vid.thumbnail!)

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

extension FavoritesTableViewController{
    func executeSearch(){
        do{
            try fetchedResultsController.performFetch()
            //tableView.reloadData()
        }catch let e as NSError{
            print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
        }
        
    }
}