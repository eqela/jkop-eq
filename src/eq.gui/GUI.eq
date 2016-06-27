
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

public interface GUI
{
	public static GUI engine;

	public static void initialize(GUI newEngine) {
		engine = newEngine;
	}

	public bool is_image_file(File file);
	public RenderableImage create_renderable_image(int w, int h);
	public Image create_image_for_buffer(ImageBuffer buf);
	public Image create_image_for_file(File file, int w, int h);
	public Image create_image_for_resource(String res, int w, int h);
	public Clipboard get_default_clipboard();
	public TextLayout layout_text(TextProperties props, Frame frame, int dpi);
	public bool open_url(String url);
	public bool open_file(File file);
	public BackgroundTaskManager get_background_task_manager();
	public bool execute(FrameController main, String argv0, Collection args);
	public WindowManager get_window_manager();
}
