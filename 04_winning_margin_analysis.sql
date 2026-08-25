-- Tamil Nadu Election Data Analysis
-- Source: Untitled2.ipynb (project SQL notebook)
-- Winning-margin analysis

-- Winning-margin categories
SELECT
    CASE
        WHEN c.card_margin < 5000 THEN 'Close'
        WHEN c.card_margin < 20000 THEN 'Moderate'
        WHEN c.card_margin < 50000 THEN 'Strong'
        ELSE 'Landslide'
    END AS margin_category,

    COUNT(*) AS constituency_count

FROM candidates c

WHERE c.rank = 1

GROUP BY margin_category

ORDER BY constituency_count DESC;

-- Winning-margin category percentages
SELECT
    margin_category,
    COUNT(*) AS constituency_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM candidates
         WHERE rank = 1),
        2
    ) AS percentage
FROM (
    SELECT
        CASE
            WHEN card_margin < 5000 THEN 'Close'
            WHEN card_margin < 20000 THEN 'Moderate'
            WHEN card_margin < 50000 THEN 'Strong'
            ELSE 'Landslide'
        END AS margin_category
    FROM candidates
    WHERE rank = 1
)
GROUP BY margin_category
ORDER BY constituency_count DESC;

-- Party candidate vote gaps using LAG
SELECT
    party,
    candidate,
    total_votes,
    previous_votes,

    previous_votes - total_votes AS vote_gap

FROM (
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
)

ORDER BY party, total_votes DESC;

-- Largest within-party vote gaps
SELECT
    party,
    candidate,
    total_votes,
    previous_votes,
    previous_votes - total_votes AS vote_gap

FROM (
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
)

WHERE previous_votes IS NOT NULL

ORDER BY vote_gap DESC
LIMIT 20;

-- Next-candidate vote gaps using LEAD
SELECT
    party,
    candidate,
    total_votes,
    next_candidate_votes,

    total_votes - next_candidate_votes AS next_vote_gap

FROM (
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
)

WHERE next_candidate_votes IS NOT NULL

ORDER BY next_vote_gap DESC
LIMIT 20;
