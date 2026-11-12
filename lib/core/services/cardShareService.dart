import 'package:ridlers/index.dart';

/// Business logic for sharing bank cards with other customers.
///
/// Owners create [CardShare] invitations; invitees accept or reject them.
/// Invitees can request card withdrawals, which owners approve with their
/// PIN. All mutations are persisted locally through [StorageService]. When
/// the backend is ready, each method also calls the corresponding
/// [CardShareApi] endpoint.
class CardShareService {
  CardShareService(this.bloc);

  final WalletBloc bloc;

  /// Hydrates the bloc from local storage.
  Future<void> load() async {
    bloc.setCardShares(await StorageService.loadCardShares());
    bloc.setWithdrawalRequests(await StorageService.loadWithdrawalRequests());
  }

  /// The current user shares one of their cards with [inviteePhone].
  ///
  /// The owner's [pin] is required and verified before the invitation is
  /// created. Returns `null` when the PIN is wrong.
  Future<CardShare?> shareCard({
    required String cardId,
    required String cardName,
    required String cardBankName,
    required String cardLast4,
    required String cardColor,
    required String inviteePhone,
    required String pin,
  }) async {
    if (!await authService.verifyPin(pin)) return null;
    final ownerPhone = systemBloc.phone;
    final share = CardShare(
      id: Functions.generateId(),
      cardId: cardId,
      cardName: cardName,
      cardBankName: cardBankName,
      cardLast4: cardLast4,
      cardColor: cardColor,
      ownerPhone: ownerPhone,
      inviteePhone: inviteePhone,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final shares = [...bloc.cardShares, share];
    await _persistShares(shares);

    // TODO: Call CardShareApi.shareCard(...) when backend is ready.
    return share;
  }

  /// The invitee accepts a pending [shareId].
  Future<void> acceptShare(String shareId) async {
    if (bloc.cardShares.every((s) => s.id != shareId)) return;
    final shares = bloc.cardShares
        .map((s) => s.id == shareId ? s.copyWith(status: 'accepted') : s)
        .toList();
    await _persistShares(shares);

    // TODO: Call CardShareApi.acceptShare(...) when backend is ready.
  }

  /// The invitee rejects a pending [shareId].
  Future<void> rejectShare(String shareId) async {
    if (bloc.cardShares.every((s) => s.id != shareId)) return;
    final shares = bloc.cardShares
        .map((s) => s.id == shareId ? s.copyWith(status: 'rejected') : s)
        .toList();
    await _persistShares(shares);

    // TODO: Call CardShareApi.rejectShare(...) when backend is ready.
  }

  /// The invitee asks the [ownerPhone] to approve a withdrawal from a
  /// shared card. No money moves until the owner approves.
  Future<WithdrawalRequest> requestWithdrawal({
    required String cardId,
    required String cardName,
    required String cardBankName,
    required String cardLast4,
    required String ownerPhone,
    required double amount,
  }) async {
    final requesterPhone = systemBloc.phone;
    final request = WithdrawalRequest(
      id: Functions.generateId(),
      cardId: cardId,
      cardName: cardName,
      cardBankName: cardBankName,
      cardLast4: cardLast4,
      ownerPhone: ownerPhone,
      requesterPhone: requesterPhone,
      amount: amount,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final requests = [...bloc.withdrawalRequests, request];
    await _persistRequests(requests);

    // TODO: Call CardShareApi.requestWithdrawal(...) when backend is ready.
    return request;
  }

  /// The owner approves a pending [requestId]: the card is debited and the
  /// money lands in the wallet. Returns `false` when the PIN is wrong or the
  /// card can't cover the amount.
  Future<bool> approveWithdrawal(
    String requestId, {
    required String pin,
  }) async {
    if (!await authService.verifyPin(pin)) return false;
    final idx = bloc.withdrawalRequests.indexWhere((r) => r.id == requestId);
    if (idx == -1) return false;
    final request = bloc.withdrawalRequests[idx];
    if (!request.isPending) return false;

    if (!await walletService.withdrawFromCard(
      cardId: request.cardId,
      amount: request.amount,
    )) {
      return false;
    }

    final requests = bloc.withdrawalRequests
        .map((r) => r.id == requestId ? r.copyWith(status: 'accepted') : r)
        .toList();
    await _persistRequests(requests);

    // TODO: Call CardShareApi.approveWithdrawal(...) when backend is ready.
    return true;
  }

  /// The owner rejects a pending withdrawal request.
  Future<void> rejectWithdrawal(String requestId) async {
    if (bloc.withdrawalRequests.every((r) => r.id != requestId)) return;
    final requests = bloc.withdrawalRequests
        .map((r) => r.id == requestId ? r.copyWith(status: 'rejected') : r)
        .toList();
    await _persistRequests(requests);

    // TODO: Call CardShareApi.rejectWithdrawal(...) when backend is ready.
  }

  Future<void> _persistShares(List<CardShare> shares) async {
    bloc.setCardShares(shares);
    await StorageService.saveCardShares(shares);
  }

  Future<void> _persistRequests(List<WithdrawalRequest> requests) async {
    bloc.setWithdrawalRequests(requests);
    await StorageService.saveWithdrawalRequests(requests);
  }
}