#import <UIKit/UIKit.h>
#import <substrate.h>

static BOOL enableTweak = NO;

%hook SBCCBrightnessSectionController

-(void)_sliderDidBeginTracking:(id)var
{
	%orig;
	if(enableTweak)
	{
		NSLog(@"DidBegin!, %@",var);
		UIViewController * parent = MSHookIvar<UIViewController*>(self,"_parentViewController");
		UIView * parentView = [parent view];
		NSLog(@"parentView: %@",parentView);
		UIView * sbcv = [parentView _rootView];
		[UIView beginAnimations:nil context:NULL];
		sbcv.hidden = YES;
		[UIView commitAnimations];
	}
}

-(void)_sliderDidEndTracking:(id)var
{
	%orig;
	if(enableTweak)
	{
		NSLog(@"DidEnd!, %@",var);
		UIViewController * parent = MSHookIvar<UIViewController*>(self,"_parentViewController");
		UIView * parentView = [parent view];
		NSLog(@"parentView: %@",parentView);
		UIView * sbcv = [parentView _rootView];
		[UIView beginAnimations:nil context:NULL];
		sbcv.hidden = NO;
		[UIView commitAnimations];
	}
}

%end

static void loadPrefs() 
{
	NSLog(@"Loading CCLiveBrightness prefs");
    CFPreferencesAppSynchronize(CFSTR("com.joshdoctors.cclivebrightness"));

    enableTweak = !CFPreferencesCopyAppValue(CFSTR("enableTweak"), CFSTR("com.joshdoctors.cclivebrightness")) ? NO : [(id)CFPreferencesCopyAppValue(CFSTR("enableTweak"), CFSTR("com.joshdoctors.cclivebrightness")) boolValue];
    if (enableTweak) {
        NSLog(@"[CCLiveBrightness] We are enabled");
    } else {
        NSLog(@"[CCLiveBrightness] We are NOT enabled");
    }
}

%ctor
{
	NSLog(@"Loading CCLiveBrightness");
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                NULL,
                                (CFNotificationCallback)loadPrefs,
                                CFSTR("com.joshdoctors.cclivebrightness/settingschanged"),
                                NULL,
                                CFNotificationSuspensionBehaviorDeliverImmediately);
	loadPrefs();
}