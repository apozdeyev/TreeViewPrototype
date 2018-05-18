#import "ArrayDataSource.h"

@interface ArrayDataSource()

@property () NSMutableArray *array;

@end


@implementation ArrayDataSource


@synthesize dataChangingDelegate;


#pragma mark Initialization


+ (instancetype)dataSourceFor:(NSArray *)array {
	return [[self alloc] initFor:array];
}


- (id)initFor:(NSArray *)array {
	self = [super init];
	if (self) {
		self.array = [array mutableCopy];
	}
	return self;
}


#pragma mark Public Methods


- (void)removeObjectAtIndex:(NSUInteger)index {
	if (index >= self.array.count) {
//		AssertWithReporting(NO, @"Invalid index to remove: %@, size: %@", @(index), @(self.array.count));
		return;
	}

	[self notifyDataSourceWillChangeContent];

	id object = [self.array objectAtIndex:index];
	[self.array removeObjectAtIndex:index];
	[self notifyObject:object changed:TreeViewDataSourceChangeDelete atIndex:index];

	[self notifyDataSourceDidChangeContent];
}


- (void)insertObject:(id)object atIndex:(NSUInteger)index {
	if (index > self.array.count) {
//		AssertWithReporting(NO, @"Invalid index to insert: %@, size: %@", @(index), @(self.array.count));
		return;
	}

	[self notifyDataSourceWillChangeContent];

	[self.array insertObject:object atIndex:index];
	[self notifyObject:object changed:TreeViewDataSourceChangeInsert atIndex:index];

	[self notifyDataSourceDidChangeContent];
}


- (void)updateObject:(id)object atIndex:(NSUInteger)index {
	if (index >= self.array.count) {
//		AssertWithReporting(NO, @"Invalid index to update: %@, size: %@", @(index), @(self.array.count));
		return;
	}

	[self notifyDataSourceWillChangeContent];

	self.array[index] = object;
	[self notifyObject:object changed:TreeViewDataSourceChangeUpdate atIndex:index];

	[self notifyDataSourceDidChangeContent];
}


- (BOOL)performFetch:(NSError **)error {
	return YES;
}


- (id)objectAtIndex:(NSUInteger)index {
	id objectAtIndex = [self.array objectAtIndex:index];
	return objectAtIndex;
}


- (NSUInteger)indexForObject:(id)object {
	NSUInteger indexForObject = [self.array indexOfObject:object];
	return indexForObject;
}


- (NSUInteger)numberOfObjects {
	NSUInteger numberOfObjects = self.array.count;
	return numberOfObjects;
}


#pragma mark Private Methods


- (void)notifyDataSourceWillChangeContent {
	if (self.dataChangingDelegate != nil && [self.dataChangingDelegate respondsToSelector:@selector(dataSourceWillChangeContent:)]) {
		[self.dataChangingDelegate dataSourceWillChangeContent:self];
	}
}


- (void)notifyDataSourceDidChangeContent {
	if (self.dataChangingDelegate != nil && [self.dataChangingDelegate respondsToSelector:@selector(dataSourceDidChangeContent:)]) {
		[self.dataChangingDelegate dataSourceDidChangeContent:self];
	}
}


- (void)notifyObject:(id)object changed:(TreeViewDataSourceChangeType)type atIndex:(NSUInteger)index {
	if (self.dataChangingDelegate != nil && [self.dataChangingDelegate respondsToSelector:@selector(dataSource:didChangeObject:atIndex:forChangeType:newIndex:)]) {
		[self.dataChangingDelegate dataSource:self didChangeObject:object atIndex:index forChangeType:type newIndex:0];
	}
}


@end
