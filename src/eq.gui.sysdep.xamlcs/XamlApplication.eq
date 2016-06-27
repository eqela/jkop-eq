
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

#public @class : @extends $magical<Windows.UI.Xaml.Application>
{
	@constructor {
		@lang "cs" {{{
			this.Suspending += OnSuspending;
		}}}
	}

	#public #virtual $void navigateToMainPage(
		$magical<Windows.UI.Xaml.Controls.Frame> frame,
		$magical<Windows.ApplicationModel.Activation.LaunchActivatedEventArgs> args) {
	}

	#public #virtual $void loadApplicationState() {
	}

	#public #virtual $void saveApplicationState() {
	}

	@lang "cs" {{{
		protected override void OnLaunched(Windows.ApplicationModel.Activation.LaunchActivatedEventArgs args) {
			Windows.UI.Xaml.Controls.Frame rootFrame = Windows.UI.Xaml.Window.Current.Content as Windows.UI.Xaml.Controls.Frame;
			if(rootFrame == null) {
				rootFrame = new Windows.UI.Xaml.Controls.Frame();
				if(args.PreviousExecutionState == Windows.ApplicationModel.Activation.ApplicationExecutionState.Terminated) {
					loadApplicationState();
				}
				Windows.UI.Xaml.Window.Current.Content = rootFrame;
			}
			if(rootFrame.Content == null) {
				navigateToMainPage(rootFrame, args);
			}
			Windows.UI.Xaml.Window.Current.Activate();
		}

		private void OnSuspending(object sender, Windows.ApplicationModel.SuspendingEventArgs e) {
			var deferral = e.SuspendingOperation.GetDeferral();
			saveApplicationState();
			deferral.Complete();
		}
    }}}
}
