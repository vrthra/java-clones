--title Test Recommendation
--author Rahul Gopinath <gopinath@eecs.oregonstate.edu>
--footer Repository: https://github.com/vrthra/java-clones/

--newpage Easy
--heading Easy
--horline

* Write the snippet
--##---
* Check for similar snippets in the repository
--##---
* Steal its test case
--##---
* Checkin

--##--huge PARTY !!!

--newpage Find Similarities
--heading Find Similarities
--horline

* Program Comprehension
* Clone Detection

--newpage Program Comprehension
--heading Program Comprehension
--horline

* Linguistics
* Rule Based
* Cliches (Snippets) + Advice
* Similar Execution Trace
* Vector based Decision tree classifier (ICPC 2010)

--horline
---
--boldon
--color red
Problems
--boldoff
--color white
- Mostly from 1990
--##---
- Very difficult to get implementations
--##---
- Analysis - if any - done on trivial projects (<1kloc)
--##---

--newpage Clone Detection
--heading Clone Detection
--horline

* Metrics based (Halstead Metrics)
* Text Based
  * Tokens
  * Lines
* Graph Based
  * AST
  * PDG
* Linguistics
  * Comments and Names

--newpage Clone Detection Tools
--heading Clone Detection Tools
--horline

--color blue
* Simian
--color white
* CPD
* Clone Digger
* Checkstyle
* ConQAT
* CloneDr
* Duplo
* ...

--horline

The industry standard is Simian, and of the tools I tried to use, it is the fastest.

--newpage Strategy
--heading Strategy
--horline

--beginoutput
Run Simian for each pair of projects we have, Look at each instance of duplication reported by it; Run coverage analysis to get the test covering the duplicate snippets. If duplication on one side is missing, then copy the test case covering it to the other project.
--endoutput

- Mean 31.52% (Median 20.61%)

- However it included a large number of projects with no tests at all.
  (Dr. Groce suggests that it is better to not consider these for comparison)

- So we cleaned up projects that were less than 1000 loc, and had test coverage near zero.

--newpage Only those who made an effort to test
--heading Only those who made an effort to test
--horline


--boldon
Densitiy plot of coverage%
--boldoff


r| txtdensity(cov[cov$coverage_percentage > 0,]$coverage_percentage,width=80)
      +--+------------+------------+------------+-------------+------------+---+
0.012 +                                              *********                 +
      |                                           ****       **                |
      |                                        ****           **               |
      |              **                     ***                 *              |
 0.01 +          ***** ****               ***                    *             +
      |        ***        ***           ***                      **            |
      |       **            ***       ***                         **           |
      |      **               *********                            **          |
0.008 +     *                                                       *          +
      |    **                                                        *         |
      |   **                                                         **        |
0.006 +  **                                                           **       +
      |                                                                **      |
      |                                                                 *      |
      |                                                                 **     |
0.004 +                                                                  **    +
      |                                                                   **   |
      +--+------------+------------+------------+-------------+------------+---+
         0           20           40           60            80           100   


  - Mean without 0's = 50.202 (Median 53.434)


--newpage Similarity
--heading Similarity
--horline

* First tried with Javascript
  * Too much pseudo-duplication (too much noice)
* Java was better, analysis of 100 best coverage X 130 randomly selected
  * Found too many getters/setters, array constructors
  * Stricter match criteria discarded a lot of possible cases
- yet
  - 679 getters/setters
  - 186 equals/hashCode matches
  - 2 Copies of files (Base64.java,GraphMLWriter) with tests in one project
  - one shared (readFileAsString) but no tests
- Results too low to be graphed
- Too slow to run on large repositories

--newpage Epiphani
--heading Epiphani
--horline

--color red
--boldon
We are doing it wrong.
--boldoff
--color white

* Clone detection looks for copied code. In particular it tries hard to avoid detecting code that is similar in intent but not cloned.
* We want the opposite.
  * We just want programs that are similar.
    * We can just look at the type signature and names to get those.
  * We dont care about the structure of the program (unlike clone detection) but about intent.
    * We can use invariants to detect that.
    * There are automatic invariant detectors like Daikon that will help us there.

--newpage Similarity Results
--heading Similarity Results
--horline

* Eliminated duplicate projects (file name dups > 50%)
* Eliminated test classes from methods defined by project.

--boldon
Densitiy plot of shared functions%
--boldoff


r| txtdensity(cov$share_percentage_fn ,width=80)
     +--+-------------+------------+------------+------------+-------------+---+
0.04 +              ****                                                       +
     |              *  **                                                      |
     |             *    *                                                      |
     |            **     *                                                     |
0.03 +           **      *                                                     +
     |          **        *                                                    |
     |          *         **                                                   |
     |         **          *                                                   |
0.02 +        **           **                                                  +
     |        *              **                                                |
     |       **               ***                                              |
     |      **                  **                                             |
0.01 +      *                    **                                            +
     |    **                      ***                                          |
     |  ***                         *******                                    |
     |                                    *****                                |
   0 +                                        ******************************   +
     +--+-------------+------------+------------+------------+-------------+---+
        0            20           40           60           80            100   

- Median shared functions: 21.36%, Mean : 23.98%

--horline
--color red
--boldon
Problems
--boldoff
--color white

- Generic naems
  - Methods like toString, main, getName, getId etc have the same signature but that does not mean they are similar. (need to use invariant detection here.)
- Functions are not self contained:
  - Especially for above methods, object state becomes important. It is not clear how to deal with that.

--newpage Both
--heading Both
--horline

- Used the signatures as a guide, and used similarity measures to check the similarity between functions with same signature.
  - Results better than using simian alone, still not a lot (not enough to plot).

--newpage Theoretical Upperbound
--heading Theoretical Upperbound
--horline

Aim: To find an upper bound for increase in coverage.

projectA/addFn (high coverage)
--beginoutput
1aaaaa
2bbbbb
3ccccc
4ddddd
5eeeee
--endoutput
- Has 20% coverage from testAddFn (say 12)
- Contributes 5% of the projectA:loc

projectB/addFn (low coverage)
--beginoutput
0zzzzz
1aaaaa
2bbbbb
3ccccc
4ddddd
--endoutput
- Contributes 10% of the projectB:loc

Then we have 1234 that mathed; Copying testAddFn to projectB would increase the %coverage by two lines
(assuming that it was not covered earlier by other test cases).

So the new coverage of projectB would be

--beginoutput
projectB:originalcov_
  = projectB:orig_coveredloc_ / projectB:totalloc_

projectB:newcov
  = projectB:new_coveredloc / projectB:totalloc_

projectB:new_coveredloc
  = projectB:orig_coveredloc_ + (projectA/testAddFn:contrib_lines - projectB/testAddFn:cov%addFn_)

projectA/testAddFn:contrib_lines
  = projectA/testAddFn%cov A projectB/addFn_

--endoutput

--newpage Current Status
--heading Current Status
--horline

It is hard to obtain coverage per Test case.
- Emma which I was using, does not provide it
- Codecover (FOSS), and Clover (Commercial) are the ones who provide test specific data,
  - unable to get either of them to work well with apache maven.
  - fell back to the simple strategy of iterating through test cases, running them one by one
    and collecting coverage, but it is time intensive, I have just 15 projects out of 532 now.
    (still running the remaining)

- What I have:
  - Test coverage per test case of each method in the projects analyzed
  - Methods that are similar to given method in each of these.



--newpage Recommendations
--heading Recommendations
--horline

- Used a parser to obtain the calls made from each test class.
   - No type information unfortunately, so it is even less reliable
- Yet to go through (manual)

--newpage Near Future
--heading Near Future
--horline

- Incorporting Invariants to ensure that the unit tests are indeed applicable
- Of the recommendations collected, how many can make it to actual unittests?

--newpage Future
--heading Future
--horline

- Both method signatures and Invariants do not preclude recommendations across
  language boundaries (unlike clone detection)
- What can we do about tests that require object states?
  - Can we automatically adapt the test cases?
- Can we understand the program sufficiently enough to identify variants?
  - And track these variants so that the origin is identified?
    - Fingerprinting?
- Is code coverage a good metric? Should we look at which properties are satisfied instead?
  - We get good code coverage if we rely on clone detection
  - good property coverage if we rely on types and invariants.

--##type annotation
