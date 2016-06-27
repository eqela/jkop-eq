
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

class HTML5SEApplication : SEApplication
{
	embed {{{
		function jkopInitializeSpriteEngineApp(scene, images) {
			eq.api.Application.initialize(
				eq.api.StringStatic.for_strptr("jkop.sprite.api.html5.app"),
				eq.api.StringStatic.for_strptr("Jkop application"),
				eq.api.StringStatic.for_strptr(""),
				eq.api.StringStatic.for_strptr(""),
				eq.api.StringStatic.for_strptr(""),
				eq.api.StringStatic.for_strptr(""),
				eq.api.StringStatic.for_strptr("")
			);
			eq.gui.engine.GUIEngine.initialize();
			var fr = new eq.gui.sysdep.html5.HTML5Frame();
			eq.gui.sysdep.html5.GuiEngine.eq_gui_sysdep_html5_GuiEngine_icon_ids.set(
				eq.api.StringStatic.for_strptr("eqela_splash_logo"),
				eq.api.StringStatic.for_strptr("eqela_splash_logo.png")
			);
			fr.load_icon_js("eqela_splash_logo");
			if(images) {
				for(var n=0 ; n<images.length; n++) {
					var idx = images[n].lastIndexOf('.');
					if(idx < 0) {
						continue;
					}
					var id = images[n].substring(0, idx);
					eq.gui.sysdep.html5.GuiEngine.eq_gui_sysdep_html5_GuiEngine_icon_ids.set(
						eq.api.StringStatic.for_strptr(id),
						eq.api.StringStatic.for_strptr(images[n])
					);
					fr.load_icon_js(id);
				}
			}
			var mo = new jkop.sprite.api.html5.HTML5SEApplication();
			mo.set_main_scene(scene);
			fr.initialize(mo);
			return(mo);
		}
	}}}

	public HTML5SEApplication() {
		SEDefaultEngine.activate();
	}
}
