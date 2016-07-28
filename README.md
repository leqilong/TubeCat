# TubeCat
TubeCat is an application which allows user to explore and browse YouTube videos based on an array of highly popular video categories. The app also includes features such as managing user's favorite videos and searching for channels and videos using keywords.

TubeCat is able to retrieve various YouTube videos information using YouTube API. Here's the [full documentation](https://developers.google.com/youtube/v3/docs/) that I used throughout building this app.

TubeCat achieves data persistence using CoreData.


## CoreData Model
TubeCat's coredata model consists of three entities: 
- User
    *Attributes: current user's information such as profile picture URL, user id, authentication token, etc.
- Category 
    *Attributes: category id, page tokens, name of the category, etc, some of which comes in handy as parameters to make HTTP requests to retrieve videos of specific categories
- Video
    *Attributes: video id, playlist item id, thumbnail image url, video title, video description, etc. This entity has one to many relationships with both User and Category

## View Controller Scenes 

### LoginViewController.swift
This is the initial view when the app first launches. It allows the user to sign in Google account or create a new new account if they don't have any. I used Google Sign-In library to implement this feature. See [here] (https://developers.google.com/identity/sign-in/ios/sign-in?ver=swift) for installation and usage instructions in either Swift or Objective-C.

### CatBoxViewController.swift
Once sign in successfully, a tab bar view controller with 4 scenes are presented. The default scene is the CatBoxViewController. A spinning box created with [SceneKit](https://developer.apple.com/library/ios/documentation/SceneKit/Reference/SceneKit_Framework/), which is an Objective-C framework that allows you to create amazing 3D animations, has 6 faces, each one represents a video category. The user can spin the box whichever direction they want. At top right corner of the navigation bar is a picker view, that allows the user to pick between three boxes, each one consists of a specific sets of categories. Whenever a user taps on a certain face of the box, this controller would then navigate to VideosTableViewController which I will explain in the next part.

### VideosTableViewController.swift
This is a table view controller which is a subclass of CoreDataTableViewController, which conforms to protocol NSFetchedResultsControllerDelegate. Since this app has multiple table view controllers that fetch core data objects, having a dedicated table view controller that does just that, and have other classes being the subclasses of it avoids repeated codes. This table view controller displays videos associated with a specific category which was chosen by the user. The navigation bar consists of 3 bar items: refresh, previous page, next page. 

### SearchViewController.swift
This view controller is a subclass of UIViewController. It consists of a UITableView, a TextField, an UIView whose only function is to indicate "wait" while a request is being made, and a SegmentControl at the navigation bar. By manipulating the segments, user can search either channels or videos based on keywords enter by the user in the textfield. The UITableView would then display the search results. Whenever the segment changes from one to another, an HTTP call is made to retrieve the respective type of results. If the user is at the "channel" segment, and select a specific channel, the segment would then change to "Video" and the UITableView would display videos of that specific channel. If the user is at the "Video" segment, selecting a video in the result would then navigate to the VideoPlayerViewController which I would explain next.

### VideoPlayerViewController.swift
This view controller displays video title, a button with a heart icon inside and a video player view. I incorporated [YouTube Helper Library](https://developers.google.com/youtube/v3/guides/ios_youtube_helper) to embed the YouTube video player in the UIView. 
    
When user presses the heart button, an HTTP request, either .POST or .DELETE depending on whether this video is previously a favorite video or not, is made. This allows the user to manage favorite videos.

### FavoritesTableViewController.swift
This table view controller is another subclass of CoreDataTableViewController. It displays a user's favorite videos if any. If the app launches for the first time, or refresh, nextpageButton, prevPageButton being pressed, an HTTP call is made to download videos information. As the call is being made, cell's activity indicator would start animating to show the user downloading is in process.

### ProfileViewController.swift
This is a subclass of UIViewController. It has UIImageView which contains user's profile picture, which was downnloaded when the user first signs in. It has a UILabel which contains user's full name - another infomration obtained upon signing in. In addition, there's a logout button that when pressed, tab bar view controller would be dismissed and the user would be presented with the login view controller. 

##Credits 
Leqi Long

##Contacts
longleqi89@gmail.com





