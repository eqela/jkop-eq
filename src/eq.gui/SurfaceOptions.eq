
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

public class SurfaceOptions
{
	public static SurfaceOptions top() {
		return(new SurfaceOptions().set_placement(SurfaceOptions.TOP));
	}

	public static SurfaceOptions bottom() {
		return(new SurfaceOptions().set_placement(SurfaceOptions.BOTTOM));
	}

	public static SurfaceOptions above(Surface ss) {
		return(new SurfaceOptions().set_placement(SurfaceOptions.ABOVE).set_relative(ss));
	}

	public static SurfaceOptions below(Surface ss) {
		return(new SurfaceOptions().set_placement(SurfaceOptions.BELOW).set_relative(ss));
	}

	public static SurfaceOptions inside(Surface ss) {
		return(new SurfaceOptions().set_placement(SurfaceOptions.INSIDE).set_relative(ss));
	}

	public static int TOP = 0;
	public static int BOTTOM = 1;
	public static int ABOVE = 2;
	public static int BELOW = 3;
	public static int INSIDE = 4;
	public static int SURFACE_TYPE_RENDERABLE = 0;
	public static int SURFACE_TYPE_CONTAINER = 1;

	property int placement;
	property Surface relative;
	property Surface surface;
	property int surface_type;
}
