
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

public class XamlMenuBar : MenuBarControl
{
	property Frame frame;
	embed {{{
		Windows.UI.Xaml.Controls.CommandBar cmdbar;
	}}}

	public static XamlMenuBar for_frame(Frame frame) {
		return(new XamlMenuBar().set_frame(frame));
	}

	embed {{{
		public void populate_menu_flyout(Windows.UI.Xaml.Controls.MenuFlyout flyout, eq.api.Collection items, eq.api.EventReceiver e) {
			var itr = ((eq.api.Iterateable)items).iterate();
			while(true) {
				var o = itr.next();
				if(o == null) {
					return;
				}
				if(o is eq.gui.ActionItem) {
					var ai = (eq.gui.ActionItem)o;
					var txt = ai.get_text();
					var item = new Windows.UI.Xaml.Controls.MenuFlyoutItem() { Text = txt.to_strptr() };
					item.Click += (sender, eh) => {
						if(ai.execute()) {
							return;
						}
						if(e != null) {
							e.on_event(ai.get_event());
						}
					};
					flyout.Items.Add(item);
				}
				else if(o is eq.gui.SeparatorItem) {
					flyout.Items.Add(new Windows.UI.Xaml.Controls.MenuFlyoutSeparator());
				}
			}
		}
	}}}

	public void initialize_menubar(DesktopWindowMenuBar mb, EventReceiver evr) {
		embed {{{
			var pframe = frame as eq.gui.sysdep.xamlcs.XamlPanelFrame;
			if(pframe == null) {
				return;
			}
			var page = pframe.Parent as Windows.UI.Xaml.Controls.Page;
			if(page == null) {
				return;
			} 
		}}}
		var menus = mb.as_non_mac_menus();
		if(menus != null) {
			embed {{{
				var cmd = page.TopAppBar as Windows.UI.Xaml.Controls.CommandBar;
				if(cmd == null) {
					cmd = new Windows.UI.Xaml.Controls.CommandBar();
				}
				cmd.SecondaryCommands.Clear();
				cmdbar = cmd;
			}}}
			foreach(Menu me in menus) {
				var mtitle = me.get_title();
				var items = me.get_items();
				if(items == null || items.count() < 1) {
					continue;
				}
				embed {{{
					var menu = new Windows.UI.Xaml.Controls.MenuFlyout() { Placement = Windows.UI.Xaml.Controls.Primitives.FlyoutPlacementMode.Left };
					populate_menu_flyout(menu, items, evr);
					cmd.SecondaryCommands.Add(new Windows.UI.Xaml.Controls.AppBarButton() { Label = mtitle.to_strptr(), Flyout = menu });
				}}}
			}
			embed {{{
				page.TopAppBar = cmd;
			}}}
		}
	}

	public void finalize() {
		embed {{{
			if(cmdbar != null) {
				cmdbar.SecondaryCommands.Clear();
			}
		}}}
	}
}
