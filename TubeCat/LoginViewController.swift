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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            let currentUser = User(id: user.userID, context: self.context) // For client-side use only!
            currentUser.authToken = user.authentication.idToken // Safe to send to the server
            currentUser.firstName = user.profile.givenName
            currentUser.lastName = user.profile.familyName
            currentUser.email = user.profile.email
            currentUser.imageData = NSData(contentsOfURL: user.profile.imageURLWithDimension(100))
            
            dataSource.user = currentUser
            
            do{
                try self.context.save()
            }catch{}
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)

        }
    }
    
    //        func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
    //            <#code#>
    //        }
    
    
}
