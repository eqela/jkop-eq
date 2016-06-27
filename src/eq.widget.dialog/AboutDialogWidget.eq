
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

public class AboutDialogWidget : MultiLineTextDialogWidget
{
	public static AboutDialogWidget instance() {
		return(new AboutDialogWidget());
	}

	public AboutDialogWidget() {
		set_title("About");
		add_line("%s %s".printf()
			.add(Application.get_display_name())
			.add(Application.get_version())
			.to_string(),
			"color=#222288 bold 5mm"
		);
		add_line("(API version %s)".printf().add(API.version()).to_string());
		var cp = Application.get_copyright();
		if(String.is_empty(cp) == false) {
			add_line(cp);
		}
	}

	public void initialize() {
		base.initialize();
		set_dialog_footer_widget(ButtonSet.ok());
	}
}
