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

#import <sqlite3.h>

@class ObjSqliteDB;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface ObjSqliteStatement : NSObject {
@private
  ObjSqliteDB*  _db;

  const char*   _sql;
  sqlite3_stmt* _statement;
}


@property (nonatomic, readonly) const char* sql;


///////////////////////////////////////////////////////////////////////////////////////////////////
// db is a weak pointer.
- (id) initWithSQL:(const char*)sql db:(ObjSqliteDB*)db;


// Binding

- (BOOL) bindText:(NSString*)value  toColumn:(int)column;
- (BOOL) bindDouble:(double)value   toColumn:(int)column;
- (BOOL) bindInt:(int)value         toColumn:(int)column;
- (BOOL) bindInt64:(long long)value toColumn:(int)column;
- (BOOL) bindNullToColumn:(int)column;


// Execution

- (BOOL)executeStatement;


// Stepping

// @returns true if the step succeeded.
- (BOOL) step;

// @returns true if a row was loaded into memory. false if there were no rows left to load.
- (BOOL) stepAndHasNextRow;

- (void) resetStatement;

// Step and reset
- (BOOL) stepAndResetStatement;

- (void) finalizeStatement;


// Fetching

-    (double) doubleFromColumn:(int)column;
-       (int) intFromColumn:(int)column;
- (long long) int64FromColumn:(int)column;
- (NSString*) textFromColumn:(int)column;
-   (NSDate*) dateFromColumn:(int)column;


@end
