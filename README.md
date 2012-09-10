We have run the testsuites of all our src/. components, and have collected
their coverage data under cov.all/. and analyzed % coverate is in .Rdata.
But these are full suite tests. To colllect the coverage per test suite so
that we know which files were covered by which test suite, we are trying
to run the test suite test class by test class.


Procedure:

update the coverage list

    r| write.table(file='cov.lst', subset(cov, select=c('percentage')) , quote=F, col.names=F)

run R -q and choose a project

    r| cov[sample(nrow(cov),1),]
    = myproj


- run finddup.rb <from> <to> to populate dups/

    for i in $(cat best_cov.100); do echo $i; ./bin/finddup.rb -all src/$i src/$myproj; done

- ls dups/d.p1.p2

    cat dups/d.p1.p2/* | sort -u  (1)


- Then for each file pair found, run

    bin/findsim.sh -l file1 file2

- Then, if that is promicing, check cov.all/p1
  else run
  ./bin/testrun.sh p1
  check which test case covers the duplicated portion in cov.all/p1/

  Check if any of the files in (1) are present in coverage.

  bin/is\_dup\_file\_covered.sh mp3agic SpoutcraftAPI | tee o

  If so, find the paired files in p2
  ./bin/pair.sh Mp3Retag.java p1 p2

  and see if any of the paird file has methods that can be transfered.

   for i in $(cat o | grep java );
   do echo $i ;echo "======================" ;
      ./bin/paired.sh $i mp3agic SpoutcraftAPI ;
   done | less



New Procedure
=====================

Run the command

    ./bin/fortemplate.sh > raw_dups

And eliminate each unwanted dup like equals, set/get etc. Now, for each
remaining.

Inspect the percentage of coverage for the project
in question

    grep myrpoject coverage/cov.lst

run this to see if there are any tests covered

    bin/show\_covered\_classes.sh src/myproject

===========================
if not, run

    ./bin/gentestsrun.rb -chunk src/myproject

You may at some point also want to run

    ./bin/gentestsrun.rb -each src/myproject

(even though we have coverage for the project, we dont have it per test case
until this is run.)

Now run this and clollect covered class

    ./bin/show\_covered\_classes.sh src/myrpoject > covered.classes

Now open probable\_dups and go gF on the file x.i.x we want to inspect, and in
the x.i.x file, note the class name, and see if it is in covered.classes
if it is, then we know it was covered.

now run

    ./lib/findtests.rb -l src/myproj > mytests

to get the test cases the project has. Does any of the test cases seem to be
close to the class in question?

if you know the test

    ./bin/gentestsrun.rb -one src/myproject my.test.Case

    grep -l SimpleNode.java  coverage/update/MarkdownPapers/**/coverage.xml

    ./bin/coverage.xml.rb $i

Or

    find ./src/myproj -name \*.java | grep test | xargs grep -c MyClass | grep -v ':0$'
