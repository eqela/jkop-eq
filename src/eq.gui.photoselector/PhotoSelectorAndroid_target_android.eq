
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

class PhotoSelectorAndroid : eq.gui.sysdep.android.ActivityResultListener
{
	property EventReceiver listener;

	embed {{{
		private byte[] getImageBytes(android.content.Intent data) {
			eq.gui.sysdep.android.FrameActivity myactivity = eq.gui.sysdep.android.FrameActivity.get_instance();
			if(myactivity == null) {
				return(null);
			}
			android.content.ContentResolver cr = myactivity.getContentResolver();
			if(cr == null) {
				return(null);
			}
			byte[] v = null;
			try {
				java.io.InputStream ins = cr.openInputStream(data.getData());
				if(ins == null) {
					return(null);
				}
				java.io.ByteArrayOutputStream os = new java.io.ByteArrayOutputStream();
				byte[] bytes = new byte[1024];
				int c;
				while((c = ins.read(bytes)) > 0) {
					os.write(bytes, 0, c);
				}
				v = os.toByteArray();
			}
			catch(Exception e) {
				e.printStackTrace();
				v = null;
			}
			return(v);
		}

		public void onActivityResult(int requestCode, int resultCode, android.content.Intent data) {
			if(requestCode != 111 || data == null) {
				return;
			}
			String path = getPath(eq.api.Android.context, data.getData());
			if(path == null) {
				path = "";
			}
			eq.gui.sysdep.android.FrameActivity myactivity = eq.gui.sysdep.android.FrameActivity.get_instance();
			if(myactivity != null) {
				myactivity.remove_activity_result_listener(this);
			}
			byte[] bytes = getImageBytes(data);
			int sz = 0;
			if(bytes != null) {
				sz = bytes.length;
			}
			on_image_bytes(bytes, sz, eq.api.String.Static.for_strptr(path));
		}

		public static String getPath(android.content.Context context, android.net.Uri uri) {
			if(uri == null) {
				return(null);
			}
			if("content".equalsIgnoreCase(uri.getScheme())) {
				String[] projection = { "_data" };
				android.database.Cursor cursor = null;
				try {
					cursor = context.getContentResolver().query(uri, projection, null, null, null);
					int column_index = cursor.getColumnIndexOrThrow("_data");
					if(cursor.moveToFirst()) {
						return cursor.getString(column_index);
					}
				} catch (java.lang.Exception e) {
				}
			}
			else if("file".equalsIgnoreCase(uri.getScheme())) {
				return(uri.getPath());
			}
			return(null);
		}
	}}}

	void on_image_bytes(ptr bytes, int sz, String path) {
		var e = new PhotoSelectorResult();
		var file = File.for_native_path(path);
		e.set_image(Image.create_image_for_buffer(ImageBuffer.for_jpg(Buffer.for_pointer(Pointer.create(bytes), sz))));
		e.set_filename(file.basename());
		EventReceiver.event(listener, e);
	}

	public bool execute() {
		embed {{{
			eq.gui.sysdep.android.FrameActivity myactivity = eq.gui.sysdep.android.FrameActivity.get_instance();
			if(myactivity != null) {
				android.content.Intent intent = new android.content.Intent(android.content.Intent.ACTION_PICK);
				intent.setType("image/*");
				myactivity.add_activity_result_listener(this);
				myactivity.startActivityForResult(intent, 111);
			}
		}}}
		return(true);
	}
}
