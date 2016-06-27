
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

class WPPasswordBox : WPNativeWidget
{
	WPTextInputWidget container;
	embed "cs" {{{
		System.Windows.Controls.PasswordBox pb;
	}}}

	public WPPasswordBox set_widget(WPTextInputWidget widget) {
		container = widget;
		return(this);
	}

	embed "cs" {{{
		void widget_got_focus(object sender, System.Windows.RoutedEventArgs e) {
			var pb = sender as System.Windows.Controls.PasswordBox;
			if(pb != null) {
				pb.Background = null;
			}
			if(container != null) {
				container.on_textbox_got_focus();
			}
		}

		void widget_lost_focus(object sender, System.Windows.RoutedEventArgs e) {
			if(container != null) {
				container.on_textbox_lost_focus();
			}
		}

		protected override System.Windows.Controls.Control create_wp_control() {
			eq.gui.Font font = new eq.gui.Font();
			pb = new System.Windows.Controls.PasswordBox();
			pb.GotFocus += new System.Windows.RoutedEventHandler(widget_got_focus);
			pb.LostFocus += new System.Windows.RoutedEventHandler(widget_lost_focus);
			pb.KeyUp += key_up;
			float heightpx = (float)eq.gui.Length.eq_gui_Length_to_pixels(font.get_size(), get_dpi());
			pb.FontSize = heightpx;
			pb.BorderThickness = new System.Windows.Thickness(0);
			pb.Background = null;
			update_size_request();
			if(container != null) {
				container.update_subcomponents();
			}
			return(pb);
		}

		void key_up(object sender, System.Windows.Input.KeyEventArgs args) {
			if(args.Key == System.Windows.Input.Key.Enter) {
				container.on_enter_pressed();
			}
		}

		public System.Windows.Controls.PasswordBox get_native_passwordbox() {
			return(pb);
		}
	}}}
}
