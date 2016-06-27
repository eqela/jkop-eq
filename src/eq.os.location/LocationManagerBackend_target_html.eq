
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

	public bool start_location_updates() {
		embed "js" {{{
			if(!navigator.geolocation) {
				return(false);
			}
			navigator.geolocation.watchPosition(positionCallBack);
		}}}
		return(true);
	}

	public bool stop_location_updates() {
		embed "js" {{{
			if(!navigator.geolocation) {
				return(false);
			}
			navigator.geolocation.clearWatch(positionCallBack);
		}}}
		return(true);
	}

	embed "js" {{{
		function positionCallBack(position) {
			eq.os.location.LocationManagerBackend.prototype.update_location.call(eq.os.location.LocationManagerBackend.eq_os_location_LocationManagerBackend__instance, position.coords.latitude, position.coords.longitude);
		}
	}}}

	private void update_location(double latitude, double longitude) {
		Location location = new Location();
		location.set_latitude(latitude);
		location.set_longitude(longitude);
		notify_listeners(location);
	}
}
