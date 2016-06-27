
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

public class AndroidAdMobInterstitialView
{
	embed "java" {{{
		static com.google.android.gms.ads.InterstitialAd interstitial;
	}}}

	public static bool initialize_interstitial(String id, Collection test_devices = null) {
		if(String.is_empty(id)) {
			return(false);
		}
		IFDEF("target_android") {
			embed "java" {{{
				interstitial = new com.google.android.gms.ads.InterstitialAd(eq.api.Android.context);
				interstitial.setAdUnitId(id.to_strptr());
				com.google.android.gms.ads.AdRequest.Builder request_builder = new com.google.android.gms.ads.AdRequest.Builder();
				request_builder.addTestDevice(com.google.android.gms.ads.AdRequest.DEVICE_ID_EMULATOR);
			}}}
			foreach(String device in test_devices) {
				embed "java" {{{
					request_builder.addTestDevice(device.to_strptr());
				}}}
			}
			embed "java" {{{
				interstitial.loadAd(request_builder.build());
			}}}
		}
		return(true);
	}

	public static void show_interstitial() {
		IFDEF("target_android") {
			embed "java" {{{
				if(interstitial != null) {
					if(interstitial.isLoaded()) {
						interstitial.show();
					}
				}
			}}}
		}
	}
}
