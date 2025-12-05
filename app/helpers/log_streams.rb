module LogStreams
  MOOD_CARD_PARTIAL = {
    "home"  => "home/partials/card_mood_log_home",
    "index" => "logs/partials/card_mood_log_index"
  }.freeze

  EMPTY_CARD_PARTIAL = {
    "home"  => "home/partials/empty_card_home",
    "index" => "logs/partials/empty_card_index"
  }.freeze

  def render_streams(diffs, dom_from, log_exists:)
    return if diffs.blank?

    streams = %i[before after].filter_map do |timing|
      diff = diffs[timing][:action]
      log  = diffs[timing][:log]

      mood_stream_for(diff, log, dom_from, log_exists)
    end

    safe_join(streams)
  end

  private

  def mood_stream_for(diff, log, dom_from, log_exists)
    return if diff == :none

    # prepend ならリスト全体、その他はカード単体
    target = diff == :prepend ? "mood_logs_#{dom_from}" : dom_id(log, dom_from.to_sym)

    # empty の処理
    empty_state = empty_state(diff, dom_from, log_exists)

    stream =
      if diff == :remove
        turbo_stream.remove(target)
      else
        turbo_stream.public_send(diff, target) do
          render_mood_card(log, dom_from)
        end
      end

    [ empty_state, stream ].compact
  end

  def render_mood_card(log, dom_from)
    render MOOD_CARD_PARTIAL[dom_from], mood_log: log
  end

  def empty_state(diff, dom_from, log_exists)
    if !log_exists && diff == :remove
      turbo_stream.update "mood_logs_#{dom_from}_empty" do
        render EMPTY_CARD_PARTIAL[dom_from], msg: "気分ログ"
      end
    elsif log_exists && diff == :prepend
      turbo_stream.update("mood_logs_#{dom_from}_empty", "")
    else
      nil
    end
  end
end
