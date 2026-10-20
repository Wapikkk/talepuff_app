class RelativeTime {
  RelativeTime._();

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static String format(DateTime then, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final difference = current.difference(then);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} h ago';
    if (difference.inDays < 7) return '${difference.inDays} d ago';

    final date = '${then.day} ${_months[then.month - 1]}';
    return then.year == current.year ? date : '$date ${then.year}';
  }
}
