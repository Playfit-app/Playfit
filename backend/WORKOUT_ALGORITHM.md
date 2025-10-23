# Workout Exercise Generation Algorithm / Algorithme de Génération d'Exercices

## Overview / Aperçu

**English:**  
This document describes the intelligent workout exercise generation algorithm implemented in `workout/views.py`.

**Français:**  
Ce document décrit l'algorithme intelligent de génération d'exercices d'entraînement implémenté dans `workout/views.py`.

---

### Current Implementation (v1.0) / Implémentation Actuelle (v1.0)

**English:**  
The system currently uses 3 core exercises (pushUp, squat, jumpingJack) across all difficulty levels. Workout progression is achieved through:
- Dynamic rep count adjustments based on performance trends
- Three difficulty tiers (beginner, intermediate, advanced) with different target reps
- Intelligent progression algorithm that adapts to individual user performance

The architecture is designed to be easily extensible for additional exercises in future releases.

**Français:**  
Le système utilise actuellement 3 exercices de base (pushUp, squat, jumpingJack) pour tous les niveaux de difficulté. La progression de l'entraînement est réalisée par :
- Ajustements dynamiques du nombre de répétitions basés sur les tendances de performance
- Trois niveaux de difficulté (débutant, intermédiaire, avancé) avec des objectifs de répétitions différents
- Algorithme de progression intelligent qui s'adapte à la performance individuelle de l'utilisateur

L'architecture est conçue pour être facilement extensible pour des exercices supplémentaires dans les futures versions.

## Features / Fonctionnalités

### 1. **Consistent Exercise Count / Nombre d'Exercices Constant**

**English:**  
The algorithm generates the same 3 core exercises across all difficulty levels:
- **Beginner**: 3 exercises
- **Intermediate**: 3 exercises  
- **Advanced**: 3 exercises

The difficulty variation comes from the number of repetitions, not the number of exercises.

**Français:**  
L'algorithme génère les mêmes 3 exercices de base pour tous les niveaux de difficulté :
- **Débutant** : 3 exercices
- **Intermédiaire** : 3 exercices
- **Avancé** : 3 exercices

La variation de difficulté provient du nombre de répétitions, pas du nombre d'exercices.

---

### 2. **Exercise Pool Management / Gestion du Pool d'Exercices**

**English:**  
Currently using 3 core exercises across all fitness levels:
- **All Levels**: pushUp, squat, jumpingJack

*Note: The system is designed to be easily expandable. Additional exercises like plank and burpee can be added in future updates.*

**Français:**  
Utilise actuellement 3 exercices de base pour tous les niveaux de forme physique :
- **Tous les niveaux** : pushUp (pompes), squat, jumpingJack (jumping jack)

*Note : Le système est conçu pour être facilement extensible. Des exercices supplémentaires comme plank (planche) et burpee peuvent être ajoutés dans les futures mises à jour.*

### 3. **Dynamic Adaptive Progressive Overload / Surcharge Progressive Adaptative Dynamique**

**English:**  
The algorithm uses a **3-5 session average** with **trend-aware, rep-range-based progression rates**.

**Français:**  
L'algorithme utilise une **moyenne de 3-5 séances** avec des **taux de progression basés sur les tendances et la plage de répétitions**.

---

#### First Session (Default Values) / Première Séance (Valeurs par Défaut)

**English:**  
For users with no workout history, the algorithm uses predefined starting values for the 3 core exercises:

**Français:**  
Pour les utilisateurs sans historique d'entraînement, l'algorithme utilise des valeurs de départ prédéfinies pour les 3 exercices de base :

| Exercise / Exercice | Beginner / Débutant | Intermediate / Intermédiaire | Advanced / Avancé |
|---------------------|---------------------|------------------------------|-------------------|
| pushUp (pompes) | 5 reps / rép. | 10 reps / rép. | 15 reps / rép. |
| squat | 10 reps / rép. | 15 reps / rép. | 25 reps / rép. |
| jumpingJack | 15 reps / rép. | 25 reps / rép. | 40 reps / rép. |

---

#### Subsequent Sessions (Performance-Based with Trend Analysis) / Séances Suivantes (Basées sur la Performance avec Analyse de Tendance)

**English:**  
For returning users:
- The algorithm retrieves the **last 3-5 completed performances** for each exercise at each difficulty level
- Calculates the **average repetitions** from these sessions to smooth out variations
- **Analyzes performance trend** by comparing recent vs older performances
- Applies **dynamic progressive overload** based on rep range AND performance trend

**Français:**  
Pour les utilisateurs réguliers :
- L'algorithme récupère les **3-5 dernières performances complétées** pour chaque exercice à chaque niveau de difficulté
- Calcule la **moyenne des répétitions** de ces séances pour lisser les variations
- **Analyse la tendance de performance** en comparant les performances récentes et anciennes
- Applique une **surcharge progressive dynamique** basée sur la plage de répétitions ET la tendance de performance

---

**Base Progression Rates by Rep Range / Taux de Progression de Base par Plage de Répétitions:**

| Rep Range / Plage | Base Rate / Taux de Base | Example / Exemple | Rationale / Justification (EN/FR) |
|-------------------|--------------------------|-------------------|-----------------------------------|
| ≤5 reps / rép. | 20% | 5 → 6 | Low reps need absolute increase / Les faibles rép. nécessitent une augmentation absolue |
| 6-10 reps / rép. | 15% | 10 → 11-12 | Moderate increase for strength / Augmentation modérée pour la force |
| 11-20 reps / rép. | 10% | 15 → 16-17 | Balanced progression / Progression équilibrée |
| >20 reps / rép. | 5% | 40 → 42 | Smaller increases for endurance / Augmentations plus petites pour l'endurance |

---

**Dynamic Rate Adjustment Based on Performance Trend / Ajustement Dynamique du Taux Basé sur la Tendance de Performance:**

| Trend / Tendance | Adjustment / Ajustement | Effective Rate / Taux Effectif (10% base) | When to Use / Quand l'utiliser |
|------------------|-------------------------|-------------------------------------------|-------------------------------|
| Strong Improvement / Forte amélioration (>10%) | +50% | 15% | User beating targets / Utilisateur dépasse les objectifs |
| Moderate Improvement / Amélioration modérée (5-10%) | +25% | 12.5% | User progressing / Utilisateur progresse |
| Stable (±5%) | No change / Aucun changement | 10% | User maintaining / Utilisateur maintient |
| Slight Decline / Légère baisse (<0%) | -15% | 8.5% | User struggling / Utilisateur en difficulté |
| Strong Decline / Forte baisse (<-5%) | -30% | 7% | User needs rest / Utilisateur a besoin de repos |

---

**Key Features / Caractéristiques Clés:**

**English:**
- **Trend-Aware**: Recognizes when users are improving and pushes them harder
- **Self-Regulating**: Backs off when users are struggling or plateauing
- **Personalized**: Each exercise progresses at its own rate based on individual performance
- **Injury Prevention**: Reduces progression rate if performance is declining
- **Motivation**: Rewards consistent improvement with faster progression
- **Smart Recovery**: Allows consolidation periods when needed

**Français:**
- **Sensible aux tendances** : Reconnaît quand les utilisateurs s'améliorent et les pousse plus fort
- **Auto-régulé** : Se retire quand les utilisateurs ont des difficultés ou stagnent
- **Personnalisé** : Chaque exercice progresse à son propre rythme basé sur la performance individuelle
- **Prévention des blessures** : Réduit le taux de progression si la performance décline
- **Motivation** : Récompense l'amélioration constante avec une progression plus rapide
- **Récupération intelligente** : Permet des périodes de consolidation si nécessaire

---

### 4. **User Fitness Level Integration / Intégration du Niveau de Forme Physique**

**English:**  
The algorithm respects the user's `fitness_level` field from their profile:
- Uses the appropriate exercise pool based on their level
- Can be set to: `beginner`, `intermediate`, or `advanced`

**Français:**  
L'algorithme respecte le champ `fitness_level` du profil de l'utilisateur :
- Utilise le pool d'exercices approprié selon leur niveau
- Peut être défini comme : `beginner` (débutant), `intermediate` (intermédiaire), ou `advanced` (avancé)

## Implementation Details / Détails d'Implémentation

### Function / Fonction: `generate_workout_exercises(user, workout_session)`

**Parameters / Paramètres:**

**English:**
- `user`: The CustomUser instance
- `workout_session`: The WorkoutSession instance to populate with exercises

**Français:**
- `user` : L'instance CustomUser
- `workout_session` : L'instance WorkoutSession à remplir avec les exercices

**Logic Flow:**
1. Determine user's fitness level from profile
2. Select exercise pool (currently same 3 exercises for all levels)
3. For each difficulty level (beginner, intermediate, advanced):
   - Use all 3 core exercises (pushUp, squat, jumpingJack)
   - For each exercise:
     - **Query `WorkoutSessionExercise` directly** to retrieve the last 3-5 completed performances for this specific exercise and difficulty
     - If found:
       - Calculate average reps from all performances
       - Analyze performance trend (recent vs older performances)
       - Determine base progression rate from rep range
       - Adjust rate based on trend (+50% to -30%)
       - Apply dynamic progressive overload
       - Ensure minimum +1 rep (if trending positive)
     - If not found: Use default starting values
   - Create WorkoutSessionExercise record

**Decision Tree for Progression Rate:**
```
[Get Recent Performances]
        ↓
[Calculate Average Reps]
        ↓
[Analyze Trend: Compare Recent vs Older]
        ↓
[Determine Base Rate]
   ≤5 reps    → 20%
   6-10 reps  → 15%
   11-20 reps → 10%
   >20 reps   → 5%
        ↓
[Adjust Rate Based on Trend]
   Strong Up (>10%)    → Base × 1.5
   Moderate Up (5-10%) → Base × 1.25
   Stable (±5%)        → Base × 1.0
   Slight Down (<0%)   → Base × 0.85
   Strong Down (<-5%)  → Base × 0.7
        ↓
[Apply: avg_reps × (1 + adjusted_rate)]
        ↓
[Ensure: min +1 rep if not declining]
```

**Important Note on Data Retrieval:**
The algorithm queries `WorkoutSessionExercise` records directly (not just `WorkoutSession`) because:
- Performance data (sets, reps, weight) is stored in `WorkoutSessionExercise`
- Each exercise can have different performance at different difficulty levels
- This allows precise tracking: "What has the user's recent performance been for pushUps at intermediate difficulty?"

**Multi-Performance Analysis:**
The algorithm retrieves up to 5 recent performances (ordered by most recent first):
```python
recent_performances = WorkoutSessionExercise.objects.filter(
    workout_session__user=user,
    workout_session__completed_date__isnull=False,
    exercise=exercise,
    difficulty=difficulty
).order_by('-workout_session__completed_date')[:5]
```

Benefits of averaging 3-5 performances:
- **Stability**: Prevents wild swings from one exceptional or poor performance
- **Accuracy**: Better represents user's current fitness level
- **Fairness**: Accounts for variations in daily energy, motivation, and conditions
- **Progressive**: Still allows for steady improvement through 10% increases

### Integration
The function is called in `WorkoutSessionExerciseView.get()` when:
- A new workout session needs to be generated
- User requests exercises for their current position (city/transition)
- No existing workout session exists for that position

## Example Data Flow

### Scenario: User's Performance Over Multiple Weeks

**Weeks 1-4 (Completed):**
```
WorkoutSession #1 (completed_date: 2025-09-25)
  └─ WorkoutSessionExercise:
      - exercise: pushUp, difficulty: beginner, reps: 10, sets: 1
      
WorkoutSession #2 (completed_date: 2025-10-02)
  └─ WorkoutSessionExercise:
      - exercise: pushUp, difficulty: beginner, reps: 12, sets: 1
      
WorkoutSession #3 (completed_date: 2025-10-09)
  └─ WorkoutSessionExercise:
      - exercise: pushUp, difficulty: beginner, reps: 11, sets: 1
      
WorkoutSession #4 (completed_date: 2025-10-16)
  └─ WorkoutSessionExercise:
      - exercise: pushUp, difficulty: beginner, reps: 13, sets: 1
```

**Week 5 (New Generation - October 23, 2025):**
```python
# Algorithm queries last 3-5 performances:
recent_performances = WorkoutSessionExercise.objects.filter(
    workout_session__user=user,
    workout_session__completed_date__isnull=False,
    exercise=pushUp,
    difficulty='beginner'
).order_by('-workout_session__completed_date')[:5]
# Returns: [13, 11, 12, 10] reps (most recent first)

# Calculates average: (13 + 11 + 12 + 10) / 4 = 11.5 reps
# Applies adaptive progressive overload:
# 11.5 reps falls in 11-20 range → use 10% increase
# 11.5 * 1.10 = 12.65 → int(12.65) = 12 reps
```

**Generated Workout Session #5:**
```
WorkoutSession #5 (creation_date: 2025-10-23)
  └─ WorkoutSessionExercise:
      - exercise: pushUp, difficulty: beginner, reps: 12, sets: 1
      
# This is reasonable because:
# - User's recent average was 11.5 reps
# - User has done 12 and 13 reps recently, so 12 is achievable
# - Not jumping to 14 reps based solely on one great performance of 13
```

### Additional Examples with Trend Analysis

**Example 1: Strong Improvement Trend**
```
User's last 4 push-up sessions: [10, 11, 12, 13] reps
Average: 11.5 reps
Recent avg (12, 13): 12.5 reps
Older avg (10, 11): 10.5 reps
Trend: (12.5 - 10.5) / 10.5 = +19% (strong improvement!)

Base rate for 11-20 reps: 10%
Adjusted rate: 10% * 1.5 = 15% (due to strong improvement)
New target: 11.5 * 1.15 = 13.2 → 13 reps

Result: User was consistently improving, so we challenge them more!
```

**Example 2: Declining Performance**
```
User's last 4 squat sessions: [20, 18, 17, 16] reps
Average: 17.75 reps
Recent avg (17, 16): 16.5 reps
Older avg (20, 18): 19 reps
Trend: (16.5 - 19) / 19 = -13% (declining performance)

Base rate for 11-20 reps: 10%
Adjusted rate: 10% * 0.7 = 7% (reduced due to decline)
New target: 17.75 * 1.07 = 19.0 → 19 reps

Result: User is struggling, so we ease the progression to allow recovery.
```

**Example 3: Stable Performance**
```
User's last 4 jumping jack sessions: [40, 41, 40, 41] reps
Average: 40.5 reps
Recent avg (40, 41): 40.5 reps
Older avg (40, 41): 40.5 reps
Trend: (40.5 - 40.5) / 40.5 = 0% (stable)

Base rate for >20 reps: 5%
Adjusted rate: 5% (no adjustment for stable performance)
New target: 40.5 * 1.05 = 42.5 → 42 reps

Result: Steady, reliable progression for a stable performer.
```

**Example 4: Low Reps with Improvement**
```
User's last 3 pushUp sessions (beginner difficulty): [4, 5, 5] reps
Average: 4.67 reps
Recent avg (5, 5): 5 reps
Older avg (4): 4 reps
Trend: (5 - 4) / 4 = +25% (strong improvement!)

Base rate for ≤5 reps: 20%
Adjusted rate: 20% * 1.5 = 30%
New target: 4.67 * 1.30 = 6.07 → 6 reps

Result: User improving on difficult exercise, so we push harder.
```

## Benefits / Avantages

### Core Features / Fonctionnalités de Base

**English / Français:**
1. **Personalized / Personnalisé**: Adapts to individual fitness level / S'adapte au niveau de forme individuel
2. **Progressive / Progressif**: Automatically increases difficulty / Augmente automatiquement la difficulté
3. **Scalable / Évolutif**: Easy to add exercises / Facile d'ajouter des exercices
4. **Consistent / Cohérent**: Reliable starting points / Points de départ fiables
5. **Accurate / Précis**: Tracks at exercise level / Suivi au niveau de l'exercice

### Statistical Intelligence / Intelligence Statistique

**English / Français:**
6. **Stable**: Uses 3-5 performance average / Utilise une moyenne de 3-5 performances
7. **Intelligent**: Distinguishes peaks from sustained capability / Distingue les pics de la capacité soutenue
8. **Fair / Équitable**: Doesn't punish off-days / Ne pénalise pas les mauvais jours
9. **Data-Driven / Basé sur les données**: Uses statistical trends / Utilise les tendances statistiques

### Dynamic Adaptation / Adaptation Dynamique

**English / Français:**
10. **Trend-Aware / Sensible aux tendances**: Recognizes patterns / Reconnaît les motifs
11. **Self-Regulating / Auto-régulé**: Backs off when struggling / Se retire en cas de difficulté
12. **Responsive / Réactif**: Accelerates for excellence / Accélère pour l'excellence
13. **Protective / Protecteur**: Reduces load when declining / Réduit la charge en cas de baisse
14. **Motivating / Motivant**: Rewards improvement / Récompense l'amélioration

### Exercise-Specific Optimization / Optimisation Spécifique aux Exercices

**English / Français:**
15. **Context-Aware / Contextuel**: Different rates for strength vs endurance / Taux différents force vs endurance
16. **Prevents Plateaus / Évite les plateaux**: Meaningful progression / Progression significative
17. **Sustainable / Durable**: Prevents burnout / Évite l'épuisement
18. **Exercise-Independent / Indépendant**: Each progresses optimally / Chacun progresse de manière optimale

## Future Enhancements / Améliorations Futures

### Planned Exercise Expansion / Extension Planifiée des Exercices

**English:**
- **Phase 2**: Add intermediate-level exercises (e.g., plank, lunges)
- **Phase 3**: Add advanced-level exercises (e.g., burpee, mountain climbers)
- **Dynamic Exercise Selection**: Different exercise counts based on difficulty:
  - Beginner: 3 exercises
  - Intermediate: 4 exercises
  - Advanced: 5 exercises

**Français:**
- **Phase 2** : Ajouter des exercices de niveau intermédiaire (ex: planche, fentes)
- **Phase 3** : Ajouter des exercices de niveau avancé (ex: burpee, mountain climbers)
- **Sélection Dynamique d'Exercices** : Nombre d'exercices différent selon la difficulté :
  - Débutant : 3 exercices
  - Intermédiaire : 4 exercices
  - Avancé : 5 exercices

---

### Additional Features / Fonctionnalités Supplémentaires

**English:**  
Potential improvements could include:
- Adjustable progressive overload percentage based on user goals
- Rest period calculations
- Exercise variety rotation to prevent plateaus
- Integration with user's physical particularities
- Machine learning to predict optimal rep ranges
- Time-based exercises (e.g., plank duration)
- Sets progression in addition to reps
- Weight/resistance tracking for exercises

**Français:**  
Les améliorations potentielles pourraient inclure :
- Pourcentage de surcharge progressive ajustable selon les objectifs
- Calculs des périodes de repos
- Rotation de variété d'exercices pour éviter les plateaux
- Intégration avec les particularités physiques de l'utilisateur
- Apprentissage automatique pour prédire les plages de répétitions optimales
- Exercices basés sur le temps (ex: durée de planche)
- Progression des séries en plus des répétitions
- Suivi du poids/résistance pour les exercices
