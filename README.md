java-clones
===========

Procedure:
- run ./bin/process.sim.latest.sh
  Find projects with highest similarity, and check

    ls d/d.p1.p2
    cat d/d.p1.p2/* | sort -u  (1)


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

    for i in $(cat o | grep java ); do echo $i ;echo "======================" ; ./bin/paired.sh $i mp3agic SpoutcraftAPI ; done | less


