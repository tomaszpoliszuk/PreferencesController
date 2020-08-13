#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

NSString *domainString = @"com.tomaszpoliszuk.preferencescontroller";

NSMutableDictionary *tweakSettings;

static BOOL enableTweak;

static BOOL enableAbilityToBlockWiFiAccess;

static BOOL showIcons;

static BOOL showSeparators;

static BOOL roundedGroups;

UILongPressGestureRecognizer *longPressGestureRecognizer;

void SettingsChanged() {
	NSUserDefaults *tweakSettings = [[NSUserDefaults alloc] initWithSuiteName:domainString];

	enableTweak = [([tweakSettings objectForKey:@"enableTweak"] ?: @(YES)) boolValue];

	enableAbilityToBlockWiFiAccess = [([tweakSettings objectForKey:@"enableAbilityToBlockWiFiAccess"] ?: @(YES)) boolValue];

	showIcons = [([tweakSettings objectForKey:@"showIcons"] ?: @(YES)) boolValue];

	showSeparators = [([tweakSettings objectForKey:@"showSeparators"] ?: @(YES)) boolValue];

	roundedGroups = [([tweakSettings objectForKey:@"roundedGroups"] ?: @(YES)) boolValue];
}

%hook UIDevice
-(bool)sf_isChinaRegionCellularDevice {
	bool origValue = %orig;
	if ( enableTweak ) {
		return enableAbilityToBlockWiFiAccess;
	} else {
		return origValue;
	}
}
%end

%hook PSListController
- (bool)edgeToEdgeCells {
	bool origValue = %orig;
	if ( enableTweak ) {
		return !roundedGroups;
	} else {
		return origValue;
	}
}
- (bool)_isRegularWidth {
	bool origValue = %orig;
	if ( enableTweak ) {
		return roundedGroups;
	} else {
		return origValue;
	}
}
%end

@interface PSUIPrefsListController : PSListController
@end
%hook PSUIPrefsListController
- (bool)_cellularDataSetting {
	bool origValue = %orig;
	if ( enableTweak && enableAbilityToBlockWiFiAccess ) {
		return enableAbilityToBlockWiFiAccess;
	} else {
		return origValue;
	}
}
- (bool)isCellularDataEnabled {
	bool origValue = %orig;
	if ( enableTweak && enableAbilityToBlockWiFiAccess ) {
		return enableAbilityToBlockWiFiAccess;
	} else {
		return origValue;
	}
}
- (bool)_cellularDataSettingInitialized {
	bool origValue = %orig;
	if ( enableTweak && enableAbilityToBlockWiFiAccess ) {
		return enableAbilityToBlockWiFiAccess;
	} else {
		return origValue;
	}
}
- (void)set_cellularDataSetting:(bool)arg1 {
	if ( enableTweak && enableAbilityToBlockWiFiAccess ) {
		%orig(enableAbilityToBlockWiFiAccess);
	} else {
		%orig;
	}
}
- (void)set_cellularDataSettingInitialized:(bool)arg1 {
	if ( enableTweak && enableAbilityToBlockWiFiAccess ) {
		%orig(enableAbilityToBlockWiFiAccess);
	} else {
		%orig;
	}
}

- (bool)skipSelectingDefaultCategoryOnLaunch {
	bool origValue = %orig;
	if ( enableTweak ) {
		return YES;
	} else {
		return origValue;
	}
}
%end

%hook PSTableCell
- (void)setIcon:(id)arg1 {
	if ( enableTweak && !showIcons ) {
		%orig(nil);
	} else {
		%orig;
	}
}
- (double)_separatorHeight {
	double origValue = %orig;
	if ( enableTweak && !showSeparators ) {
		return 0;
	} else {
		return origValue;
	}
}
- (long long)separatorStyle {
	long long origValue = %orig;
	if ( enableTweak && !showSeparators ) {
		return 0;
	} else {
		return origValue;
	}
}
- (bool)_usesRoundedGroups {
	bool origValue = %orig;
	if ( enableTweak ) {
		return roundedGroups;
	} else {
		return origValue;
	}
}
%end

%ctor {
	SettingsChanged();
	CFNotificationCenterAddObserver( CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)SettingsChanged, CFSTR("com.tomaszpoliszuk.preferencescontroller.settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately );
	%init;
}
