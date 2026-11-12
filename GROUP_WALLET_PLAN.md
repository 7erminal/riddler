# Group Wallet Feature — Implementation Plan

## Goal
Introduce a "group wallet" — a wallet owned by multiple people. Members are invited via phone number, must confirm/reject the invitation, and confirmed members gain shared access. The wallets page gets a tab to switch between individual and group wallets.

---

## Phase 1 — Data Models

### 1a. New file: `lib/infrastructure/models/groupWalletModel.dart`

Two new classes:

**`GroupMember`** — represents one invited member
| Field | Type | Default | Notes |
|---|---|---|---|
| `id` | `String` | required | Unique member ID |
| `phone` | `String` | required | Phone number |
| `name` | `String` | `''` | Display name (populated after backend lookup) |
| `role` | `String` | `'member'` | `'owner'` / `'admin'` / `'member'` |
| `status` | `String` | `'pending'` | `'pending'` / `'accepted'` / `'rejected'` |
| `joinedAt` | `DateTime?` | `null` | Set when accepted |

Methods: `copyWith`, `fromJson`, `toJson`, getters `isAccepted`, `isPending`.

**`GroupWallet`** — the shared wallet
| Field | Type | Default | Notes |
|---|---|---|---|
| `id` | `String` | required | Unique wallet ID |
| `name` | `String` | required | Wallet name |
| `color` | `String` | `'mint'` | Color key |
| `ownerId` | `String` | required | Phone of the creator |
| `members` | `List<GroupMember>` | `[]` | All invited members |
| `subWallets` | `List<SubWallet>` | `[]` | Same pocket model as regular wallets |
| `totalBalance` | `double` | `0` | Total money in wallet |
| `createdAt` | `DateTime` | required | Creation timestamp |

Computed: `allocatedPercent`, `remainingPercent`, `mainBalance` — same as `Wallet`. Getters: `acceptedMembers`, `pendingMembers`, `memberCount`.

Methods: `copyWith`, `fromJson`, `toJson`.

### 1b. Update `lib/infrastructure/models/index.dart`
Add: `export 'groupWalletModel.dart';`

---

## Phase 2 — Storage Layer

### 2a. Update `lib/core/services/storageService.dart`

Add a new key: `static const _groupWalletsKey = 'ridlers_group_wallets';`

Add two static methods:
- `saveGroupWallets(List<GroupWallet> wallets)` — serializes to JSON, saves under `_groupWalletsKey`
- `loadGroupWallets()` — deserializes from JSON, returns `List<GroupWallet>`

Pattern matches existing `saveWallets`/`loadWallets` exactly.

---

## Phase 3 — Bloc Layer

### 3a. Update `lib/infrastructure/blocs/walletBloc.dart`

New private state field:
- `_groupWallets` = `List<GroupWallet>` (unmodifiable)

New getter:
- `groupWallets` → `UnmodifiableListView(_groupWallets)`

New methods:
- `setGroupWallets(List<GroupWallet> wallets)` — replaces list, calls `notifyListeners()`
- `groupWalletById(String id)` — lookup by ID

---

## Phase 4 — API Boilerplate (frontend bypass)

### 4a. New file: `lib/core/api_services/groupWalletApi.dart`

Static methods that call `ApisCaller.postData`/`getData` etc. For now each method returns a placeholder result (simulated success). The method signatures and endpoint paths are defined so a backend dev can wire them up:

| Method | HTTP | Endpoint | Purpose |
|---|---|---|---|
| `createGroupWallet(name, members)` | POST | `/api/group-wallets/` | Create + send invites |
| `getGroupWallets()` | GET | `/api/group-wallets/` | Fetch user's group wallets |
| `getGroupWallet(id)` | GET | `/api/group-wallets/{id}/` | Fetch single group wallet |
| `inviteMember(walletId, phone)` | POST | `/api/group-wallets/{id}/invite/` | Add member |
| `removeMember(walletId, memberId)` | DELETE | `/api/group-wallets/{id}/members/{memberId}/` | Remove member |
| `acceptInvite(walletId, phone)` | POST | `/api/group-wallets/{id}/accept/` | Accept invitation |
| `rejectInvite(walletId, phone)` | POST | `/api/group-wallets/{id}/reject/` | Reject invitation |
| `verifyPhone(phone)` | GET | `/api/verify-phone/{phone}/` | Check phone exists in system |

Each method accepts an optional `builder` function (matching existing `ApiServices` pattern). For now, return `ServerFailure('Not connected')` as a placeholder — this makes it clear the backend isn't wired yet while preserving the correct interface.

### 4b. Export in `lib/core/api_services/index.dart` (create if needed, or add to existing)

---

## Phase 5 — Service Layer

### 5a. New file: `lib/core/services/groupWalletService.dart`

Takes `WalletBloc` as dependency (same pattern as `WalletService`).

**`load()`** — hydrates bloc from local storage:
```dart
bloc.setGroupWallets(await StorageService.loadGroupWallets());
```

**`createGroupWallet({name, color, memberPhones})`** — the main creation flow:
1. Create `GroupWallet` with `ownerId = systemBloc.phone`
2. Create `GroupMember` entries for each phone with `status: 'pending'` (owner auto-accepted)
3. Add the owner as an accepted member
4. Save locally via `StorageService`
5. TODO: Call `GroupWalletApi.createGroupWallet(...)` when backend is ready
6. Return the created wallet

**`acceptInvite(String walletId)`** — the current user accepts:
1. Find the group wallet, find the member entry matching `systemBloc.phone`
2. Set status to `'accepted'`, set `joinedAt`
3. Persist
4. TODO: Call `GroupWalletApi.acceptInvite(...)`

**`rejectInvite(String walletId)`** — the current user rejects:
1. Find member entry, set status to `'rejected'`
2. Persist
3. TODO: Call `GroupWalletApi.rejectInvite(...)`

**`addMember(String walletId, String phone)`** — owner adds a member:
1. Create `GroupMember` with `status: 'pending'`
2. Persist
3. TODO: Call `GroupWalletApi.inviteMember(...)`

**`removeMember(String walletId, String memberId)`** — owner removes a member:
1. Filter out the member
2. Persist
3. TODO: Call `GroupWalletApi.removeMember(...)`

**`deleteGroupWallet(String walletId)`** — owner deletes:
1. Filter out the wallet (only if owner)
2. Persist

---

## Phase 6 — Global Wiring

### 6a. Update `lib/core/utils/constants.dart`
Add: `GroupWalletService groupWalletService = GroupWalletService(walletBloc);`

### 6b. Update `WalletService.load()`
Add: `bloc.setGroupWallets(await StorageService.loadGroupWallets());`

### 6c. Update `lib/core/services/index.dart`
Add: `export 'groupWalletService.dart';`

---

## Phase 7 — UI: Wallet Creation Flow

### 7a. Update `showAddWalletSheet` in `lib/interface/widgets/sheets.dart`

Add a toggle/chip at the top of the sheet: **"Individual"** vs **"Group"** (default: Individual).

When **Group** is selected:
1. Show the same name + color fields
2. Below color, add a "Members" section:
   - A text field + "Add" button for entering phone numbers
   - Added numbers appear as chips/tags below the field
   - Each chip has an ✕ to remove
3. Phone validation: must be at least 9 digits, no duplicates
4. "Create wallet" button calls `groupWalletService.createGroupWallet(...)` instead of `walletService.addWallet(...)`

When **Individual** is selected:
- Existing flow unchanged

State additions in `_AddWalletSheetState`:
- `_isGroup = false` — toggle
- `_memberPhones = <String>[]` — list of entered phones
- `_phoneController` — text controller for phone input
- `_addPhone()` — validates and adds to list
- `_removePhone(index)` — removes from list

---

## Phase 8 — UI: Wallets Page Tab Switcher

### 8a. Update `lib/interface/screens/wallet.dart`

Convert `WalletScreen` from `StatelessWidget` to `StatefulWidget` (to hold tab state).

Add a `_selectedTab` state: `0` = Individual, `1` = Group.

Insert below the header (after the "YOUR WALLETS" label row), before the WalletSelector:

```
[Individual]  [Group]
```

Two `StickerButton` chips side by side. The selected tab has `AppTheme.primary` color, unselected has `AppTheme.surface`.

**Tab 0 (Individual):** Show the existing `WalletSelector` + full wallet detail (unchanged).

**Tab 1 (Group):** Show:
- A `GroupWalletSelector` (horizontal chips for group wallets + "New group" button)
- Below: selected group wallet detail (similar to individual but with member list)
- If no group wallets: empty state with "Create your first group wallet" CTA

---

## Phase 9 — UI: Group Wallet Display

### 9a. New widget in `lib/interface/widgets/groupWalletWidgets.dart`

**`GroupWalletSelector`** — horizontal chip list similar to `WalletSelector`:
- Chips show group wallet name + member count badge (👥 3)
- "New group" button at the end
- Selected state uses `themeColor(wallet.color)`

**`GroupMemberTile`** — one row per member:
- Status icon: ✅ accepted, ⏳ pending, ❌ rejected
- Name or phone number
- Role badge (owner/admin/member)
- Remove button (owner only, for non-owner members)

**`GroupWalletHeader`** — the total balance card for group wallets:
- Same design as individual wallet header (Sticker with themeColor)
- Shows total balance, allocation bar
- Below: member count + "View members" expandable

**`GroupWalletDetail`** — the full pocket view:
- Same as individual: MainWalletTile + SubWalletTile list
- Below pockets: "Members" section with GroupMemberTile list

---

## Phase 10 — UI: Pending Invitations

### 10a. Update Home screen to show pending group invitations

In `lib/interface/screens/home.dart`, add a section after the money overview (before cards) when there are pending group wallet invitations:

```
┌─────────────────────────────────┐
│ 👥 Group invitation             │
│ "Family Fund" — 3 members      │
│ [Accept]  [Reject]              │
└─────────────────────────────────┘
```

This uses a `Sticker` with `AppTheme.lavender` background, matching the design system.

Add to `WalletBloc`:
- `pendingGroupInvitations` getter — filters group wallets where the current user has a pending member entry

Add to `GroupWalletService`:
- `pendingInvitations()` — returns group wallets where `systemBloc.phone` has a pending member entry

---

## Phase 11 — Verification

1. `flutter analyze` — 0 errors/warnings (31 pre-existing info lints OK)
2. `flutter test` — all 25 tests pass
3. `flutter build macos --debug` — succeeds

---

## File Summary

| Action | File | What |
|---|---|---|
| NEW | `lib/infrastructure/models/groupWalletModel.dart` | GroupWallet + GroupMember models |
| EDIT | `lib/infrastructure/models/index.dart` | Add export |
| EDIT | `lib/infrastructure/blocs/walletBloc.dart` | Add groupWallets state + methods |
| EDIT | `lib/core/services/storageService.dart` | Add group wallet persistence |
| EDIT | `lib/core/services/walletService.dart` | Load group wallets in `load()` |
| NEW | `lib/core/services/groupWalletService.dart` | Group wallet business logic |
| EDIT | `lib/core/services/index.dart` | Add export |
| NEW | `lib/core/api_services/groupWalletApi.dart` | Backend boilerplate |
| EDIT | `lib/core/utils/constants.dart` | Add global service instance |
| EDIT | `lib/interface/widgets/sheets.dart` | Add group option to wallet creation sheet |
| EDIT | `lib/interface/screens/wallet.dart` | Add Individual/Group tab switcher |
| NEW | `lib/interface/widgets/groupWalletWidgets.dart` | GroupWalletSelector, GroupMemberTile, etc. |
| EDIT | `lib/interface/screens/home.dart` | Add pending invitation banner |
