
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

public class GUIEngine
{
	public static void initialize() {
		if(eq.gui.GUI.engine != null) {
			return;
		}
		GUI e;
		IFDEF("target_android") {
			e = new eq.gui.sysdep.android.GuiEngine();
		}
		ELSE IFDEF("target_osx") {
			e = new eq.gui.sysdep.osx.GuiEngine();
		}
		ELSE IFDEF("target_ios") {
			e = new eq.gui.sysdep.ios.GuiEngine();
		}
		ELSE IFDEF("target_html") {
			e = new eq.gui.sysdep.html5.GuiEngine();
		}
		ELSE IFDEF("target_linux") {
			e = new eq.gui.sysdep.gtk.GuiEngine();
		}
		ELSE IFDEF("target_win7m32") {
			e = new eq.gui.sysdep.direct2d.GuiEngine();
		}
		ELSE IFDEF("target_win7m64") {
			e = new eq.gui.sysdep.direct2d.GuiEngine();
		}
		ELSE IFDEF("target_winxp") {
			e = new eq.gui.sysdep.gdiplus.GuiEngine();
		}
		ELSE IFDEF("target_wp8cs") {
			e = new eq.gui.sysdep.wpcs.GuiEngine();
		}
		ELSE IFDEF("target_uwpcs") {
			e = new eq.gui.sysdep.xamlcs.GuiEngine();
		}
		ELSE IFDEF("target_bbjava") {
			e = new eq.gui.sysdep.bbjava.GuiEngine();
		}
		ELSE IFDEF("target_j2me") {
			e = new eq.gui.sysdep.j2me.GuiEngine();
		}
		ELSE IFDEF("target_j2se") {
			e = new eq.gui.sysdep.swing.GuiEngine();
		}
		eq.gui.GUI.engine = e;
	}
}
