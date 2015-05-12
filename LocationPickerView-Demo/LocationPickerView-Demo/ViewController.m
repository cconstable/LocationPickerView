//
//  ViewController.m
//  LocationPickerView-Demo
//
//  Created by Christopher Constable on 5/11/13.
//  Copyright (c) 2013 Christopher Constable. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()

@property (nonatomic,strong)NSArray *cities;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // The LocationPickerView can be created programmatically (see below) or
    // using Storyboards/XIBs (see Storyboard file).
    self.locationPickerView = [[LocationPickerView alloc] initWithFrame:self.view.bounds];
    self.locationPickerView.tableViewDataSource = self;
    self.locationPickerView.tableViewDelegate = self;
    
    // Optional parameters
    self.locationPickerView.delegate = self;
    self.locationPickerView.shouldAutoCenterOnUserLocation = YES;
    self.locationPickerView.shouldCreateHideMapButton = YES;
    self.locationPickerView.pullToExpandMapEnabled = YES;
    self.locationPickerView.defaultMapHeight = 220.0;           // larger than normal
    self.locationPickerView.parallaxScrollFactor = 0.3;         // little slower than normal.
    
    // Optional setup
    self.locationPickerView.mapViewDidLoadBlock = ^(LocationPickerView *locationPicker) {
        locationPicker.mapView.mapType = MKMapTypeStandard;
        locationPicker.mapView.userTrackingMode = MKUserTrackingModeFollow;
    };
    self.locationPickerView.tableViewDidLoadBlock = ^(LocationPickerView *locationPicker) {
        locationPicker.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    };
    
    // set custom close button
    /*
    UIButton *customCloseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [customCloseButton setTitle:@"close" forState:UIControlStateNormal];
    [customCloseButton setBackgroundColor:[UIColor blueColor]];
    [customCloseButton setFrame:CGRectMake(0, 0, 80, 80)];
    [self.locationPickerView setCustomCloseButton:customCloseButton atPoint:CGPointMake(100, 400)];
    */

    [self.view addSubview:self.locationPickerView];
    
    self.cities = [NSArray arrayWithObjects:@"Colombo",@"London",@"New York",@"Cardiff",@"Moscow",@"Beijing",@"Tokyo",@"Melbourne",@"Zurich",@"Berlin",@"Salzburg",@"Helsinki",@"Seoul",@"Pyong Yang",@"Perth",@"Brisbane",@"Oslo",@"Sydney",@"Vienna",@"Cairo",@"Rio De Janeiro",@"Nairobi", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cities count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusable"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusable"];
    }
    
    cell.textLabel.text = [self.cities objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setLocation:[self.cities objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - LocationPickerViewDelegate

/** Called when the mapView is about to be expanded (made fullscreen).
 Use this to perform custom animations or set attributes of the map/table. */
- (void)locationPicker:(LocationPickerView *)locationPicker
     mapViewWillExpand:(MKMapView *)mapView
{
    self.navigationItem.title = @"Map Expanding";
}

/** Called when the mapView was expanded (made fullscreen). Use this to
 perform custom animations or set attributes of the map/table. */
- (void)locationPicker:(LocationPickerView *)locationPicker
      mapViewDidExpand:(MKMapView *)mapView
{
    self.navigationItem.title = @"Map Expanded";
}

/** Called when the mapView is about to be hidden (made tiny). Use this to
 perform custom animations or set attributes of the map/table. */
- (void)locationPicker:(LocationPickerView *)locationPicker
   mapViewWillBeHidden:(MKMapView *)mapView
{
    self.navigationItem.title = @"Map Shrinking";
}

/** Called when the mapView was hidden (made tiny). Use this to
 perform custom animations or set attributes of the map/table. */
- (void)locationPicker:(LocationPickerView *)locationPicker
      mapViewWasHidden:(MKMapView *)mapView
{
    self.navigationItem.title = @"Map Normal";
}

- (void)locationPicker:(LocationPickerView *)locationPicker mapViewDidLoad:(MKMapView *)mapView
{
    mapView.mapType = MKMapTypeStandard;
}

- (void)locationPicker:(LocationPickerView *)locationPicker tableViewDidLoad:(UITableView *)tableView
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

#pragma mark -
- (void)setLocation:(NSString *)location{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    __weak typeof(self) weakSelf = self;
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
                         MKCoordinateRegion region = weakSelf.locationPickerView.mapView.region;
                         region.center = [(CLCircularRegion *)placemark.region center];
                         region.span.longitudeDelta /= 8.0;
                         region.span.latitudeDelta /= 8.0;
                         
                         [weakSelf.locationPickerView.mapView setRegion:region animated:YES];
                         [weakSelf.locationPickerView.mapView addAnnotation:placemark];
                     }
                 }
     ];
}

@end
