
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

public class OSXLabelControl : AlignWidget, LabelControl
{
	class OSXLabelControlCell : OSXNativeWidget
	{
		embed {{{
			#import <Cocoa/Cocoa.h>
		}}}

		String text;
		int text_align;
		bool bold;
		Color color;

		public OSXLabelControlCell() {
			text_align = Alignment.LEFT;
		}

		public void initialize_nsview() {
			base.initialize_nsview();
			update_label();
		}

		public ptr create_nsview() {
			ptr v = null;
			embed {{{
				NSTextField* tf = [[NSTextField alloc] init];
				[tf setEditable:NO];
				[tf setSelectable:NO];
				[tf setDrawsBackground:NO];
				[tf setWantsLayer:YES];
				[tf setBezeled:NO];
				v = (__bridge_retained void*)tf;
			}}}
			return(v);
		}

		void update_label() {
			var view = get_nsview();
			if(view == null) {
				return;
			}
			var text = this.text;;
			if(text == null) {
				text = "";
			}
			var tp = text.to_strptr();
			embed {{{
				NSTextField* tf = (__bridge NSTextField*)view;
				[tf setStringValue:[NSString stringWithUTF8String:tp]];
			}}}
			if(text_align == Alignment.RIGHT) {
				embed {{{ [tf setAlignment:NSRightTextAlignment]; }}}
			}
			else if(text_align == Alignment.CENTER) {
				embed {{{ [tf setAlignment:NSCenterTextAlignment]; }}}
			}
			else {
				embed {{{ [tf setAlignment:NSNaturalTextAlignment]; }}}
			}
			if(bold) {
				embed {{{
					[tf setFont:[NSFont boldSystemFontOfSize:0]];
				}}}
			}
			else {
				embed {{{
					[tf setFont:[NSFont systemFontOfSize:0]];
				}}}
			}
			var cc = color;
			if(cc == null) {
				cc = get_draw_color();
			}
			if(cc != null) {
				var r = cc.get_r(), g = cc.get_g(), b = cc.get_b(), a = cc.get_a();
				embed {{{
					[tf setTextColor:[NSColor colorWithCalibratedRed:r green:g blue:b alpha:a]];
				}}}
			}
			update_size_request();
		}

		public void set_text(String text) {
			this.text = text;
			update_label();
		}

		public void set_text_align(int align) {
			this.text_align = align;
			update_label();
		}

		public void set_font_bold(bool value) {
			this.bold = value;
			update_label();
		}

		public void set_font_color(Color color) {
			this.color = color;
			update_label();
		}
	}

	OSXLabelControlCell cell;

	public OSXLabelControl() {
		cell = new OSXLabelControlCell();
	}

	public void initialize() {
		base.initialize();
		add_align(-1, 0, cell);
	}

	public LabelControl set_text(String text) {
		cell.set_text(text);
		return(this);
	}

	public LabelControl set_text_align(int align) {
		cell.set_text_align(align);
		return(this);
	}

	public LabelControl set_font_bold(bool value) {
		cell.set_font_bold(value);
		return(this);
	}

	public LabelControl set_font_color(Color color) {
		cell.set_font_color(color);
		return(this);
	}
}
