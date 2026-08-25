-- Tamil Nadu Election Data Analysis
-- Source: Untitled2.ipynb (project SQL notebook)
-- Party performance analysis

-- Party totals using JOIN, GROUP BY and SUM
SELECT
    p.name AS party,
    SUM(c.total_votes) AS total_votes
FROM candidates c
JOIN parties p
    ON c.party_id = p.id
GROUP BY p.name
ORDER BY total_votes DESC;

-- Party performance using COUNT, SUM and AVG
SELECT
    p.name AS party,
    COUNT(c.id) AS candidate_count,
    SUM(c.total_votes) AS total_votes,
    AVG(c.total_votes) AS average_votes
FROM candidates c
JOIN parties p
    ON c.party_id = p.id
GROUP BY p.name
ORDER BY average_votes DESC;

-- Party performance excluding NOTA and Independent
SELECT
    p.name AS party,
    COUNT(c.id) AS candidate_count,
    SUM(c.total_votes) AS total_votes,
    AVG(c.total_votes) AS average_votes
FROM candidates c
JOIN parties p
    ON c.party_id = p.id
WHERE p.name NOT IN (
    'None of the Above',
    'Independent'
)
GROUP BY p.name
ORDER BY total_votes DESC;

-- Parties exceeding one million total votes
SELECT
    p.name AS party,
    COUNT(c.id) AS candidate_count,
    SUM(c.total_votes) AS total_votes
FROM candidates c
JOIN parties p
    ON c.party_id = p.id
WHERE p.name NOT IN (
    'None of the Above',
    'Independent'
)
GROUP BY p.name
HAVING SUM(c.total_votes) > 1000000
ORDER BY total_votes DESC;

-- Party summary: highest, lowest, average and vote range
SELECT
    p.name AS party,

    COUNT(c.id) AS candidate_count,

    MAX(c.total_votes) AS highest_votes,

    MIN(c.total_votes) AS lowest_votes,

    ROUND(AVG(c.total_votes), 2) AS average_votes,

    MAX(c.total_votes) - MIN(c.total_votes) AS vote_range

FROM candidates c

JOIN parties p
    ON c.party_id = p.id

WHERE c.is_nota = 0

GROUP BY p.name

ORDER BY highest_votes DESC;

-- Top parties by average candidate votes
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

ORDER BY average_votes DESC

LIMIT 10;
