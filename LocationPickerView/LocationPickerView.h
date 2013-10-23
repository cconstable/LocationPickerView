//
//  LocationPickerView.h
//
//  Created by Christopher Constable on 5/10/13.
//  Copyright (c) 2013 Futura IO. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MKMapView;
@class LocationPickerView;

@protocol MKMapViewDelegate;
@protocol LocationPickerViewDelegate;

typedef void (^LocationPickerViewBlock)(LocationPickerView *locationPicker);


@interface LocationPickerView : UIView <UIScrollViewDelegate>

/** How much of the screen the map takes up initially and the height
 it returns to after scrolling is done. By default this is set to
 "180.0f". */
@property (nonatomic) CGFloat defaultMapHeight;

/** How fast the map scrolls with the table view. If this is set to
 "1.0" it scrolls at the same speed. A value less than "1.0" produces
 a slower scrolling map while a value greater than "1.0" makes the map
 scroll faster. The default value is "0.5". */
@property (nonatomic) CGFloat parallaxScrollFactor;

/** Determines whether or not the user can pull to a certain point
 on the table view to expand the map. This is disabled by default 
 because it may interfere with pull-to-refresh or other controls. */
@property (nonatomic) BOOL pullToExpandMapEnabled;

/** The amount you must "pull down" on the scroll view to make the 
 map view pop-out to full screen. By default this is set to "140.0f". */
@property (nonatomic) CGFloat amountToScrollToFullScreenMap;

/** If set to YES, this will automatically create an "X" button to shrink
 the map back down when it is shown. The button hides when the map returns
 to it's default size. This property defaults to NO. */
@property (nonatomic) BOOL shouldCreateHideMapButton;

/** Is the map covering the full screen? */
@property (nonatomic, readonly) BOOL isMapFullScreen;

/** The delegate gets notified when the map expands, shrinks, etc. */
@property (nonatomic, weak) IBOutlet id<LocationPickerViewDelegate> delegate;

/** The map view, duh. */
@property (nonatomic, strong) MKMapView *mapView;

/** Table view that sits below the map. */
@property (nonatomic, strong) UITableView *tableView;

/** The view to the tableview background view. */
@property (nonatomic, strong) UIView *backgroundView;

/** The color of the backgroundView */
@property (nonatomic, strong) UIColor *backgroundViewColor;

/** This UITableViewDataSource is forwarded to the LocationPickers's
 UITableView when it is created. */
@property (nonatomic, weak) IBOutlet id<UITableViewDataSource> tableViewDataSource;

/** This UITableViewDelegate is forwarded to the LocationPickers's
 UITableView when it is created. */
@property (nonatomic, weak) IBOutlet id<UITableViewDelegate> tableViewDelegate;

/** This MKMapViewDelegate is forwarded to the LocationPickers's
 MKMapView when it is created. */
@property (nonatomic, weak) IBOutlet id<MKMapViewDelegate> mapViewDelegate;

/** Called after the tableView has been loaded. Allows for additional setup. */
@property (nonatomic, copy) LocationPickerViewBlock tableViewDidLoadBlock;

/** Called after the mapView has been loaded. Allows for additional setup. */
@property (nonatomic, copy) LocationPickerViewBlock mapViewDidLoadBlock;

@property (nonatomic, copy) LocationPickerViewBlock mapViewWillExpand;
@property (nonatomic, copy) LocationPickerViewBlock mapViewDidExpand;
@property (nonatomic, copy) LocationPickerViewBlock mapViewWillBeHidden;
@property (nonatomic, copy) LocationPickerViewBlock mapViewWasHidden;

/** Makes the map view full screen. */
- (void)expandMapView:(id)sender animated:(BOOL)animated;
- (IBAction)expandMapView:(id)sender;

/** Shrinks the map view back down to it's default height. */
- (void)hideMapView:(id)sender animated:(BOOL)animated;
- (IBAction)hideMapView:(id)sender;

/** Expands or shrinks the map view. */
- (IBAction)toggleMapView:(id)sender;

/** Set custom close button map */
- (void)setCustomCloseButton:(UIButton *)closeButton;

@end


@protocol LocationPickerViewDelegate <NSObject>

@optional

/** Called when the mapView is loaded or reloaded. Alternatively, the block 
 properties of LocationPickerView can be used. */
- (void)locationPicker:(LocationPickerView *)locationPicker
     mapViewDidLoad:(MKMapView *)mapView;

/** Called when the tableView is loaded or reloaded. Alternatively, the block
 properties of LocationPickerView can be used.  */
- (void)locationPicker:(LocationPickerView *)locationPicker
        tableViewDidLoad:(UITableView *)tableView;

/** Called when the mapView is about to be expanded (made fullscreen).
 Use this to perform custom animations or set attributes of the map/table. */
- (void)locationPicker:(LocationPickerView *)locationPicker
     mapViewWillExpand:(MKMapView *)mapView;

/** Called when the mapView was expanded (made fullscreen). Use this to
 perform custom animations or set attributes of the map/table. */
- (void)locationPicker:(LocationPickerView *)locationPicker
      mapViewDidExpand:(MKMapView *)mapView;

/** Called when the mapView is about to be hidden (made tiny). Use this to
 perform custom animations or set attributes of the map/table. */
- (void)locationPicker:(LocationPickerView *)locationPicker
   mapViewWillBeHidden:(MKMapView *)mapView;

/** Called when the mapView was hidden (made tiny). Use this to
 perform custom animations or set attributes of the map/table. */
- (void)locationPicker:(LocationPickerView *)locationPicker
      mapViewWasHidden:(MKMapView *)mapView;

@end
