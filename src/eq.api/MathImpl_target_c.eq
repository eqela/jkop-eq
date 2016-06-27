
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

class MathImpl : MathInterface
{
	embed "c" {{{
		#include <math.h>
		#include <time.h>
	}}}

	IFDEF("target_win32") {
		embed "c" {{{
			#include <float.h>
		}}}
	}

	IFDEF("target_qnx") {
		embed "c" {{{
			#undef sin
			#undef cos
			#undef log
			#undef log10
		}}}
	}

	public static MathInterface create() {
		return(new MathImpl());
	}

	public MathImpl() {
	}

	public int abs(int n) {
		if(n < 0) {
			return(-n);
		}
		return(n);
	}

	public double fabs(double n) {
		if(n < 0) {
			return(-n);
		}
		return(n);
	}

	public double ceil(double n) {
		double v;
		embed "c" {{{
			v = ceil(n);
		}}}
		return(v);
	}

	public double floor(double n) {
		double v;
		embed "c" {{{
			v = floor(n);
		}}}
		return(v);
	}

	public double rint(double n) {
		double v;
		IFDEF("target_win32") {
			embed "c" {{{
				double x = n - (double)((int)n);
				if(x < 0.5) {
					v = floor(n);
				}
				else {
					v = ceil(n);
				}
			}}}
		}
		ELSE {
			embed "c" {{{
				v = rint(n);
			}}}
		}
		return(v);
	}

	public double sin(double n) {
		double v;
		IFDEF("target_qnx") {
			embed "c" {{{
				v = _Sin(n, 0);
			}}}
		}
		ELSE {
			embed "c" {{{
				v = sin(n);
			}}}
		}

		return(v);
	}

	public double asin(double n) {
		double v;
		embed "c" {{{
			v = asin(n);
		}}}
		return(v);
	}

	public double cos(double n) {
		double v;
		IFDEF("target_qnx") {
			embed "c" {{{
				v = _Sin(n, 1);
			}}}
		}
		ELSE {
			embed "c" {{{
				v = cos(n);
			}}}
		}
		return(v);
	}

	public double acos(double n) {
		double v;
		embed "c" {{{
			v = acos(n);
		}}}
		return(v);
	}

	public double tan(double n) {
		double v;
		embed "c" {{{
			v = tan(n);
		}}}
		return(v);
	}

	public double atan(double n) {
		double v;
		embed "c" {{{
			v = atan(n);
		}}}
		return(v);
	}

	public double atan2(double a, double b) {
		double v;
		embed "c" {{{
			v = atan2(a, b);
		}}}
		return(v);
	}

	public double sqrt(double n) {
		double v;
		embed "c" {{{
			v = sqrt(n);
		}}}
		return(v);
	}

	public double cbrt(double n) {
		double v;
		IFDEF("target_win32") {
			embed "c" {{{
				if(n > 0.0) {
					v = pow(n, 1.0/3.0);
				}
				else {
					v = -pow(-n, 1.0/3.0);
				}
			}}}
		}
		ELSE {
			embed "c" {{{
				v = cbrt(n);
			}}}
		}
		return(v);
	}

	public double log(double n) {
		double v;
		IFDEF("target_qnx") {
			embed "c" {{{
				v = _Log(n, 0);
			}}}
		}
		ELSE {
			embed "c" {{{
				v = log(n);
			}}}
		}
		return(v);
	}

	public double log10(double n) {
		double v;
		IFDEF("target_qnx") {
			embed "c" {{{
				v = _Log(n, 1);
			}}}
		}
		ELSE {
			embed "c" {{{
				v = log10(n);
			}}}
		}
		return(v);
	}

	public double exp(double x) {
		double v;
		embed "c" {{{
			v = exp(x);
		}}}
		return(v);
	}

	public double pow(double a, double b) {
		double v;
		embed "c" {{{
			v = pow(a, b);
		}}}
		return(v);
	}

	private static bool sranded = false;

	public int random(int min, int max) {
		if(sranded == false) {
			sranded = true;
			embed "c" {{{
				srand(time(NULL));
			}}}
		}
		if(max == min) {
			return(max);
		}
		int v;
		embed "c" {{{
			v = min + rand() % (max - min);
		}}}
		return(v);
	}
}

