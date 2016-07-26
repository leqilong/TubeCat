//
//  LoginViewController.swift
//  TubeCat
//
//  Created by Leqi Long on 7/18/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate{

    //MARK: -Outlets
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    //MARK: -Properties
    var context: NSManagedObjectContext{
        return CoreDataStack.sharedInstance.context
    }
    
    let dataSource = DataSource.sharedClient()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.contents = UIImage(named: "TubeCat.scnassets/Textures/stairs.jpg")?.CGImage
        
        signInButton.colorScheme = .Dark
        signInButton.style = .Wide
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "181815803767-ccuc13g9536f8orinon2q5p69k0ivn73.apps.googleusercontent.com"
        
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/youtube")
        
        //GIDSignIn.sharedInstance().signInSilently()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let error = error {
            print(error)
        }
        else {
            
            let fr = NSFetchRequest(entityName: "User")
            
            do{
                print("Will try to fetch existing users in database")
                users = try context.executeFetchRequest(fr) as! [User]
            }catch let e as NSError{
                print("Error in fetchrequest: \(e)")
                users = [User]()
            }
            
            for existinguUser in users{
                if existinguUser.id == user.userID{
                    print("Found an existing user")
                    dataSource.user = existinguUser
                    break
                }
            }
            
            if dataSource.user == nil{
                //Create a new user
                print("Creating a new user!")
                let currentUser = User(id: user.userID, context: context) // For client-side use only!
                currentUser.authToken = user.authentication.idToken // Safe to send to the server
                currentUser.firstName = user.profile.name
                currentUser.lastName = user.profile.familyName
                currentUser.email = user.profile.email
                currentUser.imageData = NSData(contentsOfURL: user.profile.imageURLWithDimension(200))
                dataSource.user = currentUser
                
            }
            
            do{
                try self.context.save()
            }catch{}
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)

        }
    }
    
    
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        if let error = error{
            print(error)
        }
        
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
        
        controller.dismissViewControllerAnimated(true, completion: nil)

    }
    
    
}
