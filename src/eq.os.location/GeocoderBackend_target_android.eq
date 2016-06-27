
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

	public bool query_address(double latitude, double longitude, GeocoderAddressListener listener) {
		embed "java" {{{
			if(!android.location.Geocoder.isPresent()) {
				return(false);
			}
			android.location.Geocoder geocoder = new android.location.Geocoder(eq.api.Android.context);
			android.location.Location location = new android.location.Location(android.location.LocationManager.GPS_PROVIDER);
			location.setLatitude(latitude);
			location.setLongitude(longitude);
			new GetAddressTask(listener).execute(location);	
		}}}
		return(true);
	}

	public bool query_location(String address, GeocoderLocationListener listener) {
		if(String.is_empty(address)) {
			return(false);
		}
		var paddress = address.to_strptr();
		embed "java" {{{
			if(!android.location.Geocoder.isPresent()) {
				return(false);
			}
			new GetLocationTask(listener).execute(paddress);
		}}}
		return(true);
	}

	embed "java" {{{
		private class GetLocationTask extends android.os.AsyncTask<java.lang.String, Void, android.location.Address>
		{
			public GetLocationTask(GeocoderLocationListener listener) {
				this.listener = listener;
			}

			private GeocoderLocationListener listener;

			protected android.location.Address doInBackground(java.lang.String... params) {
				java.lang.String locationName = params[0];
				java.util.List<android.location.Address> addresses = null;
				android.location.Geocoder geocoder = new android.location.Geocoder(eq.api.Android.context);
				try {
					addresses = geocoder.getFromLocationName(locationName, 1);
				}catch (java.lang.Exception e) {
					if(listener != null) {
						eq.api.String err_msg = eq.api.String.Static.for_strptr(e.getMessage());
						listener.on_query_location_error_received(eq.api.Error.Static.for_message(err_msg));
					}
				}
				if (addresses != null && addresses.size() > 0) {
					return(addresses.get(0));
				}
				return(null);
			}

			protected void onPostExecute(android.location.Address address) {
				if(address == null) {
					if(listener != null) {
						eq.api.String err_msg = eq.api.String.Static.for_strptr("Can't Find Location");
						listener.on_query_location_error_received(eq.api.Error.Static.for_message(err_msg));
					}
				}
				else {
					Location l = new Location();
					l.set_latitude(address.getLatitude());
					l.set_longitude(address.getLongitude());
					if(listener != null) {
						listener.on_query_location_completed(l);
					}
				}
			}
		}
		
		private class GetAddressTask extends android.os.AsyncTask<android.location.Location, Void, android.location.Address>
		{
			public GetAddressTask(GeocoderAddressListener listener) {
				this.listener = listener;
			}
			
			private GeocoderAddressListener listener;

			protected android.location.Address doInBackground(android.location.Location... params) {
				android.location.Location loc = params[0];
				java.util.List<android.location.Address> addresses = null;
				android.location.Geocoder geocoder = new android.location.Geocoder(eq.api.Android.context);
			 	try {
					addresses = geocoder.getFromLocation(loc.getLatitude(), loc.getLongitude(), 1);
				} catch (java.lang.Exception e) {
					if(listener != null) {
						eq.api.String err_msg = eq.api.String.Static.for_strptr(e.getMessage());
						listener.on_query_address_error_received(eq.api.Error.Static.for_message(err_msg));
					}
				}
				if(addresses != null && addresses.size() > 0) {
					return(addresses.get(0));
				}
				return(null);		
			}
			
			protected void onPostExecute(android.location.Address address) {
				if(address == null) {
					if(listener != null) {
						eq.api.String err_msg = eq.api.String.Static.for_strptr("Can't Find Address");
						listener.on_query_address_error_received(eq.api.Error.Static.for_message(err_msg));
					}
				}
				else {
					Address a = new Address();
					a.set_country(eq.api.String.Static.for_strptr(address.getCountryName()));
					a.set_country_code(eq.api.String.Static.for_strptr(address.getCountryCode()));
					a.set_administrative_area(eq.api.String.Static.for_strptr(address.getAdminArea()));
					a.set_sub_administrative_area(eq.api.String.Static.for_strptr(address.getSubAdminArea()));
					a.set_locality(eq.api.String.Static.for_strptr(address.getLocality()));
					a.set_sub_locality(eq.api.String.Static.for_strptr(address.getSubLocality()));
					a.set_thoroughfare(eq.api.String.Static.for_strptr(address.getThoroughfare()));
					a.set_sub_thoroughfare(eq.api.String.Static.for_strptr(address.getSubThoroughfare()));
					a.set_postal_code(eq.api.String.Static.for_strptr(address.getPostalCode()));
					if(listener != null) {
						listener.on_query_address_completed(a);
					}
				}
			}
		}
	}}}
}
