//
//  ProfileViewController.swift
//  TubeCat
//
//  Created by Leqi Long on 7/25/16.
//  Copyright © 2016 Student. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subscribersLabel: UILabel!
    @IBOutlet weak var subscriptionsLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    let dataSource = DataSource.sharedClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure(){
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.88, green:0.38, blue:0.21, alpha:1.0)
        view.layer.contents = UIImage(named: "TubeCat.scnassets/BackgroundImage/ProfileBackground.jpg")?.CGImage
        let image = UIImage(data: (dataSource.user?.imageData)!)
        profileImageView.image = image!.rounded
        nameLabel.text = dataSource.user?.firstName
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
        dismissViewControllerAnimated(true, completion: nil)
    }
  
    
}
