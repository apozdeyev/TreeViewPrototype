#import <CoreData/NSFetchedResultsController.h>

@protocol ITableDataSource;


typedef NS_ENUM(NSUInteger, TreeViewDataSourceChangeType) {
	TreeViewDataSourceChangeInsert = NSFetchedResultsChangeInsert,
	TreeViewDataSourceChangeDelete = NSFetchedResultsChangeDelete,
	TreeViewDataSourceChangeMove = NSFetchedResultsChangeMove,
	TreeViewDataSourceChangeUpdate = NSFetchedResultsChangeUpdate
};


@protocol ITreeViewDataSourceDelegate <NSObject>

@optional
- (void)dataSource:(id<ITableDataSource>)dataSource didChangeObject:(id)anObject atIndex:(NSUInteger)index forChangeType:(TreeViewDataSourceChangeType)type newIndex:(NSUInteger)newIndex;

@optional
- (void)dataSourceWillChangeContent:(id<ITableDataSource>)dataSource;

@optional
- (void)dataSourceDidChangeContent:(id<ITableDataSource>)dataSource;


@end

@protocol ITableDataSource <NSObject>

- (BOOL)performFetch:(NSError **)error;

- (id)objectAtIndex:(NSUInteger)index;

// Can return NSNotFound.
-(NSUInteger)indexForObject:(id)object;

@property(nonatomic, weak) id<ITreeViewDataSourceDelegate> dataChangingDelegate;

@property (nonatomic, readonly) NSUInteger numberOfObjects;

@end


@protocol ITreeDataSource <NSObject>

@required
- (id<ITableDataSource>)dataSourceForItemsPath:(NSArray *)item;

@end

