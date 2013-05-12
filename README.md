LocationPickerView
============================

MKMapView + UITableView + Parallax scrolling. Provides a framework for building an interactive location picker on iOS.

This view is useful for when a list of scrollable, selectable locations need to be shown along with their locations on map. A search bar can easily be added for searching or filtering.

<table>
  <tr>
    <td><img src="https://raw.github.com/mstrchrstphr/LocationPickerView/master/github-images/01.png"/></td>
    <td><img src="https://raw.github.com/mstrchrstphr/LocationPickerView/master/github-images/02.png"/></td>
  </tr>
</table>

## Usage

1. Drop the **LocationPickerView** folder into you app. 
2. In the view controlller you'd like to use the location picker in, add the following lines to `viewDidLoad`:

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

[self.view addSubview:self.locationPickerView];
```

Of particular use is the `delegate` property which allows you to know when important things are happening (like the map view is about to expand full screen).

## Upcoming Features / Items

* Add Podspec.
* Add map annotations that sync with table view.
* Add some basic search functionality.
* Add more map controls (zooming, following user location, etc).

## Contributing

1. Fork
2. Code
3. Comment :)

## License

The MIT License (MIT)

Copyright (c) 2013 Christopher Constable

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.