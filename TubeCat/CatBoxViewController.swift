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
    
    
    enum Box{
        case BoxOne(categories: [CategoryInfo])
        case BoxTwo(categories: [CategoryInfo])
        case BoxThree(categories: [CategoryInfo])
    }
    
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
    

    
    var thinkBox = [CategoryInfo.Animals, .Politics, .Style, .Education, .Science, .Nonprofit]
    
    var watchBox = [CategoryInfo.Films, .Sports, .Comedy, .Movies, .Documentary, .TVShows]
    
    var loveBox = [CategoryInfo.Auto, .Music, .Travel, .Gaming, .PeopleBlogs, .Entertainment]
    
    var boxes: [[CategoryInfo]]{
        return [thinkBox, watchBox, loveBox]
    }
    
    var boxCategories = Array(count: 3, repeatedValue: [Category]())
    
    var currentBoxIndex: Int?
    
    var boxNode: SCNNode!
    
 //MARK: Outlets
    @IBOutlet weak var scnView: SCNView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    
 //MARK: Properties
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var geometry: SCNGeometry!
    var context: NSManagedObjectContext{
        return CoreDataStack.sharedInstance.context
    }
    private let youtubeClient = YouTubeClient.sharedClient()
    var nextPageToken: String?
    
    var geometries = [SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0.0),
                      SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0.0),
                      SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0.0)]
    
    var geometryNodes = [SCNNode]()
    var nodeInFrame: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
    
        setupBox(0)
    }
    
    enum CubeFace: Int {
        case Front, Right, Back, Left, Top, Bottom
    }
    
    /*Returns a Boolean value indicating whether the view controller's contents should auto rotate.*/
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    /*Specifies whether the view controller prefers the status bar to be hidden or shown.*/
    override func prefersStatusBarHidden() -> Bool {
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
        scnScene.background.contents = "TubeCat.scnassets/Textures/fabric-1407721.jpg"
        
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
                bpvc.preferredContentSize = CGSizeMake(self.view.frame.width/2, self.view.frame.height/3)
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
            print("About to set up box")
            let geometry = SCNBox(width: 3.0, height: 3.0, length: 3.0, chamferRadius: 0.0)
            geometry.materials = setMaterials(boxes[index!])
            currentBoxIndex = index
            //print("currentBoxIndex is: \(currentBoxIndex)")
            
            boxNode = SCNNode(geometry: geometry)
            boxNode.position = SCNVector3(x: 0, y: 0.0, z: 0.0)
        
            
            let move1 = SCNAction.moveByX(0.0, y: CGFloat(1.0), z: 0.0, duration: 1.0)
            let move2 = SCNAction.moveByX(0.0, y: CGFloat(-1.0), z: 0.0, duration: 1.0)
            let sequence = SCNAction.sequence([move1,move2])
            let repeatedSequence = SCNAction.repeatActionForever(sequence)

            let spin = CABasicAnimation(keyPath: "rotation")
            spin.fromValue =  NSValue(SCNVector4: SCNVector4(x: 0, y: 0, z: 1, w: 0))
            spin.toValue = NSValue(SCNVector4: SCNVector4(x: 0, y: 0, z: 1, w: Float(2 * M_PI)))
            spin.duration = 6
            spin.repeatCount = .infinity
            boxNode.addAnimation(spin, forKey: "spin around")
            //node.position = SCNVector3(x: x, y: 0, z: z)
            boxNode.runAction(repeatedSequence)
            
            boxNode.pivot = SCNMatrix4MakeRotation(Float(M_PI_2), 1, 0, 0)
        
             scnScene.rootNode.addChildNode(boxNode)
        
    }
    
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
//    
//    
//    func createCategories(index: Int?){
//        
//        print("About to create new categories!")
//        //var categoryArray = [Category]()
//        
//        if let index = index{
//            //print("index is \(index)")
//            for i in 0..<6{
//                let cat = boxes[index][i].category
//                boxCategories[index].append(cat)
//            }
//            //boxCategories[index] = categoryArray
//            
//            do{
//                try context.save()
//            }catch{}
//        }
//    }
//    
//    func loadCategories(index: Int?){
//        print("About to fetch existing categories!")
//        let fr = NSFetchRequest(entityName: "Category")
//        if let index = index{
//            do{
//                boxCategories[index] = try context.executeFetchRequest(fr) as! [Category]
//            }catch let e as NSError{
//                print("Error in fetchrequest: \(e)")
//                boxCategories[index] = [Category]()
//                createCategories(index)
//            }
//
//        }
//    }
    
    @IBAction func boxFaceTapped(sender: UITapGestureRecognizer) {
        let location = sender.locationInView(scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        if let result = hitResults.first{
            let node = result.node
            
            _ = node.geometry!.materials[result.geometryIndex]
            
            print("geometryIndex is \(result.geometryIndex)")
            
            print("segue is about to start")
            let fr = NSFetchRequest(entityName: "Category")
            
            do{
                print("Will try to fetch existing categories")
                boxCategories[currentBoxIndex!] = try context.executeFetchRequest(fr) as! [Category]
            }catch let e as NSError{
                print("Error in fetchrequest: \(e)")
                boxCategories[currentBoxIndex!] = [Category]()
            }

            if boxCategories[currentBoxIndex!].isEmpty{
                print("About to create new categories for currentBoxIndex \(currentBoxIndex)!")
                for i in 0..<6{
                    let cat = boxes[currentBoxIndex!][i].category
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
                    print("cat.id is \(cat.id) and categoryId is (categoryId)")
                        videosTableVC.category = cat
                        break
                }
            }
            
            
            print("About to segue to new videosVC. The category ID is \(boxCategories[currentBoxIndex!][result.geometryIndex].id)!!!")
            

           self.navigationController?.pushViewController(videosTableVC, animated: true)
           print("hit face: \(CubeFace(rawValue: result.geometryIndex))")
        }
    }
}
