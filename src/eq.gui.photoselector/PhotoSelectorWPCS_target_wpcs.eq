
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

public class PhotoSelectorWPCS
{
	property EventReceiver listener;
	embed "cs" {{{
		System.Windows.Threading.Dispatcher ui_dispatcher;
	}}}

	embed "cs" {{{
		void choose_completed(object sender, Microsoft.Phone.Tasks.PhotoResult e) {
			if(e.TaskResult == Microsoft.Phone.Tasks.TaskResult.OK) {
				var bmp = new System.Windows.Media.Imaging.BitmapImage();
				var mystream = e.ChosenPhoto;
				var stream = new System.IO.MemoryStream((int)mystream.Length);
				mystream.CopyTo(stream);
				mystream.Position = 0;
				stream.Position = 0;
				var buf = eq.api.DynamicBufferStatic.eq_api_DynamicBufferStatic_create((int)stream.Length) as eq.api.Buffer;
				if(buf!=null) {
					var data = buf.get_pointer().get_native_pointer();
					if(data != null) {
						stream.Read(data, 0, (int)stream.Length);
					}
				}
				bmp.SetSource(mystream);
				ui_dispatcher.BeginInvoke(new System.Action(() => {
					var img = eq.gui.sysdep.wpcs.WPCSImage.create_from_native_bitmap(bmp, buf);
					if(listener != null) {
						var psr = new PhotoSelectorResult().set_image(img);
						listener.on_event(psr);
					}
				}));
				
			}
		}
	}}}

	public bool execute() {
		embed "cs" {{{
			ui_dispatcher = System.Windows.Application.Current.RootVisual.Dispatcher;
			var selector = new Microsoft.Phone.Tasks.PhotoChooserTask();
			selector.Completed += new System.EventHandler<Microsoft.Phone.Tasks.PhotoResult>(choose_completed);
			selector.Show();
		}}}
		return(true);
	}
}
