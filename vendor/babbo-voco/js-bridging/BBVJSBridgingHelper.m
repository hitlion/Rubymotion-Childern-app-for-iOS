#import "BBVJSBridgingHelper.h"
#import <objc/runtime.h>

@implementation BBVJSBridgingHelper
+( BOOL )injectProtocol:( NSString* )protocolName intoClass:( Class )cls
{
  /* ignore the following lines, Clang won't actually generate the protocols
   * unless it sees them used *somewhere*..
   */
  (void)@protocol(BBVJSBridgedObject);
  (void)@protocol(BBVJSBridgedObjectVideo);
  (void)@protocol(BBVJSBridgedObjectAudio);
  (void)@protocol(BBVJSBridgedObjectPicture);
  (void)@protocol(BBVJSBridgedObjectScreen);

  Protocol *p = objc_getProtocol( [protocolName cStringUsingEncoding:NSUTF8StringEncoding] );
  if( p != NULL )
  {
    if( class_conformsToProtocol( cls, p ) == NO )
    {
      // inject only once
      class_addProtocol( cls, p );
    }
    return YES;
  }
  NSLog( @"I screwed up.. couldn't find a protocol named '%@'", protocolName );
  return NO;
}

+( BOOL )checkClass:( Class )cls forProtocol:( NSString* )protocolName
{
  Protocol *p = objc_getProtocol( [protocolName cStringUsingEncoding:NSUTF8StringEncoding] );
  if( p != NULL )
  {
    return class_conformsToProtocol( cls, p );
  }
  return NO;
}

// instance methods exported to each JSContext
-( void )log:( NSString* )message
{
  NSLog( @"[BBVJSBridged.log]: %@", message );
}

-( void )msleep:( useconds_t )millisec
{
  [NSThread sleepForTimeInterval:(double)millisec / 1000.0];
}

-( NSArray* )shuffle:( NSArray* )base
{
  NSMutableArray *array = [base mutableCopy];

  for( NSInteger count = base.count; count >= 0; --count )
  {
    NSUInteger index = arc4random() % ( array.count - 1 );
    id object = [array objectAtIndex:index];

    [array removeObjectAtIndex:index];
    index = arc4random() % ( array.count - 1);
    [array insertObject:object atIndex:index];
  }
  return array;
}
@end

