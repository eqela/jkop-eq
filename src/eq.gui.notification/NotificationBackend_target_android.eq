
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

class NotificationBackend
{
	public static NotificationBackend instance() {
		return(new NotificationBackend());
	}

	static int mnotificationid = 0;

	public bool show(Notification ni) {
		if(ni == null) {
			return(false);
		}
		var title = ni.get_title();
		var content = ni.get_content();
		if(String.is_empty(content)) {
			return(false);
		}
		if(String.is_empty(title)) {
			title = "Notification";
		}
		ptr n;
		var titlep = title.to_strptr();
		var contentp = content.to_strptr();
		var id = mnotificationid++;
		var mainactivity = "%s.MainActivity".printf().add(Application.get_name()).to_string();
		var path = "%s:drawable/appicon".printf().add(Application.get_name()).to_string();
		var rid = path.to_strptr();
		int resicon;
		embed "java" {{{
			java.lang.Class cls = null;
			try {
				cls = java.lang.Class.forName(mainactivity.to_strptr());
			}
			catch(ClassNotFoundException e) {
			}
			resicon = eq.api.Android.context.getResources().getIdentifier(rid, null, null);
			if(resicon < 1) {
				resicon = android.R.drawable.sym_def_app_icon;
			}
			android.app.Notification.Builder mBuilder = new android.app.Notification.Builder(eq.api.Android.context);
			mBuilder.setSmallIcon(resicon);
			mBuilder.setContentTitle(titlep);
			mBuilder.setContentText(contentp);
			mBuilder.setTicker(contentp);
			mBuilder.setDefaults(android.app.Notification.DEFAULT_ALL);
			mBuilder.setAutoCancel(true);
			android.content.Intent resultIntent = new android.content.Intent(eq.api.Android.context, cls);
			android.app.PendingIntent resultPendingIntent = android.app.PendingIntent.getActivity(eq.api.Android.context, 0,
				resultIntent, android.app.PendingIntent.FLAG_UPDATE_CURRENT);
			mBuilder.setContentIntent(resultPendingIntent);
			android.app.NotificationManager mNotificationManager = (android.app.NotificationManager)
				eq.api.Android.context.getSystemService(eq.api.Android.context.NOTIFICATION_SERVICE);
			android.app.Notification mbuilt = mBuilder.build();
			if(mbuilt == null) {
				return(false);
			}
			mNotificationManager.notify(id, mbuilt);
		}}}
		return(true);
	}
}
