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
    self.autoresizesSubviews        = YES;
    self.autoresizingMask           = UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleHeight;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.delegate = self.tableViewDelegate;
        self.tableView.dataSource = self.tableViewDataSource;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        
        // Add scroll view KVO
        void *context = (__bridge void *)self;
        [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:context];
        
        [self addSubview:self.tableView];
        
        if ([self.delegate respondsToSelector:@selector(locationPicker:tableViewDidLoad:)]) {
            [self.delegate locationPicker:self tableViewDidLoad:self.tableView];
        }
        
        if (self.tableViewDidLoadBlock) {
            [self tableViewDidLoadBlock];
        }
    }
    
    if (!self.tableView.tableHeaderView) {
        CGRect tableHeaderViewFrame = CGRectMake(0.0, 0.0, self.tableView.frame.size.width, self.defaultMapHeight);
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        self.tableView.tableHeaderView = tableHeaderView;
    }
    
    if (!self.mapView) {
        self.defaultMapViewFrame = CGRectMake(0.0, -100.0, 320.0, self.defaultMapHeight + 100.0f);
        _mapView = [[MKMapView alloc] initWithFrame:self.defaultMapViewFrame];
        self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.mapView.scrollEnabled = NO;
        self.mapView.zoomEnabled = NO;
        self.mapView.delegate = self.mapViewDelegate;
        [self insertSubview:self.mapView aboveSubview:self.tableView];
        
        if ([self.delegate respondsToSelector:@selector(locationPicker:mapViewDidLoad:)]) {
            [self.delegate locationPicker:self mapViewDidLoad:self.mapView];
        }
        
        if (self.mapViewDidLoadBlock) {
            [self mapViewDidLoadBlock];
        }
    }
    
    // Add tap gesture to map
    if (!self.mapTapGesture) {
        self.mapTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(mapWasTapped:)];
        self.mapTapGesture.cancelsTouchesInView = YES;
        self.mapTapGesture.delaysTouchesBegan = NO;
        [self.mapView addGestureRecognizer:self.mapTapGesture];
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
        [self tableViewDidLoadBlock];
    }
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    
    if ([self.delegate respondsToSelector:@selector(locationPicker:mapViewDidLoad:)]) {
        [self.delegate locationPicker:self mapViewDidLoad:self.mapView];
    }
    
    if (self.mapViewDidLoadBlock) {
        [self mapViewDidLoadBlock];
    }
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
        self.closeMapButton.frame = CGRectMake(14.0, 14.0, 42.0, 42.0);
        [self.closeMapButton setImage:[UIImage imageForXIcon] forState:UIControlStateNormal];
        [self.closeMapButton setImage:[UIImage imageForXIcon] forState:UIControlStateHighlighted];
        [self.closeMapButton addTarget:self action:@selector(hideMapView:) forControlEvents:UIControlEventTouchUpInside];
        self.closeMapButton.hidden = YES;
        
        [self insertSubview:self.closeMapButton aboveSubview:self.mapView];
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

#pragma mark - Public Methods

- (void)expandMapView:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(locationPicker:mapViewWillExpand:)]) {
        [self.delegate locationPicker:self mapViewWillExpand:self.mapView];
    }
    
    self.isMapAnimating = YES;
    [self.mapView removeGestureRecognizer:self.mapTapGesture];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.mapView.frame = self.bounds;
                     } completion:^(BOOL finished) {
                         self.isMapAnimating = NO;
                         _isMapFullScreen = YES;
                         self.mapView.scrollEnabled = YES;
                         self.mapView.zoomEnabled = YES;
                         
                         if ([self.delegate respondsToSelector:@selector(locationPicker:mapViewDidExpand:)]) {
                             [self.delegate locationPicker:self mapViewDidExpand:self.mapView];
                         }
                         
                         if (self.shouldCreateHideMapButton) {
                             [self showCloseMapButton];
                         }
                     }];
}

- (void)hideMapView:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(locationPicker:mapViewWillBeHidden:)]) {
        [self.delegate locationPicker:self mapViewWillBeHidden:self.mapView];
    }
    
    if (self.shouldCreateHideMapButton) {
        [self hideCloseMapButton];
    }
    
    self.isMapAnimating = YES;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    [self.mapView addGestureRecognizer:self.mapTapGesture];
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.mapView.frame = self.defaultMapViewFrame;
                     } completion:^(BOOL finished) {
                         self.isMapAnimating = NO;
                         _isMapFullScreen = NO;
                         
                         if ([self.delegate respondsToSelector:@selector(locationPicker:mapViewWasHidden:)]) {
                             [self.delegate locationPicker:self mapViewWasHidden:self.mapView];
                         }
                     }];
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
        return;
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
            mapFrameYAdjustment = self.defaultMapViewFrame.origin.y - scrollOffset;
            
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
