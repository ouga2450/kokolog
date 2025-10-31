module MoodsHelper
  # 絵文字マッピング（label -> emoji）
  MOOD_EMOJI_BY_LABEL = {
    "very_good" => "🤩",
    "good"      => "😊",
    "neutral"   => "😐",
    "bad"       => "😕",
    "very_bad"  => "😞"
  }.freeze

  # スコアとラベルの対応（0..4）
  MOOD_LABEL_BY_SCORE = {
    0 => "very_bad",
    1 => "bad",
    2 => "neutral",
    3 => "good",
    4 => "very_good"
  }.freeze

  # labelから絵文字
  def emoji_for_label(label)
    MOOD_EMOJI_BY_LABEL[label.to_s]
  end

  # scoreから絵文字
  def emoji_for_score(score)
    label = MOOD_LABEL_BY_SCORE[score.to_i]
    emoji_for_label(label)
  end

  # Moodまたはlabel文字列から絵文字
  def emoji_for_mood(mood)
    return if mood.nil?
    label = mood.respond_to?(:label) ? mood.label : mood.to_s
    emoji_for_label(label)
  end

  # 日本語表示用ラベル（label -> ja）
  def jp_label_for_label(label)
    map = {
      "very_good" => "最高",
      "good"      => "良い",
      "neutral"   => "普通",
      "bad"       => "悪い",
      "very_bad"  => "最悪"
    }
    map[label.to_s] || label.to_s
  end

  # score -> 日本語表示ラベル
  def jp_label_for_score(score)
    jp_label_for_label(MOOD_LABEL_BY_SCORE[score.to_i])
  end

  # Mood -> 日本語表示ラベル
  def jp_label_for_mood(mood)
    return if mood.nil?
    jp_label_for_label(mood.label)
  end
end

