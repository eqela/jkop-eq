
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

IFDEF("target_wp8cs")
{
	public class LocationManagerBackend : LocationManagerBase
	{
		static LocationManagerBackend _instance;

		public static LocationManagerBackend instance() {
			if(_instance == null) {
				_instance = new LocationManagerBackend();
			}
			return(_instance);
		}

		embed "cs" {{{
			private Windows.Devices.Geolocation.Geolocator geolocator = null;
		}}}

		public LocationManagerBackend() {
			embed "cs" {{{
				geolocator = new Windows.Devices.Geolocation.Geolocator();
				geolocator.DesiredAccuracy = Windows.Devices.Geolocation.PositionAccuracy.High;
				geolocator.ReportInterval = 1;
			}}}
		}

		public bool start_location_updates() {
			embed "cs" {{{
				if(!System.IO.IsolatedStorage.IsolatedStorageSettings.ApplicationSettings.Contains("LocationConsent")) {
					showDialog();
				}
				if((bool)System.IO.IsolatedStorage.IsolatedStorageSettings.ApplicationSettings["LocationConsent"] == false) {
					return(false);
				}
				geolocator.PositionChanged += geolocator_PositionChanged;	
			}}}
			return(true);
		}

		public bool stop_location_updates() {
			embed "cs" {{{
				geolocator.PositionChanged -= geolocator_PositionChanged;
			}}}
			return(true);
		}

		private void update_location(double latitude, double longitude) {
			Location location = new Location();
			location.set_latitude(latitude);
			location.set_longitude(longitude);
			notify_listeners(location);
		}

		embed "cs" {{{
			void geolocator_PositionChanged(Windows.Devices.Geolocation.Geolocator sender, Windows.Devices.Geolocation.PositionChangedEventArgs args)
			{
				System.Windows.Deployment.Current.Dispatcher.BeginInvoke(() =>
				{
					update_location(args.Position.Coordinate.Latitude, args.Position.Coordinate.Longitude);
				});
			}

			void showDialog() {
				System.Windows.MessageBoxResult result = System.Windows.MessageBox.Show("This app accesses your phone's location. Is that ok?", 
					"Location",
					System.Windows.MessageBoxButton.OKCancel);
				if(result == System.Windows.MessageBoxResult.OK)
				{
					System.IO.IsolatedStorage.IsolatedStorageSettings.ApplicationSettings["LocationConsent"] = true;
				}
				else
				{
					System.IO.IsolatedStorage.IsolatedStorageSettings.ApplicationSettings["LocationConsent"] = false;
				}
				System.IO.IsolatedStorage.IsolatedStorageSettings.ApplicationSettings.Save();
			}
		}}}
	}
}

ELSE
{
	public class LocationManagerBackend : LocationManagerBase
	{
		public static LocationManagerBackend instance() {
			return(null);
		}
	}
}
