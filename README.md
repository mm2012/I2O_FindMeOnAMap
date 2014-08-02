I2O_FindMeOnAMap
================

A simple example of Location-awareness using CoreLocation and MapKit

For a new Developer, Apple`s API can be intimidating as they try to cover many scenarios.
Sometimes it's a challenge to go through the examples just do some simple stuff.

This project address a simple problem statement like..
"How do I locate my current location on a Map? 
Then show a Pin there with a Callout that has a title, address of this location as a it's subtitle and an image?".

The example uses:
- CoreLocation's Location Manager  (talking to the the hardware underneath, finds current location)
- MKMapView  (to show a Map in the UI using MapKit API)
- MKAnnotation (A custom MKAnnotation-confirming Annotation object that Annotates the location on the MKMapView object)
- MKAnnotationView (to place callout left accessory image)
- CLGeocoder (to Reverse Geocode the Latitude and Longitude to a physical address)
- CLPlacemark (for getting the address information the CLGeocoder found on the location Coordinate)
- The " -(MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation" delegate method, has the long but needed code for placing an image in the callout by setting 'leftCalloutAccessoryView' property of the MkAnnotationView (for the pin). Note: NOT the 'image' property.

Note:
Reverse Geocoding request is processed Asynchronously with a Block for Completion Handling. 
Why Asynchronous? Neither do we want to block execution Main thread (namely, a responsive UI) and who knows how long the Reverse Geocoding request will take.
