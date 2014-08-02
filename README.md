I2O_FindMeOnAMap
================

A Location-awareness example using CoreLocation, MKMapView, CLGeocoder,  MKAnnotation and CLPlacemark.

For a new Developer, Apple`s API can be intimidating as they try to hit many scenarios.
Sometimes it's a challenge to go through the examples just to do some simple stuff.

This project address a simple situation:
"How do I locate my current location on a Map?"
"Then show a Pin there with a Callout that has a title, address of this location (as it's subtitle) and an image?".


Features used:
- CoreLocation's Location Manager  (talking to the the hardware underneath, finds current location)
- MKMapView  (to show a Map in the UI using MapKit API)
- MKAnnotation (A custom MKAnnotation-confirming Annotation object that Annotates the location on the MKMapView object)
- MKAnnotationView (to place callout left accessory image)
- CLGeocoder (to Reverse Geocode the Latitude and Longitude to a physical address)
- CLPlacemark (for getting the address information the CLGeocoder found on the location Coordinate)
- The " -(MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation" delegate method, has the long but needed code for placing an image in the callout by setting 'leftCalloutAccessoryView' property of the MkAnnotationView (for the pin). Note: NOT the 'image' property.
- A UITextField for the user to enter the Annotation title. Which the UITextField informs it'S Delegate the View Controller.


Async processing:

Reverse Geocoding request is processed Asynchronously with a Block for Completion Handling. 
Why Asynchronous? Neither do we want to block execution Main thread (namely, a responsive UI) and who knows how long the Reverse Geocoding request will take.


Delegation:
- UITextField uses Delegation to inform the View Controller that the return key was pressed, so the FirstResponder can be resigned and the hence the keyboard dismissed.
- In your XIB don't forget to connect the UITextField and MKMApView objects to their respective Delegate property in  File's Owner. Or how can they receive messages?
