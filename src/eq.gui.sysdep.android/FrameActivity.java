
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

package eq.gui.sysdep.android;

import eq.gui.*;
import android.view.View;
import android.view.ViewGroup;
import android.view.MotionEvent;

public class FrameActivity extends android.app.Activity
{
	public static FrameActivity get_instance() {
		return((FrameActivity)eq.api.Android.context);
	}

	private FrameViewGroup viewgroup;
	private java.util.LinkedList<ActivityResultListener> activitylisteners;
	private java.util.LinkedList<ActivityResultListener> addable_listeners;
	private java.util.LinkedList<ActivityResultListener> removable_listeners;	

	public FrameActivity() {
		eq.api.Android.context = this;
	}

	public void set_bottom_view(android.view.View bview) {
		if(viewgroup == null) {
			return;
		}
		viewgroup.set_bottom_view(bview);
	}

	public void lock_bottom_view() {
		if(viewgroup != null) {
			viewgroup.lock_bottom_view();
		}
	}

	public ViewGroup get_viewgroup() {
		return(viewgroup);
	}

	public FrameController create_frame_controller() {
		return(null);
	}

	public void on_view_group_created() {
	}

	public void on_create_custom() {
        eq.gui.sysdep.android.Application.Static.initialize(this);
		viewgroup = new FrameViewGroup(this);
		on_view_group_created();
		viewgroup.initialize(create_frame_controller(), null);
		setContentView(viewgroup);
	}

	public void onCreate(android.os.Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		on_create_custom();
	}

	public void onResume() {
		super.onResume();
		if(viewgroup != null) {
			viewgroup.start();
		}
	}

	public void onPause() {
		super.onPause();
		if(viewgroup != null) {
			viewgroup.stop();
		}
	}

	public boolean onKeyDown(int keyCode, android.view.KeyEvent event) {
		if(viewgroup != null) {
			return(viewgroup.on_key_down(keyCode, event));
		}
		return(false);
	}

	public boolean onKeyUp(int keyCode, android.view.KeyEvent event) {
		if(viewgroup != null) {
			return(viewgroup.on_key_up(keyCode, event));
		}
		return(false);
	}

	public void add_activity_result_listener(ActivityResultListener l) {
		if(activitylisteners == null) {
			activitylisteners = new java.util.LinkedList<ActivityResultListener>();
		}
		if(addable_listeners != null) {
			addable_listeners.add(l);
		}
		else {
			activitylisteners.add(l);
		}
	}

	public void remove_activity_result_listener(ActivityResultListener l) {
		if(activitylisteners == null) {
			return;
		}
		if(removable_listeners != null) {
			removable_listeners.add(l);
		}
		else {
			activitylisteners.remove(l);
		}
	}

	protected void onActivityResult(int requestCode, int resultCode, android.content.Intent data) {
		if(activitylisteners == null) {
			return;
		}
		java.util.Iterator<ActivityResultListener> ii = activitylisteners.iterator();
		if(ii == null) {
			return;
		}
		addable_listeners = new java.util.LinkedList<ActivityResultListener>();
		removable_listeners = new java.util.LinkedList<ActivityResultListener>();
		while(ii.hasNext()) {
			ActivityResultListener listener = ii.next();
			if(listener != null) {
				listener.onActivityResult(requestCode, resultCode, data);
			}
		}
		for(ActivityResultListener aarl : addable_listeners) {
			activitylisteners.add(aarl);
		}
		for(ActivityResultListener rarl : removable_listeners) {
			activitylisteners.remove(rarl);
		}
		addable_listeners = null;
		removable_listeners = null;
	}

	public void onConfigurationChanged(android.content.res.Configuration newconfig) {
		super.onConfigurationChanged(newconfig);
	}
}
