-- Tamil Nadu Election Data Analysis
-- Source: Untitled2.ipynb (project SQL notebook)
-- Winner and ranking analysis

-- Winners and winning margins
SELECT
    c.name AS winner,
    p.name AS winner_party,
    c.total_votes,
    c.card_margin AS winning_margin,

    CASE
        WHEN c.card_margin < 5000 THEN 'Close'
        WHEN c.card_margin < 20000 THEN 'Moderate'
        WHEN c.card_margin < 50000 THEN 'Strong'
        ELSE 'Landslide'
    END AS margin_category

FROM candidates c

JOIN parties p
    ON c.party_id = p.id

WHERE c.rank = 1

ORDER BY c.card_margin DESC;

-- Winners with votes above the average winning-candidate vote count
SELECT
    c.name AS winner,
    p.name AS party,
    c.total_votes
FROM candidates c
JOIN parties p
    ON c.party_id = p.id
WHERE c.rank = 1
AND c.total_votes > (
    SELECT AVG(total_votes)
    FROM candidates
    WHERE rank = 1
)
ORDER BY c.total_votes DESC;

-- Top winners by winning margin
SELECT
    c.name AS winner,
    p.name AS party,
    c.card_margin AS winning_margin,

    RANK() OVER (
        ORDER BY c.card_margin DESC
    ) AS margin_rank

FROM candidates c

JOIN parties p
    ON c.party_id = p.id

WHERE c.rank = 1

ORDER BY margin_rank
LIMIT 10;

-- Top candidate from each party
SELECT
    party,
    candidate,
    total_votes
FROM (
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
)
WHERE party_rank = 1
ORDER BY total_votes DESC;
