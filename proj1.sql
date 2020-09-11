-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst, namelast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) AS avgheight, COUNT(*) as count
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height) AS avgheight, COUNT(*) as count
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT DISTINCT namefirst, namelast, people.playerid, yearid
  FROM people
  INNER JOIN halloffame
  ON people.playerid = halloffame.playerid AND halloffame.inducted = 'Y'
  ORDER BY yearid DESC, halloffame.playerid ASC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, people.playerid, schools.schoolid, halloffame.yearid
  FROM people, collegeplaying, halloffame, schools
  WHERE (people.playerid = halloffame.playerid AND halloffame.inducted = 'Y' AND people.playerid = collegeplaying.playerid)
        AND (collegeplaying.schoolid = schools.schoolid AND schools.state = 'CA')
  ORDER BY halloffame.yearid DESC, schools.schoolid ASC, people.playerid ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT people.playerid, namefirst, namelast, schoolid
  FROM people
  INNER JOIN halloffame
  ON (people.playerid = halloffame.playerid AND halloffame.inducted = 'Y')
  LEFT JOIN collegeplaying
  ON people.playerid = collegeplaying.playerid
  ORDER BY people.playerid DESC, collegeplaying.playerid, schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT people.playerid, namefirst, namelast, yearid, ((CAST(H AS FLOAT) - h2b - h3b - HR) + (2*h2b) + (3*h3b) + (4*HR))/AB AS slg
  FROM batting
  INNER JOIN people
  ON (batting.playerid = people.playerid)
  WHERE batting.AB > 50
  ORDER BY slg DESC, yearid ASC, people.playerid ASC
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT DISTINCT people.playerid, namefirst, namelast, ((CAST(SUM(H) AS FLOAT) - SUM(H2B) - SUM(H3B) - SUM(HR)) + SUM(2*H2B) + SUM(3*H3B) + SUM(4*HR))/SUM(AB) AS lslg
  FROM people
  INNER JOIN batting
  ON people.playerid = batting.playerid
  GROUP BY people.playerid
  HAVING SUM(batting.AB)>50
  ORDER BY lslg DESC, people.playerid ASC
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast, ((CAST(SUM(H) AS FLOAT) - SUM(H2B) - SUM(H3B) - SUM(HR)) + SUM(2*H2B) + SUM(3*H3B) + SUM(4*HR))/SUM(AB) AS lslg
  FROM people
  INNER JOIN batting
  ON batting.playerid = people.playerid
  GROUP BY people.playerid
  HAVING (SUM(batting.AB) > 50 AND lslg > (SELECT ((CAST(SUM(H) AS FLOAT) - SUM(H2B) - SUM(H3B) - SUM(HR)) + SUM(2*H2B) + SUM(3*H3B) + SUM(4*HR))/SUM(AB) AS lslg
                                           FROM batting
                                           WHERE batting.playerid = 'mayswi01'
                                           GROUP BY batting.playerid))
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary) AS min, MAX(salary) AS max, AVG(salary) AS avg
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid ASC
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH binids(binid) AS (VALUES (0), (1), (2), (3), (4), (5), (6), (7), (8), (9))
  SELECT binid, low, high, COUNT(binid) AS count
  FROM (SELECT binid, ((binid)*((MAX(salary) - MIN(salary))/10)) + MIN(salary) AS low,
                        ((binid + 1)*((MAX(salary) - MIN(salary))/10)) + MIN(salary) AS high
  FROM binids, (SELECT salary FROM salaries WHERE yearid = 2016)
  GROUP BY binid)
  INNER JOIN (SELECT * FROM salaries WHERE yearid = 2016)
  ON salary >= low AND salary <= high
  GROUP BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
    SELECT y2.yearid, MIN(y2.salary) - MIN(y1.salary) AS mindiff, MAX(y2.salary) - MAX(y1.salary) AS maxdiff, AVG(y2.salary) - AVG(y1.salary)
    FROM salaries AS y2
    INNER JOIN salaries AS y1
    ON y2.yearid = y1.yearid + 1
    GROUP BY y2.yearid, y1.yearid
    ORDER BY y2.yearid ASC
  
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT people.playerid, namefirst, namelast, MAX(salary), yearid
  FROM salaries, people
  WHERE salaries.playerid = people.playerid
  GROUP BY yearid
  HAVING yearid = 2000
  UNION
  SELECT people.playerid, namefirst, namelast, MAX(salary), yearid
  FROM salaries, people
  WHERE salaries.playerid = people.playerid
  GROUP BY yearid
  HAVING yearid = 2001
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT allstarfull.teamid AS teamid, MAX(salary) - MIN(salary) AS diffAvg
  FROM salaries
  INNER JOIN allstarfull
  ON allstarfull.playerid = salaries.playerid AND allstarfull.yearid = salaries.yearid
  WHERE allstarfull.yearid = 2016
  GROUP BY allstarfull.teamid
;

