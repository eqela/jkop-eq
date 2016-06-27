
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
		class MyMovingEntity : SEMovingSpriteEntity
		{
			public void initialize(SEResourceCache rsc) {
				base.initialize(rsc);
				randomize_speed();
				set_image_sheet(rsc.get_image_sheet("coin"));
			}

			public void on_outside_x() {
				set_xspeed(get_xspeed() * -1);
			}

			public void on_outside_y() {
				set_yspeed(get_yspeed() * -1);
			}

			public void tick(TimeVal now, double delta) {
				base.tick(now, delta);
				next_frame();
			}
		}

		public void initialize(SEResourceCache rsc) {
			base.initialize(rsc);
			rsc.prepare_image_sheet("coin", null, 16, 2, -1, 0.1 * get_scene_width());
			set_background(Color.instance("#808008"));
		}

		public void on_pointer_press(SEPointerInfo pi) {
			base.on_pointer_press(pi);
			add_entity(new MyMovingEntity().set_xy(pi.get_x(), pi.get_y()));
		}
	}

	public Main() {
		SEDefaultEngine.activate();
	}

	public override FrameController create_main_scene() {
		return(new MainScene());
	}
}