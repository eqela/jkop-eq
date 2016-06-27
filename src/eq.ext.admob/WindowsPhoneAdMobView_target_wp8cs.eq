
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

// NOTE: The Windows Phone implementation is not complete.
class WindowsPhoneAdMobView
{
	public static bool apply_to_frame(Frame frame, String id) {
		embed "cs" {{{
			if(frame == null || frame is eq.gui.sysdep.wpcs.FramePanel == false || id == null) {
				return(false);
			}
			eq.gui.sysdep.wpcs.FramePanel fp = (eq.gui.sysdep.wpcs.FramePanel)frame;
			GoogleAds.AdView ads = new GoogleAds.AdView {
				Format = GoogleAds.AdFormats.SmartBanner, AdUnitID = id.to_strptr()
			};
			System.Diagnostics.Debug.WriteLine("AD UNIT ID IS `" + id.to_strptr() + "'");
			ads.ReceivedAd += OnAdReceived;
            ads.FailedToReceiveAd += OnFailedToReceiveAd;
			fp.set_bottom_element(ads);
			GoogleAds.AdRequest req = new GoogleAds.AdRequest();
			// req.ForceTesting = true;
			ads.LoadAd(req);
		}}}
		return(false);
	}

	embed "cs" {{{
        private static void OnAdReceived(object sender, GoogleAds.AdEventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("Received ad successfully");
        }

        private static void OnFailedToReceiveAd(object sender, GoogleAds.AdErrorEventArgs errorCode)
        {
            System.Diagnostics.Debug.WriteLine("Failed to receive ad with BAD BAD error " + errorCode.ErrorCode);
        }
	}}}
	
	public static void remove_from_frame(Frame frame) {
	}
}
