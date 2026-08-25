-- Tamil Nadu Election Data Analysis
-- Source: Untitled2.ipynb (project SQL notebook)
-- Advanced SQL: window functions, CTEs, CASE WHEN and HAVING

-- RANK(): top candidates
SELECT
    name AS candidate,
    total_votes,
    RANK() OVER (
        ORDER BY total_votes DESC
    ) AS vote_rank
FROM candidates
WHERE is_nota = 0
ORDER BY vote_rank
LIMIT 10;

-- RANK() within each party
SELECT
    p.name AS party,
    c.name AS candidate,
    c.total_votes,

    RANK() OVER (
        PARTITION BY p.name
        ORDER BY c.total_votes DESC
    ) AS party_rank

FROM candidates c

JOIN parties p
    ON c.party_id = p.id

WHERE c.is_nota = 0

ORDER BY p.name, party_rank;

-- ROW_NUMBER() within each party
SELECT
    p.name AS party,
    c.name AS candidate,
    c.total_votes,

    ROW_NUMBER() OVER (
        PARTITION BY p.name
        ORDER BY c.total_votes DESC
    ) AS row_number

FROM candidates c

JOIN parties p
    ON c.party_id = p.id

WHERE c.is_nota = 0

ORDER BY p.name, row_number;

-- LAG(): previous candidate votes
SELECT
    p.name AS party,
    c.name AS candidate,
    c.total_votes,

    LAG(c.total_votes) OVER (
        PARTITION BY p.name
        ORDER BY c.total_votes DESC
    ) AS previous_votes

FROM candidates c

JOIN parties p
    ON c.party_id = p.id

WHERE c.is_nota = 0

ORDER BY p.name, c.total_votes DESC;

-- LEAD(): next candidate votes
SELECT
    p.name AS party,
    c.name AS candidate,
    c.total_votes,

    LEAD(c.total_votes) OVER (
        PARTITION BY p.name
        ORDER BY c.total_votes DESC
    ) AS next_candidate_votes

FROM candidates c

JOIN parties p
    ON c.party_id = p.id

WHERE c.is_nota = 0

ORDER BY p.name, c.total_votes DESC;

-- FIRST_VALUE(): highest vote total within each party
SELECT
    party,
    candidate,
    total_votes,

    FIRST_VALUE(total_votes) OVER (
        PARTITION BY party
        ORDER BY total_votes DESC
    ) AS highest_party_votes,

    FIRST_VALUE(total_votes) OVER (
        PARTITION BY party
        ORDER BY total_votes DESC
    ) - total_votes AS gap_from_top

FROM (
    SELECT
        p.name AS party,
        c.name AS candidate,
        c.total_votes
    FROM candidates c
    JOIN parties p
        ON c.party_id = p.id
    WHERE c.is_nota = 0
)

ORDER BY party, total_votes DESC;

-- LAST_VALUE(): lowest vote total within each party
SELECT
    p.name AS party,
    c.name AS candidate,
    c.total_votes,

    LAST_VALUE(c.total_votes) OVER (
        PARTITION BY p.name
        ORDER BY c.total_votes DESC
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
    ) AS lowest_party_votes

FROM candidates c

JOIN parties p
    ON c.party_id = p.id

WHERE c.is_nota = 0

ORDER BY p.name, c.total_votes DESC;

-- Window-function vote range
SELECT
    party,
    candidate,
    total_votes,

    MAX(total_votes) OVER (
        PARTITION BY party
    ) AS highest_votes,

    MIN(total_votes) OVER (
        PARTITION BY party
    ) AS lowest_votes,

    MAX(total_votes) OVER (
        PARTITION BY party
    ) -
    MIN(total_votes) OVER (
        PARTITION BY party
    ) AS vote_range

FROM (
    SELECT
        p.name AS party,
        c.name AS candidate,
        c.total_votes

    FROM candidates c

    JOIN parties p
        ON c.party_id = p.id

    WHERE c.is_nota = 0
)

ORDER BY vote_range DESC;

-- The notebook's final advanced SQL lesson contains queries 9.31-9.37.

-- query_931
SELECT
    p.name AS party,
    COUNT(c.id) AS candidate_count,
    SUM(c.total_votes) AS total_votes,
    ROUND(AVG(c.total_votes), 2) AS average_votes

FROM candidates c

JOIN parties p
    ON c.party_id = p.id

WHERE c.is_nota = 0

GROUP BY p.name

HAVING COUNT(c.id) >= 10

ORDER BY average_votes DESC;

-- query_932
SELECT
    p.name AS party,
    COUNT(c.id) AS candidate_count,
    ROUND(AVG(c.total_votes), 2) AS average_votes,

    CASE
        WHEN AVG(c.total_votes) >= 70000
            THEN 'High Performance'

        WHEN AVG(c.total_votes) >= 50000
            THEN 'Medium Performance'

        ELSE 'Low Performance'
    END AS performance_category

FROM candidates c

JOIN parties p
    ON c.party_id = p.id

WHERE c.is_nota = 0

GROUP BY p.name

HAVING COUNT(c.id) >= 10

ORDER BY average_votes DESC;

-- query_933
SELECT *
FROM (
    SELECT
        p.name AS party,
        COUNT(c.id) AS candidate_count,
        ROUND(AVG(c.total_votes), 2) AS average_votes,

        CASE
            WHEN AVG(c.total_votes) >= 70000
                THEN 'High Performance'

            WHEN AVG(c.total_votes) >= 50000
                THEN 'Medium Performance'

            ELSE 'Low Performance'
        END AS performance_category

    FROM candidates c

    JOIN parties p
        ON c.party_id = p.id

    WHERE c.is_nota = 0

    GROUP BY p.name

    HAVING COUNT(c.id) >= 10
)

WHERE performance_category = 'High Performance'

ORDER BY average_votes DESC;

-- query_934
WITH party_stats AS (

    SELECT
        p.name AS party,
        COUNT(c.id) AS candidate_count,
        SUM(c.total_votes) AS total_votes,
        ROUND(AVG(c.total_votes), 2) AS average_votes

    FROM candidates c

    JOIN parties p
        ON c.party_id = p.id

    WHERE c.is_nota = 0

    GROUP BY p.name
)

SELECT *
FROM party_stats

WHERE candidate_count >= 10

ORDER BY average_votes DESC;

-- query_935
WITH party_stats AS (

    SELECT
        p.name AS party,
        COUNT(c.id) AS candidate_count,
        SUM(c.total_votes) AS total_votes,
        ROUND(AVG(c.total_votes), 2) AS average_votes

    FROM candidates c

    JOIN parties p
        ON c.party_id = p.id

    WHERE c.is_nota = 0

    GROUP BY p.name
),

party_analysis AS (

    SELECT
        party,
        candidate_count,
        total_votes,
        average_votes,

        CASE
            WHEN average_votes >= 70000
                THEN 'High Performance'

            WHEN average_votes >= 50000
                THEN 'Medium Performance'

            ELSE 'Low Performance'
        END AS performance_category

    FROM party_stats

    WHERE candidate_count >= 10
)

SELECT *
FROM party_analysis

ORDER BY average_votes DESC;

-- query_936
WITH ranked_candidates AS (

    SELECT
        p.name AS party,
        c.name AS candidate,
        c.total_votes,

        ROW_NUMBER() OVER (
            PARTITION BY p.name
            ORDER BY c.total_votes DESC
        ) AS row_num

    FROM candidates c

    JOIN parties p
        ON c.party_id = p.id

    WHERE c.is_nota = 0
)

SELECT
    party,
    candidate,
    total_votes

FROM ranked_candidates

WHERE row_num = 1

ORDER BY total_votes DESC;

-- query_937
WITH party_stats AS (

    SELECT
        p.name AS party,

        COUNT(c.id) AS candidate_count,

        SUM(c.total_votes) AS total_votes,

        ROUND(AVG(c.total_votes), 2) AS average_votes,

        MAX(c.total_votes) AS highest_votes,

        MIN(c.total_votes) AS lowest_votes,

        MAX(c.total_votes) - MIN(c.total_votes)
            AS vote_range

    FROM candidates c

    JOIN parties p
        ON c.party_id = p.id

    WHERE c.is_nota = 0

    GROUP BY p.name
),

ranked_candidates AS (

    SELECT
        p.name AS party,
        c.name AS top_candidate,
        c.total_votes AS top_candidate_votes,

        ROW_NUMBER() OVER (
            PARTITION BY p.name
            ORDER BY c.total_votes DESC
        ) AS row_num

    FROM candidates c

    JOIN parties p
        ON c.party_id = p.id

    WHERE c.is_nota = 0
),

top_candidates AS (

    SELECT
        party,
        top_candidate,
        top_candidate_votes

    FROM ranked_candidates

    WHERE row_num = 1
)

SELECT
    ps.party,
    ps.candidate_count,
    ps.total_votes,
    ps.average_votes,
    ps.highest_votes,
    ps.lowest_votes,
    ps.vote_range,

    tc.top_candidate,
    tc.top_candidate_votes,

    CASE
        WHEN ps.average_votes >= 70000
            THEN 'High Performance'

        WHEN ps.average_votes >= 50000
            THEN 'Medium Performance'

        ELSE 'Low Performance'

    END AS performance_category

FROM party_stats ps

JOIN top_candidates tc
    ON ps.party = tc.party

WHERE ps.candidate_count >= 10

ORDER BY ps.average_votes DESC;
