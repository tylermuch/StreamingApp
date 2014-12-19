//
//  debug.h
//  StreamingApp
//
//  Created by Tyler  Much on 12/17/14.
//  Copyright (c) 2014 Tyler Much. All rights reserved.
//

#ifndef StreamingApp_debug_h
#define StreamingApp_debug_h


#ifdef ENABLE_SPOTIFY_TRACE
#define SPOTIFY_TRACE(fmt, ...) NSLog((@"SPOTIFY: %s[Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define SPOTIFY_TRACE(...)
#endif


#ifdef ENABLE_SERVER_TRACE
#define SERVER_TRACE(fmt, ...) NSLog((@"SERVER: %s[Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define SERVER_TRACE(...)
#endif


#ifdef ENABLE_PLAYBACK_TRACE
#define PLAYBACK_TRACE(fmt, ...) NSLog((@"PLAYBACK: %s[Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define PLAYBACK_TRACE(...)
#endif


#ifdef ENABLE_UI_TRACE
#define UI_TRACE(fmt, ...) NSLog((@"UI: %s[Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define UI_TRACE(...)
#endif

#endif


// NSLog(format, ## __VA_ARGS__); \
