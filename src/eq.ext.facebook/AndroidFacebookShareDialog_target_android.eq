
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

extern interface eq.gui.sysdep.android.ActivityResultListener
{
}

public class AndroidFacebookShareDialog : FacebookShareDialog
{
	class AndroidFacebookShareDialogActivityResultListener : eq.gui.sysdep.android.ActivityResultListener
	{
		embed "java" {{{
			eq.gui.social.SocialShareDialogListener listener;
			com.facebook.UiLifecycleHelper uiHelper;

			public void onActivityResult(int requestCode, int resultCode, android.content.Intent data) {
				if(uiHelper != null) {
					uiHelper.onActivityResult(requestCode, resultCode, data, new com.facebook.widget.FacebookDialog.Callback() {
						@Override
						public void onError(com.facebook.widget.FacebookDialog.PendingCall pendingCall, Exception error, android.os.Bundle data) {
							if (listener != null) {
								listener.on_social_share_complete(false);
							}
						}

						@Override
						public void onComplete(com.facebook.widget.FacebookDialog.PendingCall pendingCall, android.os.Bundle data) {
							if (listener != null) {
								listener.on_social_share_complete(true);
							}
						}
					});
				}
				eq.gui.sysdep.android.FrameActivity activity = eq.gui.sysdep.android.FrameActivity.get_instance();
				if(activity != null) {
					activity.remove_activity_result_listener(this);
				}
			}

			public AndroidFacebookShareDialogActivityResultListener set_listener(eq.gui.social.SocialShareDialogListener listener) {
				this.listener = listener;
				return(this);
			}

			public AndroidFacebookShareDialogActivityResultListener set_uiHelper(com.facebook.UiLifecycleHelper uiHelper) {
				this.uiHelper = uiHelper;
				return(this);
			}
		}}}
	}

	embed "java" {{{
		class AndroidFacebookShareDialogSessionStatusCallback implements com.facebook.Session.StatusCallback
		{
			eq.gui.social.SocialShareDialogListener listener;
			eq.gui.sysdep.android.FrameActivity activity;
			android.os.Bundle params;

			@Override
			public void call(com.facebook.Session session, com.facebook.SessionState state, Exception exception) {
				if (session.isOpened()) {
					com.facebook.Session.setActiveSession(session);
					com.facebook.widget.WebDialog feedDialog = (new com.facebook.widget.WebDialog.FeedDialogBuilder(activity, session, params))
						.setOnCompleteListener(new com.facebook.widget.WebDialog.OnCompleteListener() {
							@Override
							public void onComplete(android.os.Bundle values, com.facebook.FacebookException error) {
								if (error == null) {
									if (values.getString("post_id") != null) {
										if (listener != null) {
											listener.on_social_share_complete(true);
										}
									} else {
										if (listener != null) {
											listener.on_social_share_complete(false);
										}
									}
								} else if (error instanceof com.facebook.FacebookOperationCanceledException) {
									if (listener != null) {
										listener.on_social_share_complete(false);
									}
								} else {
									if (listener != null) {
										listener.on_social_share_complete(false);
									}
								}
							}
						})
						.build();
					feedDialog.show();
				} else {
					System.out.println("[ERROR] Failed to open `Facebook Session'. Discarding task.");
				}
			}

			public AndroidFacebookShareDialogSessionStatusCallback set_listener(eq.gui.social.SocialShareDialogListener listener) {
				this.listener = listener;
				return(this);
			}

			public AndroidFacebookShareDialogSessionStatusCallback set_activity(eq.gui.sysdep.android.FrameActivity activity) {
				this.activity = activity;
				return(this);
			}

			public AndroidFacebookShareDialogSessionStatusCallback set_params(android.os.Bundle params) {
				this.params = params;
				return(this);
			}
		}
	}}}

	public void execute(Frame frame, SocialShareDialogListener listener) {
		if(frame == null) {
			if(listener != null) {
				listener.on_social_share_complete(false);
			}
			return;
		}
		var appid = get_application_id();
		if(String.is_empty(appid)) {
			URLHandler.open("https://www.facebook.com/sharer/sharer.php?u=".append(URLEncoder.encode(get_initial_link())));
			return;
		}
		var a = appid.to_strptr();
		var link_title = get_link_title();
		if(String.is_empty(link_title)) {
			link_title = "";
		}
		var lt = link_title.to_strptr();
		var link_subtitle = get_link_subtitle();
		if(String.is_empty(link_subtitle)) {
			link_subtitle = "";
		}
		var lst = link_subtitle.to_strptr();
		var link_description = get_link_description();
		if(String.is_empty(link_description)) {
			link_description = "";
		}
		var ld = link_description.to_strptr();
		var link_picture = get_link_picture();
		if(String.is_empty(link_picture)) {
			link_picture = "";
		}
		var lp = link_picture.to_strptr();
		var link = get_initial_link();
		if(String.is_empty(link)) {
			link = "";
		}
		var l = link.to_strptr();
		embed "java" {{{
			eq.gui.sysdep.android.FrameActivity activity = eq.gui.sysdep.android.FrameActivity.get_instance();
			if (activity == null) {
				System.out.println("[ERROR] No Android activity!");
				return;
			}
			com.facebook.UiLifecycleHelper uiHelper = new com.facebook.UiLifecycleHelper(activity, null);
			activity.add_activity_result_listener(new AndroidFacebookShareDialogActivityResultListener().set_listener(listener).set_uiHelper(uiHelper));
			com.facebook.Settings.setApplicationId(a);
			if (com.facebook.widget.FacebookDialog.canPresentShareDialog(eq.api.Android.context, com.facebook.widget.FacebookDialog.ShareDialogFeature.SHARE_DIALOG)) {
				com.facebook.widget.FacebookDialog.ShareDialogBuilder shareDialogBuilder = new com.facebook.widget.FacebookDialog.ShareDialogBuilder(activity);
				if (lt.length() > 0) {
					shareDialogBuilder.setName(lt);
				}
				if (lst.length() > 0) {
					shareDialogBuilder.setCaption(lst);
				}
				if (ld.length() > 0) {
					shareDialogBuilder.setDescription(ld);
				}
				if (lp.length() > 0) {
					shareDialogBuilder.setPicture(lp);
				}
				if (l.length() > 0) {
					shareDialogBuilder.setLink(l);
				}
				if (shareDialogBuilder.canPresent()) {
					com.facebook.widget.FacebookDialog shareDialog = shareDialogBuilder.build();
					if (shareDialog == null) {
						System.out.println("[ERROR] Failed to create `Facebook Dialog'.");
						return;
					}
					if (uiHelper == null) {
						System.out.println("[WARNING] Failed to initialize `Facebook UiLifecycleHelper'.");
						shareDialog.present();
						return;
					}
					uiHelper.trackPendingDialogCall(shareDialog.present());
				}
			}
			else {
				android.os.Bundle params = new android.os.Bundle();
				if (lt.length() > 0) {
					params.putString("name", lt);
				}
				if (lst.length() > 0) {
					params.putString("caption", lst);
				}
				if (ld.length() > 0) {
					params.putString("description", ld);
				}
				if (lp.length() > 0) {
					params.putString("picture", lp);
				}
				if (l.length() > 0) {
					params.putString("link", l);
				}
				com.facebook.Session session = com.facebook.Session.getActiveSession();
				if (session == null) {
					session = new com.facebook.Session(activity);
					if (session == null) {
						System.out.println("[ERROR] Failed to initialize `Facebook Session'. Discarding task.");
						return;
					}
				}
				com.facebook.Session.openActiveSession(activity, true, new AndroidFacebookShareDialogSessionStatusCallback()
					.set_listener(listener)
					.set_activity(activity)
					.set_params(params)
				);
			}
		}}}
	}
}
