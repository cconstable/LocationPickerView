//
//  ViewController.h
//  LocationPickerView-Demo
//
//  Created by Christopher Constable on 5/11/13.
//  Copyright (c) 2013 Christopher Constable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationPickerView.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, LocationPickerViewDelegate>

@property (nonatomic, strong) LocationPickerView *locationPickerView;

@end
