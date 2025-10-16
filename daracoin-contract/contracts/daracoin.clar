;; daracoin - A comprehensive fungible token implementing SIP-010
;; This contract implements a fully-featured cryptocurrency token with
;; minting, burning, transfers, and administrative controls

;; Define the fungible token
(define-fungible-token daracoin)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-transfer-failed (err u104))
(define-constant err-mint-failed (err u105))
(define-constant err-burn-failed (err u106))

;; Token metadata
(define-constant token-name "Daracoin")
(define-constant token-symbol "DARA")
(define-constant token-decimals u6)
(define-constant token-uri (some u"https://daracoin.io/metadata.json"))

;; Initial supply (1 billion tokens with 6 decimals)
(define-constant initial-supply u1000000000000000)

;; Data variables
(define-data-var token-supply uint u0)
(define-data-var contract-paused bool false)

;; Data maps
(define-map approved-minters principal bool)

;; Initialize the contract
(begin
  ;; Mint initial supply to contract owner
  (try! (ft-mint? daracoin initial-supply contract-owner))
  (var-set token-supply initial-supply)
  ;; Set contract owner as approved minter
  (map-set approved-minters contract-owner true)
)

;; SIP-010 trait implementation
(define-trait sip-010-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 32) uint))
    (get-decimals () (response uint uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)

;; Public functions

;; Transfer tokens
(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (not (var-get contract-paused)) (err u107))
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (is-eq from tx-sender) err-not-token-owner)
    (try! (ft-transfer? daracoin amount from to))
    (print {action: "transfer", from: from, to: to, amount: amount, memo: memo})
    (ok true)
  )
)

;; Mint new tokens (only approved minters)
(define-public (mint (amount uint) (to principal))
  (begin
    (asserts! (not (var-get contract-paused)) (err u107))
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (default-to false (map-get? approved-minters tx-sender)) err-owner-only)
    (try! (ft-mint? daracoin amount to))
    (var-set token-supply (+ (var-get token-supply) amount))
    (print {action: "mint", to: to, amount: amount})
    (ok true)
  )
)

;; Burn tokens
(define-public (burn (amount uint) (from principal))
  (begin
    (asserts! (not (var-get contract-paused)) (err u107))
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (is-eq from tx-sender) err-not-token-owner)
    (try! (ft-burn? daracoin amount from))
    (var-set token-supply (- (var-get token-supply) amount))
    (print {action: "burn", from: from, amount: amount})
    (ok true)
  )
)

;; Administrative functions

;; Add approved minter (owner only)
(define-public (add-minter (minter principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set approved-minters minter true)
    (print {action: "add-minter", minter: minter})
    (ok true)
  )
)

;; Remove approved minter (owner only)
(define-public (remove-minter (minter principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-delete approved-minters minter)
    (print {action: "remove-minter", minter: minter})
    (ok true)
  )
)

;; Pause contract (owner only)
(define-public (pause-contract)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set contract-paused true)
    (print {action: "pause-contract"})
    (ok true)
  )
)

;; Unpause contract (owner only)
(define-public (unpause-contract)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set contract-paused false)
    (print {action: "unpause-contract"})
    (ok true)
  )
)

;; SIP-010 required read-only functions

;; Get token name
(define-read-only (get-name)
  (ok token-name)
)

;; Get token symbol
(define-read-only (get-symbol)
  (ok token-symbol)
)

;; Get token decimals
(define-read-only (get-decimals)
  (ok token-decimals)
)

;; Get balance of a principal
(define-read-only (get-balance (who principal))
  (ok (ft-get-balance daracoin who))
)

;; Get total token supply
(define-read-only (get-total-supply)
  (ok (var-get token-supply))
)

;; Get token URI
(define-read-only (get-token-uri)
  (ok token-uri)
)

;; Additional read-only functions

;; Check if principal is approved minter
(define-read-only (is-minter (who principal))
  (default-to false (map-get? approved-minters who))
)

;; Check if contract is paused
(define-read-only (is-paused)
  (var-get contract-paused)
)

;; Get contract owner
(define-read-only (get-owner)
  contract-owner
)

;; title: daracoin
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps
;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

