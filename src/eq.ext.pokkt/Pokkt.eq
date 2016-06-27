
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

public class Pokkt
{
	property PokktOfferWallListener offer_wall_listener;
	property PokktVideoListener video_listener;
	property String security_key;
	property String application_id;
	property String user_id;
	property int integration_type;
	property bool skip_video = true;

	public static Pokkt for_video(String key, String app_id, String user_id, PokktVideoListener listener, Frame f = null) {
		return(create(key, app_id, user_id, PokktIntegrationType.ONLY_VIDEO, listener, null, f));
	}

	public static Pokkt for_offerwall(String key, String app_id, String user_id, PokktOfferWallListener listener) {
		return(create(key, app_id, user_id, PokktIntegrationType.ONLY_OFFER_WALL, null, listener));
	}

	public static Pokkt create(String key, String app_id, String user_id, int type, PokktVideoListener video_listener, PokktOfferWallListener offer_wall_listener, Frame ff = null) {
		Pokkt pokkt;
		IFDEF("target_android") {
			pokkt = new AndroidPokkt();
		}
		ELSE IFDEF("target_ios") {
			pokkt = new IOSPokkt();
		}
		if(pokkt == null) {
			return(null);
		}
		pokkt.set_security_key(key);
		pokkt.set_application_id(app_id);
		pokkt.set_integration_type(type);
		pokkt.set_user_id(user_id);
		pokkt.set_video_listener(video_listener);
		pokkt.set_offer_wall_listener(offer_wall_listener);
		if(!pokkt.initialize(ff)) {
			pokkt = null;
		}
		return(pokkt);
	}

	public virtual bool initialize(Frame ff = null) {
		return(false);
	}

	public virtual bool is_video_available() {
		return(false);
	}

	public virtual void play_video_campaign(bool is_incent, String title) {
	}

	public virtual void show_offerwall() {
	}
}
