;; SafeStream Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-pool (err u101))
(define-constant err-pool-exists (err u102))
(define-constant err-insufficient-stake (err u103))

;; Data vars
(define-map pools
  { pool-id: uint }
  {
    owner: principal,
    stake-required: uint,
    claim-period: uint,
    active: bool
  }
)

(define-map claims 
  { claim-id: uint }
  {
    pool-id: uint,
    claimant: principal,
    amount: uint,
    status: (string-ascii 10)
  }
)

(define-data-var next-pool-id uint u0)
(define-data-var next-claim-id uint u0)

;; Public functions
(define-public (create-pool (stake-required uint) (claim-period uint))
  (let ((pool-id (var-get next-pool-id)))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-insert pools
      { pool-id: pool-id }
      {
        owner: tx-sender,
        stake-required: stake-required,
        claim-period: claim-period,
        active: true
      }
    )
    (var-set next-pool-id (+ pool-id u1))
    (ok pool-id)
  )
)

(define-public (submit-claim (pool-id uint) (amount uint))
  (let ((claim-id (var-get next-claim-id)))
    (asserts! (is-some (map-get? pools { pool-id: pool-id })) err-invalid-pool)
    (map-insert claims
      { claim-id: claim-id }
      {
        pool-id: pool-id,
        claimant: tx-sender,
        amount: amount,
        status: "pending"
      }
    )
    (var-set next-claim-id (+ claim-id u1))
    (ok claim-id)
  )
)
