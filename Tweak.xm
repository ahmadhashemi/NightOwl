
%hook T1AppDelegate

- (void)configureColorPalette {

NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
formatter.dateFormat = @"H";
NSString *hourString = [formatter stringFromDate:[[NSDate alloc] init]];
NSInteger hour = [hourString integerValue];

if (hour > 20 || hour < 6) {
	[[NSUserDefaults standardUserDefaults] setObject:@"dark" forKey:@"TFNTwitterColorSettings.colorPaletteName"];
} else {
	[[NSUserDefaults standardUserDefaults] setObject:@"standard" forKey:@"TFNTwitterColorSettings.colorPaletteName"];
}

%orig;

// 
// id sharedSettings = [%c(TFNTwitterColorSettings) performSelector:@selector(sharedSettings)];
// NSArray *available = [sharedSettings performSelector:@selector(availableColorPalettes)];
// id current = [sharedSettings performSelector:@selector(currentColorPalette)];
	// 
	// current = available[1];
	// 
	// [sharedSettings performSelector:@selector(applyCurrentColorPalette)];
	
}

%end