;; darabit: simple OTC escrow for trading a SIP-010 FT (e.g., DARA) for STX

(define-constant ERR-OFFER-NOT-FOUND u200)
(define-constant ERR-NOT-SELLER u201)
(define-constant ERR-ALREADY-FILLED u202)
(define-constant ERR-FT-TRANSFER u300)
(define-constant ERR-STX-TRANSFER u301)

(define-data-var last-offer-id uint u0)

(define-map offers
  { id: uint }
  { seller: principal, amount: uint, price: uint, filled: bool, buyer: (optional principal) }
)

(define-read-only (get-last-offer-id) (var-get last-offer-id))
(define-read-only (get-offer (id uint)) (map-get? offers { id: id }))

(define-public (create-offer (amount uint) (price uint))
  (let ((id (+ u1 (var-get last-offer-id)))
        (contract-principal (as-contract tx-sender)))
    (match (contract-call? .daracoin transfer amount tx-sender contract-principal none)
      ok-bool
      (begin
        (map-set offers { id: id }
          { seller: tx-sender, amount: amount, price: price, filled: false, buyer: none })
        (var-set last-offer-id id)
        (ok id))
      err-code (err ERR-FT-TRANSFER))))

(define-public (cancel-offer (id uint))
  (let ((maybe (map-get? offers { id: id })))
    (match maybe offer
      (if (is-eq (get seller offer) tx-sender)
          (if (not (get filled offer))
              (let ((contract-principal (as-contract tx-sender)))
                ;; return escrowed tokens to seller
                (match (contract-call? .daracoin transfer (get amount offer) contract-principal tx-sender none)
                  ok-bool (begin (map-delete offers { id: id }) (ok true))
                  err-code (err ERR-FT-TRANSFER)))
              (err ERR-ALREADY-FILLED))
          (err ERR-NOT-SELLER))
      (err ERR-OFFER-NOT-FOUND))))

(define-public (accept-offer (id uint))
  (let ((maybe (map-get? offers { id: id })))
    (match maybe offer
      (if (get filled offer)
          (err ERR-ALREADY-FILLED)
          (let ((price (get price offer))
                (amount (get amount offer))
                (seller (get seller offer))
                (contract-principal (as-contract tx-sender)))
(match (stx-transfer? price tx-sender seller)
              ok-stx
              (match (contract-call? .daracoin transfer amount contract-principal tx-sender none)
                ok-ft
                (begin
                  (map-set offers { id: id }
                    (merge offer { filled: true, buyer: (some tx-sender) }))
                  (ok true))
                ft-err (err ERR-FT-TRANSFER))
              stx-err (err ERR-STX-TRANSFER))))
      (err ERR-OFFER-NOT-FOUND))))
