
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

public class PointerImpl : Pointer
{
	public static PointerImpl create(ptr pointer) {
		var v = new PointerImpl();
		v.pointer = pointer;
		v.n = 0;
		return(v);
	}

	private ptr pointer = null;
	private int n = 0;

	public Pointer move(int n) {
		var np = new PointerImpl();
		np.pointer = pointer;
		np.n = this.n + n;
		return(np);
	}

	public int get_current_index() {
		return(n);
	}

	public bool cpyfrom(Pointer src, int soffset, int doffset, int size) {
		if(src == null || src is PointerImpl == false) {
			return(false);
		}
		var sp = src.get_native_pointer();
		var pointer = this.pointer;
		var thisn = this.n;
		var srcn = ((PointerImpl)src).n;
		embed "js" {{{
			var n = 0;
			while(n < size) {
				pointer[thisn + n + doffset] = sp[srcn + n + soffset];
				n++;
			}
		}}}
		return(true);
	}

	public void set_range(int val, int size) {
		//FIXME: TBI
	}

	public void set_byte(int n, uint8 bt) {
		var pointer = this.pointer;
		var thisn = this.n;
		embed "js" {{{
			pointer[thisn + n] = bt;
		}}}
	}

	public uint8 get_byte(int n) {
		uint8 v;
		var pointer = this.pointer;
		var thisn = this.n;
		embed "js" {{{
			v = pointer[thisn + n];
		}}}
		return(v);
	}

	public ptr get_native_pointer() {
		return(pointer);
	}
}

