
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

public class ActivityManagerBackgroundWidget : LayerWidget
{
	public static ActivityManagerBackgroundWidget for_tile(String name, int sz) {
		return(new ActivityManagerBackgroundWidget().set_imgname(name).set_tilesz(sz));
	}

	public static ActivityManagerBackgroundWidget for_filled_image(String name) {
		return(new ActivityManagerBackgroundWidget().set_imgname(name));
	}

	public static ActivityManagerBackgroundWidget for_color(Color cc) {
		return(new ActivityManagerBackgroundWidget().set_color(cc));
	}

	property String imgname;
	property int tilesz;
	property Color color;

	public void initialize() {
		base.initialize();
		if(imgname != null) {
			if(tilesz > 0) {
				var bgi = IconCache.get(imgname, tilesz, tilesz);
				if(bgi != null) {
					add(ImageWidget.for_image(bgi).set_mode("tile"));
				}
			}
			else {
				add(ImageWidget.for_image(IconCache.get(imgname)).set_mode("fill"));
			}
		}
		else if(color != null) {
			add(CanvasWidget.for_color(color));
		}
	}
}
