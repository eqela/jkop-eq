
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

public class AndroidAdMobView
{
	public static bool apply_to_frame(Frame frame, String id, Collection test_devices = null) {
		if(String.is_empty(id) || frame == null) {
			return(false);
		}
		Surface v;
		IFDEF("target_android") {
			embed "java" {{{
				if(frame instanceof eq.gui.sysdep.android.FrameViewGroup == false) {
					return(false);
				}
				android.view.View existing = ((eq.gui.sysdep.android.FrameViewGroup)frame).get_bottom_view();
				if(existing != null && existing instanceof com.google.android.gms.ads.AdView) {
					return(false);
				}
				com.google.android.gms.ads.AdView adv = new com.google.android.gms.ads.AdView(
					eq.api.Android.context);
				adv.setAdSize(com.google.android.gms.ads.AdSize.SMART_BANNER);
				adv.setAdUnitId(id.to_strptr());
				com.google.android.gms.ads.AdRequest.Builder rrb = new com.google.android.gms.ads.AdRequest.Builder();
				rrb.addTestDevice(com.google.android.gms.ads.AdRequest.DEVICE_ID_EMULATOR);
			}}}
			foreach(String device in test_devices) {
				embed "java" {{{
					rrb.addTestDevice(device.to_strptr());
				}}}
			}
			int wr, hr;
			embed "java" {{{
				adv.loadAd(rrb.build());
				adv.resume();
				adv.setAdListener(new com.google.android.gms.ads.AdListener() {
					public void onAdLoaded() {
						super.onAdLoaded();
						System.out.println("ADMOB: Ad loaded");
					}
					public void onAdOpened() {
						System.out.println("ADMON: Ad opened");
					}
					public void onAdFailedToLoad(int cc) {
						if(cc == com.google.android.gms.ads.AdRequest.ERROR_CODE_INTERNAL_ERROR) {
							System.out.println("ADMOB: INTERNAL ERROR");
						}
						else if(cc == com.google.android.gms.ads.AdRequest.ERROR_CODE_INVALID_REQUEST) {
							System.out.println("ADMOB: INVALID REQUEST");
						}
						else if(cc == com.google.android.gms.ads.AdRequest.ERROR_CODE_NETWORK_ERROR) {
							System.out.println("ADMOB: NETWORK ERROR");
						}
						else if(cc == com.google.android.gms.ads.AdRequest.ERROR_CODE_NO_FILL) {
							System.out.println("ADMOB: NO FILL");
						}
						else {
							System.out.println("ADMOB: UNKNOWN ERROR");
						}
					}
		        });
				((eq.gui.sysdep.android.FrameViewGroup)frame).set_bottom_view(adv);
			}}}
		}
		return(true);
	}

	public static void remove_from_frame(Frame frame) {
		embed {{{
			if(frame != null && frame instanceof eq.gui.sysdep.android.FrameViewGroup) {
				((eq.gui.sysdep.android.FrameViewGroup)frame).set_bottom_view(null);
			}
		}}}
	}
}
