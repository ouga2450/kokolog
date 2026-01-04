module MoodsHelper
  # label -> SVGファイル名
  MOOD_SVG_BY_LABEL = {
    "very_good" => "very-good.svg",
    "good"      => "good.svg",
    "neutral"   => "neutral.svg",
    "bad"       => "sad.svg",
    "very_bad"  => "very-sad.svg"
  }.freeze

  # score -> label
  MOOD_LABEL_BY_SCORE = {
    1 => "very_bad",
    2 => "bad",
    3 => "neutral",
    4 => "good",
    5 => "very_good"
  }.freeze

  # ========== SVG絵文字 ==========
  # label -> SVG（絵文字感覚）
  def emoji_for_label(label)
    filename = MOOD_SVG_BY_LABEL[label.to_s]
    return unless filename

    inline_svg_tag(
      "moods/#{filename}",
      class: "mood-emoji",
      aria: { hidden: true }
    )
  end

  # score -> SVG
  def emoji_for_score(score)
    label = MOOD_LABEL_BY_SCORE[score.to_i]
    emoji_for_label(label)
  end

  # Mood or label -> SVG
  def emoji_for_mood(mood)
    return if mood.nil?
    label = mood.respond_to?(:label) ? mood.label : mood.to_s
    emoji_for_label(label)
  end

  # ========== 日本語ラベル ==========
  def jp_label_for_label(label)
    {
      "very_good" => "最高",
      "good"      => "良い",
      "neutral"   => "普通",
      "bad"       => "悪い",
      "very_bad"  => "最悪"
    }[label.to_s] || label.to_s
  end

  def jp_label_for_score(score)
    jp_label_for_label(MOOD_LABEL_BY_SCORE[score.to_i])
  end

  def jp_label_for_mood(mood)
    return if mood.nil?
    jp_label_for_label(mood.label)
  end
end
