
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

public class SEGenericGameLoop : SEGameLoop, TimerHandler
{
	public static SEGenericGameLoop for_scene(SEScene scene, int target_fps = 60) {
		if(scene == null) {
			return(null);
		}
		var v = new SEGenericGameLoop().set_scene(scene).set_target_fps(target_fps);
		if(v.start() == false) {
			v = null;
		}
		return(v);
	}

	BackgroundTask timer;
	property SEScene scene;
	property int target_fps = 60;
	bool stop_flag = false;

	public bool start() {
		if(timer != null) {
			return(false);
		}
		if(GUI.engine == null) {
			return(false);
		}
		timer = Timer.start(GUI.engine.get_background_task_manager(), 1000000 / target_fps, this);
		if(timer == null) {
			return(false);
		}
		return(true);
	}

	public bool on_timer(Object arg) {
		if(stop_flag == false) {
			scene.tick();
		}
		if(stop_flag) {
			timer = null;
			return(false);
		}
		return(true);
	}

	public void stop() {
		stop_flag = true;
	}
}
