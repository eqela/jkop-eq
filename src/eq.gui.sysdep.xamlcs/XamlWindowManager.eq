
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

class XamlWindowManager :  WindowManager
{
	embed {{{
		Windows.UI.Core.CoreDispatcher main_dispatcher;
		int main_id;
	}}}

	public XamlWindowManager() {
		embed {{{
			main_dispatcher = Windows.UI.Core.CoreWindow.GetForCurrentThread().Dispatcher;
			main_id = Windows.UI.ViewManagement.ApplicationView.GetForCurrentView().Id;
		}}}
	}

	public WindowManagerScreen get_default_screen() {
		return(null);
	}

	public Collection get_screens() {
		return(null);
	}

	public Frame create_frame(FrameController fc, CreateFrameOptions opts = null) {
		if(opts != null) {
			embed {{{
				var parent = opts.get_parent() as XamlPanelFrame;
				if(parent != null) {
					var pop = new Windows.UI.Xaml.Controls.Primitives.Popup();
					var xpf = new XamlSecondaryPanelFrame(main_dispatcher);
					xpf.set_force_fullscreen(false);
					xpf.set_main_object((eq.api.Object)fc, opts);
					parent.Children.Add(pop);
					parent.disable_inputs();
					pop.Child = xpf;
					pop.IsOpen = true;
					return(xpf);
				}
			}}}
		}
		var frame = new XamlSecondaryFrameManager();
		embed {{{
			int id = 0, mid = main_id;
			int curr_id = 0;
			try {
				curr_id = Windows.UI.ViewManagement.ApplicationView.GetForCurrentView().Id;
			}
			catch(System.Exception) {
			}
			if(mid != curr_id) {
				mid = curr_id;
			}
			var coreview = Windows.ApplicationModel.Core.CoreApplication.CreateNewView();
			var aaction = coreview.Dispatcher.RunAsync(Windows.UI.Core.CoreDispatcherPriority.Normal, () => {
				var xpf = new XamlSecondaryPanelFrame(main_dispatcher);
				xpf.set_main_object((eq.api.Object)fc);
				var xframe = new Windows.UI.Xaml.Controls.Frame();
				if(!xframe.Navigate(typeof(XamlWindowManagerPage), xpf)) {
					throw new System.Exception("Failed to create secondary page");
				}
				frame.set_origframe(xpf);
				Windows.UI.Xaml.Window.Current.Content = xframe;
				id = Windows.UI.ViewManagement.ApplicationView.GetForCurrentView().Id;
				Windows.UI.Xaml.Window.Current.Activate();
			});
			aaction.Completed = (s, a) => {
				Windows.UI.ViewManagement.ApplicationViewSwitcher.TryShowAsStandaloneAsync(id, 0,mid,0);
			};
		}}}
		return(frame);
	}
}