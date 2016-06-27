
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

public class SmallArrowIcon : IconWidget
{
	public static SmallArrowIcon left() {
		return(new SmallArrowIcon().set_direction(SmallArrowIcon.LEFT));
	}

	public static SmallArrowIcon up() {
		return(new SmallArrowIcon().set_direction(SmallArrowIcon.UP));
	}

	public static SmallArrowIcon right() {
		return(new SmallArrowIcon().set_direction(SmallArrowIcon.RIGHT));
	}

	public static SmallArrowIcon down() {
		return(new SmallArrowIcon().set_direction(SmallArrowIcon.DOWN));
	}

	public static int LEFT = 0;
	public static int UP = 1;
	public static int RIGHT = 2;
	public static int DOWN = 3;
	property int direction = 0;
	property String arrow_size;
	int sz;

	public SmallArrowIcon() {
		arrow_size = "1500um";
	}

	public void initialize() {
		base.initialize();
		sz = px(arrow_size);
	}

	public Collection render() {
		var cc = get_draw_color();
		if(cc == null) {
			cc = Color.instance("black");
		}
		var w2 = get_width() / 2;
		var h2 = get_height() / 2;
		var v = LinkedList.create();
		Shape ss;
		if(direction == LEFT) {
			ss = CustomShape.create(w2-sz/2, h2).line(w2+sz/2, h2-sz/2).line(w2+sz/2, h2+sz/2);
		}
		else if(direction == UP) {
			ss = CustomShape.create(w2, h2-sz/2).line(w2+sz/2, h2+sz/2).line(w2-sz/2, h2+sz/2);
		}
		else if(direction == RIGHT) {
			ss = CustomShape.create(w2+sz/2, h2).line(w2-sz/2, h2-sz/2).line(w2-sz/2, h2+sz/2);
		}
		else if(direction == DOWN) {
			ss = CustomShape.create(w2, h2+sz/2).line(w2+sz/2, h2-sz/2).line(w2-sz/2, h2-sz/2);
		}
		v.add(new FillColorOperation().set_color(cc).set_shape(ss));
		return(v);
	}
}
