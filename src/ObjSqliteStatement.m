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

#import "ObjSqliteStatement.h"

#import "ObjSqliteDB.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation ObjSqliteStatement

@synthesize sql = _sql;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithSQL:(const char*)sql db:(ObjSqliteDB*)db {
  if (self = [super init]) {
    _db = db;
    _sql = sql;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  @synchronized(_db) {
    if (nil != _statement) {
      sqlite3_finalize(_statement);
      _statement = nil;
    }
  }

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (sqlite3_stmt*)ObjSqliteStatement {
  @synchronized(_db) {
    if (nil == _statement) {
      if (SQLITE_OK != sqlite3_prepare_v2(_db.sqliteDB, _sql, -1, &_statement, NULL)) {
        _statement = nil;
      }
    }
  }

  return _statement;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Binding


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)bindText:(NSString*)value toColumn:(int)column {
  BOOL result;
  @synchronized(_db) {
    result = SQLITE_OK == sqlite3_bind_text(
      [self ObjSqliteStatement],
      column,
      [value UTF8String],
      -1,
      SQLITE_TRANSIENT
    );
  }
  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)bindDouble:(double)value toColumn:(int)column {
  BOOL result;
  @synchronized(_db) {
    result = SQLITE_OK == sqlite3_bind_double([self ObjSqliteStatement], column, value);
  }
  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)bindInt:(int)value toColumn:(int)column {
  BOOL result;
  @synchronized(_db) {
    result = SQLITE_OK == sqlite3_bind_int([self ObjSqliteStatement], column, value);
  }
  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)bindInt64:(long long)value toColumn:(int)column {
  BOOL result;
  @synchronized(_db) {
    result = SQLITE_OK == sqlite3_bind_int64([self ObjSqliteStatement], column, value);
  }
  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)bindNullToColumn:(int)column {
  BOOL result;
  @synchronized(_db) {
    result = SQLITE_OK == sqlite3_bind_null([self ObjSqliteStatement], column);
  }
  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Stepping


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)stepAndHasNextRow {
  BOOL result = YES;

  @synchronized(_db) {
    if (nil == [self ObjSqliteStatement]) {
      result = NO;
    }

    if (result) {
      int code = sqlite3_step([self ObjSqliteStatement]);
      if (code == SQLITE_DONE) {
        result = NO;
      } else if (code == SQLITE_ROW) {
        result = YES;
      } else {
        result = NO;
      }
    }
  }

  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)step {
  BOOL result = YES;

  @synchronized(_db) {
    if (nil == [self ObjSqliteStatement]) {
      return NO;
    }

    if (result) {
      int code = sqlite3_step([self ObjSqliteStatement]);

      result = code == SQLITE_DONE || code == SQLITE_ROW || code == SQLITE_OK;
    }
  }

  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)resetStatement {
  @synchronized(_db) {
    if (nil != _statement) {
      sqlite3_reset(_statement);
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)finalizeStatement {
  @synchronized(_db) {
    if (nil != _statement) {
      sqlite3_finalize(_statement);
      _statement = nil;
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)executeStatement {
  BOOL succeeded;
  @synchronized(_db) {
    succeeded = [self step];
    [self resetStatement];
  }
  return succeeded;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Fetching


///////////////////////////////////////////////////////////////////////////////////////////////////
- (double)doubleFromColumn:(int)column {
  double result;

  @synchronized(_db) {
    result = sqlite3_column_double(_statement, column);
  }

  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (int)intFromColumn:(int)column {
  int result;

  @synchronized(_db) {
    result = sqlite3_column_int(_statement, column);
  }

  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (long long)int64FromColumn:(int)column {
  long long result;

  @synchronized(_db) {
    result = sqlite3_column_int64(_statement, column);
  }

  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)textFromColumn:(int)column {
  NSString* result;

  @synchronized(_db) {
    const char* value = (const char*)sqlite3_column_text(_statement, column);
    result = (value && *value) ? [NSString stringWithUTF8String:value] : nil;
  }

  return result;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate*)dateFromColumn:(int)column {
  NSDate* result;

  @synchronized(_db) {
    int value = sqlite3_column_int(_statement, column);
    result = value ? [NSDate dateWithTimeIntervalSince1970:value] : nil;
  }

  return result;
}


@end
