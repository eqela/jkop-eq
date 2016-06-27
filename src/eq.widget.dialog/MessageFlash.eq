
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

public class MessageFlash : LayerWidget
{
	public static void show(Widget master, String message) {
		if(master == null) {
			return;
		}
		Popup.execute(master.get_engine(), PopupSettings.instance()
			.set_widget(new MessageFlash().set_message(message))
			.set_modal(false).set_master(master).set_timeout(1500000)
		);
	}

	property String message;
	property Color background_color;
	property Color outline_color;
	property bool rounded;
	property String margin_width;
	property String shadow_thickness;
	property Font font;

	public MessageFlash() {
		background_color = Theme.color("eq.widget.dialog.MessageFlash.background_color", "%s".printf().add(Theme.get_base_color()).to_string());
		outline_color = Theme.color("eq.widget.dialog.MessageFlash.outline_color", "none");
		rounded = Theme.boolean("eq.widget.dialog.MessageFlash.rounded", "false");
		margin_width = Theme.string("eq.widget.dialog.MessageFlash.margin_width", "500um");
		shadow_thickness = Theme.string("eq.widget.dialog.MessageFlash.shadow_thickness", "2mm");
		font = Theme.font("eq.widget.dialog.MessageFlash.font", "color=white 150%");
	}

	public void initialize() {
		base.initialize();
		set_margin(px(margin_width));
		var ll = LayerWidget.instance();
		ll.add(CanvasWidget.for_color(background_color).set_outline_color(outline_color).set_rounded(rounded));
		ll.add(LayerWidget.instance().set_margin(px("2mm"))
			.add(LabelWidget.for_string(message).set_font(font).set_wrap(true))
		);
		var ss = ShadowContainerWidget.for_widget(ll);
		ss.set_shadow_thickness(shadow_thickness);
		add(ss);
	}
}
