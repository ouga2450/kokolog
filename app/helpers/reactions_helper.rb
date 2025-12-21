module ReactionsHelper
  def daily_mood_text(avg_mood, logs)
    return "今日はまだ記録がありません" if logs.blank?

    if avg_mood && avg_mood >= 3.5
      "気分の高い一日です"
    elsif avg_mood && avg_mood <= 2.5
      "無理せず過ごした一日です"
    else
      "落ち着いた一日です"
    end
  end

  def daily_achievement_text(achievement_rate)
    rate = achievement_rate.to_i

    if rate == 100
      "やり切れた一日でした。自分のペースを大切にできました"

    elsif rate > 0
      "今日の記録が残りました。小さな一歩で十分です"

    else
      "今日はまだ記録がありません"
    end
  end
end
