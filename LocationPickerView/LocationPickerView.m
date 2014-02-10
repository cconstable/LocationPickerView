//
//  LocationPickerView.m
//
//  Created by Christopher Constable on 5/10/13.
//  Copyright (c) 2013 Futura IO. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "LocationPickerView.h"
#import "UIImage+Icons.h"

@interface LocationPickerView ()

@property (nonatomic) BOOL isMapAnimating;
@property (nonatomic) CGRect defaultMapViewFrame;
@property (nonatomic, strong) UITapGestureRecognizer *mapTapGesture;

/** This is only created if the user does not override the 
 mapViewDidExpand: method. Allows the user to shrink the map. */
@property (nonatomic, strong) UIButton *closeMapButton;
@property (nonatomic, readwrite) CGPoint closeButtonPoint;
- (void)didTapCloseMapViewButton:(id)sender;
@end

@implementation LocationPickerView

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _defaultMapHeight               = 130.0f;
    _parallaxScrollFactor           = 0.6f;
    _amountToScrollToFullScreenMap  = 110.0f;
    _shouldAutoCenterOnUserLocation = NO;
    self.autoresizesSubviews        = YES;
    self.autoresizingMask           = UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleHeight;
    
    self.closeButtonPoint = CGPointMake(14.0, 14.0);
    self.backgroundViewColor = [UIColor clearColor];
}

- (void)dealloc
{
    void *context = (__bridge void *)self;
    [self.tableView removeObserver:self forKeyPath:@"contentOffset" context:context];
    [self.mapView removeObserver:self forKeyPath:@"userTrackingMode" context:context];
    [self.mapView.userLocation removeObserver:self forKeyPath:@"location" context:context];
    
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self.tableViewDelegate;
        self.tableView.dataSource = self.tableViewDataSource;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        
        if ([self.delegate respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0);
        }
        
        void *context = (__bridge void *)self;
        [self.tableView addObserver:self
                         forKeyPath:@"contentOffset"
                            options:NSKeyValueObservingOptionNew
                            context:context];
        
        [self addSubview:self.tableView];
        
        if ([self.delegate respondsToSelector:@selector(locationPicker:tableViewDidLoad:)]) {
            [self.delegate locationPicker:self tableViewDidLoad:self.tableView];
        }
        
        if (self.tableViewDidLoadBlock) {
            self.tableViewDidLoadBlock(self);
        }
    }
    
    if (!self.tableView.tableHeaderView) {
        CGRect tableHeaderViewFrame = CGRectMake(0.0, 0.0, self.tableView.frame.size.width, self.defaultMapHeight);
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        tableHeaderView.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = tableHeaderView;
    }
    
    if (!self.mapView) {
        self.defaultMapViewFrame = CGRectMake(0.0,
                                              -self.defaultMapHeight * self.parallaxScrollFactor * 2,
                                              self.tableView.frame.size.width,
                                              self.defaultMapHeight + (self.defaultMapHeight * self.parallaxScrollFactor * 4));
        _mapView = [[MKMapView alloc] initWithFrame:self.defaultMapViewFrame];
        self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.mapView.scrollEnabled = NO;
        self.mapView.zoomEnabled = NO;
        self.mapView.delegate = self.mapViewDelegate;
        [self insertSubview:self.mapView belowSubview:self.tableView];
        
        void *context = (__bridge void *)self;
        [self.mapView.userLocation addObserver:self
                                    forKeyPath:@"location"
                                       options:NSKeyValueObservingOptionNew
                                       context:context];
        
        [self.mapView addObserver:self
                       forKeyPath:@"userTrackingMode"
                          options:NSKeyValueObservingOptionNew
                          context:context];
        
        if ([self.delegate respondsToSelector:@selector(locationPicker:mapViewDidLoad:)]) {
            [self.delegate locationPicker:self mapViewDidLoad:self.mapView];
        }
        
        if (self.mapViewDidLoadBlock) {
            self.mapViewDidLoadBlock(self);
        }
    }
    
    // Add tap gesture to table
    if (!self.mapTapGesture) {
        self.mapTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(mapWasTapped:)];
        self.mapTapGesture.cancelsTouchesInView = YES;
        self.mapTapGesture.delaysTouchesBegan = NO;
        [self.tableView.tableHeaderView addGestureRecognizer:self.mapTapGesture];
    }
    
    // Add the background tableView
    if (!self.backgroundView) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.defaultMapHeight,
                                                                self.tableView.frame.size.width,
                                                                self.tableView.frame.size.height - self.defaultMapHeight)];
        view.backgroundColor = self.backgroundViewColor;
        self.backgroundView = view;
        self.backgroundView.userInteractionEnabled=NO;
        [self.tableView insertSubview:self.backgroundView atIndex:0];
    }
}

- (void)setTableViewDataSource:(id<UITableViewDataSource>)tableViewDataSource
{
    _tableViewDataSource = tableViewDataSource;
    self.tableView.dataSource = _tableViewDataSource;
    
    if (_tableViewDelegate) {
        [self.tableView reloadData];
    }
}

- (void)setTableViewDelegate:(id<UITableViewDelegate>)tableViewDelegate
{
    _tableViewDelegate = tableViewDelegate;
    self.tableView.delegate = _tableViewDelegate;
    
    if (_tableViewDataSource) {
        [self.tableView reloadData];
    }
}

- (void)setMapViewDelegate:(id<MKMapViewDelegate>)mapViewDelegate
{
    _mapViewDelegate = mapViewDelegate;
    self.mapView.delegate = _mapViewDelegate;
}

- (void)setTableView:(UITableView *)tableView
{
    _tableView = tableView;
    
    if ([self.delegate respondsToSelector:@selector(locationPicker:tableViewDidLoad:)]) {
        [self.delegate locationPicker:self tableViewDidLoad:self.tableView];
    }
    
    if (self.tableViewDidLoadBlock) {
        self.tableViewDidLoadBlock(self);
    }
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    
    if ([self.delegate respondsToSelector:@selector(locationPicker:mapViewDidLoad:)]) {
        [self.delegate locationPicker:self mapViewDidLoad:self.mapView];
    }
    
    if (self.mapViewDidLoadBlock) {
        self.mapViewDidLoadBlock(self);
    }
}

- (void)setCustomCloseButton:(UIButton *)closeButton
{
    [self setCustomCloseButton:closeButton atPoint:self.closeButtonPoint];
}

- (void)setCustomCloseButton:(UIButton *)closeButton atPoint:(CGPoint)buttonPoint{
    if(self.closeMapButton) [self.closeMapButton removeFromSuperview];
    self.closeMapButton = closeButton;
    self.closeButtonPoint = buttonPoint;
    [self.closeMapButton addTarget:self action:@selector(didTapCloseMapViewButton:) forControlEvents:UIControlEventTouchUpInside];
    self.closeMapButton.hidden = YES;
    
    [self insertSubview:self.closeMapButton aboveSubview:self.mapView];
}

#pragma mark - Internal Methods

- (void)mapWasTapped:(id)sender
{
    [self expandMapView:self];
}

- (void)showCloseMapButton
{
    if (!self.closeMapButton) {
        self.closeMapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeMapButton.frame = CGRectMake(self.closeButtonPoint.x, self.closeButtonPoint.y, 42.0, 42.0);
        [self.closeMapButton setImage:[UIImage imageForXIcon] forState:UIControlStateNormal];
        [self.closeMapButton setImage:[UIImage imageForXIcon] forState:UIControlStateHighlighted];
        [self.closeMapButton addTarget:self action:@selector(didTapCloseMapViewButton:) forControlEvents:UIControlEventTouchUpInside];
        self.closeMapButton.hidden = YES;
        
        [self insertSubview:self.closeMapButton aboveSubview:self.mapView];
    }
    else{
        [self.closeMapButton setFrame:CGRectMake(self.closeButtonPoint.x, self.closeButtonPoint.y, self.closeMapButton.frame.size.width, self.closeMapButton.frame.size.height)];
    }
    
    self.closeMapButton.alpha = 0.0;
    self.closeMapButton.hidden = NO;
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.closeMapButton.alpha = 1.0;
                     }
                     completion:nil];
}

- (void)hideCloseMapButton
{
    if (self.closeMapButton) {
        self.closeMapButton.hidden = NO;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.closeMapButton.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             self.closeMapButton.hidden = YES;
                         }];
    }
}

#pragma mark - Expanding / Shrinking Map Methods

- (void)expandMapView:(id)sender
{
    [self expandMapView:sender animated:YES];
}

- (void)expandMapView:(id)sender
             animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(locationPicker:mapViewWillExpand:)]) {
        [self.delegate locationPicker:self mapViewWillExpand:self.mapView];
    }
    if (self.mapViewWillExpand) {
        self.mapViewWillExpand(self);
    }
    
    self.isMapAnimating = animated;
    [self.tableView.tableHeaderView removeGestureRecognizer:self.mapTapGesture];
    if (self.tableView.numberOfSections && [self.tableView numberOfRowsInSection:0]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
    
    CGRect newMapFrame = self.mapView.frame;
    newMapFrame = CGRectMake(self.defaultMapViewFrame.origin.x,
                             self.defaultMapViewFrame.origin.y + (self.defaultMapHeight * self.parallaxScrollFactor),
                             self.defaultMapViewFrame.size.width,
                             self.defaultMapHeight + (self.defaultMapHeight * self.parallaxScrollFactor * 2));
    self.mapView.frame = newMapFrame;
    
    [self bringSubviewToFront:self.mapView];
    [self insertSubview:self.closeMapButton aboveSubview:self.mapView];
    
    if(animated == YES)
    {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.mapView.frame = self.bounds;
                         } completion:^(BOOL finished) {
                             [self mapViewDidFinishExpanding];
                         }];
    }
    else
    {
        self.mapView.frame = self.bounds;
        [self mapViewDidFinishExpanding];
    }
}

- (void)mapViewDidFinishExpanding
{
    self.isMapAnimating = NO;
    _isMapFullScreen = YES;
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    
    [self centerMapOnUserLocationIfNecessary];
    
    if ([self.delegate respondsToSelector:@selector(locationPicker:mapViewDidExpand:)]) {
        [self.delegate locationPicker:self mapViewDidExpand:self.mapView];
    }
    if (self.mapViewDidExpand) {
        self.mapViewDidExpand(self);
    }
    
    if (self.shouldCreateHideMapButton) {
        [self showCloseMapButton];
    }
}

- (void)hideMapView:(id)sender
{
    [self hideMapView:sender animated:YES];
}

- (void)didTapCloseMapViewButton:(id)sender
{
    // override default close map button action if block is set
    if(self.mapCloseButtonTapped)
    {
        self.mapCloseButtonTapped(self);
    }
    else
    {
        // default action for close map view button
        [self hideMapView:self];
    }
}

- (void)hideMapView:(id)sender animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(locationPicker:mapViewWillBeHidden:)]) {
        [self.delegate locationPicker:self mapViewWillBeHidden:self.mapView];
    }
    if (self.mapViewWillBeHidden) {
        self.mapViewWillBeHidden(self);
    }
    
    if (self.shouldCreateHideMapButton) {
        [self hideCloseMapButton];
    }
    
    self.isMapAnimating = animated;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    [self.tableView.tableHeaderView addGestureRecognizer:self.mapTapGesture];
    
    // Store the correct tableViewFrame.
    // Set table view off the bottom of the screen, and animate
    // back to normal
    CGRect tempFrame = self.tableView.frame;
    self.tableView.frame = CGRectMake(0, 480, tempFrame.size.width, tempFrame.size.height);
    [self insertSubview:self.mapView belowSubview:self.tableView];
    
    if(animated == YES)
    {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.mapView.frame = self.defaultMapViewFrame;
                             self.tableView.frame = tempFrame;
                         } completion:^(BOOL finished) {
                             [self mapViewDidFinishHiding];
                         }];
    }
    else
    {
        self.mapView.frame = self.defaultMapViewFrame;
        self.tableView.frame = tempFrame;
        [self mapViewDidFinishHiding];
    }
}

- (void)mapViewDidFinishHiding
{
    [self insertSubview:self.closeMapButton aboveSubview:self.mapView];
    self.isMapAnimating = NO;
    _isMapFullScreen = NO;
    
    [self centerMapOnUserLocationIfNecessary];
    
    if ([self.delegate respondsToSelector:@selector(locationPicker:mapViewWasHidden:)]) {
        [self.delegate locationPicker:self mapViewWasHidden:self.mapView];
    }
    if (self.mapViewWasHidden) {
        self.mapViewWasHidden(self);
    }
}

- (void)toggleMapView:(id)sender
{
    if (!self.isMapAnimating) {
        if (self.isMapFullScreen) {
            [self hideMapView:self];
        }
        else {
            [self expandMapView:self];
        }
    }
}

- (void)centerMapOnUserLocationIfNecessary
{
    if (self.shouldAutoCenterOnUserLocation && self.mapView.userTrackingMode) {
        MKCoordinateRegion centerCoordinate = MKCoordinateRegionMake(self.mapView.userLocation.coordinate, self.mapView.region.span);
        [self.mapView setRegion:centerCoordinate
                       animated:YES];
    }
}

#pragma mark - KVO Methods

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{    
	// Make sure we are observing this value.
	if (context != (__bridge void *)self) {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
		return;
	}
    
    if ((object == self.tableView) &&
        ([keyPath isEqualToString:@"contentOffset"] == YES)) {
        [self scrollViewDidScrollWithOffset:self.tableView.contentOffset.y];
    }
    else if ((object == self.mapView) &&
        ([keyPath isEqualToString:@"userTrackingMode"] == YES)) {
    }
}

- (void)scrollViewDidScrollWithOffset:(CGFloat)scrollOffset
{
    if ((self.isMapFullScreen == NO) &&
        (self.isMapAnimating == NO)) {
        CGFloat mapFrameYAdjustment = 0.0;
        
        // If the user is pulling down
        if (scrollOffset < 0) {
            
            // Pull to expand map?
            if (self.pullToExpandMapEnabled &&
                (self.isMapAnimating == NO) &&
                (scrollOffset <= -self.amountToScrollToFullScreenMap)) {
                [self expandMapView:self];
            }
            else {
                mapFrameYAdjustment = self.defaultMapViewFrame.origin.y - (scrollOffset * self.parallaxScrollFactor);
            }
        }
        
        // If the user is scrolling normally,
        else {
            mapFrameYAdjustment = self.defaultMapViewFrame.origin.y - (scrollOffset * self.parallaxScrollFactor);
            
            // Don't move the map way off-screen
            if (mapFrameYAdjustment <= -(self.defaultMapViewFrame.size.height)) {
                mapFrameYAdjustment = -(self.defaultMapViewFrame.size.height);
            }
        }
        
        if (mapFrameYAdjustment) {
            CGRect newMapFrame = self.mapView.frame;
            newMapFrame.origin.y = mapFrameYAdjustment;
            self.mapView.frame = newMapFrame;
        }
    }
}

@end
