
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

public class XamlToolBar : ToolBarControl
{
	property Frame frame;
	embed {{{
		Windows.UI.Xaml.Controls.CommandBar cmdbar;
	}}}

	public static XamlToolBar for_frame(Frame frame) {
		var v = new XamlToolBar();
		v.frame = frame;
		return(v);
	}

	public void initialize_toolbar(ToolBar tb, ToolBarControlListener listener) {
		if(frame == null) {
			return;
		}
		embed {{{
			var pframe = frame as eq.gui.sysdep.xamlcs.XamlPanelFrame;
			if(pframe == null) {
				return;
			}
			var items = tb.get_items();
			if(items == null) {
				return;
			}
			var page = pframe.Parent as Windows.UI.Xaml.Controls.Page;
			if(page == null) {
				return;
			}
			var cmd = page.TopAppBar as Windows.UI.Xaml.Controls.CommandBar;
			if(cmd == null) {
				cmd = new Windows.UI.Xaml.Controls.CommandBar();
			}
			cmdbar = cmd;
			cmd.PrimaryCommands.Clear();
			int cc = items.count();
			var stack = new Windows.UI.Xaml.Controls.StackPanel() {
				Orientation = Windows.UI.Xaml.Controls.Orientation.Horizontal,
			};
			cmd.Content = stack;
			for(int i = 0; i < cc; i++) {
				var co = items.get(i);
				if(co is eq.gui.ActionItem) {
					var ai = (eq.gui.ActionItem)co;
					var txt = ai.get_text();
					var icn = ai.get_icon() as eq.gui.sysdep.xamlcs.XamlImage;
					var bmpi = new Windows.UI.Xaml.Controls.BitmapIcon();
					if(icn != null) {
						bmpi.UriSource = icn.get_uri();
					}
					string sptr = null;
					if(txt != null) {
						sptr = txt.to_strptr();
					}
					var btn = new Windows.UI.Xaml.Controls.AppBarButton();
					btn.IsCompact = true;
					btn.Label = sptr;
					btn.Icon = bmpi;
					btn.Click += (sender, args) => {
						if(ai.execute()) {
							return;
						}
						if(listener != null) {
							listener.on_toolbar_entry_selected(ai);
						}
					};
					cmd.PrimaryCommands.Add(btn);
				}
				else if(co is eq.gui.SeparatorItem) {
					cmd.PrimaryCommands.Add(new Windows.UI.Xaml.Controls.AppBarSeparator());
				}
			}		
            page.TopAppBar = cmd;
		}}}
	}

	public void finalize() {
		embed {{{
			if(cmdbar != null) {
				cmdbar.PrimaryCommands.Clear();
			}
		}}}
	}
}
