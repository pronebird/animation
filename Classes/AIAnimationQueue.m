//
//  AIAnimationQueue.m
//  Animation
//
//  Created by Avi Itskovich on 10-08-07.
//  Copyright 2010 Avi Itskovich. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "AIAnimationQueue.h"

@implementation AIAnimationQueue

+ (instancetype)sharedInstance {
	static id _instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		_instance = [[AIAnimationQueue alloc] init];
	});
	
	return _instance;
}

- (id)init {
	if (self = [super init]) {
		queue = [[NSMutableArray alloc] init];
	}
	return self;
}

#pragma mark -
#pragma mark Selector Animations

- (void)addAnimation:(SEL)selector target:(id)target {
	[self addAnimation:selector target:target parameters:nil];
}

- (void)addAnimation:(SEL)selector target:(id)target parameters:(NSArray *)parameters {
	[self addSelector:selector target:target parameters:parameters animation:YES];
}

- (void)addComputation:(SEL)selector target:(id)target {
	[self addComputation:selector target:target parameters:nil];
}

- (void)addComputation:(SEL)selector target:(id)target parameters:(NSArray *)parameters {
	[self addSelector:selector target:target parameters:parameters animation:NO];
}

- (void)addSelector:(SEL)selector target:(id)target parameters:(NSArray *)parameters animation:(BOOL)animation {
	AISelectorQueueObject *aObject = [AISelectorQueueObject alloc];
	
	if (animation) 
		aObject = [aObject initWithAnimation:selector target:target arguments:parameters];
	else
		aObject = [aObject initWithComputation:selector target:target arguments:parameters];
	
	aObject.delegate = self;
	[queue addObject:aObject];
	if (!animating) {
		[self next];
	}
	
}


#pragma mark -
#pragma mark Block Animations

- (void)addAnimation:(void (^)(void))animation {
	[self addBlock:animation animation:YES];
}

- (void)addComputation:(void (^)(void))computation {
	[self addBlock:computation animation:NO];
}

- (void)addBlock:(void (^)(void))block animation:(BOOL)animation {
	AIBlockQueueObject *aObject = [AIBlockQueueObject alloc];
	
	if (animation) aObject = [aObject initWithAnimation:block];
	else aObject = [aObject initWithComputation:block];
	
	aObject.delegate = self;
	[queue addObject:aObject];
	if (!animating) {
		[self next];
	}
}

#pragma mark -
#pragma mark Queue Management

- (void)clear {
    [queue removeAllObjects];
}

- (void)removeObjectsOfType:(Class)classType {
    for (int i = 0; i < [queue count]; i++) {
        id queueObject = [queue objectAtIndex:i];
        if ([queueObject isKindOfClass:classType]) {
            [queue removeObjectAtIndex:i];
            i--;
        }
    }
}

- (NSUInteger)count {
    return [queue count];
}

- (void)next {
	if ([queue count] > 0) {
		AIQueueObject *animation = [queue objectAtIndex:0];
		
		// Set boolean and remove before playing because animations where nothing happens
		// occur instantaneously causing an infinited loop if these are set after play
		// is called
		animating = TRUE;
		[queue removeObjectAtIndex:0];
		
		[animation play];
		return;
	}
	animating = FALSE;
}


@end
