
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
	IFDEF("target_j2me") {
		embed "Java" {{{
			java.util.Random rand = null;
		}}}
	}
	public static MathInterface create() {
		return(new MathImpl());
	}

	public MathImpl() {
		IFDEF("target_j2me") {
			embed "Java" {{{
				rand = new java.util.Random();
			}}}
		}
	}

	public int abs(int n) {
		int v;
		embed "Java" {{{ v = java.lang.Math.abs(n); }}}
		return(v);
	}

	public double fabs(double n) {
		double v;
		embed "Java" {{{ v = java.lang.Math.abs(n); }}}
		return(v);
	}

	public double ceil(double n) {
		double v;
		embed "Java" {{{ v = java.lang.Math.ceil(n); }}}
		return(v);
	}

	public double floor(double n) {
		double v;
		embed "Java" {{{ v = java.lang.Math.floor(n); }}}
		return(v);
	}

	public double rint(double n) {
		double v;
		IFDEF("target_bbjava") {
			embed "Java" {{{ v = net.rim.device.api.util.MathUtilities.round(n); }}}
		}
		ELSE {
			IFNDEF("target_j2me") {
				embed "Java" {{{ v = java.lang.Math.rint(n); }}}
			}
		}
		return(v);
	}

	public double sin(double n) {
		double v;
		embed "Java" {{{ v = java.lang.Math.sin(n); }}}
		return(v);
	}

	public double asin(double n) {
		double v;
		IFDEF("target_bbjava") {
			embed "Java" {{{ v = net.rim.device.api.util.MathUtilities.asin(n); }}}
		}
		ELSE {
			IFNDEF("target_j2me") {
				embed "Java" {{{ v = java.lang.Math.asin(n); }}}
			}
		}
		return(v);
	}

	public double cos(double n) {
		double v;
		embed "Java" {{{ v = java.lang.Math.cos(n); }}}
		return(v);
	}

	public double acos(double n) {
		double v;
		IFDEF("target_bbjava") {
			embed "Java" {{{ v = net.rim.device.api.util.MathUtilities.acos(n); }}}
		}
		ELSE {
			IFNDEF("target_j2me") {
				embed "Java" {{{ v = java.lang.Math.acos(n); }}}
			}
		}
		return(v);
	}

	public double tan(double n) {
		double v;
		embed "Java" {{{ v = java.lang.Math.tan(n); }}}
		return(v);
	}

	public double atan(double n) {
		double v;
		IFDEF("target_bbjava") {
			embed "Java" {{{ v = net.rim.device.api.util.MathUtilities.atan(n); }}}
		}
		ELSE {
			IFNDEF("target_j2me") {
				embed "Java" {{{ v = java.lang.Math.atan(n); }}}
			}
		}
		return(v);
	}

	public double atan2(double a, double b) {
		double v;
		IFDEF("target_bbjava") {
			embed "Java" {{{ v = net.rim.device.api.util.MathUtilities.atan2(a, b); }}}
		}
		ELSE {
			IFNDEF("target_j2me") {
				embed "Java" {{{ v = java.lang.Math.atan2(a, b); }}}
			}
		}
		return(v);
	}

	public double sqrt(double n) {
		double v;
		embed "Java" {{{ v = java.lang.Math.sqrt(n); }}}
		return(v);
	}

	public double cbrt(double n) {
		double v;
		IFDEF("target_bbjava") {
			embed "Java" {{{
					v = net.rim.device.api.util.MathUtilities.pow(n, 1/3); 
			}}}
		}
		ELSE {
			IFNDEF("target_j2me") {
				embed "Java" {{{ v = java.lang.Math.cbrt(n); }}}
			}
		}
		return(v);
	}

	public double log(double n) {
		double v;
		IFDEF("target_bbjava") {
			embed "Java" {{{ v = net.rim.device.api.util.MathUtilities.log(n); }}}
		}
		ELSE {
			IFNDEF("target_j2me") {
				embed "Java" {{{ v = java.lang.Math.log(n); }}}
			}
		}
		return(v);
	}

	public double log10(double n) {
		double v;
		IFDEF("target_bbjava") {
			embed "Java" {{{
				v = net.rim.device.api.util.MathUtilities.log(n) / net.rim.device.api.util.MathUtilities.log(10); 
			}}}
		}
		ELSE {
			IFNDEF("target_j2me") {
				embed "Java" {{{ v = java.lang.Math.log10(n); }}}
			}
		}
		return(v);
	}

	public double exp(double x) {
		double v;
		embed "java" {{{
			v = java.lang.Math.exp(x);
		}}}
		return(v);
	}

	public double pow(double a, double b) {
		double v;
		embed "java" {{{
			v = java.lang.Math.pow(a, b);
		}}}
		return(v);
	}

	public int random(int min, int max) {
		int v;
		IFDEF("target_j2me") {
			embed "Java" {{{ 
				try {
					v = rand.nextInt(max - min) + min; 
				}
				catch(Exception e) {
				}
			}}}
		}
		ELSE {
			embed "Java" {{{ v = (int)(java.lang.Math.random() * (max - min)) + min; }}}
		}
		return(v);
	}
}

