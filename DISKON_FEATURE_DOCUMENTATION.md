# CRUD Diskon Menu - Implementation Documentation

## Overview

Implementation of complete CRUD operations for discount management system where discounts are scoped per canteen (stanId). Students can see discounted prices when browsing menus.

## Architecture - Clean Architecture Pattern

### Domain Layer (`lib/features/diskon/domain/`)

#### Entities

1. **`diskon.dart`** - Core discount entity
   - Fields: `id`, `stanId`, `namaDiskon`, `persentaseDiskon`, `tanggalAwal`, `tanggalAkhir`
   - Computed: `isValid`, `isExpired`
   - **Key Feature**: `stanId` field ensures discounts only apply to specific canteen

2. **`menu_diskon.dart`** - Junction table entity for many-to-many relationship
   - Links Menu items to Discounts
   - Fields: `id`, `menuId`, `diskonId`, `createdAt`

#### Repository Interface

**`i_diskon_repository.dart`** - Contract for data operations

- `createDiskon()` - Requires stanId parameter
- `getDiskonsByStan()` - Get all/active discounts per canteen
- `updateDiskon()` - Update discount fields
- `deleteDiskon()` - Remove discount
- Helper methods: `linkDiskonToMenu()`, `getDiskonForMenu()`, etc.

#### Use Cases

1. **`create_diskon_usecase.dart`** - Create new discount

   ```dart
   CreateDiskonParams(
     stanId: String,
     namaDiskon: String,
     persentaseDiskon: double,
     tanggalAwal: DateTime,
     tanggalAkhir: DateTime,
   )
   ```

2. **`get_diskons_by_stan_usecase.dart`** - Get discounts for specific canteen
   - Supports `activeOnly` flag to filter only valid discounts

3. **`update_diskon_usecase.dart`** - Update discount properties
   - All fields optional except `diskonId`

4. **`delete_diskon_usecase.dart`** - Delete discount by ID

5. **`assign_diskon_to_menus_usecase.dart`** - Assign discount to menu items

### Data Layer (`lib/features/diskon/data/`)

#### Models

**`diskon_model.dart`** - Firestore serialization

- `fromFirestore()` - Convert DocumentSnapshot to DiskonModel
- `toFirestore()` - Convert to Map for Firestore
- `fromJson()` / `toJson()` - JSON serialization
- `fromEntity()` / `toEntity()` - Convert between model and entity
- **All methods include stanId field**

**`menu_diskon_model.dart`** - Junction table model

- Similar serialization methods
- Includes `createdAt` timestamp

#### Datasource

**`diskon_datasource.dart`** - Firebase Firestore operations

- `createDiskon()` - Creates document with stanId in 'diskon' collection
- `getDiskonsByStan()` - Queries by stanId with optional activeOnly filter
- `updateDiskon()` - Updates specific fields
- `deleteDiskon()` - Deletes document
- Junction operations: `linkDiskonToMenu()`, `unlinkDiskonFromMenu()`, etc.

**Collections Used:**

- `diskon` - Main discount storage
- `menu_diskon` - Menu-Discount relationships

#### Repository Implementation

**`diskon_repository.dart`** - Implements IDiskonRepository

- Wraps datasource calls with Either<Failure, T> pattern
- Converts exceptions to Failures
- Transforms models to entities

### Presentation Layer (`lib/features/diskon/presentation/`)

#### BLoC

**Events** (`diskon_management_event.dart`):

- `LoadDiskons` - Load all discounts for canteen
- `CreateDiskonEvent` - Create new discount
- `UpdateDiskonEvent` - Update existing discount
- `DeleteDiskonEvent` - Delete discount
- `ToggleDiskonStatusEvent` - Activate/deactivate (future use)
- `AssignDiskonToMenusEvent` - Link discount to menus

**States** (`diskon_management_state.dart`):

- `DiskonManagementInitial`
- `DiskonManagementLoading`
- `DiskonManagementLoaded` - Contains `diskons`, `activeDiskons`, `expiredDiskons`
- `DiskonCreatedSuccess` / `UpdatedSuccess` / `DeletedSuccess`
- `DiskonManagementError`

**Bloc** (`diskon_management_bloc.dart`):

- Auto-categorizes discounts into active/expired lists
- Auto-reloads after create/delete operations
- Handles all CRUD events with proper error handling

#### UI Screen

**`diskon_management_screen.dart`** - Admin interface

- **TabView**: Semua | Aktif | Kadaluarsa
- **Features**:
  - Create discount dialog with date pickers
  - Edit discount with pre-filled data
  - Delete confirmation dialog
  - Card-based list view showing:
    - Discount percentage badge
    - Status badge (AKTIF/KADALUARSA)
    - Date range
    - Popup menu for edit/delete
  - Pull-to-refresh
  - Floating action button for create

### Menu Entity Extensions (`lib/features/menu/domain/entities/`)

**`menu_extensions.dart`** - Helper functions for discount calculations

- `MenuDiskonExtension`:
  - `calculateDiscountedPrice()` - Final price after discount
  - `calculateDiscountAmount()` - Discount value
  - `hasValidDiskon()` - Check if discount is valid
  - `getDiscountLabel()` - "X% OFF" text
  - `formatPriceWithDiskon()` - Formatted price string

- `MenuDiskonHelper`:
  - `calculateTotalPrice()` - Total for multiple items
  - `calculateTotalDiscountAmount()` - Total savings
  - `groupByDiscount()` - Separate items with/without discount

- `MenuDiskonPair`:
  - Combines Menu + Diskon + quantity
  - Properties: `subtotal`, `discountAmount`, `originalPrice`

### Admin Dashboard Integration

**`admin_dashboard_screen.dart`** updates:

1. Added drawer menu item "Kelola Diskon" with icon `Icons.local_offer_outlined`
2. Added route case `'discounts'`
3. Provides DiskonManagementBloc via BlocProvider
4. Passes `stanId` to DiskonManagementScreen

### Dependency Injection (`injection_container.dart`)

**Registered:**

1. **Datasource**: `DiskonRemoteDatasourceImpl`
2. **Repository**: `DiskonRepository` → `IDiskonRepository`
3. **Use Cases**:
   - `CreateDiskonUseCase`
   - `GetDiskonsByStanUseCase`
   - `UpdateDiskonUseCase`
   - `DeleteDiskonUseCase`
4. **Bloc**: `DiskonManagementBloc` (Factory)

## Key Design Decisions

### 1. Per-Canteen Scoping

- **Problem**: Initial design had global discounts
- **Solution**: Added `stanId` field to Diskon entity
- **Impact**: Changed `getAllDiskon()` to `getDiskonsByStan(stanId)`
- **Benefit**: Discounts are isolated per canteen, matching business requirement

### 2. Active/Expired Auto-Categorization

- Bloc automatically separates discounts based on date range
- No `isActive` boolean flag needed
- Validation happens in entity: `isValid` getter checks date range

### 3. Extension Methods for Calculations

- Instead of modifying Menu entity, created extension
- Clean separation of concerns
- Easy to test discount calculations
- Helper classes for complex scenarios (cart, checkout)

### 4. Junction Table Pattern

- `menu_diskon` collection for many-to-many relationship
- One menu can have multiple discounts (if needed)
- One discount can apply to multiple menus

## Firestore Schema

### Collection: `diskon`

```json
{
  "stanId": "stan123",
  "namaDiskon": "Promo Ramadan",
  "persentaseDiskon": 15.0,
  "tanggalAwal": Timestamp,
  "tanggalAkhir": Timestamp,
  "createdAt": Timestamp
}
```

### Collection: `menu_diskon`

```json
{
  "menuId": "menu456",
  "diskonId": "diskon789",
  "createdAt": Timestamp
}
```

## Usage Example

### Create Discount (Admin)

1. Admin navigates to "Kelola Diskon" from drawer
2. Clicks FAB "Tambah Diskon"
3. Fills form: Name, Percentage, Start Date, End Date
4. Bloc dispatches `CreateDiskonEvent`
5. Repository saves to Firestore with `stanId`
6. UI auto-refreshes showing new discount

### View Discounted Menu (Student)

1. Student browses menu
2. App fetches menu items for canteen
3. For each menu, fetch active discount: `getDiskonForMenu(menuId)`
4. Calculate price: `menu.calculateDiscountedPrice(diskon)`
5. Display with strikethrough original price if discounted

### Apply Discount in Cart

1. Cart items stored as `MenuDiskonPair`
2. Calculate subtotal: `pair.subtotal` (already includes discount)
3. Display savings: `pair.discountAmount`
4. Total: Sum of all `pair.subtotal`

## Files Created/Modified

### Created

1. ✅ `lib/features/diskon/domain/entities/diskon.dart` (updated with stanId)
2. ✅ `lib/features/diskon/domain/entities/menu_diskon.dart` (cleaned)
3. ✅ `lib/features/diskon/data/models/diskon_model.dart` (all 8 methods updated)
4. ✅ `lib/features/diskon/domain/usecases/create_diskon_usecase.dart`
5. ✅ `lib/features/diskon/domain/usecases/get_diskons_by_stan_usecase.dart`
6. ✅ `lib/features/diskon/domain/usecases/update_diskon_usecase.dart`
7. ✅ `lib/features/diskon/domain/usecases/delete_diskon_usecase.dart`
8. ✅ `lib/features/diskon/domain/usecases/assign_diskon_to_menus_usecase.dart`
9. ✅ `lib/features/diskon/presentation/bloc/diskon_management_event.dart`
10. ✅ `lib/features/diskon/presentation/bloc/diskon_management_state.dart`
11. ✅ `lib/features/diskon/presentation/bloc/diskon_management_bloc.dart`
12. ✅ `lib/features/diskon/presentation/screens/diskon_management_screen.dart`
13. ✅ `lib/features/menu/domain/entities/menu_extensions.dart`

### Modified

1. ✅ `lib/features/diskon/domain/repositories/i_diskon_repository.dart` (stanId params)
2. ✅ `lib/features/diskon/data/datasources/diskon_datasource.dart` (stanId support)
3. ✅ `lib/features/diskon/data/repositories/diskon_repository.dart` (stanId implementation)
4. ✅ `lib/features/admin/presentation/screens/admin_dashboard_screen.dart` (navigation)
5. ✅ `lib/core/di/injection_container.dart` (DI registration)

## Testing Checklist

### Unit Tests Needed

- [ ] Diskon entity validation (isValid, isExpired)
- [ ] DiskonModel serialization/deserialization
- [ ] Use cases parameter validation
- [ ] MenuDiskonExtension calculations
- [ ] MenuDiskonHelper total calculations

### Integration Tests Needed

- [ ] Create discount flow
- [ ] Get discounts by stan
- [ ] Update discount
- [ ] Delete discount
- [ ] Link/unlink discount to menu

### UI Tests Needed

- [ ] Create discount dialog
- [ ] Tab switching (Semua/Aktif/Kadaluarsa)
- [ ] Edit discount
- [ ] Delete confirmation
- [ ] Pull to refresh

## Next Steps / Future Enhancements

1. **Assign Discount to Menu UI**
   - Add button in DiskonManagementScreen to select menus
   - Multi-select menu picker dialog
   - Show assigned menus count in card

2. **Student View**
   - Update menu list to show discount badge
   - Strikethrough original price
   - Highlight discounted items

3. **Discount Analytics**
   - Track how many times discount used
   - Revenue impact calculation
   - Most popular discounts report

4. **Advanced Features**
   - Minimum purchase amount for discount
   - Maximum discount cap
   - Discount codes (coupon system)
   - First-time buyer discounts

## Error Handling

All operations return `Either<Failure, T>`:

- **ServerFailure**: Firestore errors
- **ValidationFailure**: Invalid parameters
- **NotFoundFailure**: Discount doesn't exist

UI shows SnackBar with error messages for user feedback.

## Performance Considerations

1. **Firestore Queries**:
   - Indexed by `stanId` + `createdAt`
   - Use `activeOnly` flag to reduce data transfer

2. **Caching**:
   - BLoC maintains state to avoid re-fetching
   - Discounts cached until user navigates away

3. **Pagination** (Future):
   - Currently loads all discounts
   - Consider pagination for canteens with 100+ discounts

## Security

- Admin-only feature (requires `isAdminStan` role)
- Discounts scoped by `stanId` - admin can only manage their own canteen
- Firestore rules should enforce:
  ```javascript
  match /diskon/{diskonId} {
    allow read: if request.auth != null;
    allow write: if request.auth != null &&
                   request.auth.token.isAdminStan == true &&
                   request.resource.data.stanId == getUserStanId();
  }
  ```

---

**Implementation Status**: ✅ Complete

**Last Updated**: 2025-02-02

**Author**: GitHub Copilot + Developer
