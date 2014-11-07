//
//  AppConstants.h
//  Wimoto
//
//  Created by Mobitexoft on 30.08.13.
//
//


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define NOTIFICATION_ACTION_DISMISS_ID              @"dismiss"
#define NOTIFICATION_ACTION_ALARM_OFF_ID            @"alarmOff"
#define NOTIFICATION_ALARM_CATEGORY_ID              @"sensor"