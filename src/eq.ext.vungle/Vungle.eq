
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

IFDEF("target_android") {
public class Vungle
{
	public static bool initialize(String id) {
		if(String.is_empty(id)) {
			return;
		}
		bool v = true;
		embed {{{
			try {
				com.vungle.publisher.VunglePub vungle =
					com.vungle.publisher.VunglePub.getInstance();
				vungle.init(eq.api.Android.context, id.to_strptr());
			}
			catch(Exception e) {
				e.printStackTrace();
				v = false;
			}
		}}}
		return(v);
	}

	public static void start() {
		embed {{{
			com.vungle.publisher.VunglePub vungle =
				com.vungle.publisher.VunglePub.getInstance();
			vungle.onResume();
		}}}
	}

	public static void stop() {
		embed {{{
			com.vungle.publisher.VunglePub vungle =
				com.vungle.publisher.VunglePub.getInstance();
			vungle.onPause();
		}}}
	}

	public static void play() {
		embed {{{
			com.vungle.publisher.VunglePub vungle =
				com.vungle.publisher.VunglePub.getInstance();
			vungle.playAd();
		}}}
	}

	public static void play_incentivized(String userid) {
		if(String.is_empty(userid)) {
			play();
			return;
		}
		embed {{{
			com.vungle.publisher.VunglePub vungle =
				com.vungle.publisher.VunglePub.getInstance();
			com.vungle.publisher.AdConfig config =
				new com.vungle.publisher.AdConfig();
			config.setIncentivized(true);
			config.setIncentivizedUserId(userid.to_strptr());
			vungle.playAd(config);
		}}}
	}
}
}

ELSE {
public class Vungle
{
	public static void initialize(String id) {
	}

	public static void start() {
	}

	public static void stop() {
	}

	public static void play() {
	}

	public static void play_incentivized(String userid) {
	}
}}
