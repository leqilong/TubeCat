# TubeCat
TubeCat is an application which allows users to explore and browse YouTube videos based on popular video categories. It also includes features such as managing user's favorite videos and searching for channels and videos using keywords.

TubeCat is able to retrieve various YouTube videos information using YouTube's' API. Here's the [full documentation](https://developers.google.com/youtube/v3/docs/) that was used throughout building this app.

TubeCat achieves data persistence using CoreData.

To run TubeCat, clone or download the project and open the TubeCat.xcworkspace file. 

## CoreData Model
TubeCat's coredata model consists of three entities: 
- User
*Attributes: current user's information such as profile picture URL, user id, authentication token, etc.
- Category 
*Attributes: category id, page tokens, name of the category, etc, some of which comes in handy as parameters to make HTTP requests to retrieve videos of specific categories
- Video
*Attributes: video id, playlist item id, thumbnail image url, video title, video description, etc. This entity has a one to many relationships with both User and Category

## View Controller Scenes 

### LoginViewController.swift
This is the initial view when the app first launches. It allows the user to sign in with their Google account or create a new new account. This feature is implemented with Google's sign-in library. See [here] (https://developers.google.com/identity/sign-in/ios/sign-in?ver=swift) for installation and usage instructions in either Swift or Objective-C.

### CatBoxViewController.swift
Once signed in, a tab bar view controller with four scenes are presented. The default scene is the CatBoxViewController. A spinning box created with [SceneKit](https://developer.apple.com/library/ios/documentation/SceneKit/Reference/SceneKit_Framework/), which is an Objective-C framework that allows you to create amazing 3D animations, has six faces representing a video category. The user can spin the box whichever direction they desire. At the top right corner of the navigation bar is a picker view, that allows the user to pick between three boxes consisting of a specific sets of categories. Whenever a user taps on a face of the box, this controller will navigate to VideosTableViewController which is explained in further below.

### VideosTableViewController.swift
VideosTableViewController controller which is a subclass of CoreDataTableViewController that conforms to protocol NSFetchedResultsControllerDelegate. Since this app has multiple table view controllers that fetch core data objects, having a dedicated table view controller that implements this feature, and having other classes being the subclasses of it avoids repeated codes. This table view controller displays videos associated with a specific category chosen by the user. The navigation bar consists of 3 bar items: refresh, previous page, next page. 

### SearchViewController.swift
SearchViewController is a subclass of UIViewController. It consists of a UITableView, a TextField, an UIView whose only function is to indicate "wait" while a request is being made, and a SegmentControl at the navigation bar. By manipulating the segments, user can search either channels or videos based on keywords enter by the user in the textfield. The UITableView would then display the search results. Whenever the segment changes from one to another, an HTTP call is made to retrieve the respective type of results. If the user is at the "channel" segment, and select a specific channel, the segment would then change to "Video" and the UITableView would display videos of that specific channel. If the user is at the "Video" segment, selecting a video in the result would then navigate to the VideoPlayerViewController which I would explain next.

### VideoPlayerViewController.swift
VideoPlayerViewController displays the video title, a button with a heart icon and a video player view. The purpose of this controller is to utilize an incorporated [YouTube Helper Library](https://developers.google.com/youtube/v3/guides/ios_youtube_helper) to embed the YouTube video player in the UIView. 
    
When the user presses the heart button, an HTTP request, either .POST or .DELETE, depending on whether this video was previously favorited video, is sent. This allows the user to manage their favorite videos.

### FavoritesTableViewController.swift
FavoritesTableViewController is another subclass of CoreDataTableViewController. It displays the user's favorite videos if they exist. When the app launches for the first time, or navigation bar items are pressed, a HTTP call is sent to download the videos thumbnail, description, and title. As the call is sent, the cell's activity indicator begins animating to display the user's' downloading progression.

### ProfileViewController.swift
ProfileViewController is a subclass of UIViewController. It has an UIImageView which contains the user's profile picture that was downloaded when the user signed in and also contains an UILabel which displays the user's full name. The logout button dismisses the tab bar view controller and the user returns to the the login view controller to enter their credentials. 

##Credits 
Leqi Long

##Contacts
longleqi89@gmail.com
