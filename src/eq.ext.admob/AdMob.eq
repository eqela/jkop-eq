
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

public class AdMob
{
	public static bool apply_to_frame(Frame frame, String id, Collection test_devices = null) {
		IFDEF("target_android") {
			return(AndroidAdMobView.apply_to_frame(frame, id, test_devices));
		}
		ELSE IFDEF("target_wpcs") {
			return(WindowsPhoneAdMobView.apply_to_frame(frame, id));
		}
		ELSE IFDEF("target_ios") {
			return(IOSAdMobView.apply_to_frame(frame, id, test_devices));
		}
		ELSE {
			return(false);
		}
	}

	public static bool initialize_interstitial(String id, Collection test_devices = null) {
		IFDEF("target_android") {
			return(AndroidAdMobInterstitialView.initialize_interstitial(id, test_devices));
		}
		ELSE IFDEF("target_ios") {
			return(IOSAdMobInterstitialAdView.initialize_interstitial(id, test_devices));
		}
		ELSE {
			return(false);
		}
	}

	public static void show_interstitial(Frame frame = null) {
		IFDEF("target_android") {
			AndroidAdMobInterstitialView.show_interstitial();
		}
		ELSE IFDEF("target_ios") {
			IOSAdMobInterstitialAdView.show_interstitial(frame);
		}
	}

	public static void remove_from_frame(Frame frame) {
		IFDEF("target_android") {
			AndroidAdMobView.remove_from_frame(frame);
		}
		ELSE IFDEF("target_wpcs") {
			WindowsPhoneAdMobView.remove_from_frame(frame);
		}
		ELSE IFDEF("target_ios") {
			IOSAdMobView.remove_from_frame(frame);
		}
	}
}
