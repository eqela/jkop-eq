
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

public class SEPointerInfo
{
	property int id = -1;
	property int x = -1;
	property int y = -1;
	property bool pressed = false;
	property int pressed_x = -1;
	property int pressed_y = -1;
	property PointerEvent last_event;

	public bool is_inside(double sx, double sy, double sw, double sh) {
		if(x >= sx && x < sx + sw && y >= sy && y < sy + sh) {
			return(true);
		}
		return(false);
	}

	IFDEF("enable_foreign_api") {
		public int getId() {
			return(id);
		}
		public SEPointerInfo setId(int i) {
			id = i;
			return(this);
		}
		public int getX() {
			return(x);
		}
		public SEPointerInfo setX(int v) {
			x = v;
			return(this);
		}
		public int getY() {
			return(y);
		}
		public SEPointerInfo setY(int v) {
			y = v;
			return(this);
		}
		public bool getPressed() {
			return(pressed);
		}
		public SEPointerInfo setPressed(bool v) {
			pressed = v;
			return(this);
		}
		public int getPressedX() {
			return(pressed_x);
		}
		public SEPointerInfo setPressedX(int v) {
			pressed_x = v;
			return(this);
		}
		public int getPressedY() {
			return(pressed_y);
		}
		public SEPointerInfo setPressedY(int v) {
			pressed_y = v;
			return(this);
		}
		public PointerEvent getLastEvent() {
			return(last_event);
		}
		public SEPointerInfo setLastEvent(PointerEvent ev) {
			last_event = ev;
			return(this);
		}
		public bool isInside(double sx, double sy, double sw, double sh) {
			return(is_inside(sx,sy,sw,sh));
		}
	}
}
