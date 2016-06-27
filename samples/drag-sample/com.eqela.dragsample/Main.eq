
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

public class Main : SEApplication
{
	class MainScene : SEScene
	{
		public void initialize(SEResourceCache rsc) {
			base.initialize(rsc);
			var width = get_scene_width();
			var height = get_scene_height();
			rsc.prepare_image("image", "image", get_scene_width() * 0.15);
			rsc.prepare_font("myfont", "color=white bold outline-color=#80FF80", height * 0.07);
			var layer = add_layer(0, 0, width, height);
			add_entity(SESpriteEntity.for_color(Color.instance("#000040"), width, height)
				.set_container(layer));
			add_entity(new MyDraggableSprite().set_xy(width/3, height/2));
			add_entity(new MyDraggableSprite().set_xy(width/2, height/2));
			add_entity(new MyDraggableSprite().set_xy(width/3*2, height/2));
			add_entity(new MyTextSprite().set_xy(width * 0.02, height * 0.02));
		}
	}

	public Main() {
		SEDefaultEngine.activate();
	}

	public override FrameController create_main_scene() {
		return(new MainScene());
	}
}
