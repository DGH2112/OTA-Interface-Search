# OTA-Interface-Search

Author:   David Hoyle

Version:  1.3

Date:     12 Jan 2020

Web Page: [Open Tools API Interface Search](https://www.davidghoyle.co.uk/WordPress/?page_id=1481)

## Overview

This application is designed to allow the user to search the Open Tools API .pas files for interfaces, methods and properties and to aid the user in finding paths to various interfaces, method and properties from different aspects of the API.

In order to compile the software yourself you will need the following components:

* Virtual Treeview V6.x or above;
* SynEdit.

## Use

The first thing you will have to do is configure the file OTA Tools API file list to pooint to oen or more `.pas` files in which to search (generally the `Source\TooslAPI\` folder of your RAD Studio installations).

Then type a regular expression in the first search box and the list of interfaces, classes, methods and properties of the OTA files will be filtered for only those that contain the regular expression.

If you select a line in the filter treeview the code window below will show you the OTA code associated with the line. If you display the Creation Paths view, the application will attempt to find a code path within the OTA that allows you to create / access the interfaces search requested.

The secondary Target search can be used to find the starting point of a creation path search.

## Current Limitations

There are no know issues at this time.

## Source Code and Binaries

You can download a binary of this project if you don't want to compile it yourself from the web page above.
