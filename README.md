# Project 2 - Yelp

Yelp is a Yelp search app using the [Yelp API](http://www.yelp.com/developers/documentation/v2/search_api).

## User Stories

The following **required** functionality is completed:

- [x] Search results page
   - [x] Table rows should be dynamic height according to the content height.
   - [x] Custom cells should have the proper Auto Layout constraints.
   - [x] Search bar should be in the navigation bar (doesn't have to expand to show location like the real Yelp app does).
- [x] Filter page. 
   - [x] The filters you should actually have are: category, sort (best match, distance, highest rated), distance, deals (on/off).
   - [x] The filters table should be organized into sections as in the mock.
   - [x] use the default UISwitch for on/off states.
   - [x] Clicking on the "Search" button should dismiss the filters page and trigger the search w/ the new filter settings.
   - [ ] Display some of the available Yelp categories (choose any 3-4 that you want).

The following **optional** features are implemented:

- [x] Search results page
   - [x] Infinite scroll for restaurant results.
   - [x] Implement map view of restaurant results.
   - [x] Loading indicator displayed while fetching results.
- [x] Filter page
   - [ ] Implement a custom switch instead of the default UISwitch.
   - [x] Distance filter should expand as in the real Yelp app.
   - [x] Categories should show a subset of the full list with a "See All" row to expand. Category list is [here](http://www.yelp.com/developers/documentation/category_list).
- [x] Restaurant detail page
   - [x] Implement the restaurant detail page. (Note: most of this page is not functional. My main focus was on replicating the Yelp UI, and getting the parallex effect/fade working.)

The following **additional** features are implemented:

- [x] Search results page
   - [x] Map view zooms to fit business annotations.
   - [x] Switch between the table and map views.
- [x] Filter page
   - [x] Sort by filter should expand as in the real Yelp app.
- [x] Restaurant detail page
   - [x] Implement a layout similiar to the actual Yelp app.
   - [x] Add paralax to display image view when scrolling.

## TODO



## Video Walk-through

Here's a walk-through of implemented user stories:

![Video Walk-through](Yelp.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

## License

    Copyright 2016 Raikirat Sohi

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.