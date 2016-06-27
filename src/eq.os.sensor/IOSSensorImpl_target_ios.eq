
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

public class IOSSensorImpl : Sensor
{
	embed "objc" {{{
		#import <UIKit/UIKit.h>
		#import <CoreMotion/CoreMotion.h>
	}}}

	public static Sensor create(String type) {
		if(type == null) {
			return(null);
		}
		var v = new IOSSensorImpl();
		if(v.initialize(type) == false) {
			Log.error("Sensor type `%s' not supported".printf().add(type));
			return(null);
		}
		return(v);
	}

	~IOSSensorImpl() {
		stop();
	}

	PropertyObject values = null;
	String type = null;
	SensorListener listener;
	ptr motionManager;

	public bool initialize(String type) {
		if(type == null) {
			return(false);
		}
		ptr mm;
		values = new PropertyObject();
		this.type = type;
		var tt = this.type.to_strptr();
		embed "objc" {{{
			CMMotionManager* cmmm = [[CMMotionManager alloc] init];
			NSString* nstype = [[NSString alloc] initWithUTF8String:tt];
			if ([nstype isEqualToString:@"gyroscope"])
			{
				cmmm.gyroUpdateInterval = .2;
				if (cmmm.gyroAvailable) {
					[cmmm startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
						CMRotationRate rotation = gyroData.rotationRate;
						eq_os_sensor_IOSSensorImpl_setMotionData(self, rotation.x, rotation.y, rotation.z);
					}];
				}
			}
			else if ([nstype isEqualToString:@"accelerometer"])
			{
				cmmm.accelerometerUpdateInterval = .2;
				if (cmmm.accelerometerAvailable) {
					[cmmm startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
						eq_os_sensor_IOSSensorImpl_setMotionData(self, accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z);
					}];
				}
			}
			else if ([nstype isEqualToString:@"magnetometer"])
			{
				cmmm.magnetometerUpdateInterval = .2;
				if (cmmm.magnetometerAvailable) {
					[cmmm startMagnetometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
						CMMagneticField magneticfield = magnetometerData.magneticField;
						eq_os_sensor_IOSSensorImpl_setMotionData(self, magneticfield.x, magneticfield.y, magneticfield.z);
					}];
				}
			}
			else {
				return(false);
			}
			mm = (__bridge_retained void*)cmmm;
		}}}
		motionManager = mm;
		return(true);
	}

	private void setMotionData(double x, double y, double z) {
		if(listener == null) {
			return;
		}
		values.set_double("value0", x);
		values.set_double("value1", y);
		values.set_double("value2", z);
		listener.on_sensor_changed(this);
	}

	public Object get_value() {
		return(values);
	}

	public String get_type() {
		return(type);
	}

	public void set_listener(SensorListener listener) {
		this.listener = listener;
	}

	private void stop() {
		if(motionManager == null) {
			return;
		}
		var mm = motionManager;
		var tt = type.to_strptr();
		embed "objc" {{{
			CMMotionManager* cmmm = (__bridge CMMotionManager*)mm;
			NSString* nstype = [[NSString alloc] initWithUTF8String:tt];
			if ([nstype isEqualToString:@"gyroscope"])
			{
				[cmmm stopGyroUpdates];
			}
			else if ([nstype isEqualToString:@"accelerometer"])
			{
				[cmmm stopAccelerometerUpdates];
			}
			else if ([nstype isEqualToString:@"magnetometer"])
			{
				[cmmm stopMagnetometerUpdates];
			}
			(__bridge_transfer CMMotionManager*)mm;
		}}}
		motionManager = null;
	}
}
