
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

public class SEMovingSpriteEntity : SESpriteEntity
{
	property double xspeed;
	property double yspeed;
	property int rotatespeed;

	public virtual void randomize_speed() {
		set_xspeed(get_scene_width() * (double)Math.random(0-100, 100) / 1500.0);
		set_yspeed(get_scene_width() * (double)Math.random(0-100, 100) / 1500.0);
		set_rotatespeed(Math.random(1, 3));
	}

	public virtual void on_outside_x() {
		remove_entity();
	}

	public virtual void on_outside_y() {
		remove_entity();
	}

	public void move_vector(double x, double y, double f) {
		move(get_x() + x * f, get_y() + y * f);
	}

	public void tick(TimeVal now, double delta) {
		base.tick(now, delta);
		var xspeed = get_xspeed();
		var yspeed = get_yspeed();
		move_vector(xspeed, yspeed, delta);
		set_rotation(get_rotation() + ((double)rotatespeed) * delta);
		if(get_x() < 0 - get_width() || get_x() > get_scene_width()) {
			on_outside_x();
			return;
		}
		if(get_y() < 0 || get_y() >= get_scene_height() - get_height()) {
			on_outside_y();
			return;
		}
	}
}
