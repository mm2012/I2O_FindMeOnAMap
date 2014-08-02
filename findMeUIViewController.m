//
//  findMeUIViewController.m
//  I2O_findMeOnTheMap

//  Copyright (c) 2013 Mikki Mann, Idea2Objects. All rights reserved.
//
/*
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#import "findMeUIViewController.h"
#import "I2OAnnotationPoint.h"

#pragma mark View Controller stuff

@interface findMeUIViewController ()

{
    CLLocationManager *locationManager;  // will hide this in the Class extension
    CLGeocoder* geocoder;
}

-(void)setupLocationManager;
-(void)findLocation;
-(void)foundLocation:(CLLocation*)loc;
-(void)showPlacemark:(NSArray*)placemarks withCoordinate:(CLLocationCoordinate2D)coordinate;


@end


@implementation findMeUIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupLocationManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [worldView setShowsUserLocation:YES]; // show user's current location on Map using CLLocationManager
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Text field

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self findLocation];
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark Location Manager stuff

-(void)setupLocationManager
{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest]; // Not going to worry about Battery usage in this sample
    [locationManager setDelegate:self];
         //[locationManager startUpdatingLocation];  --- MAPView takes care of this
    geocoder = [[CLGeocoder alloc] init];
}

-(void)locationManager:(CLLocationManager *)manager
                        didUpdateLocations:(NSArray *)locations
{
    NSLog(@"location array (%lu): %@\n", (unsigned long)[locations count], locations);
   
    CLLocation* loc = [locations objectAtIndex:0];
    
        // check time interval before updating
    NSTimeInterval t =  [[loc timestamp] timeIntervalSinceNow];  //How many seconds ago
        //if location was received less then3 mins ago, ignore it
    if (t < -180)
    { // dont use this cached data
        return;
    }
    
    [self foundLocation:loc];
}

-(void)findLocation
{
    [locationManager startUpdatingLocation];
    [activityIndicator startAnimating];
    [locationTitleField setHidden:YES];
}

-(void)foundLocation:(CLLocation *)loc
{
    
  [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSLog(@"Reverse Geocoding of location failed with error: %@", error);
            return;
        }
        NSLog(@"Received placemarks: %@", placemarks);
          [self showPlacemark:placemarks withCoordinate:loc.coordinate];
    }];
    
}


#pragma mark MapView stuff


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 250,250);
    [worldView setRegion:region animated:YES];
    
    NSLog(@"User Location updated to, Latitude: %0.2f Longitude: %0.2f",
                                userLocation.location.coordinate.latitude,
                                userLocation.location.coordinate.longitude);
}


-(void)showPlacemark:(NSArray*)placemarks withCoordinate:(CLLocationCoordinate2D)coordinate
{
    CLPlacemark *placeMark = [placemarks objectAtIndex:0]; // first item is what we need
    
    I2OAnnotationPoint *aPoint = [[I2OAnnotationPoint alloc] initWithCoordinate:coordinate
                                                                          title:[locationTitleField text]
                                                                       subtitle:[NSString stringWithFormat:@"%@ %@, %@ %@",
                                                                                 placeMark.thoroughfare,
                                                                                 placeMark.subThoroughfare,
                                                                                 placeMark.postalCode,
                                                                                 placeMark.locality]];
    [worldView addAnnotation:aPoint];
    [worldView selectAnnotation:aPoint animated:YES];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 250, 250);
    [worldView setRegion:region animated:YES];
    //reset the UI
    [locationTitleField setText:@""];
    [activityIndicator stopAnimating];
    [locationTitleField setHidden:NO];
    [locationManager stopUpdatingLocation];
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
  {
      // this method customizes the Pin view to show a custom image in Pin's callout (by setting pinView.leftCalloutAccessoryView)
  
                // check if it's  the user location, we already have an annotation, so just return nil
      if ([annotation isKindOfClass:[MKUserLocation class]])
      {
          return nil;
      }

            // Try to dequeue an existing pin view first
    static NSString* annotationViewIdentifier = @"annotationViewIdentifier";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[worldView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
      
            // If pin view doesnt exist, create a new one.
    if (!pinView) {
        MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc]
                                              initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier];
        customPinView.pinColor = MKPinAnnotationColorPurple;
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
            // Add the custom image to the left side of the callout.
        UIImageView *myImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smiley.png"]];
        customPinView.leftCalloutAccessoryView = myImage;
        
        return customPinView;
     }
    else   // already exists? no sweat. easier work.
    {
        pinView.annotation = annotation;
        return pinView;
    }
    
    return nil; // if none of it matches just return good old fashioned nil
}

@end
