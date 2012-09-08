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

  bin/is_dup_file_covered.sh mp3agic SpoutcraftAPI | tee o

  If so, find the paired files in p2
  ./bin/pair.sh Mp3Retag.java p1 p2

  and see if any of the paird file has methods that can be transfered.

   for i in $(cat o | grep java );
   do echo $i ;echo "======================" ;
      ./bin/paired.sh $i mp3agic SpoutcraftAPI ;
   done | less
