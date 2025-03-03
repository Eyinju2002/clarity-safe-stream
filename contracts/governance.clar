;; Governance Contract

;; Constants
(define-constant min-votes u3)
(define-constant vote-period u144) ;; ~1 day in blocks
(define-constant err-already-voted (err u404))
(define-constant err-vote-period-ended (err u403))
(define-constant err-insufficient-votes (err u405))

;; Maps
(define-map votes
  { claim-id: uint, voter: principal }
  { approved: bool }
)

(define-map vote-counts
  { claim-id: uint }
  { 
    approve: uint,
    reject: uint,
    end-block: uint
  }
)

;; Public functions
(define-public (vote-on-claim (claim-id uint) (approved bool))
  (let ((vote-count (default-to
    { approve: u0, reject: u0, end-block: (+ block-height vote-period) }
    (map-get? vote-counts { claim-id: claim-id }))))
    
    (asserts! (< block-height (get end-block vote-count)) err-vote-period-ended)
    (asserts! (is-none (map-get? votes { claim-id: claim-id, voter: tx-sender })) err-already-voted)
    
    (map-set votes
      { claim-id: claim-id, voter: tx-sender }
      { approved: approved }
    )
    
    (map-set vote-counts
      { claim-id: claim-id }
      (merge vote-count {
        approve: (if approved (+ (get approve vote-count) u1) (get approve vote-count)),
        reject: (if (not approved) (+ (get reject vote-count) u1) (get reject vote-count))
      })
    )
    
    (ok true)
  )
)

(define-public (finalize-claim (claim-id uint))
  (let (
    (vote-count (unwrap! (map-get? vote-counts { claim-id: claim-id }) err-insufficient-votes))
    (total-votes (+ (get approve vote-count) (get reject vote-count)))
  )
    (asserts! (>= block-height (get end-block vote-count)) err-vote-period-ended)
    (asserts! (>= total-votes min-votes) err-insufficient-votes)
    
    (contract-call? .safe-stream update-claim-status 
      claim-id 
      (if (> (get approve vote-count) (get reject vote-count)) "approved" "rejected")
    )
  )
)
