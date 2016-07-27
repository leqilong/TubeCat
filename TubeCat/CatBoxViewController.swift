//
//  CatBoxViewController.swift
//  TubeCat
//
//  Created by Leqi Long on 7/11/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import SceneKit
import CoreData

class CatBoxViewController: UIViewController, UIPopoverPresentationControllerDelegate, BoxesPickerViewControllerDelegate{
    
    
   //MARK: -data source for setting up each face of the box
    
    enum CategoryInfo{
        
        var context: NSManagedObjectContext{
            return CoreDataStack.sharedInstance.context
        }
        
        case Animals, Auto, TVShows, Movies, Comedy, Documentary, Education, Entertainment, Films, Gaming, Music, Nonprofit, PeopleBlogs, Politics, Science, ShortFilms, Sports, Style, Trailers, Travel
        var url: String{
            switch self{
            case Animals: return "TubeCat.scnassets/Textures/Animals.png"
            case Auto: return "TubeCat.scnassets/Textures/Auto.png"
            case TVShows: return "TubeCat.scnassets/Textures/TVShows.png"
            case Movies: return "TubeCat.scnassets/Textures/Movies.png"
            case Comedy: return "TubeCat.scnassets/Textures/Comedy.png"
            case Documentary: return "TubeCat.scnassets/Textures/Documentary.png"
            case Education: return "TubeCat.scnassets/Textures/Education.png"
            case Entertainment: return "TubeCat.scnassets/Textures/Entertainment.png"
            case Films: return "TubeCat.scnassets/Textures/Trailers.png"
            case Gaming: return "TubeCat.scnassets/Textures/Gaming.png"
            case Music: return "TubeCat.scnassets/Textures/Music.png"
            case Nonprofit: return "TubeCat.scnassets/Textures/Nonprofit.png"
            case PeopleBlogs: return "TubeCat.scnassets/Textures/PeopleBlogs.png"
            case Politics: return "TubeCat.scnassets/Textures/Politics.png"
            case Science: return "TubeCat.scnassets/Textures/Science.png"
            case ShortFilms: return "TubeCat.scnassets/Textures/ShortFilms.png"
            case Sports: return "TubeCat.scnassets/Textures/Sports.png"
            case Style: return "TubeCat.scnassets/Textures/Style.png"
            case Trailers: return "TubeCat.scnassets/Textures/Trailers.png"
            case Travel: return "TubeCat.scnassets/Textures/Travel.png"
            }
        }
        
        var category: Category{
            switch self{
            case Animals: return Category(id: YouTubeClient.CategoryParameterValues.Animals, context: context)
            case Auto: return Category(id: YouTubeClient.CategoryParameterValues.Auto, context: context)
            case TVShows: return Category(id: YouTubeClient.CategoryParameterValues.Shows, context: context)
            case Movies: return Category(id: YouTubeClient.CategoryParameterValues.Movies, context: context)
            case Comedy: return Category(id: YouTubeClient.CategoryParameterValues.Comedy, context: context)
            case Documentary: return Category(id: YouTubeClient.CategoryParameterValues.Documentary, context: context)
            case Education: return Category(id: YouTubeClient.CategoryParameterValues.Education, context: context)
            case Entertainment: return Category(id: YouTubeClient.CategoryParameterValues.Entertainment, context: context)
            case Films: return Category(id: YouTubeClient.CategoryParameterValues.Films, context: context)
            case Gaming: return Category(id: YouTubeClient.CategoryParameterValues.Gaming, context: context)
            case Music: return Category(id: YouTubeClient.CategoryParameterValues.Music, context: context)
            case Nonprofit: return Category(id: YouTubeClient.CategoryParameterValues.Nonprofit, context: context)
            case PeopleBlogs: return Category(id: YouTubeClient.CategoryParameterValues.PeopleAndBlogs, context: context)
            case Politics: return Category(id: YouTubeClient.CategoryParameterValues.Politics, context: context)
            case Science: return Category(id: YouTubeClient.CategoryParameterValues.Science, context: context)
            case ShortFilms: return Category(id: YouTubeClient.CategoryParameterValues.ShortFilms, context: context)
            case Sports: return Category(id: YouTubeClient.CategoryParameterValues.Sports, context: context)
            case Style: return Category(id: YouTubeClient.CategoryParameterValues.Style, context: context)
            case Trailers: return Category(id: YouTubeClient.CategoryParameterValues.Trailers, context: context)
            case Travel: return Category(id: YouTubeClient.CategoryParameterValues.Travel, context: context)
            }
        }
    }
    

    //MARK: -Properties
    var thinkBox = [CategoryInfo.Animals, .Politics, .Style, .Education, .Science, .Nonprofit]
    var watchBox = [CategoryInfo.Films, .Sports, .Comedy, .Movies, .Documentary, .TVShows]
    var loveBox = [CategoryInfo.Auto, .Music, .Travel, .Gaming, .PeopleBlogs, .Entertainment]
    var boxes: [[CategoryInfo]]{
        return [thinkBox, watchBox, loveBox]
    }
    var boxCategories = Array(count: 3, repeatedValue: [Category]())
    var currentBoxIndex: Int?
    var boxNode: SCNNode!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var geometry: SCNGeometry!
    var context: NSManagedObjectContext{
        return CoreDataStack.sharedInstance.context
    }
    private let youtubeClient = YouTubeClient.sharedClient()

    
 //MARK: Outlets
    @IBOutlet weak var scnView: SCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
    
        setupBox(0)
    }
    
    /*Returns a Boolean value indicating whether the view controller's contents should auto rotate.*/
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func setupView(){
        scnView.allowsCameraControl = true
        scnView.playing = true
        scnView.autoenablesDefaultLighting = true
        scnView.pointOfView = cameraNode
    }
    
    func setupScene(){
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = "TubeCat.scnassets/Textures/wallPaper.jpg"
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor(white: 0.2, alpha: 0.5)
        scnScene.rootNode.addChildNode(ambientLightNode)
    }
    
    func setupCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    

    @IBAction func pickABox(sender: AnyObject) {
        performSegueWithIdentifier("showBoxPicker", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showBoxPicker"{
            let bpvc = segue.destinationViewController as! BoxesPickerViewController
            bpvc.delegate = self
            
            if let boxPickerPopover = bpvc.popoverPresentationController{
                bpvc.preferredContentSize = CGSizeMake(self.view.frame.width/3, self.view.frame.height/4)
                boxPickerPopover.delegate = self
            }
        }
    }
    
    //Make the popover show up not only on iPad but also iPhone
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    
    func setupBox(index: Int?){
        
            if boxNode != nil{
                boxNode.removeFromParentNode()
            }
            let geometry = SCNBox(width: 3.0, height: 3.0, length: 3.0, chamferRadius: 0.0)
            geometry.materials = setMaterials(boxes[index!])
            currentBoxIndex = index
            
            boxNode = SCNNode(geometry: geometry)
            boxNode.position = SCNVector3(x: 0, y: 0.0, z: 0.0)
        
            
            let move1 = SCNAction.moveByX(0.0, y: CGFloat(1.0), z: 0.0, duration: 1.0)
            let move2 = SCNAction.moveByX(0.0, y: CGFloat(-1.0), z: 0.0, duration: 1.0)
            let sequence = SCNAction.sequence([move1,move2])
            let repeatedSequence = SCNAction.repeatActionForever(sequence)

            let spin = CABasicAnimation(keyPath: "rotation")
            spin.fromValue =  NSValue(SCNVector4: SCNVector4(x: 0, y: 0, z: 1, w: 0))
            spin.toValue = NSValue(SCNVector4: SCNVector4(x: 1, y: 0, z: 1, w: Float(2 * M_PI)))
            spin.duration = 6
            spin.repeatCount = .infinity
            boxNode.addAnimation(spin, forKey: "spin around")
            boxNode.runAction(repeatedSequence)
        
            boxNode.pivot = SCNMatrix4MakeRotation(Float(M_PI_2), 1, 0, 0)
        
            scnScene.rootNode.addChildNode(boxNode)
        
    }
    
    //MARK: - set up material for each face of the cube
    func setMaterials(box: [CategoryInfo]) -> [SCNMaterial]{
        var materials = [SCNMaterial]()
        
        for i in 0..<6{
            let material = SCNMaterial()
            material.diffuse.contents = box[i].url
            print("index \(i) has image \(box[i].url)")
            materials.append(material)
        }
        
        return materials
    }
    
    @IBAction func boxFaceTapped(sender: UITapGestureRecognizer) {
        let location = sender.locationInView(scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        if let result = hitResults.first{
            let node = result.node
            
            _ = node.geometry!.materials[result.geometryIndex]
            
            //Use NSPredicate to fetch existing categories which belongs to the current index of the boxes
            let fr = NSFetchRequest(entityName: "Category")
            fr.predicate = NSPredicate(format: "boxIndex == \(currentBoxIndex!)")
            
            do{
                print("Will try to fetch existing categories")
                boxCategories[currentBoxIndex!] = try context.executeFetchRequest(fr) as! [Category]
            }catch let e as NSError{
                print("Error in fetchrequest: \(e)")
                boxCategories[currentBoxIndex!] = [Category]()
            }

            if boxCategories[currentBoxIndex!].isEmpty{
                print("No existing categories. About to create new categories for currentBoxIndex \(currentBoxIndex)!")
                for i in 0..<6{
                    let cat = boxes[currentBoxIndex!][i].category
                    cat.boxIndex = currentBoxIndex
                    print("category id for index \(i) is \(boxes[currentBoxIndex!][i].category.id)")
                    boxCategories[currentBoxIndex!].append(cat)
                }
                
                do{
                    try context.save()
                }catch{}
            }
            
            var categoryId: String?
            switch (result.geometryIndex) {
                case 0:
                    categoryId = boxes[currentBoxIndex!][0].category.id
                case 1:
                    categoryId = boxes[currentBoxIndex!][1].category.id
                case 2:
                    categoryId = boxes[currentBoxIndex!][2].category.id
                case 3:
                    categoryId = boxes[currentBoxIndex!][3].category.id
                case 4:
                    categoryId = boxes[currentBoxIndex!][4].category.id
                case 5:
                    categoryId = boxes[currentBoxIndex!][5].category.id
                default:
                    break
             }
            
            let videosTableVC = storyboard!.instantiateViewControllerWithIdentifier("videosTable") as! VideosTableViewController

            for cat in boxCategories[currentBoxIndex!]{
                if cat.id == categoryId{
                        videosTableVC.category = cat
                        break
                }
            }

           self.navigationController?.pushViewController(videosTableVC, animated: true)
        }
    }
}
