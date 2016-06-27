
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

public class LocationManager
{
	public static bool start_location_updates(LocationListener listener = null) {
		var backend = LocationManagerBackend.instance();
		if(backend != null) {
			if(listener != null) {
				add_listener(listener);
			}
			return(backend.start_location_updates());
		}
		return(false);
	}

	public static bool stop_location_updates() {
		var backend = LocationManagerBackend.instance();
		if(backend != null) {
			return(backend.stop_location_updates());
		}
		return(false);
	}

	public static void add_listener(LocationListener listener) {
		var backend = LocationManagerBackend.instance();
		if(backend != null) {
			backend.add_listener(listener);
		}
	}

	public static void remove_listener(LocationListener listener) {
		var backend = LocationManagerBackend.instance();
		if(backend != null) {
			backend.remove_listener(listener);
		}
	}

	public static void remove_all_listeners() {
		var backend = LocationManagerBackend.instance();
		if(backend != null) {
			backend.remove_all_listeners();
		}
	}
}
