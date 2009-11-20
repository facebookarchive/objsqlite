// Copyright 2009 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain
// a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations
// under the License.

#import "ObjSqliteTest.h"

#import "ObjSqliteDB.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ObjSqliteDBTest

static NSString* kTestDBPath = @"ObjSqliteDBtest.db";

static const char* kTestCreateDB = "CREATE TABLE test (\
  'id' INTEGER, \
  'value' INTEGER \
);";

static const char* kTestInsertDB = "INSERT INTO test VALUES(1, 1001);";
static const char* kTestSelectDB = "SELECT value FROM test WHERE id = 1;";
static const char* kTestDeleteDB = "DELETE FROM test WHERE id = 1;";

static const char* kTestInsertValueDB = "INSERT INTO test VALUES(?, ?);";
static const char* kTestSelectValueDB = "SELECT value FROM test WHERE id = ?;";

// See: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/905-A-Unit-Test_Result_Macro_Reference/unit-test_results.html#//apple_ref/doc/uid/TP40007959-CH21-SW2
// for unit test macros.


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUp {
  [[NSFileManager defaultManager] removeItemAtPath:kTestDBPath error:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tearDown {
  [[NSFileManager defaultManager] removeItemAtPath:kTestDBPath error:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLoadNewDbNoCreate {
  ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:kTestDBPath];
  STAssertNotNil(db, @"The db failed to initialize.");

  sqlite3* ObjSqliteDB = db.sqliteDB;

  STAssertTrue(nil != ObjSqliteDB, @"The db failed to be created.");
  STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:kTestDBPath], @"The db doesn't exist");

  [db release];
  db = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLoadNewDbWithCreate {
  ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:kTestDBPath];

  // Create the DB.
  db.createSQL = kTestCreateDB;

  sqlite3* ObjSqliteDB = db.sqliteDB;

  STAssertTrue(nil != ObjSqliteDB, @"The db failed to be created.");
  STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:kTestDBPath], @"The db doesn't exist");

  [db release];
  db = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLoadNewDbWithInsertStatement {
  ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:kTestDBPath];
  db.createSQL = kTestCreateDB;

  ObjSqliteStatement* statement;

  statement = [[ObjSqliteStatement alloc] initWithSQL:kTestInsertDB db:db];
  STAssertTrue([statement step], @"Failed statement: %@", db.lastErrorMessage);
  [statement release];
  statement = nil;

  [db release];
  db = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testCloseDbWithInsertStatement {
  ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:kTestDBPath];
  db.createSQL = kTestCreateDB;

  ObjSqliteStatement* statement;

  statement = [[ObjSqliteStatement alloc] initWithSQL:kTestInsertDB db:db];
  STAssertTrue([statement step], @"Failed statement: %@", db.lastErrorMessage);
  [statement release];
  statement = nil;

  [db close];
  [[NSFileManager defaultManager] removeItemAtPath:kTestDBPath error:nil];

  statement = [[ObjSqliteStatement alloc] initWithSQL:kTestInsertDB db:db];
  STAssertTrue([statement step], @"Failed statement: %@", db.lastErrorMessage);
  [statement release];
  statement = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLoadNewDbWithInsertValueStatement {
  ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:kTestDBPath];
  db.createSQL = kTestCreateDB;

  ObjSqliteStatement* statement;

  statement = [[ObjSqliteStatement alloc] initWithSQL:kTestInsertValueDB db:db];
  [statement bindInt:1 toColumn:1];
  [statement bindInt:1001 toColumn:2];
  STAssertTrue([statement step], @"Failed statement: %@", db.lastErrorMessage);
  [statement release];
  statement = nil;

  statement = [[ObjSqliteStatement alloc] initWithSQL:kTestSelectValueDB db:db];
  [statement bindInt:1 toColumn:1];
  STAssertTrue([statement step], @"Failed statement: %@", db.lastErrorMessage);
  STAssertEquals([statement intFromColumn:0], 1001, @"Failed statement: %@", db.lastErrorMessage);
  [statement release];
  statement = nil;

  [db release];
  db = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLoadNewDbWithSelectStatement {
  ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:kTestDBPath];
  db.createSQL = kTestCreateDB;

  ObjSqliteStatement* statement;

  statement = [[ObjSqliteStatement alloc] initWithSQL:kTestInsertDB db:db];
  STAssertTrue([statement step], @"Failed statement: %@", db.lastErrorMessage);
  [statement release];
  statement = nil;

  statement = [[ObjSqliteStatement alloc] initWithSQL:kTestSelectDB db:db];
  STAssertTrue([statement step], @"Failed statement: %@", db.lastErrorMessage);
  STAssertEquals([statement intFromColumn:0], 1001, @"Failed statement: %@", db.lastErrorMessage);
  [statement release];
  statement = nil;

  [db release];
  db = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testLoadNewDbWithDeleteStatement {
  ObjSqliteDB* db = [[ObjSqliteDB alloc] initWithPath:kTestDBPath];
  db.createSQL = kTestCreateDB;

  ObjSqliteStatement* statement;

  statement = [[ObjSqliteStatement alloc] initWithSQL:kTestInsertDB db:db];
  STAssertTrue([statement step], @"Failed statement: %@", db.lastErrorMessage);
  [statement release];
  statement = nil;

  statement = [[ObjSqliteStatement alloc] initWithSQL:kTestDeleteDB db:db];
  STAssertTrue([statement step], @"Failed statement: %@", db.lastErrorMessage);
  [statement release];
  statement = nil;

  [db release];
  db = nil;
}



@end
