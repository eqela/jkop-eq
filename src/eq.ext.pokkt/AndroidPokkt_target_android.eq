
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

private class AndroidPokkt : Pokkt
{
	embed "java" {{{
		class MyVideoListener implements com.app.pokktsdk.DownloadCompleteListener, com.app.pokktsdk.VideoDisplayedListener, 
			com.app.pokktsdk.VideoCompletedListener, com.app.pokktsdk.VideoSkippedListener, com.app.pokktsdk.VideoClosedListener, com.app.pokktsdk.VideoGratifiedListener
		{
			public MyVideoListener(eq.ext.pokkt.PokktVideoListener listener) {
				this.listener = listener;
			}
			
			eq.ext.pokkt.PokktVideoListener listener;
			
			@Override
			public void onDownloadCompletion(float result) {
				if(listener != null) {
					listener.on_download_completion((double)result);
				}
			}
			@Override
			public void onDownloadFailed(String message) {
				if(listener != null) {
					listener.on_download_failed(eq.api.String.Static.for_strptr(message));
				}
			}
			@Override
			public void onVideoDisplayed() {
				if(listener != null) {
					listener.on_video_displayed();
				}
			}
			@Override
			public void onVideoCompleted() {
				if(listener != null) {
					listener.on_video_completed();
				}
			}
			@Override
			public void onVideoSkipped() {
				if(listener != null) {
					listener.on_video_skipped();
				}
			}
			@Override
			public void onVideoClosed(boolean val) {
				if(listener != null) {
					listener.on_video_closed();
				}
			}
			@Override
			public void onVideoGratified(com.app.pokktsdk.model.VideoResponse videoResponse) {
				if("1".equalsIgnoreCase(videoResponse.getCoinStatus())) {
					if(listener != null) {
						listener.on_video_gratified(java.lang.Integer.parseInt(videoResponse.getCoins()));
					}
				}
				else {
					if(listener != null) {
						listener.on_video_gratified(0);
					}
				}
			}
		}
	}}}
	
	embed "java" {{{
		com.app.pokktsdk.PokktManager pokktManager;
	}}}

	public bool initialize(Frame f = null) {
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
		var offer_wall_listener = get_offer_wall_listener();
		int type = get_integration_type();
		bool skip = get_skip_video();
		bool b = false;
		embed "java" {{{
			java.util.HashMap<String,Object> metaMap = new java.util.HashMap<String,Object>();
			metaMap.put(com.app.pokktsdk.PokktManager.SECURITY_KEY, keyp);
			metaMap.put(com.app.pokktsdk.PokktManager.APPLICATION_ID, appp);
			metaMap.put(com.app.pokktsdk.PokktManager.INTEGRATION_TYPE, type);
			metaMap.put(com.app.pokktsdk.PokktManager.AUTO_CACHE_VIDEO, true);
			metaMap.put(com.app.pokktsdk.PokktManager.USER_ID, usrp);
			pokktManager = com.app.pokktsdk.PokktManager.getInstance(eq.api.Android.context, metaMap);
			MyVideoListener vl = new MyVideoListener(video_listener);
			pokktManager.setDownloadCompletionlListener(vl);
			pokktManager.setVideoDisplayedListener(vl);
			pokktManager.setVideoCompletedListener(vl);
			pokktManager.setVideoSkippedListener(vl);
			pokktManager.setVideoClosedListener(vl);
			pokktManager.setVideoGratifiedListener(vl);
			pokktManager.setSkipVideo(skip);
			com.app.pokktsdk.PokktManager.setDebug(false);
			eq.ext.pokkt.PokktCallBackReceiver offerwall_receiver = new eq.ext.pokkt.PokktCallBackReceiver();
			offerwall_receiver.registerBroadcastReceiver(offer_wall_listener);
			b = true;
		}}}
		return(b);
	}

	public override void show_offerwall() {
		embed "java" {{{
			if(pokktManager != null) {
				pokktManager.getCoins(eq.api.Android.context, true);
			}
		}}}
	}

	public override void play_video_campaign(bool is_incent, String title) {
		if(String.is_empty(title)) {
			return;
		}
		embed "java" {{{
			if(pokktManager != null) {
				if(pokktManager.isVideoAvailable()) {
					pokktManager.playVideoCampaign(is_incent, title.to_strptr());
				}
			}
		}}}
	}

	public override bool is_video_available() {
		embed "java" {{{
			if(pokktManager != null) {
				return(pokktManager.isVideoAvailable());
			}
		}}}
		return(false);
	}
}
