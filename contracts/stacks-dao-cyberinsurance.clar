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
