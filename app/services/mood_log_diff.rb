class MoodLogDiff
  # 保存前後の状態を確認して返り値を決める
  def self.diff(old, new)
    case
    when old.nil? && new.nil?
      { action: :none, log: nil }
    when old.nil? && new.present?
      { action: :prepend, log: new }
    when old.present? && new.nil?
      { action: :remove, log: old }
    when old.present? && new.present?
      { action: :replace, log: new }
    end
  end
end
