#pragma once
#include <unistd.h>
#import <JavaScriptCore/JSExport.h>

@protocol BBVJSBridgedGlobal <JSExport>
-( void )log:( NSString* )message;
-( void )msleep:( useconds_t )millisec;
-( NSArray* )shuffle:( NSArray* )base;
@end

@protocol BBVJSBridgedCache <JSExport>
// read-only attribute access
@property(readonly) NSArray* props;

-( id )get:( NSString* )name;
JSExportAs(set,
    -( void )set:( NSString* )name value:( id )val
);
@end

@protocol BBVJSBridgedObject <JSExport>
// read-only attribute access
@property(readonly) NSString* name;
@property(readonly) double position_x;
@property(readonly) double position_y;
@property(readonly) double size_x;
@property(readonly) double size_y;
@property(readonly) double layer;
@property(readonly) double transparency;

// attribute manipulation
-( void )move:( NSDictionary* )args;
-( void )resize:( NSDictionary* )args;
-( void )fade:( NSDictionary* )args;
-( void )concurrent:( NSDictionary* )args;
-( void )layer:( NSDictionary* )args;
-( BOOL )emit:( NSString* )slot;
@end

@protocol BBVJSBridgedObjectVideo <JSExport>
- (NSString* )status;

-( void )start;
-( void )stop;
-( void )pause;
-( void )restart;
@end

@protocol BBVJSBridgedObjectAudio <JSExport>
-( void )start;
-( void )stop;
-( void )pause;
-( void )restart;
@end

@protocol BBVJSBridgedObjectPicture <JSExport>
@end

@protocol BBVJSBridgedObjectScreen <JSExport>
@property(readonly) double screen_id;

-( void )exit_to:( NSString* )path;
-( void )exit_story;
@end

@protocol BBVJSBridgedFuture <JSExport>
@property(readonly) NSString * path;
@property(readonly) NSString * name;

-( BOOL )emit:( NSString* )slot;
@end

@interface BBVJSBridgingHelper : NSObject
+( BOOL )injectProtocol:( NSString* )protocolName intoClass:( Class )cls;
+( BOOL )checkClass:( Class )cls forProtocol:( NSString* )protocolName;
@end

