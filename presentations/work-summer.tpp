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

--newpage Coverage
--heading Coverage
--horline


--boldon
Densitiy plot of coverage%
--boldoff

r| txtdensity(cov$coverage_percentage,width=80)
      +--+------------+------------+------------+-------------+------------+---+
 0.02 +  ****                                                                  +
      |     **                                                                 |
      |      **                                                                |
      |       *                                                                |
      |        *                                                               |
0.015 +        **                                                              +
      |         **                                                             |
      |          *                                                             |
      |           *                                                            |
 0.01 +           **                                                           +
      |            ***                                                         |
      |              ***                             *********                 |
      |                ****                **********        *****             |
      |                   ******************                     ****          |
0.005 +                                                             ***        +
      |                                                               ****     |
      |                                                                  ***   |
      +--+------------+------------+------------+-------------+------------+---+
         0           20           40           60            80           100   

- Mean 31.52% (Median 20.61%)

- However it included a large number of projects with no tests at all.
  (Dr. Groce suggests that it is better to not consider these for comparison)

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
  - Dr. Groce also thinks that we would have a higher impact if we concentrate on increasing the coverage of highest covered projects because they evidently care about testing.


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

--newpage Graphs
--heading Graphs
--horline

r| txtplot(cov$share_percentage_fn, cov$coverage_percentage, width=80)

    +--+-------------+------------+-------------+------------+------------+----+
100 +  *       * *    *                * *                                *    +
    |    * * *   *** * *    * *        *                                       |
    |       ** ** * ***  ****    *                                             |
 80 +        ***   *** *****  **                                               +
    |  *   * ******* *****   **                                                |
    |       **  ********** ***  *                                              |
 60 +       * ***  * ** **** *                                                 +
    |  *          **** ****  ** *      *     *                                 |
    |        *** ****** *  *    *      *                                       |
    |          *** *** ***                                                     |
 40 +     *   *   * * * *   * * *       *                                 *    +
    |              ****  ** *   ***   *                                        |
    |       *  * * * ***** *  *   *     *                                      |
 20 +    *   * * **** ***  *  *     *                                          +
    |  *   *  ****  * **   ***    *                                            |
    |          * ***** * *   ** *        *                    *                |
  0 +  * ***************************** ***** **    **     *       *       *    +
    +--+-------------+------------+-------------+------------+------------+----+
       0            20           40            60           80           100    

--newpage


r| txtplot(cov$share_percentage_fn, cov$total_fn, width=80)
--horline

      +--+------------+------------+------------+-------------+------------+---+
      |           *                                                            |
20000 +        *                                                               +
      |                                                                        |
      |                                                                        |
15000 +       *                                                                +
      |                                                                        |
      |                                                                        |
      |           *    *  *                                                    |
10000 +         *     *                                                        +
      |                                                                        |
      |            * *   **                                                    |
      |          *  * **  *    *                                               |
 5000 +          * * *     **                                                  +
      |        *  * *** * * **                                                 |
      |    **   * * ********  *    *                                           |
      |      * ************* ***** *  *  *                                     |
    0 +  ************************************ **    **    *   *    *       *   +
      +--+------------+------------+------------+-------------+------------+---+
         0           20           40           60            80           100   

--newpage


r| txtplot(cov$share_percentage_fn, cov$contrib_count , width=80)
--horline

    +--+-------------+------------+-------------+------------+------------+----+
    |               *                                                          |
    |         *                                                                |
100 +                                                                          +
    |         *                                                                |
    |                             *                                            |
 80 +                                                                          +
    |           * *  *                                                         |
    |              ** *                                                        |
 60 +                   **  *                                                  +
    |               ***   *                                                    |
 40 +      *         * *     * *                                               +
    |          ***   ***    *                                                  |
    |          *   * ** * *  *    *                                            |
 20 +          ********* *** **                                                +
    |    ******* ******* **** * **     *                                       |
    |  * ** **********************  ** *      *                                |
  0 +  * *********************************** **    **     *   *   *       *    +
    +--+-------------+------------+-------------+------------+------------+----+
       0            20           40            60           80           100    

--newpage

r| txtplot(cov$share_percentage_fn, cov$commit_count , width=80)
--horline

      +--+------------+------------+------------+-------------+------------+---+
      |         *                                                              |
12000 +                                                                        +
      |                                                                        |
10000 +                                                                        +
      |                                                                        |
      |           *                                                            |
 8000 +                                                                        +
      |                                                                        |
 6000 +             *                                                          +
      |           *                                                            |
      |               *      *                                                 |
 4000 +          *   *                                                         +
      |              * **                                                      |
      |          ** *** ****                                                   |
 2000 +        **  *  *** * ***                                                +
      |   * *  ************ *** *  *                                           |
    0 +  * ********************************** **    **    *   *    *       *   +
      +--+------------+------------+------------+-------------+------------+---+
         0           20           40           60            80           100   

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
