#pragma once

@interface NSData(Digest)
/* Return the SHA1 digest of `length` bytes pulled from `bytes` */
+( NSString* )sha1FromBytes:( const void* )bytes length:( NSUInteger )length;
/* Return the SHA1 digest calculated from the contents of `path` */
+( NSString* )sha1FromContentsOfFile:( NSString* )path;

/* Return the SHA256 digest of `length` bytes pulled from `bytes` */
+( NSString* )sha256FromBytes:( const void* )bytes length:( NSUInteger )length;
/* Return the SHA256 digest calculated from the contents of `path` */
+( NSString* )sha256FromContentsOfFile:( NSString* )path;

/* Return the MD5 digest of `length` bytes pulled from `bytes` */
+( NSString* )md5FromBytes:( const void* )bytes length:( NSUInteger )length;
/* Return the MD5 digest calculated from the contents of `path` */
+( NSString* )md5FromContentsOfFile:( NSString* )path;

/* Return the SHA1 digest based on the contents of this NSData */
-( NSString* )sha1;

/* Return the SHA256 digest based on the contents of this NSData */
-( NSString* )sha256;

/* Return the MD5 digest based on the contents of this NSData */
-( NSString* )md5;
@end

