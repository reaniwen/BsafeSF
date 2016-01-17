BsafeSF
===========

# Introduction
This APP is a demo to show the crime happened in the recent 1 month and show you whether some districts are safe or not.<br>
The district is based on zipcode, and the color of district is based on how many crime it has comparing with other districts.<br>
On the right top conern, there is a button to show or hide markers of all the crimes.<br>
There is a `painted egg` in the app, find it! <br>
After all, I also like the name of SAFE, which is short for SAn Francisco Elite.<br>

# Requirement
* Map that overlays the points. <br>
* Paged request that makes API request for crime data within the city reported from the last 1 month. <br>
* On the map, the districts should have markers. <br>
* The markers colors should contrast in some given range. <br>
* Lastly, this app will need a toolbar/action bar with the name of the application you choose. <br>

# Achievement
* Show the base map of San Francisco. <br>
* All the crime data was requested from SF OpenData, which is happened in the recent 1 month. <br>
* Show where all the crime happened on the map with annotations. <br>
* Instead of color the annotations, I choose to color the district because the different color of annotations should be different category of crime. <br>
* The raw crime data was classify with PD district. In order to show where it happened, I reclassify all the data with administrative districts, which is zipcode.(This took majority of time) <br>
* Have a toolbar with the name of this application

# Log
#### Jan 13
		Familiar with MapKit.
		Build a blank map application.

#### Jan 14
		Generate the marks with the example data using Alamofire and SwiftyJson.
		Classify the marks with PD district.

#### Jan 15
		Familiar with SODA API.
		Replace the example data with the data reponsed from query.
		Looking for public supervisor districts data.

#### Jan 16
		Grab the supervisor districts data.
		Generate the new map with supervisor districts data.
		Reclassify the crime data with supervisor districts.

#### Jan 17
		Clean the useless code and add new comment to the code.
		Add a button to show/hide annotations
		Finish the Doc.
