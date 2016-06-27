
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

public class ModalDialogEngineWPCS : ModalDialogEngine
{
	embed "cs" {{{
		class ModalBooleanEventButton : System.Windows.Controls.Button
		{
			ModalDialogBooleanListener listener;

			public void set_listener(ModalDialogBooleanListener alistener) {
				listener = alistener;
			}

			public ModalDialogBooleanListener get_listener() {
				return(listener);
			}
		}

		class ModalStringEventButton : System.Windows.Controls.Button
		{
			ModalDialogStringListener listener;
			System.Windows.Controls.TextBox txtbox;

			public void set_text_box(System.Windows.Controls.TextBox text_box) {
				txtbox = text_box;
			}

			public System.Windows.Controls.TextBox get_text_box() {
				return(txtbox);
			}

			public void set_listener(ModalDialogStringListener string_listener) {
				listener = string_listener;
			}

			public ModalDialogStringListener get_listener() {
				return(listener);
			}
		}	
	}}}

	public void message(Frame frame, String text, String title, ModalDialogListener listener) {
		var atext = String.as_strptr(text);
		if(atext == null) {
			embed {{{
				atext = "";	
			}}}
		}
		var atitle = String.as_strptr(title);
		if(atitle == null) {
			embed {{{
				atitle = "";	
			}}}
		}
		embed "cs" {{{
			System.Windows.MessageBoxResult result = System.Windows.MessageBox.Show(atext, atitle, System.Windows.MessageBoxButton.OK);
			if(result == System.Windows.MessageBoxResult.OK) {
				if(listener != null) {
					listener.on_dialog_closed();
				}
			}
		}}}
	}

	public void error(Frame frame, String text, String title, ModalDialogListener listener) {
		var atext = String.as_strptr(text);
		if(atext == null) {
			embed {{{
				atext = "";	
			}}}
		}
		var atitle = String.as_strptr(title);
		if(atitle == null) {
			embed {{{
				atitle = "";	
			}}}
		}
		embed "cs" {{{
			System.Windows.MessageBoxResult result = System.Windows.MessageBox.Show(atext, atitle, System.Windows.MessageBoxButton.OK);
			if(result == System.Windows.MessageBoxResult.OK) {
				if(listener != null) {
					listener.on_dialog_closed();
				}
			}
		}}}
	}

	public void okcancel(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var atext = String.as_strptr(text);
		if(atext == null) {
			embed {{{
				atext = "";	
			}}}
		}
		var atitle = String.as_strptr(title);
		if(atitle == null) {
			embed {{{
				atitle = "";	
			}}}
		}
		embed "cs" {{{
			System.Windows.MessageBoxResult result = System.Windows.MessageBox.Show(atext, atitle, System.Windows.MessageBoxButton.OKCancel);
			if(result == System.Windows.MessageBoxResult.OK) {
				listener.on_dialog_boolean_result(true);
			}
			else {
				listener.on_dialog_boolean_result(false);
			}
		}}}
	}

	public void yesno(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var textp = String.as_strptr(text);
		if(textp == null) {
			embed {{{
				textp = "";
			}}}
		}
		var titlep = String.as_strptr(title);
		if(titlep == null) {
			embed {{{
				titlep = "";
			}}}
		}
		embed {{{
			open_customized_yesno(titlep, textp, listener);
		}}}
	}

	embed "cs" {{{
		System.Windows.Media.SolidColorBrush get_theme_color(System.String id) {
			return(System.Windows.Application.Current.Resources[id] as System.Windows.Media.SolidColorBrush);
		}
		
		System.Windows.Controls.StackPanel create_base_panel(bool is_txtinput, double w, double h) {
			var base_panel = new System.Windows.Controls.StackPanel();
			base_panel.Width = w;
			base_panel.Height = h;
			if(!is_txtinput) {
				base_panel.Background = get_theme_color("PhoneSemitransparentBrush");
			}
			else {
				base_panel.Background = get_theme_color("PhoneBackgroundBrush");
			}
			return(base_panel);
		}

		System.Windows.Controls.StackPanel create_text_panel(System.String titlea, System.String texta) {
			var textpanel = new System.Windows.Controls.StackPanel();
			var titleblock = new System.Windows.Controls.TextBlock();
			titleblock.Margin = new System.Windows.Thickness(20);
			titleblock.FontSize = (System.Double)System.Windows.Application.Current.Resources["PhoneFontSizeLarge"];
			titleblock.FontFamily = (System.Windows.Media.FontFamily)System.Windows.Application.Current.Resources["PhoneFontFamilySemiBold"];
			titleblock.Text = titlea;
			var strblock = new System.Windows.Controls.TextBlock();
			strblock.Margin = new System.Windows.Thickness(15);
			strblock.FontSize = (System.Double)System.Windows.Application.Current.Resources["PhoneFontSizeMediumLarge"];	
			strblock.Text = texta;
			textpanel.Background = get_theme_color("PhoneBackgroundBrush");
			textpanel.Children.Add(titleblock);
			textpanel.Children.Add(strblock);
			return(textpanel);
		}

		System.Windows.Controls.StackPanel create_button_panel() {
			System.Windows.Controls.StackPanel buttonspanel = new System.Windows.Controls.StackPanel();
			buttonspanel.Background = get_theme_color("PhoneBackgroundBrush");
			buttonspanel.Orientation = System.Windows.Controls.Orientation.Horizontal;
			return(buttonspanel);
		}

		void initialize_button(System.Windows.Controls.Button btn, System.String text, eq.api.String w, int margin) {
			var p = (eq.gui.sysdep.wpcs.FramePanel)eq.gui.sysdep.wpcs.GuiEngine.rootframe;
			if(p == null) {
				return;
			}
			btn.Content = text;
			btn.Width = eq.gui.Length.eq_gui_Length_to_pixels(w, p.get_dpi());
			btn.Margin = new System.Windows.Thickness(margin);
		}

		void on_btnyes_click(object sender, System.Windows.RoutedEventArgs e) {
			var button_yes = sender as ModalBooleanEventButton;
			on_btnyesno_respond(true, button_yes.get_listener(), get_popup_widget(button_yes));
		}

		void on_btnno_click(object sender, System.Windows.RoutedEventArgs e) {
			var button_no = sender as ModalBooleanEventButton;
			on_btnyesno_respond(false, button_no.get_listener(), get_popup_widget(button_no));
		}

		void on_btnyesno_respond(bool val, ModalDialogBooleanListener alistener, System.Windows.Controls.Primitives.Popup pp) {
			if(alistener != null) {
				alistener.on_dialog_boolean_result(val);	
			}
			var parent = pp.Parent as eq.gui.sysdep.wpcs.FramePanel;
			if(parent != null) {
				parent.set_input_enabled(true);
				parent.Children.Remove(pp);
			}
		}

		System.Windows.Controls.Primitives.Popup get_popup_widget(System.Windows.FrameworkElement btn) {
			var parent = btn.Parent as System.Windows.FrameworkElement;
			while(parent is System.Windows.Controls.Primitives.Popup == false && parent != null) {
				parent = parent.Parent as System.Windows.FrameworkElement;
			}
			return((System.Windows.Controls.Primitives.Popup)parent);
		}
		
		void open_customized_yesno(System.String titlep, System.String textp, ModalDialogBooleanListener listener) {
			int swidth = (int)System.Windows.Application.Current.Host.Content.ActualWidth;
			int sheight = (int)System.Windows.Application.Current.Host.Content.ActualHeight;
			var p = new System.Windows.Controls.Primitives.Popup();
			var yesno_basepanel = create_base_panel(false, swidth, sheight);
			var btn_panel = create_button_panel();
			ModalBooleanEventButton btnpositive = new ModalBooleanEventButton();
			btnpositive.set_listener(listener);
			initialize_button(btnpositive, "yes", eq.api.StringStatic.eq_api_StringStatic_for_strptr("38mm"), 10);
			btnpositive.Click += new System.Windows.RoutedEventHandler(on_btnyes_click);
			ModalBooleanEventButton btnnegative = new ModalBooleanEventButton();
			btnnegative.set_listener(listener);
			initialize_button(btnnegative, "no", eq.api.StringStatic.eq_api_StringStatic_for_strptr("38mm"), 10);
			btnnegative.Click += new System.Windows.RoutedEventHandler(on_btnno_click);
			btn_panel.Children.Add(btnpositive);
			btn_panel.Children.Add(btnnegative);
			yesno_basepanel.Children.Add(create_text_panel(titlep, textp));
			yesno_basepanel.Children.Add(btn_panel);	
			p.Child = yesno_basepanel;
			var framepanel = (eq.gui.sysdep.wpcs.FramePanel)eq.gui.sysdep.wpcs.GuiEngine.rootframe;
			framepanel.Children.Add(p);
			framepanel.set_input_enabled(false);
			p.IsOpen = true;
		}
	}}}

	public void textinput(Frame frame, String text, String title, String initial_value, ModalDialogStringListener listener) {
		var textp = String.as_strptr(text);
		if(textp == null) {
			embed {{{
				textp = "";
			}}}
		}
		var titlep = String.as_strptr(title);
		if(titlep == null) {
			embed {{{
				titlep = "";
			}}}
		}
		var initialp = String.as_strptr(initial_value);
		if(initialp == null) {
			embed {{{
				initialp = "";
			}}}
		}
		embed {{{
			open_customized_textinput(textp, titlep, initialp, listener);
		}}}
	}

	embed "cs" {{{
		void on_btnok_click(object sender, System.Windows.RoutedEventArgs e) {
			var button_ok = sender as ModalStringEventButton;
			on_btntxtinput_respond(button_ok.get_text_box(), button_ok.get_listener(), get_popup_widget(button_ok));
		}

		void on_btncancel_click(object sender, System.Windows.RoutedEventArgs e) {
			var button_cancel = sender as ModalStringEventButton;
			on_btntxtinput_respond(null, button_cancel.get_listener(), get_popup_widget(button_cancel));
		}

		void on_btntxtinput_respond(System.Windows.Controls.TextBox txtbox, ModalDialogStringListener alistener, System.Windows.Controls.Primitives.Popup pp) {
			if(alistener != null) {
				if(txtbox != null) {
					alistener.on_dialog_string_result(eq.api.StringStatic.eq_api_StringStatic_for_strptr(txtbox.Text));
				}
				else {
					alistener.on_dialog_string_result(eq.api.StringStatic.eq_api_StringStatic_for_strptr(null));	
				}
			}
			var parent = pp.Parent as eq.gui.sysdep.wpcs.FramePanel;
			if(parent != null) {
				parent.set_input_enabled(true);
				parent.Children.Remove(pp);
			}
		}
		
		void open_customized_textinput(System.String titlep, System.String textp, System.String initialp,  ModalDialogStringListener listener) {
			int swidth = (int)System.Windows.Application.Current.Host.Content.ActualWidth;
			int sheight = (int)System.Windows.Application.Current.Host.Content.ActualHeight;
			var p = new System.Windows.Controls.Primitives.Popup();
			var txtinput_base_panel = create_base_panel(true, swidth, sheight);
			txtinput_base_panel.Children.Add(create_text_panel(titlep, textp));
			var txtbox = new System.Windows.Controls.TextBox();
			txtbox.Text = initialp;
			txtbox.Select(0, initialp.Length);
			txtinput_base_panel.Children.Add(txtbox);
			var txtinput_btn_panel = create_button_panel();
			ModalStringEventButton btnpositive = new ModalStringEventButton();
			btnpositive.set_listener(listener);
			btnpositive.set_text_box(txtbox);
			initialize_button(btnpositive, "ok", eq.api.StringStatic.eq_api_StringStatic_for_strptr("38mm"), 10);
			btnpositive.Click += new System.Windows.RoutedEventHandler(on_btnok_click);
			ModalStringEventButton btnnegative = new ModalStringEventButton();
			btnnegative.set_listener(listener);
			initialize_button(btnnegative, "cancel", eq.api.StringStatic.eq_api_StringStatic_for_strptr("38mm"), 10);
			btnnegative.Click += new System.Windows.RoutedEventHandler(on_btncancel_click);
			txtinput_btn_panel.Children.Add(btnpositive);
			txtinput_btn_panel.Children.Add(btnnegative);
			txtinput_base_panel.Children.Add(txtinput_btn_panel);	
			p.Child = txtinput_base_panel;
			var framepanel = (eq.gui.sysdep.wpcs.FramePanel)eq.gui.sysdep.wpcs.GuiEngine.rootframe;
			framepanel.Children.Add(p);
			framepanel.set_input_enabled(false);
			p.IsOpen = true;
		}
	}}}
}
