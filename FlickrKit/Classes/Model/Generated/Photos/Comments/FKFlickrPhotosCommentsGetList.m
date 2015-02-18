//
//  FKFlickrPhotosCommentsGetList.m
//  FlickrKit
//
//  Generated by FKAPIBuilder on 19 Sep, 2014 at 10:49.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrPhotosCommentsGetList.h" 

@implementation FKFlickrPhotosCommentsGetList



- (BOOL) needsLogin {
    return NO;
}

- (BOOL) needsSigning {
    return NO;
}

- (FKPermission) requiredPerms {
    return -1;
}

- (NSString *) name {
    return @"flickr.photos.comments.getList";
}

- (BOOL) isValid:(NSError **)error {
    BOOL valid = YES;
	NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"You are missing required params: "];
	if(!self.photo_id) {
		valid = NO;
		[errorDescription appendString:@"'photo_id', "];
	}

	if(error != NULL) {
		if(!valid) {	
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errorDescription};
			*error = [NSError errorWithDomain:FKFlickrKitErrorDomain code:FKErrorInvalidArgs userInfo:userInfo];
		}
	}
    return valid;
}

- (NSDictionary *) args {
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
	if(self.photo_id) {
		[args setValue:self.photo_id forKey:@"photo_id"];
	}
	if(self.min_comment_date) {
		[args setValue:self.min_comment_date forKey:@"min_comment_date"];
	}
	if(self.max_comment_date) {
		[args setValue:self.max_comment_date forKey:@"max_comment_date"];
	}

    return [args copy];
}

- (NSString *) descriptionForError:(NSInteger)error {
    switch(error) {
		case FKFlickrPhotosCommentsGetListError_PhotoNotFound:
			return @"Photo not found";
		case FKFlickrPhotosCommentsGetListError_InvalidAPIKey:
			return @"Invalid API Key";
		case FKFlickrPhotosCommentsGetListError_ServiceCurrentlyUnavailable:
			return @"Service currently unavailable";
		case FKFlickrPhotosCommentsGetListError_WriteOperationFailed:
			return @"Write operation failed";
		case FKFlickrPhotosCommentsGetListError_FormatXXXNotFound:
			return @"Format \"xxx\" not found";
		case FKFlickrPhotosCommentsGetListError_MethodXXXNotFound:
			return @"Method \"xxx\" not found";
		case FKFlickrPhotosCommentsGetListError_InvalidSOAPEnvelope:
			return @"Invalid SOAP envelope";
		case FKFlickrPhotosCommentsGetListError_InvalidXMLRPCMethodCall:
			return @"Invalid XML-RPC Method Call";
		case FKFlickrPhotosCommentsGetListError_BadURLFound:
			return @"Bad URL found";
  
		default:
			return @"Unknown error code";
    }
}

@end
