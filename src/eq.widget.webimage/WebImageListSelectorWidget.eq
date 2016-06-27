
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

public class WebImageListSelectorWidget : ListSelectorWidget
{
	class WebImageListItemWidget : ListItemWidget
	{
		public override Widget create_view_widget() {
			var hb = HBoxWidget.instance();
			hb.set_margin(px("1mm"));
			hb.set_spacing(px("1mm"));
			URL icon_url;
			String text;
			String desc;
			var item = get_item();
			var webitem = item as WebImageActionItem;
			if(webitem != null) {
				icon_url = webitem.get_icon_url();
			}
			if(item != null) {
				text = item.get_text();
				desc = item.get_desc();
			}
			var iconsize = Theme.get_icon_size();
			if(get_icon_size() != null) {
				iconsize = get_icon_size();
			}
			if(iconsize == null) {
				iconsize = "5mm";
			}
			var iconmargin = get_icon_margin();
			if(iconmargin == null) {
				iconmargin = "1mm";
			}
			if(get_show_desc()) {
				if(get_show_icon()) {
					var sz = px(iconsize) + px(iconmargin) * 2;
					var px_str = "%spx".printf().add(sz).to_string();
					if(icon_url != null) {
						hb.add(AlignWidget.instance().add_align(0, -1, WebImageWidget.for_url(icon_url).set_image_width(px_str).set_image_height(px_str).set_size_request_override(sz, sz)));
					}
				}
				hb.add_hbox(1, AlignWidget.instance().add_align(-1, 0, VBoxWidget.instance()
					.add(LabelWidget.for_string(text).set_text_align(LabelWidget.LEFT).set_font(get_text_font()))
					.add(LabelWidget.for_string(desc).set_text_align(LabelWidget.LEFT).set_font(get_desc_font()))
				));
			}
			else {
				if(get_show_icon()) {
					var sz = px(iconsize);
					if(icon_url != null) {
						hb.add(WebImageWidget.for_url(icon_url).set_image_width(iconsize).set_image_height(iconsize).set_size_request_override(sz, sz));
					}
				}
				hb.add_hbox(1, LabelWidget.for_string(text).set_text_align(LabelWidget.LEFT));
			}
			return(hb);
		}
	}

	public WebImageListSelectorWidget () {
		set_adapt_to_content(false);
	}

	public override ListItemWidget create_widget_for_item() {
		return(new WebImageListItemWidget());
	}
}
