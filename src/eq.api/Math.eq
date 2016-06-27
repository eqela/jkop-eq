
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

public class Math
{
	static MathInterface math;

	public static int abs(int n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.abs(n));
	}

	public static double fabs(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.fabs(n));
	}

	public static double ceil(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.ceil(n));
	}

	public static double floor(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.floor(n));
	}

	public static double rint(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.rint(n));
	}

	public static double sin(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.sin(n));
	}

	public static double asin(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.asin(n));
	}

	public static double cos(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.cos(n));
	}

	public static double acos(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.acos(n));
	}

	public static double tan(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.tan(n));
	}

	public static double atan(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.atan(n));
	}

	public static double atan2(double a, double b) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.atan2(a, b));
	}

	public static double sqrt(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.sqrt(n));
	}

	public static double cbrt(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.cbrt(n));
	}

	public static double log(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.log(n));
	}

	public static double log10(double n) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.log10(n));
	}

	public static int random(int min, int max) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.random(min, max));
	}

	public static double exp(double x) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.exp(x));
	}

	public static double pow(double a, double b) {
		if(math == null) {
			math = new MathImpl();
		}
		return(math.pow(a, b));
	}

	public static double min(double a, double b) {
		if(a < b) {
			return(a);
		}
		return(b);
	}

	public static double max(double a, double b) {
		if(a > b) {
			return(a);
		}
		return(b);
	}
}
