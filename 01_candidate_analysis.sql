-- Tamil Nadu Election Data Analysis
-- Source: Untitled2.ipynb (project SQL notebook)
-- Candidate-level analysis

-- Top candidates by total votes, excluding NOTA
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

-- Candidates above the overall average vote count
SELECT
    name AS candidate,
    total_votes
FROM candidates
WHERE total_votes > (
    SELECT AVG(total_votes)
    FROM candidates
)
ORDER BY total_votes DESC;

-- Candidate vote categories using CASE WHEN
SELECT
    name AS candidate,
    total_votes,
    CASE
        WHEN total_votes >= 100000 THEN 'High Votes'
        WHEN total_votes >= 50000 THEN 'Medium Votes'
        ELSE 'Low Votes'
    END AS vote_category
FROM candidates
ORDER BY total_votes DESC
LIMIT 20;
