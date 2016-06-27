
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

class CameraAndroid : eq.gui.sysdep.android.ActivityResultListener
{
	property EventReceiver listener;
	int id;

	public CameraAndroid() {
		id = Math.random(0, 999);
	}

	public bool execute() {
		embed "java" {{{
			android.content.Intent intent = new android.content.Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
		  	if (intent.resolveActivity(eq.api.Android.context.getPackageManager()) != null) {
				eq.gui.sysdep.android.FrameActivity activity = eq.gui.sysdep.android.FrameActivity.get_instance();
				if(activity == null) {
					return(false);
				}
				activity.add_activity_result_listener(this);
				java.io.File containerFile = null;
				try {
					containerFile = createImageFile();
				} 
				catch(java.io.IOException ex) {
					containerFile = null;
					return(false);
				}
				if(containerFile != null) {
					intent.putExtra(android.provider.MediaStore.EXTRA_OUTPUT, android.net.Uri.fromFile(containerFile));
					activity.startActivityForResult(intent, id);
					return(true);
				}
		 	}
		}}}
		return(false);
	}

	void on_image_bytes(ptr bytes, int sz) {
		var e = new CameraResult();
		e.set_image(Image.create_image_for_buffer(ImageBuffer.for_jpg(Buffer.for_pointer(Pointer.create(bytes), sz))));
		EventReceiver.event(listener, e);
	}

	embed "java" {{{
		private byte[] getImageBytes() {
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
				android.net.Uri uri = android.net.Uri.parse(myCurrentImagePath);
				java.io.InputStream ins = cr.openInputStream(uri);
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
				v = null;
			}
			return(v);
		}

		public void onActivityResult(int requestCode, int resultCode, android.content.Intent data) {
			if(requestCode != id) {
				return;
			}
			eq.gui.sysdep.android.FrameActivity myactivity = eq.gui.sysdep.android.FrameActivity.get_instance();
			if(myactivity != null) {
				myactivity.remove_activity_result_listener(this);
			}
			byte[] bytes = getImageBytes();
			int sz = 0;
			if(bytes != null) {
				sz = bytes.length;
			}
			on_image_bytes(bytes, sz);
		}

		String myCurrentImagePath;

		private java.io.File createImageFile() throws java.io.IOException {
			String timeStamp = new java.text.SimpleDateFormat("yyyyMMdd_HHmmss").format(new java.util.Date());
			String imageFileName = "JPEG_" + timeStamp + "_";
			java.io.File storageDir = android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_PICTURES);
			java.io.File image = java.io.File.createTempFile(imageFileName, ".jpg", storageDir);
			myCurrentImagePath = "file:" + image.getAbsolutePath();
			return(image);
		}
	}}}
}
