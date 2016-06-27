
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

public class IOSPokkt : Pokkt
{
	embed "objc" {{{
		#import "PokktController.h"
		#import "PokktManager.h"
		#import "VideoResponse.h"
		
		@interface MyPokktDelegate : UIViewController<PokktDelegate>
		@property void* myself;
		@end

		@implementation MyPokktDelegate
		- (void)didFinishedVideoDownload:(BOOL)isFinished
		{
			eq_ext_pokkt_IOSPokkt_on_download_finished(self.myself, YES);
		}
		- (void)didFailedVideoDownload:(NSError *)error
		{
			NSString* error_msg = [[NSString alloc] initWithString:[error description]];
			eq_ext_pokkt_IOSPokkt_on_download_failed(self.myself, [error_msg UTF8String]);
		}
		- (void)onVideoDisplayed{
			eq_ext_pokkt_IOSPokkt_on_video_displayed(self.myself);
		}
		- (void)onVideoCompleated:(BOOL)isCompleated
		{
			eq_ext_pokkt_IOSPokkt_on_video_completed(self.myself);
		}
		- (void)onVideoSkiped
		{
			eq_ext_pokkt_IOSPokkt_on_video_skipped(self.myself);
		}
		- (void)onVideoGratified:(VideoResponse*)videoResponse
		{
			int point = [videoResponse.coins intValue];
			eq_ext_pokkt_IOSPokkt_on_gratified(self.myself, point);
		}
		-(void)onVideoClosed {
			eq_ext_pokkt_IOSPokkt_on_video_closed(self.myself);
		}
		@end
	}}}

	ptr myManager;

	public void on_download_finished(bool is_finished) {
		var vl = get_video_listener();
		if(vl != null) {
			vl.on_download_completion(6);	
		}
	}

	public void on_download_failed(strptr error) {
		var vl = get_video_listener();
		if(vl != null) {	
			vl.on_download_failed(String.for_strptr(error).dup());
		}
	}

	public void on_video_displayed() {
		var vl = get_video_listener();
		if(vl != null) {	
			vl.on_video_displayed();
		}
	}

	public void on_video_completed() {
		var vl = get_video_listener();
		if(vl != null) {	
			vl.on_video_completed();
		}
	}

	public void on_video_skipped() {
		var vl = get_video_listener();
		if(vl != null) {	
			vl.on_video_skipped();
		}
	}

	public void on_gratified(int points) {
		var vl = get_video_listener();
		if(vl != null) {	
			vl.on_video_gratified(points);
		}
	}

	public void on_video_closed() {
		var vl = get_video_listener();
		if(vl != null) {
			vl.on_video_closed();
		}
	}	
	
	public bool initialize(Frame f) {
		String key = get_security_key();
		String app_id = get_application_id();
		String user_id = get_user_id();
		strptr keyp = null;
		if(key != null) {
			keyp = key.to_strptr();
		}
		strptr appp = null;
		if(app_id != null) {
			appp = app_id.to_strptr();
		}
		strptr usrp = null;
		if(user_id != null) {
			usrp = user_id.to_strptr();
		}
		var video_listener = get_video_listener();
		String type = String.for_integer(get_integration_type());
		strptr typep = null;
		if(type != null) {
			typep = type.to_strptr();
		}
		bool skip = get_skip_video();
		bool b = false;
		ptr uiview;
		if(f is UIKitFrame) {
			uiview = ((UIKitFrame)f).get_view_controller();
		}
		ptr myPokktManager;
		embed "objc" {{{
			UIViewController* uiv = (__bridge UIViewController*)uiview;
			NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSString stringWithUTF8String:keyp], SECURITY_KEY,
			[NSString stringWithUTF8String:appp], APPLICATION_ID,
			[NSString stringWithUTF8String:usrp], USER_ID,
			[NSString stringWithUTF8String:typep], INTEGRATION_TYPE, 
			nil];
			PokktManager *pokktManager = [PokktManager sharedInstance: userDict];
			MyPokktDelegate* del = [[MyPokktDelegate alloc] init];
			del.myself = self;
			[pokktManager setDebugger:NO];
			[pokktManager cacheVideoCampaign];
			[pokktManager setSkipVideo:skip];
			[pokktManager setPokktDelegate:del];
			[pokktManager setPresentView: uiv];
			myPokktManager = (__bridge_retained void*)pokktManager;
			b = true;
		}}}
		myManager = myPokktManager;
		return(b);
	}

	public bool is_video_available() {
		if(myManager == null) {
			return(false);
		}
		ptr manager = myManager;
		embed "objc" {{{
			PokktManager *pokktManager = (__bridge PokktManager*)manager;
			return[pokktManager isVideoAvailable];
		}}}
		return(false);
	}

	public void play_video_campaign(bool is_incent, String title) {
		if(myManager == null) {
			return;
		}
		ptr manager = myManager;
		bool val = is_incent;
		embed "objc" {{{
			PokktManager *pokktManager = (__bridge PokktManager*)manager;
			if([pokktManager isVideoAvailable] == YES) {
				[pokktManager playVideoCampaign:val];	
			}
		}}}
	}

	public void show_offerwall() {
		return;
	}
}
