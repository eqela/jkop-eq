
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

public class AndroidFacebookLogin
{
	class AndroidFacebookLoginActivityResultListener : eq.gui.sysdep.android.ActivityResultListener
	{
		embed "java" {{{
			public void onActivityResult(int requestCode, int resultCode, android.content.Intent data) {
				eq.gui.sysdep.android.FrameActivity activity = eq.gui.sysdep.android.FrameActivity.get_instance();
				if(activity != null) {
					com.facebook.Session.getActiveSession().onActivityResult(activity, requestCode, resultCode, data);
					activity.remove_activity_result_listener(this);
				}
			}
		}}}
	}

	embed "java" {{{
		class MySessionStatusCallback implements com.facebook.Session.StatusCallback
		{
			public MySessionStatusCallback(eq.ext.facebook.FacebookLoginListener listener) {
				this.listener = listener;
			}

			eq.ext.facebook.FacebookLoginListener listener;

			public void call(com.facebook.Session session, com.facebook.SessionState state, Exception exception) {
				if(session.isOpened()) {
					if(listener != null) {
						java.util.List<java.lang.String> permissions = session.getPermissions();
						eq.api.Collection col = eq.api.LinkedList.Static.create();
						for(java.lang.String p : permissions ) {
							eq.api.String s = eq.api.String.Static.for_strptr(p);
							col.add((eq.api.Object)s);
						}
						listener.on_facebook_login_completed(eq.api.String.Static.for_strptr(session.getAccessToken()), col);
					}
					session.removeCallback(this);
				}
				else if(session.isClosed()) {
					if(listener != null) {
						listener.on_facebook_login_completed(null, null);
					}
					session.removeCallback(this);
				}
			}
		}
	}}}

	static AndroidFacebookLogin _instance;

	public static AndroidFacebookLogin instance() {
		if(_instance == null) {
			_instance = new AndroidFacebookLogin();
		}
		return(_instance);
	}

	public bool execute(String application_id, FacebookLoginListener listener, Collection permissions = null) {
		if(String.is_empty(application_id)) {
			return(false);
		}
		embed "java" {{{
			eq.gui.sysdep.android.FrameActivity activity = eq.gui.sysdep.android.FrameActivity.get_instance();
			if(activity == null) {
				return(false);
			}
			com.facebook.Session active_session = com.facebook.Session.getActiveSession();
			if(active_session != null && active_session.isOpened()) {
				active_session.closeAndClearTokenInformation();
			}
			java.util.ArrayList<java.lang.String> list = new java.util.ArrayList<java.lang.String>();
		}}}
		if(permissions != null) {
			foreach(String p in permissions) {
				embed "java" {{{
					list.add(p.to_strptr());
				}}}
			} 
		}
		embed "java" {{{
			activity.add_activity_result_listener(new AndroidFacebookLoginActivityResultListener());
			com.facebook.Settings.setApplicationId(application_id.to_strptr());
			MySessionStatusCallback myCallback = new MySessionStatusCallback(listener);
			try {
				if(permissions == null) {
					com.facebook.Session.openActiveSession(activity, true, myCallback);
				}
				else {
					com.facebook.Session.openActiveSession(activity, true, list, myCallback);
				}
			}
			catch(java.lang.Exception e) {
				return(false);
			}
			
		}}}
		return(true);
	}

	public bool request_new_read_permissions(Collection permissions, FacebookLoginListener listener) {
		return(request_new_permissions(permissions, listener, true));
	}

	public bool request_new_publish_permissions(Collection permissions, FacebookLoginListener listener) {
		return(request_new_permissions(permissions, listener, false));
	}

	private bool request_new_permissions(Collection permissions, FacebookLoginListener listener, bool is_read_permissions) {
		if(permissions == null || permissions.count() < 1) {
			return(false);
		}
		embed "java" {{{
			java.util.ArrayList<java.lang.String> list = new java.util.ArrayList<java.lang.String>();
		}}}
		foreach(String p in permissions) {
			embed "java" {{{
				list.add(p.to_strptr());
			}}}
		}
		embed "java" {{{
			com.facebook.Session active_session = com.facebook.Session.getActiveSession();
			eq.gui.sysdep.android.FrameActivity activity = eq.gui.sysdep.android.FrameActivity.get_instance();
			if(activity == null) {
				return(false);
			}
			if(active_session != null && active_session.isOpened()) {
				com.facebook.Session.NewPermissionsRequest req = new com.facebook.Session.NewPermissionsRequest(activity, list);
				activity.add_activity_result_listener(new AndroidFacebookLoginActivityResultListener());
				MySessionStatusCallback myCallback = new MySessionStatusCallback(listener);
				active_session.addCallback(myCallback);
				try {
					if(is_read_permissions) {
						active_session.requestNewReadPermissions(req);
					} else {
						active_session.requestNewPublishPermissions(req);
					}
					return(true);
				}
				catch(java.lang.Exception e) {
				}
			}
		}}}
		return(false);
	}
}
