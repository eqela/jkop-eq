
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

public class FillGradientOperation
{
	public static int VERTICAL = 0;
	public static int HORIZONTAL = 1;
	public static int RADIAL = 2;
	public static int DIAGONAL_TLBR = 3; // TLBR = Top Left -> Bottom Right
	public static int DIAGONAL_TRBL = 4; // TRBL = Top Right -> Bottom Left
	public static int DIAGONAL_BRTL = 5; // BRTL = Bottom Right -> Top Left
	public static int DIAGONAL_BLTR = 6; // BLTR = Bottom Left -> Top Right
	property double x;
	property double y;
	property Shape shape;
	property Transform transform;
	property double radius;
	property Color color1;
	property Color color2;
	property int type;
}
