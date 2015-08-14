#import "NSData+digest.h"
#include <CommonCrypto/CommonDigest.h>

@implementation NSData(Digest)

+( NSString* )sha1FromBytes:( const void* )bytes length:( NSUInteger )length;
{
	return [[NSData dataWithBytes:bytes length:length] sha1];
}

+( NSString* )sha1FromContentsOfFile:( NSString* )path
{
	return [[NSData dataWithContentsOfFile:path] sha1];
}

+( NSString* )sha256FromBytes:( const void* )bytes length:( NSUInteger )length;
{
	return [[NSData dataWithBytes:bytes length:length] sha256];
}

+( NSString* )sha256FromContentsOfFile:( NSString* )path
{
	return [[NSData dataWithContentsOfFile:path] sha256];
}

+( NSString* )md5FromBytes:( const void* )bytes length:( NSUInteger )length;
{
	return [[NSData dataWithBytes:bytes length:length] md5];
}

+( NSString* )md5FromContentsOfFile:( NSString* )path
{
	return [[NSData dataWithContentsOfFile:path] md5];
}

-( NSString* )sha1
{
	if( self.length < 1 )
	{
		return @"";
	}

	unsigned char hashBytes[CC_SHA1_DIGEST_LENGTH];

	memset( &hashBytes, 0, sizeof( hashBytes ) );

	if( CC_SHA1( self.bytes, self.length, hashBytes ) == NULL )
	{
		return @"";
	}

	NSMutableString *result = [[NSMutableString alloc] init];
	NSUInteger i = 0;

	for( i = 0; i < CC_SHA1_DIGEST_LENGTH; ++i )
	{
		[result appendFormat:@"%02.2x", hashBytes[i]];
	}
	return result;
}


-( NSString* )sha256
{
	if( self.length < 1 )
	{
		return @"";
	}

	unsigned char hashBytes[CC_SHA256_DIGEST_LENGTH];

	memset( &hashBytes, 0, sizeof( hashBytes ) );

	if( CC_SHA256( self.bytes, self.length, hashBytes ) == NULL )
	{
		return @"";
	}

	NSMutableString *result = [[NSMutableString alloc] init];
	NSUInteger i = 0;

	for( i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i )
	{
		[result appendFormat:@"%02.2x", hashBytes[i]];
	}
	return result;
}

-( NSString* )md5
{
	if( self.length < 1 )
	{
		return @"";
	}

	unsigned char hashBytes[CC_MD5_DIGEST_LENGTH];

	memset( &hashBytes, 0, sizeof( hashBytes ) );

	if( CC_MD5( self.bytes, self.length, hashBytes ) == NULL )
	{
		return @"";
	}

	NSMutableString *result = [[NSMutableString alloc] init];
	NSUInteger i = 0;

	for( i = 0; i < CC_MD5_DIGEST_LENGTH; ++i )
	{
		[result appendFormat:@"%02.2x", hashBytes[i]];
	}
	return result;
}

@end

