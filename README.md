LocationPickerView
============================

MKMapView + UITableView + Parallax scrolling. Provides a framework for building an interactive location picker on iOS.

This view is useful for when a list of scrollable, selectable locations need to be shown along with their locations on map. A search bar can easily be added for searching or filtering.

<p align="center">
    <img src="github-images/location-picker.gif"/></td>
</p>

## Install

### CocoaPods

`pod 'LocationPickerView', '~> 1.2.0'`

### Manual

Drop the **LocationPickerView** folder into your app. 

## Usage

In the view controlller you'd like to use the location picker in, add the following lines to `viewDidLoad`:

```
LocationPickerView *locationPickerView = [[LocationPickerView alloc] initWithFrame:self.view.bounds];
locationPickerView.tableViewDataSource = self;
locationPickerView.tableViewDelegate = self;
[self.view addSubview:self.locationPickerView];
```

Alternatively, you can setup the `LocationPickerView` in a Storyboard. Just set the view's class to `LocationPickerView`

![](https://raw.github.com/mstrchrstphr/LocationPickerView/master/github-images/03.png)

and be sure to hook up the table view delegate and datasource.

![](https://raw.github.com/mstrchrstphr/LocationPickerView/master/github-images/04.png)

## Advanced Usage

If you want to get fancy you can specify more options:


```
// Create the location picker
LocationPickerView *locationPickerView = [[LocationPickerView alloc] initWithFrame:self.view.bounds];
locationPickerView.tableViewDataSource = self;
locationPickerView.tableViewDelegate = self;

// Optional parameters
locationPickerView.delegate = self;
locationPickerView.shouldCreateHideMapButton = YES;
locationPickerView.pullToExpandMapEnabled = YES;
locationPickerView.defaultMapHeight = 190.0;
locationPickerView.parallaxScrollFactor = 0.4; // little slower than normal.
locationPickerView.backgroundViewColor = [UIColor yellowColor]; //set color to the tableView background without the map

// Optional setup
self.locationPickerView.mapViewDidLoadBlock = ^(LocationPickerView *locationPicker) {
    locationPicker.mapView.mapType = MKMapTypeStandard;
};
self.locationPickerView.tableViewDidLoadBlock = ^(LocationPickerView *locationPicker) {
    locationPicker.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
};

[self.view addSubview:self.locationPickerView];
```

Of particular use is the `delegate` property which allows you to know when important things are happening (like the map view is about to expand full screen).

NOTE: Don't set the `backgroundColor` property of the table view. Color your cells or the `LocationPickerView` instead.

## Feature Wishlist

* Add map annotations that sync with table view.
* Add some basic search functionality.
* Add more map controls (zooming, following user location, etc).

## Known Issues

* Currently, deselecting a cell with animation doesn't look so good. You'll need to animate this yourself but hey, you can make it fancy!

## Contributing

1. Fork
2. Code
3. Comment :)

## License

The MIT License Copyright (c) 2013 Christopher Constable
