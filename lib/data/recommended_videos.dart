import '../models/shared_video_model.dart'; // SharedVideoModel をインポート

/// グローバルで利用可能な推奨動画のリスト
final List<SharedVideoModel> recommendedVideos = [
  SharedVideoModel(
    id: 'W54Y0cn78NY',
    url: 'https://www.youtube.com/watch?v=W54Y0cn78NY',
    title: 'the best of Tony Stark (IRON MAN)',
    channelName: 'ALCHEMY',
    thumbnailUrl: 'https://i.ytimg.com/vi/W54Y0cn78NY/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    // titleJa は SharedVideoModel にはないため、必要であれば captionsWithTimestamps などに格納するか、
    // モデル自体を拡張することを検討。ここでは title をそのまま利用。
  ),
  SharedVideoModel(
    id: '7fvCb5_Nzq4',
    url: 'https://www.youtube.com/watch?v=7fvCb5_Nzq4',
    title: 'Learning Japanese Isnt Actually That Hard',
    channelName: 'Trenton《トレントン》',
    thumbnailUrl: 'https://i.ytimg.com/vi/7fvCb5_Nzq4/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: 'pnH0BHaDyIo',
    url: 'https://www.youtube.com/watch?v=pnH0BHaDyIo',
    title:
        '【葬送のフリーレン1話】美しいのに悲しい… 堪えきれなくなって泣いてしまうジャミネキ【海外の反応】【英語学習】【英語解説】【英語字幕】【REACTS】',
    channelName: 'セカスト翻訳【別コーディネート】',
    thumbnailUrl: 'https://i.ytimg.com/vi/pnH0BHaDyIo/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: 'oakWgLqCwUc',
    url: 'https://www.youtube.com/watch?v=oakWgLqCwUc',
    title: 'Milk. White Poison or Healthy Drink?',
    channelName: 'Kurzgesagt – In a Nutshell',
    thumbnailUrl: 'https://i.ytimg.com/vi/oakWgLqCwUc/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),

  SharedVideoModel(
    id: '3zGM3WE3FSo',
    url: 'https://www.youtube.com/watch?v=3zGM3WE3FSo',
    title:
        'Frieren: Beyond Journey\'s End -Frieren vs Aura the Guillotine Full Fight',
    channelName: 'AnimeClips',
    thumbnailUrl: 'https://i.ytimg.com/vi/3zGM3WE3FSo/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: 'eIho2S0ZahI',
    url: 'https://www.youtube.com/watch?v=eIho2S0ZahI',
    title: 'How to Speak So That People Want to Listen',
    channelName: 'TED',
    thumbnailUrl: 'https://i.ytimg.com/vi/eIho2S0ZahI/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: 'jf-SbSfiXn4',
    url: 'https://www.youtube.com/watch?v=jf-SbSfiXn4',
    title: 'Why Im Quitting the Japanese Duolingo Course (An Honest Review)',
    channelName: 'Livakivi',
    thumbnailUrl: 'https://i.ytimg.com/vi/jf-SbSfiXn4/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: 'UF8uR6Z6KLc',
    url: 'https://www.youtube.com/watch?v=UF8uR6Z6KLc',
    title: "Steve Jobs' 2005 Stanford Commencement Address",
    channelName: 'Stanford University',
    thumbnailUrl: 'https://i.ytimg.com/vi/UF8uR6Z6KLc/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: 'wubITdJ_MCw',
    url: 'https://www.youtube.com/watch?v=wubITdJ_MCw',
    title:
        'Full Speech: Elon Musk speaks at Donald Trump inauguration rally, gives \'salute\'',
    channelName: '9NEWS',
    thumbnailUrl: 'https://i.ytimg.com/vi/wubITdJ_MCw/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: 'LmpuerlbJu0',
    url: 'https://www.youtube.com/watch?v=LmpuerlbJu0',
    title: 'You Are Immune Against Every Disease',
    channelName: 'Kurzgesagt – In a Nutshell',
    thumbnailUrl: 'https://i.ytimg.com/vi/LmpuerlbJu0/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: '4czjS9h4Fpg',
    url: 'https://www.youtube.com/watch?v=4czjS9h4Fpg',
    title: 'Perseverance Rover\'s Descent and Touchdown on Mars',
    channelName: 'NASA',
    thumbnailUrl: 'https://i.ytimg.com/vi/4czjS9h4Fpg/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: 'XPx7yQD95Mc',
    url: 'https://www.youtube.com/watch?v=XPx7yQD95Mc',
    title: 'How to Make Perfect Creamy Scrambled Eggs',
    channelName: 'Gordon Ramsay',
    thumbnailUrl: 'https://i.ytimg.com/vi/XPx7yQD95Mc/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: 'loiha3kRsoY',
    url: 'https://www.youtube.com/watch?v=loiha3kRsoY',
    title: 'Why is HD 1080p? | Nostalgia Nerd',
    channelName: 'Nostalgia Nerd',
    thumbnailUrl: 'https://i.ytimg.com/vi/loiha3kRsoY/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: '7YX7PAdo4B0',
    url: 'https://www.youtube.com/watch?v=7YX7PAdo4B0',
    title:
        'how I LEARNED A LANGUAGE by myself WITHOUT STUDYING it | language tips from a POLYGLOT',
    channelName: 'Ruri Ohama',
    thumbnailUrl: 'https://i.ytimg.com/vi/7YX7PAdo4B0/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

/// 日本語学習者向けの推奨動画のリスト
final List<SharedVideoModel> recommendedVideosJa = [
  SharedVideoModel(
    id: '0cY1QaRTWM8',
    url: 'https://www.youtube.com/watch?v=0cY1QaRTWM8',
    title: '【Room Tour】A Japanese Manga Artist\'s Desk Tour',
    channelName: 'Tobalog_tokyo | トバログ',
    thumbnailUrl: 'https://i.ytimg.com/vi/0cY1QaRTWM8/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  // ゆる言語学ラジオ – ことば系雑談（全編日本語＋手動字幕）
  SharedVideoModel(
    id: '2YY9DT4uDh0',
    url: 'https://www.youtube.com/watch?v=2YY9DT4uDh0',
    title: '「イルカも喋る」は大ウソ【言語学って何？】#1',
    channelName: 'ゆる言語学ラジオ',
    thumbnailUrl: 'https://i.ytimg.com/vi/2YY9DT4uDh0/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),

  SharedVideoModel(
    id: 'qDYNcFzYV68',
    url: 'https://www.youtube.com/watch?v=qDYNcFzYV68',
    title: 'Room Tour - Japanese 3DCG Animation Artist\'s Work Room and Desk',
    channelName: 'Tobalog_tokyo | トバログ',
    thumbnailUrl: 'https://i.ytimg.com/vi/qDYNcFzYV68/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: '1tsS-A_g0As',
    url: 'https://www.youtube.com/watch?v=1tsS-A_g0As',
    title: 'まるで詩のような科学本『クジラと話す方法』が最高。【#297】',
    channelName: 'ゆる言語学ラジオ',
    thumbnailUrl: 'https://i.ytimg.com/vi/1tsS-A_g0As/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),

  SharedVideoModel(
    id: 'wfhT3_Z42FM',
    url: 'https://www.youtube.com/watch?v=wfhT3_Z42FM',
    title:
        '10 Things Suisei Hoshimachi Can\'t Live Without | 10 Essentials | GQ JAPAN',
    channelName: 'GQ JAPAN',
    thumbnailUrl: 'https://i.ytimg.com/vi/wfhT3_Z42FM/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),

  // Onomappu – 人気のゆっくり日本語解説（日本語&多言語字幕）
  SharedVideoModel(
    id: 'DACyYF4NpC8',
    url: 'https://www.youtube.com/watch?v=DACyYF4NpC8',
    title: 'Teaching You Actual Japanese Slang Used in Daily Life',
    channelName: 'Onomappu',
    thumbnailUrl: 'https://i.ytimg.com/vi/DACyYF4NpC8/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: 'h39VzDrAMYk',
    url: 'https://www.youtube.com/watch?v=h39VzDrAMYk',
    title: 'Memorizing Japanese Vocabulary the Scientific Way',
    channelName: 'Onomappu',
    thumbnailUrl: 'https://i.ytimg.com/vi/h39VzDrAMYk/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),

  // Comprehensible Japanese – 初級向け CI（手動日本語＋簡易ルビ）
  SharedVideoModel(
    id: 'IC5RHt8unAI',
    url: 'https://www.youtube.com/watch?v=IC5RHt8unAI',
    title: 'Toast – Complete Beginner Japanese (Comprehensible Input)',
    channelName: 'Comprehensible Japanese',
    thumbnailUrl: 'https://i.ytimg.com/vi/IC5RHt8unAI/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  SharedVideoModel(
    id: 'jZ5nqjqAT7c',
    url: 'https://www.youtube.com/watch?v=jZ5nqjqAT7c',
    title: 'BALL / Let’s learn Japanese with a ball【Beginner】',
    channelName: 'Comprehensible Japanese',
    thumbnailUrl: 'https://i.ytimg.com/vi/jZ5nqjqAT7c/hqdefault.jpg',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];
