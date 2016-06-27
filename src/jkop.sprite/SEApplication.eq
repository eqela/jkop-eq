
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

public class SEApplication : SceneApplication
{
	property Size window_size = null;
	property bool enable_splash_scene = true;

	public virtual void customize_splash_scene(SESplashScene scene) {
	}

	public virtual FrameController create_splash_scene(FrameController next_scene) {
		var v = new SESplashScene();
		v.set_next_scene(next_scene);
		customize_splash_scene(v);
		return(v);
	}

	public FrameController customize_first_scene(FrameController scene) {
		if(enable_splash_scene) {
			return(create_splash_scene(scene));
		}
		return(scene);
	}

	public CreateFrameOptions get_frame_options() {
		parse_args();
		var v = new CreateFrameOptions();
		v.set_resizable(false);
		var ws = window_size;
		var wt = SystemEnvironment.get_env_var("EQ_SPRITEENGINE_FULLSCREEN");
		if("yes".equals(wt)) {
			ws = null;
		}
		if(ws == null) {
			v.set_type(CreateFrameOptions.TYPE_FULLSCREEN);
		}
		else {
			v.set_type(CreateFrameOptions.TYPE_NORMAL);
		}
		return(v);
	}

	public Size get_preferred_size() {
		parse_args();
		var v = window_size;
		if(v == null) {
			v = Size.instance(1024, 768);
		}
		return(v);
	}

	bool _args_parsed = false;
	void parse_args() {
		if(_args_parsed) {
			return;
		}
		_args_parsed = true;
		foreach(String arg in Application.get_instance_args()) {
			if("-fullscreen".equals(arg) || "-fs".equals(arg)) {
				window_size = null;
			}
			else if(arg.has_prefix("-window=")) {
				var wss = arg.substring(8);
				var it = wss.split('x', 2);
				var widths = String.as_string(it.next());
				var heights = String.as_string(it.next());
				if(widths != null && heights != null) {
					window_size = Size.instance(widths.to_integer(), heights.to_integer());
				}
			}
		}
	}
}
