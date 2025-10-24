;; TasteQuest - Decentralized Culinary Discovery Platform
;; A comprehensive blockchain-based food platform that tracks culinary adventures,
;; rewards recipe sharing, and builds foodie communities

;; Contract constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))
(define-constant err-insufficient-tokens (err u105))
(define-constant err-recipe-not-public (err u106))
(define-constant err-invalid-rating (err u107))

;; Token constants
(define-constant token-name "TasteQuest Flavor Token")
(define-constant token-symbol "TFT")
(define-constant token-decimals u6)
(define-constant token-max-supply u2800000000000) ;; 2.8 million tokens with 6 decimals

;; Reward amounts (in micro-tokens)
(define-constant reward-recipe-creation u55000000) ;; 55 TFT
(define-constant reward-cooking-attempt u35000000) ;; 35 TFT
(define-constant reward-review-creation u30000000) ;; 30 TFT
(define-constant reward-challenge-completion u120000000) ;; 120 TFT
(define-constant reward-ingredient-discovery u45000000) ;; 45 TFT

;; Data variables
(define-data-var total-supply uint u0)
(define-data-var next-recipe-id uint u1)
(define-data-var next-challenge-id uint u1)
(define-data-var next-review-id uint u1)

;; Token balances
(define-map token-balances principal uint)

;; Cuisine categories
(define-map cuisine-categories
  uint
  {
    name: (string-ascii 32),
    origin-region: (string-ascii 32),
    difficulty-level: uint, ;; 1-5
    popularity-score: uint, ;; 1-10
    ingredient-complexity: uint, ;; 1-5
    verified: bool
  }
)

;; Chef profiles
(define-map chef-profiles
  principal
  {
    username: (string-ascii 32),
    chef-level: uint, ;; 1-10
    recipes-created: uint,
    dishes-cooked: uint,
    reviews-written: uint,
    challenges-completed: uint,
    favorite-cuisines: (list 3 uint),
    reputation-score: uint,
    join-date: uint,
    last-activity: uint
  }
)

;; Recipe registry
(define-map recipes
  uint
  {
    creator: principal,
    title: (string-ascii 128),
    description: (string-ascii 500),
    cuisine-category-id: uint,
    difficulty: uint, ;; 1-5
    prep-time-minutes: uint,
    cook-time-minutes: uint,
    servings: uint,
    ingredients: (string-ascii 1000),
    instructions: (string-ascii 2000),
    public: bool,
    total-attempts: uint,
    success-rate: uint,
    average-rating: uint,
    creation-date: uint
  }
)

;; Cooking attempts
(define-map cooking-attempts
  { chef: principal, recipe-id: uint, attempt-date: uint }
  {
    success: bool,
    actual-cook-time: uint,
    difficulty-experienced: uint, ;; 1-5
    modifications: (string-ascii 300),
    photo-hash: (optional (buff 32)),
    notes: (string-ascii 500),
    shared-with-others: bool
  }
)

;; Recipe reviews
(define-map recipe-reviews
  uint
  {
    recipe-id: uint,
    reviewer: principal,
    rating: uint, ;; 1-5 stars
    taste-rating: uint, ;; 1-5
    difficulty-rating: uint, ;; 1-5
    review-text: (string-ascii 800),
    cooked-successfully: bool,
    timestamp: uint,
    helpful-votes: uint
  }
)

;; Culinary challenges
(define-map culinary-challenges
  uint
  {
    creator: principal,
    title: (string-ascii 128),
    description: (string-ascii 500),
    challenge-type: (string-ascii 32), ;; "ingredient", "cuisine", "technique", "time"
    target-recipes: uint,
    duration-days: uint,
    participants: uint,
    start-date: uint,
    end-date: uint,
    reward-pool: uint,
    active: bool
  }
)

;; Challenge participants
(define-map challenge-participants
  { challenge-id: uint, participant: principal }
  {
    join-date: uint,
    recipes-completed: uint,
    attempts-made: uint,
    success-rate: uint,
    final-rank: (optional uint),
    completed: bool
  }
)

;; Ingredient database
(define-map ingredients
  uint
  {
    name: (string-ascii 64),
    category: (string-ascii 32), ;; "vegetable", "protein", "spice", "grain"
    season: (string-ascii 16), ;; "spring", "summer", "fall", "winter", "year-round"
    rarity: uint, ;; 1-5
    nutrition-score: uint, ;; 1-10
    added-by: principal,
    usage-count: uint,
    verified: bool
  }
)

;; Chef specializations
(define-map chef-specializations
  { chef: principal, cuisine-id: uint }
  {
    expertise-level: uint, ;; 1-10
    recipes-in-cuisine: uint,
    success-rate: uint,
    recognition-date: uint,
    verified: bool
  }
)

;; Flavor profiles
(define-map flavor-profiles
  { chef: principal }
  {
    sweet-preference: uint, ;; 1-10
    spicy-tolerance: uint, ;; 1-10
    umami-appreciation: uint, ;; 1-10
    texture-preference: (string-ascii 32),
    dietary-restrictions: (string-ascii 100),
    adventure-level: uint ;; 1-10
  }
)

;; Helper function to get or create chef profile
(define-private (get-or-create-profile (chef principal))
  (match (map-get? chef-profiles chef)
    profile profile
    {
      username: "",
      chef-level: u1,
      recipes-created: u0,
      dishes-cooked: u0,
      reviews-written: u0,
      challenges-completed: u0,
      favorite-cuisines: (list),
      reputation-score: u100,
      join-date: stacks-block-height,
      last-activity: stacks-block-height
    }
  )
)

;; Token functions
(define-read-only (get-name)
  (ok token-name)
)

(define-read-only (get-symbol)
  (ok token-symbol)
)

(define-read-only (get-decimals)
  (ok token-decimals)
)

(define-read-only (get-balance (user principal))
  (ok (default-to u0 (map-get? token-balances user)))
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-private (mint-tokens (recipient principal) (amount uint))
  (let (
    (current-balance (default-to u0 (map-get? token-balances recipient)))
    (new-balance (+ current-balance amount))
    (new-total-supply (+ (var-get total-supply) amount))
  )
    (asserts! (<= new-total-supply token-max-supply) err-invalid-input)
    (map-set token-balances recipient new-balance)
    (var-set total-supply new-total-supply)
    (ok amount)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (let (
    (sender-balance (default-to u0 (map-get? token-balances sender)))
  )
    (asserts! (is-eq tx-sender sender) err-unauthorized)
    (asserts! (>= sender-balance amount) err-insufficient-tokens)
    (try! (mint-tokens recipient amount))
    (map-set token-balances sender (- sender-balance amount))
    (print {action: "transfer", sender: sender, recipient: recipient, amount: amount, memo: memo})
    (ok true)
  )
)

;; Cuisine category management
(define-public (add-cuisine-category (name (string-ascii 32)) (origin-region (string-ascii 32))
                                    (difficulty-level uint) (popularity-score uint) (ingredient-complexity uint))
  (let (
    (category-id (var-get next-recipe-id))
  )
    (asserts! (> (len name) u0) err-invalid-input)
    (asserts! (> (len origin-region) u0) err-invalid-input)
    (asserts! (and (>= difficulty-level u1) (<= difficulty-level u5)) err-invalid-input)
    (asserts! (and (>= popularity-score u1) (<= popularity-score u10)) err-invalid-input)
    (asserts! (and (>= ingredient-complexity u1) (<= ingredient-complexity u5)) err-invalid-input)
    
    (map-set cuisine-categories category-id {
      name: name,
      origin-region: origin-region,
      difficulty-level: difficulty-level,
      popularity-score: popularity-score,
      ingredient-complexity: ingredient-complexity,
      verified: false
    })
    
    (var-set next-recipe-id (+ category-id u1))
    (print {action: "cuisine-category-added", category-id: category-id, name: name})
    (ok category-id)
  )
)

;; Recipe creation
(define-public (create-recipe (title (string-ascii 128)) (description (string-ascii 500))
                             (cuisine-category-id uint) (difficulty uint) (prep-time uint) (cook-time uint)
                             (servings uint) (ingredient-list (string-ascii 1000)) (instructions (string-ascii 2000)) (public bool))
  (let (
    (recipe-id (var-get next-recipe-id))
    (cuisine-category (unwrap! (map-get? cuisine-categories cuisine-category-id) err-not-found))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len title) u0) err-invalid-input)
    (asserts! (> (len description) u0) err-invalid-input)
    (asserts! (and (>= difficulty u1) (<= difficulty u5)) err-invalid-input)
    (asserts! (> prep-time u0) err-invalid-input)
    (asserts! (> cook-time u0) err-invalid-input)
    (asserts! (> servings u0) err-invalid-input)
    (asserts! (> (len ingredient-list) u0) err-invalid-input)
    (asserts! (> (len instructions) u0) err-invalid-input)
    
    (map-set recipes recipe-id {
      creator: tx-sender,
      title: title,
      description: description,
      cuisine-category-id: cuisine-category-id,
      difficulty: difficulty,
      prep-time-minutes: prep-time,
      cook-time-minutes: cook-time,
      servings: servings,
      ingredients: ingredient-list,
      instructions: instructions,
      public: public,
      total-attempts: u0,
      success-rate: u0,
      average-rating: u0,
      creation-date: stacks-block-height
    })
    
    ;; Update chef profile
    (map-set chef-profiles tx-sender
      (merge profile {
        recipes-created: (+ (get recipes-created profile) u1),
        reputation-score: (+ (get reputation-score profile) u15),
        last-activity: stacks-block-height
      })
    )
    
    ;; Award recipe creation reward
    (try! (mint-tokens tx-sender reward-recipe-creation))
    
    (var-set next-recipe-id (+ recipe-id u1))
    (print {action: "recipe-created", recipe-id: recipe-id, creator: tx-sender, title: title})
    (ok recipe-id)
  )
)

;; Cooking attempt logging
(define-public (log-cooking-attempt (recipe-id uint) (success bool) (actual-cook-time uint)
                                   (difficulty-experienced uint) (modifications (string-ascii 300))
                                   (photo-hash (optional (buff 32))) (notes (string-ascii 500)) (shared bool))
  (let (
    (recipe (unwrap! (map-get? recipes recipe-id) err-not-found))
    (attempt-date (/ stacks-block-height u144)) ;; Daily grouping
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (or (get public recipe) (is-eq tx-sender (get creator recipe))) err-recipe-not-public)
    (asserts! (> actual-cook-time u0) err-invalid-input)
    (asserts! (and (>= difficulty-experienced u1) (<= difficulty-experienced u5)) err-invalid-input)
    
    (map-set cooking-attempts {chef: tx-sender, recipe-id: recipe-id, attempt-date: attempt-date} {
      success: success,
      actual-cook-time: actual-cook-time,
      difficulty-experienced: difficulty-experienced,
      modifications: modifications,
      photo-hash: photo-hash,
      notes: notes,
      shared-with-others: shared
    })
    
    ;; Update recipe statistics
    (let (
      (new-attempts (+ (get total-attempts recipe) u1))
      (success-count (if success (+ (/ (* (get success-rate recipe) (get total-attempts recipe)) u100) u1)
                                (/ (* (get success-rate recipe) (get total-attempts recipe)) u100)))
      (new-success-rate (if (> new-attempts u0) (/ (* success-count u100) new-attempts) u0))
    )
      (map-set recipes recipe-id
        (merge recipe {
          total-attempts: new-attempts,
          success-rate: new-success-rate
        })
      )
    )
    
    ;; Update chef profile
    (map-set chef-profiles tx-sender
      (merge profile {
        dishes-cooked: (+ (get dishes-cooked profile) u1),
        reputation-score: (+ (get reputation-score profile) (if success u8 u3)),
        last-activity: stacks-block-height
      })
    )
    
    ;; Award cooking attempt reward
    (try! (mint-tokens tx-sender reward-cooking-attempt))
    
    (print {action: "cooking-attempt-logged", chef: tx-sender, recipe-id: recipe-id, success: success})
    (ok true)
  )
)

;; Recipe review system
(define-public (review-recipe (recipe-id uint) (rating uint) (taste-rating uint) (difficulty-rating uint)
                             (review-text (string-ascii 800)) (cooked-successfully bool))
  (let (
    (recipe (unwrap! (map-get? recipes recipe-id) err-not-found))
    (review-id (var-get next-review-id))
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (get public recipe) err-recipe-not-public)
    (asserts! (not (is-eq tx-sender (get creator recipe))) err-unauthorized)
    (asserts! (and (>= rating u1) (<= rating u5)) err-invalid-rating)
    (asserts! (and (>= taste-rating u1) (<= taste-rating u5)) err-invalid-rating)
    (asserts! (and (>= difficulty-rating u1) (<= difficulty-rating u5)) err-invalid-rating)
    (asserts! (> (len review-text) u0) err-invalid-input)
    
    (map-set recipe-reviews review-id {
      recipe-id: recipe-id,
      reviewer: tx-sender,
      rating: rating,
      taste-rating: taste-rating,
      difficulty-rating: difficulty-rating,
      review-text: review-text,
      cooked-successfully: cooked-successfully,
      timestamp: stacks-block-height,
      helpful-votes: u0
    })
    
    ;; Update recipe average rating
    (let (
      (current-avg (get average-rating recipe))
      (review-count (+ (/ (* current-avg u10) u5) u1)) ;; Simplified calculation
      (new-avg (/ (+ (* current-avg (- review-count u1)) rating) review-count))
    )
      (map-set recipes recipe-id (merge recipe {average-rating: new-avg}))
    )
    
    ;; Update reviewer profile
    (map-set chef-profiles tx-sender
      (merge profile {
        reviews-written: (+ (get reviews-written profile) u1),
        reputation-score: (+ (get reputation-score profile) u5),
        last-activity: stacks-block-height
      })
    )
    
    ;; Award review reward
    (try! (mint-tokens tx-sender reward-review-creation))
    
    (var-set next-review-id (+ review-id u1))
    (print {action: "recipe-reviewed", review-id: review-id, recipe-id: recipe-id, reviewer: tx-sender})
    (ok review-id)
  )
)

;; Culinary challenge creation
(define-public (create-culinary-challenge (title (string-ascii 128)) (description (string-ascii 500))
                                         (challenge-type (string-ascii 32)) (target-recipes uint)
                                         (duration-days uint) (reward-pool uint))
  (let (
    (challenge-id (var-get next-challenge-id))
    (creator-profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len title) u0) err-invalid-input)
    (asserts! (> (len description) u0) err-invalid-input)
    (asserts! (> target-recipes u0) err-invalid-input)
    (asserts! (> duration-days u0) err-invalid-input)
    (asserts! (>= (get reputation-score creator-profile) u250) err-unauthorized)
    
    (map-set culinary-challenges challenge-id {
      creator: tx-sender,
      title: title,
      description: description,
      challenge-type: challenge-type,
      target-recipes: target-recipes,
      duration-days: duration-days,
      participants: u0,
      start-date: stacks-block-height,
      end-date: (+ stacks-block-height duration-days),
      reward-pool: reward-pool,
      active: true
    })
    
    ;; Update creator reputation
    (map-set chef-profiles tx-sender
      (merge creator-profile {
        reputation-score: (+ (get reputation-score creator-profile) u30),
        last-activity: stacks-block-height
      })
    )
    
    (var-set next-challenge-id (+ challenge-id u1))
    (print {action: "culinary-challenge-created", challenge-id: challenge-id, creator: tx-sender})
    (ok challenge-id)
  )
)

;; Ingredient discovery
(define-public (add-ingredient (name (string-ascii 64)) (category (string-ascii 32)) (season (string-ascii 16))
                              (rarity uint) (nutrition-score uint))
  (let (
    (ingredient-id (var-get next-challenge-id)) ;; Reuse counter
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len name) u0) err-invalid-input)
    (asserts! (> (len category) u0) err-invalid-input)
    (asserts! (and (>= rarity u1) (<= rarity u5)) err-invalid-input)
    (asserts! (and (>= nutrition-score u1) (<= nutrition-score u10)) err-invalid-input)
    
    (map-set ingredients ingredient-id {
      name: name,
      category: category,
      season: season,
      rarity: rarity,
      nutrition-score: nutrition-score,
      added-by: tx-sender,
      usage-count: u0,
      verified: false
    })
    
    ;; Award ingredient discovery reward
    (try! (mint-tokens tx-sender reward-ingredient-discovery))
    
    ;; Update profile
    (map-set chef-profiles tx-sender
      (merge profile {
        reputation-score: (+ (get reputation-score profile) u12),
        last-activity: stacks-block-height
      })
    )
    
    (var-set next-challenge-id (+ ingredient-id u1))
    (print {action: "ingredient-added", ingredient-id: ingredient-id, name: name, added-by: tx-sender})
    (ok ingredient-id)
  )
)

;; Flavor profile management
(define-public (update-flavor-profile (sweet uint) (spicy uint) (umami uint)
                                     (texture (string-ascii 32)) (restrictions (string-ascii 100)) (adventure uint))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (and (>= sweet u1) (<= sweet u10)) err-invalid-input)
    (asserts! (and (>= spicy u1) (<= spicy u10)) err-invalid-input)
    (asserts! (and (>= umami u1) (<= umami u10)) err-invalid-input)
    (asserts! (and (>= adventure u1) (<= adventure u10)) err-invalid-input)
    
    (map-set flavor-profiles {chef: tx-sender} {
      sweet-preference: sweet,
      spicy-tolerance: spicy,
      umami-appreciation: umami,
      texture-preference: texture,
      dietary-restrictions: restrictions,
      adventure-level: adventure
    })
    
    ;; Update profile
    (map-set chef-profiles tx-sender (merge profile {last-activity: stacks-block-height}))
    
    (print {action: "flavor-profile-updated", chef: tx-sender})
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-chef-profile (chef principal))
  (map-get? chef-profiles chef)
)

(define-read-only (get-cuisine-category (category-id uint))
  (map-get? cuisine-categories category-id)
)

(define-read-only (get-recipe (recipe-id uint))
  (map-get? recipes recipe-id)
)

(define-read-only (get-cooking-attempt (chef principal) (recipe-id uint) (attempt-date uint))
  (map-get? cooking-attempts {chef: chef, recipe-id: recipe-id, attempt-date: attempt-date})
)

(define-read-only (get-recipe-review (review-id uint))
  (map-get? recipe-reviews review-id)
)

(define-read-only (get-culinary-challenge (challenge-id uint))
  (map-get? culinary-challenges challenge-id)
)

(define-read-only (get-ingredient (ingredient-id uint))
  (map-get? ingredients ingredient-id)
)

(define-read-only (get-chef-specialization (chef principal) (cuisine-id uint))
  (map-get? chef-specializations {chef: chef, cuisine-id: cuisine-id})
)

(define-read-only (get-flavor-profile (chef principal))
  (map-get? flavor-profiles {chef: chef})
)

;; Admin functions
(define-public (verify-cuisine-category (category-id uint))
  (let (
    (category (unwrap! (map-get? cuisine-categories category-id) err-not-found))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set cuisine-categories category-id (merge category {verified: true}))
    (print {action: "cuisine-category-verified", category-id: category-id})
    (ok true)
  )
)

(define-public (update-chef-username (new-username (string-ascii 32)))
  (let (
    (profile (get-or-create-profile tx-sender))
  )
    (asserts! (> (len new-username) u0) err-invalid-input)
    (map-set chef-profiles tx-sender (merge profile {username: new-username}))
    (print {action: "chef-username-updated", chef: tx-sender, username: new-username})
    (ok true)
  )
)