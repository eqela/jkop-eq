
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

class PhotoLibraryBackendAndroid : PhotoLibrary
{
	public static PhotoLibrary instance() {
		var pl = new PhotoLibraryBackendAndroid();
		if(pl.initialize()) {
			return(pl);
		}
		return(null);
	}

	public PhotoLibraryBackendAndroid() {
		mutex = Mutex.create();
	}

	~PhotoLibraryBackendAndroid() {
		cleanup();
	}

	void cleanup() {
		embed "java" {{{
			if(cursor != null) {
				cursor.close();
			}
			cursor = null;
			resolver = null;
		}}}
	}

	embed "java" {{{
		android.database.Cursor cursor = null;
		android.content.ContentResolver resolver = null;
	}}}

	Mutex mutex;

	bool initialize() {
		bool v = false;
		embed "java" {{{
			resolver = eq.api.Android.context.getApplicationContext().getContentResolver();
			if(resolver != null) {
				String[] columns = { android.provider.MediaStore.Images.Media.DATA, android.provider.MediaStore.Images.Media._ID };
				cursor = resolver.query(android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI, columns, null, null, android.provider.MediaStore.Images.Media._ID);
				v = true;
			}
		}}}
		return(v);
	}

	public int get_photo_count() {
		int cnt = 0;
		embed "java" {{{
			if(cursor != null) {
				cnt = cursor.getCount();
			}
		}}}
		return(cnt);
	}

	public PhotoLibraryEntry get_fullsize_by_index(int index) {
		if(index < 0) {
			return(null);
		}
		File f = null;
		Image img = null;
		embed "java" {{{
			if(cursor != null && resolver != null) {
				try {
					if(cursor.moveToPosition(index)) {
						f = eq.os.File.Static.for_native_path(eq.api.String.Static.for_strptr(cursor.getString(cursor.getColumnIndex(android.provider.MediaStore.Images.Media.DATA))), null);
						if(f != null) {
							img = eq.gui.Image.Static.for_file(f, -1, -1);
						}
					}
				}
				catch (java.lang.OutOfMemoryError e) {
					img = null;
				}
				catch (java.lang.Exception e) {
					img = null;
				}
			}
		}}}
		var ple = new PhotoLibraryEntry();
		ple.set_image(img);
		if(f != null) {
			ple.set_filename(f.basename());
		}
		return(ple);
	}

	public void get_thumbnail_by_index(int index, PhotoLibraryThumbnailListener listener) {
		if(index < 0) {
			if(listener != null) {
				listener.on_thumbnail_photo(null);
			}
			return;
		}
		var btm = GUI.engine.get_background_task_manager();
		if(btm != null) {
			var plt = new PhotoLibraryTask();
			plt.set_listener(listener);
			plt.set_mutex(mutex);
			plt.set_index(index);
			embed "java" {{{
				plt.set_cursor(cursor);
				plt.set_resolver(resolver);
			}}}
			btm.start_task(plt, plt);
		}
	}

	class PhotoLibraryTask : RunnableTask, EventReceiver
	{
		property PhotoLibraryThumbnailListener listener;
		property Mutex mutex;
		property int index;

		embed "java" {{{
			public void set_cursor(android.database.Cursor cursor) {
				this.cursor = cursor;
			}

			public void set_resolver(android.content.ContentResolver resolver) {
				this.resolver = resolver;
			}

			android.database.Cursor cursor = null;
			android.content.ContentResolver resolver = null;
		}}}

		public void run(EventReceiver listener, BooleanValue abortflag) {
			File f;
			Image tn;
			mutex.lock();
			embed "java" {{{
				if(cursor != null && resolver != null) {
					try {
						if(cursor.moveToPosition(index)) {
							android.graphics.Bitmap thumbnail = android.provider.MediaStore.Images.Thumbnails.getThumbnail(resolver,
								cursor.getInt(cursor.getColumnIndex(android.provider.MediaStore.Images.Media._ID)),
								android.provider.MediaStore.Images.Thumbnails.MICRO_KIND,
								null);
							if(thumbnail != null) {
								tn = (eq.gui.Image)eq.gui.sysdep.android.AndroidBitmapImage.for_android_bitmap(thumbnail);
							}
							f = eq.os.File.Static.for_native_path(eq.api.String.Static.for_strptr(cursor.getString(cursor.getColumnIndex(android.provider.MediaStore.Images.Media.DATA))), null);
						}
					}
					catch (java.lang.Exception e) {
					}
				}
			}}}
 			mutex.unlock();
			var ple = new PhotoLibraryEntry();
			ple.set_image(tn);
			if(f != null) {
				ple.set_filename(f.basename());
			}
			if(listener != null) {
				listener.on_event(ple);
			}
		}

		public void on_event(Object o) {
			if(o is PhotoLibraryEntry) {
				var ple = (PhotoLibraryEntry)o;
				if(ple != null && listener != null) {
					listener.on_thumbnail_photo(ple);
				}
			}
		}
	}
}
