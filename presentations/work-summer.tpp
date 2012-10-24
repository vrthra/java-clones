--title Test Recommendation
--author Rahul Gopinath <gopinath@eecs.oregonstate.edu>
--##--footer Repository: https://github.com/vrthra/java-clones/
--newpage Why
--heading Why
--horline

* We are lazy
---

* A survey on programmers found that very few actually test code.
* Testing is tedious and boring[1], not worth the time spent.
* Developers want better tools for writing test cases, especially on reused code.
* 75% felt that their test cases were not good enough.
* 48% rarely test their code [1].

---

* Usually copy and paste if we can find similar, but forget the tests
* Reinvent the wheel often times (Not Invented Here), but postpone testing
* We can increase the quality of the code if we can adapt test cases

---

* But even a little testing can increase the quality of code by preventing regression

--horline
  [1]: A Survey on Testing and Reuse / ICS03


--newpage Easy
--heading Easy
--horline

* Write the snippet
---
* Check for similar snippets in the repository
---
* Steal its test case
---

--beginslideleft 
--fgcolor yellow
* Profit!
--fgcolor white
--endslideleft 

--newpage Reuse
--heading Reuse
--horline

* 53% of Survey[1] said they had some elements of reuse.
  * Of these only 34% tested the reused code[1].
* 36% actively search for snippets to reuse[1].
* 46% likes to rewrite code rather than reuse[1]

--newpage Find Similarities
--heading Find Similarities
--horline

* Program Comprehension
* Clone Detection
* Spam Detection

--newpage Program Comprehension
--heading Program Comprehension
--horline

* Linguistics
* Rule Based
* Cliches (Snippets) + Advice
* Similar Execution Trace (Dynamic)
* Vector based Decision tree classifier (*ICPC 2010)

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
--newpage SpamSpam Detection/Text Classification
--heading Spam Detection/Text Classification
--horline

* Not specific to programs
* But has good approaches, e.g fast fingerprinting (related code has similar hashes : high locality)

--newpage Clone Detection
--heading Clone Detection
--horline

* Metrics based
  * Halstead Metrics
* Text Based (Usually with normalization)
  * Lines (with checsum and treating single lines as unit)
  * Tokens
* Graph Based
  * AST Subgraph matching
  * PDG Slices
* Linguistics
  * Comments and Names
* Hybrid

--newpage Clone Detection Tools
--heading Clone Detection Tools
--horline

--color green
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

--newpage Strategy
--heading Strategy
--horline

- Mean 31.52% (Median 20.61%)
- However it included a large number of projects with no tests at all.
- So we cleaned up projects that were less than 1000 loc, and had test coverage near zero.

> txtplot(x[order(x$coverage_percentage),]$coverage_percentage, width=80)
    +--+----------+----------+----------+----------+----------+----------+-----+
100 +                                                                    **    +
    |                                                                 ****     |
    |                                                              ****        |
 80 +                                                        *******           +
    |                                                   ******                 |
    |                                              *****                       |
 60 +                                         *****                            +
    |                                     *****                                |
    |                                 *****                                    |
    |                              ***                                         |
 40 +                           ***                                            +
    |                        ***                                               |
    |                   ******                                                 |
 20 +              ******                                                      +
    |           ****                                                           |
    |       ****                                                               |
  0 +  ******                                                                  +
    +--+----------+----------+----------+----------+----------+----------+-----+
       0         50         100        150        200        250        300     

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
0.006 +  **         ^                                                 **       +
      |             |                                                  **      |
      |      probabilty of this value as the % for a random project     *      |
      |                                                                 **     |
0.004 +                                                                  **    +
      |     coverage% ->                                                  **   |
      +--+------------+------------+------------+-------------+------------+---+
         0           20           40           60            80           100   

  - Mean without 0's = 50.202 (Median 53.434)


--newpage Similarity
--heading Similarity
--horline

* First tried with Javascript
  * Too much pseudo-duplication (too much noise)
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

--horline
Invariants:
--beginoutput
  { x > 10, y == 20}
    y = x+1
  { x > 10, y > 11 }

--endoutput

--newpage Similarity Results (Same Signature)
--heading Similarity Results (Same Signature)
--horline

* Eliminated duplicate projects (file name dups > 50%)
* Eliminated test classes from methods defined by project.
--boldon
Densitiy plot of shared functions% (shared signature)
--boldoff
r| txtdensity(cov$share_percentage_fn ,width=80)
     +--+-------------+------------+------------+------------+-------------+---+
0.04 +              ****                                                       +
     |              *  **                                                      |
     |             *    *                                                      |
     |            **     *                                                     |
0.03 +           **      *                                                     +
     |          **        *                                                    |
     |          *         **       shared fn% ->                               |
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

--newpage Similarity Results (Same Signature) - problems
--heading Similarity Results (Same Signature) - problems
--horline

- Generic naems
  - Methods like toString, main, getName, getId etc have the same signature but that does not mean they are similar. (need to use invariant detection here.)
- Functions are not self contained:
  - Especially for above methods, object state becomes important. It is not clear how to deal with that.

--newpage Both
--heading Both
--horline

- Used the signatures as a guide, and used similarity measures to check the similarity between functions with same signature.
- Results better than using simian alone, still not a lot.

--newpage Upperbound
--heading Upperbound
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

--newpage cont

So the new coverage of projectB would be

--beginoutput
projectB:originalcov_
  = projectB:orig_coveredloc_ / projectB:totalloc_

projectB:newcov
  = projectB:new_coveredloc / projectB:totalloc_

projectB:new_coveredloc
  = projectB:orig_coveredloc_ + (projectA/testAddFn:contrib_lines - projectB/testAddFn:cov%addFn_)

projectA/testAddFn:contrib_lines
  = projectA/testAddFn%cov (And) projectB/addFn_

--endoutput

--newpage Current Status
--heading Current Status
--horline

It is hard to obtain line-coverage per Test case.
- Emma which I was using, has it buried deep in horrible html soup.
- Codecover (FOSS), and Clover (Commercial) are the ones who provide test specific data,
  - unable to get either of them to work well with apache maven, which is what we are running.
  - fell back to the simple strategy of iterating through test cases, running them one by one
    and collecting coverage, but it is time intensive.
- Finding the intersection of projectA:method1 and projectB:method1 is difficult
  (variable names, space etc are normalized before compare)

- What I have:
  - Test coverage per test case of each method in the projects analyzed,
  - Methods that are similar to given method in each of these.
  - From the above, tests that cover these similar methods.

- Shooting for Function Coverage.

--beginoutput
  function_coverage = functions_cov_ / functions_total_
  function_coverage_new = functions_newly_cov + functions_cov_ / functions_total_
  functions_newly_cov = (functions_total_ - functions_cov_) A (covered_repo_functions)
--endoutput

--newpage Function Coverage
--heading Function Coverage
--horline

    +--+-------------------+-------------------+-------------------+-----------+
100 +                                                        .   .   ......    +
    |                           .                        .    .  ........      |
    |                                             . .  . ............          |
 80 +                                    .  .  . ............//./              +
    |             .                    ... .. ......../..///                   |
    |                             . .......... .. /////                        |
 60 |                 .         .  .. . . ..  .///                             |
 60 +                   .    .   . ..... ././//                                +
    |     .   .       . .   ..........././                                     |
    |           . .   .. ...........///                                        |
 40 +     .      ....  ......    ///            Legend                         +
    |     .  . ..  ... .     //./               /  Old Coverage                |
    |        . . .   ../////.      ^            .  New Coverage                |
 20 |   .  .. .... .////           |                                           |
 20 +    .......///.              percentage coverage                          +
    |  ... .//.//                 rank ->                                      |
  0 |  /..//                                                                   |
    +--+-------------------+-------------------+-------------------+-----------+
       0                  100                 200                 300

          Old   New
Median    51.3  69.1
Mean      49.9  63.9

--newpage Recommendations
--heading Recommendations
--horline

- Used a parser to obtain the calls made from each test class.
- No type information unfortunately, so it is even less reliable
- Still working on it.

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
  - Can we automatecally adapt the test cases?
- Can we understand the program sufficiently enough to identify variants?
  - And track these variants so that the origin is identified?
    - Fingerprinting?
- Is code coverage a good metric? Should we look at which properties are satisfied instead?
  - We get good code coverage if we rely on clone detection
  - good property coverage if we rely on types and invariants.

