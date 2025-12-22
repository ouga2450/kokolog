puts "→ Reseeding moods..."

MoodLog.delete_all
Mood.delete_all

presets = [
  { score: 1, label: "very_bad",  color: "bg-blue-300" },
  { score: 2, label: "bad",       color: "bg-sky-300" },
  { score: 3, label: "neutral",   color: "bg-yellow-300" },
  { score: 4, label: "good",      color: "bg-orange-300" },
  { score: 5, label: "very_good", color: "bg-pink-300" }
]

presets.each do |attrs|
  Mood.create!(attrs)
end

puts "✅ Moods reseeded: #{Mood.count}"
