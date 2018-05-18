#import "ITreeDataSource.h"

@interface ArrayDataSource : NSObject <ITableDataSource>

+ (instancetype)dataSourceFor:(NSArray *)array;

- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)insertObject:(id)object atIndex:(NSUInteger)index;

- (void)updateObject:(id)object atIndex:(NSUInteger)index;

@end
