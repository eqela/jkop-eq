
/*
 * This file is part of Jkop
 * Copyright (c) 2016 Job and Esther Technologies, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

public class LocationManagerBackend : LocationManagerBase
{
	static LocationManagerBackend _instance;

	public static LocationManagerBackend instance() {
		if(_instance == null) {
			_instance = new LocationManagerBackend();
		}
		return(_instance);
	}

	embed "objc" {{{
		#import <CoreLocation/CLLocation.h>
		#import <CoreLocation/CLLocationManager.h>
		@interface MyDelegate : NSObject
		@property void* myself;
		@end
		@implementation MyDelegate
		- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
			CLLocation *location = [locations lastObject];
			eq_os_location_LocationManagerBackend_update_location(self.myself, location.coordinate.latitude, location.coordinate.longitude);
		}
		- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
			eq_os_location_LocationManagerBackend_update_location(self.myself, newLocation.coordinate.latitude, newLocation.coordinate.longitude);
		}
		- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
			NSString *error_msg = [[NSString alloc] initWithString:[error description]];
			NSLog(error_msg);
		}
		@end
	}}}

	ptr lm = null;
	ptr delegate = null;

	public LocationManagerBackend() {
		ptr p;
		ptr dd;
		embed "objc" {{{
			MyDelegate* mdg = [[MyDelegate alloc] init];
			mdg.myself = self;
			CLLocationManager* locManager = [[CLLocationManager alloc] init];
			locManager.delegate = mdg;
			p = (__bridge_retained void*)locManager;
			dd = (__bridge_retained void*)mdg;
		}}}
		lm = p;
		delegate = dd;
	}

	~LocationManagerBackend() {
		var p = lm;
		var dd = delegate;
		if(lm != null) {
			embed {{{
				(__bridge_transfer CLLocationManager*)p;
			}}}
			lm = null;
		}
		if(dd != null) {
			embed {{{
				(__bridge_transfer MyDelegate*)dd;
			}}}
			delegate = null;
		}
	}

	public bool start_location_updates() {
		var p = lm;
		embed "objc" {{{
			CLLocationManager* locManager = (__bridge CLLocationManager*)p;
			[locManager startUpdatingLocation];
		}}}
		return(true);
	}

	public bool stop_location_updates() {
		var p = lm;
		embed "objc" {{{
			[(__bridge CLLocationManager*)p stopUpdatingLocation];
		}}}
		return(true);
	}

	private void update_location(double latitude, double longitude) {
		Location location = new Location();
		location.set_latitude(latitude);
		location.set_longitude(longitude);
		notify_listeners(location);
	}
}
