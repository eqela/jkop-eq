
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

public class SceneApplication : FrameController, SceneController, SceneEndListener
{
	Frame frame;
	FrameController scene;
	FrameController nextscene;
	bool started = false;
	CreateFrameOptions frame_options;
	Size preferred_size;
	int prev_w = -1;
	int prev_h = -1;
	Stack scene_stack;

	public SceneApplication() {
		nextscene = create_main_scene();
	}

	public void set_main_scene(FrameController fc) {
		nextscene = fc;
	}

	public virtual FrameController create_main_scene() {
		return(null);
	}

	public Frame get_frame() {
		return(frame);
	}

	public SceneApplication set_frame_options(CreateFrameOptions opts) {
		frame_options = opts;
		return(this);
	}

	public CreateFrameOptions get_frame_options() {
		if(frame_options == null && nextscene != null) {
			return(nextscene.get_frame_options());
		}
		return(frame_options);
	}

	public SceneApplication set_preferred_size(Size sz) {
		preferred_size = sz;
		return(this);
	}

	public Size get_preferred_size() {
		if(preferred_size == null && nextscene != null) {
			return(nextscene.get_preferred_size());
		}
		return(preferred_size);
	}

	public virtual Scene get_next_scene(Scene previous_scene) {
		if(scene_stack != null) {
			return(scene_stack.pop() as Scene);
		}
		return(null);
	}

	public void on_scene_ended(Scene oldscene) {
		if(nextscene == null) {
			nextscene = get_next_scene(oldscene);
		}
		if(scene != null) {
			var nst = nextscene as TransferrableScene;
			var ost = scene as Scene;
			if(nst != null && ost != null) {
				nst.transfer_from(ost);
			}
			scene.stop();
			scene.destroy();
			scene = null;
		}
		if(nextscene != null) {
			scene = nextscene;
			nextscene = null;
			if(scene is Scene) {
				((Scene)scene).set_scene_controller(this);
			}
			scene.initialize_frame(frame);
			scene.on_event(new FrameResizeEvent().set_width(frame.get_width()).set_height(frame.get_height()));
			if(started) {
				scene.start();
			}
		}
		else {
			/* FIXME: closing the frame causes random crashing
			var ff = frame as ClosableFrame;
			if(ff != null) {
				ff.close();
			}
			else {
				SystemEnvironment.terminate(0);
			}
			*/
			SystemEnvironment.terminate(0);
		}
	}

	public void push_scene(FrameController newscene) {
		if(newscene == null) {
			return;
		}
		if(scene != null) {
			if(scene_stack == null) {
				scene_stack = Stack.create();
			}
			scene_stack.push(scene);
		}
		switch_scene(newscene);
	}

	public void pop_scene() {
		switch_scene(null);
	}

	public virtual void switch_scene(FrameController newscene) {
		this.nextscene = newscene;
		if(scene != null && scene is Scene) {
			var ss = (Scene)scene;
			ss.end_scene(this);
		}
		else {
			on_scene_ended(null);
		}
	}

	public virtual Color get_background_color() {
		return(Color.instance("black"));
	}

	public virtual void initialize_frame(Frame frame) {
		Log.debug("SceneApplication frame initializing");
		this.frame = frame;
		if(frame != null && frame is TitledFrame) {
			((TitledFrame)frame).set_title(Application.get_display_name());
			((TitledFrame)frame).set_icon(IconCache.get("appicon"));
		}
		if(frame != null && frame is ColoredFrame) {
			var bgc = get_background_color();
			if(bgc != null) {
				((ColoredFrame)frame).set_frame_background_color(bgc);
			}
		}
		initialize();
	}

	public virtual void initialize() {
	}

	public virtual void start() {
		started = true;
		if(scene != null) {
			scene.start();
		}
	}

	public virtual void stop() {
		started = false;
		if(scene != null) {
			scene.stop();
		}
	}

	public virtual void destroy() {
		if(scene != null) {
			scene.destroy();
			scene = null;
		}
	}

	public virtual FrameController customize_first_scene(FrameController scene) {
		return(scene);
	}

	public bool on_event(Object o) {
		if(o != null && o is FrameResizeEvent) {
			if(frame == null) {
				Log.debug("SceneApplication received a FrameResizeEvent, but no frame is yet available.");
				return(false);
			}
			if(frame.get_width() == prev_w && frame.get_height() == prev_h) {
				return(true);
			}
			prev_w = frame.get_width();
			prev_h = frame.get_height();
			if(scene == null) {
				nextscene = customize_first_scene(nextscene);
			}
			if(scene == null && nextscene != null) {
				on_scene_ended(null);
			}
			else if(scene != null) {
				scene.on_event(o);
			}
			return(true);
		}
		if(scene != null) {
			if(scene.on_event(o)) {
				return(true);
			}
		}
		if(o != null && o is FrameCloseRequestEvent) {
			((FrameCloseRequestEvent)o).accept();
			return(true);
		}
		return(false);
	}

	public void on_create(String command, Collection args) {
	}
}
