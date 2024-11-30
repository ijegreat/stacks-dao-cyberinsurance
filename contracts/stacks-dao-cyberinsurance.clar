;; Pooled Cyber Insurance DAO Smart Contract

;; Contract constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-INSUFFICIENT-FUNDS (err u2))
(define-constant ERR-INVALID-CLAIM (err u3))
(define-constant ERR-ALREADY-VOTED (err u4))
(define-constant ERR-CLAIM-TIMEOUT (err u5))
(define-constant ERR-BLOCK-UPDATE-FAILED (err u6))

;; Manual Block Height Tracking
(define-data-var current-block-height uint u0)
(define-data-var last-block-updater principal tx-sender)

;; Block Height Update Function
(define-public (update-block-height)
    (begin
        ;; Prevent multiple updates by the same sender in quick succession
        (asserts! 
            (not (is-eq (var-get last-block-updater) tx-sender)) 
            ERR-BLOCK-UPDATE-FAILED
        )

        ;; Update block height
        (var-set current-block-height 
            (+ (var-get current-block-height) u1)
        )

        ;; Record last updater
        (var-set last-block-updater tx-sender)

        (ok (var-get current-block-height))
    )
)

;; Storage for insurance pool
(define-map insurance-pool 
    {member: principal} 
    {
        contributed-amount: uint,
        active-coverage: bool,
        contribution-block: uint
    }
)

;; Storage for claims
(define-map claims
    {claim-id: uint}
    {
        protocol: principal,
        amount-requested: uint,
        total-votes: uint,
        approved-votes: uint,
        is-resolved: bool,
        claim-block: uint,
        voting-end-block: uint
    }
)


;; Track votes for each member on each claim
(define-map member-votes
    {member: principal, claim-id: uint}
    {voted: bool}
)

;; Track total pool funds and next claim ID
(define-data-var total-pool-funds uint u0)
(define-data-var next-claim-id uint u1)

;; Voting period constants
(define-constant VOTING-PERIOD u144) ;; Approximately 24 hours 
(define-constant CLAIM-EXPIRATION u1440) ;; Approximately 10 days

;; Member contribution function
(define-public (contribute (amount uint))
    (let 
        (
            (current-height (var-get current-block-height))
        )
        (begin
            ;; Ensure minimum contribution
            (asserts! (> amount u0) ERR-INSUFFICIENT-FUNDS)

            ;; Transfer STX to contract
            (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

            ;; Update pool mapping
            (map-set insurance-pool 
                {member: tx-sender} 
                {
                    contributed-amount: amount,
                    active-coverage: true,
                    contribution-block: current-height
                }
            )

            ;; Increment total pool funds
            (var-set total-pool-funds 
                (+ (var-get total-pool-funds) amount)
            )

            (ok true)
        )
    )
)

;; Submit claim function
(define-public (submit-claim 
    (protocol principal) 
    (amount-requested uint)
)
    (let 
        (
            (claim-id (var-get next-claim-id))
            (current-height (var-get current-block-height))
            (member-info 
                (unwrap! 
                    (map-get? insurance-pool {member: tx-sender}) 
                    ERR-NOT-AUTHORIZED
                )
            )
            (voting-end (+ current-height VOTING-PERIOD))
        )

        ;; Ensure member has active coverage
        (asserts! (get active-coverage member-info) ERR-NOT-AUTHORIZED)

        ;; Ensure claim is submitted within coverage period
        (asserts! 
            (<= 
                (- current-height (get contribution-block member-info)) 
                CLAIM-EXPIRATION
            ) 
            ERR-CLAIM-TIMEOUT
        )

        ;; Create claim
        (map-set claims 
            {claim-id: claim-id}
            {
                protocol: protocol,
                amount-requested: amount-requested,
                total-votes: u0,
                approved-votes: u0,
                is-resolved: false,
                claim-block: current-height,
                voting-end-block: voting-end
            }
        )

        ;; Increment next claim ID
        (var-set next-claim-id (+ claim-id u1))

        (ok claim-id)
    )
)