
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

public class GuiApplication
{
	public static bool execute(Object main, String argv0, Collection argv) {
		Application.set_main(main);
		Application.set_instance_command(argv0);
		Application.set_instance_args(argv);
		if(GUI.engine == null) {
			Log.error("No GUI engine.");
			return(false);
		}
		FrameController controller;
		if(main == null) {
			Log.error("No Main object.");
			return(false);
		}
		if(main is GuiApplicationMain) {
			controller = ((GuiApplicationMain)main).create_frame_controller();
		}
		else if(main is FrameController) {
			controller = (FrameController)main;
		}
		else {
			Log.error("GuiApplication: The Main object is of unknown data type.");
		}
		if(controller == null) {
			Log.error("GuiApplication: Unable to come up with a frame controller. Exiting.");
			return(false);
		}
		controller.on_create(argv0, argv);
		return(GUI.engine.execute(controller, argv0, argv));
	}
}
