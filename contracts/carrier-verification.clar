;; Carrier Verification Contract
;; This contract validates legitimate transportation companies

(define-data-var admin principal tx-sender)

;; Map to store verified carriers
(define-map verified-carriers principal
  {
    company-name: (string-utf8 100),
    license-number: (string-utf8 50),
    verification-date: uint,
    is-active: bool
  }
)

;; Public function to verify a carrier (admin only)
(define-public (verify-carrier
    (carrier principal)
    (company-name (string-utf8 100))
    (license-number (string-utf8 50)))
  (begin
    (asserts! (is-admin tx-sender) (err u1))
    (ok (map-set verified-carriers carrier
      {
        company-name: company-name,
        license-number: license-number,
        verification-date: block-height,
        is-active: true
      }
    ))
  )
)

;; Public function to revoke carrier verification (admin only)
(define-public (revoke-carrier (carrier principal))
  (begin
    (asserts! (is-admin tx-sender) (err u1))
    (asserts! (is-carrier-verified carrier) (err u2))
    (let ((carrier-data (unwrap! (map-get? verified-carriers carrier) (err u3))))
      (ok (map-set verified-carriers carrier
        (merge carrier-data { is-active: false })
      ))
    )
  )
)

;; Read-only function to check if a carrier is verified
(define-read-only (is-carrier-verified (carrier principal))
  (match (map-get? verified-carriers carrier)
    carrier-data (get is-active carrier-data)
    false
  )
)

;; Read-only function to get carrier details
(define-read-only (get-carrier-details (carrier principal))
  (map-get? verified-carriers carrier)
)

;; Helper function to check if caller is admin
(define-private (is-admin (caller principal))
  (is-eq caller (var-get admin))
)

;; Function to transfer admin rights (admin only)
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin tx-sender) (err u1))
    (ok (var-set admin new-admin))
  )
)
