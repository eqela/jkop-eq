
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

public class GeocoderBackend : Geocoder
{
	public static GeocoderBackend instance() {
		return(new GeocoderBackend());
	}

	embed "objc" {{{
		#import <CoreLocation/CLLocation.h>
		#import <CoreLocation/CLGeocoder.h>
		#import <CoreLocation/CLPlacemark.h>
	}}}

	ptr gc;

	public GeocoderBackend () {
		ptr p;
		embed "objc" {{{
			CLGeocoder *geocoder = [[CLGeocoder alloc] init];
			p = (__bridge_retained void*)geocoder;
		}}}
		gc = p;
	}

	public bool query_location(String address, GeocoderLocationListener listener) {
		if(String.is_empty(address)) {
			return(false);
		}
		var paddress = address.to_strptr();
		ptr p = gc;
		embed "objc" {{{
			NSString *nsLocation = [NSString stringWithUTF8String:paddress];
			ref_eq_api_Object(self);
			[(__bridge CLGeocoder*)p geocodeAddressString:nsLocation
			completionHandler:^(NSArray* placemarks, NSError* error){
				if(error) {
					NSString *error_msg = [[NSString alloc] initWithString:[error description]];
					eq_os_location_GeocoderBackend_on_query_location_error_received(self, [error_msg UTF8String], listener);
				}
				else {
					if([placemarks count] <= 0) {
						NSString *error_msg = @"Can't Find Location";
						eq_os_location_GeocoderBackend_on_query_location_error_received(self, [error_msg UTF8String], listener);
					}
					else {
						CLPlacemark *pm = [placemarks lastObject];
						CLLocation *location = pm.location;
						eq_os_location_GeocoderBackend_on_location_response(self, (__bridge void*)location, listener);
					}
				}
				unref_eq_api_Object(self);			
			}];
		}}}
		return(true);
	}

	public bool query_address(double latitude, double longitude, GeocoderAddressListener listener) {
		ptr p = gc;
		embed "objc" {{{
			CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
			ref_eq_api_Object(self);
			[(__bridge CLGeocoder*)p reverseGeocodeLocation:location 
			completionHandler: ^(NSArray* placemarks, NSError* error) {
				if(error) {
					NSString *error_msg = [[NSString alloc] initWithString:[error description]];
					eq_os_location_GeocoderBackend_on_query_address_error_received(self, [error_msg UTF8String], listener);
				}
				else {
					if([placemarks count] <= 0) {
						NSString *error_msg = @"Can't Find Address";
						eq_os_location_GeocoderBackend_on_query_address_error_received(self, [error_msg UTF8String], listener);
					}
					else {
						CLPlacemark *pm = [placemarks lastObject];
						eq_os_location_GeocoderBackend_on_address_response(self, (__bridge void*)pm, listener);
					}
				}
				unref_eq_api_Object(self);
			}];
		}}}
		return(true);
	}

	private void on_query_address_error_received(ptr error, GeocoderAddressListener l) {
		if(l != null) {
			l.on_query_address_error_received(Error.for_message(String.for_strptr(error)));
		}
	}

	private void on_query_location_error_received(ptr error, GeocoderLocationListener l) {
		if(l != null) {
			l.on_query_location_error_received(Error.for_message(String.for_strptr(error)));
		}
	}

	private void on_location_response(ptr p, GeocoderLocationListener l) {
		double latitude;
		double longitude;
		embed "objc" {{{
			CLLocation *loc = (__bridge CLLocation*)p;
			latitude = loc.coordinate.latitude;
			longitude = loc.coordinate.longitude;
		}}}
		var location = new Location();
		location.set_latitude(latitude);
		location.set_longitude(longitude);
		if(l != null) {
			l.on_query_location_completed(location);
		}
	}

	private void on_address_response(ptr p, GeocoderAddressListener l) {
		strptr pcountry;
		strptr pcountry_code;
		strptr padministrative_area;
		strptr psub_administrative_area;
		strptr plocality;
		strptr psub_locality;
		strptr pthoroughfare;
		strptr psub_thoroughfare;
		strptr ppostal_code;
		embed "objc" {{{
			CLPlacemark *pm = (__bridge CLPlacemark*)p;
			pcountry = [pm.country UTF8String];
			pcountry_code = [pm.ISOcountryCode UTF8String];
			padministrative_area = [pm.administrativeArea UTF8String];
			psub_administrative_area = [pm.subAdministrativeArea UTF8String];
			plocality = [pm.locality UTF8String];
			psub_locality = [pm.subLocality UTF8String];
			pthoroughfare = [pm.thoroughfare UTF8String];
			psub_thoroughfare = [pm.subThoroughfare UTF8String];
			ppostal_code = [pm.postalCode UTF8String];
		}}}
		Address a = new Address();
		a.set_country(String.for_strptr(pcountry));
		a.set_country_code(String.for_strptr(pcountry_code));
		a.set_administrative_area(String.for_strptr(padministrative_area));
		a.set_sub_administrative_area(String.for_strptr(psub_administrative_area));
		a.set_locality(String.for_strptr(plocality));
		a.set_sub_locality(String.for_strptr(psub_locality));
		a.set_thoroughfare(String.for_strptr(pthoroughfare));
		a.set_sub_thoroughfare(String.for_strptr(psub_thoroughfare));
		a.set_postal_code(String.for_strptr(ppostal_code));
		if(l != null) {
			l.on_query_address_completed(a);
		}
	}
}
