-- Switch from FILTER to CASE for RedShift compatibility.
SELECT
    *
FROM (
    SELECT
        rs_requester AS requester,
        sum(
            CASE WHEN rs_to_status = 'REQ_VALIDATED' THEN
                1
            ELSE
                0
            END) AS reqs,
        sum(
            CASE WHEN rs_to_status = 'REQ_CANCELLED' THEN
                1
            ELSE
                0
            END) AS cancelled,
        sum(
            CASE WHEN rs_to_status = 'REQ_END_OF_ROTA' THEN
                1
            ELSE
                0
            END) AS unfilled,
        sum(
            CASE WHEN (rs_from_status = 'REQ_SHIPPED'
                AND rs_to_status = 'REQ_CHECKED_IN')
                OR rs_to_status = 'REQ_FILLED_LOCALLY' THEN
                1
            ELSE
                0
            END) AS received,
        round((sum(
                CASE WHEN (rs_from_status = 'REQ_SHIPPED'
                    AND rs_to_status = 'REQ_CHECKED_IN') THEN
                    1
                ELSE
                    0
                END) / cast(sum(
                    CASE WHEN rs_to_status = 'REQ_VALIDATED' THEN
                        1
                    ELSE
                        0
                    END) AS decimal)), 2) AS filled_ratio
    FROM
        reshare_derived.req_stats
    GROUP BY
        requester
    UNION
    SELECT
        'consortium' AS requester,
        sum(
            CASE WHEN rs_to_status = 'REQ_VALIDATED' THEN
                1
            ELSE
                0
            END) AS reqs,
        sum(
            CASE WHEN rs_to_status = 'REQ_CANCELLED' THEN
                1
            ELSE
                0
            END) AS cancelled,
        sum(
            CASE WHEN rs_to_status = 'REQ_END_OF_ROTA' THEN
                1
            ELSE
                0
            END) AS unfilled,
        sum(
            CASE WHEN (rs_from_status = 'REQ_SHIPPED'
                AND rs_to_status = 'REQ_CHECKED_IN')
                OR rs_to_status = 'REQ_FILLED_LOCALLY' THEN
                1
            ELSE
                0
            END) AS received,
        round((sum(
                CASE WHEN (rs_from_status = 'REQ_SHIPPED'
                    AND rs_to_status = 'REQ_CHECKED_IN') THEN
                    1
                ELSE
                    0
                END) / cast(sum(
                    CASE WHEN rs_to_status = 'REQ_VALIDATED' THEN
                        1
                    ELSE
                        0
                    END) AS decimal)), 2) AS filled_ratio
    FROM
        reshare_derived.req_stats
    GROUP BY
        requester) AS core_req
ORDER BY
    (
        CASE WHEN core_req.requester = 'consortium' THEN
            0
        ELSE
            1
        END),
    core_req.requester;

