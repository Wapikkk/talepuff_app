/// Argumen untuk membuka detail cerita. [autoPlay] langsung memutarnya di HP (mis. dari tombol "Putar cerita terakhir").
class StoryDetailArgs {
  final int id;
  final bool autoPlay;
  const StoryDetailArgs(this.id, {this.autoPlay = false});
}
