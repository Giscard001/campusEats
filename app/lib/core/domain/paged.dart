import 'package:equatable/equatable.dart';

class PagedResult<T> extends Equatable {
  const PagedResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int total;

  bool get hasMore => page * limit < total;

  @override
  List<Object?> get props => [items, page, limit, total];
}
