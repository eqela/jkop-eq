
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
	public class GeocoderBackend : Geocoder
	{
		public static GeocoderBackend instance() {
			return(new GeocoderBackend());
		}

		embed "cs" {{{
			private Microsoft.Phone.Maps.Services.ReverseGeocodeQuery reverseGeocodeQuery = null;
			private Microsoft.Phone.Maps.Services.GeocodeQuery forwardGeocodeQuery = null;
		}}}

		GeocoderAddressListener alistener;
		GeocoderLocationListener llistener;

		public GeocoderBackend () {
			embed "cs" {{{
				reverseGeocodeQuery = new Microsoft.Phone.Maps.Services.ReverseGeocodeQuery();
				forwardGeocodeQuery = new Microsoft.Phone.Maps.Services.GeocodeQuery();
			}}}
		}

		public bool query_address(double latitude, double longitude, GeocoderAddressListener alistener) {
			this.alistener = alistener;
			embed "cs" {{{
				try {
					if(reverseGeocodeQuery.IsBusy) {
						return(false);
					}
					reverseGeocodeQuery.GeoCoordinate = new System.Device.Location.GeoCoordinate(latitude, longitude);
					reverseGeocodeQuery.QueryCompleted += reverseGeocode_QueryCompleted;
					reverseGeocodeQuery.QueryAsync();
				}
				catch(System.Exception) {
				}
				
			}}}
			return(true);
		}

		public bool query_location(String address, GeocoderLocationListener llistener) {
			if(String.is_empty(address)) {
				return(false);
			}
			this.llistener = llistener;
			var paddress = address.to_strptr();
			embed "cs" {{{
				try {
					if(forwardGeocodeQuery.IsBusy) {
						return(false);
					}
					forwardGeocodeQuery.SearchTerm = paddress;
					forwardGeocodeQuery.GeoCoordinate = new System.Device.Location.GeoCoordinate();
					forwardGeocodeQuery.QueryCompleted += forwardGeocode_QueryCompleted;
					forwardGeocodeQuery.QueryAsync();
				}
				catch(System.Exception) {
				}
			}}}
			return(true);
		}

		embed "cs" {{{
			void reverseGeocode_QueryCompleted(System.Object sender, 
				Microsoft.Phone.Maps.Services.QueryCompletedEventArgs<System.Collections.Generic.IList<Microsoft.Phone.Maps.Services.MapLocation>> e)
			{
				System.Windows.Deployment.Current.Dispatcher.BeginInvoke(() =>
				{
					if(!(e.Error == null)) {
						if(alistener != null) {
							eq.api.String err_msg = eq.api.StringStatic.eq_api_StringStatic_for_strptr(e.Error.Message);
							alistener.on_query_address_error_received(eq.api.Error.eq_api_Error_for_message(err_msg));
						}
					}
					else {
						if(e.Result.Count <= 0) {
							if(alistener != null) {
								eq.api.String err_msg = eq.api.StringStatic.eq_api_StringStatic_for_strptr("Can't Find Address");
								alistener.on_query_address_error_received(eq.api.Error.eq_api_Error_for_message(err_msg));
							}
						}
						else {
							Microsoft.Phone.Maps.Services.MapAddress geoAddress = e.Result[0].Information.Address;
							Address a = new Address();
							a.set_country(eq.api.StringStatic.eq_api_StringStatic_for_strptr(geoAddress.Country));
							a.set_country_code(eq.api.StringStatic.eq_api_StringStatic_for_strptr(geoAddress.CountryCode));
							a.set_administrative_area(eq.api.StringStatic.eq_api_StringStatic_for_strptr(geoAddress.Province));
							a.set_sub_administrative_area(eq.api.StringStatic.eq_api_StringStatic_for_strptr(geoAddress.State));
							a.set_locality(eq.api.StringStatic.eq_api_StringStatic_for_strptr(geoAddress.City));
							a.set_sub_locality(eq.api.StringStatic.eq_api_StringStatic_for_strptr(geoAddress.District));
							a.set_thoroughfare(eq.api.StringStatic.eq_api_StringStatic_for_strptr(geoAddress.Street));
							a.set_sub_thoroughfare(eq.api.StringStatic.eq_api_StringStatic_for_strptr(geoAddress.Neighborhood));
							a.set_postal_code(eq.api.StringStatic.eq_api_StringStatic_for_strptr(geoAddress.PostalCode));
							if(alistener != null) {
								alistener.on_query_address_completed(a);
							}
						}
					}
				});
			}

			void forwardGeocode_QueryCompleted(System.Object sender, 
				Microsoft.Phone.Maps.Services.QueryCompletedEventArgs<System.Collections.Generic.IList<Microsoft.Phone.Maps.Services.MapLocation>> e)
			{
				System.Windows.Deployment.Current.Dispatcher.BeginInvoke(() =>
				{
					if(!(e.Error == null)) {
						if(llistener != null) {
							eq.api.String error_msg = eq.api.StringStatic.eq_api_StringStatic_for_strptr(e.Error.Message);
							llistener.on_query_location_error_received(eq.api.Error.eq_api_Error_for_message(error_msg));
						}
					}
					else {
						if(e.Result.Count <= 0) {
							if(llistener != null) {
								eq.api.String error_msg = eq.api.StringStatic.eq_api_StringStatic_for_strptr("Can't Find Location");
								llistener.on_query_location_error_received(eq.api.Error.eq_api_Error_for_message(error_msg));
							}
						}
						else {
							System.Device.Location.GeoCoordinate geoLocation = e.Result[0].GeoCoordinate;
							Location l = new Location();
							l.set_latitude(geoLocation.Latitude);
							l.set_longitude(geoLocation.Longitude);
							if(llistener != null) {
								llistener.on_query_location_completed(l);
							}
						}
					}
				});
			}
		}}}
	}
}

ELSE
{
	public class GeocoderBackend
	{
		public static Geocoder instance() {
			return(null);
		}

		public bool get_address(double latitude, double longitude, GeocoderAddressListener listener) {
			return(false);
		}

		public bool get_location(String address, GeocoderLocationListener listener) {
			return(false);
		}
	}
}