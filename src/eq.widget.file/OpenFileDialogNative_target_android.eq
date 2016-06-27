
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

class OpenFileDialogNative : eq.gui.sysdep.android.ActivityResultListener
{
	property OpenFileDialogListener listener;

	public static bool execute(Frame frame, File directory, String filter, bool choose_directories, OpenFileDialogListener listen) {
		embed "java" {{{
			eq.gui.sysdep.android.FrameActivity activity = eq.gui.sysdep.android.FrameActivity.get_instance();
			if(activity == null) {
				return(false);
			}
			String filter_type = eq.api.String.Static.as_strptr((eq.api.Object)filter);
			if(filter_type == null) {
				filter_type = "*/*";
			}
			activity.add_activity_result_listener(new OpenFileDialogNative().set_listener(listen));
			android.content.Intent intent = new android.content.Intent(android.content.Intent.ACTION_GET_CONTENT);
			intent.setType(filter_type);
			intent.addCategory(android.content.Intent.CATEGORY_OPENABLE);
			try {
				activity.startActivityForResult(android.content.Intent.createChooser(intent, "Select a file"), 0);
			}
			catch(android.content.ActivityNotFoundException ex) {
			}
		}}}
		return(true);
	}

	void on_file_selected(String path) {
		if(listener != null) {
			listener.on_open_file_dialog_ok(File.for_native_path(path));
		}
	}

	embed {{{
		public void onActivityResult(int requestCode, int resultCode, android.content.Intent data) {
			eq.gui.sysdep.android.FrameActivity myactivity = eq.gui.sysdep.android.FrameActivity.get_instance();
			if(resultCode == android.app.Activity.RESULT_OK) {
				if(data != null) {
					android.net.Uri uri = data.getData();
					String path = getPath(eq.api.Android.context, uri);
					try {
						on_file_selected(eq.api.String.Static.for_strptr(path));
					}
					catch(java.lang.Exception e) {
					}
				}
			}
			if(myactivity != null) {
				myactivity.remove_activity_result_listener(this);
			}
		}
		
		public static String getPath(android.content.Context context, android.net.Uri uri) {
			if("content".equalsIgnoreCase(uri.getScheme())) {
				String[] projection = { android.provider.MediaStore.Images.Media.DATA };
				android.database.Cursor cursor = null;
				try {
					cursor = context.getContentResolver().query(uri, projection, null, null, null);
					int column_index = cursor.getColumnIndexOrThrow(projection[0]);
					String v;
					if(cursor.moveToFirst()) {
						v = cursor.getString(column_index);
						cursor.close();
						return v;
					}
				}
				catch (java.lang.Exception e) {
				}
				if(cursor != null && !cursor.isClosed()) {
					cursor.close();
				}
			}
			else if("file".equalsIgnoreCase(uri.getScheme())) {
				return uri.getPath();
			}
			return null;
		}
	}}}
}
