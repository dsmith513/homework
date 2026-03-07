WITH players AS (
    SELECT 'B' AS player
    UNION ALL
    SELECT 'W'
),
empty AS (
    SELECT a.x, b.y
    FROM generate_series(1, 5) a(x)
    CROSS JOIN generate_series(1, 5) b(y)
    EXCEPT
    SELECT x, y FROM public.go_board
),
possible_moves AS (
    SELECT p.player, e.x, e.y
    FROM players p
    CROSS JOIN empty e
)
SELECT pm.player, pm.x, pm.y
FROM possible_moves pm
WHERE EXISTS (
    WITH RECURSIVE group_stones AS (
        SELECT pm.x AS gx, pm.y AS gy
        UNION ALL
        SELECT gb.x, gb.y
        FROM public.go_board gb
        JOIN group_stones gs ON gb.color = pm.player
        AND (
            (gb.x = gs.gx + 1 AND gb.y = gs.gy) OR
            (gb.x = gs.gx - 1 AND gb.y = gs.gy) OR
            (gb.x = gs.gx AND gb.y = gs.gy + 1) OR
            (gb.x = gs.gx AND gb.y = gs.gy - 1)
        )
    )
    SELECT 1
    FROM group_stones g
    WHERE EXISTS (
        SELECT 1
        FROM (VALUES
            (g.gx + 1, g.gy),
            (g.gx - 1, g.gy),
            (g.gx, g.gy + 1),
            (g.gx, g.gy - 1)
        ) AS adj(ax, ay)
        WHERE ax BETWEEN 1 AND 5
        AND ay BETWEEN 1 AND 5
        AND NOT EXISTS (
            SELECT 1 FROM public.go_board WHERE x = ax AND y = ay
        )
    )
);