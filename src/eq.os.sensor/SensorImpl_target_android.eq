
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

class SensorImpl : Sensor
{
	public static Sensor create(String type) {
		if(type == null) {
			return(null);
		}
		var v = new SensorImpl();
		if(v.initialize(type) == false) {
			Log.error("Sensor type `%s' not supported".printf().add(type));
			return(null);
		}
		return(v);
	}

	~SensorImpl() {
		stop();
	}

	embed "java" {{{
		private class SensorEventHandler implements android.hardware.SensorEventListener
		{
			private eq.os.sensor.Sensor sensor = null;
			private eq.os.sensor.SensorListener listener = null;
			private eq.api.PropertyObject values = null;
			public SensorEventHandler(eq.os.sensor.Sensor sensor) {
				this.sensor = sensor;
				this.values = (eq.api.PropertyObject)this.sensor.get_value();
			}
			public void set_listener(eq.os.sensor.SensorListener listener) {
				this.listener = listener;
			}
			public void onAccuracyChanged(android.hardware.Sensor sensor, int accuracy) {
			}
			public void onSensorChanged(android.hardware.SensorEvent event) {
				int len = event.values.length;
				this.values.set_int(eqstr("timestamp"), (int)event.timestamp);
				for(int i = 0; i < len; i++) {
					this.values.set_double(eqstr("value"+i), (double)event.values[i]);
				}
				if(listener != null) {
					listener.on_sensor_changed(this.sensor);
				}
			}
			private eq.api.String eqstr(java.lang.String str) {
				return(eq.api.String.Static.for_strptr(str));
			}
		}
		private android.hardware.Sensor sensor = null;
		private android.hardware.SensorManager manager = null;
		private SensorEventHandler handler = null;
	}}}

	private PropertyObject values = null;
	private String type = null;

	public bool initialize(String type) {
		if(type == null) {
			return(false);
		}
		values = new PropertyObject();
		this.type = type;
		embed "java" {{{
			int sensor_type = 0;
			if(type.equals_ignore_case(eqstr("gyroscope"))) {
				sensor_type = android.hardware.Sensor.TYPE_GYROSCOPE;
			}
			else if(type.equals_ignore_case(eqstr("accelerometer"))) {
				sensor_type = android.hardware.Sensor.TYPE_ACCELEROMETER;
			}
			else if(type.equals_ignore_case(eqstr("gravity"))) {
				sensor_type = android.hardware.Sensor.TYPE_GRAVITY;
			}
			else if(type.equals_ignore_case(eqstr("orientation"))) {
				sensor_type = android.hardware.Sensor.TYPE_ORIENTATION;
			}
			manager = (android.hardware.SensorManager)eq.api.Android.context
				.getSystemService(eq.api.Android.context.SENSOR_SERVICE);
			handler = new SensorEventHandler((eq.os.sensor.Sensor)this);
			if(manager != null) {
				sensor = manager.getDefaultSensor(sensor_type);
				if(sensor == null) {
					return(false);
				}
				manager.registerListener(handler, sensor, android.hardware.SensorManager.SENSOR_DELAY_NORMAL);
				
			}
		}}}
		return(true);
	}

	private Object eqstr(strptr str) {
		return(String.for_strptr(str));
	}

	public Object get_value() {
		return(values);
	}

	public String get_type() {
		return(type);
	}

	public void set_listener(SensorListener listener) {
		embed "java" {{{
			if(handler != null) {
				handler.set_listener(listener);
			}
		}}}
	}

	public void stop() {
		embed "java" {{{
			if(manager != null) {
				manager.unregisterListener(handler);
			}
		}}}
	}
}

