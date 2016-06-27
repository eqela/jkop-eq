
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

#public @class : @extends $magical<Windows.UI.Xaml.Controls.Page>
{
	#public #virtual eq.api.Object create_main_object() {
		return(null);
	}

	@lang "cs" {{{
		protected override void OnNavigatedTo(Windows.UI.Xaml.Navigation.NavigationEventArgs e) {
			var ui = new eq.gui.sysdep.xamlcs.XamlPanelFrame();
			var main = create_main_object();
			eq.api.Object mmain = main;
			if(main is eq.gui.GuiApplicationMain) {
				mmain = (eq.api.Object)((eq.gui.GuiApplicationMain)main).create_frame_controller();
			}
			ui.set_main_object(mmain);
			Content = ui;
			eq.gui.engine.GUIEngine.initialize();
		}
	}}}
}
