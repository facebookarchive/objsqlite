ObjSqlite
=========

Objective Sqlite is a lightweight Objective-C wrapper for sqlite. It provides a number of
convenience functions for binding and retrieving data from sqlite results.

Adding ObjSqlite to your project
================================

ObjSqlite is compiled as a static library.  Here is how to add it to your project:

1. Clone the ObjSqlite git repository: `git clone git://github.com/facebook/ObjSqlite.git`.  Make
   sure you store the repository in a permanent place because Xcode will need to reference the
   files every time you compile your project.

2. Locate the "ObjSqlite.xcodeproj" file under "ObjSqlite/src".  Drag ObjSqlite.xcodeproj and drop
   it onto the root of your Xcode project's "Groups and Files"  sidebar.  A dialog will appear --
   make sure "Copy items" is unchecked and "Reference Type" is "Relative to Project" before
   clicking "Add".

3. Now you need to link the ObjSqlite static library to your project.  Click the
   "ObjSqlite.xcodeproj" item that has just been added to the sidebar.  Under the "Details" table,
   you will see a single item: libObjSqlite.a.  Check the checkbox on the far right of
   libObjSqlite.a.

4. Now you need to add ObjSqlite as a dependency of your project, so Xcode compiles it whenever
   you compile your project.  Expand the "Targets" section of the sidebar and double-click your
   application's target.  Under the "General" tab you will see a "Direct Dependencies" section. 
   Click the "+" button, select "ObjSqlite", and click "Add Target".

5. Now you need to add the sqlite lib to your project.  Under the same tab where you added
   ObjSqlite as a dependency you will see a "Linked Libraries" section. Click the "+" button,
   select "libsqlite3.0.dylib", and click "Add Target".

6. Finally, we need to tell your project where to find the ObjSqlite headers.  Open your
   "Project Settings" and go to the "Build" tab. Look for "Header Search Paths" and double-click
   it.  Add the relative path from your project's directory to the "ObjSqlite/src" directory.

7. You're ready to go.  Just #import <ObjSqlite/ObjSqliteDB.h> anywhere you want to use ObjSqlite
   classes in your project.

Testing ObjSqlite
=================

The ObjSqlite includes a unit testing target to ensure that nothing breaks if the code is played
with. To run the unit tests, simply set your build target to ObjSqliteTest and build the project.
The simple act of building the project will run the unit tests. If there are any errors, they
will appear in the same way that build errors do.

