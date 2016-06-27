
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

package eq.gui.sysdep.android;

import eq.gui.*;

public class RenderableSurfaceView extends SurfaceView implements Renderable
{
	private eq.api.Collection ops = null;

	public RenderableSurfaceView(android.content.Context ctx) {
		super(ctx);
		if(android.os.Build.VERSION.SDK_INT >= 11) {
			setLayerType(android.view.View.LAYER_TYPE_HARDWARE, null);
		}
	}

	public void render(eq.api.Collection ops) {
		this.ops = ops;
		if(helper.legacy_alpha && helper._alpha < 0.05) {
			helper.legacy_alpha_render = true;
			return;
		}
		invalidate();
	}

	protected void onDraw(android.graphics.Canvas canvas) {
		if(helper.legacy_alpha && helper._alpha < 0.05) {
			return;
		}
		AndroidVgContext ctx = new AndroidVgContext(canvas);
		ctx.clear(0, 0, eq.gui.vg.VgPathRectangle.Static.create(0, 0, (int)get_width(), (int)get_height()), null);
		eq.gui.vg.VgRenderer.Static.render_to_vg_context(ops, ctx, 0, 0);
	}
}
