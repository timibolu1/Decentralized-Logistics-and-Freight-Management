;; Payment Escrow Contract
;; This contract holds and releases funds based on delivery confirmation

(define-data-var admin principal tx-sender)
(define-constant err-unauthorized u1)
(define-constant err-not-found u2)
(define-constant err-already-exists u3)
(define-constant err-insufficient-funds u4)
(define-constant err-invalid-state u5)

;; Structure for escrow payments
(define-map escrows uint
  {
    shipment-id: uint,
    amount: uint,
    shipper: principal,
    carrier: principal,
    status: (string-utf8 20),
    created-at: uint,
    completed-at: uint
  }
)

;; Public function to create an escrow for a shipment
(define-public (create-escrow (shipment-id uint) (amount uint))
  (let
    (
      (shipment (unwrap! (contract-call? .shipment-booking get-shipment shipment-id) (err-not-found)))
    )
    ;; Verify caller is the shipper for this shipment
    (asserts! (is-eq tx-sender (get shipper shipment)) (err-unauthorized))

    ;; Check if escrow already exists
    (asserts! (is-none (map-get? escrows shipment-id)) (err-already-exists))

    ;; Transfer funds to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

    ;; Create the escrow
    (map-set escrows shipment-id
      {
        shipment-id: shipment-id,
        amount: amount,
        shipper: (get shipper shipment),
        carrier: (get carrier shipment),
        status: "funded",
        created-at: block-height,
        completed-at: u0
      }
    )

    (ok true)
  )
)

;; Public function to release funds to carrier (shipper only, after delivery)
(define-public (release-funds (shipment-id uint))
  (let ((escrow (unwrap! (map-get? escrows shipment-id) (err-not-found))))
    ;; Verify caller is the shipper
    (asserts! (is-eq tx-sender (get shipper escrow)) (err-unauthorized))

    ;; Verify escrow is in funded state
    (asserts! (is-eq (get status escrow) "funded") (err-invalid-state))

    ;; Transfer funds to carrier
    (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get carrier escrow))))

    ;; Update escrow status
    (ok (map-set escrows shipment-id
      (merge escrow {
        status: "completed",
        completed-at: block-height
      })
    ))
  )
)

;; Public function to dispute an escrow (shipper only)
(define-public (dispute-escrow (shipment-id uint))
  (let ((escrow (unwrap! (map-get? escrows shipment-id) (err-not-found))))
    ;; Verify caller is the shipper
    (asserts! (is-eq tx-sender (get shipper escrow)) (err-unauthorized))

    ;; Verify escrow is in funded state
    (asserts! (is-eq (get status escrow) "funded") (err-invalid-state))

    ;; Update escrow status
    (ok (map-set escrows shipment-id
      (merge escrow { status: "disputed" })
    ))
  )
)

;; Public function to resolve a dispute (admin only)
(define-public (resolve-dispute (shipment-id uint) (to-carrier uint) (to-shipper uint))
  (let ((escrow (unwrap! (map-get? escrows shipment-id) (err-not-found))))
    ;; Verify caller is admin
    (asserts! (is-admin tx-sender) (err-unauthorized))

    ;; Verify escrow is in disputed state
    (asserts! (is-eq (get status escrow) "disputed") (err-invalid-state))

    ;; Verify amounts add up to escrow amount
    (asserts! (is-eq (+ to-carrier to-shipper) (get amount escrow)) (err-invalid-state))

    ;; Transfer funds to carrier and shipper
    (try! (as-contract (stx-transfer? to-carrier tx-sender (get carrier escrow))))
    (try! (as-contract (stx-transfer? to-shipper tx-sender (get shipper escrow))))

    ;; Update escrow status
    (ok (map-set escrows shipment-id
      (merge escrow {
        status: "resolved",
        completed-at: block-height
      })
    ))
  )
)

;; Read-only function to get escrow details
(define-read-only (get-escrow (shipment-id uint))
  (map-get? escrows shipment-id)
)

;; Helper function to check if caller is admin
(define-private (is-admin (caller principal))
  (is-eq caller (var-get admin))
)

;; Function to transfer admin rights (admin only)
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin tx-sender) (err-unauthorized))
    (ok (var-set admin new-admin))
  )
)
