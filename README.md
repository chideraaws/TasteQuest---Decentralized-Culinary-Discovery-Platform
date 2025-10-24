# TasteQuest - Decentralized Culinary Discovery Platform

A blockchain-based food platform built on Stacks that revolutionizes how food enthusiasts share recipes, track culinary adventures, and build communities around cooking.

## Overview

TasteQuest combines blockchain technology with culinary passion to create a decentralized platform where chefs and food lovers can:
- Create and share recipes with detailed instructions
- Log cooking attempts and track success rates
- Review and rate recipes from the community
- Participate in culinary challenges
- Build reputation through contributions
- Earn TasteQuest Flavor Tokens (TFT) for platform activities

## Core Features

### 🍳 Recipe Management
- Create detailed recipes with ingredients, instructions, prep/cook times
- Categorize recipes by cuisine type
- Set difficulty levels (1-5) and serving sizes
- Choose public or private visibility
- Track recipe success rates and average ratings

### 👨‍🍳 Chef Profiles
- Build your culinary identity with customizable profiles
- Track personal statistics (recipes created, dishes cooked, reviews written)
- Level up your chef status (1-10 levels)
- Earn reputation points through platform engagement
- Manage favorite cuisines and specializations

### 📊 Cooking Attempts Tracking
- Log detailed cooking attempts for any public recipe
- Record success/failure, actual cooking time, and difficulty experienced
- Add personal modifications and notes
- Upload photo hashes for visual documentation
- Track sharing activities with others

### ⭐ Recipe Review System
- Rate recipes on multiple dimensions (overall, taste, difficulty)
- Write detailed reviews (up to 800 characters)
- Indicate whether you successfully cooked the recipe
- Build credibility through helpful review contributions
- Cannot review your own recipes

### 🏆 Culinary Challenges
- Create community challenges with specific goals
- Multiple challenge types: ingredient-based, cuisine-focused, technique-driven, time-limited
- Set target recipe counts and duration
- Build reward pools for top performers
- Track participant progress and rankings

### 🥬 Ingredient Database
- Community-driven ingredient discovery
- Categorize ingredients (vegetable, protein, spice, grain)
- Track seasonal availability and rarity (1-5)
- Nutrition scoring (1-10)
- Monitor ingredient usage across recipes

### 🎨 Flavor Profiles
- Personalize your taste preferences (sweet, spicy, umami levels 1-10)
- Set texture preferences and dietary restrictions
- Define your culinary adventure level
- Enable better recipe recommendations

## Token Economics

### TasteQuest Flavor Token (TFT)
- **Symbol**: TFT
- **Decimals**: 6
- **Max Supply**: 2,800,000 TFT (2.8 million tokens)
- **Purpose**: Reward platform contributions and enable governance

### Reward Structure
| Activity | Reward Amount |
|----------|---------------|
| Recipe Creation | 55 TFT |
| Ingredient Discovery | 45 TFT |
| Cooking Attempt | 35 TFT |
| Recipe Review | 30 TFT |
| Challenge Completion | 120 TFT |

### Reputation System
Earn reputation points through various activities:
- Recipe creation: +15 points
- Successful cooking: +8 points
- Failed attempt: +3 points
- Writing reviews: +5 points
- Challenge creation: +30 points
- Ingredient discovery: +12 points

## Smart Contract Architecture

### Data Maps
- **chef-profiles**: User profiles with stats and reputation
- **recipes**: Recipe details with metadata and performance metrics
- **cooking-attempts**: Individual cooking logs with outcomes
- **recipe-reviews**: Multi-dimensional recipe ratings and feedback
- **culinary-challenges**: Community challenges with participation tracking
- **cuisine-categories**: Organized cuisine classifications
- **ingredients**: Community-maintained ingredient database
- **chef-specializations**: Expert status in specific cuisines
- **flavor-profiles**: Personalized taste preferences
- **token-balances**: TFT token holdings

### Key Functions

#### Recipe Operations
```clarity
(create-recipe title description cuisine-id difficulty prep-time cook-time servings ingredients instructions public)
(log-cooking-attempt recipe-id success cook-time difficulty mods photo notes shared)
(review-recipe recipe-id rating taste-rating difficulty-rating review-text cooked-successfully)
```

#### Profile Management
```clarity
(update-chef-username new-username)
(update-flavor-profile sweet spicy umami texture restrictions adventure)
```

#### Challenge System
```clarity
(create-culinary-challenge title description type target-recipes duration reward-pool)
```

#### Community Contributions
```clarity
(add-cuisine-category name origin-region difficulty popularity complexity)
(add-ingredient name category season rarity nutrition-score)
```

#### Token Operations
```clarity
(get-balance user)
(transfer amount sender recipient memo)
(get-total-supply)
```

### Read-Only Functions
- `get-chef-profile`: Retrieve user profile data
- `get-recipe`: Fetch recipe details
- `get-cooking-attempt`: View specific cooking logs
- `get-recipe-review`: Access review information
- `get-culinary-challenge`: Challenge details
- `get-ingredient`: Ingredient information
- `get-flavor-profile`: User taste preferences

## Error Codes

| Code | Error | Description |
|------|-------|-------------|
| u100 | err-owner-only | Action restricted to contract owner |
| u101 | err-not-found | Resource does not exist |
| u102 | err-already-exists | Resource already registered |
| u103 | err-unauthorized | Insufficient permissions |
| u104 | err-invalid-input | Invalid parameter values |
| u105 | err-insufficient-tokens | Not enough TFT balance |
| u106 | err-recipe-not-public | Recipe is private |
| u107 | err-invalid-rating | Rating outside valid range (1-5) |

## Getting Started

### Prerequisites
- Stacks wallet (Hiro Wallet, Xverse, etc.)
- STX tokens for transaction fees

### Deploying the Contract
```bash
clarinet contract deploy tastequest
```

### Creating Your Chef Profile
Your profile is automatically initialized on first interaction. Update your username:
```clarity
(contract-call? .tastequest update-chef-username "ChefMasterX")
```

### Creating Your First Recipe
```clarity
(contract-call? .tastequest create-recipe 
  "Spicy Thai Basil Chicken"
  "A quick and flavorful Thai stir-fry with holy basil"
  u1  ;; cuisine-category-id
  u3  ;; difficulty (medium)
  u15 ;; prep-time (15 minutes)
  u10 ;; cook-time (10 minutes)
  u4  ;; servings
  "chicken, thai basil, chilies, garlic, soy sauce, oyster sauce"
  "1. Prep ingredients. 2. Heat wok. 3. Stir-fry chicken. 4. Add sauce. 5. Toss with basil."
  true ;; public
)
```

## Use Cases

### For Home Cooks
- Discover new recipes from global cuisines
- Track your cooking journey and improvements
- Share your favorite family recipes
- Build a personal recipe collection
- Earn tokens for trying new dishes

### For Food Bloggers
- Monetize recipe creation through token rewards
- Build reputation in specific cuisines
- Engage with a dedicated foodie community
- Track recipe performance metrics
- Create challenges to boost engagement

### For Culinary Students
- Learn from diverse cooking experiences
- Document your culinary education
- Receive feedback from experienced cooks
- Participate in skill-building challenges
- Build a professional portfolio

### For Food Brands
- Sponsor culinary challenges
- Discover trending ingredients and recipes
- Engage with target audiences
- Support community initiatives
- Track ingredient popularity

## Security Considerations

- Only recipe creators can make recipes private
- Users cannot review their own recipes
- Challenge creation requires minimum reputation (250 points)
- Token minting is capped at max supply
- Transfer authorization verified through tx-sender
- All numeric inputs validated within acceptable ranges

## Roadmap

### Phase 1 (Current)
- ✅ Core recipe management
- ✅ Chef profiles and reputation
- ✅ Token rewards system
- ✅ Review and rating functionality

### Phase 2 (Planned)
- NFT recipe certificates for verified classics
- Advanced recommendation engine
- Social features (following, feed)
- Recipe collections and cookbooks
- Mobile app integration

### Phase 3 (Future)
- DAO governance for platform decisions
- Marketplace for premium recipes
- Chef certification programs
- Integration with food delivery services
- Virtual cooking classes

## Contributing

We welcome contributions from the community! Areas of interest:
- Additional cuisine categories
- Ingredient database expansion
- Recipe validation improvements
- UI/UX enhancements
- Documentation updates

## License

This project is licensed under the MIT License.

## Support

- Documentation: [docs.tastequest.io]
- Discord: [Join our community]
- Twitter: [@TasteQuestChef]
- Email: support@tastequest.io

## Acknowledgments

Built on the Stacks blockchain for true decentralization and user ownership. Special thanks to the culinary community for inspiring this platform.

---

**Cook. Share. Earn. Repeat.** 🍽️
