/* Preferences Controller
 * Copyright (C) 2020 Tomasz Poliszuk
 *
 * Preferences Controller is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * Preferences Controller is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Preferences Controller. If not, see <https://www.gnu.org/licenses/>.
 */


#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

NSString *domainString = @"com.tomaszpoliszuk.preferencescontroller";

NSMutableDictionary *tweakSettings;

static BOOL enableTweak;

static BOOL icons;

static BOOL separators;

static BOOL rounded;

static BOOL fullWidthCells;

static int largeTitle;

void SettingsChanged() {
	NSUserDefaults *tweakSettings = [[NSUserDefaults alloc] initWithSuiteName:domainString];

	enableTweak = [([tweakSettings objectForKey:@"enableTweak"] ?: @(YES)) boolValue];

	icons = [([tweakSettings objectForKey:@"icons"] ?: @(YES)) boolValue];
	separators = [([tweakSettings objectForKey:@"separators"] ?: @(YES)) boolValue];
	rounded = [([tweakSettings objectForKey:@"rounded"] ?: @(YES)) boolValue];
	fullWidthCells = [([tweakSettings objectForKey:@"fullWidthCells"] ?: @(YES)) boolValue];
	largeTitle = [([tweakSettings objectForKey:@"largeTitle"] ?: @(999)) integerValue];
}

//	%hook PSCapabilityManager
//	- (bool)capabilityBoolAnswer:(id)arg1 {
//		return YES;
//	}
//	- (bool)hasCapabilities:(id)arg1 {
//		return YES;
//	}
//	%end

//	%hook UIDevice
//	-(bool)sf_isChinaRegionCellularDevice {
//		bool origValue = %orig;
//		if ( enableTweak ) {
//			return enableAbilityToBlockWiFiAccess;
//		} else {
//			return origValue;
//		}
//	}
//	%end

%hook UINavigationBar
- (bool)prefersLargeTitles {
	bool origValue = %orig;
	if ( enableTweak && largeTitle != 999 ) {
		return largeTitle;
	}
	return origValue;
}
%end

%hook UITableView
- (UIEdgeInsets)_sectionContentInset {
	UIEdgeInsets origValue = %orig;
	if ( enableTweak ) {
		if ( !fullWidthCells ) {
			origValue.left = 20;
			origValue.right = 20;
		} else {
			origValue.left = 0;
			origValue.right = 0;
		}
	}
	return origValue;
}
- (double)_sectionCornerRadius {
	double origValue = %orig;
	if ( enableTweak && !rounded ) {
		return 10;
	}
	return origValue;
}
%end

%hook UITableViewCell
- (bool)_usesrounded {
	bool origValue = %orig;
	if ( enableTweak && !fullWidthCells ) {
		return rounded;
	}
	return origValue;
}
- (double)_roundedGroupCornerRadius {
	double origValue = %orig;
	if ( enableTweak && !rounded ) {
		return 10;
	}
	return origValue;
}
- (double)_separatorHeight {
	double origValue = %orig;
	if ( enableTweak && !separators ) {
		return 0;
	}
	return origValue;
}
%end

%ctor {
	SettingsChanged();
	CFNotificationCenterAddObserver( CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)SettingsChanged, CFSTR("com.tomaszpoliszuk.preferencescontroller.settingschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately );
	%init;
}
