
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

private class PokktCallBackReceiver 
{
	embed "java" {{{
		eq.ext.pokkt.PokktOfferWallListener offer_wall_listener;

		public void registerBroadcastReceiver(eq.ext.pokkt.PokktOfferWallListener listener) {
			try {
				offer_wall_listener = listener;
				android.content.IntentFilter filter = new android.content.IntentFilter(com.app.pokktsdk.PokktManager.ACTION);
				MyReceiver receiver = new MyReceiver(offer_wall_listener);
				eq.api.Android.context.registerReceiver(receiver, filter);
			} catch (Exception e) {
			}
		}

		class MyReceiver extends android.content.BroadcastReceiver
		{
			public MyReceiver(eq.ext.pokkt.PokktOfferWallListener offer_wall_listener) {
				this.offer_wall_listener = offer_wall_listener;
			}

			eq.ext.pokkt.PokktOfferWallListener offer_wall_listener;
			@Override
			public void onReceive(android.content.Context context, android.content.Intent intent) {
				try {
					if(intent.getExtras() != null) {
						if(intent.getAction().equals(com.app.pokktsdk.PokktManager.ACTION)) {
							android.os.Bundle b = intent.getExtras();
							String coinStatus = b.getString(com.app.pokktsdk.PokktManager.COINS_STATUS);
							String coins = b.getString(com.app.pokktsdk.PokktManager.COINS);
							if(coinStatus.equals("1")) {
								if(offer_wall_listener != null) {
									offer_wall_listener.on_offer_wall_gratified(java.lang.Integer.parseInt(coins));
								}
							}
							else {
								if(offer_wall_listener != null) {
									offer_wall_listener.on_offer_wall_gratified(0);
								}
							}
							
						}
					}
				}
				catch(Exception e) {
				}
			}
		}
	}}}
}
