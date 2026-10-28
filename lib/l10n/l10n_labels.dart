import '../core/language_preference.dart';
import '../core/mascots.dart';
import '../data/models/story.dart';
import '../data/models/totem.dart';
import '../ui/view_models/loading/loading_view_model.dart';
import 'app_localizations.dart';

extension AppLocalizationsLabels on AppLocalizations {
  String languageLabel(LanguagePreference preference) => switch (preference) {
        LanguagePreference.system => languageFollowDevice,
        LanguagePreference.english => languageEnglish,
        LanguagePreference.indonesian => languageIndonesian,
      };

  String mascotLabel(String id) => switch (id) {
        'Harimau' => mascotHarimau,
        'OrangUtan' => mascotOrangUtan,
        'Badak' => mascotBadak,
        'Burung' => mascotBurung,
        _ => Mascots.byId(id).id,
      };

  String feedbackCategoryLabel(String value) => switch (value) {
        'bug' => feedbackBug,
        'idea' => feedbackIdea,
        'other' => feedbackOther,
        _ => value,
      };

  String storyTabLabel(StoryTab tab) => switch (tab) {
        StoryTab.recent => storyTabRecent,
        StoryTab.favorites => storyTabFavorites,
        StoryTab.popular => storyTabPopular,
      };

  String themeLabel(String value) => switch (value) {
        'Daily' => themeDaily,
        'Friendship' => themeFriendship,
        'Adventure' => themeAdventure,
        'Feeling' => themeFeeling,
        _ => value,
      };

  String moodLabel(String value) => switch (value) {
        'Calm' => moodCalm,
        'Curious' => moodCurious,
        'Warm' => moodWarm,
        'Joyful' => moodJoyful,
        'Fantasy' => moodFantasy,
        'Cozy' => moodCozy,
        'Brave' => moodBrave,
        'Nature' => moodNature,
        _ => value,
      };

  String voiceLabel(String value) => switch (value) {
        'Warm' => voiceWarm,
        'Brave' => voiceBrave,
        'Gentle' => voiceGentle,
        'Character' => voiceCharacter,
        'Friendly' => voiceFriendly,
        'Neutral' => voiceNeutral,
        _ => value,
      };

  String lengthLabel(String value) {
    final minutes = int.tryParse(value.split(' ').first);
    return minutes == null ? value : lengthMinutes(minutes);
  }

  String loadingStageLabel(LoadingStage stage) => switch (stage) {
        LoadingStage.starting => loadingStarting,
        LoadingStage.writing => loadingWriting,
        LoadingStage.voice => loadingVoice,
        LoadingStage.done => loadingDone,
        LoadingStage.failed => loadingFailed,
      };

  String totemStateLabel(TotemStatus status) {
    if (!status.online) return totemOffline;
    return switch (status.state) {
      'idle' => totemStateIdle,
      'loading' => totemStateLoading,
      'playing' => totemStatePlaying,
      'paused' => totemStatePaused,
      'error' => totemStateError,
      _ => totemStateUnknown,
    };
  }

  String genderLabel(String value) => switch (value) {
        'male' => genderMale,
        'female' => genderFemale,
        'n/a' => genderNotSpecified,
        _ => value,
      };

  String interestLabel(String value) => switch (value) {
        'Sports' => interestSports,
        'Music' => interestMusic,
        'Art' => interestArt,
        'Science' => interestScience,
        'Nature' => interestNature,
        'Space' => interestSpace,
        'Magic' => interestMagic,
        'Reading' => interestReading,
        'Dancing' => interestDancing,
        'Games' => interestGames,
        _ => value,
      };
}
