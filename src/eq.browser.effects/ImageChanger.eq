
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

public class ImageChanger
{
	Collection elements;
	int current;
	property int slide_delay = 5000000;
	property int transition_delay = 500000;

	class SwitchTimer : BrowserTimer {
		property ImageChanger ic;
		public bool on_timer() {
			ic.next_image();
			return(true);
		}
	}

	public void initialize(String id, Collection imgs) {
		var el = new HTMLDocument().get_element_by_id(id);
		if(el == null) {
			return;
		}
		foreach(HTMLElement e in el.get_children()) {
			new FadeOutTimer().set_element(e).set_duration(transition_delay).execute();
		}
		elements = LinkedList.create();
		foreach(String img in imgs) {
			var e = HTMLElement.create("img").set_attribute("src", img).set_attribute("style", "position: fixed; left: 0; top: 0; right: 0; bottom: 0; opacity: 0;");
			elements.append(e);
			el.append_child(e);
		}
		current = -1;
		next_image();
		new SwitchTimer().set_ic(this).start(slide_delay);
	}

	public void initialize_js(strptr id, ptr imgs) {
		if(imgs == null) {
			return;
		}
		var ia = LinkedList.create();
		strptr ip;
		embed {{{
			for(var i = 0; i<imgs.length; i++) {
				ip = imgs[i];
				}}}
				ia.append(String.for_strptr(ip).dup());
				embed {{{
			}
		}}}
		initialize(String.for_strptr(id).dup(), ia);
	}

	class FadeOutTimer : BrowserProgressTimer
	{
		property HTMLElement element;
		public void on_progress(double f) {
			element.set_style("opacity", "%f".printf().add(1.0 - f).to_string());
		}
	}

	class FadeInTimer : BrowserProgressTimer
	{
		property HTMLElement element;
		public void on_progress(double f) {
			element.set_style("opacity", "%f".printf().add(f).to_string());
		}
	}

	public void next_image() {
		var ce = elements.get(current) as HTMLElement;
		current++;
		if(current >= elements.count()) {
			current = 0;
		}
		var ne = elements.get(current) as HTMLElement;
		if(ce != null) {
			new FadeOutTimer().set_element(ce).set_duration(transition_delay).execute();
		}
		if(ne != null) {
			new FadeInTimer().set_element(ne).set_duration(transition_delay).execute();
		}
	}
}
