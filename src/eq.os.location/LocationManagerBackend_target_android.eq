
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

class LocationManagerBackend : LocationManagerBase
{
	static LocationManagerBackend _instance;

	public static LocationManagerBackend instance() {
		if(_instance == null) {
			_instance = new LocationManagerBackend();
		}
		return(_instance);
	}

	embed "java" {{{
		private android.location.LocationManager locationManager;
		private LocationCallBack lcb;
	}}}

	public LocationManagerBackend() {
		embed "java" {{{
			lcb = new LocationCallBack(this);
			locationManager = (android.location.LocationManager)eq.api.Android.context
						.getSystemService(eq.api.Android.context.LOCATION_SERVICE);
		}}}
	}

	public bool start_location_updates() {
		embed "java" {{{
			boolean isGPSEnabled = false;
			boolean isNetworkEnabled = false;
			try {
				isGPSEnabled = locationManager.isProviderEnabled(android.location.LocationManager.GPS_PROVIDER);
				isNetworkEnabled = locationManager.isProviderEnabled(android.location.LocationManager.NETWORK_PROVIDER);
				if(isGPSEnabled) {
					locationManager.requestLocationUpdates(android.location.LocationManager.GPS_PROVIDER, 0, 0, lcb);
				}
				else if(isNetworkEnabled) {
					locationManager.requestLocationUpdates(android.location.LocationManager.NETWORK_PROVIDER, 0, 0, lcb);
				}
				else {
					return(false);
				}
			} catch (java.lang.Exception e) {
			}
		}}}
		return(true);
	}

	public bool stop_location_updates() {
		embed "java" {{{
			if(locationManager != null) {
				locationManager.removeUpdates(lcb);
				return(true);
			}
		}}}
		return(false);
	}

	embed "java" {{{
		class LocationCallBack implements android.location.LocationListener {

			public LocationCallBack(LocationManagerBackend self) {
				this.self = self;
			}

			private LocationManagerBackend self;

			@Override
			public void onLocationChanged(android.location.Location location) {
				Location l = new Location();
				l.set_latitude(location.getLatitude());
				l.set_longitude(location.getLongitude());
				self.notify_listeners(l);
			}

			@Override
			public void onProviderDisabled(String provider) {
			}

			@Override
			public void onProviderEnabled(String provider) {
			}

			@Override
			public void onStatusChanged(String provider, int status, android.os.Bundle extras) {
			}
		}
	}}}
}
