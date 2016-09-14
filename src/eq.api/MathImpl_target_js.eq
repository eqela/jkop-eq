
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
	public static MathInterface create() {
		return(new MathImpl());
	}

	public int abs(int n) {
		int v;
		embed "js" {{{
			v = Math.abs(n);
		}}}
		return(v);
	}

	public double fabs(double n) {
		double v;
		embed "js" {{{
			v = Math.abs(n);
		}}}
		return(v);
	}

	public double ceil(double n) {
		double v;
		embed "js" {{{
			v = Math.ceil(n);
		}}}
		return(v);
	}

	public double floor(double n) {
		double v;
		embed "js" {{{
			v = Math.floor(n);
		}}}
		return(v);
	}

	public double rint(double n) {
		double v;
		embed "js" {{{
			v = Math.round(n);
		}}}
		return(v);
	}

	public double sin(double n) {
		double v;
		embed "js" {{{
			v = Math.sin(n);
		}}}
		return(v);
	}

	public double asin(double n) {
		double v;
		embed "js" {{{
			v = Math.asin(n);
		}}}
		return(v);
	}

	public double cos(double n) {
		double v;
		embed "js" {{{
			v = Math.cos(n);
		}}}
		return(v);
	}

	public double acos(double n) {
		double v;
		embed "js" {{{
			v = Math.acos(n);
		}}}
		return(v);
	}

	public double tan(double n) {
		double v;
		embed "js" {{{
			v = Math.tan(n);
		}}}
		return(v);
	}

	public double atan(double n) {
		double v;
		embed "js" {{{
			v = Math.atan(n);
		}}}
		return(v);
	}

	public double atan2(double a, double b) {
		double v;
		embed "js" {{{
			v = Math.atan2(a, b);
		}}}
		return(v);
	}

	public double sqrt(double n) {
		double v;
		embed "js" {{{
			v = Math.sqrt(n);
		}}}
		return(v);
	}

	public double cbrt(double n) {
		double v;
		embed "js" {{{
			v = Math.pow(n, 1/3);
		}}}
		return(v);
	}

	public double log(double n) {
		double v;
		embed "js" {{{
			v = Math.log(n);
		}}}
		return(v);
	}

	public double log10(double n) {
		double v;
		embed "js" {{{
			v = Math.log(n) / Math.log(10);
		}}}
		return(v);
	}

	public double exp(double x) {
		double v;
		embed "js" {{{
			v = Math.exp(x);
		}}}
		return(v);
	}

	public double pow(double a, double b) {
		double v;
		embed "js" {{{
			v = Math.pow(a,b);
		}}}
		return(v);
	}

	public int random(int min, int max) {
		int v;
		embed "js" {{{
			v = ~~(min + Math.random() * (max - min));
		}}}
		return(v);
	}
}

